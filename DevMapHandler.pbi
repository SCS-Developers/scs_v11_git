; File: DevMapHandler.pbi

EnableExplicit

Procedure initDevMapHandler()
  PROCNAMEC()
  Protected n
  
  debugMsg(sProcName, #SCS_START)
  
  If gbUseSMS = #True And grLicInfo\nLicLevel >= #SCS_LIC_PLUS
    gbDelayTimeAvailable = #True
  Else
    gbDelayTimeAvailable = #False
  EndIf
  gbDelayTimeAvailable = #False ; !!!!!!!!!!!!!!!!! TEMP - REMOVE WHEN DELAY TIME AND OUTPUT GAIN INCLUDED !!!!!!!!!!!!!!!!!!
  
  grMaps\nMaxMapIndex = -1
  grMapsForDevChgs\nMaxMapIndex = -1
  
  With grDevMapDevDef
    \nDevGrp = #SCS_DEVGRP_NONE
    \nDevType = #SCS_DEVTYPE_NONE
    \nPrevDevIndex = -1
    \nNextDevIndex = -1
    \sLogicalDev = ""
    \nPhysicalDevPtr = -1
    \sDevOutputGainDB = "0.0"
    \nDelayTime = 0
    \nInputDelayTime = 0
    \nMixerStreamPtr = -1
    \nReassignDevMapDevPtr = -1
    \nBassDevice = -1
    \bBassASIO = #False
    \nBassASIODevice = -1
  EndWith
  
  With grDevMapDef
    \sDevMapName = ""
    \nFirstDevIndex = -1
  EndWith
  
  ; grMaps
  For n = 0 To ArraySize(grMaps\aMap())
    grMaps\aMap(n) = grDevMapDef
  Next n
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure setDefaultVidAudDeviceIfReqd(bPrimaryFile, bUseDevChgs=#False)
  PROCNAMEC()
  Protected nDevMapPtr
  Protected d
  
  debugMsg(sProcName, #SCS_START + ", bPrimaryFile=" + strB(bPrimaryFile) + ", bUseDevChgs=" + strB(bUseDevChgs))
  
  If bUseDevChgs = #False
    If bPrimaryFile
      nDevMapPtr = grProd\nSelectedDevMapPtr
      If nDevMapPtr >= 0
        d = grMaps\aMap(nDevMapPtr)\nFirstDevIndex
        While d >= 0
          With grMaps\aDev(d)
            Select \nDevType
              Case #SCS_DEVTYPE_VIDEO_AUDIO
                debugMsg(sProcName, "grMaps\aDev(" + d + ")\sPhysicalDev=" + \sPhysicalDev + ", \nPhysicalDevPtr=" + \nPhysicalDevPtr)
                If Len(\sPhysicalDev) = 0
                  If \nPhysicalDevPtr = -1
                    debugMsg(sProcName, "grMaps\aDev(" + d + ")\sLogicalDev=" + \sLogicalDev + ", setting \nPhysicalDevPtr=0")
                    \nPhysicalDevPtr = 0
                    debugMsg(sProcName, "gaVideoAudioDev(" + \nPhysicalDevPtr + ")\sVidAudName=" + gaVideoAudioDev(\nPhysicalDevPtr)\sVidAudName)
                    \sPhysicalDev = gaVideoAudioDev(\nPhysicalDevPtr)\sVidAudName
                    debugMsg(sProcName, "grMaps\aDev(" + d + ")\sPhysicalDev=" + grMaps\aDev(d)\sPhysicalDev)
                  ElseIf Len(\sPhysicalDev) = 0
                    debugMsg(sProcName, "gaVideoAudioDev(" + \nPhysicalDevPtr + ")\sVidAudName=" + gaVideoAudioDev(\nPhysicalDevPtr)\sVidAudName)
                    \sPhysicalDev = gaVideoAudioDev(\nPhysicalDevPtr)\sVidAudName
                    debugMsg(sProcName, "grMaps\aDev(" + d + ")\sPhysicalDev=" + grMaps\aDev(d)\sPhysicalDev)
                  EndIf
                EndIf
            EndSelect
            d = \nNextDevIndex
          EndWith
        Wend
      EndIf
      
    Else ; bPrimaryFile = #False
      nDevMapPtr = gr2ndProd\nSelectedDevMapPtr
      If nDevMapPtr >= 0
        d = grMapsForImport\aMap(nDevMapPtr)\nFirstDevIndex
        While d >= 0
          With grMapsForImport\aDev(d)
            Select \nDevType
              Case #SCS_DEVTYPE_VIDEO_AUDIO
                If \nPhysicalDevPtr = -1
                  debugMsg(sProcName, "ga2ndDev(" + d + ")\sLogicalDev=" + \sLogicalDev + ", setting \nPhysicalDevPtr=0")
                  \nPhysicalDevPtr = 0
                  debugMsg(sProcName, "gaVideoAudioDev(" + \nPhysicalDevPtr + ")\sVidAudName=" + gaVideoAudioDev(\nPhysicalDevPtr)\sVidAudName)
                  \sPhysicalDev = gaVideoAudioDev(\nPhysicalDevPtr)\sVidAudName
                EndIf
            EndSelect
            d = \nNextDevIndex
          EndWith
        Wend
      EndIf
      
    EndIf
    
  Else ; bUseDevChgs = #True
    nDevMapPtr = grProdForDevChgs\nSelectedDevMapPtr
    If nDevMapPtr >= 0
      d = grMapsForDevChgs\aMap(nDevMapPtr)\nFirstDevIndex
      While d >= 0
        With grMapsForDevChgs\aDev(d)
          Select \nDevType
            Case #SCS_DEVTYPE_VIDEO_AUDIO
              If \nPhysicalDevPtr = -1
                debugMsg(sProcName, "grMaps\aDev(" + d + ")\sLogicalDev=" + \sLogicalDev + ", setting \nPhysicalDevPtr=0")
                \nPhysicalDevPtr = 0
                debugMsg(sProcName, "gaVideoAudioDev(" + \nPhysicalDevPtr + ")\sVidAudName=" + gaVideoAudioDev(\nPhysicalDevPtr)\sVidAudName)
                \sPhysicalDev = gaVideoAudioDev(\nPhysicalDevPtr)\sVidAudName
                debugMsg(sProcName, "grMapsForDevChgs\aDev(" + d + ")\sPhysicalDev=" + grMapsForDevChgs\aDev(d)\sPhysicalDev)
              ElseIf Len(\sPhysicalDev) = 0
                debugMsg(sProcName, "gaVideoAudioDev(" + \nPhysicalDevPtr + ")\sVidAudName=" + gaVideoAudioDev(\nPhysicalDevPtr)\sVidAudName)
                \sPhysicalDev = gaVideoAudioDev(\nPhysicalDevPtr)\sVidAudName
                debugMsg(sProcName, "grMapsForDevChgs\aDev(" + d + ")\sPhysicalDev=" + grMapsForDevChgs\aDev(d)\sPhysicalDev)
              EndIf
          EndSelect
          d = \nNextDevIndex
        EndWith
      Wend
    EndIf
  EndIf
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure openAndReadXMLDevMapFile(bPrimaryFile, bInDevChgs=#False, bCreateFromTemplate=#False, bTemplate=#False)
  PROCNAMEC()
  Protected sReadDevMapFile.s, sImportDevMapFile.s
  Protected nDevMapPtr
  Protected sCueOrTemplateFile.s
  Protected d, n
  Protected i, j, m
  Protected sSelectedDevMapName.s
  Protected nValidDevMapPtr
  Protected bExistingDevMapFileFound
  Protected nAudioDriver
  Protected bLoadArrayResult
  Protected sProdId.s
  Protected bProdIdFoundInCueFile
  Protected sMessage.s
  Protected sDevMapFile.s, sDevMapFolder.s
  Protected bSaveToTemplateFolder
  Protected sBestDevMapFile.s, nNewDevMapFile, nReadDevMapFile, sDevMapLine.s, sTrimmedLine.s, nCopyResult
  Protected sDevMap.s, sNewDevMapMsg.s
  
  debugMsg(sProcName, #SCS_START + ", bPrimaryFile=" + strB(bPrimaryFile) + ", bInDevChgs=" + strB(bInDevChgs) + ", bCreateFromTemplate=" + strB(bCreateFromTemplate) + ", bTemplate=" + strB(bTemplate))
  
  If Len(gsDevMapsPath) = 0
    gsDevMapsPath = gsMyDocsPath + "SCS DevMaps\"
    If FolderExists(gsDevMapsPath) = #False
      CreateDirectory(gsDevMapsPath)
    EndIf
  EndIf
  
  If gnCurrAudioDriver = 0
    setCurrAudioDriver(gnDefaultAudioDriver)
  EndIf
  nAudioDriver = gnCurrAudioDriver
  
  If bPrimaryFile
    grMaps\nMaxMapIndex = -1
    If bInDevChgs = #False
      grProd\sSelectedDevMapName = ""
      grProd\nSelectedDevMapPtr = -1
    EndIf
    grMapsForDevChgs\nMaxMapIndex = -1
    grProdForDevChgs\sSelectedDevMapName = ""
    grProdForDevChgs\nSelectedDevMapPtr = -1
  Else
    grMapsForImport\nMaxMapIndex = -1
    ; gr2ndProd\sSelectedDevMapName = ""  ; do not clear these fields as we will use the existing settings
    ; gr2ndProd\nSelectedDevMapPtr = -1
  EndIf
  
  If bPrimaryFile
    If bCreateFromTemplate Or bTemplate
      sCueOrTemplateFile = gsTemplateFile
      sDevMapFolder = gsTemplatesFolder
      ; sProdId and bProdIdFoundInCueFile left at default values
    Else
      sCueOrTemplateFile = gsCueFile
      sDevMapFolder = gsDevMapsPath
      If bInDevChgs
        sProdId = grProdForDevChgs\sProdId
        bProdIdFoundInCueFile = grProdForDevChgs\bProdIdFoundInCueFile
      Else
        sProdId = grProd\sProdId
        bProdIdFoundInCueFile = grProd\bProdIdFoundInCueFile
      EndIf
    EndIf
  Else
    sCueOrTemplateFile = gs2ndCueFile
    sDevMapFolder = gsDevMapsPath
    sProdId = gr2ndProd\sProdId
    bProdIdFoundInCueFile = gr2ndProd\bProdIdFoundInCueFile
  EndIf
  debugMsg(sProcName, "sCueOrTemplateFile=" + #DQUOTE$ + sCueOrTemplateFile  + #DQUOTE$ + ", sProdId=" + sProdId + ", bProdIdFoundInCueFile=" + strB(bProdIdFoundInCueFile))
  
  If Len(GetFilePart(sCueOrTemplateFile)) = 0
    ; no action - probably clearing cue file
    
  ElseIf FileExists(sCueOrTemplateFile) = #False
    debugMsg(sProcName, "File does not exist")
    
  Else
    If bCreateFromTemplate Or bTemplate
      sReadDevMapFile = sDevMapFolder + ignoreExtension(GetFilePart(sCueOrTemplateFile)) + ".scstd"
    ElseIf (bProdIdFoundInCueFile) And (Len(sProdId) > 0)
      sReadDevMapFile = sDevMapFolder + ignoreExtension(GetFilePart(sCueOrTemplateFile)) + "_" + sProdId + ".scsd"
    Else
      sReadDevMapFile = sDevMapFolder + ignoreExtension(GetFilePart(sCueOrTemplateFile)) + ".scsd"
    EndIf
    debugMsg(sProcName, "sReadDevMapFile=" + sReadDevMapFile)
    If FileExists(sReadDevMapFile) = #False
      If (bCreateFromTemplate = #False) And (bTemplate = #False)
        ; can't find the device map file, so check if we have an exported device map file we can import
        If (bProdIdFoundInCueFile) And (Len(sProdId) > 0)
          sImportDevMapFile = ignoreExtension(sCueOrTemplateFile) + "_" + sProdId + ".scsdx"
        Else
          sImportDevMapFile = ignoreExtension(sCueOrTemplateFile) + ".scsdx"
        EndIf
        If FileExists(sImportDevMapFile)
          importDeviceMapFile(sCueOrTemplateFile, sImportDevMapFile, sReadDevMapFile)
        EndIf
      EndIf
    EndIf
    If FileExists(sReadDevMapFile)
      debugDevMapFile(sReadDevMapFile)
    Else
      If (bCreateFromTemplate = #False) And (bTemplate = #False)
        ; don't show message if creating from a template as this means the template itself doesn't have a device map file - so we create one without displaying the warning message
        If LCase(GetFilePart(sCueOrTemplateFile)) <> "demo.scs11" And LCase(GetFilePart(sCueOrTemplateFile)) <> "scs11_demo_v2.scs11"
          sBestDevMapFile = lookForBestMatchingDevMapFile(sCueOrTemplateFile) ; nb also sets gbSCSDefaultDevsOnly - see condition around "FileNotFound2" message below
          If sBestDevMapFile
            nReadDevMapFile = ReadFile(#PB_Any, sDevMapFolder + sBestDevMapFile, #PB_File_SharedRead)
            If nReadDevMapFile
              nNewDevMapFile = CreateFile(#PB_Any, sReadDevMapFile)
              If nNewDevMapFile
                While Eof(nReadDevMapFile) = 0
                  sDevMapLine = ReadString(nReadDevMapFile)
                  sTrimmedLine = Trim(sDevMapLine)
                  If Left(sTrimmedLine, 9) = "<_Saved_>"
                    sDevMapLine = Space(FindString(sDevMapLine, "<")-1) + "<_Saved_>" + FormatDate("%yyyy/%mm/%dd %hh:%ii:%ss", Date()) + "</_Saved_>"
                  ElseIf Left(sTrimmedLine, 15) = "<_SCS_Version_>"
                    sDevMapLine = Space(FindString(sDevMapLine, "<")-1) + "<_SCS_Version_>" + #SCS_VERSION + "</_SCS_Version_>"
                  ElseIf Left(sTrimmedLine, 13) = "<_SCS_Build_>"
                    sDevMapLine = Space(FindString(sDevMapLine, "<")-1) + "<_SCS_Build_>" + grProgVersion\sBuildDateTime + "</_SCS_Build_>"
                  EndIf
                  WriteStringN(nNewDevMapFile, sDevMapLine)
                Wend
                CloseFile(nReadDevMapFile)
                CloseFile(nNewDevMapFile)
                debugMsg(sProcName, "gbSCSDefaultDevsOnly=" + strB(gbSCSDefaultDevsOnly))
                If gbSCSDefaultDevsOnly = #False ; do not display the message if there is a single audio output device and a single video audio device and no other devices at all
                  sMessage = LangPars("DevMap", "FileNotFound2", #DQUOTE$ + GetFilePart(sCueOrTemplateFile) + #DQUOTE$)
                  debugMsg(sProcName, sMessage)
                  MessageRequester(GetFilePart(sCueOrTemplateFile), sMessage, #PB_MessageRequester_Info)
                EndIf
              EndIf
            EndIf
            debugDevMapFile(sReadDevMapFile)
          Else
            sMessage = LangPars("DevMap", "FileNotFound",
                                #DQUOTE$ + GetFilePart(sCueOrTemplateFile) + #DQUOTE$,
                                #DQUOTE$ + GetFilePart(sReadDevMapFile) + #DQUOTE$,
                                #DQUOTE$ + sDevMapFolder + #DQUOTE$)
            debugMsg(sProcName, sMessage)
            MessageRequester(GetFilePart(sCueOrTemplateFile), sMessage, #MB_ICONEXCLAMATION)
          EndIf
        EndIf
      EndIf
      gbNewDevMapFileCreated = #True
    EndIf
  EndIf
  
  If sReadDevMapFile
    bExistingDevMapFileFound = #True
    debugMsg(sProcName, "calling readXMLDevMapFile(" + strB(bPrimaryFile) + ", " + GetFilePart(sReadDevMapFile) + ")")
    sSelectedDevMapName = readXMLDevMapFile(bPrimaryFile, sReadDevMapFile)
    debugMsg(sProcName, "sSelectedDevMapName=" + sSelectedDevMapName)
  EndIf
  If Len(sSelectedDevMapName) = 0
    If bPrimaryFile
      debugMsg(sProcName, "calling createInitialDevMapForProd()")
      nDevMapPtr = createInitialDevMapForProd()
      sSelectedDevMapName = grMaps\sSelectedDevMapName ; getDevMapName(nDevMapPtr)
      If bPrimaryFile
        If GetFilePart(sCueOrTemplateFile)
          debugMsg(sProcName, "sCueOrTemplateFile=" + #DQUOTE$ + sCueOrTemplateFile + #DQUOTE$)
          If bCreateFromTemplate Or bTemplate
            bSaveToTemplateFolder = #True
          EndIf
          debugMsg(sProcName, "calling writeXMLDevMapFile(" + sSelectedDevMapName + ", " + sProdId + ", #False, #False, " + strB(bSaveToTemplateFolder) + ")")
          sDevMapFile = writeXMLDevMapFile(sSelectedDevMapName, sProdId, #False, #False, bSaveToTemplateFolder)
          If bPrimaryFile
            If bInDevChgs
              grProdForDevChgs\sDevMapFile = sDevMapFile
            Else
              grProd\sDevMapFile = sDevMapFile
            EndIf
          Else
            gr2ndProd\sDevMapFile = sDevMapFile
          EndIf
        EndIf
      EndIf
    Else
      nDevMapPtr = gr2ndProd\nSelectedDevMapPtr
      sSelectedDevMapName = gr2ndProd\sSelectedDevMapName
    EndIf
  ElseIf bPrimaryFile
    nDevMapPtr = getDevMapPtr(@grMaps, sSelectedDevMapName)
    grProd\nSelectedDevMapPtr = nDevMapPtr
    debugMsg(sProcName, "grProd\nSelectedDevMapPtr=" + grProd\nSelectedDevMapPtr + ", sSelectedDevMapName=" + sSelectedDevMapName)
  EndIf
  
  If bPrimaryFile
    debugMsg(sProcName, "calling resetSessionOptions()")
    resetSessionOptions()
  EndIf
  
  debugMsg(sProcName, "sSelectedDevMapName=" + sSelectedDevMapName)
  
  If bInDevChgs = #False
    If bPrimaryFile
      grProd\bExistingDevMapFileFound = bExistingDevMapFileFound
      grProd\sDevMapFile = sReadDevMapFile
      grProd\sSelectedDevMapName = sSelectedDevMapName
      grProd\nSelectedDevMapPtr = getDevMapPtr(@grMaps, sSelectedDevMapName)
      If grProd\nSelectedDevMapPtr >= 0
        nAudioDriver = grMaps\aMap(grProd\nSelectedDevMapPtr)\nAudioDriver
      EndIf
    Else
      gr2ndProd\bExistingDevMapFileFound = bExistingDevMapFileFound
      gr2ndProd\sDevMapFile = sReadDevMapFile
      ; gr2ndProd\sSelectedDevMapName = sSelectedDevMapName     ; already set (?)
      ; gr2ndProd\nSelectedDevMapPtr = getDevMapPtr(sSelectedDevMapName)
      If sSelectedDevMapName
        gr2ndProd\sSelectedDevMapName = sSelectedDevMapName
        gr2ndProd\nSelectedDevMapPtr = getDevMapPtr(@grMapsForImport, sSelectedDevMapName)
        If gr2ndProd\nSelectedDevMapPtr >= 0
          nAudioDriver = grMapsForImport\aMap(gr2ndProd\nSelectedDevMapPtr)\nAudioDriver
        EndIf
      EndIf
      debugMsg(sProcName, "sSelectedDevMapName=" + sSelectedDevMapName + ", gr2ndProd\sSelectedDevMapName=" + gr2ndProd\sSelectedDevMapName + ", gr2ndProd\nSelectedDevMapPtr=" + gr2ndProd\nSelectedDevMapPtr)
    EndIf
  Else
    grProdForDevChgs\bExistingDevMapFileFound = bExistingDevMapFileFound
    grProdForDevChgs\sDevMapFile = sReadDevMapFile
    grProdForDevChgs\sSelectedDevMapName = sSelectedDevMapName
    grProdForDevChgs\nSelectedDevMapPtr = getDevMapPtr(@grMapsForDevChgs, sSelectedDevMapName)
    If grProdForDevChgs\nSelectedDevMapPtr >= 0
      nAudioDriver = grMapsForDevChgs\aMap(grProdForDevChgs\nSelectedDevMapPtr)\nAudioDriver
    EndIf
    nValidDevMapPtr = grProdForDevChgs\nSelectedDevMapPtr
  EndIf
  
  setCurrAudioDriver(nAudioDriver)
  debugMsg(sProcName, "calling sortAudioDevs(" + decodeDriver(nAudioDriver) + ")")
  sortAudioDevs(nAudioDriver)
  
  If bTemplate = #False
    setDefaultVidAudDeviceIfReqd(bPrimaryFile)
  EndIf
  
  If bInDevChgs = #False
    If bPrimaryFile
      If grProd\nSelectedDevMapPtr = -1
        debugMsg(sProcName, "calling createInitialDevMapForProd()")
        grProd\nSelectedDevMapPtr = createInitialDevMapForProd()
        debugMsg(sProcName, "createInitialDevMapForProd() returned grProd\nSelectedDevMapPtr=" + grProd\nSelectedDevMapPtr)
      EndIf
      
      debugMsg(sProcName, "calling loadNetworkControl(#False)")
      loadNetworkControl(#False)
      
      nDevMapPtr = grProd\nSelectedDevMapPtr  ; keep nDevMapPtr for debug code below
      debugMsg(sProcName, "calling findValidDevMap(" + nDevMapPtr + ", " + GetFilePart(sCueOrTemplateFile) + ")")
      nValidDevMapPtr = findValidDevMap(nDevMapPtr, sCueOrTemplateFile)
      debugMsg(sProcName, "findValidDevMap(" + nDevMapPtr + "," + GetFilePart(sCueOrTemplateFile) + ") returned " + nValidDevMapPtr)
      ; Added 18Jan2025
      If nValidDevMapPtr = #SCS_REVIEW_DEVMAP ; = -101
        If grProd\nMaxLiveInputLogicalDev >= 0 ; Test added 11Feb2025 11.10.7ab
          nValidDevMapPtr = createNewDevMapFromExistingDevMap(nDevMapPtr)
          debugMsg(sProcName, "createNewDevMapFromExistingDevMap(" + nDevMapPtr + ") returned " + nValidDevMapPtr)
          sDevMap = Lang("Info", "DevMap")
          sNewDevMapMsg = LangPars("DevMap", "NewAsioDevMap", grMaps\sSelectedDevMapName)
          scsMessageRequester(sDevMap, sNewDevMapMsg, #PB_MessageRequester_Info)
        EndIf
      EndIf
      ; End added 18Jan2025
      If nValidDevMapPtr >= 0
        setCurrAudioDriver(grMaps\aMap(nValidDevMapPtr)\nAudioDriver)
        debugMsg(sProcName, "gnCurrAudioDriver=" + decodeDriver(gnCurrAudioDriver))
        grProd\nSelectedDevMapPtr = nValidDevMapPtr
        grProd\sSelectedDevMapName = grMaps\aMap(nValidDevMapPtr)\sDevMapName
        sSelectedDevMapName = grProd\sSelectedDevMapName
        
        debugMsg(sProcName, "calling loadMidiControl(#False)")
        loadMidiControl(#False)
        
        debugMsg(sProcName, "calling DMX_loadDMXControl()")
        DMX_loadDMXControl()
        
      Else
        sSelectedDevMapName = ""
      EndIf
      
    EndIf
  EndIf
  
  If bInDevChgs
    debugMsg(sProcName, "calling syncFixturesInDev(@grProdForDevChgs, @grMapsForDevChgs)")
    syncFixturesInDev(@grProdForDevChgs, @grMapsForDevChgs)
  ElseIf bPrimaryFile
    debugMsg(sProcName, "calling syncFixturesInDev(@grProd, @grMaps)")
    syncFixturesInDev(@grProd, @grMaps)
    debugMsg(sProcName, "calling populateAllDevStartChannelArrays()")
    populateAllDevStartChannelArrays()
  EndIf
  
  ; summarizeAllDevMaps()
  If bPrimaryFile
    debugMsg(sProcName, "calling listAllDevMaps()")
    listAllDevMaps()
  Else
    debugMsg(sProcName, "calling listAllDevMapsForImport()")
    listAllDevMapsForImport()
  EndIf
  
  For i = 1 To gnLastCue
    j = aCue(i)\nFirstSubIndex
    While j >= 0
      With aSub(j)
        If \bSubTypeM
          For m = 0 To #SCS_MAX_CTRL_SEND
            \aCtrlSend[m]\nCSPhysicalDevPtr = getPhysDevPtrForLogicalDev(@grMaps, #SCS_DEVGRP_CTRL_SEND, \aCtrlSend[m]\sCSLogicalDev)
          Next m
        EndIf
        j = \nNextSubIndex
      EndWith
    Wend
  Next i
  
  debugMsg(sProcName, #SCS_END + " returning " + nValidDevMapPtr + ", sSelectedDevMapName=" + sSelectedDevMapName)
  ProcedureReturn nValidDevMapPtr
  
EndProcedure

Procedure.s getDevGrpDesc(nDevGrp)
  Protected sDevGrp.s
  
  sDevGrp = decodeDevGrp(nDevGrp)
  If Len(sDevGrp) = 0
    ProcedureReturn ""
  Else
    ProcedureReturn Lang("DevGrp", sDevGrp)
  EndIf
EndProcedure

Procedure getDevGrpFromDevDevType(nDevType)
  PROCNAMEC()
  Protected nDevGrp
  
  Select nDevType
    Case #SCS_DEVTYPE_NONE
      nDevGrp = #SCS_DEVGRP_NONE
      
    Case #SCS_DEVTYPE_AUDIO_OUTPUT  ; , #SCS_DEVTYPE_MIDI_PLAYBACK
      nDevGrp = #SCS_DEVGRP_AUDIO_OUTPUT
      
    Case #SCS_DEVTYPE_VIDEO_AUDIO
      nDevGrp = #SCS_DEVGRP_VIDEO_AUDIO
      
    Case #SCS_DEVTYPE_VIDEO_CAPTURE
      nDevGrp = #SCS_DEVGRP_VIDEO_CAPTURE
      
    Case #SCS_DEVTYPE_LIVE_INPUT
      nDevGrp = #SCS_DEVGRP_LIVE_INPUT
      
    Case #SCS_DEVTYPE_LT_DMX_OUT
      nDevGrp = #SCS_DEVGRP_LIGHTING
      
    Case #SCS_DEVTYPE_CS_MIDI_OUT, #SCS_DEVTYPE_CS_MIDI_THRU, #SCS_DEVTYPE_CS_RS232_OUT, #SCS_DEVTYPE_CS_NETWORK_OUT, #SCS_DEVTYPE_MIDI_PLAYBACK, #SCS_DEVTYPE_CS_HTTP_REQUEST
      nDevGrp = #SCS_DEVGRP_CTRL_SEND
      
    Case #SCS_DEVTYPE_CC_MIDI_IN, #SCS_DEVTYPE_CC_RS232_IN, #SCS_DEVTYPE_CC_NETWORK_IN, #SCS_DEVTYPE_CC_DMX_IN
      nDevGrp = #SCS_DEVGRP_CUE_CTRL
      
  EndSelect
  ProcedureReturn nDevGrp
EndProcedure

Procedure checkDevMap(nDevMapPtr)
  PROCNAMEC()
  Protected nResult
  Protected nAudioDriver, nAudioDriverUsed
  
  debugMsg(sProcName, #SCS_START + ", nDevMapPtr=" + nDevMapPtr + " (" + getDevMapName(nDevMapPtr) + ")")
  
  gsCheckDevMapMsg = ""
  grDevMapCheck = grDevMapCheckDef
  grDevMapCheckForSetIgnoreDevInds = grDevMapCheck
  debugMsg(sProcName, "grDevMapCheck\nCheckItemCount=" + grDevMapCheck\nCheckItemCount)
  
  If nDevMapPtr >= 0
    nAudioDriver = grMaps\aMap(nDevMapPtr)\nAudioDriver
    debugMsg(sProcName, "nAudioDriver=" + decodeDriver(nAudioDriver))
    
    debugMsg(sProcName, "calling initBassForAudioDriver(" + decodeDriver(nAudioDriver) + ")")
    nAudioDriverUsed = initBassForAudioDriver(nAudioDriver)
    If nAudioDriverUsed < 0
      If gbCloseCueFile
        ProcedureReturn #SCS_CLOSE_CUE_FILE
      ElseIf gbReviewDevMap
        ProcedureReturn #SCS_REVIEW_DEVMAP
      EndIf
    EndIf
    If nAudioDriverUsed <> nAudioDriver
      nAudioDriver = nAudioDriverUsed
      grMaps\aMap(nDevMapPtr)\nAudioDriver = nAudioDriver
    EndIf
    
    debugMsg(sProcName, "calling updateDevMapPhysicalDevPtrs()")
    updateDevMapPhysicalDevPtrs()
    
    debugMsg(sProcName, "openLightingAndCueCtrlDMXDevsIfReqd()")
    openLightingAndCueCtrlDMXDevsIfReqd()
    
    debugMsg(sProcName, "calling listAllDevMaps()")
    listAllDevMaps()
    
    ; copy DevMap to DevMapForChecker
    grMapsForChecker = grMaps
    grProdForChecker = grProd
    debugMsg(sProcName, "calling checkDevMapCommon(" + getDevMapName(nDevMapPtr) + ", #False)")
    nResult = checkDevMapCommon(nDevMapPtr, #False)
    debugMsg(sProcName, "checkDevMapCommon(" + getDevMapName(nDevMapPtr) + ", #False) returned " + nResult)
    
    grProd = grProdForChecker
    ; copy DevMapForChecker to DevMap
    grMaps = grMapsForChecker
    
  EndIf
  
  debugMsg(sProcName, #SCS_END + " returning " + nResult)
  ProcedureReturn nResult
  
EndProcedure

Procedure setDevChgsDevStatus(nDevMapDevPtr, nDevGrp, nDevNo)
  PROCNAMEC()
  Protected nDevState
  Protected nNetworkRole
  Protected nDMXControlPtr
  
  debugMsg(sProcName, #SCS_START + ", nDevMapDevPtr=" + nDevMapDevPtr)
  
  nDevState = #SCS_DEVSTATE_INACTIVE
  
  If nDevMapDevPtr >= 0
    With grMapsForDevChgs\aDev(nDevMapDevPtr)
      debugMsg(sProcName, "grMapsForDevChgs\aDev(" + nDevMapDevPtr + ")\nDevType=" + decodeDevType(\nDevType) + ", \sPhysicalDev=" + \sPhysicalDev + ", \nPhysicalDevPtr=" + \nPhysicalDevPtr)
      Select \nDevType
        Case #SCS_DEVTYPE_AUDIO_OUTPUT
          
        Case #SCS_DEVTYPE_VIDEO_AUDIO
          
        Case #SCS_DEVTYPE_LIVE_INPUT
          
        Case #SCS_DEVTYPE_CC_MIDI_IN
          ;{
          If \nPhysicalDevPtr < 0
            \nPhysicalDevPtr = getMidiInPhysicalDevPtr(\sPhysicalDev, \bDummy)
          EndIf
          If \nPhysicalDevPtr >= 0
            If gaMidiInDevice(\nPhysicalDevPtr)\bInitialized = #False
              If gaMidiInDevice(\nPhysicalDevPtr)\bDummy
                gaMidiInDevice(\nPhysicalDevPtr)\bInitialized = #True
              Else
                debugMsg(sProcName, "calling MidiIn_Port('open', " + \nPhysicalDevPtr + ", 'cuectrl')")
                MidiIn_Port("open", \nPhysicalDevPtr, "cuectrl")
              EndIf
            EndIf
            If gaMidiInDevice(\nPhysicalDevPtr)\bInitialized
              nDevState = #SCS_DEVSTATE_ACTIVE
            EndIf
          EndIf
          ;}
        Case #SCS_DEVTYPE_CS_MIDI_OUT
          ;{
          If \nPhysicalDevPtr < 0
            \nPhysicalDevPtr = getMidiOutPhysicalDevPtr(\sPhysicalDev, \bDummy)
          EndIf
          If \nPhysicalDevPtr >= 0
            debugMsg(sProcName, "gaMidiOutDevice(" + \nPhysicalDevPtr + ")\bInitialized=" + strB(gaMidiOutDevice(\nPhysicalDevPtr)\bInitialized))
            If gaMidiOutDevice(\nPhysicalDevPtr)\bInitialized = #False
              If gaMidiOutDevice(\nPhysicalDevPtr)\bDummy
                gaMidiOutDevice(\nPhysicalDevPtr)\bInitialized = #True
              Else
                MidiOut_Port("open", \nPhysicalDevPtr, "ctrlsend")
              EndIf
            EndIf
            If gaMidiOutDevice(\nPhysicalDevPtr)\bInitialized
              nDevState = #SCS_DEVSTATE_ACTIVE
            EndIf
          EndIf
          ;}
        Case #SCS_DEVTYPE_CS_MIDI_THRU
          ;{
          If \nPhysicalDevPtr < 0
            \nPhysicalDevPtr = getMidiOutPhysicalDevPtr(\sPhysicalDev, \bDummy)
          EndIf
          If \nPhysicalDevPtr >= 0
            If gaMidiOutDevice(\nPhysicalDevPtr)\bInitialized = #False
              If gaMidiOutDevice(\nPhysicalDevPtr)\bDummy
                gaMidiOutDevice(\nPhysicalDevPtr)\bInitialized = #True
              Else
                MidiOut_Port("open", \nPhysicalDevPtr, "ctrlsend")
              EndIf
            EndIf
          EndIf
          If \nMidiThruInPhysicalDevPtr < 0
            \nMidiThruInPhysicalDevPtr = getMidiInPhysicalDevPtr(\sMidiThruInPhysicalDev, \bMidiThruInDummy)
          EndIf
          If \nMidiThruInPhysicalDevPtr >= 0
            If gaMidiInDevice(\nMidiThruInPhysicalDevPtr)\bInitialized = #False
              If gaMidiInDevice(\nMidiThruInPhysicalDevPtr)\bDummy
                gaMidiInDevice(\nMidiThruInPhysicalDevPtr)\bInitialized = #True
              Else
                debugMsg(sProcName, "calling MidiIn_Port('open', " + \nMidiThruInPhysicalDevPtr + ", 'cuectrl')")
                MidiIn_Port("open", \nMidiThruInPhysicalDevPtr, "cuectrl")
              EndIf
            EndIf
          EndIf
          If (\nPhysicalDevPtr >= 0) And (\nMidiThruInPhysicalDevPtr >= 0)
            If (gaMidiOutDevice(\nPhysicalDevPtr)\bInitialized) And (gaMidiInDevice(\nMidiThruInPhysicalDevPtr)\bInitialized)
              nDevState = #SCS_DEVSTATE_ACTIVE
            EndIf
          EndIf
          ;}
        Case #SCS_DEVTYPE_CC_RS232_IN, #SCS_DEVTYPE_CS_RS232_OUT
          ;{
          If \nPhysicalDevPtr < 0
            \nPhysicalDevPtr = getRS232ControlIndexForRS232PortAddress(\sPhysicalDev, \bDummy)
          EndIf
          ; debugMsg(sProcName, "grMapsForDevChgs\aDev(" + nDevMapDevPtr + ")\nPhysicalDevPtr=" + \nPhysicalDevPtr)
          If \nPhysicalDevPtr >= 0
            If gaRS232Control(\nPhysicalDevPtr)\bInitialized = #False
              If gaRS232Control(\nPhysicalDevPtr)\bDummy
                gaRS232Control(\nPhysicalDevPtr)\bInitialized = #True
              Else
                initRS232Device(\nPhysicalDevPtr, \nDevType)
              EndIf
            EndIf
            If gaRS232Control(\nPhysicalDevPtr)\bInitialized
              If \nDevType = #SCS_DEVTYPE_CC_RS232_IN
                gaRS232Control(\nPhysicalDevPtr)\bRS232In = #True
              Else
                gaRS232Control(\nPhysicalDevPtr)\bRS232Out = #True
              EndIf
              nDevState = #SCS_DEVSTATE_ACTIVE
            EndIf
          EndIf
          ;}
        Case #SCS_DEVTYPE_CC_NETWORK_IN, #SCS_DEVTYPE_CS_NETWORK_OUT
          ;{
          If nDevNo >= 0
            Select nDevGrp
              Case #SCS_DEVGRP_CTRL_SEND
                nNetworkRole = grProdForDevChgs\aCtrlSendLogicalDevs(nDevNo)\nNetworkRole
              Case #SCS_DEVGRP_CUE_CTRL
                nNetworkRole = grProdForDevChgs\aCueCtrlLogicalDevs(nDevNo)\nNetworkRole
            EndSelect
            Select nNetworkRole
              Case #SCS_ROLE_DUMMY
                nDevState = #SCS_DEVSTATE_ACTIVE
              Case #SCS_NETWORK_ROLE_SCS_IS_A_CLIENT, #SCS_NETWORK_ROLE_SCS_IS_A_SERVER
                debugMsg(sProcName, "grMapsForDevChgs\aDev(" + nDevMapDevPtr + ")\nPhysicalDevPtr=" + \nPhysicalDevPtr)
                If \nPhysicalDevPtr >= 0
                  debugMsg(sProcName, "gaNetworkControl(" + \nPhysicalDevPtr + ")\bNetworkDevInitialized=" + strB(gaNetworkControl(\nPhysicalDevPtr)\bNetworkDevInitialized))
                  If gaNetworkControl(\nPhysicalDevPtr)\bNetworkDevInitialized
                    nDevState = #SCS_DEVSTATE_ACTIVE
                  EndIf
                EndIf
            EndSelect
          EndIf
          ;}
        Case #SCS_DEVTYPE_CC_DMX_IN, #SCS_DEVTYPE_LT_DMX_OUT
          ;{
          If \nPhysicalDevPtr < 0
            \nPhysicalDevPtr = DMX_getDMXDevPtr(\sPhysicalDev, \sDMXSerial, \nDMXSerial, \bDummy)
            debugMsg(sProcName, "DMX_getDMXDevPtr(" + \sPhysicalDev + ", " + \sDMXSerial + ", " + \nDMXSerial + ", " + strB(\bDummy) + ") returned " + \nPhysicalDevPtr)
          EndIf
          If \nPhysicalDevPtr >= 0
            If gaDMXDevice(\nPhysicalDevPtr)\bInitialized = #False
              If gaDMXDevice(\nPhysicalDevPtr)\bDummy
                gaDMXDevice(\nPhysicalDevPtr)\bInitialized = #True
              Else
                nDMXControlPtr = DMX_getDMXControlPtrForDevNo(\nDevType, nDevNo)
                If nDMXControlPtr >= 0
                  debugMsg(sProcName, "calling DMX_openDMXDev(" + nDMXControlPtr + ")")
                  DMX_openDMXDev(nDMXControlPtr)
                EndIf
              EndIf
            EndIf
            If gaDMXDevice(\nPhysicalDevPtr)\bInitialized
              nDevState = #SCS_DEVSTATE_ACTIVE
            EndIf
          EndIf
          ;}
        Case #SCS_DEVTYPE_CS_HTTP_REQUEST
          ;{
          If \nPhysicalDevPtr < 0
            \nPhysicalDevPtr = 0
          EndIf
          nDevState = #SCS_DEVSTATE_ACTIVE
          ;}
      EndSelect
      
      If nDevState = #SCS_DEVSTATE_INACTIVE
        If (\bDummy) And (\nPhysicalDevPtr >= 0)
          nDevState = #SCS_DEVSTATE_ACTIVE
        EndIf
      EndIf
      \nDevState = nDevState
    EndWith
  EndIf
  
  debugMsg(sProcName, #SCS_END + ", grMapsForDevChgs\aDev(" + nDevMapDevPtr + ")\nDevState=" + decodeDevState(grMapsForDevChgs\aDev(nDevMapDevPtr)\nDevState))
  
EndProcedure

Procedure addDevMapCheckItem(*rDev.tyDevMapDev, sCheckMsg.s, nCheckResult)
  PROCNAMEC()
  Protected nIndex
  Protected nDevGrp, nDevType, nDevId
  Protected n, bAlreadyInArray
  Protected sDevGrp.s, sDevType.s
  
  debugMsg(sProcName, #SCS_START)
  
  With *rDev
    debugMsg(sProcName, "*rDev\nDevMapId=" + \nDevMapId + ", \nDevGrp=" + decodeDevGrp(\nDevGrp) + ", \nDevType=" + decodeDevType(\nDevType) +
                        ", \sLogicalDev=" + \sLogicalDev + ", \sPhysicalDev=" + \sPhysicalDev + ", nCheckResult=" + nCheckResult + ", sCheckMsg=" + sCheckMsg)
    nDevGrp = \nDevGrp
    nDevType = \nDevType
    nDevId = \nDevId
  EndWith
  
  With grDevMapCheck
    For n = 0 To (grDevMapCheck\nCheckItemCount - 1)
      If (\aCheckItem(n)\nDevGrp = nDevGrp) And (\aCheckItem(n)\nDevId = nDevId) And (\aCheckItem(n)\sCheckMsg = sCheckMsg) ; Added sCheckMsg test 25Jun2021 11.8.5ao
        bAlreadyInArray = #True
        Break
      EndIf
    Next n
  EndWith
  
  If bAlreadyInArray = #False
    With grDevMapCheck
      nIndex = \nCheckItemCount
      \nCheckItemCount + 1
      If ArraySize(\aCheckItem()) < nIndex
        ReDim \aCheckItem(nIndex + 5)
      EndIf
      \bDevGrpIssue[nDevGrp] = #True
    EndWith
    With grDevMapCheck\aCheckItem(nIndex)
      \nDevGrp = nDevGrp
      \nDevType = nDevType
      \nDevId = nDevId
      \sLogicalDev = *rDev\sLogicalDev
      \sPhysicalDevInfo = *rDev\sPhysicalDev
      \sCheckMsg = sCheckMsg
      \nCheckResult = nCheckResult
    EndWith
  EndIf
  
  If Len(gsCheckDevMapMsg) = 0
    sDevGrp = decodeDevGrpL(nDevGrp)
    sDevType = decodeDevTypeL(nDevType)
    gsCheckDevMapMsg = sDevGrp
    If LCase(sDevType) <> LCase(sDevGrp)
      gsCheckDevMapMsg + " " + sDevType
    EndIf
    gsCheckDevMapMsg + " " + sCheckMsg
    grDevMapCheckForSetIgnoreDevInds = grDevMapCheck
    debugMsg(sProcName, "gsCheckDevMapMsg=" + gsCheckDevMapMsg + ", grDevMapCheckForSetIgnoreDevInds\nCheckItemCount=" + grDevMapCheckForSetIgnoreDevInds\nCheckItemCount)
  EndIf
  
EndProcedure

Procedure addDevMapCheckItemForDevGrp(nDevGrp, sCheckMsg.s, nCheckResult)
  PROCNAMEC()
  Protected nIndex
  Protected nDevId
  Protected n, bAlreadyInArray
  
  debugMsg(sProcName, #SCS_START + ", nDevGrp=" + decodeDevGrp(nDevGrp) + ", nCheckResult=" + nCheckResult + ", sCheckMsg=" + sCheckMsg)
  
  nDevId = -1
  
  With grDevMapCheck
    For n = 0 To (grDevMapCheck\nCheckItemCount - 1)
      If (\aCheckItem(n)\nDevGrp = nDevGrp) And (\aCheckItem(n)\nDevId = nDevId)
        bAlreadyInArray = #True
        Break
      EndIf
    Next n
  EndWith
  
  If bAlreadyInArray = #False
    With grDevMapCheck
      nIndex = \nCheckItemCount
      \nCheckItemCount + 1
      If ArraySize(\aCheckItem()) < nIndex
        ReDim \aCheckItem(nIndex + 5)
      EndIf
      \bDevGrpIssue[nDevGrp] = #True
    EndWith
    With grDevMapCheck\aCheckItem(nIndex)
      \nDevGrp = nDevGrp
      \nDevType = #SCS_DEVTYPE_NONE
      \nDevId = nDevId
      \sCheckMsg = sCheckMsg
      \nCheckResult = nCheckResult
    EndWith
  EndIf
  
  If Len(gsCheckDevMapMsg) = 0
    gsCheckDevMapMsg = sCheckMsg
    grDevMapCheckForSetIgnoreDevInds = grDevMapCheck
    debugMsg(sProcName, "gsCheckDevMapMsg=" + gsCheckDevMapMsg + ", grDevMapCheckForSetIgnoreDevInds\nCheckItemCount=" + grDevMapCheckForSetIgnoreDevInds\nCheckItemCount)
  EndIf
  
EndProcedure

Procedure clearIgnoreDevThisRunInds()
  PROCNAMEC()
  Protected d
  
  debugMsg(sProcName, #SCS_START)
  
  For d = 0 To ArraySize(grMaps\aDev())
    grMaps\aDev(d)\bIgnoreDevThisRun = #False
    ; debugMsg(sProcName, "grMaps\aDev(" + d + ")\bIgnoreDevThisRun=" + strB(grMaps\aDev(d)\bIgnoreDevThisRun))
  Next d
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure setIgnoreDevThisRunInds()
  PROCNAMEC()
  Protected nDevMapPtr, nDevMapDevPtr, bIgnoreDevThisRun
  Protected n
  
  debugMsg(sProcName, #SCS_START)
  
  debugMsg(sProcName, "grDevMapCheck\nCheckItemCount=" + grDevMapCheck\nCheckItemCount)
  
  For n = 0 To (grDevMapCheck\nCheckItemCount - 1)
    With grDevMapCheck\aCheckItem(n)
      debugMsg(sProcName, "grDevMapCheck\aCheckItem(" + n + ")\nDevGrp=" + decodeDevGrp(\nDevGrp) + ", \nDevType=" + decodeDevType(\nDevType) + ", \nDevId=" + \nDevId + ", \sLogicalDev=" + \sLogicalDev +
                          ", \sPhysicalDevInfo=" + \sPhysicalDevInfo + ", \sCheckMsg=" + \sCheckMsg)
      If \nDevId >= 0
        nDevMapDevPtr = getDevMapDevPtrDevId(\nDevGrp, \nDevId)
        If nDevMapDevPtr >= 0
          nDevMapPtr = getDevMapPtrForDevMapId(@grMaps, grMaps\aDev(nDevMapDevPtr)\nDevMapId)
          If nDevMapPtr >= 0
            bIgnoreDevThisRun = #True
            If (\nDevType = #SCS_DEVTYPE_AUDIO_OUTPUT) And (grMaps\aMap(nDevMapPtr)\nAudioDriver = #SCS_DRV_BASS_DS Or grMaps\aMap(nDevMapPtr)\nAudioDriver = #SCS_DRV_BASS_WASAPI)
              grMaps\aDev(nDevMapDevPtr)\nBassDevice = -1 ; bass device -1 = default device
              grMaps\aDev(nDevMapDevPtr)\bReroutedToDefault = #True
              ; ignored audio output device re-routed to default audio device, so no need to ignore
              bIgnoreDevThisRun = #False
            EndIf
            grMaps\aDev(nDevMapDevPtr)\bIgnoreDevThisRun = bIgnoreDevThisRun ; Changed 16Mar2020 11.8.2.3aa - was previously commented out but I don't know why
            ; This MUST be included or the program can loop on 'ignore these devices' in the 'checking device map' error message (10May2022 11.9.1 re-issue, following email from Joe Eaton)
            debugMsg(sProcName, "grMaps\aDev(" + nDevMapDevPtr + ")\bIgnoreDevThisRun=" + strB(grMaps\aDev(nDevMapDevPtr)\bIgnoreDevThisRun))
            If grMaps\aDev(nDevMapDevPtr)\bIgnoreDevThisRun Or grMaps\aDev(nDevMapDevPtr)\bReroutedToDefault
              debugMsg(sProcName, "grMaps\aDev(" + nDevMapDevPtr + ")\bIgnoreDevThisRun=" + strB(grMaps\aDev(nDevMapDevPtr)\bIgnoreDevThisRun) +
                                  ", \bReroutedToDefault=" + strB(grMaps\aDev(nDevMapDevPtr)\bReroutedToDefault) +
                                  ", \nDevGrp=" + decodeDevGrp(grMaps\aDev(nDevMapDevPtr)\nDevGrp) +
                                  ", \nDevType=" + decodeDevType(grMaps\aDev(nDevMapDevPtr)\nDevType) +
                                  ", \sLogicalDev=" + grMaps\aDev(nDevMapDevPtr)\sLogicalDev)
            EndIf
          EndIf
        EndIf
      EndIf
    EndWith
  Next n
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure loadDMXStartChannelsIfReqd(*rProd.tyProd, *rDevMapdev.tyDevMapDev)
  PROCNAMEC()
  Protected n, nMaxDMXChannel, nTotalChans, nDefaultDMXStartChannel, sFixtureType.s
  Protected sCheckMsg.s, nDevResult
  
  With *rDevMapDev
    For n = 0 To \nMaxDevFixture
      nMaxDMXChannel = 512
      If \aDevFixture(n)\sDevFixtureCode
        sFixtureType = getFixtureTypeForLightingDeviceFixtureCode(*rProd, \sLogicalDev, \aDevFixture(n)\sDevFixtureCode)
        If sFixtureType
          nTotalChans = getTotalChansForFixtureType(*rProd, sFixtureType)
          If nTotalChans > 0
            nMaxDMXChannel = 513 - nTotalChans
          EndIf
        EndIf
        If Len(\aDevFixture(n)\sDevDMXStartChannels) = 0 And (\aDevFixture(n)\nDevDMXStartChannel < 1 Or \aDevFixture(n)\nDevDMXStartChannel > nMaxDMXChannel)
          ; if no (valid) DMX start channel is found for this fixture in the device map, see if the 'default start channel' is set
          nDefaultDMXStartChannel = getFixtureDfltStartChanForLightingDeviceFixtureCode(*rProd, \sLogicalDev, \aDevFixture(n)\sDevFixtureCode)
          If nDefaultDMXStartChannel > 0 And \aDevFixture(n)\nDevDMXStartChannel <= nMaxDMXChannel
            ; use the 'default start channel'
            debugMsg(sProcName, "Using 'default start channel' (" + nDefaultDMXStartChannel + ") for fixture " + \aDevFixture(n)\sDevFixtureCode)
            \aDevFixture(n)\nDevDMXStartChannel = nDefaultDMXStartChannel
          Else
            ; no (valid) 'default start channel' found, so include in a list to be displayed
            sCheckMsg = LangPars("DevMap", "InvalidDMXStartChannel", \aDevFixture(n)\sDevFixtureCode)
            nDevResult = #SCS_ASK_TO_REVIEW_DEVMAP
            addDevMapCheckItem(*rDevMapdev, sCheckMsg, nDevResult)
            debugMsg(sProcName, "(dmxout) nDevResult=" + nDevResult + ": review device map")
          EndIf
        EndIf
      EndIf
    Next n
  EndWith
  
EndProcedure

Procedure loadDevMapLightingFixturesIfReqd(*rProd.tyProd, *rDevMapDev.tyDevMapDev)
  PROCNAMEC()
  ; Procedure created 2Oct2023 11.10.0cf following this scenario:
  ; 1. Create a new production.
  ; 2. Import devices from a cue file that contains lighting devices and fixtures but with a phisical interface not currently connected (DM USB PRO MK2).
  ; 3. In Lighting Devices in the editor, the fixtures for the selected lighting device were correctly displayed.
  ; 4. Changed the selected lighting device to the DMX USB PRO (not the MK2).
  ; 5. Clicked Apply Device Changes - program reported a DMX start channel need to be entered, even though it was displayed on the screen.
  ; The error was that the device map's \aDevFixture array had not been updated, so this procedure now handles that.
  Protected nProdDevNo, nFixIndex
  
  debugMsg(sProcName, #SCS_START + ", *rDevMapDev\nMaxDevFixture=" + *rDevMapDev\nMaxDevFixture)
  
  If *rDevMapDev\nMaxDevFixture < 0
    ; not yet populated
    nProdDevNo = getDevNoForLogicalDev(*rProd, #SCS_DEVGRP_LIGHTING, *rDevMapDev\sLogicalDev)
    debugMsg(sProcName, "*rDevMapDev\sLogicalDev=" + *rDevMapDev\sLogicalDev + ", nProdDevNo=" + nProdDevNo)
    With *rProd\aLightingLogicalDevs(nProdDevNo)
      If ArraySize(*rDevMapDev\aDevFixture()) < \nMaxFixture
        debugMsg(sProcName, "calling ReDim *rDevMapDev\aDevFixture(" + \nMaxFixture + ")")
        ReDim *rDevMapDev\aDevFixture(\nMaxFixture)
      EndIf
      For nFixIndex = 0 To \nMaxFixture
        *rDevMapDev\aDevFixture(nFixIndex) = grDevFixtureDef
        *rDevMapDev\aDevFixture(nFixIndex)\sDevFixtureCode = \aFixture(nFixIndex)\sFixtureCode
        *rDevMapDev\aDevFixture(nFixIndex)\nDevDMXStartChannel = \aFixture(nFixIndex)\nDefaultDMXStartChannel
        *rDevMapDev\aDevFixture(nFixIndex)\sDevDMXStartChannels = Str(*rDevMapDev\aDevFixture(nFixIndex)\nDevDMXStartChannel)
        debugMsg(sProcName, "*rDevMapDev\aDevFixture(" + nFixIndex + ")\sDevFixtureCode=" + *rDevMapDev\aDevFixture(nFixIndex)\sDevFixtureCode + ", \nDevDMXStartChannel=" + *rDevMapDev\aDevFixture(nFixIndex)\nDevDMXStartChannel)
      Next nFixIndex
      *rDevMapDev\nMaxDevFixture = \nMaxFixture
      debugMsg(sProcName, "*rDevMapDev\nMaxDevFixture=" + *rDevMapDev\nMaxDevFixture)
    EndWith
  EndIf
  
EndProcedure

Procedure checkDevMapCommon(nDevMapPtr, bInDevChgs=#False)
  PROCNAMEC()
  Protected nDevMapResult
  Protected nDevResult
  Protected d, d2, n
  Protected bLogicalDevFound
  Protected bSufficientOutputs, bSufficientInputs
  Protected nInitResult
  Protected rMyDev.tyDevMapDev
  Protected nDevOutputs, nDevInputs
  Protected sLogicalDev.s
  Protected nRealPhysDevPtr
  Protected nMousePointer
  Protected nTotalOutputCount
  Protected bCreatingASIOGroup
  Protected sMsg.s
  Protected nResponse
  Protected bExitFunction
  Protected nPass
  Protected bLiveInputsReqd
  Protected bUsingASIOGroup
  Protected sErrorMsg.s
  Protected nDevType
  Protected sCheckMsg.s, sPhysicalDevQuoted.s, sMyPhysicalDev.s
  Protected sDevMapNameForCCetc.s, nFirstDevIndexForCCetc
  Protected bDevGrpFound
  Protected sFixtureType.s, nTotalChans, nMaxDMXChannel, nDefaultDMXStartChannel
  Protected nDevCount, nDummyCount
  
  debugMsg(sProcName, #SCS_START + ", nDevMapPtr=" + getDevMapName(nDevMapPtr) + ", bInDevChgs=" + strB(bInDevChgs))
  
  nMousePointer = GetMouseCursor()
  setMouseCursorBusy()
  
  ; debugMsg(sProcName, "gsSelectedDevMapName=" + gsSelectedDevMapName)
  
  sDevMapNameForCCetc = grMapsForChecker\aMap(nDevMapPtr)\sDevMapName
  nFirstDevIndexForCCetc = grMapsForChecker\aMap(nDevMapPtr)\nFirstDevIndex
  
  With grProdForChecker
    ; check nominated device map has at least the required list of device names used in cues
    For d = 0 To \nMaxAudioLogicalDev
      sLogicalDev = \aAudioLogicalDevs(d)\sLogicalDev
      If sLogicalDev
        bLogicalDevFound = #False
        d2 = grMapsForChecker\aMap(nDevMapPtr)\nFirstDevIndex
        While d2 >= 0
          If grMapsForChecker\aDev(d2)\nDevGrp = #SCS_DEVGRP_AUDIO_OUTPUT
            If grMapsForChecker\aDev(d2)\sLogicalDev = sLogicalDev
              bLogicalDevFound = #True
              Break
            EndIf
          EndIf
          d2 = grMapsForChecker\aDev(d2)\nNextDevIndex
        Wend
        If bLogicalDevFound = #False
          nDevMapResult = -1
          sCheckMsg = LangPars("DevMap", "DevNotInDevMap", Lang("DevGrp", "AudioOutput"), sLogicalDev, grMapsForChecker\aMap(nDevMapPtr)\sDevMapName)
          addDevMapCheckItemForDevGrp(#SCS_DEVGRP_AUDIO_OUTPUT, sCheckMsg, nDevMapResult)
          debugMsg(sProcName, "d=" + d + ", " + gsCheckDevMapMsg)
          Break
        EndIf
      EndIf
    Next d
    
    If nDevMapResult = 0
      For d = 0 To \nMaxVidAudLogicalDev
        sLogicalDev = \aVidAudLogicalDevs(d)\sVidAudLogicalDev
        If sLogicalDev
          bLogicalDevFound = #False
          d2 = grMapsForChecker\aMap(nDevMapPtr)\nFirstDevIndex
          While d2 >= 0
            If grMapsForChecker\aDev(d2)\nDevGrp = #SCS_DEVGRP_VIDEO_AUDIO
              If grMapsForChecker\aDev(d2)\sLogicalDev = sLogicalDev
                bLogicalDevFound = #True
                Break
              EndIf
            EndIf
            d2 = grMapsForChecker\aDev(d2)\nNextDevIndex
          Wend
          If bLogicalDevFound = #False
            nDevMapResult = -1
            sCheckMsg = LangPars("DevMap", "DevNotInDevMap", Lang("DevGrp", "VideoAudio"), sLogicalDev, grMapsForChecker\aMap(nDevMapPtr)\sDevMapName)
            addDevMapCheckItemForDevGrp(#SCS_DEVGRP_VIDEO_AUDIO, sCheckMsg, nDevMapResult)
            debugMsg(sProcName, "d=" + d + ", " + gsCheckDevMapMsg)
            Break
          EndIf
        EndIf
      Next d
    EndIf
    
    If nDevMapResult = 0
      For d = 0 To \nMaxVidCapLogicalDev
        sLogicalDev = \aVidCapLogicalDevs(d)\sLogicalDev
        If sLogicalDev
          bLogicalDevFound = #False
          d2 = grMapsForChecker\aMap(nDevMapPtr)\nFirstDevIndex
          While d2 >= 0
            If grMapsForChecker\aDev(d2)\nDevGrp = #SCS_DEVGRP_VIDEO_CAPTURE
              If grMapsForChecker\aDev(d2)\sLogicalDev = sLogicalDev
                bLogicalDevFound = #True
                Break
              EndIf
            EndIf
            d2 = grMapsForChecker\aDev(d2)\nNextDevIndex
          Wend
          If bLogicalDevFound = #False
            nDevMapResult = -1
            sCheckMsg = LangPars("DevMap", "DevNotInDevMap", Lang("DevGrp", "VideoCapture"), sLogicalDev, grMapsForChecker\aMap(nDevMapPtr)\sDevMapName)
            addDevMapCheckItemForDevGrp(#SCS_DEVGRP_VIDEO_CAPTURE, sCheckMsg, nDevMapResult)
            debugMsg(sProcName, "d=" + d + ", " + gsCheckDevMapMsg)
            Break
          EndIf
        EndIf
      Next d
    EndIf
    
    If nDevMapResult = 0
      For d = 0 To \nMaxLiveInputLogicalDev
        sLogicalDev = \aLiveInputLogicalDevs(d)\sLogicalDev
        If sLogicalDev
          bLogicalDevFound = #False
          bLiveInputsReqd = #True
          d2 = grMapsForChecker\aMap(nDevMapPtr)\nFirstDevIndex
          While d2 >= 0
            If grMapsForChecker\aDev(d2)\nDevGrp = #SCS_DEVGRP_LIVE_INPUT
              If grMapsForChecker\aDev(d2)\sLogicalDev = sLogicalDev
                bLogicalDevFound = #True
                If grMapsForChecker\aDev(d2)\bDummy
                  nDummyCount + 1
                EndIf
                Break
              EndIf
            EndIf
            d2 = grMapsForChecker\aDev(d2)\nNextDevIndex
          Wend
          If bLogicalDevFound = #False
            nDevMapResult = -1
            sCheckMsg = LangPars("DevMap", "DevNotInDevMap", Lang("DevGrp", "LiveInput"), sLogicalDev, grMapsForChecker\aMap(nDevMapPtr)\sDevMapName)
            addDevMapCheckItemForDevGrp(#SCS_DEVGRP_LIVE_INPUT, sCheckMsg, nDevMapResult)
            debugMsg(sProcName, "d=" + d + ", " + gsCheckDevMapMsg)
            Break
          EndIf
        EndIf
      Next d
    EndIf
    
    If bLiveInputsReqd
      If grMapsForChecker\aMap(nDevMapPtr)\nAudioDriver <> #SCS_DRV_SMS_ASIO
        For d = 0 To \nMaxLiveInputLogicalDev
          If \aLiveInputLogicalDevs(d)\sLogicalDev
            nDevCount + 1
          EndIf
        Next d
        If nDummyCount > 0
          debugMsg(sProcName, "nDevCount=" + nDevCount + ", nDummyCount=" + nDummyCount)
        EndIf
        If nDevCount > nDummyCount
          nDevMapResult = -1
          sCheckMsg = LangPars("DevMap", "RequiresSMS", grMapsForChecker\aMap(nDevMapPtr)\sDevMapName)
          addDevMapCheckItemForDevGrp(#SCS_DEVGRP_LIVE_INPUT, sCheckMsg, nDevMapResult)
          debugMsg(sProcName, gsCheckDevMapMsg)
        EndIf
      EndIf
    EndIf
    
    If nDevMapResult = 0
      For d = 0 To \nMaxLightingLogicalDev
        sLogicalDev = \aLightingLogicalDevs(d)\sLogicalDev
        If sLogicalDev
          bLogicalDevFound = #False
          d2 = nFirstDevIndexForCCetc
          While d2 >= 0
            If grMapsForChecker\aDev(d2)\nDevGrp = #SCS_DEVGRP_LIGHTING
              debugMsg(sProcName, "grMapsForChecker\aDev(" + d2 + ")\sLogicalDev=" + grMapsForChecker\aDev(d2)\sLogicalDev)
              If grMapsForChecker\aDev(d2)\sLogicalDev = sLogicalDev
                bLogicalDevFound = #True
                Break
              EndIf
            EndIf
            d2 = grMapsForChecker\aDev(d2)\nNextDevIndex
          Wend
          debugMsg(sProcName, "bLogicalDevFound=" + strB(bLogicalDevFound))
          If bLogicalDevFound = #False
            nDevMapResult = -1
            sCheckMsg = LangPars("DevMap", "DevNotInDevMap", Lang("DevGrp", "Lighting"), sLogicalDev, sDevMapNameForCCetc)
            addDevMapCheckItemForDevGrp(#SCS_DEVGRP_LIGHTING, sCheckMsg, nDevMapResult)
            debugMsg(sProcName, "d=" + d + ", " + gsCheckDevMapMsg)
            Break
          EndIf
        EndIf
      Next d
    EndIf
    
    If nDevMapResult = 0
      For d = 0 To \nMaxCtrlSendLogicalDev
        If \aCtrlSendLogicalDevs(d)\nDevType <> #SCS_DEVTYPE_CS_HTTP_REQUEST ; Added HTTP Request test 13Nov2023 11.10.0cw
          sLogicalDev = \aCtrlSendLogicalDevs(d)\sLogicalDev
          If sLogicalDev
            bLogicalDevFound = #False
            d2 = nFirstDevIndexForCCetc
            While d2 >= 0
              If grMapsForChecker\aDev(d2)\nDevGrp = #SCS_DEVGRP_CTRL_SEND
                If grMapsForChecker\aDev(d2)\sLogicalDev = sLogicalDev
                  bLogicalDevFound = #True
                  Break
                EndIf
              EndIf
              d2 = grMapsForChecker\aDev(d2)\nNextDevIndex
            Wend
            If bLogicalDevFound = #False
              nDevMapResult = -1
              sCheckMsg = LangPars("DevMap", "DevNotInDevMap", Lang("DevGrp", "CtrlSend"), sLogicalDev, sDevMapNameForCCetc)
              addDevMapCheckItemForDevGrp(#SCS_DEVGRP_CTRL_SEND, sCheckMsg, nDevMapResult)
              debugMsg(sProcName, "d=" + d + ", " + gsCheckDevMapMsg)
              Break
            EndIf
          EndIf
        EndIf
      Next d
    EndIf
    
    If nDevMapResult = 0
      For d = 0 To \nMaxCueCtrlLogicalDev
        sLogicalDev = \aCueCtrlLogicalDevs(d)\sCueCtrlLogicalDev
        nDevType = \aCueCtrlLogicalDevs(d)\nDevType
        If (sLogicalDev) And (nDevType <> #SCS_DEVTYPE_NONE)
          bLogicalDevFound = #False
          d2 = nFirstDevIndexForCCetc
          While d2 >= 0
            If grMapsForChecker\aDev(d2)\nDevGrp = #SCS_DEVGRP_CUE_CTRL
              If (grMapsForChecker\aDev(d2)\sLogicalDev = sLogicalDev) And (grMapsForChecker\aDev(d2)\nDevType = nDevType)
                bLogicalDevFound = #True
                Break
              EndIf
            EndIf
            d2 = grMapsForChecker\aDev(d2)\nNextDevIndex
          Wend
          If bLogicalDevFound = #False
            nDevMapResult = -1
            sCheckMsg = LangPars("DevMap", "DevNotInDevMap", Lang("DevGrp", "CueCtrl"), sLogicalDev, sDevMapNameForCCetc)
            addDevMapCheckItemForDevGrp(#SCS_DEVGRP_CUE_CTRL, sCheckMsg, nDevMapResult)
            debugMsg(sProcName, "d=" + d + ", " + gsCheckDevMapMsg)
            Break
          EndIf
        EndIf
      Next d
    EndIf
  EndWith
  
  Select grMapsForChecker\aMap(nDevMapPtr)\nAudioDriver
    Case #SCS_DRV_BASS_DS, #SCS_DRV_BASS_WASAPI, #SCS_DRV_BASS_ASIO ; BASS
      ;{
      debugMsg(sProcName, "calling setBassInfoInDevMapForChecker(" + getDevMapName(nDevMapPtr) + ")")
      setBassInfoInDevMapForChecker(nDevMapPtr)
      ;}
    Case #SCS_DRV_SMS_ASIO ; SM-S
      ;{
      If grSMS\nSMSClientConnection = 0
        debugMsg(sProcName, "calling openSMSConnection()")
        openSMSConnection()
      EndIf
      bCreatingASIOGroup = #True
      bExitFunction = #False
      While bCreatingASIOGroup
        debugMsg(sProcName, "calling createASIOGroup()")
        createASIOGroup()
        If grASIOGroup\bGroupCreated = #True
          bCreatingASIOGroup = #False
        Else
          sMsg = grASIOGroup\sErrorMsg
          If Left(sMsg, 10) = "ERROR 0500"
            sMsg + "||This may be because the device is already connected to SM-S."
            sMsg + "||If so then disconnect the device from SM-S and click Retry.|"
            debugMsg(sProcName, "sMsg=" + sMsg)
            ensureSplashNotOnTop()
            nResponse = OptionRequester(0, 0, "SCS Device Mapper" + "|" + sMsg, "Retry|Cancel", 100, #IDI_EXCLAMATION)
            If nResponse = 2
              bCreatingASIOGroup = #False
              bExitFunction = #True
            EndIf
          Else
            bCreatingASIOGroup = #False
            bExitFunction = #True
          EndIf
        EndIf
      Wend
      If bExitFunction
        gsCheckDevMapMsg = grASIOGroup\sErrorMsg
        grDevMapCheckForSetIgnoreDevInds = grDevMapCheck
        debugMsg(sProcName, "gsCheckDevMapMsg=" + gsCheckDevMapMsg + ", grDevMapCheckForSetIgnoreDevInds\nCheckItemCount=" + grDevMapCheckForSetIgnoreDevInds\nCheckItemCount)
        SetMouseCursor(nMousePointer)
        debugMsg(sProcName, "returning -10 because createASIOGroup() failed")
        sCheckMsg = Lang("Errors", "CannotCreateASIOGroup")
        nDevResult = -10
        addDevMapCheckItemForDevGrp(#SCS_DEVGRP_AUDIO_OUTPUT, sCheckMsg, nDevResult)
        nDevMapResult = nDevResult
      EndIf
      bUsingASIOGroup = #True
      ;}
  EndSelect
  
  ; check each device in the devmap
  d = grMapsForChecker\aMap(nDevMapPtr)\nFirstDevIndex
  While d >= 0
    bDevGrpFound = #False
    rMyDev = grMapsForChecker\aDev(d)
    With rMyDev
      sPhysicalDevQuoted = "'" + \sPhysicalDev + "'"
      nDevResult = 0
      If \bIgnoreDevThisRun = #False
        Select \nDevGrp
          Case #SCS_DEVGRP_AUDIO_OUTPUT   ; #SCS_DEVGRP_AUDIO_OUTPUT
            ;{
            bDevGrpFound = #True
            Select \nDevType
              Case #SCS_DEVTYPE_AUDIO_OUTPUT
                If \bReroutedToDefault
                  sMyPhysicalDev = grMMedia\sDefAudDevDesc
                Else
                  sMyPhysicalDev = \sPhysicalDev
                EndIf
                debugMsg(sProcName, "grMapsForChecker\aDev(" + d + ")\nDevType=" + decodeDevType(\nDevType) + ", d=" + d + ", \sLogicalDev=" + \sLogicalDev + ", \nNrOfDevOutputChans=" + \nNrOfDevOutputChans +
                                    ", \sPhysicalDev=" + \sPhysicalDev + ", \bReroutedToDefault=" + strB(\bReroutedToDefault) + ", sMyPhysicalDev=" + sMyPhysicalDev + ", grMapsForChecker\aMap(" + nDevMapPtr + ")\nAudioDriver=" + decodeDriver(grMapsForChecker\aMap(nDevMapPtr)\nAudioDriver))
                ; check if this device is present (eg connected)
                \nPhysicalDevPtr = -1
                If Len(sMyPhysicalDev) = 0
                  sCheckMsg = LangPars("DevMap", "PhysDevBlank", decodeDevTypeL(\nDevType), \sLogicalDev)
                  nDevResult = -2
                  addDevMapCheckItem(@rMyDev, sCheckMsg, nDevResult)
                Else
                  ; debugMsg(sProcName, "sMyPhysicalDev=" + sMyPhysicalDev + ", grMapsForChecker\aMap(" + nDevMapPtr + ")\nAudioDriver=" + decodeDriver(grMapsForChecker\aMap(nDevMapPtr)\nAudioDriver))
                  For nPass = 1 To 2
                    For d2 = 0 To (gnPhysicalAudDevs - 1)
                      ; debugMsg(sProcName, "gaAudioDev(" + d2 + ")\sDesc=" + gaAudioDev(d2)\sDesc + ", \nAudioDriver=" + decodeDriver(gaAudioDev(d2)\nAudioDriver))
                      If (comparePhysDevDescs(gaAudioDev(d2)\sDesc, sMyPhysicalDev, nPass)) And (gaAudioDev(d2)\nAudioDriver = grMapsForChecker\aMap(nDevMapPtr)\nAudioDriver)
                        ; debugMsg(sProcName, "found")
                        If gaAudioDev(d2)\bInitialized = #False
                          debugMsg(sProcName, "calling initDevice(" + d2 + ", #False)")
                          nInitResult = initDevice(d2, #False)
                        EndIf
                        If gaAudioDev(d2)\bInitialized ; Test added 28Oct2024 11.10.6ax
                          grMapsForChecker\aDev(d)\nBassDevice = gaAudioDev(d2)\nBassDevice
                          ; debugMsg(sProcName, "grMapsForChecker\aDev(" + d + ")\nBassDevice=" + grMapsForChecker\aDev(d)\nBassDevice)
                          If gaAudioDev(d2)\bNoDevice
                            nRealPhysDevPtr = gaAudioDev(d2)\nRealPhysDevPtr
                          Else
                            nRealPhysDevPtr = d2
                          EndIf
                          debugMsg(sProcName, "grMapsForChecker\aDev(" + d + ")\nBassDevice=" + grMapsForChecker\aDev(d)\nBassDevice + ", nRealPhysDevPtr=" + nRealPhysDevPtr + ", gaAudioDev(" + nRealPhysDevPtr + ")\nInterfaceNo=" + gaAudioDev(nRealPhysDevPtr)\nInterfaceNo)
                          If gaAudioDev(nRealPhysDevPtr)\nInterfaceNo >= 0
                            \nPhysicalDevPtr = d2
                            ; debugMsg(sProcName, "\nPhysicalDevPtr=" + \nPhysicalDevPtr)
                            Break
                          EndIf
                        EndIf
                      Else
                        ; debugMsg(sProcName, "not found")
                      EndIf
                    Next d2
                    If \nPhysicalDevPtr >= 0
                      Break
                    EndIf
                  Next nPass
                  If \nPhysicalDevPtr = -1
                    sCheckMsg = LangPars("DevMap", "DevNotFound", sPhysicalDevQuoted)
                    If grMapsForChecker\aMap(nDevMapPtr)\nAudioDriver = #SCS_DRV_BASS_ASIO ; ASIO test added 28Oct2024 11.10.6ax
                      nDevResult = -21
                    Else
                      nDevResult = -3
                    EndIf
                    ; debugMsg(sProcName, "calling addDevMapCheckItem(@rMyDev, " + #DQUOTE$ + sCheckMsg + #DQUOTE$ + ", " + nDevResult + ")")
                    addDevMapCheckItem(@rMyDev, sCheckMsg, nDevResult)
                    debugMsg(sProcName, "nDevResult=" + nDevResult + ": device not found")
                  EndIf
                EndIf
                
                ; check all required fields entered
                If nDevResult = 0
                  If (\bNoDevice = #False) And (\nFirst1BasedOutputChan < 1)
                    sCheckMsg = LangPars("DevMap", "OutsBlank", decodeDevTypeL(\nDevType), \sLogicalDev)
                    nDevResult = -4
                    addDevMapCheckItem(@rMyDev, sCheckMsg, nDevResult)
                  EndIf
                EndIf
                
                If nDevResult = 0
                  ; initialize device if not yet initialized
                  If gaAudioDev(\nPhysicalDevPtr)\bInitialized = #False
                    debugMsg(sProcName, "calling initDevice(" + \nPhysicalDevPtr + ", #False)")
                    nInitResult = initDevice(\nPhysicalDevPtr, #False)
                    If nInitResult = #BASS_OK
                      grMapsForChecker\aDev(d)\nBassDevice = gaAudioDev(\nPhysicalDevPtr)\nBassDevice
                      debugMsg(sProcName, "grMapsForChecker\aDev(" + d + ")\nBassDevice=" + grMapsForChecker\aDev(d)\nBassDevice)
                    Else
                      sCheckMsg = "Device " + sPhysicalDevQuoted + " cannot be initialized (not connected or not started?)"
                      nDevResult = -5
                      addDevMapCheckItem(@rMyDev, sCheckMsg, nDevResult)
                    EndIf
                  Else
                    nInitResult = #BASS_OK
                  EndIf
                EndIf
                
                If nDevResult = 0
                  ; check sufficient outputs available
                  If \bNoDevice = #False
                    bSufficientOutputs = #False
                    If bUsingASIOGroup
                      nDevOutputs = grASIOGroup\nGroupOutputs
                    Else
                      nDevOutputs = gaAudioDev(\nPhysicalDevPtr)\nOutputs
                    EndIf
                    debugMsg(sProcName, "bUsingASIOGroup=" + strB(bUsingASIOGroup) + ", gaAudioDev(" + \nPhysicalDevPtr + ")\nOutputs=" + gaAudioDev(\nPhysicalDevPtr)\nOutputs +
                                        ", nDevOutputs=" + nDevOutputs + ", \nFirst1BasedOutputChan=" + \nFirst1BasedOutputChan + ", \nNrOfDevOutputChans=" + \nNrOfDevOutputChans +
                                        ", \s1BasedOutputRange=" + \s1BasedOutputRange)
                    If nDevOutputs >= (\nFirst1BasedOutputChan + \nNrOfDevOutputChans - 1)
                      bSufficientOutputs = #True
                    EndIf
                    ; added 16/07/2014 to handle outputs > those supported by the SM-S dongle or demo version - drops outputs back to be within range
                    If bSufficientOutputs = #False
                      If (grMapsForChecker\aMap(nDevMapPtr)\nAudioDriver = #SCS_DRV_SMS_ASIO) Or (\bReroutedToDefault) ; added \bReroutedToDefault 17Apr2018 11.7.0.1aw
                        If \nNrOfDevOutputChans <= nDevOutputs
                          While \nFirst1BasedOutputChan >= 1
                            \nFirst1BasedOutputChan - 2
                            If nDevOutputs >= (\nFirst1BasedOutputChan + \nNrOfDevOutputChans - 1)
                              If \nFirst1BasedOutputChan < 1
                                \nFirst1BasedOutputChan = 1
                              EndIf
                              bSufficientOutputs = #True
                              Break
                            EndIf
                          Wend
                        EndIf
                      EndIf
                    EndIf
                    ; end added 16/07/2014
                    If bSufficientOutputs = #False
                      debugMsg(sProcName, "d=" + d + ", bSufficientOutputs=" + strB(bSufficientOutputs) + ", \sPhysicalDev=" + \sPhysicalDev +
                                          ", nDevOutputs=" + nDevOutputs + ", \nFirst1BasedOutputChan=" + \nFirst1BasedOutputChan)
                      sCheckMsg = "Insufficient outputs available on " + sPhysicalDevQuoted + ". Require at least " + Str(\nFirst1BasedOutputChan + \nNrOfDevOutputChans - 1) +
                                  " but only " + nDevOutputs + " available."
                      nDevResult = -6
                      addDevMapCheckItem(@rMyDev, sCheckMsg, nDevResult)
                    EndIf
                    
                    If nDevResult = 0
                      If grMapsForChecker\aMap(nDevMapPtr)\nAudioDriver = #SCS_DRV_BASS_DS Or grMapsForChecker\aMap(nDevMapPtr)\nAudioDriver = #SCS_DRV_BASS_WASAPI
                        If rMyDev\bReroutedToDefault = #False
                          If checkDevMapForCheckerDSOutputsUsed(@rMyDev) = #False
                            sCheckMsg = "Requested output(s) (" + rMyDev\s1BasedOutputRange + ") for " + rMyDev\sLogicalDev + " not found on " + sPhysicalDevQuoted
                            nDevResult = -61
                            addDevMapCheckItem(@rMyDev, sCheckMsg, nDevResult)
                          EndIf
                        EndIf
                      EndIf
                    EndIf
                    
                  EndIf
                EndIf
                
            EndSelect
            ;}
          Case #SCS_DEVGRP_VIDEO_AUDIO   ; #SCS_DEVGRP_VIDEO_AUDIO
            ;{
            bDevGrpFound = #True
            Select \nDevType
              Case #SCS_DEVTYPE_VIDEO_AUDIO
                debugMsg(sProcName, "\nDevType=" + decodeDevType(\nDevType) + ", d=" + d + ", \sLogicalDev=" + \sLogicalDev + ", \sPhysicalDev=" + \sPhysicalDev)
                ; check if this device is present (eg connected)
                \nPhysicalDevPtr = -1
                If Len(\sPhysicalDev) = 0
                  sCheckMsg = LangPars("DevMap", "PhysDevBlank", decodeDevTypeL(\nDevType), \sLogicalDev)
                  nDevResult = -2
                  addDevMapCheckItem(@rMyDev, sCheckMsg, nDevResult)
                Else
                  debugMsg(sProcName, "\sPhysicalDev=" + \sPhysicalDev + ", grMapsForChecker\aMap(nDevMapPtr)\nAudioDriver=" + decodeDriver(grMapsForChecker\aMap(nDevMapPtr)\nAudioDriver))
                  For nPass = 1 To 2
                    For d2 = 0 To (gnNumVideoAudioDevs - 1)
                      debugMsg(sProcName, "gaVideoAudioDev(" + d2 + ")\sVidAudName=" + gaVideoAudioDev(d2)\sVidAudName)
                      If comparePhysDevDescs(gaVideoAudioDev(d2)\sVidAudName, \sPhysicalDev, nPass)
                        ; debugMsg(sProcName, "found")
                        If gaVideoAudioDev(d2)\bVidAudInitialized = #False
                          debugMsg(sProcName, "calling initVidAudDevice(" + d2 + ", #False)")
                          initVidAudDevice(d2, #False)
                        EndIf
                        nRealPhysDevPtr = d2
                        \nPhysicalDevPtr = d2
                        ; debugMsg(sProcName, "\nPhysicalDevPtr=" + \nPhysicalDevPtr)
                        Break
                      EndIf
                    Next d2
                    If \nPhysicalDevPtr >= 0
                      Break
                    EndIf
                  Next nPass
                  If \nPhysicalDevPtr = -1
                    ; If \sPhysicalDev = #SCS_DEFAULT_VIDAUD_PHYSICALDEV  ; "Windows Default Sound Device"
                    If \sPhysicalDev = "Windows Default Sound Device"
                      \nPhysicalDevPtr = 0
                    EndIf
                  EndIf
                  If \nPhysicalDevPtr = -1
                    sCheckMsg = LangPars("DevMap", "DevNotFound", sPhysicalDevQuoted)
                    nDevResult = -3
                    addDevMapCheckItem(@rMyDev, sCheckMsg, nDevResult)
                    debugMsg(sProcName, "nDevResult=" + nDevResult + ": device not found")
                  EndIf
                EndIf
                nInitResult = #BASS_OK
            EndSelect
            ;}
          Case #SCS_DEVGRP_VIDEO_CAPTURE   ; #SCS_DEVGRP_VIDEO_CAPTURE
            ;{
            bDevGrpFound = #True
            Select \nDevType
              Case #SCS_DEVTYPE_VIDEO_CAPTURE
                debugMsg(sProcName, "\nDevType=" + decodeDevType(\nDevType) + ", d=" + d + ", \sLogicalDev=" + \sLogicalDev + ", \sPhysicalDev=" + \sPhysicalDev)
                ; check if this device is present (eg connected)
                \nPhysicalDevPtr = -1
                If Len(\sPhysicalDev) = 0
                  sCheckMsg = LangPars("DevMap", "PhysDevBlank", decodeDevTypeL(\nDevType), \sLogicalDev)
                  nDevResult = -2
                  addDevMapCheckItem(@rMyDev, sCheckMsg, nDevResult)
                Else
                  debugMsg(sProcName, "\sPhysicalDev=" + \sPhysicalDev)
                  For nPass = 1 To 2
                    For d2 = 0 To (gnNumVideoCaptureDevs - 1)
                      debugMsg(sProcName, "gaVideoCaptureDev(" + d2 + ")\sVidCapName=" + gaVideoCaptureDev(d2)\sVidCapName)
                      If comparePhysDevDescs(gaVideoCaptureDev(d2)\sVidCapName, \sPhysicalDev, nPass)
                        debugMsg(sProcName, "found")
                        If gaVideoCaptureDev(d2)\bVidCapInitialized = #False
                          debugMsg(sProcName, "calling initVidCapDevice(" + d2 + ", #False)")
                          initVidCapDevice(d2, #False)
                        EndIf
                        nRealPhysDevPtr = d2
                        \nPhysicalDevPtr = d2
                        ; debugMsg(sProcName, "\nPhysicalDevPtr=" + \nPhysicalDevPtr)
                        Break
                      EndIf
                    Next d2
                    If \nPhysicalDevPtr >= 0
                      Break
                    EndIf
                  Next nPass
                  If \nPhysicalDevPtr = -1
                    sCheckMsg = LangPars("DevMap", "DevNotFound", sPhysicalDevQuoted)
                    nDevResult = -3
                    addDevMapCheckItem(@rMyDev, sCheckMsg, nDevResult)
                    debugMsg(sProcName, "nDevResult=" + nDevResult + ": device not found")
                  EndIf
                EndIf
                nInitResult = #BASS_OK
            EndSelect
            ;}
          Case #SCS_DEVGRP_LIVE_INPUT   ; #SCS_DEVGRP_LIVE_INPUT
            ;{
            bDevGrpFound = #True
            Select \nDevType
              Case #SCS_DEVTYPE_LIVE_INPUT
                debugMsg(sProcName, "\nDevType=" + decodeDevType(\nDevType) + ", d=" + d + ", \sLogicalDev=" + \sLogicalDev + ", \nNrOfInputChans=" + \nNrOfInputChans)
                ; check if this device is present (eg connected)
                \nPhysicalDevPtr = -1
                If Len(\sPhysicalDev) = 0
                  If Len(gsCheckDevMapMsg) = 0
                    gsCheckDevMapMsg = LangPars("DevMap", "PhysDevBlank", decodeDevTypeL(\nDevType), \sLogicalDev)
                    grDevMapCheckForSetIgnoreDevInds = grDevMapCheck
                    debugMsg(sProcName, "gsCheckDevMapMsg=" + gsCheckDevMapMsg + ", grDevMapCheckForSetIgnoreDevInds\nCheckItemCount=" + grDevMapCheckForSetIgnoreDevInds\nCheckItemCount)
                  EndIf
                  grDevMapCheck\bDevGrpIssue[#SCS_DEVGRP_LIVE_INPUT] = #True
                  nDevResult = -2
                Else
                  debugMsg(sProcName, "\sPhysicalDev=" + \sPhysicalDev + ", grMapsForChecker\aMap(" + nDevMapPtr + ")\nAudioDriver=" + decodeDriver(grMapsForChecker\aMap(nDevMapPtr)\nAudioDriver))
                  If \bDummy = #False
                    For nPass = 1 To 2
                      For d2 = 0 To (gnPhysicalAudDevs - 1)
                        ; debugMsg(sProcName, "gaAudioDev(" + d2 + ")\sDesc=" + gaAudioDev(d2)\sDesc)
                        If (comparePhysDevDescs(gaAudioDev(d2)\sDesc, \sPhysicalDev, nPass)) And (gaAudioDev(d2)\nAudioDriver = grMapsForChecker\aMap(nDevMapPtr)\nAudioDriver)
                          ; debugMsg(sProcName, "found")
                          If gaAudioDev(d2)\bInitialized = #False
                            debugMsg(sProcName, "calling initDevice(" + d2 + ", #False)")
                            initDevice(d2, #False)
                          EndIf
                          grMapsForChecker\aDev(d)\nBassDevice = gaAudioDev(d2)\nBassDevice
                          debugMsg(sProcName, "grMapsForChecker\aDev(" + d + ")\nBassDevice=" + grMapsForChecker\aDev(d)\nBassDevice)
                          If gaAudioDev(d2)\bNoDevice
                            nRealPhysDevPtr = gaAudioDev(d2)\nRealPhysDevPtr
                          Else
                            nRealPhysDevPtr = d2
                          EndIf
                          debugMsg(sProcName, "nRealPhysDevPtr=" + nRealPhysDevPtr + ", gaAudioDev(" + nRealPhysDevPtr + ")\nInterfaceNo=" + gaAudioDev(nRealPhysDevPtr)\nInterfaceNo)
                          If gaAudioDev(nRealPhysDevPtr)\nInterfaceNo >= 0
                            \nPhysicalDevPtr = d2
                            ; debugMsg(sProcName, "\nPhysicalDevPtr=" + \nPhysicalDevPtr)
                            Break
                          EndIf
                        EndIf
                      Next d2
                      If \nPhysicalDevPtr >= 0
                        Break
                      EndIf
                    Next nPass
                    If \nPhysicalDevPtr = -1
                      sCheckMsg = LangPars("DevMap", "DevNotFound", sPhysicalDevQuoted)
                      nDevResult = -3
                      addDevMapCheckItem(@rMyDev, sCheckMsg, nDevResult)
                      debugMsg(sProcName, "nDevResult=" + nDevResult + ": device not found")
                    EndIf
                  EndIf
                EndIf
                
                ; check all required fields entered
                If nDevResult = 0
                  If (\bNoDevice = #False) And (\nFirst1BasedInputChan < 1)
                    debugMsg(sProcName, "grMapsForChecker\aDev(" + d + ")\nFirst1BasedInputChan=" + grMapsForChecker\aDev(d)\nFirst1BasedInputChan)
                    sCheckMsg = LangPars("DevMap", "InputChanBlank", decodeDevTypeL(\nDevType), \sLogicalDev)
                    nDevResult = -4
                    addDevMapCheckItem(@rMyDev, sCheckMsg, nDevResult)
                  EndIf
                EndIf
                
                If nDevResult = 0
                  If \bDummy = #False
                    ; initialize device if not yet initialized
                    If gaAudioDev(\nPhysicalDevPtr)\bInitialized = #False
                      debugMsg(sProcName, "(s0 calling initDevice(" + \nPhysicalDevPtr + ", #False)")
                      nInitResult = initDevice(\nPhysicalDevPtr, #False)
                      If nInitResult = #BASS_OK
                        grMapsForChecker\aDev(d)\nBassDevice = gaAudioDev(\nPhysicalDevPtr)\nBassDevice
                        debugMsg(sProcName, "grMapsForChecker\aDev(" + d + ")\nBassDevice=" + grMapsForChecker\aDev(d)\nBassDevice)
                      Else
                        sCheckMsg = "Device " + sPhysicalDevQuoted + " cannot be initialized (not connected or not started?)"
                        nDevResult = -5
                        addDevMapCheckItem(@rMyDev, sCheckMsg, nDevResult)
                      EndIf
                    Else
                      nInitResult = #BASS_OK
                    EndIf
                  Else
                    nInitResult = #BASS_OK
                  EndIf
                EndIf
                
                If nDevResult = 0
                  ; check sufficient inputs available
                  If \bNoDevice = #False And \bDummy = #False
                    bSufficientInputs = #False
                    If bUsingASIOGroup
                      nDevInputs = grASIOGroup\nGroupInputs
                    Else
                      nDevInputs = gaAudioDev(\nPhysicalDevPtr)\nInputs
                    EndIf
                    If nDevInputs >= (\nFirst1BasedInputChan + \nNrOfInputChans - 1)
                      bSufficientInputs = #True
                    EndIf
                    If bSufficientInputs = #False
                      debugMsg(sProcName, "d=" + d + ", bSufficientInputs=" + strB(bSufficientInputs) + ", \sPhysicalDev=" + \sPhysicalDev + ", nDevInputs=" + nDevInputs + ", \nFirst1BasedInputChan=" + \nFirst1BasedInputChan)
                      sCheckMsg = "Insufficient Inputs available on " + \sPhysicalDev + ". Require at least " + \nFirst1BasedInputChan + " but only " + nDevInputs + " available."
                      nDevResult = -6
                      addDevMapCheckItem(@rMyDev, sCheckMsg, nDevResult)
                    EndIf
                  EndIf
                EndIf
                
            EndSelect
            ;}
        EndSelect ; EndSelect \nDevGrp
      EndIf ; EndIf \bIgnoreDevThisRun = #False
      
      If bDevGrpFound
        If nDevResult = 0
          grMapsForChecker\aDev(d)\nDevState = #SCS_DEVSTATE_ACTIVE
        Else
          grMapsForChecker\aDev(d)\nDevState = #SCS_DEVSTATE_INACTIVE
          debugMsg(sProcName, "d=" + d + ", " + gsCheckDevMapMsg)
          If nDevMapResult = 0
            nDevMapResult = nDevResult
          EndIf
        EndIf
        debugMsg(sProcName, "grMapsForChecker\aDev(" + d + ")\nDevGrp=" + decodeDevGrp(grMapsForChecker\aDev(d)\nDevGrp) +
                            ", \nDevType=" + decodeDevType(grMapsForChecker\aDev(d)\nDevType) +
                            ", \sPhysicalDev=" + grMapsForChecker\aDev(d)\sPhysicalDev +
                            ", \bDefaultDev=" + strB(grMapsForChecker\aDev(d)\bDefaultDev) +
                            ", \bDummy=" + strB(grMapsForChecker\aDev(d)\bDummy) +
                            ", \nDevState=" + decodeDevState(grMapsForChecker\aDev(d)\nDevState))
      EndIf
      d = grMapsForChecker\aDev(d)\nNextDevIndex
    EndWith
  Wend
  
  ; check other devices (which used to controlled by devmapC)
  debugMsg(sProcName, "check other devices")
  d = grMapsForChecker\aMap(nDevMapPtr)\nFirstDevIndex
  
  While d >= 0
    bDevGrpFound = #False
    rMyDev = grMapsForChecker\aDev(d)
    With rMyDev
      If \bIgnoreDevThisRun
        debugMsg(sProcName, "grMapsForChecker\aDev(" + d + ")\nDevType=" + decodeDevType(\nDevType) + ", \bIgnoreDevThisRun=" + strB(\bIgnoreDevThisRun))
      EndIf
      Select \nDevType
        Case #SCS_DEVTYPE_CC_DMX_IN, #SCS_DEVTYPE_LT_DMX_OUT
          sPhysicalDevQuoted = "'" + \sPhysicalDev
          If \nDMXSerial
            sPhysicalDevQuoted + " (" + \nDMXSerial + ")"
          ElseIf \sDMXSerial
            sPhysicalDevQuoted + " (" + \sDMXSerial + ")"
          EndIf
          sPhysicalDevQuoted + "'"
          ; debugMsg(sProcName, "\nDevType=" + decodeDevType(\nDevType) + ", \sLogicalDev=" + \sLogicalDev + ", \sPhysicalDev=" + \sPhysicalDev +
          ;                     ", \nDMXSerial=" + \nDMXSerial + ", \sDMXSerial=" + \sDMXSerial + ", sPhysicalDevQuoted=" + sPhysicalDevQuoted)
        Default
          sPhysicalDevQuoted = "'" + \sPhysicalDev + "'"
      EndSelect
      \nPhysicalDevPtr = -1
      nDevResult = 0
      If \bIgnoreDevThisRun = #False
        If \nDevType <> #SCS_DEVTYPE_NONE And \nDevType <> #SCS_DEVTYPE_CS_HTTP_REQUEST ; Added HTTP Request devtype 13Nov2023 11.10.0cw
          debugMsg(sProcName, "grMapsForChecker\aDev(" + d + ")\nDevGrp=" + decodeDevGrp(\nDevGrp) + ", \nDevType=" + decodeDevType(\nDevType) + ", \sPhysicalDev=" + \sPhysicalDev + ", \bDummy=" + strB(\bDummy))
        EndIf
        Select \nDevGrp
          Case #SCS_DEVGRP_LIGHTING  ; #SCS_DEVGRP_LIGHTING
            ;{
            bDevGrpFound = #True
            If Len(\sPhysicalDev) = 0
              sCheckMsg = LangPars("DevMap", "PhysDevBlank", decodeDevTypeL(\nDevType), \sLogicalDev)
              nDevResult = -2
              addDevMapCheckItem(@rMyDev, sCheckMsg, nDevResult)
            Else
              Select \nDevType
                Case #SCS_DEVTYPE_LT_DMX_OUT
                  \nPhysicalDevPtr = DMX_getDMXDevPtr(\sPhysicalDev, \sDMXSerial, \nDMXSerial, \bDummy)
                  debugMsg(sProcName, "DMX_getDMXDevPtr(" + \sPhysicalDev + ", " + \sDMXSerial + ", " + \nDMXSerial + ", " + strB(\bDummy) + ") returned " + \nPhysicalDevPtr)
                  If \nPhysicalDevPtr = -1
                    sCheckMsg = LangPars("DevMap", "DevNotFound", sPhysicalDevQuoted)
                    nDevResult = -3
                    addDevMapCheckItem(@rMyDev, sCheckMsg, nDevResult)
                    debugMsg(sProcName, "(dmxout) nDevResult=" + nDevResult + ": device not found")
                  EndIf
                  ; Added 25Jun2021 11.8.5ao
                  loadDMXStartChannelsIfReqd(@grProdForChecker, @grMapsForChecker\aDev(d)) ; replacement for code below 11Apr2022 11.9.1ba
              EndSelect
            EndIf
            ;}
          Case #SCS_DEVGRP_CTRL_SEND  ; #SCS_DEVGRP_CTRL_SEND
            ;{
            bDevGrpFound = #True
            If Len(\sPhysicalDev) = 0 And \nDevType <> #SCS_DEVTYPE_CS_HTTP_REQUEST ; Added HTTP Request test 13Nov2023 11.10.0cw
              sCheckMsg = LangPars("DevMap", "PhysDevBlank", decodeDevTypeL(\nDevType), \sLogicalDev)
              nDevResult = -2
              addDevMapCheckItem(@rMyDev, sCheckMsg, nDevResult)
            Else
              Select \nDevType
                Case #SCS_DEVTYPE_CS_MIDI_OUT
                  \nPhysicalDevPtr = getMidiOutPhysicalDevPtr(\sPhysicalDev, \bDummy)
                  If \nPhysicalDevPtr = -1
                    sCheckMsg = LangPars("DevMap", "DevNotFound", sPhysicalDevQuoted)
                    nDevResult = -3
                    addDevMapCheckItem(@rMyDev, sCheckMsg, nDevResult)
                    debugMsg(sProcName, "(midiout) nDevResult=" + nDevResult + ": device not found")
                  EndIf
                  
                Case #SCS_DEVTYPE_CS_MIDI_THRU
                  \nPhysicalDevPtr = getMidiOutPhysicalDevPtr(\sPhysicalDev, \bDummy)
                  If \nPhysicalDevPtr = -1
                    sCheckMsg = LangPars("DevMap", "DevNotFound", sPhysicalDevQuoted)
                    nDevResult = -3
                    addDevMapCheckItem(@rMyDev, sCheckMsg, nDevResult)
                    debugMsg(sProcName, "(midithru-out) nDevResult=" + nDevResult + ": device not found")
                  EndIf
                  \nMidiThruInPhysicalDevPtr = getMidiInPhysicalDevPtr(\sMidiThruInPhysicalDev, \bMidiThruInDummy)
                  If \nMidiThruInPhysicalDevPtr = -1
                    sCheckMsg = LangPars("DevMap", "DevNotFound", "'" + \sMidiThruInPhysicalDev + "'")
                    nDevResult = -3
                    addDevMapCheckItem(@rMyDev, sCheckMsg, nDevResult)
                    debugMsg(sProcName, "(midithru-in) nDevResult=" + nDevResult + ": device not found")
                  EndIf
                  
                Case #SCS_DEVTYPE_CS_RS232_OUT
                  \nPhysicalDevPtr = getRS232ControlIndexForRS232PortAddress(\sPhysicalDev, \bDummy) 
                  If \nPhysicalDevPtr >= 0
                    If gaRS232Control(\nPhysicalDevPtr)\bInitialized = #False
                      initRS232Device(\nPhysicalDevPtr, \nDevType)
                    EndIf
                    If gaRS232Control(\nPhysicalDevPtr)\bInitialized
                      gaRS232Control(\nPhysicalDevPtr)\bRS232Out = #True
                    Else
                      sCheckMsg = LangPars("DevMap", "DevNotActive", decodeDevTypeL(\nDevType), \sPhysicalDev)
                      nDevResult = -7
                      addDevMapCheckItem(@rMyDev, sCheckMsg, nDevResult)
                    EndIf
                  EndIf
                  If \nPhysicalDevPtr = -1
                    sCheckMsg = LangPars("DevMap", "DevNotFound", sPhysicalDevQuoted)
                    nDevResult = -3
                    addDevMapCheckItem(@rMyDev, sCheckMsg, nDevResult)
                    debugMsg(sProcName, "(rs232out) nDevResult=" + nDevResult + ": device not found")
                  EndIf
                  
                Case #SCS_DEVTYPE_CS_NETWORK_OUT
                  \nPhysicalDevPtr = getNetworkControlPtrForNetworkDevDesc(\nDevType, \sPhysicalDev, \bDummy)
                  debugMsg(sProcName, "(networkout) grMapsForChecker\aDev(" + d + ")\nPhysicalDevPtr=" + \nPhysicalDevPtr)
                  If \nPhysicalDevPtr >= 0
                    debugMsg(sProcName, "(networkout) (1) gaNetworkControl(" + \nPhysicalDevPtr + ")\bNetworkDevInitialized=" + strB(gaNetworkControl(\nPhysicalDevPtr)\bNetworkDevInitialized))
                    If gaNetworkControl(\nPhysicalDevPtr)\bNetworkDevInitialized = #False
                      debugMsg(sProcName, "#SCS_DEVTYPE_CS_NETWORK_OUT: calling startNetwork(" + \nPhysicalDevPtr + ", " + strB(bInDevChgs) + ", " + d + ")")
                      startNetwork(\nPhysicalDevPtr, bInDevChgs, d)
                      \bIgnoreDevThisRun = grMapsForChecker\aDev(d)\bIgnoreDevThisRun
                      debugMsg(sProcName, "grMapsForChecker\aDev(" + d + ")\bIgnoreDevThisRun=" + strB(\bIgnoreDevThisRun))
                    EndIf
                    If \bIgnoreDevThisRun = #False And \bConnectWhenReqd = #False ; Changed 19Sep2022 11.9.6
                      debugMsg(sProcName, "(networkout) (2) gaNetworkControl(" + \nPhysicalDevPtr + ")\bNetworkDevInitialized=" + strB(gaNetworkControl(\nPhysicalDevPtr)\bNetworkDevInitialized))
                      If (gaNetworkControl(\nPhysicalDevPtr)\bNetworkDevInitialized = #False) And (gaNetworkControl(\nPhysicalDevPtr)\bNWDummy = #False)
                        sCheckMsg = LangPars("DevMap", "DevNotActive", decodeDevTypeL(\nDevType), \sPhysicalDev)
                        nDevResult = -8
                        addDevMapCheckItem(@rMyDev, sCheckMsg, nDevResult)
                      EndIf
                    EndIf
                  EndIf
                  If \nPhysicalDevPtr = -1
                    sCheckMsg = LangPars("DevMap", "DevNotFound", sPhysicalDevQuoted)
                    nDevResult = -3
                    addDevMapCheckItem(@rMyDev, sCheckMsg, nDevResult)
                    debugMsg(sProcName, "(networkout) nDevResult=" + nDevResult + ": device not found")
                  EndIf
                  
                Case #SCS_DEVTYPE_LT_DMX_OUT
                  \nPhysicalDevPtr = DMX_getDMXDevPtr(\sPhysicalDev, \sDMXSerial, \nDMXSerial, \bDummy)
                  debugMsg(sProcName, "DMX_getDMXDevPtr(" + \sPhysicalDev + ", " + \sDMXSerial + ", " + \nDMXSerial + ", " + strB(\bDummy) + ") returned " + \nPhysicalDevPtr)
                  If \nPhysicalDevPtr = -1
                    sCheckMsg = LangPars("DevMap", "DevNotFound", sPhysicalDevQuoted)
                    nDevResult = -3
                    addDevMapCheckItem(@rMyDev, sCheckMsg, nDevResult)
                    debugMsg(sProcName, "(dmxout) nDevResult=" + nDevResult + ": device not found")
                  EndIf
                  
                Case #SCS_DEVTYPE_CS_HTTP_REQUEST
                  \nPhysicalDevPtr = 0
                  
              EndSelect
            EndIf
            ;}
          Case #SCS_DEVGRP_CUE_CTRL   ; #SCS_DEVGRP_CUE_CTRL
            ;{
            bDevGrpFound = #True
            Select \nDevType
              Case #SCS_DEVTYPE_CC_MIDI_IN
                \nPhysicalDevPtr = getMidiInPhysicalDevPtr(\sPhysicalDev, \bDummy)
                If \nPhysicalDevPtr = -1
                  sCheckMsg = LangPars("DevMap", "DevNotFound", sPhysicalDevQuoted)
                  nDevResult = -3
                  addDevMapCheckItem(@rMyDev, sCheckMsg, nDevResult)
                  debugMsg(sProcName, "(midiin) nDevResult=" + nDevResult + ": device not found")
                EndIf
                
              Case #SCS_DEVTYPE_CC_RS232_IN
                \nPhysicalDevPtr = getRS232ControlIndexForRS232PortAddress(\sPhysicalDev, \bDummy) 
                If \nPhysicalDevPtr >= 0
                  If gaRS232Control(\nPhysicalDevPtr)\bInitialized = #False
                    initRS232Device(\nPhysicalDevPtr, \nDevType)
                  EndIf
                  If gaRS232Control(\nPhysicalDevPtr)\bInitialized
                    gaRS232Control(\nPhysicalDevPtr)\bRS232In = #True
                  Else
                    sCheckMsg = LangPars("DevMap", "DevNotActive", decodeDevTypeL(\nDevType), sPhysicalDevQuoted)
                    nDevResult = -11
                    addDevMapCheckItem(@rMyDev, sCheckMsg, nDevResult)
                  EndIf
                EndIf
                If \nPhysicalDevPtr = -1
                  sCheckMsg = LangPars("DevMap", "DevNotFound", sPhysicalDevQuoted)
                  nDevResult = -3
                  addDevMapCheckItem(@rMyDev, sCheckMsg, nDevResult)
                  debugMsg(sProcName, "(rs232in) nDevResult=" + nDevResult + ": device not found")
                EndIf
                
              Case #SCS_DEVTYPE_CC_NETWORK_IN
                debugMsg(sProcName, "#SCS_DEVTYPE_CC_NETWORK_IN: \sRemoteHost=" + \sRemoteHost + ", \nRemotePort=" + \nRemotePort + ", \nLocalPort=" + \nLocalPort)
                debugMsg(sProcName, "grMapsForChecker\aDev(" + d + ")\nPhysicalDevPtr=" + \nPhysicalDevPtr)
                \nPhysicalDevPtr = getNetworkControlPtrForNetworkDevDesc(\nDevType, \sPhysicalDev, \bDummy)
                debugMsg(sProcName, "getNetworkControlPtrForNetworkDevDesc(" + decodeDevType(\nDevType) + ", " + \sPhysicalDev + ", " + strB(\bDummy) + ") returned grMapsForChecker\aDev(" + d + ")\nPhysicalDevPtr=" + \nPhysicalDevPtr)
                debugMsg(sProcName, "grMapsForChecker\aDev(" + d + ")\nPhysicalDevPtr=" + \nPhysicalDevPtr)
                If \nPhysicalDevPtr >= 0
                  If gaNetworkControl(\nPhysicalDevPtr)\bNetworkDevInitialized = #False
                    debugMsg(sProcName, "#SCS_DEVTYPE_CC_NETWORK_IN: calling startNetwork(" + \nPhysicalDevPtr + ", " + strB(bInDevChgs) + ", " + d + ")")
                    startNetwork(\nPhysicalDevPtr, bInDevChgs, d)
                    \bIgnoreDevThisRun = grMapsForChecker\aDev(d)\bIgnoreDevThisRun
                  EndIf
                  If \bIgnoreDevThisRun = #False
                    If (gaNetworkControl(\nPhysicalDevPtr)\bNetworkDevInitialized = #False) And (gaNetworkControl(\nPhysicalDevPtr)\bNWDummy = #False)
                      sCheckMsg = LangPars("DevMap", "DevNotActive", decodeDevTypeL(\nDevType), \sPhysicalDev)
                      nDevResult = -12
                      addDevMapCheckItem(@rMyDev, sCheckMsg, nDevResult)
                      debugMsg(sProcName, "(networkin) nDevResult=" + nDevResult)
                    EndIf
                  EndIf
                EndIf
                If \nPhysicalDevPtr = -1
                  sCheckMsg = LangPars("DevMap", "DevNotFound", sPhysicalDevQuoted)
                  nDevResult = -3
                  addDevMapCheckItem(@rMyDev, sCheckMsg, nDevResult)
                  debugMsg(sProcName, "(networkin) nDevResult=" + nDevResult + ": device not found")
                EndIf
                
              Case #SCS_DEVTYPE_CC_DMX_IN
                \nPhysicalDevPtr = DMX_getDMXDevPtr(\sPhysicalDev, \sDMXSerial, \nDMXSerial, \bDummy)
                debugMsg(sProcName, "DMX_getDMXDevPtr(" + \sPhysicalDev + ", " + \sDMXSerial + ", " + \nDMXSerial + ", " + strB(\bDummy) + ") returned " + \nPhysicalDevPtr)
                If \nPhysicalDevPtr = -1
                  sCheckMsg = LangPars("DevMap", "DevNotFound", sPhysicalDevQuoted)
                  nDevResult = -3
                  addDevMapCheckItem(@rMyDev, sCheckMsg, nDevResult)
                  debugMsg(sProcName, "(dmxin) nDevResult=" + nDevResult + ": device not found")
                EndIf
                
            EndSelect
            ;}
        EndSelect ; EndSelect \nDevGrp
      EndIf ; EndIf \bIgnoreDevThisRun = #False
      
      If bDevGrpFound
        If nDevResult = 0
          If \nDevType = #SCS_DEVTYPE_NONE
            grMapsForChecker\aDev(d)\nDevState = #SCS_DEVSTATE_NA
          Else
            grMapsForChecker\aDev(d)\nDevState = #SCS_DEVSTATE_ACTIVE
          EndIf
        Else
          grMapsForChecker\aDev(d)\nDevState = #SCS_DEVSTATE_INACTIVE
          debugMsg(sProcName, "d=" + d + ", nDevResult=" + nDevResult + ", " + gsCheckDevMapMsg)
          ; MessageRequester("stop", "(z) d=" + d + ", " + gsCheckDevMapMsg)
          If nDevMapResult = 0
            nDevMapResult = nDevResult
          EndIf
        EndIf
        If \nDevType <> #SCS_DEVTYPE_NONE
          debugMsg(sProcName, "grMapsForChecker\aDev(" + d + ")\nDevGrp=" + decodeDevGrp(grMapsForChecker\aDev(d)\nDevGrp) +
                              ", \nDevType=" + decodeDevType(grMapsForChecker\aDev(d)\nDevType) +
                              ", \sPhysicalDev=" + grMapsForChecker\aDev(d)\sPhysicalDev +
                              ", \bDummy=" + strB(grMapsForChecker\aDev(d)\bDummy) +
                              ", \nDevState=" + decodeDevState(grMapsForChecker\aDev(d)\nDevState))
        EndIf
      EndIf
      d = grMapsForChecker\aDev(d)\nNextDevIndex
    EndWith
  Wend
  
  Select grMapsForChecker\aMap(nDevMapPtr)\nAudioDriver
    Case #SCS_DRV_SMS_ASIO ; SM-S
      If checkDevMapForCheckerSMSOutputsUsed(nDevMapPtr) = #False
        sCheckMsg = "More outputs assigned than available - please adjust mappings to use no more than " + grMMedia\nSMSMaxOutputs + " outputs."
        nDevMapResult = -9
        addDevMapCheckItemForDevGrp(#SCS_DEVGRP_AUDIO_OUTPUT, sCheckMsg, nDevMapResult)
      EndIf
  EndSelect
  
  debugMsg(sProcName, "calling checkMTCLTCIntegrity(@grProdForChecker)")
  sErrorMsg = checkMTCLTCIntegrity(@grProdForChecker)
  If sErrorMsg
    If Len(gsCheckDevMapMsg) = 0
      gsCheckDevMapMsg = sErrorMsg
      grDevMapCheckForSetIgnoreDevInds = grDevMapCheck
      debugMsg(sProcName, "gsCheckDevMapMsg=" + gsCheckDevMapMsg + ", grDevMapCheckForSetIgnoreDevInds\nCheckItemCount=" + grDevMapCheckForSetIgnoreDevInds\nCheckItemCount)
    EndIf
    ; grDevMapCheck\bDevGrpIssue[#SCS_DEVGRP_CUE_CTRL] = #True  ; commented out - set within checkMTCIntegrity()
    nDevMapResult = -10
  EndIf
  
  SetMouseCursor(nMousePointer)
  
  debugMsg(sProcName, #SCS_END + ", returning " + nDevMapResult)
  ProcedureReturn nDevMapResult
EndProcedure

Procedure createInitialDevMapForProd()
  PROCNAMEC()
  Protected nSelectedDevMapPtr, nDevMapId
  Protected d, d2, d3, n
  Protected nNrOfOutputChans, nFirst1BasedOutputChan
  Protected nSortedPhysPtr, bFound
  Protected nLastOutputUsed, nOutputs
  Protected nLastInputUsed, nInputs
  Protected bUsingNoDevice
  Protected bUsingMonitor
  Protected bGetNextDev
  Protected nLastMonitorOutputUsed
  Protected nMyPrevDevIndex
  Protected nDevType
  Protected Dim aDevTypeDevCount(#SCS_DEVTYPE_LAST)
  Protected bRequiresSMS
  Protected sReqdAudPrimaryDev.s
  Protected bDefaultDev, bDefaultDevUsed ; Added 25Nov2022 11.9.7am
  
  debugMsg(sProcName, #SCS_START)
  
  With grMaps
    \nMaxMapIndex = -1
    \nMaxDevIndex = -1
    \nMaxLiveGrpIndex = -1
    \sSelectedDevMapName = ""
  EndWith
  
  nSortedPhysPtr = -1
  nSelectedDevMapPtr = -1
  bUsingNoDevice = #False
  bUsingMonitor = #False
  
  debugMsg(sProcName, "gnPhysicalAudDevs=" + gnPhysicalAudDevs + ", gnCurrAudioDriver=" + decodeDriver(gnCurrAudioDriver))
  
  If gnPhysicalAudDevs > 0
    gnUniqueDevMapId + 1
    nDevMapId = gnUniqueDevMapId
    grMaps\nMaxMapIndex + 1
    nSelectedDevMapPtr = grMaps\nMaxMapIndex
    debugMsg(sProcName, "grMaps\nMaxMapIndex=" + grMaps\nMaxMapIndex + ", ArraySize(grMaps\aMap()=" + ArraySize(grMaps\aMap()))
    If grMaps\nMaxMapIndex > ArraySize(grMaps\aMap())
      REDIM_ARRAY(grMaps\aMap, grMaps\nMaxMapIndex, grDevMapDef, "grMaps\aMap()")
    EndIf
    
    For d = 0 To grProd\nMaxLiveInputLogicalDev
      If grProd\aLiveInputLogicalDevs(d)\sLogicalDev
        ; at least one live input device so requires SoundMan-Server
        bRequiresSMS = #True
        Break
      EndIf
    Next d
    
    debugMsg(sProcName, "grAction\bProcessingAction=" + strB(grAction\bProcessingAction) + ", grAction\nAction=" + grAction\nAction + ", Trim(grAction\sDevMapName)=" + Trim(grAction\sDevMapName))
    If (grAction\bProcessingAction) And (grAction\nAction = #SCS_ACTION_CREATE) And (Trim(grAction\sDevMapName))
      grMaps\aMap(nSelectedDevMapPtr)\sDevMapName = Trim(grAction\sDevMapName)
    ElseIf Trim(grLoadProdPrefs\sDevMapName)
      grMaps\aMap(nSelectedDevMapPtr)\sDevMapName = Trim(grLoadProdPrefs\sDevMapName)
    Else
      grMaps\aMap(nSelectedDevMapPtr)\sDevMapName = Trim(GetEnvironmentVariable("computername"))
    EndIf
    grMaps\sSelectedDevMapName = grMaps\aMap(nSelectedDevMapPtr)\sDevMapName
    debugMsg(sProcName, "grMaps\aMap(" + nSelectedDevMapPtr + ")\sDevMapName=" + grMaps\aMap(nSelectedDevMapPtr)\sDevMapName + ", grMaps\sSelectedDevMapName=" + grMaps\sSelectedDevMapName)
    grMaps\aMap(nSelectedDevMapPtr)\nDevMapId = nDevMapId
    grMaps\aMap(nSelectedDevMapPtr)\nFirstDevIndex = -1
    grMaps\aMap(nSelectedDevMapPtr)\bNewDevMap = #True
    If bRequiresSMS
      grMaps\aMap(nSelectedDevMapPtr)\nAudioDriver = #SCS_DRV_SMS_ASIO
    ElseIf (grAction\bProcessingAction) And (grAction\nAction = #SCS_ACTION_CREATE)
      grMaps\aMap(nSelectedDevMapPtr)\nAudioDriver = grAction\nAudioDriver
      sReqdAudPrimaryDev = grAction\sAudPrimaryDev
      debugMsg(sProcName, "sReqdAudPrimaryDev=" + sReqdAudPrimaryDev)
    Else
      grMaps\aMap(nSelectedDevMapPtr)\nAudioDriver = gnDefaultAudioDriver
    EndIf
    debugMsg(sProcName, "grMaps\aMap(" + nSelectedDevMapPtr + ")\nFirstDevIndex=" + grMaps\aMap(nSelectedDevMapPtr)\nFirstDevIndex)
    
    debugMsg(sProcName, "calling setCurrAudioDriver(" + decodeDriver(grMaps\aMap(nSelectedDevMapPtr)\nAudioDriver) + ")")
    setCurrAudioDriver(grMaps\aMap(nSelectedDevMapPtr)\nAudioDriver)
    
    debugMsg(sProcName, "grMaps\nMaxDevIndex=" + grMaps\nMaxDevIndex)
    d2 = grMaps\nMaxDevIndex
    nMyPrevDevIndex = -1
    
    ; INFO: create initial audio devices
    ;{
    debugMsg(sProcName, "calling sortAudioDevs(" + decodeDriver(gnCurrAudioDriver) + ")")
    sortAudioDevs(gnCurrAudioDriver)
    nSortedPhysPtr = -1
    nDevType = #SCS_DEVTYPE_AUDIO_OUTPUT
    bDefaultDevUsed = #False ; Added 25Nov2022 11.9.7am
    For d = 0 To grProd\nMaxAudioLogicalDev
      If (Len(grProd\aAudioLogicalDevs(d)\sLogicalDev) > 0) And (grProd\aAudioLogicalDevs(d)\nNrOfOutputChans > 0)
        debugMsg(sProcName, "grProd\aAudioLogicalDevs(" + d + ")\sLogicalDev=" + grProd\aAudioLogicalDevs(d)\sLogicalDev + ", \nNrOfOutputChans=" + grProd\aAudioLogicalDevs(d)\nNrOfOutputChans)
        aDevTypeDevCount(nDevType) + 1
        d2 + 1
        If d2 > ArraySize(grMaps\aDev())
          REDIM_ARRAY(grMaps\aDev, d2+20, grDevMapDevDef, "grMaps\aDev()")
        EndIf
        If nMyPrevDevIndex < 0
          grMaps\aMap(nSelectedDevMapPtr)\nFirstDevIndex = d2
        Else
          grMaps\aDev(nMyPrevDevIndex)\nNextDevIndex = d2
        EndIf
        With grMaps\aDev(d2)
          grMaps\aDev(d2) = grDevMapDevDef ; Added 1Apr2020 11.8.2.3ai
          \bExists = #True
          \nDevMapId =  nDevMapId
          debugMsg(sProcName, "grMaps\aDev(" + d2 + ")\nDevMapId=" + \nDevMapId)
          \nPrevDevIndex = nMyPrevDevIndex
          \nNextDevIndex = -1
          debugMsg(sProcName, "grMaps\aDev(" + d2 + ")\nPrevDevIndex=" + \nPrevDevIndex + ", grMaps\aDev(" + d2 + ")\nNextDevIndex=" + \nNextDevIndex)
          \nDevGrp = #SCS_DEVGRP_AUDIO_OUTPUT
          \nDevType = #SCS_DEVTYPE_AUDIO_OUTPUT
          \sLogicalDev = grProd\aAudioLogicalDevs(d)\sLogicalDev
          \nNrOfDevOutputChans = grProd\aAudioLogicalDevs(d)\nNrOfOutputChans
          ; debugMsg(sProcName, "grProd\aAudioLogicalDevs(" + d + ")\sLogicalDev=" + grProd\aAudioLogicalDevs(d)\sLogicalDev + ", \nDevId=" + grProd\aAudioLogicalDevs(d)\nDevId)
          \nDevId = grProd\aAudioLogicalDevs(d)\nDevId
          debugMsg(sProcName, "grMaps\aDev(" + d2 + ")\sLogicalDev=" + \sLogicalDev + ", \nDevId=" + \nDevId + ", \nNrOfDevOutputChans=" + \nNrOfDevOutputChans + ", gnSortedAudioDevs=" + gnSortedAudioDevs + ", sReqdAudPrimaryDev=" + sReqdAudPrimaryDev)
          If sReqdAudPrimaryDev
            For n = 0 To (gnSortedAudioDevs - 1)
              If gaAudioDevSorted(n)\sDesc = sReqdAudPrimaryDev
                nSortedPhysPtr = n
                bFound = #True
                Break
              EndIf
            Next n
          EndIf
          If bFound = #False
            debugMsg(sProcName, "nSortedPhysPtr=" + nSortedPhysPtr + ", nLastOutputUsed=" + nLastOutputUsed + ", grMaps\aDev(" + d2 + ")\nNrOfDevOutputChans=" + \nNrOfDevOutputChans + ", nOutputs=" + nOutputs)
            If (aDevTypeDevCount(#SCS_DEVTYPE_AUDIO_OUTPUT) = 1) Or (((nLastOutputUsed + \nNrOfDevOutputChans) > nOutputs) And (bUsingNoDevice = #False) And (bUsingMonitor = #False))
              ; first time, or insufficient remaining outputs on the current device so go to the next device
              bGetNextDev = #True
              While bGetNextDev
                If nSortedPhysPtr < (gnSortedAudioDevs - 1)
                  nSortedPhysPtr + 1
                  debugMsg(sProcName, "nSortedPhysPtr=" + nSortedPhysPtr)
                  CheckSubInRange(nSortedPhysPtr, ArraySize(gaAudioDevSorted()), "gaAudioDevSorted()")
                  nOutputs = gaAudioDevSorted(nSortedPhysPtr)\nOutputs
                  ; Added 25Nov2022 11.9.7am
                  bDefaultDev = gaAudioDevSorted(nSortedPhysPtr)\bDefaultDev
                  If bDefaultDev And bDefaultDevUsed
                    Continue
                  EndIf
                  ; End added 25Nov2022 11.9.7am
                  nLastOutputUsed = 0    ; reset nLastOutputUsed on change of device
                  If (nOutputs > 0) Or (gaAudioDevSorted(nSortedPhysPtr)\bNoDevice)
                    bGetNextDev = #False
                  EndIf
                Else
                  bGetNextDev = #False
                EndIf
              Wend
            EndIf
          EndIf
          If nSortedPhysPtr >= 0 ; Test added 1Apr2020 following bug reported by Theo Anderson. If Live Input cues exist then SM-S is required, but if the SM-S connection fails then gnSortedAudioDevs=0 and nSortedPhysPtr=-1
            ; debugMsg(sProcName, "(aa) nSortedPhysPtr=" + Str(nSortedPhysPtr))
            CheckSubInRange(nSortedPhysPtr, ArraySize(gaAudioDevSorted()), "gaAudioDevSorted()")
            \nPhysicalDevPtr = gaAudioDevSorted(nSortedPhysPtr)\nPhysDevPtr
            \sPhysicalDev = gaAudioDevSorted(nSortedPhysPtr)\sDesc
            debugMsg(sProcName, "grMaps\aDev(" + d2 + ")\nPhysicalDevPtr=" + \nPhysicalDevPtr + ", \sPhysicalDev=" + \sPhysicalDev)
            \bNoSoundDevice = gaAudioDevSorted(nSortedPhysPtr)\bNoSoundDevice
            \bNoDevice = gaAudioDevSorted(nSortedPhysPtr)\bNoDevice
            ; Added 25Nov2022 11.9.7am
            \bDefaultDev = gaAudioDevSorted(nSortedPhysPtr)\bDefaultDev
            If \bDefaultDev
              bDefaultDevUsed = #True
            EndIf
            ; End added 25Nov2022 11.9.7am
            If \bNoDevice
              bUsingNoDevice = #True
              \nFirst1BasedOutputChan = 0
              \s1BasedOutputRange = ""
              \s0BasedOutputRangeAG = ""
              nLastOutputUsed = 0
            Else
              \nFirst1BasedOutputChan = nLastOutputUsed + 1
              ; debugMsg(sProcName, "grMaps\aDev(" + d2 + ")\s1BasedOutputRange=" + \s1BasedOutputRange)
              \s1BasedOutputRange = build1BasedOutputRangeString(\nFirst1BasedOutputChan, \nNrOfDevOutputChans, \nPhysicalDevPtr)
              debugMsg(sProcName, "grMaps\aDev(" + d2 + ")\s1BasedOutputRange=" + \s1BasedOutputRange)
              nLastOutputUsed + \nNrOfDevOutputChans
            EndIf
            ; debugMsg(sProcName, "grMaps\aDev(" + d2 + ")\sLogicalDev=" + \sLogicalDev + ", \nFirst1BasedOutputChan=" + \nFirst1BasedOutputChan)
            \nDelayTime = 0
            \sDevOutputGainDB = "0.0"
            debugMsg(sProcName, "grMaps\aDev(" + d2 + ")\sLogicalDev=" + \sLogicalDev + ", \sPhysicalDev=" + \sPhysicalDev +
                                ", \nFirst1BasedOutputChan=" + \nFirst1BasedOutputChan + ", \s1BasedOutputRange=" + \s1BasedOutputRange)
            If \nReassignDevMapDevPtr >= 0
              debugMsg(sProcName, "grMaps\aDev(" + d2 + ")\nReassignDevMapDevPtr=" + \nReassignDevMapDevPtr)
            EndIf
          EndIf
        EndWith
        nMyPrevDevIndex = d2
      EndIf
    Next d
    ;}
    
    ; INFO: create initial video audio devices
    ;{
    nDevType = #SCS_DEVTYPE_VIDEO_AUDIO
    For d = 0 To grProd\nMaxVidAudLogicalDev
      If grProd\aVidAudLogicalDevs(d)\sVidAudLogicalDev
        debugMsg(sProcName, "grProd\aVidAudLogicalDevs(" + d + ")\sVidAudLogicalDev=" + grProd\aVidAudLogicalDevs(d)\sVidAudLogicalDev)
        aDevTypeDevCount(nDevType) + 1
        d2 + 1
        If d2 > ArraySize(grMaps\aDev())
          REDIM_ARRAY(grMaps\aDev, d2+20, grDevMapDevDef, "grMaps\aDev()")
        EndIf
        If nMyPrevDevIndex < 0
          grMaps\aMap(nSelectedDevMapPtr)\nFirstDevIndex = d2
        Else
          grMaps\aDev(nMyPrevDevIndex)\nNextDevIndex = d2
        EndIf
        With grMaps\aDev(d2)
          grMaps\aDev(d2) = grDevMapDevDef ; Added 1Apr2020 11.8.2.3ai
          \bExists = #True
          \nDevMapId =  nDevMapId
          \nPrevDevIndex = nMyPrevDevIndex
          \nNextDevIndex = -1
          debugMsg(sProcName, "grMaps\aDev(" + d2 + ")\nPrevDevIndex=" + \nPrevDevIndex + ", grMaps\aDev(" + d2 + ")\nNextDevIndex=" + \nNextDevIndex)
          \nDevGrp = #SCS_DEVGRP_VIDEO_AUDIO
          \nDevType = #SCS_DEVTYPE_VIDEO_AUDIO
          \sLogicalDev = grProd\aVidAudLogicalDevs(d)\sVidAudLogicalDev
          \nNrOfDevOutputChans = grProd\aVidAudLogicalDevs(d)\nNrOfOutputChans
          \nDevId = grProd\aVidAudLogicalDevs(d)\nDevId
          \nPhysicalDevPtr = 0  ; default to the first video audio device
          \sPhysicalDev = gaVideoAudioDev(\nPhysicalDevPtr)\sVidAudName
          \sDevOutputGainDB = "0.0"
        EndWith
        nMyPrevDevIndex = d2
      EndIf
    Next d
    ;}
    
    ; INFO: create initial video capture devices
    ;{
    nDevType = #SCS_DEVTYPE_VIDEO_CAPTURE
    For d = 0 To grProd\nMaxVidCapLogicalDev
      If Len(grProd\aVidCapLogicalDevs(d)\sLogicalDev) > 0
        debugMsg(sProcName, "grProd\aVidCapLogicalDevs(" + d + ")\sLogicalDev=" + grProd\aVidCapLogicalDevs(d)\sLogicalDev)
        aDevTypeDevCount(nDevType) + 1
        d2 + 1
        If d2 > ArraySize(grMaps\aDev())
          REDIM_ARRAY(grMaps\aDev, d2+20, grDevMapDevDef, "grMaps\aDev()")
        EndIf
        If nMyPrevDevIndex < 0
          grMaps\aMap(nSelectedDevMapPtr)\nFirstDevIndex = d2
        Else
          grMaps\aDev(nMyPrevDevIndex)\nNextDevIndex = d2
        EndIf
        With grMaps\aDev(d2)
          grMaps\aDev(d2) = grDevMapDevDef ; Added 1Apr2020 11.8.2.3ai
          \bExists = #True
          \nDevMapId =  nDevMapId
          \nPrevDevIndex = nMyPrevDevIndex
          \nNextDevIndex = -1
          debugMsg(sProcName, "grMaps\aDev(" + d2 + ")\nPrevDevIndex=" + \nPrevDevIndex + ", grMaps\aDev(" + d2 + ")\nNextDevIndex=" + \nNextDevIndex)
          \nDevGrp = #SCS_DEVGRP_VIDEO_CAPTURE
          \nDevType = #SCS_DEVTYPE_VIDEO_CAPTURE
          \sLogicalDev = grProd\aVidCapLogicalDevs(d)\sLogicalDev
          \nDevId = grProd\aVidCapLogicalDevs(d)\nDevId
          \nPhysicalDevPtr = 0  ; default to the first video capture device
          \sPhysicalDev = gaVideoCaptureDev(\nPhysicalDevPtr)\sVidCapName
        EndWith
        nMyPrevDevIndex = d2
      EndIf
    Next d
    ;}
    
    ; INFO: create initial live input devices
    ;{
    nSortedPhysPtr = -1
    nDevType = #SCS_DEVTYPE_LIVE_INPUT
    For d = 0 To grProd\nMaxLiveInputLogicalDev
      If Len(grProd\aLiveInputLogicalDevs(d)\sLogicalDev) > 0
        debugMsg(sProcName, "__ grProd\aLiveInputLogicalDevs(" + d + ")\sLogicalDev=" + grProd\aLiveInputLogicalDevs(d)\sLogicalDev)
        aDevTypeDevCount(nDevType) + 1
        d2 + 1
        If d2 > ArraySize(grMaps\aDev())
          REDIM_ARRAY(grMaps\aDev, d2+20, grDevMapDevDef, "grMaps\aDev()")
        EndIf
        If nMyPrevDevIndex < 0
          grMaps\aMap(nSelectedDevMapPtr)\nFirstDevIndex = d2
        Else
          grMaps\aDev(nMyPrevDevIndex)\nNextDevIndex = d2
        EndIf
        With grMaps\aDev(d2)
          grMaps\aDev(d2) = grDevMapDevDef ; Added 1Apr2020 11.8.2.3ai
          \bExists = #True
          \nDevMapId =  nDevMapId
          \nPrevDevIndex = nMyPrevDevIndex
          \nNextDevIndex = -1
          debugMsg(sProcName, "grMaps\aDev(" + d2 + ")\nPrevDevIndex=" + \nPrevDevIndex + ", grMaps\aDev(" + d2 + ")\nNextDevIndex=" + \nNextDevIndex)
          \nDevGrp = #SCS_DEVGRP_LIVE_INPUT
          \nDevType = #SCS_DEVTYPE_LIVE_INPUT
          \sLogicalDev = grProd\aLiveInputLogicalDevs(d)\sLogicalDev
          \nNrOfInputChans = grProd\aLiveInputLogicalDevs(d)\nNrOfInputChans
          \nDevId = grProd\aLiveInputLogicalDevs(d)\nDevId
          debugMsg(sProcName, "nSortedPhysPtr=" + nSortedPhysPtr + ", nLastInputUsed=" + nLastInputUsed + ", grMaps\aDev(" + d2 + ")\nNrOfInputChans=" + \nNrOfInputChans + ", nInputs=" + nInputs)
          If (aDevTypeDevCount(#SCS_DEVTYPE_LIVE_INPUT) = 1) Or (((nLastInputUsed + 1) > nInputs) And (bUsingNoDevice = #False) And (bUsingMonitor = #False))
            ; first time, or insufficient remaining Inputs on the current device so go to the next device
            bGetNextDev = #True
            While bGetNextDev
              If nSortedPhysPtr < (gnSortedAudioDevs - 1)
                nSortedPhysPtr + 1
                debugMsg(sProcName, "nSortedPhysPtr=" + nSortedPhysPtr)
                nInputs = gaAudioDevSorted(nSortedPhysPtr)\nInputs
                debugMsg(sProcName, "gaAudioDevSorted(" + nSortedPhysPtr + ")\nInputs=" + gaAudioDevSorted(nSortedPhysPtr)\nInputs)
                nLastInputUsed = 0    ; reset nLastInputUsed on change of device
                If (nInputs > 0) Or (gaAudioDevSorted(nSortedPhysPtr)\bNoDevice)
                  bGetNextDev = #False
                EndIf
              Else
                bGetNextDev = #False
              EndIf
            Wend
          EndIf
          If nSortedPhysPtr >= 0 ; Test added 1Apr2020 following bug reported by Theo Anderson. If Live Input cues exist then SM-S is required, but if the SM-S connection fails then gnSortedAudioDevs=0 and nSortedPhysPtr=-1
            \nPhysicalDevPtr = gaAudioDevSorted(nSortedPhysPtr)\nPhysDevPtr
            ; debugMsg(sProcName, "grMaps\aDev(" + d2 + ")\nPhysicalDevPtr=" + \nPhysicalDevPtr)
            \sPhysicalDev = gaAudioDevSorted(nSortedPhysPtr)\sDesc
            \bNoDevice = gaAudioDevSorted(nSortedPhysPtr)\bNoDevice
            If \bNoDevice
              bUsingNoDevice = #True
              \nFirst1BasedInputChan = 0
              \s1BasedInputRange = ""
              \s0BasedInputRangeAG = ""
              nLastInputUsed = 1
            Else
              \nFirst1BasedInputChan = nLastInputUsed + 1
              \s1BasedInputRange = build1BasedInputRangeString(\nFirst1BasedInputChan, \nNrOfInputChans, \nPhysicalDevPtr)
              debugMsg(sProcName, "grMaps\aDev(" + d2 + ")\nFirst1BasedInputChan=" + \nFirst1BasedInputChan + ", \s1BasedInputRange=" + \s1BasedInputRange)
              nLastInputUsed + \nNrOfInputChans
            EndIf
            \nInputDelayTime = 0
            \sInputGainDB = "0.0"
          EndIf
          debugMsg(sProcName, "grMaps\aDev(" + d2 + ")\sLogicalDev=" + \sLogicalDev + ", \nFirst1BasedInputChan=" + \nFirst1BasedInputChan)
        EndWith
        nMyPrevDevIndex = d2
      EndIf
    Next d
    ;}
    
    ; INFO: create initial lighting devices
    ;{
    For d = 0 To grProd\nMaxLightingLogicalDev
      nDevType = grProd\aLightingLogicalDevs(d)\nDevType
      If (grProd\aLightingLogicalDevs(d)\sLogicalDev) And (nDevType <> #SCS_DEVTYPE_NONE)
        aDevTypeDevCount(nDevType) + 1
        d2 + 1
        If d2 > ArraySize(grMaps\aDev())
          REDIM_ARRAY(grMaps\aDev, d2+20, grDevMapDevDef, "grMaps\aDev()")
        EndIf
        If nMyPrevDevIndex < 0
          grMaps\aMap(nSelectedDevMapPtr)\nFirstDevIndex = d2
        Else
          grMaps\aDev(nMyPrevDevIndex)\nNextDevIndex = d2
        EndIf
        With grMaps\aDev(d2)
          grMaps\aDev(d2) = grDevMapDevDef ; Added 1Apr2020 11.8.2.3ai
          \bExists = #True
          \nDevMapId =  nDevMapId
          \nPrevDevIndex = nMyPrevDevIndex
          \nNextDevIndex = -1
          debugMsg(sProcName, "grMaps\aDev(" + d2 + ")\nPrevDevIndex=" + \nPrevDevIndex + ", grMaps\aDev(" + d2 + ")\nNextDevIndex=" + \nNextDevIndex)
          \nDevGrp = #SCS_DEVGRP_LIGHTING
          \nDevType = nDevType
          \sLogicalDev = grProd\aLightingLogicalDevs(d)\sLogicalDev
          \nDevId = grProd\aLightingLogicalDevs(d)\nDevId
          \nPhysicalDevPtr = 0  ; default to the first lighting device
          \sPhysicalDev = gaDMXDevice(\nPhysicalDevPtr)\sName
          \sDMXSerial = gaDMXDevice(\nPhysicalDevPtr)\sSerial
          \bDummy = gaDMXDevice(\nPhysicalDevPtr)\bDummy
          \nMaxDevFixture = grProd\aLightingLogicalDevs(d)\nMaxFixture
          debugMsg(sProcName, "grMaps\aDev(" + d2 + ")\nMaxDevFixture=" + \nMaxDevFixture)
          If \nMaxDevFixture >= 0
            ReDim \aDevFixture(\nMaxDevFixture)
            For n = 0 To \nMaxDevFixture
              \aDevFixture(n)\sDevFixtureCode = grProd\aLightingLogicalDevs(d)\aFixture(n)\sFixtureCode
              \aDevFixture(n)\nDevDMXStartChannel = 0 ; zero means 'not set'
            Next n
          EndIf
          debugMsg(sProcName, "grMaps\aDev(" + d2 + ")\sLogicalDev=" + \sLogicalDev + ", \sPhysicalDev=" + \sPhysicalDev + ", \sDMXSerial=" + \sDMXSerial + ", \bDummy=" + strB(\bDummy))
          If \nReassignDevMapDevPtr >= 0
            debugMsg(sProcName, "grMaps\aDev(" + d2 + ")\nReassignDevMapDevPtr=" + \nReassignDevMapDevPtr)
          EndIf
        EndWith
        nMyPrevDevIndex = d2
      EndIf
    Next d
    ;}
    
    ; INFO: create initial ctrl send devices
    ;{
    For d = 0 To grProd\nMaxCtrlSendLogicalDev
      nDevType = grProd\aCtrlSendLogicalDevs(d)\nDevType
      If (grProd\aCtrlSendLogicalDevs(d)\sLogicalDev) And (nDevType <> #SCS_DEVTYPE_NONE)
        aDevTypeDevCount(nDevType) + 1
        d2 + 1
        If d2 > ArraySize(grMaps\aDev())
          REDIM_ARRAY(grMaps\aDev, d2+20, grDevMapDevDef, "grMaps\aDev()")
        EndIf
        If nMyPrevDevIndex < 0
          grMaps\aMap(nSelectedDevMapPtr)\nFirstDevIndex = d2
        Else
          grMaps\aDev(nMyPrevDevIndex)\nNextDevIndex = d2
        EndIf
        With grMaps\aDev(d2)
          grMaps\aDev(d2) = grDevMapDevDef ; Added 1Apr2020 11.8.2.3ai
          \bExists = #True
          \nDevMapId =  nDevMapId
          \nPrevDevIndex = nMyPrevDevIndex
          \nNextDevIndex = -1
          debugMsg(sProcName, "grMaps\aDev(" + d2 + ")\nPrevDevIndex=" + \nPrevDevIndex + ", grMaps\aDev(" + d2 + ")\nNextDevIndex=" + \nNextDevIndex)
          \nDevGrp = #SCS_DEVGRP_CTRL_SEND
          \nDevType = nDevType
          \sLogicalDev = grProd\aCtrlSendLogicalDevs(d)\sLogicalDev
          \nDevId = grProd\aCtrlSendLogicalDevs(d)\nDevId
          Select nDevType
            Case #SCS_DEVTYPE_CS_MIDI_OUT
              \nPhysicalDevPtr = getFirstMidiDevice(#False)
              If \nPhysicalDevPtr >= 0
                \sPhysicalDev = gaMidiOutDevice(\nPhysicalDevPtr)\sName
                \bDummy = #False
              Else
                \sPhysicalDev = ""
                \bDummy = #True
              EndIf
              
            Case #SCS_DEVTYPE_CS_RS232_OUT
              \nPhysicalDevPtr = 0
              \sPhysicalDev = gaRS232Control(\nPhysicalDevPtr)\sRS232PortAddress
              
            Case #SCS_DEVTYPE_CS_NETWORK_OUT
              Select grProd\aCtrlSendLogicalDevs(d)\nNetworkRole
                Case #SCS_NETWORK_ROLE_SCS_IS_A_SERVER
                  Select grProd\aCtrlSendLogicalDevs(d)\nCtrlNetworkRemoteDev
                    Case #SCS_CS_NETWORK_REM_SCS
                      \nLocalPort = #SCS_DEFAULT_NETWORK_LOCAL_PORT
                  EndSelect
                Case #SCS_NETWORK_ROLE_SCS_IS_A_CLIENT
                  Select grProd\aCtrlSendLogicalDevs(d)\nCtrlNetworkRemoteDev
                    Case #SCS_CS_NETWORK_REM_SCS
                      \nRemotePort = #SCS_DEFAULT_NETWORK_LOCAL_PORT
                    Case #SCS_CS_NETWORK_REM_LF
                      \nRemotePort = 3100
                    Case #SCS_CS_NETWORK_REM_OSC_X32, #SCS_CS_NETWORK_REM_OSC_X32_COMPACT
                      \nRemotePort = 10023
                    Case #SCS_CS_NETWORK_REM_OSC_X32TC
                      \nRemotePort = 32000
                      \sRemoteHost = "127.0.0.1" ; as suggested by James Holt (X32TC writer) 15Jun2021
                  EndSelect
                Case #SCS_DEVTYPE_CS_MIDI_OUT
              EndSelect
              
          EndSelect
          debugMsg(sProcName, "grMaps\aDev(" + d2 + ")\sLogicalDev=" + \sLogicalDev + ", \sPhysicalDev=" + \sPhysicalDev)
          If \nReassignDevMapDevPtr >= 0
            debugMsg(sProcName, "grMaps\aDev(" + d2 + ")\nReassignDevMapDevPtr=" + \nReassignDevMapDevPtr)
          EndIf
        EndWith
        nMyPrevDevIndex = d2
      EndIf
    Next d
    ;}
    
    ; INFO: create initial cue ctrl devices
    ;{
    For d = 0 To grProd\nMaxCueCtrlLogicalDev
      nDevType = grProd\aCueCtrlLogicalDevs(d)\nDevType
      If (grProd\aCueCtrlLogicalDevs(d)\sCueCtrlLogicalDev) And (nDevType <> #SCS_DEVTYPE_NONE)
        aDevTypeDevCount(nDevType) + 1
        d2 + 1
        If d2 > ArraySize(grMaps\aDev())
          REDIM_ARRAY(grMaps\aDev, d2+20, grDevMapDevDef, "grMaps\aDev()")
        EndIf
        If nMyPrevDevIndex < 0
          grMaps\aMap(nSelectedDevMapPtr)\nFirstDevIndex = d2
        Else
          grMaps\aDev(nMyPrevDevIndex)\nNextDevIndex = d2
        EndIf
        With grMaps\aDev(d2)
          grMaps\aDev(d2) = grDevMapDevDef ; Added 1Apr2020 11.8.2.3ai
          \bExists = #True
          \nDevMapId =  nDevMapId
          \nPrevDevIndex = nMyPrevDevIndex
          \nNextDevIndex = -1
          debugMsg(sProcName, "grMaps\aDev(" + d2 + ")\nPrevDevIndex=" + \nPrevDevIndex + ", grMaps\aDev(" + d2 + ")\nNextDevIndex=" + \nNextDevIndex)
          \nDevGrp = #SCS_DEVGRP_CUE_CTRL
          \nDevType = nDevType
          \sLogicalDev = grProd\aCueCtrlLogicalDevs(d)\sCueCtrlLogicalDev
          \nDevId = grProd\aCueCtrlLogicalDevs(d)\nDevId
          Select nDevType
            Case #SCS_DEVTYPE_CC_MIDI_IN
              \nPhysicalDevPtr = getFirstMidiDevice(#True)
              \sPhysicalDev = gaMidiInDevice(\nPhysicalDevPtr)\sName
              
            Case #SCS_DEVTYPE_CC_RS232_IN
              \nPhysicalDevPtr = 0
              \sPhysicalDev = gaRS232Control(\nPhysicalDevPtr)\sRS232PortAddress
              
            Case #SCS_DEVTYPE_CC_NETWORK_IN
              ; \nPhysicalDevPtr = 0 ; Deleted 21Jun2021 11.8.5al
              Select grProd\aCueCtrlLogicalDevs(d)\nNetworkRole
                Case #SCS_NETWORK_ROLE_SCS_IS_A_SERVER
                  Select grProd\aCueCtrlLogicalDevs(d)\nCueNetworkRemoteDev
                    Case #SCS_CC_NETWORK_REM_SCS
                      \nLocalPort = #SCS_DEFAULT_NETWORK_LOCAL_PORT
                    Case #SCS_CC_NETWORK_REM_OSC_X32TC
                      \nLocalPort = 59000
                  EndSelect
                Case #SCS_NETWORK_ROLE_SCS_IS_A_CLIENT
                  Select grProd\aCueCtrlLogicalDevs(d)\nCueNetworkRemoteDev
                    Case #SCS_CC_NETWORK_REM_SCS
                      \nRemotePort = #SCS_DEFAULT_NETWORK_LOCAL_PORT
                    Case #SCS_CC_NETWORK_REM_LF
                      \nRemotePort = 3100
                    Case #SCS_CC_NETWORK_REM_OSC_X32, #SCS_CC_NETWORK_REM_OSC_X32_COMPACT
                      \nRemotePort = 10023
                  EndSelect
              EndSelect
              
            Case #SCS_DEVTYPE_CC_DMX_IN ; Added 31Oct2022 11.9.6
              If grDMX\nNumDMXDevs >= 0
                \nPhysicalDevPtr = 0 ; first item in array gaDMXDevice()
                ; the following based on code in WEP_cboDMXPhysDev_Click()
                d3 = \nPhysicalDevPtr
                \sPhysicalDev = gaDMXDevice(d3)\sName
                \sPhysicalDev = gaDMXDevice(d3)\sName
                \sDMXSerial = gaDMXDevice(d3)\sSerial
                \nDMXSerial = gaDMXDevice(d3)\nSerial
                \nDMXPorts = gaDMXDevice(d3)\nDMXPorts
                \nDMXPort = 1
                \bDummy = gaDMXDevice(d3)\bDummy
              EndIf
              
          EndSelect
          debugMsg(sProcName, "grMaps\aDev(" + d2 + ")\sLogicalDev=" + \sLogicalDev + ", \sPhysicalDev=" + \sPhysicalDev)
          If \nReassignDevMapDevPtr >= 0
            debugMsg(sProcName, "grMaps\aDev(" + d2 + ")\nReassignDevMapDevPtr=" + \nReassignDevMapDevPtr)
          EndIf
        EndWith
        nMyPrevDevIndex = d2
      EndIf
    Next d
    ;}
    
    grMaps\nMaxDevIndex = d2
    debugMsg(sProcName, "grMaps\nMaxDevIndex=" + grMaps\nMaxDevIndex + ", ArraySize(grMaps\aDev())=" + ArraySize(grMaps\aDev()))
    
  EndIf
  
  debugMsg(sProcName, "calling resetSessionOptions()")
  resetSessionOptions()
  
  debugMsg(sProcName, #SCS_END + ", returning nSelectedDevMapPtr=" + nSelectedDevMapPtr)
  ProcedureReturn nSelectedDevMapPtr
EndProcedure

Procedure createMissingLightingDevsForDevMap(nDevMapPtr)
  PROCNAMEC()
  Protected nDevMapId
  Protected d, d2, d3, n
  Protected nDevType, sLogicalDev.s
  Protected bDevFound
  Protected nMyPrevDevIndex
  
  debugMsg(sProcName, #SCS_START + ", nDevMapPtr=" + nDevMapPtr)
  
  If nDevMapPtr < 0
    ProcedureReturn
  EndIf
  
  nDevMapId = grMaps\aMap(nDevMapPtr)\nDevMapId
  d2 = grMaps\nMaxDevIndex
  
  ; lighting devices
  For d = 0 To grProd\nMaxLightingLogicalDev
    nDevType = grProd\aLightingLogicalDevs(d)\nDevType
    sLogicalDev = grProd\aLightingLogicalDevs(d)\sLogicalDev
    If sLogicalDev And nDevType <> #SCS_DEVTYPE_NONE
      debugMsg(sProcName, "grProd\aLightingLogicalDevs(" + d + ")\nDevType=" + decodeDevType(grProd\aLightingLogicalDevs(d)\nDevType) + ", sLogicalDev=" + sLogicalDev)
      bDevFound = #False
      nMyPrevDevIndex = -1
      d3 = grMaps\aMap(nDevMapPtr)\nFirstDevIndex
      While d3 >= 0
        With grMaps\aDev(d3)
          If (\nDevMapId = nDevMapId) And (\nDevType = nDevType) And (\sLogicalDev = sLogicalDev)
            bDevFound = #True
            debugMsg(sProcName, "found at grMaps\aDev(" + d3 + ")")
            ; Break   ; do NOT break as we are also calculating a value for nMyPrevDevIndex
          EndIf
        EndWith
        nMyPrevDevIndex = d3
        d3 = grMaps\aDev(d3)\nNextDevIndex
      Wend
      If bDevFound = #False
        debugMsg(sProcName, "creating device " + sLogicalDev)
        d2 + 1
        If d2 > ArraySize(grMaps\aDev())
          REDIM_ARRAY(grMaps\aDev, d2+20, grDevMapDevDef, "grMaps\aDev()")
        EndIf
        If nMyPrevDevIndex < 0
          grMaps\aMap(nDevMapPtr)\nFirstDevIndex = d2
        Else
          grMaps\aDev(nMyPrevDevIndex)\nNextDevIndex = d2
        EndIf
        With grMaps\aDev(d2)
          \bExists = #True
          \nDevMapId =  nDevMapId
          \nPrevDevIndex = nMyPrevDevIndex
          \nNextDevIndex = -1
          ; debugMsg(sProcName, "grMaps\aDev(" + d2 + ")\nPrevDevIndex=" + grMaps\aDev(d2)\nPrevDevIndex + ", grMaps\aDev(" + d2 + ")\nNextDevIndex=" + grMaps\aDev(d2)\nNextDevIndex)
          \nDevGrp = #SCS_DEVGRP_LIGHTING
          \nDevType = nDevType
          \sLogicalDev = grProd\aLightingLogicalDevs(d)\sLogicalDev
          \nDevId = grProd\aLightingLogicalDevs(d)\nDevId
          \nMaxDevFixture = grProd\aLightingLogicalDevs(d)\nMaxFixture
          debugMsg(sProcName, "grMaps\aDev(" + d2 + ")\nMaxDevFixture=" + \nMaxDevFixture)
          If \nMaxDevFixture >= 0
            ReDim \aDevFixture(\nMaxDevFixture)
            For n = 0 To \nMaxDevFixture
              \aDevFixture(n)\sDevFixtureCode = grProd\aLightingLogicalDevs(d)\aFixture(n)\sFixtureCode
              \aDevFixture(n)\nDevDMXStartChannel = 0 ; zero means 'not set'
            Next n
          EndIf
          debugMsg(sProcName, "grMaps\aDev(" + d2 + ")\sLogicalDev=" + \sLogicalDev + ", \sPhysicalDev=" + \sPhysicalDev)
          If \nReassignDevMapDevPtr >= 0
            debugMsg(sProcName, "grMaps\aDev(" + d2 + ")\nReassignDevMapDevPtr=" + \nReassignDevMapDevPtr)
          EndIf
        EndWith
      EndIf
    EndIf
  Next d
  
  grMaps\nMaxDevIndex = d2
  debugMsg(sProcName, #SCS_END + ", grMaps\nMaxDevIndex=" + grMaps\nMaxDevIndex + ", ArraySize(grMaps\aDev())=" + ArraySize(grMaps\aDev()))
  
EndProcedure

Procedure createMissingCtrlSendDevsForDevMap(nDevMapPtr)
  PROCNAMEC()
  Protected nDevMapId
  Protected d, d2, d3
  Protected nDevType, sLogicalDev.s
  Protected bDevFound
  Protected nMyPrevDevIndex
  
  debugMsg(sProcName, #SCS_START + ", nDevMapPtr=" + nDevMapPtr)
  
  If nDevMapPtr < 0
    ProcedureReturn
  EndIf
  
  nDevMapId = grMaps\aMap(nDevMapPtr)\nDevMapId
  d2 = grMaps\nMaxDevIndex
  
  ; ctrl send devices
  For d = 0 To grProd\nMaxCtrlSendLogicalDev
    nDevType = grProd\aCtrlSendLogicalDevs(d)\nDevType
    sLogicalDev = grProd\aCtrlSendLogicalDevs(d)\sLogicalDev
    If sLogicalDev And nDevType <> #SCS_DEVTYPE_NONE
      debugMsg(sProcName, "grProd\aCtrlSendLogicalDevs(" + d + ")\nDevType=" + decodeDevType(grProd\aCtrlSendLogicalDevs(d)\nDevType) + ", sLogicalDev=" + sLogicalDev)
      bDevFound = #False
      nMyPrevDevIndex = -1
      d3 = grMaps\aMap(nDevMapPtr)\nFirstDevIndex
      While d3 >= 0
        With grMaps\aDev(d3)
          If (\nDevMapId = nDevMapId) And (\nDevType = nDevType) And (\sLogicalDev = sLogicalDev)
            bDevFound = #True
            debugMsg(sProcName, "found at grMaps\aDev(" + d3 + ")")
            ; Break   ; do NOT break as we are also calculating a value for nMyPrevDevIndex
          EndIf
        EndWith
        nMyPrevDevIndex = d3
        d3 = grMaps\aDev(d3)\nNextDevIndex
      Wend
      If bDevFound = #False
        debugMsg(sProcName, "creating device " + sLogicalDev)
        d2 + 1
        If d2 > ArraySize(grMaps\aDev())
          REDIM_ARRAY(grMaps\aDev, d2+20, grDevMapDevDef, "grMaps\aDev()")
        EndIf
        If nMyPrevDevIndex < 0
          grMaps\aMap(nDevMapPtr)\nFirstDevIndex = d2
        Else
          grMaps\aDev(nMyPrevDevIndex)\nNextDevIndex = d2
        EndIf
        With grMaps\aDev(d2)
          \bExists = #True
          \nDevMapId =  nDevMapId
          \nPrevDevIndex = nMyPrevDevIndex
          \nNextDevIndex = -1
          ; debugMsg(sProcName, "grMaps\aDev(" + d2 + ")\nPrevDevIndex=" + grMaps\aDev(d2)\nPrevDevIndex + ", grMaps\aDev(" + d2 + ")\nNextDevIndex=" + grMaps\aDev(d2)\nNextDevIndex)
          \nDevGrp = #SCS_DEVGRP_CTRL_SEND
          \nDevType = nDevType
          \sLogicalDev = grProd\aCtrlSendLogicalDevs(d)\sLogicalDev
          \nDevId = grProd\aCtrlSendLogicalDevs(d)\nDevId
          Select nDevType
            Case #SCS_DEVTYPE_CS_MIDI_OUT
              \nPhysicalDevPtr = getFirstMidiDevice(#False)
              ; the following modified 30Oct2015 11.4.1.2f to cater for getFirstMidiDevice() returning -1, and for setting \bDummy
              If \nPhysicalDevPtr >= 0
                \sPhysicalDev = gaMidiOutDevice(\nPhysicalDevPtr)\sName
                \bDummy = #False
              Else
                \sPhysicalDev = ""
                \bDummy = #True
              EndIf
              
            Case #SCS_DEVTYPE_CS_RS232_OUT
              \nPhysicalDevPtr = 0
              \sPhysicalDev = gaRS232Control(\nPhysicalDevPtr)\sRS232PortAddress
              \bDummy = gaRS232Control(\nPhysicalDevPtr)\bDummy
              
            Case #SCS_DEVTYPE_CS_NETWORK_OUT
              \nPhysicalDevPtr = -1 ; modified 30Oct2015 11.4.1.2f
              \sPhysicalDev = ""
              \bDummy = #True       ; added 30Oct2015 11.4.1.2f
              
          EndSelect
          debugMsg(sProcName, "grMaps\aDev(" + d2 + ")\sLogicalDev=" + \sLogicalDev + ", \sPhysicalDev=" + \sPhysicalDev)
          If \nReassignDevMapDevPtr >= 0
            debugMsg(sProcName, "grMaps\aDev(" + d2 + ")\nReassignDevMapDevPtr=" + \nReassignDevMapDevPtr)
          EndIf
        EndWith
      EndIf
    EndIf
  Next d
  
  grMaps\nMaxDevIndex = d2
  debugMsg(sProcName, #SCS_END + ", grMaps\nMaxDevIndex=" + grMaps\nMaxDevIndex + ", ArraySize(grMaps\aDev())=" + ArraySize(grMaps\aDev()))
  
EndProcedure

Procedure createMissingCueCtrlDevsForDevMap(nDevMapPtr)
  PROCNAMEC()
  Protected nDevMapId
  Protected d, d2, d3
  Protected nDevType, sLogicalDev.s
  Protected bDevFound
  Protected nMyPrevDevIndex
  
  debugMsg(sProcName, #SCS_START + ", nDevMapPtr=" + nDevMapPtr)
  
  If nDevMapPtr < 0
    ProcedureReturn
  EndIf
  
  nDevMapId = grMaps\aMap(nDevMapPtr)\nDevMapId
  d2 = grMaps\nMaxDevIndex
  
  ; cue control devices
  For d = 0 To grProd\nMaxCueCtrlLogicalDev
    nDevType = grProd\aCueCtrlLogicalDevs(d)\nDevType
    sLogicalDev = grProd\aCueCtrlLogicalDevs(d)\sCueCtrlLogicalDev
    If (sLogicalDev) And (nDevType <> #SCS_DEVTYPE_NONE)
      debugMsg(sProcName, "grProd\aCueCtrlLogicalDevs(" + d + ")\nDevType=" + decodeDevType(grProd\aCueCtrlLogicalDevs(d)\nDevType) + ", sLogicalDev=" + sLogicalDev)
      bDevFound = #False
      nMyPrevDevIndex = -1
      d3 = grMaps\aMap(nDevMapPtr)\nFirstDevIndex
      While d3 >= 0
        With grMaps\aDev(d3)
          If (\nDevMapId = nDevMapId) And (\nDevType = nDevType) And (\sLogicalDev = sLogicalDev)
            bDevFound = #True
            debugMsg(sProcName, "found at grMaps\aDev(" + d3 + ")")
            ; Break   ; do NOT break as we are also calculating a value for nMyPrevDevIndex
          EndIf
        EndWith
        nMyPrevDevIndex = d3
        d3 = grMaps\aDev(d3)\nNextDevIndex
      Wend
      If bDevFound = #False
        debugMsg(sProcName, "creating device " + sLogicalDev)
        d2 + 1
        If d2 > ArraySize(grMaps\aDev())
          REDIM_ARRAY(grMaps\aDev, d2+20, grDevMapDevDef, "grMaps\aDev()")
        EndIf
        If nMyPrevDevIndex < 0
          grMaps\aMap(nDevMapPtr)\nFirstDevIndex = d2
        Else
          grMaps\aDev(nMyPrevDevIndex)\nNextDevIndex = d2
        EndIf
        With grMaps\aDev(d2)
          \bExists = #True
          \nDevMapId =  nDevMapId
          \nPrevDevIndex = nMyPrevDevIndex
          \nNextDevIndex = -1
          ; debugMsg(sProcName, "grMaps\aDev(" + d2 + ")\nPrevDevIndex=" + grMaps\aDev(d2)\nPrevDevIndex + ", grMaps\aDev(" + d2 + ")\nNextDevIndex=" + grMaps\aDev(d2)\nNextDevIndex)
          \nDevGrp = #SCS_DEVGRP_CUE_CTRL
          \nDevType = nDevType
          \sLogicalDev = grProd\aCueCtrlLogicalDevs(d)\sCueCtrlLogicalDev
          \nDevId = grProd\aCueCtrlLogicalDevs(d)\nDevId
          Select nDevType
            Case #SCS_DEVTYPE_CC_MIDI_IN
              \nPhysicalDevPtr = getFirstMidiDevice(#True)
              If \nPhysicalDevPtr >= 0
                \sPhysicalDev = gaMidiInDevice(\nPhysicalDevPtr)\sName
                \bDummy = #False
              Else
                \sPhysicalDev = ""
                \bDummy = #True
              EndIf
              
            Case #SCS_DEVTYPE_CC_RS232_IN
              \nPhysicalDevPtr = 0
              \sPhysicalDev = gaRS232Control(\nPhysicalDevPtr)\sRS232PortAddress
              \bDummy = gaRS232Control(\nPhysicalDevPtr)\bDummy
              
            Case #SCS_DEVTYPE_CC_NETWORK_IN
              \nPhysicalDevPtr = -1
              \sPhysicalDev = ""
              \bDummy = #True
              
          EndSelect
          debugMsg(sProcName, "grMaps\aDev(" + d2 + ")\sLogicalDev=" + \sLogicalDev + ", \sPhysicalDev=" + \sPhysicalDev)
          If \nReassignDevMapDevPtr >= 0
            debugMsg(sProcName, "grMaps\aDev(" + d2 + ")\nReassignDevMapDevPtr=" + \nReassignDevMapDevPtr)
          EndIf
        EndWith
      EndIf
    EndIf
  Next d
  
  grMaps\nMaxDevIndex = d2
  debugMsg(sProcName, #SCS_END + ", grMaps\nMaxDevIndex=" + grMaps\nMaxDevIndex + ", ArraySize(grMaps\aDev())=" + ArraySize(grMaps\aDev()))
  
EndProcedure

Procedure.s build1BasedOutputRangeString(nFirst1BasedOutputChan, nNrOfOutputChans, nPhysicalDevPtr)
  PROCNAMEC()
  Protected s1BasedOutputRange.s
  
  If nPhysicalDevPtr < 0
    ProcedureReturn ""
  EndIf
  
  If (gaAudioDev(nPhysicalDevPtr)\bASIO = #False) And (gaAudioDev(nPhysicalDevPtr)\nOutputs = 2)
    If nNrOfOutputChans = 1
      Select nFirst1BasedOutputChan
        Case 1
          s1BasedOutputRange = "L"
        Case 2
          s1BasedOutputRange = "R"
      EndSelect
    ElseIf nNrOfOutputChans = 2
      If nFirst1BasedOutputChan = 1
        s1BasedOutputRange = "L-R"
      EndIf
    EndIf
  EndIf
  
  If Len(s1BasedOutputRange) = 0
    If nNrOfOutputChans = 1
      s1BasedOutputRange = Str(nFirst1BasedOutputChan)
    Else
      s1BasedOutputRange = Str(nFirst1BasedOutputChan) + "-" + Str(nFirst1BasedOutputChan + nNrOfOutputChans - 1)
    EndIf
  EndIf
  
  ProcedureReturn s1BasedOutputRange
EndProcedure

Procedure.s make0BasedInputRangeString(s1BasedInputRange.s)
  PROCNAMEC()
  Protected s0BasedInputRange.s
  Protected nFirst1BasedInputChan
  Protected nNrOfInputChans
  
  If Len(Trim(s1BasedInputRange)) > 0
    nFirst1BasedInputChan = getFirst1BasedChanFromRange(s1BasedInputRange)
    nNrOfInputChans = getNumChansFromRange(s1BasedInputRange)
    If nNrOfInputChans = 1
      s0BasedInputRange = Str(nFirst1BasedInputChan - 1)
    ElseIf nNrOfInputChans > 1
      s0BasedInputRange = Str(nFirst1BasedInputChan - 1) + "-" + Str(nFirst1BasedInputChan + nNrOfInputChans - 2)
    EndIf
  EndIf
  
  ProcedureReturn s0BasedInputRange
EndProcedure

Procedure.s build1BasedInputRangeString(nFirst1BasedInputChan, nNrOfInputChans, nPhysicalDevPtr)
  PROCNAMEC()
  Protected s1BasedInputRange.s
  
  If nPhysicalDevPtr < 0
    ProcedureReturn ""
  EndIf
  
  If gaAudioDev(nPhysicalDevPtr)\bASIO = #False And gaAudioDev(nPhysicalDevPtr)\nInputs = 2
    If nNrOfInputChans = 1
      Select nFirst1BasedInputChan
        Case 1
          s1BasedInputRange = "L"
        Case 2
          s1BasedInputRange = "R"
      EndSelect
    ElseIf nNrOfInputChans = 2
      If nFirst1BasedInputChan = 1
        s1BasedInputRange = "L-R"
      EndIf
    EndIf
  EndIf
  
  If Len(s1BasedInputRange) = 0
    If nNrOfInputChans = 1
      s1BasedInputRange = Str(nFirst1BasedInputChan)
    Else
      s1BasedInputRange = Str(nFirst1BasedInputChan) + "-" + Str(nFirst1BasedInputChan + nNrOfInputChans - 1)
    EndIf
  EndIf
  
  ProcedureReturn s1BasedInputRange
EndProcedure

Procedure.s getDevMapName(nDevMapPtr)
  ; PROCNAMEC()
  
  If (nDevMapPtr >= 0) And (nDevMapPtr <= grMaps\nMaxMapIndex)
    ProcedureReturn grMaps\aMap(nDevMapPtr)\sDevMapName
  Else
    ProcedureReturn ""
  EndIf
EndProcedure

Procedure.s getDevChgsDevMapName(nDevMapPtr)
  ; PROCNAMEC()
  
  If (nDevMapPtr >= 0) And (nDevMapPtr <= grMapsForDevChgs\nMaxMapIndex)
    ProcedureReturn grMapsForDevChgs\aMap(nDevMapPtr)\sDevMapName
  Else
    ProcedureReturn ""
  EndIf
  
EndProcedure

Procedure.s getDevMapForImportName(nDevMapPtr)
  ; PROCNAMEC()
  
  If (nDevMapPtr >= 0) And (nDevMapPtr <= grMapsForImport\nMaxMapIndex)
    ProcedureReturn grMapsForImport\aMap(nDevMapPtr)\sDevMapName
  Else
    ProcedureReturn ""
  EndIf
  
EndProcedure

Procedure getDevMapPtr(*rMaps.tyMaps, sDevMapName.s)
  ; PROCNAMEC()
  Protected n, nDevMapPtr
  
  nDevMapPtr = -1
  If sDevMapName
    For n = 0 To *rMaps\nMaxMapIndex
      If *rMaps\aMap(n)\sDevMapName = sDevMapName
        nDevMapPtr = n
        Break
      EndIf
    Next n
  EndIf
  
  ProcedureReturn nDevMapPtr
  
EndProcedure

Procedure getDevMapPtrForSelectedDevMap(*rMaps.tyMaps)
  ProcedureReturn getDevMapPtr(*rMaps, *rMaps\sSelectedDevMapName)
EndProcedure

Procedure getDevMapPtrForDevMapId(*rMaps.tyMaps, nDevMapId)
  ; PROCNAMEC()
  Protected n, nDevMapPtr
  
  nDevMapPtr = -1
  For n = 0 To *rMaps\nMaxMapIndex
    If *rMaps\aMap(n)\nDevMapId = nDevMapId
      nDevMapPtr = n
      Break
    EndIf
  Next n
  
  ProcedureReturn nDevMapPtr
  
EndProcedure

Procedure getDevMapDevPtrForLogicalDev(*rMaps.tyMaps, nDevGrp, sLogicalDev.s, nUseDevMapPtr=-1)
  ; PROCNAMEC()
  Protected d, nDevMapDevPtr, nDevMapPtr
  
  ; debugMsg(sProcName, #SCS_START + ", nDevGrp=" + decodeDevGrp(nDevGrp) + ", sLogicalDev=" + sLogicalDev + ", nUseDevMapPtr=" + nUseDevMapPtr + ", *rMaps=" + *rMaps + ", @grMaps=" + @grMaps + ", @grMapsForDevChgs=" + @grMapsForDevChgs)
  
  nDevMapDevPtr = -1
  If sLogicalDev
    If nUseDevMapPtr >= 0
      nDevMapPtr = nUseDevMapPtr
    ElseIf *rMaps = @grMapsForDevChgs ; Test added 26Aug2023 11.10.0by because calls that omitted nUseDevMapPtr were always using the grProd selected device map
      nDevMapPtr = grProdForDevChgs\nSelectedDevMapPtr
    ElseIf *rMaps = @grMapsForChecker ; Test added 26Aug2023 11.10.0by because calls that omitted nUseDevMapPtr were always using the grProd selected device map
      nDevMapPtr = grProdForChecker\nSelectedDevMapPtr
    ElseIf *rMaps = @grMapsForImport ; Test added 11Nov2023 11.10.0cu following test of clearing the 'Import Devices' screen
      nDevMapPtr = WID_getFirstSelectedDevMapPtr()
      ; Added 12Apr2024 11.10.2by to enable a lighting device's fixtures to be populated from the device's fixtures in grProdForDevChgs
      If nDevMapPtr < 0
        nDevMapPtr = grProdForDevChgs\nSelectedDevMapPtr
      EndIf
      ; End added 12Apr2024 11.10.2by
    Else
      nDevMapPtr = grProd\nSelectedDevMapPtr
    EndIf
    If nDevMapPtr >= 0
      d = *rMaps\aMap(nDevMapPtr)\nFirstDevIndex
      While d >= 0
        With *rMaps\aDev(d)
          ; debugMsg(sProcName, "*rMaps\aMap(" + d + ")\nDevGrp=" + decodeDevGrp(\nDevGrp) + ", \sLogicalDev=" + \sLogicalDev + ", \bExists=" + strB(\bExists))
          If (\nDevGrp = nDevGrp) And (\bExists)
            If \sLogicalDev = sLogicalDev
              nDevMapDevPtr = d
              Break
            EndIf
          EndIf
          d = \nNextDevIndex
        EndWith
      Wend
    EndIf
    ; debugMsg(sProcName, "nDevGrp=" + decodeDevGrp(nDevGrp) + ", sLogicalDev=" + sLogicalDev + ", returning " + nDevMapDevPtr)
  EndIf
  
  ProcedureReturn nDevMapDevPtr
  
EndProcedure

Procedure getDevChgsDevPtrForDevId(nDevGrp, nDevId, nUseDevMapPtr=-1)
  ; PROCNAMEC()
  Protected d, nDevMapDevPtr, nDevMapPtr
  
  ; debugMsg(sProcName, #SCS_START + ", nDevGrp=" + decodeDevGrp(nDevGrp) + ", nDevId=" + nDevId + ", nUseDevMapPtr=" + nUseDevMapPtr)
  
  nDevMapDevPtr = -1
  If nUseDevMapPtr >= 0
    nDevMapPtr = nUseDevMapPtr
  Else
    nDevMapPtr = grProdForDevChgs\nSelectedDevMapPtr
  EndIf
  ; debugMsg(sProcName, "grProdForDevChgs\nSelectedDevMapPtr=" + getDevChgsDevMapName(grProdForDevChgs\nSelectedDevMapPtr))
  If nDevMapPtr >= 0
    d = grMapsForDevChgs\aMap(nDevMapPtr)\nFirstDevIndex
    ; debugMsg(sProcName, "grMapsForDevChgs\aMap(" + nDevMapPtr + ")\nFirstDevIndex=" + grMapsForDevChgs\aMap(nDevMapPtr)\nFirstDevIndex)
    While d >= 0
      With grMapsForDevChgs\aDev(d)
        ; debugMsg(sProcName, "grMapsForDevChgs\aDev(" + d + ")\nDevGrp=" + decodeDevGrp(\nDevGrp) + ", \nDevId=" + \nDevId + ", \bExists=" + strB(\bExists) + ", \sLogicalDev=" + \sLogicalDev)
        If (\nDevGrp = nDevGrp) And (\bExists)
          If \nDevId = nDevId
            nDevMapDevPtr = d
            Break
          EndIf
        EndIf
        d = \nNextDevIndex
      EndWith
    Wend
  EndIf
  
  ; debugMsg(sProcName, #SCS_END + ", nDevGrp=" + decodeDevGrp(nDevGrp) + ", nDevId=" + nDevId + ", returning " + nDevMapDevPtr)
  ProcedureReturn nDevMapDevPtr
  
EndProcedure

Procedure getDevMapDevPtrDevId(nDevGrp, nDevId, nUseDevMapPtr=-1)
  ; PROCNAMEC()
  Protected d, nDevMapDevPtr, nDevMapPtr
  
  ; debugMsg(sProcName, #SCS_START + ", nDevGrp=" + decodeDevGrp(nDevGrp) + ", nDevId=" + nDevId)
  
  nDevMapDevPtr = -1
  If nUseDevMapPtr >= 0
    nDevMapPtr = nUseDevMapPtr
  Else
    nDevMapPtr = grProd\nSelectedDevMapPtr
  EndIf
  ; debugMsg(sProcName, "grProd\nSelectedDevMapPtr=" + getDevMapName(grProd\nSelectedDevMapPtr))
  If nDevMapPtr >= 0
    d = grMaps\aMap(nDevMapPtr)\nFirstDevIndex
    While d >= 0
      With grMaps\aDev(d)
        ; debugMsg(sProcName, "grMaps\aDev(" + d + ")\nDevGrp=" + decodeDevGrp(\nDevGrp) + ", \nDevId=" + \nDevId + ", \bExists=" + strB(\bExists) + ", \sLogicalDev=" + \sLogicalDev)
        If (\nDevGrp = nDevGrp) And (\bExists)
          If \nDevId = nDevId
            nDevMapDevPtr = d
            Break
          EndIf
        EndIf
        d = \nNextDevIndex
      EndWith
    Wend
  EndIf
  
  ; debugMsg(sProcName, #SCS_END + ", nDevGrp=" + decodeDevGrp(nDevGrp) + ", nDevId=" + nDevId + ", returning " + nDevMapDevPtr)
  ProcedureReturn nDevMapDevPtr
  
EndProcedure

Procedure getDevChgsDevPtrForDevNo(nDevGrp, nDevNo)
  ; PROCNAMEC()
  Protected nDevId, nDevMapDevPtr
  
  ; debugMsg(sProcName, #SCS_START + ", nDevGrp=" + decodeDevGrp(nDevGrp) + ", nDevNo=" + nDevNo)
  
  With grProdForDevChgs
    Select nDevGrp
      Case #SCS_DEVGRP_AUDIO_OUTPUT
        nDevId = \aAudioLogicalDevs(nDevNo)\nDevId
      Case #SCS_DEVGRP_VIDEO_AUDIO
        nDevId = \aVidAudLogicalDevs(nDevNo)\nDevId
      Case #SCS_DEVGRP_VIDEO_CAPTURE
        nDevId = \aVidCapLogicalDevs(nDevNo)\nDevId
      Case #SCS_DEVGRP_LIVE_INPUT
        nDevId = \aLiveInputLogicalDevs(nDevNo)\nDevId
      Case #SCS_DEVGRP_LIGHTING
        nDevId = \aLightingLogicalDevs(nDevNo)\nDevId
      Case #SCS_DEVGRP_CTRL_SEND
        nDevId = \aCtrlSendLogicalDevs(nDevNo)\nDevId
      Case #SCS_DEVGRP_CUE_CTRL
        nDevId = \aCueCtrlLogicalDevs(nDevNo)\nDevId
    EndSelect
  EndWith
  
  nDevMapDevPtr = getDevChgsDevPtrForDevId(nDevGrp, nDevId)
  
  ; debugMsg(sProcName, #SCS_END + ", nDevGrp=" + decodeDevGrp(nDevGrp) + ", nDevNo=" + nDevNo + ", nDevId=" + nDevId + ", returning " + nDevMapDevPtr)
  ProcedureReturn nDevMapDevPtr
  
EndProcedure

Procedure getMaxDevForDevGrp(*rProd.tyProd, nDevGrp)
  PROCNAMEC()
  Protected nMaxDev
  
  nMaxDev = -1
  With *rProd
    Select nDevGrp
      Case #SCS_DEVGRP_AUDIO_OUTPUT
        nMaxDev = \nMaxAudioLogicalDev
      Case #SCS_DEVGRP_VIDEO_AUDIO
        nMaxDev = \nMaxVidAudLogicalDev
      Case #SCS_DEVGRP_VIDEO_CAPTURE
        nMaxDev = \nMaxVidCapLogicalDev
      Case #SCS_DEVGRP_LIGHTING
        nMaxDev = \nMaxLightingLogicalDev
      Case #SCS_DEVGRP_CTRL_SEND
        nMaxDev = \nMaxCtrlSendLogicalDev
      Case #SCS_DEVGRP_CUE_CTRL
        nMaxDev = \nMaxCueCtrlLogicalDev
      Case #SCS_DEVGRP_LIVE_INPUT
        nMaxDev = \nMaxLiveInputLogicalDev
    EndSelect
  EndWith
  ProcedureReturn nMaxDev
EndProcedure

Procedure getDevMapDevPtrForDevNo(nDevGrp, nDevNo)
  ; PROCNAMEC()
  Protected nDevId, nDevMapDevPtr
  
  ; debugMsg(sProcName, #SCS_START + ", nDevGrp=" + decodeDevGrp(nDevGrp) + ", nDevNo=" + nDevNo)
  
  With grProd
    Select nDevGrp
      Case #SCS_DEVGRP_AUDIO_OUTPUT
        nDevId = \aAudioLogicalDevs(nDevNo)\nDevId
      Case #SCS_DEVGRP_VIDEO_AUDIO
        nDevId = \aVidAudLogicalDevs(nDevNo)\nDevId
      Case #SCS_DEVGRP_VIDEO_CAPTURE
        nDevId = \aVidCapLogicalDevs(nDevNo)\nDevId
      Case #SCS_DEVGRP_LIVE_INPUT
        nDevId = \aLiveInputLogicalDevs(nDevNo)\nDevId
      Case #SCS_DEVGRP_LIGHTING
        nDevId = \aLightingLogicalDevs(nDevNo)\nDevId
      Case #SCS_DEVGRP_CTRL_SEND
        nDevId = \aCtrlSendLogicalDevs(nDevNo)\nDevId
      Case #SCS_DEVGRP_CUE_CTRL
        nDevId = \aCueCtrlLogicalDevs(nDevNo)\nDevId
    EndSelect
  EndWith
  
  nDevMapDevPtr = getDevMapDevPtrDevId(nDevGrp, nDevId)
  
  ; debugMsg(sProcName, #SCS_END + ", nDevGrp=" + decodeDevGrp(nDevGrp) + ", nDevNo=" + nDevNo + ", returning " + nDevMapDevPtr)
  ProcedureReturn nDevMapDevPtr
  
EndProcedure

Procedure updateDevChgsDev(nDevGrp, nDevType, nDevNo, sLogicalDev.s)
  PROCNAMEC()
  Protected nDevMapPtr, d2
  Protected sLogicalDevOld.s, sLogicalDevNew.s
  Protected bFound, nLastDevIndex
  Protected nDevMapDevPtr
  Protected nDevId
  
  debugMsg(sProcName, #SCS_START + ", nDevGrp=" + decodeDevGrp(nDevGrp) + ", nDevType=" + decodeDevType(nDevType) + ", nDevNo=" + nDevNo)
  
  sLogicalDevOld = sLogicalDev ; original sLogicalDev if just changed
  Select nDevGrp
    Case #SCS_DEVGRP_AUDIO_OUTPUT
      sLogicalDevNew = grProdForDevChgs\aAudioLogicalDevs(nDevNo)\sLogicalDev
      nDevId = grProdForDevChgs\aAudioLogicalDevs(nDevNo)\nDevId
    Case #SCS_DEVGRP_VIDEO_AUDIO
      sLogicalDevNew = grProdForDevChgs\aVidAudLogicalDevs(nDevNo)\sVidAudLogicalDev
      nDevId = grProdForDevChgs\aVidAudLogicalDevs(nDevNo)\nDevId
    Case #SCS_DEVGRP_VIDEO_CAPTURE
      sLogicalDevNew = grProdForDevChgs\aVidCapLogicalDevs(nDevNo)\sLogicalDev
      nDevId = grProdForDevChgs\aVidCapLogicalDevs(nDevNo)\nDevId
    Case #SCS_DEVGRP_FIX_TYPE
      ; fixture type info not recorded in device maps
    Case #SCS_DEVGRP_LIGHTING
      sLogicalDevNew = grProdForDevChgs\aLightingLogicalDevs(nDevNo)\sLogicalDev
      nDevId = grProdForDevChgs\aLightingLogicalDevs(nDevNo)\nDevId
    Case #SCS_DEVGRP_CTRL_SEND
      sLogicalDevNew = grProdForDevChgs\aCtrlSendLogicalDevs(nDevNo)\sLogicalDev
      nDevId = grProdForDevChgs\aCtrlSendLogicalDevs(nDevNo)\nDevId
    Case #SCS_DEVGRP_CUE_CTRL
      sLogicalDevNew = grProdForDevChgs\aCueCtrlLogicalDevs(nDevNo)\sCueCtrlLogicalDev
      nDevId = grProdForDevChgs\aCueCtrlLogicalDevs(nDevNo)\nDevId
    Case #SCS_DEVGRP_LIVE_INPUT
      sLogicalDevNew = grProdForDevChgs\aLiveInputLogicalDevs(nDevNo)\sLogicalDev
      nDevId = grProdForDevChgs\aLiveInputLogicalDevs(nDevNo)\nDevId
    Case #SCS_DEVGRP_IN_GRP
      ; input group info not recorded in device maps
  EndSelect
  debugMsg(sProcName, "sLogicalDevOld=" + sLogicalDevOld + ", sLogicalDevNew=" + sLogicalDevNew + ", nDevId=" + nDevId)
  
  If Len(sLogicalDevOld) = 0 And Len(sLogicalDevNew) = 0
    ; nothing to do
    ProcedureReturn
  EndIf
  
  If Len(sLogicalDevOld) = 0
    sLogicalDevOld = sLogicalDevNew   ; ensure new entry is found in devmaps
  EndIf
  
  ; update all device maps
  For nDevMapPtr = 0 To grMapsForDevChgs\nMaxMapIndex
    debugMsg(sProcName, "nDevMapPtr=" + nDevMapPtr)
    bFound = #False
    d2 = grMapsForDevChgs\aMap(nDevMapPtr)\nFirstDevIndex
    nLastDevIndex = d2
    While d2 >= 0
      With grMapsForDevChgs\aDev(d2)
        If sLogicalDevOld
          ; debugMsg(sProcName, "grMapsForDevChgs\aDev(" + d2 + ")\nDevGrp=" + decodeDevGrp(\nDevGrp) + ", \nDevType=" + decodeDevType(\nDevType) +
          ;                     ", \bExists=" + strB(\bExists) + ", \sLogicalDev=" + \sLogicalDev + ", \nNextDevIndex=" + \nNextDevIndex)
          If \nDevGrp = nDevGrp
            If \sLogicalDev = sLogicalDevOld
              If \bExists
                ; debugMsg(sProcName, "found at d2=" + d2)
                debugMsg(sProcName, "grMapsForDevChgs\aDev(" + d2 + ")\nDevGrp=" + decodeDevGrp(\nDevGrp) + ", \nDevType=" + decodeDevType(\nDevType) +
                                    ", \bExists=" + strB(\bExists) + ", \sLogicalDev=" + \sLogicalDev + ", \nNextDevIndex=" + \nNextDevIndex)
                bFound = #True
                If \nDevType <> nDevType
                  \nDevType = nDevType
                  setDevChgsDevDefaults(d2, #False)
                  \nPhysicalDevPtr = -1   ; existing physical device not applicable as user has changed the device type
                EndIf
                \sLogicalDev = sLogicalDevNew
                \nDevId = nDevId
                debugMsg(sProcName, "grMapsForDevChgs\aDev(" + d2 + ")\nDevId=" + \nDevId)
                Select nDevType
                  Case #SCS_DEVTYPE_AUDIO_OUTPUT
                    \nNrOfDevOutputChans = grProdForDevChgs\aAudioLogicalDevs(nDevNo)\nNrOfOutputChans
                    debugMsg(sProcName, "grMapsForDevChgs\aDev(" + d2 + ")\nNrOfDevOutputChans=" + \nNrOfDevOutputChans)
                    If nDevMapPtr = grProdForDevChgs\nSelectedDevMapPtr
                      If \sPhysicalDev
                        \nPhysicalDevPtr = getPhysicalDevPtr(nDevType, \sPhysicalDev, grMapsForDevChgs\aMap(nDevMapPtr)\nAudioDriver, "", 0, \bDummy, \bDefaultDev)
                        ; debugMsg(sProcName, "grMapsForDevChgs\aDev(" + d2 + ")\nPhysicalDevPtr=" + \nPhysicalDevPtr)
                      EndIf
                      If Len(\sPhysicalDev) = 0 Or \nPhysicalDevPtr = -1
                        setDevChgsPhysDevIfReqd(d2, nDevNo)
                      EndIf
                      \s1BasedOutputRange = build1BasedOutputRangeString(\nFirst1BasedOutputChan, \nNrOfDevOutputChans, \nPhysicalDevPtr)
                    EndIf
                    
                  Case #SCS_DEVTYPE_VIDEO_AUDIO
                    \nNrOfDevOutputChans = grProdForDevChgs\aVidAudLogicalDevs(nDevNo)\nNrOfOutputChans
                    If nDevMapPtr = grProdForDevChgs\nSelectedDevMapPtr
                      If \sPhysicalDev
                        \nPhysicalDevPtr = getPhysicalDevPtr(nDevType, \sPhysicalDev, grMapsForDevChgs\aMap(nDevMapPtr)\nAudioDriver, "", 0, \bDummy, \bDefaultDev)
                        ; debugMsg(sProcName, "grMapsForDevChgs\aDev(" + d2 + ")\nPhysicalDevPtr=" + \nPhysicalDevPtr)
                      EndIf
                      If Len(\sPhysicalDev) = 0 Or \nPhysicalDevPtr = -1
                        debugMsg(sProcName, "calling setDevChgsPhysDevIfReqd(" + d2 + ", " + nDevNo + ")")
                        setDevChgsPhysDevIfReqd(d2, nDevNo)
                      EndIf
                    EndIf
                    
                  Case #SCS_DEVTYPE_VIDEO_CAPTURE
                    If nDevMapPtr = grProdForDevChgs\nSelectedDevMapPtr
                      If \sPhysicalDev
                        \nPhysicalDevPtr = getPhysicalDevPtr(nDevType, \sPhysicalDev, grMapsForDevChgs\aMap(nDevMapPtr)\nAudioDriver, "", 0, \bDummy, \bDefaultDev)
                        ; debugMsg(sProcName, "grMapsForDevChgs\aDev(" + d2 + ")\nPhysicalDevPtr=" + \nPhysicalDevPtr)
                      EndIf
                      If Len(\sPhysicalDev) = 0 Or \nPhysicalDevPtr = -1
                        debugMsg(sProcName, "calling setDevChgsPhysDevIfReqd(" + d2 + ", " + nDevNo + ")")
                        setDevChgsPhysDevIfReqd(d2, nDevNo)
                      EndIf
                    EndIf
                    
                  Case #SCS_DEVTYPE_LIVE_INPUT
                    \nNrOfInputChans = grProdForDevChgs\aLiveInputLogicalDevs(nDevNo)\nNrOfInputChans
                    If nDevMapPtr = grProdForDevChgs\nSelectedDevMapPtr
                      If \sPhysicalDev
                        \nPhysicalDevPtr = getPhysicalDevPtr(nDevType, \sPhysicalDev, grMapsForDevChgs\aMap(nDevMapPtr)\nAudioDriver, "", 0, \bDummy, \bDefaultDev)
                        ; debugMsg(sProcName, "grMapsForDevChgs\aDev(" + d2 + ")\nPhysicalDevPtr=" + \nPhysicalDevPtr)
                      EndIf
                      If Len(\sPhysicalDev) = 0 Or \nPhysicalDevPtr = -1
                        debugMsg(sProcName, "calling setDevChgsPhysDevIfReqd(" + d2 + ", " + nDevNo + ")")
                        setDevChgsPhysDevIfReqd(d2, nDevNo)
                      EndIf
                      \s1BasedInputRange = build1BasedInputRangeString(\nFirst1BasedInputChan, \nNrOfInputChans, \nPhysicalDevPtr)
                      ; \s0BasedInputRange = make0BasedInputRangeString(\s1BasedInputRange)
                    EndIf
                    
                  Case #SCS_DEVTYPE_LT_DMX_OUT, #SCS_DEVTYPE_CS_MIDI_OUT, #SCS_DEVTYPE_CS_RS232_OUT, #SCS_DEVTYPE_CS_HTTP_REQUEST
                    If nDevMapPtr = grProdForDevChgs\nSelectedDevMapPtr
                      debugMsg(sProcName, "calling setDevChgsPhysDevIfReqd(" + d2 + ", " + nDevNo + ")")
                      setDevChgsPhysDevIfReqd(d2, nDevNo)
                    EndIf
                    
                  Case #SCS_DEVTYPE_CC_DMX_IN, #SCS_DEVTYPE_CC_MIDI_IN, #SCS_DEVTYPE_CC_NETWORK_IN, #SCS_DEVTYPE_CC_RS232_IN
                    ; Added 9Sep2024
                    If nDevMapPtr = grProdForDevChgs\nSelectedDevMapPtr
                      debugMsg(sProcName, "calling setDevChgsPhysDevIfReqd(" + d2 + ", " + nDevNo + ")")
                      setDevChgsPhysDevIfReqd(d2, nDevNo)
                    EndIf
                    
                EndSelect
                Break
              EndIf
            EndIf
          EndIf
        EndIf
        nLastDevIndex = d2
        d2 = \nNextDevIndex
      EndWith
    Wend
    If bFound = #False
      ; OBSOLETE
      If sLogicalDevNew
        debugMsg(sProcName, "grMapsForDevChgs\aMap(" + nDevMapPtr + ")\nDevMapId=" + grMapsForDevChgs\aMap(nDevMapPtr)\nDevMapId + ", \sDevMapName=" + grMapsForDevChgs\aMap(nDevMapPtr)\sDevMapName +
                            ", bFound=#False !!!!!!!!")
      EndIf
    EndIf
  Next nDevMapPtr
  
  debugMsg(sProcName, "calling ED_checkDevMapForDevChgs(" + getDevChgsDevMapName(grProdForDevChgs\nSelectedDevMapPtr) + ")")
  ED_checkDevMapForDevChgs(grProdForDevChgs\nSelectedDevMapPtr)
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure addDevToDevChgsDevMap(nDevGrp, nDevType, nDevId, sLogicalDev.s, nNrOfOutputChans=0, nNrOfInputChans=0, nUseDevMapPtr=-1, *rImportDevMapDev.tyDevMapDev=0)
  PROCNAMEC()
  Protected nFirstDevMapPtr, nLastDevMapPtr
  Protected nDevMapPtr, nDevMapId
  Protected nNewDevMapDevPtr
  Protected n, d2, nMinArraySize, nFixtureIndex, nMaxFixtureIndex
  Protected nPrevDevMapDevPtr, nNextDevMapDevPtr
  Protected nAudioDriver
  Protected nDevNo
  
  ; debugMsg(sProcName, #SCS_START + ", nDevGrp=" + decodeDevGrp(nDevGrp) + ", nDevType=" + decodeDevType(nDevType) + ", nDevId=" + nDevId + ", sLogicalDev=" + sLogicalDev +
  ;                     ", nNrOfOutputChans=" + nNrOfOutputChans + ", nNrOfInputChans=" + nNrOfInputChans + ", nUseDevMapPtr=" + nUseDevMapPtr + ", *rImportDevMapDev.tyDevMapDev=" + *rImportDevMapDev.tyDevMapDev)
  
  nNewDevMapDevPtr = -1
  
  If nUseDevMapPtr >= 0
    nFirstDevMapPtr = nUseDevMapPtr
    nLastDevMapPtr = nUseDevMapPtr
  Else
    nFirstDevMapPtr = 0
    nLastDevMapPtr = grMapsForDevChgs\nMaxMapIndex
  EndIf
  
  ; make sure dev array is large enough for a copy of the new device for each device map
  nMinArraySize = (grMapsForDevChgs\nMaxDevIndex + 2) * (grMapsForDevChgs\nMaxMapIndex + 1)
  If nMinArraySize > ArraySize(grMapsForDevChgs\aDev())
    REDIM_ARRAY(grMapsForDevChgs\aDev, nMinArraySize, grDevMapDevDef, "grMapsForDevChgs\aDev()")
  EndIf
  
  ; append the new entries to the array, and link them to the existing last entry for the device group
  For nDevMapPtr = nFirstDevMapPtr To nLastDevMapPtr
    ; debugMsg(sProcName, ">>> nDevMapPtr=" + nDevMapPtr + " (" + getDevChgsDevMapName(nDevMapPtr) + ")")
    nDevMapId = grMapsForDevChgs\aMap(nDevMapPtr)\nDevMapId
    nAudioDriver = grMapsForDevChgs\aMap(nDevMapPtr)\nAudioDriver
    nPrevDevMapDevPtr = -1
    d2 = grMapsForDevChgs\aMap(nDevMapPtr)\nFirstDevIndex
    While d2 >= 0
      nPrevDevMapDevPtr = d2
      d2 = grMapsForDevChgs\aDev(d2)\nNextDevIndex
    Wend
    grMapsForDevChgs\nMaxDevIndex + 1
    nNextDevMapDevPtr = grMapsForDevChgs\nMaxDevIndex
    grMapsForDevChgs\aDev(nNextDevMapDevPtr) = grDevMapDevDef
    With grMapsForDevChgs\aDev(nNextDevMapDevPtr)
      \nDevMapId = nDevMapId
      ; debugMsg(sProcName, "grMapsForDevChgs\aDev(" + nNextDevMapDevPtr + ")\nDevMapId=" + grMapsForDevChgs\aDev(nNextDevMapDevPtr)\nDevMapId)
      \nDevId = nDevId
      ; debugMsg(sProcName, "grMapsForDevChgs\aDev(" + nNextDevMapDevPtr + ")\nDevMapId=" + \nDevMapId + ", \nDevId=" + \nDevId)
      \nPrevDevIndex = nPrevDevMapDevPtr
      \nNextDevIndex = -1
      ; debugMsg(sProcName, "grMapsForDevChgs\aDev(" + nNextDevMapDevPtr + ")\nPrevDevIndex=" + grMapsForDevChgs\aDev(nNextDevMapDevPtr)\nPrevDevIndex + ", grMapsForDevChgs\aDev(" + nNextDevMapDevPtr + ")\nNextDevIndex=" + grMapsForDevChgs\aDev(nNextDevMapDevPtr)\nNextDevIndex)
      \nDevGrp = nDevGrp
      \nDevType = nDevType
      \sLogicalDev = sLogicalDev
      \nNrOfDevOutputChans = nNrOfOutputChans
      ; debugMsg(sProcName, "grMapsForDevChgs\aDev(" + nNextDevMapDevPtr + ")\nNrOfDevOutputChans=" + \nNrOfDevOutputChans)
      \nNrOfInputChans = nNrOfInputChans
      ; debugMsg(sProcName, "setting grMapsForDevChgs\aDev(" + nNextDevMapDevPtr + ")\bExists=#True, was " + strB(\bExists) + ", \nDevType=" + decodeDevType(\nDevType) + ", \sLogicalDev=" + \sLogicalDev)
      \bExists = #True
      If (nDevType = #SCS_DEVTYPE_AUDIO_OUTPUT) And (nAudioDriver = #SCS_DRV_BASS_ASIO)
        \bBassASIO = #True
      EndIf
      ; Added 20Jun2023 11.10.0be
      If nDevType = #SCS_DEVTYPE_LT_DMX_OUT
        \nMaxDevFixture = -1
        If *rImportDevMapDev > 0
          \nMaxDevFixture = *rImportDevMapDev\nMaxDevFixture
          CopyArray(*rImportDevMapDev\aDevFixture(), \aDevFixture())
        Else
          ; Added 12Apr2024 11.10.2by to enable a lighting device's fixtures to be populated from the device's fixtures in grProdForDevChgs
          nDevNo = getDevNoForLogicalDev(@grProdForDevChgs, #SCS_DEVGRP_LIGHTING, sLogicalDev)
          If nDevNo >= 0
            nMaxFixtureIndex = grProdForDevChgs\aLightingLogicalDevs(nDevNo)\nMaxFixture
            If nMaxFixtureIndex >= 0
              ReDim \aDevFixture(nMaxFixtureIndex)
              For nFixtureIndex = 0 To nMaxFixtureIndex
                \aDevFixture(nFixtureIndex)\sDevFixtureCode = grProdForDevChgs\aLightingLogicalDevs(nDevNo)\aFixture(nFixtureIndex)\sFixtureCode
                \aDevFixture(nFixtureIndex)\nDevDMXStartChannel = grProdForDevChgs\aLightingLogicalDevs(nDevNo)\aFixture(nFixtureIndex)\nDefaultDMXStartChannel
                \aDevFixture(nFixtureIndex)\nMaxDevStartChannelIndex = 0
                \aDevFixture(nFixtureIndex)\aDevStartChannel(0) = \aDevFixture(nFixtureIndex)\nDevDMXStartChannel
                \aDevFixture(nFixtureIndex)\sDevDMXStartChannels = Str(\aDevFixture(nFixtureIndex)\nDevDMXStartChannel)
              Next nFixtureIndex
            EndIf
          EndIf
          ; End added 12Apr2024 11.10.2by
        EndIf
      EndIf
      ; End added 20Jun2023 11.10.0be
      \bNewDevice = #True ; added 3Nov2015 11.4.1.2g
    EndWith
    
    setDevChgsDevDefaults(nNextDevMapDevPtr)
    
    ; debugMsg(sProcName, "nPrevDevMapDevPtr=" + nPrevDevMapDevPtr + ", nNextDevMapDevPtr=" + nNextDevMapDevPtr)
    If nPrevDevMapDevPtr < 0
      grMapsForDevChgs\aMap(nDevMapPtr)\nFirstDevIndex = nNextDevMapDevPtr
    Else
      grMapsForDevChgs\aDev(nPrevDevMapDevPtr)\nNextDevIndex = nNextDevMapDevPtr
      ; debugMsg(sProcName, "grMapsForDevChgs\aDev(" + nPrevDevMapDevPtr + ")\nNextDevIndex=" + grMapsForDevChgs\aDev(nPrevDevMapDevPtr)\nNextDevIndex + ", grMapsForDevChgs\aDev(" + nNextDevMapDevPtr + ")\nPrevDevIndex=" + grMapsForDevChgs\aDev(nNextDevMapDevPtr)\nPrevDevIndex)
    EndIf
    
    If nUseDevMapPtr >= 0
      nNewDevMapDevPtr = nNextDevMapDevPtr
    Else
      If grProdForDevChgs\nSelectedDevMapPtr = nDevMapPtr
        nNewDevMapDevPtr = nNextDevMapDevPtr
      EndIf
    EndIf
    
  Next nDevMapPtr
  
  If nNewDevMapDevPtr >= 0
    With grMapsForDevChgs\aDev(nNewDevMapDevPtr)
      debugMsg(sProcName, "grMapsForDevChgs\aDev(" + nNewDevMapDevPtr + ")\nDevGrp=" + decodeDevGrp(\nDevGrp) + ", \nDevType=" + decodeDevType(\nDevType) + ", \sLogicalDev=" + \sLogicalDev + ", \nNrOfDevOutputChans=" + \nNrOfDevOutputChans + ", \bBassASIO=" + strB(\bBassASIO))
    EndWith
  EndIf
  
  ; debugMsg(sProcName, #SCS_END + " returning nDevMapDevPtr=" + nNewDevMapDevPtr)
  ProcedureReturn nNewDevMapDevPtr
  
EndProcedure

Procedure loadDevMapsForDevChgs(bProcessingUndoDevChgs=#False)
  PROCNAMEC()
  Protected d, d2, n, nArraySize
  Protected sMyLogicalDev.s
  Protected nDevMapPtr, nDevMapDevPtr
  Protected bDMXInPortChanged, bDMXOutPortChanged
  Protected nDMXDevPtr = -1
  
  debugMsg(sProcName, "copying gaDevMap array to grMapsForDevChgs\aDevMap array, grMaps\nMaxMapIndex=" + grMaps\nMaxMapIndex + ", ArraySize(grMapsForDevChgs\aMap())=" + ArraySize(grMapsForDevChgs\aMap()))
  
  ; copy device maps
  If grMaps\nMaxMapIndex >= ArraySize(grMapsForDevChgs\aMap())
    REDIM_ARRAY(grMapsForDevChgs\aMap, grMaps\nMaxMapIndex, grDevMapDef, "grMapsForDevChgs\aMap()")
  EndIf
  debugMsg(sProcName, "grMaps\nMaxMapIndex=" + grMaps\nMaxMapIndex)
  For n = 0 To grMaps\nMaxMapIndex
    CheckSubInRange(n, ArraySize(grMaps\aMap()), "grMaps\aMap()")
    CheckSubInRange(n, ArraySize(grMapsForDevChgs\aMap()), "grMapsForDevChgs\aMap()")
    grMapsForDevChgs\aMap(n) = grMaps\aMap(n)
    grMapsForDevChgs\aMap(n)\nOrigAudioDriver = grMapsForDevChgs\aMap(n)\nAudioDriver     ; used to check for changes in WEP_btnApplyDevChgs()
  Next n
  
  ; copy devices
  nArraySize = ArraySize(grMaps\aDev())
  REDIM_ARRAY(grMapsForDevChgs\aDev, nArraySize, grDevMapDevDef, "grMapsForDevChgs\aDev()")
  debugMsg(sProcName, "grMaps\nMaxDevIndex=" + grMaps\nMaxDevIndex + ", nArraySize=" + nArraySize)
  For n = 0 To grMaps\nMaxDevIndex
    CheckSubInRange(n, ArraySize(grMaps\aDev()), "grMaps\aDev()")
    CheckSubInRange(n, ArraySize(grMapsForDevChgs\aDev()), "grMapsForDevChgs\aDev()")
    Select grMapsForDevChgs\aDev(n)\nDevType
      Case #SCS_DEVTYPE_CC_DMX_IN
        nDMXDevPtr = n
        If grMapsForDevChgs\aDev(n)\sPhysicalDev <> grMaps\aDev(n)\sPhysicalDev Or grMapsForDevChgs\aDev(n)\sDMXSerial <> grMaps\aDev(n)\sDMXSerial
          bDMXInPortChanged = #True
        EndIf
      Case #SCS_DEVTYPE_LT_DMX_OUT
        nDMXDevPtr = n
        If grMapsForDevChgs\aDev(n)\sPhysicalDev <> grMaps\aDev(n)\sPhysicalDev Or grMapsForDevChgs\aDev(n)\sDMXSerial <> grMaps\aDev(n)\sDMXSerial
          bDMXOutPortChanged = #True
        EndIf
    EndSelect
    grMapsForDevChgs\aDev(n) = grMaps\aDev(n)
    grMapsForDevChgs\aDev(n)\sOrigPhysicalDev = grMapsForDevChgs\aDev(n)\sPhysicalDev     ; used to check for changes in WEP_btnApplyDevChgs()
  Next n
  grMapsForDevChgs\nMaxMapIndex = grMaps\nMaxMapIndex
  debugMsg(sProcName, "grMapsForDevChgs\nMaxMapIndex=" + grMapsForDevChgs\nMaxMapIndex)
  grProdForDevChgs\nSelectedDevMapPtr = grProd\nSelectedDevMapPtr
  grProdForDevChgs\sSelectedDevMapName = grProd\sSelectedDevMapName
  
  nDevMapPtr = grProdForDevChgs\nSelectedDevMapPtr
  ; set \nOutputDevMapDevPtr for each audio output device
  For d = 0 To grProdForDevChgs\nMaxAudioLogicalDev
    With grProdForDevChgs\aAudioLogicalDevs(d)
      nDevMapDevPtr = -1
      If \sLogicalDev
        If nDevMapPtr >= 0
          sMyLogicalDev = \sLogicalDev
          d2 = grMapsForDevChgs\aMap(nDevMapPtr)\nFirstDevIndex
          While d2 >= 0
            If grMapsForDevChgs\aDev(d2)\nDevGrp = #SCS_DEVGRP_AUDIO_OUTPUT
              If grMapsForDevChgs\aDev(d2)\sLogicalDev = sMyLogicalDev
                nDevMapDevPtr = d2
                Break
              EndIf
            EndIf
            d2 = grMapsForDevChgs\aDev(d2)\nNextDevIndex
          Wend
        EndIf
      EndIf
    EndWith
  Next d
  
  If bProcessingUndoDevChgs
    If nDMXDevPtr >= 0
      debugMsg(sProcName, "calling DMX_loadDMXControl()")
      DMX_loadDMXControl()
      debugMsg(sProcName, "bDMXInPortChanged=" + strB(bDMXInPortChanged) + ", bDMXOutPortChanged=" + strB(bDMXOutPortChanged))
      If bDMXInPortChanged Or bDMXOutPortChanged
        debugMsg(sProcName, "calling DMX_closeDMXDevs()")
        DMX_closeDMXDevs()
        debugMsg(sProcName, "calling DMX_openDMXDevs()")
        DMX_openDMXDevs()
      EndIf
    EndIf
  EndIf
  
  debugMsg(sProcName, "calling listAllDevMapsForDevChgs()")
  listAllDevMapsForDevChgs()
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure applyDevMapsForDevChgs()
  PROCNAMEC()
  Protected n, nArraySize
  Protected nSelectedDevMapPtr, nPrevSelectedDevMapPtr
  Protected bDMXInPortChanged, bDMXOutPortChanged
  Protected nDMXDevPtr = -1
  
  nPrevSelectedDevMapPtr = grProd\nSelectedDevMapPtr
  
  debugMsg(sProcName, #SCS_START + ", summarizing devmaps")
  summarizeAllDevMaps()
  
  ;   debugMsg(sProcName, "calling listAllDevMaps()")
  ;   listAllDevMaps()
  
  debugMsg(sProcName, "calling syncFixturesInDev(@grProdForDevChgs, @grMapsForDevChgs)")
  syncFixturesInDev(@grProdForDevChgs, @grMapsForDevChgs)
  
  debugMsg(sProcName, "copying grMapsForDevChgs\aDevMap array to gaDevMap array")
  
  ; copy grMapsForDevChgs\aDevMap array to gaDevMap array
  If grMapsForDevChgs\nMaxMapIndex >= 0
    REDIM_ARRAY(grMaps\aMap, grMapsForDevChgs\nMaxMapIndex, grDevMapDef, "grMaps\aMap()")
  Else
    REDIM_ARRAY(grMaps\aMap, 0, grDevMapDef, "grMaps\aMap()")
  EndIf
  
  For n = 0 To grMapsForDevChgs\nMaxMapIndex
    debugMsg(sProcName, "grMaps\aMap(" + n + ")\sDevMapName=" + grMaps\aMap(n)\sDevMapName + ", grMapsForDevChgs\aMap(" + n + ")\sDevMapName=" + grMapsForDevChgs\aMap(n)\sDevMapName)
    grMapsForDevChgs\aMap(n)\bNewDevMap = #False
    grMapsForDevChgs\aMap(n)\nOrigAudioDriver = grMapsForDevChgs\aMap(n)\nAudioDriver
    grMaps\aMap(n) = grMapsForDevChgs\aMap(n) 
    debugMsg(sProcName, "grMaps\aMap(" + n + ")\nFirstDevIndex=" + grMaps\aMap(n)\nFirstDevIndex)
  Next n
  
  ;   debugMsg(sProcName, "calling listAllDevMaps()")
  ;   listAllDevMaps()
  
  nArraySize = ArraySize(grMapsForDevChgs\aDev())
  REDIM_ARRAY(grMaps\aDev, nArraySize, grDevMapDevDef, "grMaps\aDev()")
  For n = 0 To grMapsForDevChgs\nMaxDevIndex
    If grMapsForDevChgs\aDev(n)\sOrigPhysicalDev <> grMapsForDevChgs\aDev(n)\sPhysicalDev
      debugMsg(sProcName, "grMaps\aDev(" + n + ")\sPhysicalDev=" + grMaps\aDev(n)\sPhysicalDev + ", grMapsForDevChgs\aDev(" + n + ")\sPhysicalDev=" + grMapsForDevChgs\aDev(n)\sPhysicalDev)
    EndIf
    grMapsForDevChgs\aDev(n)\sOrigPhysicalDev = grMapsForDevChgs\aDev(n)\sPhysicalDev
    Select grMapsForDevChgs\aDev(n)\nDevType
      Case #SCS_DEVTYPE_CC_DMX_IN
        nDMXDevPtr = n
        If grMapsForDevChgs\aDev(n)\sPhysicalDev <> grMaps\aDev(n)\sPhysicalDev Or grMapsForDevChgs\aDev(n)\nDMXSerial <> grMaps\aDev(n)\nDMXSerial Or grMapsForDevChgs\aDev(n)\sDMXSerial <> grMaps\aDev(n)\sDMXSerial
          debugMsg(sProcName, "grMapsForDevChgs\aDev(" + n + ")\sPhysicalDev=" + grMapsForDevChgs\aDev(n)\sPhysicalDev +
                              ", \nDMXSerial=" + grMapsForDevChgs\aDev(n)\nDMXSerial + ", \sDMXSerial=" + grMapsForDevChgs\aDev(n)\sDMXSerial)
          bDMXInPortChanged = #True
        EndIf
      Case #SCS_DEVTYPE_LT_DMX_OUT
        nDMXDevPtr = n
        If grMapsForDevChgs\aDev(n)\sPhysicalDev <> grMaps\aDev(n)\sPhysicalDev Or grMapsForDevChgs\aDev(n)\nDMXSerial <> grMaps\aDev(n)\nDMXSerial Or grMapsForDevChgs\aDev(n)\sDMXSerial <> grMaps\aDev(n)\sDMXSerial
          debugMsg(sProcName, "grMapsForDevChgs\aDev(" + n + ")\sPhysicalDev=" + grMapsForDevChgs\aDev(n)\sPhysicalDev +
                              ", \nDMXSerial=" + grMapsForDevChgs\aDev(n)\nDMXSerial + ", \sDMXSerial=" + grMapsForDevChgs\aDev(n)\sDMXSerial)
          bDMXOutPortChanged = #True
        EndIf
    EndSelect
    grMaps\aDev(n) = grMapsForDevChgs\aDev(n)
  Next n
  grMaps\nMaxDevIndex = grMapsForDevChgs\nMaxDevIndex
  ; debugMsg(sProcName, "grMaps\nMaxDevIndex=" + grMaps\nMaxDevIndex + ", ArraySize(grMaps\aDev())=" + ArraySize(grMaps\aDev()))
  
  ;   debugMsg(sProcName, "calling listAllDevMaps()")
  ;   listAllDevMaps()
  
  grMaps\nMaxMapIndex = grMapsForDevChgs\nMaxMapIndex
  grMaps\sSelectedDevMapName = grMapsForDevChgs\sSelectedDevMapName ; Added 12Dec2023 11.10.0dl because renaming a device map, applying changes, saving changes and then selecting a different driver would previously crash
                                                                    ; because grMaps\sSelectedDevMapName had not been set, so some code would return -1 as the devmap pointer
  grProd\nSelectedDevMapPtr = grProdForDevChgs\nSelectedDevMapPtr
  grProd\sSelectedDevMapName = grProdForDevChgs\sSelectedDevMapName
  
  nSelectedDevMapPtr = grProd\nSelectedDevMapPtr
  If nSelectedDevMapPtr >= 0
    ; Added 21Dec2023 11.10.0ds - changeOfDevMap() processing was previously executed when selecting a different device map, but this MUST wait until the user clicks Apply Device Changes
    If nSelectedDevMapPtr <> nPrevSelectedDevMapPtr
      changeOfDevMap(nSelectedDevMapPtr)
    EndIf
    ; End added 21Dec2023 11.10.0ds
    setCurrAudioDriver(grMaps\aMap(nSelectedDevMapPtr)\nAudioDriver)
  EndIf
  debugMsg(sProcName, "gnCurrAudioDriver=" + decodeDriver(gnCurrAudioDriver))
  
  debugMsg(sProcName, "calling loadMidiControl(#False)")
  loadMidiControl(#False)
  
  If nDMXDevPtr >= 0
    debugMsg(sProcName, "calling DMX_loadDMXControl()")
    DMX_loadDMXControl()
    If bDMXInPortChanged Or bDMXOutPortChanged
      debugMsg(sProcName, "bDMXInPortChanged=" + strB(bDMXInPortChanged) + ", bDMXOutPortChanged=" + strB(bDMXOutPortChanged))
      debugMsg(sProcName, "calling DMX_closeDMXDevs()")
      DMX_closeDMXDevs()
      debugMsg(sProcName, "calling DMX_openDMXDevs()")
      DMX_openDMXDevs()
    EndIf
  EndIf
  
  ; debugMsg(sProcName, "calling listAllDevMaps()")
  ; listAllDevMaps()
  
  ; debugMsg(sProcName, "grProd\nSelectedDevMapPtr=" + grProd\nSelectedDevMapPtr + ", grProd\sSelectedDevMapName=" + grProd\sSelectedDevMapName)
  
  debugMsg(sProcName, #SCS_END + ", summarizing devmaps")
  summarizeAllDevMaps()
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure getFirst1BasedChanFromRange(s1BasedOutputRange.s)
  PROCNAMEC()
  Protected nFirst1BasedOutputChan, nHyphenPtr
  
  ;    debugMsg(sProcName, #SCS_START + ", s1BasedOutputRange=" + s1BasedOutputRange)
  
  If Len(Trim(s1BasedOutputRange)) > 0
    nHyphenPtr = InStr(s1BasedOutputRange, "-")
    If nHyphenPtr = 0
      Select Trim(s1BasedOutputRange)
        Case "L"
          nFirst1BasedOutputChan = 1
        Case "R"
          nFirst1BasedOutputChan = 2
        Default
          nFirst1BasedOutputChan = Val(s1BasedOutputRange)
      EndSelect
    Else
      If s1BasedOutputRange = "L-R"
        nFirst1BasedOutputChan = 1
      Else
        nFirst1BasedOutputChan = Val(Left(s1BasedOutputRange, (nHyphenPtr - 1)))
      EndIf
    EndIf
  EndIf
  
  ProcedureReturn nFirst1BasedOutputChan
  
EndProcedure

Procedure getNumChansFromRange(s1BasedOutputRange.s)
  PROCNAMEC()
  Protected nFirst1BasedOutputChan, nLast1BasedOutputChan, nHyphenPtr
  
  ;    debugMsg(sProcName, #SCS_START + ", s1BasedOutputRange=" + s1BasedOutputRange)
  
  If Len(Trim(s1BasedOutputRange)) > 0
    nHyphenPtr = InStr(s1BasedOutputRange, "-")
    If nHyphenPtr = 0
      Select Trim(s1BasedOutputRange)
        Case "L"
          nFirst1BasedOutputChan = 1
        Case "R"
          nFirst1BasedOutputChan = 2
        Default
          nFirst1BasedOutputChan = Val(s1BasedOutputRange)
      EndSelect
      nLast1BasedOutputChan = nFirst1BasedOutputChan
    Else
      If s1BasedOutputRange = "L-R"
        nFirst1BasedOutputChan = 1
        nLast1BasedOutputChan = 2
      Else
        nFirst1BasedOutputChan = Val(Left(s1BasedOutputRange, (nHyphenPtr - 1)))
        nLast1BasedOutputChan = Val(Mid(s1BasedOutputRange, (nHyphenPtr + 1)))
      EndIf
    EndIf
  EndIf
  
  ProcedureReturn (nLast1BasedOutputChan - nFirst1BasedOutputChan + 1)
  
EndProcedure

Procedure setDevChgsPhysDevIfReqd(nDevMapDevPtr, nDevNo)
  PROCNAMEC()
  Protected nDevMapPtr, nDevMapId
  Protected nDevType
  Protected d
  Protected nLastPhysicalDevPtrForThisDevType
  Protected nLastAudioOutputUsed, nAudioOutputs
  Protected nLastVidAudOutputUsed, nVidAudOutputs
  Protected nVidCaps
  Protected nLastPhysCtrlSendPtr, nLastCtrlSendUsed, nCtrlSends
  Protected nLastPhysCueCtrlPtr, nLastCueCtrlUsed, nCueCtrls
  Protected nLastPhysDMXPtr, nLastDMXUsed, nDMXs
  Protected nLastLiveInputUsed, nLiveInputs
  Protected nSortedPhysPtr
  Protected nAudioPhysPtr, nVidAudPhysPtr, nVidCapPhysPtr
  Protected nPhysicalDevPtrNew
  Protected bRetryFromStart
  Protected nNetworkControlPtr
  Protected nPhysicalDevPtr
  Protected nLoopCount ; for debug purposes only
  Protected nNumAudioDevs
  Protected bDefaultDevAlreadyAssigned
  
  ; debugMsg(sProcName, #SCS_START + ", nDevMapDevPtr=" + nDevMapDevPtr + ", nDevNo=" + nDevNo)
  
  If (nDevMapDevPtr < 0) Or (nDevNo < 0)
    ProcedureReturn
  EndIf
  
  nDevType = grMapsForDevChgs\aDev(nDevMapDevPtr)\nDevType
  nDevMapPtr = grProdForDevChgs\nSelectedDevMapPtr
  debugMsg(sProcName, "nDevType=" + decodeDevType(nDevType) + ", nDevMapPtr=" + getDevChgsDevMapName(nDevMapPtr))

  While #True
    nLoopCount + 1
    ; debugMsg(sProcName, "--- nLoopCount=" + nLoopCount)
    
    With grMapsForDevChgs\aDev(nDevMapDevPtr)
      If (\nPhysicalDevPtr >= 0) And (nDevType <> #SCS_DEVTYPE_NONE)
        ; physical device already assigned
        ; debugMsg(sProcName, "exiting - grMapsForDevChgs\aDev(" + nDevMapDevPtr + ")\nPhysicalDevPtr=" + \nPhysicalDevPtr)
        ProcedureReturn
      EndIf
      
      nDevMapId = grMapsForDevChgs\aMap(nDevMapPtr)\nDevMapId
      
      ; find last initialized physical device used and (for audio output devices) find last output used on that device
      nLastPhysicalDevPtrForThisDevType = -1
      nSortedPhysPtr = -1
      
      nLastPhysCtrlSendPtr = -1
      nLastCtrlSendUsed = -1
      nCtrlSends = 0
      
      nLastPhysCueCtrlPtr = -1
      nLastCueCtrlUsed = -1
      nCueCtrls = 0
      
      nLastPhysDMXPtr = -1
      nLastDMXUsed = -1
      nDMXs = 0
      
      nLastLiveInputUsed = -1
      nLiveInputs = 0
      
      If bRetryFromStart = #False
        ;{
        If nDevType = #SCS_DEVTYPE_AUDIO_OUTPUT
          Select gnCurrAudioDriver
            Case #SCS_DRV_BASS_DS
              nNumAudioDevs = gnDSDeviceCount
            Case #SCS_DRV_BASS_WASAPI
              nNumAudioDevs = gnWASAPIDeviceCount
            Case #SCS_DRV_BASS_ASIO
              nNumAudioDevs = gnAsioDeviceCount
          EndSelect
        EndIf
        
        If nDevType <> #SCS_DEVTYPE_NONE
          ;{
          d = grMapsForDevChgs\aMap(nDevMapPtr)\nFirstDevIndex
          While d >= 0
            ; debugMsg(sProcName, "grMapsForDevChgs\aDev(" + d + ")\sLogicalDev=" + grMapsForDevChgs\aDev(d)\sLogicalDev + ", \nDevType=" + decodeDevType(grMapsForDevChgs\aDev(d)\nDevType) +
            ;                     ", \bExists=" + strB(grMapsForDevChgs\aDev(d)\bExists) + ", \sPhysicalDev=" + grMapsForDevChgs\aDev(d)\sPhysicalDev + ", \nPhysicalDevPtr=" + grMapsForDevChgs\aDev(d)\nPhysicalDevPtr)
            If (grMapsForDevChgs\aDev(d)\nDevType = nDevType) And (grMapsForDevChgs\aDev(d)\bExists) And (grMapsForDevChgs\aDev(d)\sLogicalDev)
              nPhysicalDevPtr = grMapsForDevChgs\aDev(d)\nPhysicalDevPtr
              If nPhysicalDevPtr >= 0
                Select nDevType
                  Case #SCS_DEVTYPE_AUDIO_OUTPUT, #SCS_DEVTYPE_LIVE_INPUT
                    If gaAudioDev(nPhysicalDevPtr)\bInitialized
                      nLastPhysicalDevPtrForThisDevType = grMapsForDevChgs\aDev(d)\nPhysicalDevPtr
                      If gaAudioDev(nPhysicalDevPtr)\bDefaultDev
                        bDefaultDevAlreadyAssigned = #True
                      EndIf
                    EndIf
                  Case #SCS_DEVTYPE_VIDEO_AUDIO
                    If gaVideoAudioDev(nPhysicalDevPtr)\bVidAudInitialized
                      nLastPhysicalDevPtrForThisDevType = grMapsForDevChgs\aDev(d)\nPhysicalDevPtr
                    EndIf
                  Case #SCS_DEVTYPE_VIDEO_CAPTURE
                    If gaVideoCaptureDev(nPhysicalDevPtr)\bVidCapInitialized
                      nLastPhysicalDevPtrForThisDevType = grMapsForDevChgs\aDev(d)\nPhysicalDevPtr
                    EndIf
                  Case #SCS_DEVTYPE_LT_DMX_OUT
                    If gaDMXDevice(nPhysicalDevPtr)\bInitialized
                      nLastPhysicalDevPtrForThisDevType = grMapsForDevChgs\aDev(d)\nPhysicalDevPtr
                    EndIf
                  Case #SCS_DEVTYPE_CC_MIDI_IN
                    If gaMidiInDevice(nPhysicalDevPtr)\bInitialized
                      nLastPhysicalDevPtrForThisDevType = grMapsForDevChgs\aDev(d)\nPhysicalDevPtr
                    EndIf
                  Case #SCS_DEVTYPE_CS_MIDI_OUT, #SCS_DEVTYPE_CS_MIDI_THRU
                    If gaMidiOutDevice(nPhysicalDevPtr)\bInitialized
                      nLastPhysicalDevPtrForThisDevType = grMapsForDevChgs\aDev(d)\nPhysicalDevPtr
                    EndIf
                  Case #SCS_DEVTYPE_CC_RS232_IN, #SCS_DEVTYPE_CS_RS232_OUT
                    If gaRS232Control(nPhysicalDevPtr)\bInitialized
                      nLastPhysicalDevPtrForThisDevType = grMapsForDevChgs\aDev(d)\nPhysicalDevPtr
                    EndIf
                  Case #SCS_DEVTYPE_CC_NETWORK_IN, #SCS_DEVTYPE_CS_NETWORK_OUT
                    If gaNetworkControl(nPhysicalDevPtr)\bNetworkDevInitialized
                      nLastPhysicalDevPtrForThisDevType = grMapsForDevChgs\aDev(d)\nPhysicalDevPtr
                    EndIf
                  Case #SCS_DEVTYPE_CC_DMX_IN
                    If gaDMXDevice(nPhysicalDevPtr)\bInitialized
                      nLastPhysicalDevPtrForThisDevType = grMapsForDevChgs\aDev(d)\nPhysicalDevPtr
                    EndIf
                EndSelect
              EndIf
            EndIf
            d = grMapsForDevChgs\aDev(d)\nNextDevIndex
          Wend
          ;}
        EndIf
        ;}
      EndIf
      
      debugMsg(sProcName, "bRetryFromStart=" + strB(bRetryFromStart) + ", nLastPhysicalDevPtrForThisDevType=" + nLastPhysicalDevPtrForThisDevType + ", nDevType=" + decodeDevType(nDevType))
      Select nDevType
        Case #SCS_DEVTYPE_NONE  ; #SCS_DEVTYPE_NONE
          ;{
          \sPhysicalDev = ""
          \nPhysicalDevPtr = -1
          \bDummy = #False
          ;}
          
        Case #SCS_DEVTYPE_AUDIO_OUTPUT  ; #SCS_DEVTYPE_AUDIO_OUTPUT
          ;{
          nLastAudioOutputUsed = -1
          nAudioOutputs = 0
          nAudioPhysPtr = -1
          If nLastPhysicalDevPtrForThisDevType >= 0
            nAudioOutputs = gaAudioDev(nLastPhysicalDevPtrForThisDevType)\nOutputs
            debugMsg(sProcName, "(a1) bRetryFromStart=" + strB(bRetryFromStart) + ", gaAudioDev(" + nLastPhysicalDevPtrForThisDevType + ")\sDesc=" + gaAudioDev(nLastPhysicalDevPtrForThisDevType)\sDesc + ", nAudioOutputs=" + nAudioOutputs)
            If bRetryFromStart = #False
              d = grMapsForDevChgs\aMap(nDevMapPtr)\nFirstDevIndex
              While d >= 0
                If (grMapsForDevChgs\aDev(d)\nDevType = nDevType) And (grMapsForDevChgs\aDev(d)\bExists)
                  If (grMapsForDevChgs\aDev(d)\sLogicalDev) And (grMapsForDevChgs\aDev(d)\nPhysicalDevPtr = nLastPhysicalDevPtrForThisDevType)
                    If (grMapsForDevChgs\aDev(d)\nFirst1BasedOutputChan + grMapsForDevChgs\aDev(d)\nNrOfDevOutputChans - 1) > nLastAudioOutputUsed
                      debugMsg(sProcName, "(a2) grMapsForDevChgs\aDev(" + d + ")\sLogicalDev=" + grMapsForDevChgs\aDev(d)\sLogicalDev +
                                          ", \nFirst1BasedOutputChan=" + grMapsForDevChgs\aDev(d)\nFirst1BasedOutputChan + ", \nNrOfDevOutputChans=" + grMapsForDevChgs\aDev(d)\nNrOfDevOutputChans)
                      nLastAudioOutputUsed = (grMapsForDevChgs\aDev(d)\nFirst1BasedOutputChan + grMapsForDevChgs\aDev(d)\nNrOfDevOutputChans - 1)
                    EndIf
                  EndIf
                EndIf
                d = grMapsForDevChgs\aDev(d)\nNextDevIndex
              Wend
            EndIf
            debugMsg(sProcName, "(a3) bRetryFromStart=" + strB(bRetryFromStart) + ", nLastAudioOutputUsed=" + nLastAudioOutputUsed)
            ; find where this physical device is in the list of physical devices
            For nAudioPhysPtr = 0 To (nNumAudioDevs - 1)
              If nAudioPhysPtr = nLastPhysicalDevPtrForThisDevType
                Break
              EndIf
            Next nAudioPhysPtr
            debugMsg(sProcName, "(a4) bRetryFromStart=" + strB(bRetryFromStart) + ", nAudioPhysPtr=" + nAudioPhysPtr + ", nNumAudioDevs=" + nNumAudioDevs + ", gnCurrAudioDriver=" + decodeDriver(gnCurrAudioDriver))
          EndIf
          
          debugMsg(sProcName, "(a4a) nLastAudioOutputUsed=" + nLastAudioOutputUsed +
                              ", grMapsForDevChgs\aDev(" + nDevMapDevPtr + ")\nNrOfDevOutputChans=" + grMapsForDevChgs\aDev(nDevMapDevPtr)\nNrOfDevOutputChans +
                              ", nAudioOutputs=" + nAudioOutputs + ", nLastPhysicalDevPtrForThisDevType=" + nLastPhysicalDevPtrForThisDevType)
          If (((nLastAudioOutputUsed + 1) + \nNrOfDevOutputChans - 1) > nAudioOutputs) Or (nLastPhysicalDevPtrForThisDevType = -1)
            debugMsg(sProcName, "(a5) bRetryFromStart=" + strB(bRetryFromStart) + ", nLastAudioOutputUsed=" + nLastAudioOutputUsed +
                                ", \nNrOfDevOutputChans=" + \nNrOfDevOutputChans + ", nAudioOutputs=" + nAudioOutputs + ", nAudioPhysPtrv=" + nAudioPhysPtr) ; insufficient remaining outputs on the current device (or this is the first time) so go to the next device
            nAudioPhysPtr + 1
            If bDefaultDevAlreadyAssigned
              ; This code is to prevent something like "1-2 (OCTA-CAPTURE)" being selected if this is the default device, after "Default Audio Device" has already been selected.
              ; So, for example, after "Default Audio Device", the next device selected would be something like "3-4 (OCTA-CAPTURE)", which avoids having the same physical device
              ; assigned to two audio outputs.
              While nAudioPhysPtr <= (nNumAudioDevs - 1) ; nAudioPhysPtr is 0-based but nNumAudioDevs is 1-based
                If gaAudioDev(nAudioPhysPtr)\bDefaultDev
                  nAudioPhysPtr + 1
                  Continue ; try again with the next device
                EndIf
                Break
              Wend
            EndIf
              
            nLastAudioOutputUsed = 0
            If (nAudioPhysPtr + 1) > gnNumVideoAudioDevs
              ; we've run out of physical devices
              If bRetryFromStart = #False
                debugMsg(sProcName, "(a6) run out of physical devices - retry from start")
                bRetryFromStart = #True
                Continue
              Else
                \nPhysicalDevPtr = -1
                nAudioOutputs = 0
              EndIf
            Else
              \nPhysicalDevPtr = nAudioPhysPtr
              debugMsg(sProcName, "(a7) grMapsForDevChgs\aDev(" + nDevMapDevPtr + ")\nPhysicalDevPtr=" + \nPhysicalDevPtr)
              nAudioOutputs = gaAudioDev(\nPhysicalDevPtr)\nOutputs
            EndIf
          Else
            \nPhysicalDevPtr = nLastPhysicalDevPtrForThisDevType
            debugMsg(sProcName, "(a8) grMapsForDevChgs\aDev(" + nDevMapDevPtr + ")\nPhysicalDevPtr=" + \nPhysicalDevPtr)
          EndIf
          debugMsg(sProcName, "(a9) bRetryFromStart=" + strB(bRetryFromStart) + ", \nPhysicalDevPtr=" + \nPhysicalDevPtr)
          If \nPhysicalDevPtr >= 0
            \sPhysicalDev = gaAudioDev(\nPhysicalDevPtr)\sDesc
            \bDummy = #False
            \nFirst1BasedOutputChan = nLastAudioOutputUsed + 1
            \s1BasedOutputRange = build1BasedOutputRangeString(\nFirst1BasedOutputChan, \nNrOfDevOutputChans, \nPhysicalDevPtr)
            nLastAudioOutputUsed + \nNrOfDevOutputChans
          Else
            \sPhysicalDev = ""
            \bDummy = #False
          EndIf
          debugMsg(sProcName, "(a10) grMapsForDevChgs\aDev(" + nDevMapDevPtr + ")\sLogicalDev=" + \sLogicalDev + ", \sPhysicalDev=" + \sPhysicalDev + ", \nFirstOutputChan=" + \nFirst1BasedOutputChan + ", \s1BasedOutputRange=" + \s1BasedOutputRange)
          ;}
          
        Case #SCS_DEVTYPE_VIDEO_AUDIO  ; #SCS_DEVTYPE_VIDEO_AUDIO
          ;{
          nLastVidAudOutputUsed = -1
          nVidAudOutputs = 0
          nVidAudPhysPtr = -1
          If nLastPhysicalDevPtrForThisDevType >= 0
            nVidAudOutputs = gaVideoAudioDev(nLastPhysicalDevPtrForThisDevType)\nVidAudOutputs
            debugMsg(sProcName, "(v1) bRetryFromStart=" + strB(bRetryFromStart) + ", gaVideoAudioDev(" + nLastPhysicalDevPtrForThisDevType + ")\sVidAudName=" + gaVideoAudioDev(nLastPhysicalDevPtrForThisDevType)\sVidAudName + ", nVidAudOutputs=" + nVidAudOutputs)
            If bRetryFromStart = #False
              d = grMapsForDevChgs\aMap(nDevMapPtr)\nFirstDevIndex
              While d >= 0
                If grMapsForDevChgs\aDev(d)\nDevType = nDevType And grMapsForDevChgs\aDev(d)\bExists
                  If (grMapsForDevChgs\aDev(d)\sLogicalDev) And (grMapsForDevChgs\aDev(d)\nPhysicalDevPtr = nLastPhysicalDevPtrForThisDevType)
                    If (grMapsForDevChgs\aDev(d)\nFirst1BasedOutputChan + grMapsForDevChgs\aDev(d)\nNrOfDevOutputChans - 1) > nLastVidAudOutputUsed
                      debugMsg(sProcName, "(v2) grMapsForDevChgs\aDev(" + d + ")\sLogicalDev=" + grMapsForDevChgs\aDev(d)\sLogicalDev +
                                          ", \nFirst1BasedOutputChan=" + grMapsForDevChgs\aDev(d)\nFirst1BasedOutputChan + ", \nNrOfDevOutputChans=" + grMapsForDevChgs\aDev(d)\nNrOfDevOutputChans)
                      nLastVidAudOutputUsed = (grMapsForDevChgs\aDev(d)\nFirst1BasedOutputChan + grMapsForDevChgs\aDev(d)\nNrOfDevOutputChans - 1)
                    EndIf
                  EndIf
                EndIf
                d = grMapsForDevChgs\aDev(d)\nNextDevIndex
              Wend
            EndIf
            debugMsg(sProcName, "(v3) bRetryFromStart=" + strB(bRetryFromStart) + ", nLastVidAudOutputUsed=" + nLastVidAudOutputUsed)
            ; find where this physical device is in the list of physical devices
            For nVidAudPhysPtr = 0 To (gnNumVideoAudioDevs-1)
              If nVidAudPhysPtr = nLastPhysicalDevPtrForThisDevType
                Break
              EndIf
            Next nVidAudPhysPtr
            debugMsg(sProcName, "(v4) bRetryFromStart=" + strB(bRetryFromStart) + ", nVidAudPhysPtr=" + nVidAudPhysPtr + ", gnNumVideoAudioDevs=" + gnNumVideoAudioDevs)
          EndIf
          
          debugMsg(sProcName, "(v4a) nLastVidAudOutputUsed=" + nLastVidAudOutputUsed +
                              ", grMapsForDevChgs\aDev(" + nDevMapDevPtr + ")\nNrOfDevOutputChans=" + grMapsForDevChgs\aDev(nDevMapDevPtr)\nNrOfDevOutputChans +
                              ", nVidAudOutputs=" + nVidAudOutputs + ", nLastPhysicalDevPtrForThisDevType=" + nLastPhysicalDevPtrForThisDevType)
          If (((nLastVidAudOutputUsed + 1) + \nNrOfDevOutputChans - 1) > nVidAudOutputs) Or (nLastPhysicalDevPtrForThisDevType = -1)
            debugMsg(sProcName, "(v5) bRetryFromStart=" + strB(bRetryFromStart) + ", nLastVidAudOutputUsed=" + nLastVidAudOutputUsed +
                                ", \nNrOfDevOutputChans=" + \nNrOfDevOutputChans + ", nVidAudOutputs=" + nVidAudOutputs + ", nVidAudPhysPtrv=" + nVidAudPhysPtr) ; insufficient remaining outputs on the current device (or this is the first time) so go to the next device
            nVidAudPhysPtr + 1
            nLastVidAudOutputUsed = 0
            If (nVidAudPhysPtr + 1) > gnNumVideoAudioDevs
              ; we've run out of physical devices
              If bRetryFromStart = #False
                debugMsg(sProcName, "(v6) run out of physical devices - retry from start")
                bRetryFromStart = #True
                Continue
              Else
                \nPhysicalDevPtr = -1
                nVidAudOutputs = 0
              EndIf
            Else
              \nPhysicalDevPtr = nVidAudPhysPtr
              debugMsg(sProcName, "(v7) grMapsForDevChgs\aDev(" + nDevMapDevPtr + ")\nPhysicalDevPtr=" + \nPhysicalDevPtr)
              nVidAudOutputs = gaVideoAudioDev(\nPhysicalDevPtr)\nVidAudOutputs
            EndIf
          Else
            \nPhysicalDevPtr = nLastPhysicalDevPtrForThisDevType
            debugMsg(sProcName, "(v8) grMapsForDevChgs\aDev(" + nDevMapDevPtr + ")\nPhysicalDevPtr=" + \nPhysicalDevPtr)
          EndIf
          debugMsg(sProcName, "(v9) bRetryFromStart=" + strB(bRetryFromStart) + ", \nPhysicalDevPtr=" + \nPhysicalDevPtr)
          If \nPhysicalDevPtr >= 0
            \sPhysicalDev = gaVideoAudioDev(\nPhysicalDevPtr)\sVidAudName
            \bDummy = #False
            \nFirst1BasedOutputChan = nLastVidAudOutputUsed + 1
            \s1BasedOutputRange = build1BasedOutputRangeString(\nFirst1BasedOutputChan, \nNrOfDevOutputChans, \nPhysicalDevPtr)
            nLastVidAudOutputUsed + \nNrOfDevOutputChans
          Else
            \sPhysicalDev = ""
            \bDummy = #False
          EndIf
          debugMsg(sProcName, "(v10) grMapsForDevChgs\aDev(" + nDevMapDevPtr + ")\sLogicalDev=" + \sLogicalDev + ", \sPhysicalDev=" + \sPhysicalDev + ", \nFirstOutputChan=" + \nFirst1BasedOutputChan + ", \s1BasedOutputRange=" + \s1BasedOutputRange)
          ;}
          
        Case #SCS_DEVTYPE_VIDEO_CAPTURE  ; #SCS_DEVTYPE_VIDEO_CAPTURE
          ;{
          nVidCaps = 0
          nVidCapPhysPtr = -1
          If nLastPhysicalDevPtrForThisDevType >= 0
            ; find where this physical device is in the list of physical devices
            For nVidCapPhysPtr = 0 To (gnNumVideoCaptureDevs-1)
              If nVidCapPhysPtr = nLastPhysicalDevPtrForThisDevType
                Break
              EndIf
            Next nVidCapPhysPtr
            debugMsg(sProcName, "(vc1) bRetryFromStart=" + strB(bRetryFromStart) + ", nVidCapPhysPtr=" + nVidCapPhysPtr + ", gnNumVideoCaptureDevs=" + gnNumVideoCaptureDevs)
          EndIf
          nVidCapPhysPtr + 1
          If (nVidCapPhysPtr + 1) > gnNumVideoCaptureDevs
            ; we've run out of physical devices
            If bRetryFromStart = #False
              debugMsg(sProcName, "(vc2) run out of physical devices - retry from start")
              bRetryFromStart = #True
              Continue
            Else
              \nPhysicalDevPtr = -1
            EndIf
          Else
            \nPhysicalDevPtr = nVidCapPhysPtr
            debugMsg(sProcName, "(vc3) grMapsForDevChgs\aDev(" + nDevMapDevPtr + ")\nPhysicalDevPtr=" + \nPhysicalDevPtr)
          EndIf
          debugMsg(sProcName, "(vc4) bRetryFromStart=" + strB(bRetryFromStart) + ", \nPhysicalDevPtr=" + \nPhysicalDevPtr)
          If \nPhysicalDevPtr >= 0
            \sPhysicalDev = gaVideoCaptureDev(\nPhysicalDevPtr)\sVidCapName
            \bDummy = #False
          Else
            \sPhysicalDev = ""
            \bDummy = #False
          EndIf
          debugMsg(sProcName, "(vc5) grMapsForDevChgs\aDev(" + nDevMapDevPtr + ")\sLogicalDev=" + \sLogicalDev + ", \sPhysicalDev=" + \sPhysicalDev)
          ;}
          
        Case #SCS_DEVTYPE_CS_MIDI_OUT  ; #SCS_DEVTYPE_CS_MIDI_OUT
          ;{
          nPhysicalDevPtrNew = getNextMidiDevice(#False, nLastPhysCtrlSendPtr)
          CheckSubInRange(nPhysicalDevPtrNew, ArraySize(gaMidiOutDevice()), "gaMidiOutDevice(), gnNumMidiOutDevs=" + gnNumMidiOutDevs)
          \sPhysicalDev = gaMidiOutDevice(nPhysicalDevPtrNew)\sName
          \nPhysicalDevPtr = nPhysicalDevPtrNew
          \bDummy = gaMidiOutDevice(nPhysicalDevPtrNew)\bDummy
          debugMsg(sProcName, "grMapsForDevChgs\aDev(" + nDevMapDevPtr + ")\sLogicalDev=" + \sLogicalDev + ", \sPhysicalDev=" + \sPhysicalDev + ", \nPhysicalDevPtr=" + \nPhysicalDevPtr)
          ;}
          
        Case #SCS_DEVTYPE_CC_MIDI_IN  ; #SCS_DEVTYPE_CC_MIDI_IN
          ;{
          nPhysicalDevPtrNew = getNextMidiDevice(#True, nLastPhysCtrlSendPtr)
          CheckSubInRange(nPhysicalDevPtrNew, ArraySize(gaMidiInDevice()), "gaMidiInDevice(), gnNumMidiInDevs=" + gnNumMidiInDevs)
          \sPhysicalDev = gaMidiInDevice(nPhysicalDevPtrNew)\sName
          ; \nMidiInPhysicalDevPtr = getMidiInPhysicalDevPtr(\sPhysicalDev, \bDummy)
          \nPhysicalDevPtr = nPhysicalDevPtrNew
          \bDummy = gaMidiInDevice(nPhysicalDevPtrNew)\bDummy
          debugMsg(sProcName, "grMapsForDevChgs\aDev(" + nDevMapDevPtr + ")\sLogicalDev=" + \sLogicalDev + ", \sPhysicalDev=" + \sPhysicalDev + ", \nPhysicalDevPtr=" + \nPhysicalDevPtr)
          ;}
          
        Case #SCS_DEVTYPE_CS_MIDI_THRU  ; #SCS_DEVTYPE_CS_MIDI_THRU
          ;{
          nPhysicalDevPtrNew = getNextMidiDevice(#False, nLastPhysCtrlSendPtr)
          CheckSubInRange(nPhysicalDevPtrNew, ArraySize(gaMidiOutDevice()), "gaMidiOutDevice(), gnNumMidiOutDevs=" + gnNumMidiOutDevs)
          \sPhysicalDev = gaMidiOutDevice(nPhysicalDevPtrNew)\sName
          \nPhysicalDevPtr = nPhysicalDevPtrNew
          \bDummy = gaMidiOutDevice(nPhysicalDevPtrNew)\bDummy
          debugMsg(sProcName, "grMapsForDevChgs\aDev(" + nDevMapDevPtr + ")\sLogicalDev=" + \sLogicalDev + ", \sPhysicalDev=" + \sPhysicalDev + ", \nPhysicalDevPtr=" + \nPhysicalDevPtr)
          nPhysicalDevPtrNew = getNextMidiDevice(#True, nLastPhysCtrlSendPtr)
          CheckSubInRange(nPhysicalDevPtrNew, ArraySize(gaMidiInDevice()), "gaMidiInDevice(), gnNumMidiInDevs=" + gnNumMidiInDevs)
          \sMidiThruInPhysicalDev = gaMidiInDevice(nPhysicalDevPtrNew)\sName
          \bMidiThruInDummy = gaMidiInDevice(nPhysicalDevPtrNew)\bDummy
          \nMidiThruInPhysicalDevPtr = getMidiInPhysicalDevPtr(\sMidiThruInPhysicalDev, \bMidiThruInDummy)
          debugMsg(sProcName, "grMapsForDevChgs\aDev(" + nDevMapDevPtr + ")\sMidiThruInPhysicalDev=" + \sMidiThruInPhysicalDev + ", \nMidiThruInPhysicalDevPtr=" + \nMidiThruInPhysicalDevPtr)
          ;}
          
        Case #SCS_DEVTYPE_CS_RS232_OUT, #SCS_DEVTYPE_CC_RS232_IN   ; #SCS_DEVTYPE_CS_RS232_OUT, #SCS_DEVTYPE_CC_RS232_IN
          ;{
          nPhysicalDevPtrNew = nLastPhysCtrlSendPtr + 1
          If nPhysicalDevPtrNew > gnMaxRS232Control
            nPhysicalDevPtrNew = gnMaxRS232Control
          EndIf
          CheckSubInRange(nPhysicalDevPtrNew, ArraySize(gaRS232Control()), "gaRS232Control()")
          \sPhysicalDev = gaRS232Control(nPhysicalDevPtrNew)\sRS232PortAddress
          \nPhysicalDevPtr = nPhysicalDevPtrNew
          \bDummy = gaRS232Control(nPhysicalDevPtrNew)\bDummy
          debugMsg(sProcName, "grMapsForDevChgs\aDev(" + nDevMapDevPtr + ")\sLogicalDev=" + \sLogicalDev + ", \sPhysicalDev=" + \sPhysicalDev + ", \nPhysicalDevPtr=" + \nPhysicalDevPtr)
          Select nDevType
            Case #SCS_DEVTYPE_CC_RS232_IN
              gaRS232Control(nPhysicalDevPtrNew)\bRS232In = #True
            Case #SCS_DEVTYPE_CS_RS232_OUT
              gaRS232Control(nPhysicalDevPtrNew)\bRS232Out = #True
          EndSelect
          debugMsg(sProcName, "nDevType=" + decodeDevType(nDevType) +
                              ", gaRS232Control(" + nPhysicalDevPtrNew + ")\bRS232In=" + strB(gaRS232Control(nPhysicalDevPtrNew)\bRS232In) +
                              ", gaRS232Control(" + nPhysicalDevPtrNew + ")\bRS232Out=" + strB(gaRS232Control(nPhysicalDevPtrNew)\bRS232Out))
          ;}
          
        Case #SCS_DEVTYPE_CS_NETWORK_OUT, #SCS_DEVTYPE_CC_NETWORK_IN  ; #SCS_DEVTYPE_CS_NETWORK_OUT, #SCS_DEVTYPE_CC_NETWORK_IN
          ;{
          ; create a new entry in gaNetworkControl() array
          debugMsg(sProcName, "calling getBlankNetworkControlEntry()")
          nPhysicalDevPtrNew = getBlankNetworkControlEntry()
          CheckSubInRange(nPhysicalDevPtrNew, ArraySize(gaNetworkControl()), "gaNetworkControl()")
          gaNetworkControl(nPhysicalDevPtrNew)\bControlExists = #True
          gaNetworkControl(nPhysicalDevPtrNew)\nDevMapId = nDevMapId
          gaNetworkControl(nPhysicalDevPtrNew)\nDevMapDevPtr = nDevMapDevPtr
          gaNetworkControl(nPhysicalDevPtrNew)\nDevType = nDevType
          gaNetworkControl(nPhysicalDevPtrNew)\nDevNo = nDevNo
          gaNetworkControl(nPhysicalDevPtrNew)\bNWDummy = \bDummy
          gaNetworkControl(nPhysicalDevPtrNew)\bNWIgnoreDevThisRun = \bIgnoreDevThisRun ; added 16Mar2020 11.8.2.3aa
          gaNetworkControl(nPhysicalDevPtrNew)\sRemoteHost = \sRemoteHost
          gaNetworkControl(nPhysicalDevPtrNew)\nRemotePort = \nRemotePort
          gaNetworkControl(nPhysicalDevPtrNew)\nLocalPort = \nLocalPort
          gaNetworkControl(nPhysicalDevPtrNew)\nCtrlSendDelay = \nCtrlSendDelay
          buildNetworkDevDesc(@gaNetworkControl(nPhysicalDevPtrNew))
          debugMsg(sProcName, "gaNetworkControl(" + nPhysicalDevPtrNew + ")\sNetworkDevDesc=" + gaNetworkControl(nPhysicalDevPtrNew)\sNetworkDevDesc)
          \sPhysicalDev = gaNetworkControl(nPhysicalDevPtrNew)\sNetworkDevDesc
          \nPhysicalDevPtr = nPhysicalDevPtrNew
          \bDummy = gaNetworkControl(nPhysicalDevPtrNew)\bNWDummy
          \bIgnoreDevThisRun = gaNetworkControl(nPhysicalDevPtrNew)\bNWIgnoreDevThisRun ; added 16Mar2020 11.8.2.3aa
          \nCtrlSendDelay = gaNetworkControl(nPhysicalDevPtrNew)\nCtrlSendDelay
          debugMsg(sProcName, "grMapsForDevChgs\aDev(" + nDevMapDevPtr + ")\sLogicalDev=" + \sLogicalDev + ", \sPhysicalDev=" + \sPhysicalDev + ", \nPhysicalDevPtr=" + \nPhysicalDevPtr)
          ;}
          
        Case #SCS_DEVTYPE_CC_DMX_IN, #SCS_DEVTYPE_LT_DMX_OUT  ; #SCS_DEVTYPE_CC_DMX_IN, #SCS_DEVTYPE_LT_DMX_OUT
          ;{
          debugMsg(sProcName, decodeDevType(nDevType))
          debugMsg(sProcName, "nLastPhysicalDevPtrForThisDevType=" + nLastPhysicalDevPtrForThisDevType + ", grDMX\nNumDMXDevs=" + grDMX\nNumDMXDevs)
          nPhysicalDevPtrNew = nLastPhysicalDevPtrForThisDevType + 1
          If nPhysicalDevPtrNew > (grDMX\nNumDMXDevs - 1)
            nPhysicalDevPtrNew = (grDMX\nNumDMXDevs - 1)
          EndIf
          CheckSubInRange(nPhysicalDevPtrNew, ArraySize(gaDMXDevice()), "gaDMXDevice()")
          \sPhysicalDev = gaDMXDevice(nPhysicalDevPtrNew)\sName
          \nDMXSerial = gaDMXDevice(nPhysicalDevPtrNew)\nSerial
          \sDMXSerial = gaDMXDevice(nPhysicalDevPtrNew)\sSerial
          \nDMXPorts = gaDMXDevice(nPhysicalDevPtrNew)\nDMXPorts
          \nPhysicalDevPtr = nPhysicalDevPtrNew
          \bDummy = gaDMXDevice(nPhysicalDevPtrNew)\bDummy
          ; Added 11Aug2022 11.10.0
          If \nPhysicalDevPtr >= 0 Or \bDummy
            \nDevState = #SCS_DEVSTATE_ACTIVE
          Else
            \nDevState = #SCS_DEVSTATE_INACTIVE
          EndIf
          ; End added 11Aug2022 11.10.0
          ; Added 20Jun2023 11.10.0be
          If nDevType = #SCS_DEVTYPE_LT_DMX_OUT
            \nMaxDevFixture = -1
          EndIf
          ; End added 20Jun2023 11.10.0be
          debugMsg(sProcName, "grMapsForDevChgs\aDev(" + nDevMapDevPtr + ")\sLogicalDev=" + \sLogicalDev + ", \sPhysicalDev=" + \sPhysicalDev +
                              ", \nDMXSerial=" + \nDMXSerial + ", \sDMXSerial=" + \sDMXSerial + ", \nDMXPorts=" + \nDMXPorts +
                              ", \nPhysicalDevPtr=" + \nPhysicalDevPtr + ", \bDummy=" + strB(\bDummy) + ", \nDevState=" + decodeDevState(\nDevState))
          ;}
          
        Case #SCS_DEVTYPE_CS_HTTP_REQUEST  ; #SCS_DEVTYPE_CS_HTTP_REQUEST
          ;{
          debugMsg(sProcName, "HTTP Request")
          grHTTPControl\bExists = #True
          grHTTPControl\nDevMapId = nDevMapId
          grHTTPControl\nDevType = nDevType
          buildHTTPDevDesc(@grHTTPControl)
          \sPhysicalDev = grHTTPControl\sHTTPDevDesc
          \nPhysicalDevPtr = 0
          \bDummy = #False
          debugMsg(sProcName, "grMapsForDevChgs\aDev(" + nDevMapDevPtr + ")\sLogicalDev=" + \sLogicalDev + ", \sPhysicalDev=" + \sPhysicalDev + ", \nPhysicalDevPtr=" + \nPhysicalDevPtr)
          ;}
          
        Case #SCS_DEVTYPE_LIVE_INPUT  ; #SCS_DEVTYPE_LIVE_INPUT
          ;{
          debugMsg(sProcName, "calling buildSortedInitializedAudDevsArray()")
          buildSortedInitializedAudDevsArray()
          If nLastPhysicalDevPtrForThisDevType >= 0 ; nb "nLastPhysicalDevPtrForThisDevType" is correct for live inputs as the inputs are SoundMan-Server (audio driver) inputs
            nLiveInputs = gaAudioDev(nLastPhysicalDevPtrForThisDevType)\nInputs ; nb "gaAudioDev" is correct for live inputs as the inputs are SoundMan-Server (audio driver) inputs
            debugMsg(sProcName, "bRetryFromStart=" + strB(bRetryFromStart) + ", gaAudioDev(" + nLastPhysicalDevPtrForThisDevType + ")\sDesc=" + gaAudioDev(nLastPhysicalDevPtrForThisDevType)\sDesc + ", nLiveInputs=" + nLiveInputs)
            If bRetryFromStart = #False
              d = grMapsForDevChgs\aMap(nDevMapPtr)\nFirstDevIndex
              While d >= 0
                If grMapsForDevChgs\aDev(d)\nDevType = nDevType And grMapsForDevChgs\aDev(d)\bExists
                  If Len(grMapsForDevChgs\aDev(d)\sLogicalDev) > 0 And grMapsForDevChgs\aDev(d)\nPhysicalDevPtr = nLastPhysicalDevPtrForThisDevType
                    If grMapsForDevChgs\aDev(d)\nFirst1BasedInputChan > nLastLiveInputUsed
                      nLastLiveInputUsed = grMapsForDevChgs\aDev(d)\nFirst1BasedInputChan
                    EndIf
                  EndIf
                EndIf
                d = grMapsForDevChgs\aDev(d)\nNextDevIndex
              Wend
            EndIf
            debugMsg(sProcName, "bRetryFromStart=" + strB(bRetryFromStart) + ", nLastLiveInputUsed=" + nLastLiveInputUsed)
            ; find where this physical device is in the sorted list of physical devices
            For nSortedPhysPtr = 0 To (gnSortedInitializedDevs-1)
              If gaAudioInitializedDevSorted(nSortedPhysPtr)\nAudioDriver = gnCurrAudioDriver And gaAudioInitializedDevSorted(nSortedPhysPtr)\nPhysDevPtr = nLastPhysicalDevPtrForThisDevType
                Break
              EndIf
            Next nSortedPhysPtr
            debugMsg(sProcName, "bRetryFromStart=" + strB(bRetryFromStart) + ", nSortedPhysPtr=" + nSortedPhysPtr + ", gnSortedInitializedDevs=" + gnSortedInitializedDevs)
          EndIf
          
          If (nLastLiveInputUsed + 1) > nLiveInputs Or nLastPhysicalDevPtrForThisDevType = -1
            debugMsg(sProcName, "bRetryFromStart=" + strB(bRetryFromStart) + ", nLastLiveInputUsed=" + nLastLiveInputUsed + ", nLiveInputs=" + nLiveInputs + ", nSortedPhysPtr=" + nSortedPhysPtr)
            ; insufficient remaining Inputs on the current device (or this is the first time) so go to the next device
            nSortedPhysPtr + 1
            nLastLiveInputUsed = 0
            If (nSortedPhysPtr + 1) > gnSortedInitializedDevs
              ; we've run out of physical devices
              If bRetryFromStart = #False
                debugMsg(sProcName, "run out of physical devices - retry from start")
                bRetryFromStart = #True
                Continue
              Else
                \nPhysicalDevPtr = -1
                nLiveInputs = 0
              EndIf
            Else
              \nPhysicalDevPtr = gaAudioInitializedDevSorted(nSortedPhysPtr)\nPhysDevPtr
              debugMsg(sProcName, "grMapsForDevChgs\aDev(" + nDevMapDevPtr + ")\nPhysicalDevPtr=" + \nPhysicalDevPtr)
              nLiveInputs = gaAudioDev(\nPhysicalDevPtr)\nInputs ; nb "gaAudioDev" is correct for live inputs as the inputs are SoundMan-Server (audio driver) inputs
            EndIf
          Else
            \nPhysicalDevPtr = nLastPhysicalDevPtrForThisDevType
            debugMsg(sProcName, "grMapsForDevChgs\aDev(" + nDevMapDevPtr + ")\nPhysicalDevPtr=" + \nPhysicalDevPtr)
          EndIf
          debugMsg(sProcName, "bRetryFromStart=" + strB(bRetryFromStart) + ", \nPhysicalDevPtr=" + \nPhysicalDevPtr)
          If \nPhysicalDevPtr >= 0
            \sPhysicalDev = gaAudioDev(\nPhysicalDevPtr)\sDesc ; nb "gaAudioDev" is correct for live inputs as the inputs are SoundMan-Server (audio driver) inputs
            \bDummy = gaAudioDev(\nPhysicalDevPtr)\bDummy
            \nFirst0BasedInputChan = nLastLiveInputUsed
            \nFirst1BasedInputChan = nLastLiveInputUsed + 1
            nLastLiveInputUsed + 1
          Else
            \sPhysicalDev = ""
            \bDummy = #False
          EndIf
          debugMsg(sProcName, "grMapsForDevChgs\aDev(" + nDevMapDevPtr + ")\sLogicalDev=" + \sLogicalDev + ", \sPhysicalDev=" + \sPhysicalDev + ", \nFirst1BasedInputChan=" + \nFirst1BasedInputChan)
          ;}
          
      EndSelect
      
    EndWith
    Break
  Wend
  
  Select nDevType
    Case #SCS_DEVTYPE_CC_NETWORK_IN, #SCS_DEVTYPE_CS_NETWORK_OUT
      debugMsg(sProcName, "calling setDerivedNetworkFields()")
      setDerivedNetworkFields()
      debugMsg(sProcName, "calling setUseNetworkControlPtrs()")
      setUseNetworkControlPtrs()
      debugMsg(sProcName, "calling setX32CueControl()")
      setX32CueControl()
  EndSelect
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure countAudioOutputsRequested(*prProd.tyProd)
  PROCNAMEC()
  Protected nOutputsRequested, d, n, m
  Protected Dim aOutputRequested.tyOutputRequested(0)
  Protected nPhysicalDevPtr, nFirst1BasedOutputChan, nNrOfOutputChans
  Protected nOutputChan, bFound
  
  debugMsg(sProcName, #SCS_START)
  
  ReDim aOutputRequested(grLicInfo\nMaxAudioOutputs)
  
  For d = 0 To *prProd\nMaxAudioLogicalDev ; #SCS_MAX_AUDIO_DEV_PER_PROD ; Changed 15Dec2022 11.10.0ac
    nPhysicalDevPtr = *prProd\aAudioLogicalDevs(d)\nPhysicalDevPtr
    If nPhysicalDevPtr >= 0
      ;- to be done (used in 'add multi dev')
      ; following line commented out when nFirst1BasedOutputChan removed from structure tyAudioLogicalDevs
      ; need to do something to replace this code
      ; nFirst1BasedOutputChan = *prProd\aAudioLogicalDevs(d)\nFirst1BasedOutputChan
      nNrOfOutputChans = *prProd\aAudioLogicalDevs(d)\nNrOfOutputChans
      For n = 1 To nNrOfOutputChans
        nOutputChan = nFirst1BasedOutputChan + n - 1
        ;debugMsg(sProcName, "checking for nPhysicalDevPtr=" + nPhysicalDevPtr + ", nOutputChan=" + nOutputChan)
        bFound = #False
        For m = 0 To (nOutputsRequested - 1)
          CheckSubInRange(m, ArraySize(aOutputRequested()), "aOutputRequested(), nOutputsRequested=" + nOutputsRequested)
          If aOutputRequested(m)\nPhysicalDevPtr = nPhysicalDevPtr And aOutputRequested(m)\nOutputChan = nOutputChan
            bFound = #True
            Break
          EndIf
        Next m
        ;debugMsg(sProcName, "bFound=" + bFound)
        If bFound = #False
          nOutputsRequested + 1
          If (nOutputsRequested - 1) > ArraySize(aOutputRequested())
            ReDim aOutputRequested(nOutputsRequested + 20)
          EndIf
          aOutputRequested(nOutputsRequested - 1)\nPhysicalDevPtr = nPhysicalDevPtr
          aOutputRequested(nOutputsRequested - 1)\nOutputChan = nOutputChan
        EndIf
      Next n
    EndIf
  Next d
  
  ReDim aOutputRequested(0)
  
  debugMsg(sProcName, "nOutputsRequested=" + nOutputsRequested)
  ProcedureReturn nOutputsRequested
EndProcedure

Procedure listDevMap(*rDevMap.tyDevMap, Array aDevMapDev.tyDevMapDev(1), sDevMapArray.s)  ; (1) means array supports 1 dimension
  PROCNAMEC()
  Protected d, n, m, nDevNo
  
  With *rDevMap
    debugMsg(sProcName, #SCS_START + ", sDevMapArray=" + sDevMapArray + ", \sDevMapName=" + \sDevMapName + " <<<<")
    debugMsg(sProcName, "\nDevMapId=" + \nDevMapId + ", \bNewDevMap=" + strB(\bNewDevMap) + ", \nFirstDevIndex=" + \nFirstDevIndex + ", \nAudioDriver=" + decodeDriver(\nAudioDriver))
  EndWith
  
  ; debugMsg(sProcName, "grMapsForDevChgs\nMaxDevIndex=" + grMapsForDevChgs\nMaxDevIndex)
  d = *rDevMap\nFirstDevIndex
  While d >= 0
    CheckSubInRange(d, ArraySize(aDevMapDev()), *rDevMap\sDevMapName + ", nDevno=" + nDevNo)
    With aDevMapDev(d)
      If \nDevGrp = #SCS_DEVGRP_EXT_CONTROLLER ; Added 18Jun2022 11.9.4
        debugMsg(sProcName, "d=" + d + ", \nDevMapId=" + \nDevMapId + ", \nDevGrp=" + decodeDevGrp(\nDevGrp) + ", \nDevType=" + decodeDevType(\nDevType) + ", \bExists=" + strB(\bExists) +
                            ", \sLogicalDev=" + \sLogicalDev + ", \sPhysicalDev=" + \sPhysicalDev + ", \nPhysicalDevPtr=" + \nPhysicalDevPtr +
                            ", \bIgnoreDevThisRun=" + strB(\bIgnoreDevThisRun))
      Else
        Select \nDevType
          Case #SCS_DEVTYPE_AUDIO_OUTPUT
            debugMsg(sProcName, "d=" + d + ", \nDevMapId=" + \nDevMapId + ", \nDevGrp=" + decodeDevGrp(\nDevGrp) + ", \nDevType=" + decodeDevType(\nDevType) + ", \bExists=" + strB(\bExists) +
                                ", \sLogicalDev=" + \sLogicalDev + ", \sPhysicalDev=" + \sPhysicalDev + ", \bDefaultDev=" + strB(\bDefaultDev) + ", \nPhysicalDevPtr=" + \nPhysicalDevPtr +
                                ", \nNrOfDevOutputChans=" + \nNrOfDevOutputChans + ", \s1BasedOutputRange=" + \s1BasedOutputRange + ", \bIgnoreDevThisRun=" + strB(\bIgnoreDevThisRun))
            debugMsg(sProcName, "... \nBassDevice=" + \nBassDevice + ", \bBassASIO=" + strB(\bBassASIO) + ", \nBassASIODevice=" + \nBassASIODevice + ", \nDevId=" + \nDevId + ", \nDevState=" + decodeDevState(\nDevState))
            debugMsg(sProcName, "... \nMixerStreamPtr=" + \nMixerStreamPtr + ", \nFirst0BasedInputChan=" + \nFirst0BasedInputChan)
            
          Case #SCS_DEVTYPE_VIDEO_AUDIO
            debugMsg(sProcName, "d=" + d + ", \nDevMapId=" + \nDevMapId + ", \nDevGrp=" + decodeDevGrp(\nDevGrp) + ", \nDevType=" + decodeDevType(\nDevType) + ", \bExists=" + strB(\bExists) +
                                ", \sLogicalDev=" + \sLogicalDev + ", \sPhysicalDev=" + \sPhysicalDev + ", \bDefaultDev=" + strB(\bDefaultDev) + ", \nPhysicalDevPtr=" + \nPhysicalDevPtr +
                                ", \nNrOfDevOutputChans=" + \nNrOfDevOutputChans + ", \s1BasedOutputRange=" + \s1BasedOutputRange + ", \bIgnoreDevThisRun=" + strB(\bIgnoreDevThisRun))
            debugMsg(sProcName, "... \nDevId=" + \nDevId + ", \sDevOutputGainDB=" + \sDevOutputGainDB + ", \nDevState=" + decodeDevState(\nDevState))
            
          Case #SCS_DEVTYPE_VIDEO_CAPTURE
            debugMsg(sProcName, "d=" + d + ", \nDevMapId=" + \nDevMapId + ", \nDevGrp=" + decodeDevGrp(\nDevGrp) + ", \nDevType=" + decodeDevType(\nDevType) + ", \bExists=" + strB(\bExists) +
                                ", \sLogicalDev=" + \sLogicalDev + ", \sPhysicalDev=" + \sPhysicalDev + ", \nDevId=" + \nDevId + ", \nPhysicalDevPtr=" + \nPhysicalDevPtr +
                                ", \sVidCapFormat=" + \sVidCapFormat + ", \dVidCapFrameRate=" + \dVidCapFrameRate + ", \bIgnoreDevThisRun=" + strB(\bIgnoreDevThisRun))
            
          Case #SCS_DEVTYPE_LIVE_INPUT
            debugMsg(sProcName, "d=" + d + ", \nDevMapId=" + \nDevMapId + ", \nDevGrp=" + decodeDevGrp(\nDevGrp) + ", \nDevType=" + decodeDevType(\nDevType) + ", \bExists=" + strB(\bExists) +
                                ", \sLogicalDev=" + \sLogicalDev + ", \sPhysicalDev=" + \sPhysicalDev + ", \nPhysicalDevPtr=" + \nPhysicalDevPtr + ", \bDummy=" + strB(\bDummy) +
                                ", \nNrOfInputChans=" + \nNrOfInputChans + ", \nFirst1BasedInputChan=" + \nFirst1BasedInputChan + ", \nDevState=" + decodeDevState(\nDevState))
            debugMsg(sProcName, "... \nDevId=" + \nDevId + ", \sInputGainDB=" + \sInputGainDB + ", \bInputLowCutSelected=" + strB(\bInputLowCutSelected) +
                                ", \nInputLowCutFreq=" + \nInputLowCutFreq + ", \bIgnoreDevThisRun=" + strB(\bIgnoreDevThisRun))
            For n = 0 To #SCS_MAX_EQ_BAND
              debugMsg(sProcName, "... \aInputEQBand[" + n + "]\bEQBandSelected=" + strB(\aInputEQBand[n]\bEQBandSelected) + ", \sEQGainDB=" + \aInputEQBand[n]\sEQGainDB +
                                  ", \nEQFreq=" + \aInputEQBand[n]\nEQFreq +  ", \fEQQ=" + StrF(\aInputEQBand[n]\fEQQ,1))
            Next n
            
          Case #SCS_DEVTYPE_CC_MIDI_IN
            debugMsg(sProcName, "d=" + d + ", \nDevMapId=" + \nDevMapId + ", \nDevGrp=" + decodeDevGrp(\nDevGrp) + ", \nDevType=" + decodeDevType(\nDevType) + ", \bExists=" + strB(\bExists) +
                                ", \sLogicalDev=" + \sLogicalDev + ", \sPhysicalDev=" + \sPhysicalDev + ", \nPhysicalDevPtr=" + \nPhysicalDevPtr +
                                ", \nCtrlMethod=" + decodeCtrlMethod(\nCtrlMethodx) + ", \bIgnoreDevThisRun=" + strB(\bIgnoreDevThisRun))
            For n = 0 To #SCS_MAX_MIDI_COMMAND
              If \aMidiCommandx[n]\nCmd >= 0
                debugMsg(sProcName, ".. aMidiCommand[" + n + "]\nCmd=$" + Hex(\aMidiCommandx[n]\nCmd) + ", \nCC=" + \aMidiCommandx[n]\nCC + ", \nVV=" + \aMidiCommandx[n]\nVV)
              EndIf
            Next n
            
          Case #SCS_DEVTYPE_CS_MIDI_OUT
            debugMsg(sProcName, "d=" + d + ", \nDevMapId=" + \nDevMapId + ", \nDevGrp=" + decodeDevGrp(\nDevGrp) + ", \nDevType=" + decodeDevType(\nDevType) + ", \bExists=" + strB(\bExists) +
                                ", \sLogicalDev=" + \sLogicalDev + ", \sPhysicalDev=" + \sPhysicalDev +
                                ", \nPhysicalDevPtr=" + \nPhysicalDevPtr + ", \nDevId=" + \nDevId + ", \nDevState=" + decodeDevState(\nDevState) + ", \bIgnoreDevThisRun=" + strB(\bIgnoreDevThisRun))
            
          Case #SCS_DEVTYPE_CC_DMX_IN
            debugMsg(sProcName, "d=" + d + ", \nDevMapId=" + \nDevMapId + ", \nDevGrp=" + decodeDevGrp(\nDevGrp) + ", \nDevType=" + decodeDevType(\nDevType) + ", \bExists=" + strB(\bExists) +
                                ", \sLogicalDev=" + \sLogicalDev + ", \sPhysicalDev=" + \sPhysicalDev +
                                ", \nDMXSerial=" + \nDMXSerial + ", \sDMXSerial=" + \sDMXSerial + ", \nDMXPorts=" + \nDMXPorts + ", \nDMXPort=" + \nDMXPort +
                                ", \nPhysicalDevPtr=" + \nPhysicalDevPtr + ", \nDevId=" + \nDevId + ", \nDevState=" + decodeDevState(\nDevState) + ", \bIgnoreDevThisRun=" + strB(\bIgnoreDevThisRun))
            
          Case #SCS_DEVTYPE_LT_DMX_OUT
            debugMsg(sProcName, "d=" + d + ", \nDevMapId=" + \nDevMapId + ", \nDevGrp=" + decodeDevGrp(\nDevGrp) + ", \nDevType=" + decodeDevType(\nDevType) + ", \bExists=" + strB(\bExists) +
                                ", \sLogicalDev=" + \sLogicalDev + ", \sPhysicalDev=" + \sPhysicalDev +
                                ", \nDMXSerial=" + \nDMXSerial + ", \sDMXSerial=" + \sDMXSerial + ", \nDMXPorts=" + \nDMXPorts + ", \nDMXPort=" + \nDMXPort +
                                ", \nPhysicalDevPtr=" + \nPhysicalDevPtr + ", \nDevId=" + \nDevId + ", \nDevState=" + decodeDevState(\nDevState) + ", \nMaxDevFixture=" + \nMaxDevFixture + ", \bIgnoreDevThisRun=" + strB(\bIgnoreDevThisRun))
            For m = 0 To \nMaxDevFixture
              If \aDevFixture(m)\nDevDMXStartChannel > 0
                debugMsg(sProcName, ".. \aDevFixture(" + m + ")\sDevFixtureCode=" + \aDevFixture(m)\sDevFixtureCode + ", \nDevDMXStartChannel=" + \aDevFixture(m)\nDevDMXStartChannel)
              Else
                debugMsg(sProcName, ".. \aDevFixture(" + m + ")\sDevFixtureCode=" + \aDevFixture(m)\sDevFixtureCode + ", \sDevDMXStartChannels=" + \aDevFixture(m)\sDevDMXStartChannels)
              EndIf
            Next m
            
          Case #SCS_DEVTYPE_CS_NETWORK_OUT
            debugMsg(sProcName, "d=" + d + ", \nDevMapId=" + \nDevMapId + ", \nDevGrp=" + decodeDevGrp(\nDevGrp) + ", \nDevType=" + decodeDevType(\nDevType) + ", \bExists=" + strB(\bExists) +
                                ", \sLogicalDev=" + \sLogicalDev + ", \sPhysicalDev=" + \sPhysicalDev +
                                ", \nPhysicalDevPtr=" + \nPhysicalDevPtr + ", \nDevId=" + \nDevId + ", \nDevState=" + decodeDevState(\nDevState))
            debugMsg(sProcName, "..  \nNetworkRole=" + decodeNetworkRole(\nNetworkRolex) +
                                ", \sRemoteHost=" + \sRemoteHost + ", \nRemotePort=" + \nRemotePort +
                                ", \nLocalPort=" + \nLocalPort +
                                ", \nCtrlSendDelay=" + \nCtrlSendDelay +
                                ", \bReplyMsgAddCR=" + strB(\bReplyMsgAddCRx) + ", \bReplyMsgAddLF=" + strB(\bReplyMsgAddLFx) +
                                ", \nMaxMsgResponse=" + Str(\nMaxMsgResponsex) + ", \bIgnoreDevThisRun=" + strB(\bIgnoreDevThisRun) +
                                ", \bConnectWhenReqd=" + strB(\bConnectWhenReqd)) ; Added 19Sep2022 11.9.6
            For m = 0 To #SCS_MAX_NETWORK_MSG_RESPONSE
              If \aMsgResponsex[m]\sReceiveMsg
                debugMsg(sProcName, ".. \aMsgResponse["+ m + "]\sReceiveMsg=" + \aMsgResponsex[m]\sReceiveMsg +
                                    ", \sComparisonMsg=" + \aMsgResponsex[m]\sComparisonMsg +
                                    ", \sReplyMsg=" + \aMsgResponsex[m]\sReplyMsg)
              EndIf
            Next m
            
          Case #SCS_DEVTYPE_CC_NETWORK_IN
            debugMsg(sProcName, "d=" + d + ", \nDevMapId=" + \nDevMapId + ", \nDevGrp=" + decodeDevGrp(\nDevGrp) + ", \nDevType=" + decodeDevType(\nDevType) + ", \bExists=" + strB(\bExists) +
                                ", \sLogicalDev=" + \sLogicalDev + ", \sPhysicalDev=" + \sPhysicalDev +
                                ", \nPhysicalDevPtr=" + \nPhysicalDevPtr + ", \nDevId=" + \nDevId + ", \nDevState=" + decodeDevState(\nDevState))
            debugMsg(sProcName, "..  \nNetworkRole=" + decodeNetworkRole(\nNetworkRolex) +
                                ", \sRemoteHost=" + \sRemoteHost + ", \nRemotePort=" + \nRemotePort +
                                ", \nLocalPort=" + \nLocalPort + ", \bIgnoreDevThisRun=" + strB(\bIgnoreDevThisRun))
            
          Case #SCS_DEVTYPE_CC_RS232_IN, #SCS_DEVTYPE_CS_RS232_OUT
            debugMsg(sProcName, "d=" + d + ", \nDevMapId=" + \nDevMapId + ", \nDevGrp=" + decodeDevGrp(\nDevGrp) + ", \nDevType=" + decodeDevType(\nDevType) + ", \bExists=" + strB(\bExists) +
                                ", \sLogicalDev=" + \sLogicalDev + ", \sPhysicalDev=" + \sPhysicalDev +
                                ", \nPhysicalDevPtr=" + \nPhysicalDevPtr + ", \nDevId=" + \nDevId + ", \nDevState=" + decodeDevState(\nDevState))
            debugMsg(sProcName, "..  \nRS232BaudRate=" + \nRS232BaudRatex +
                                ", \nRS232DataBits=" + \nRS232DataBitsx +
                                ", \fRS232StopBits=" + StrF(\fRS232StopBitsx,1) +
                                ", \nRS232Parity=" + \nRS232Parityx + ", \bIgnoreDevThisRun=" + strB(\bIgnoreDevThisRun))
            
          Case #SCS_DEVTYPE_NONE
            ; ignore
            
          Default
            debugMsg(sProcName, "d=" + d + ", \nDevMapId=" + \nDevMapId + ", \nDevGrp=" + decodeDevGrp(\nDevGrp) + ", \nDevType=" + decodeDevType(\nDevType) +
                                ", \bExists=" + strB(\bExists) + ", \sLogicalDev=" + \sLogicalDev +
                                ", \sPhysicalDev=" + \sPhysicalDev + ", \nPhysicalDevPtr=" + \nPhysicalDevPtr + ", \nDevId=" + \nDevId + ", \nDevState=" + decodeDevState(\nDevState) + ", \bIgnoreDevThisRun=" + strB(\bIgnoreDevThisRun))
            
        EndSelect
        d = \nNextDevIndex
        nDevNo + 1
      EndWith
    EndIf
  Wend
  
EndProcedure

Procedure summarizeDevMap(*rDevMap.tyDevMap, Array aDevMapDev.tyDevMapDev(1))  ; (1) means array supports 1 dimension
  PROCNAMEC()
  Protected d, n
  Protected nDevNo
  
  debugMsg(sProcName, "\sDevMapName=" + *rDevMap\sDevMapName + ", \nDevMapId=" + Str(*rDevMap\nDevMapId) + ", \bNewDevMap=" + strB(*rDevMap\bNewDevMap) +
                      ", \nAudioDriver=" + decodeDriver(*rDevMap\nAudioDriver))
  d = *rDevMap\nFirstDevIndex
  While d >= 0
    CheckSubInRange(d, ArraySize(aDevMapDev()), *rDevMap\sDevMapName + ", nDevno=" + nDevNo)
    With aDevMapDev(d)
      Select \nDevType
        Case #SCS_DEVTYPE_AUDIO_OUTPUT
          debugMsg(sProcName, "d=" + d + ", \nDevType=" + decodeDevType(\nDevType) + ", \sLogicalDev=" + \sLogicalDev + ", \sPhysicalDev=" + \sPhysicalDev +
                              ", \nNrOfDevOutputChans=" + \nNrOfDevOutputChans + ", \s1BasedOutputRange=" + \s1BasedOutputRange)
          
        Case #SCS_DEVTYPE_VIDEO_AUDIO
          debugMsg(sProcName, "d=" + d + ", \nDevType=" + decodeDevType(\nDevType) + ", \sLogicalDev=" + \sLogicalDev + ", \sPhysicalDev=" + \sPhysicalDev +
                              ", \nNrOfDevOutputChans=" + \nNrOfDevOutputChans + ", \s1BasedOutputRange=" + \s1BasedOutputRange)
          
        Case #SCS_DEVTYPE_LIVE_INPUT
          debugMsg(sProcName, "d=" + d + ", \nDevType=" + decodeDevType(\nDevType) + ", \sLogicalDev=" + \sLogicalDev + ", \sPhysicalDev=" + \sPhysicalDev +
                              ", \nFirst1BasedInputChan=" + Str(\nFirst1BasedInputChan))
          
        Case #SCS_DEVTYPE_CC_MIDI_IN, #SCS_DEVTYPE_CS_MIDI_OUT
          debugMsg(sProcName, "d=" + d + ", \nDevType=" + decodeDevType(\nDevType) + ", \sLogicalDev=" + \sLogicalDev + ", \sPhysicalDev=" + \sPhysicalDev)
          
        Case #SCS_DEVTYPE_CC_NETWORK_IN, #SCS_DEVTYPE_CS_NETWORK_OUT
          debugMsg(sProcName, "d=" + d + ", \nDevType=" + decodeDevType(\nDevType) + ", \sLogicalDev=" + \sLogicalDev +
                              ", \sRemoteHost=" + \sRemoteHost + ", \nRemotePort=" + \nRemotePort + ", \nLocalPort=" + \nLocalPort)
          
        Case #SCS_DEVTYPE_CC_DMX_IN, #SCS_DEVTYPE_LT_DMX_OUT
          debugMsg(sProcName, "d=" + d + ", \nDevType=" + decodeDevType(\nDevType) + ", \sLogicalDev=" + \sLogicalDev + ", \sPhysicalDev=" + \sPhysicalDev +
                              ", \nDMXSerial=" + \nDMXSerial + ", \sDMXSerial=" + \sDMXSerial)
          
        Case #SCS_DEVTYPE_NONE
          ; ignore
          
        Default
          debugMsg(sProcName, "d=" + d + ", \nDevType=" + decodeDevType(\nDevType) + ", \sLogicalDev=" + \sLogicalDev + ", \sPhysicalDev=" + \sPhysicalDev)
          
      EndSelect
      d = \nNextDevIndex
      nDevNo + 1
    EndWith
  Wend
  
EndProcedure

Procedure listAllDevMaps()
  PROCNAMEC()
  Protected n
  
  debugMsg(sProcName, #SCS_START)
  
  For n = 0 To grMaps\nMaxMapIndex
    debugMsg(sProcName, "------------ grMaps\aMap(" + n + ")\sDevMapName=" + grMaps\aMap(n)\sDevMapName)
    listDevMap(@grMaps\aMap(n), grMaps\aDev(), "grMaps\aMap()")
  Next n
  debugMsg(sProcName, "grMaps\sSelectedDevMapName=" + grMaps\sSelectedDevMapName)
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure listAllDevMapsForDevChgs()
  PROCNAMEC()
  Protected n
  
  debugMsg(sProcName, #SCS_START)
  
  For n = 0 To grMapsForDevChgs\nMaxMapIndex
    debugMsg(sProcName, "------------ grMapsForDevChgs\aMap(" + n + ")\sDevMapName=" + grMapsForDevChgs\aMap(n)\sDevMapName)
    listDevMap(@grMapsForDevChgs\aMap(n), grMapsForDevChgs\aDev(), "grMapsForDevChgs\aMap()")
  Next n
  debugMsg(sProcName, "grMapsForDevChgs\sSelectedDevMapName=" + grMapsForDevChgs\sSelectedDevMapName)
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure listAllDevMapsForImport()
  PROCNAMEC()
  Protected n
  
  debugMsg(sProcName, #SCS_START)
  
  For n = 0 To grMapsForImport\nMaxMapIndex
    debugMsg(sProcName, "------------ grMapsForImport\aMap(" + n + ")\sDevMapName=" + grMapsForImport\aMap(n)\sDevMapName)
    listDevMap(@grMapsForImport\aMap(n), grMapsForImport\aDev(), "grMapsForImport\aMap()")
  Next n
  debugMsg(sProcName, "grMapsForImport\sSelectedDevMapName=" + grMapsForImport\sSelectedDevMapName)
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure summarizeAllDevMaps()
  PROCNAMEC()
  Protected n
  
  debugMsg(sProcName, #SCS_START)
  
  For n = 0 To grMaps\nMaxMapIndex
    summarizeDevMap(@grMaps\aMap(n), grMaps\aDev())
  Next n
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure summarizeAllDevMapsForDevChgs()
  PROCNAMEC()
  Protected n
  
  debugMsg(sProcName, #SCS_START)
  
  For n = 0 To grMapsForDevChgs\nMaxMapIndex
    summarizeDevMap(@grMapsForDevChgs\aMap(n), grMapsForDevChgs\aDev())
  Next n
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure findValidDevMap(nDevMapPtr, sCueFile.s)
  PROCNAMEC()
  Protected nCheckDevMapResult
  Protected nValidDevMapPtr
  Protected sRequestedDevMap.s
  Protected sSelectedDevMap.s
  Protected nAudioDriverOfRequestedDevMap
  Protected sCheckDevMapMsg.s
  Protected sMsg.s
  Protected sTitle.s, sButtons.s
  Protected n, n2, nReply
  Protected sCueFilePart.s
  Protected sDevGrpsWithIssues.s
  Protected rDevMapCheckForMsg.tyDevMapCheck
  Protected sDevMap.s, sNewDevMapMsg.s
  
  debugMsg(sProcName, #SCS_START + ", nDevMapPtr=" + nDevMapPtr + ", sCueFile=" + GetFilePart(sCueFile))
  
  sCueFilePart = GetFilePart(sCueFile)
  sRequestedDevMap = getDevMapName(nDevMapPtr)
  nAudioDriverOfRequestedDevMap = grMaps\aMap(nDevMapPtr)\nAudioDriver
  debugMsg(sProcName, "sRequestedDevMap=" + sRequestedDevMap + ", nAudioDriverOfRequestedDevMap=" + decodeDriver(nAudioDriverOfRequestedDevMap))
  nValidDevMapPtr = -1
  
  rDevMapCheckForMsg = grDevMapCheckDef
  
  debugMsg(sProcName, "calling clearIgnoreDevThisRunInds()")
  clearIgnoreDevThisRunInds()
  
  While nValidDevMapPtr = -1
    gsCheckDevMapMsg = "" ; added 6Mar2020 11.8.2.2bc following bug reported by Stas Ushomirsky
    debugMsg(sProcName, "calling checkDevMap(" + sRequestedDevMap + ")")
    nCheckDevMapResult = checkDevMap(nDevMapPtr)
    debugMsg(sProcName, "checkDevMap(" + sRequestedDevMap + ") returned " + nCheckDevMapResult)
    debugMsg(sProcName, "nCheckDevMapResult=" + nCheckDevMapResult)
    rDevMapCheckForMsg = grDevMapCheck  ; hold for message (if message required)
    If nCheckDevMapResult = 0
      nValidDevMapPtr = nDevMapPtr
      Break
      
    ElseIf nCheckDevMapResult = #SCS_CLOSE_CUE_FILE  ; close cue file
      debugMsg(sProcName, "nCheckDevMapResult=#SCS_CLOSE_CUE_FILE")
      nValidDevMapPtr = nCheckDevMapResult
      gbCloseCueFile = #True
      gbKillSplashTimerEarly = #True
      Break
      
    ElseIf nCheckDevMapResult = #SCS_REVIEW_DEVMAP  ; review/change device map
      debugMsg(sProcName, "nCheckDevMapResult=#SCS_REVIEW_DEVMAP")
      nValidDevMapPtr = nCheckDevMapResult
      gbReviewDevMap = #True
      debugMsg(sProcName, "gbReviewDevMap=" + strB(gbReviewDevMap))
      gbKillSplashTimerEarly = #True
      Break
      
    Else
      debugMsg(sProcName, "other")
      sCheckDevMapMsg = gsCheckDevMapMsg  ; hold error message from main to checkDevMap
      debugMsg(sProcName, "sCheckDevMapMsg=" + sCheckDevMapMsg)
      For n = 0 To grMaps\nMaxMapIndex
        If n <> nDevMapPtr
          debugMsg(sProcName, "calling checkDevMap(" + getDevMapName(n) + ")")
          nCheckDevMapResult = checkDevMap(n)
          debugMsg(sProcName, "checkDevMap(" + getDevMapName(n) + ") returned " + nCheckDevMapResult)
          If nCheckDevMapResult = 0
            nValidDevMapPtr = n
            Break
          ElseIf nCheckDevMapResult = #SCS_CLOSE_CUE_FILE
            Break
          ElseIf nCheckDevMapResult = #SCS_REVIEW_DEVMAP
            Break
          EndIf
        EndIf
      Next n
      
      debugMsg(sProcName, "nCheckDevMapResult=" + nCheckDevMapResult)
      If nCheckDevMapResult = 0
        ; nValidDevMapPtr already set
        Break
        
      ElseIf nCheckDevMapResult = #SCS_CLOSE_CUE_FILE  ; close cue file
        debugMsg(sProcName, "nCheckDevMapResult=#SCS_CLOSE_CUE_FILE")
        nValidDevMapPtr = nCheckDevMapResult
        gbCloseCueFile = #True
        gbKillSplashTimerEarly = #True
        Break
        
      ElseIf nCheckDevMapResult = #SCS_REVIEW_DEVMAP  ; review/change device map
        debugMsg(sProcName, "nCheckDevMapResult=#SCS_REVIEW_DEVMAP")
        nValidDevMapPtr = nCheckDevMapResult
        gbReviewDevMap = #True
        debugMsg(sProcName, "gbReviewDevMap=" + strB(gbReviewDevMap))
        gbKillSplashTimerEarly = #True
        Break
        
      Else
        debugMsg(sProcName, "other")
        ensureSplashNotOnTop()
        setMouseCursorNormal()
        If Len(sCheckDevMapMsg) = 0
          sCheckDevMapMsg = LangPars("DevMap", "noValidDevMapFound", sCueFilePart)
          debugMsg(sProcName, "sCheckDevMapMsg=" + sCheckDevMapMsg)
        EndIf
        
        ; added 9Nov2015 11.4.1.2h
        sDevGrpsWithIssues = ""
        nCheckDevMapResult = 0 ; added 6Mar2020 11.8.2.2bc
        For n = #SCS_DEVGRP_FIRST To #SCS_DEVGRP_LAST
          If rDevMapCheckForMsg\bDevGrpIssue[n]
            sDevGrpsWithIssues + "||    " + UCase(decodeDevGrpL(n))  ; "||    " generates 2 newlines plus 4 spaces before each device group, in the SCS procedure OptionRequester()
            With rDevMapCheckForMsg
              For n2 = 0 To (\nCheckItemCount - 1)
                If \aCheckItem(n2)\nDevGrp = n
                  sDevGrpsWithIssues + "|        "
                  If n <> #SCS_DEVGRP_AUDIO_OUTPUT ; Test added 28Oct2024 11.10.6ax
                    If \aCheckItem(n2)\nDevId >= 0
                      sDevGrpsWithIssues + "* "
                    EndIf
                  EndIf
                  sDevGrpsWithIssues + \aCheckItem(n2)\sCheckMsg
                  ; added 6Mar2020 11.8.2.2bc
                  If nCheckDevMapResult <> -2 ; nb -2 (no physical device selected) takes priority regarding the buttons displayed by the call to OptionRequester() - see below
                    nCheckDevMapResult = \aCheckItem(n2)\nCheckResult
                  EndIf
                  ; end added 6Mar2020 11.8.2.2bc
                EndIf
              Next n2
            EndWith
          EndIf
        Next n
        If sDevGrpsWithIssues
          sCheckDevMapMsg = Lang("DevMap", "DevChgReqd") + sDevGrpsWithIssues
          debugMsg(sProcName, "sCheckDevMapMsg=" + sCheckDevMapMsg)
          grDevMapCheckForSetIgnoreDevInds = rDevMapCheckForMsg
          debugMsg(sProcName, "(c2) sCheckDevMapMsg=" + sCheckDevMapMsg + ", grDevMapCheckForSetIgnoreDevInds\nCheckItemCount=" + grDevMapCheckForSetIgnoreDevInds\nCheckItemCount)
        EndIf
        ; end added 9Nov2015 11.4.1.2h
        
        debugMsg(sProcName, "nCheckDevMapResult=" + nCheckDevMapResult + ", gbReviewDevMap=" + strB(gbReviewDevMap))
        If nCheckDevMapResult = -2 Or nCheckDevMapResult = #SCS_ASK_TO_REVIEW_DEVMAP
          ; no physical device selected, or ask to review device map
          sTitle = #SCS_TITLE + "|" + LangPars("DevMap", "checkingDevMap", sRequestedDevMap, sCueFilePart) +
                   "||" + sCheckDevMapMsg +
                   "||" + Lang("DevMap", "doWhat2") + "|"
          sButtons = Lang("DevMap", "chgDevMap") + "|" +
                     Lang("DevMap", "closeFile") + "|" +
                     Lang("DevMap", "CloseSCS")
          debugMsg(sProcName, sTitle)
          nReply = OptionRequester(0, 0, sTitle, sButtons, 200, #IDI_EXCLAMATION)
          debugMsg(sProcName, "nReply=" + Str(nReply))
          Select nReply
            Case 1  ; review/change device map
              nValidDevMapPtr = #SCS_REVIEW_DEVMAP
              ; Added 28Oct2024 11.10.6ax
              gbReviewDevMap = #True
              gbGoToProdPropDevices = #True
              debugMsg(sProcName, "gbReviewDevMap=" + strB(gbReviewDevMap) + ", gbGoToProdPropDevices=" + strB(gbGoToProdPropDevices))
              ; End added 28Oct2024 11.10.6ax
              gbKillSplashTimerEarly = #True
              Break
            Case 2  ; close cue file
              nValidDevMapPtr = #SCS_CLOSE_CUE_FILE
              gbKillSplashTimerEarly = #True
              Break
            Case 3  ; close SCS
              debugMsg(sProcName, "closing down")
              ; clearInitializingState()
              closeDown(#True)
              Debug "END OF RUN (in findValidDevMap())"
              End
          EndSelect
          
        ElseIf nCheckDevMapResult = -21
          ; Added 29Oct2024 11.10.6ay
          sTitle = #SCS_TITLE + "|" + LangPars("DevMap", "checkingDevMap", sRequestedDevMap, sCueFilePart) +
                   "||" + sCheckDevMapMsg +
                   "||" + Lang("DevMap", "doWhat2") + "|"
          sButtons = Lang("DevMap", "TryAgain") + "|" +
                     Lang("DevMap", "chgDevMap") + "|" +
                     Lang("DevMap", "closeFile") + "|" +
                     Lang("DevMap", "CloseSCS")
          debugMsg(sProcName, sTitle)
          nReply = OptionRequester(0, 0, sTitle, sButtons, 200, #IDI_EXCLAMATION)
          debugMsg(sProcName, "nReply=" + Str(nReply))
          Select nReply
            Case 1  ; try again
              debugMsg(sProcName, "calling reloadDevices(" + decodeDriver(nAudioDriverOfRequestedDevMap) + ")")
              reloadDevices(nAudioDriverOfRequestedDevMap)
              debugMsg(sProcName, "trying again")
              Continue
            Case 2  ; review/change device map
              nValidDevMapPtr = #SCS_REVIEW_DEVMAP
              gbReviewDevMap = #True
              gbGoToProdPropDevices = #True
              debugMsg(sProcName, "gbReviewDevMap=" + strB(gbReviewDevMap) + ", gbGoToProdPropDevices=" + strB(gbGoToProdPropDevices))
              gbKillSplashTimerEarly = #True
              Break
            Case 3  ; close cue file
              nValidDevMapPtr = #SCS_CLOSE_CUE_FILE
              gbKillSplashTimerEarly = #True
              Break
            Case 4  ; close SCS
              debugMsg(sProcName, "closing down")
              ; clearInitializingState()
              closeDown(#True)
              Debug "END OF RUN (in findValidDevMap())"
              End
          EndSelect
          ; End added 29Oct2024 11.10.6ay
          
        ElseIf nCheckDevMapResult = -3 And gbReviewDevMap
          ; Added 3Feb2025 11.10.6
          ; Already asked to review the device map
          nValidDevMapPtr = #SCS_REVIEW_DEVMAP
          ; gbReviewDevMap = #True
          gbGoToProdPropDevices = #True
          debugMsg(sProcName, "gbReviewDevMap=" + strB(gbReviewDevMap) + ", gbGoToProdPropDevices=" + strB(gbGoToProdPropDevices))
          gbKillSplashTimerEarly = #True
          Break
          ; End added 3Feb2025 11.10.6
          
        Else
          ; all other errors
          sTitle = #SCS_TITLE + "|" + LangPars("DevMap", "checkingDevMap", sRequestedDevMap, sCueFilePart) + "||" + sCheckDevMapMsg + "||" + Lang("DevMap", "doWhat3") + "|"
          sButtons = "* " + Lang("DevMap", "IgnoreDevs") + "~" + Lang("DevMap", "IgnoreDevsTT") +
                     "|" + Lang("DevMap", "TryAgain") +
                     "|" + Lang("DevMap", "chgDevMap") +
                     "|" + Lang("DevMap", "closeFile") +
                     "|" + Lang("DevMap", "CloseSCS")
          debugMsg(sProcName, sTitle)
          nReply = OptionRequester(0, 0, sTitle, sButtons, 120, #IDI_EXCLAMATION)
          debugMsg(sProcName, "nReply=" + nReply)
          Select nReply
            Case 1  ; ignore these devices
              grDevMapCheck = grDevMapCheckForSetIgnoreDevInds  ; reinstate grDevMapCheck as it was when sCheckDevMapMsg or gsCheckDevMapMsg was set
              debugMsg(sProcName, "calling setIgnoreDevThisRunInds()")
              setIgnoreDevThisRunInds()
              debugMsg(sProcName, "trying again (after setting 'ignore dev this run' inds)")
              Continue
            Case 2  ; try again
              debugMsg(sProcName, "calling reloadDevices(" + decodeDriver(nAudioDriverOfRequestedDevMap) + ")")
              reloadDevices(nAudioDriverOfRequestedDevMap)
              debugMsg(sProcName, "trying again")
              Continue
            Case 3  ; change device map
              nValidDevMapPtr = #SCS_REVIEW_DEVMAP
              gbKillSplashTimerEarly = #True
              Break
            Case 4  ; close cue file
              nValidDevMapPtr = #SCS_CLOSE_CUE_FILE
              gbCloseCueFile = #True
              gbKillSplashTimerEarly = #True
              Break
            Case 5  ; close SCS
              debugMsg(sProcName, "closing down")
              ; clearInitializingState()
              closeDown(#True)
              Debug "END OF RUN (in findValidDevMap())"
              End
          EndSelect
        EndIf
      EndIf
    EndIf
  Wend
  
  debugMsg(sProcName, "nValidDevMapPtr=" + getDevMapName(nValidDevMapPtr) + ", nDevMapPtr=" + getDevMapName(nDevMapPtr))
  
  If nValidDevMapPtr <> nDevMapPtr
    If nValidDevMapPtr >= 0
      sSelectedDevMap = getDevMapName(nValidDevMapPtr)
      sMsg = LangPars("DevMap", "ChangingDevMap", sRequestedDevMap, sSelectedDevMap)
      debugMsg(sProcName, sMsg)
      ensureSplashNotOnTop()
      scsMessageRequester(sCueFilePart, sMsg, #MB_ICONINFORMATION)
;       gsSelectedDevMapName = sSelectedDevMap
;       debugMsg(sProcName, "gsSelectedDevMapName=" + gsSelectedDevMapName)
      grMaps\sSelectedDevMapName = sSelectedDevMap
      debugMsg(sProcName, "grMaps\sSelectedDevMapName=" + grMaps\sSelectedDevMapName)
      grMVUD\bDevMapDisplayed = #False
      grMVUD\bDevMapCurrentlyDisplayed = #False
    EndIf
  EndIf
  
  If nValidDevMapPtr < 0
    debugMsg(sProcName, #SCS_END + ", returning " + nValidDevMapPtr)
  Else
    debugMsg(sProcName, #SCS_END + ", returning " + getDevMapName(nValidDevMapPtr))
  EndIf
  ProcedureReturn nValidDevMapPtr
EndProcedure

Procedure checkDevMapForCheckerSMSOutputsUsed(nDevMapPtr)
  PROCNAMEC()
  Protected d1, d2
  Protected sDevName.s
  Protected nFirst1BasedOutputChan, nLast1BasedOutputChan
  Protected nLowest1BasedOutputChan, nHighest1BasedOutputChan
  Protected Dim nOutputChan(0)
  Protected nOutputCount
  Protected bDevMapOutputsUsedOK
  
  debugMsg(sProcName, #SCS_START + ", nDevMapPtr=" + getDevMapName(nDevMapPtr))
  
  bDevMapOutputsUsedOK = #True
  
  d1 = grMapsForChecker\aMap(nDevMapPtr)\nFirstDevIndex
  While d1 >= 0
    With grMapsForChecker\aDev(d1)
      If \sLogicalDev
        If \nDevType = #SCS_DEVTYPE_AUDIO_OUTPUT
          If \bNoDevice = #False
            debugMsg(sProcName, "grMapsForChecker\aDev(" + d1 + ")\sLogicalDev=" + \sLogicalDev + ", \sPhysicalDev=" + \sPhysicalDev + ", \nPhysicalDevPtr=" + \nPhysicalDevPtr +
                                ", \nFirst1BasedOutputChan=" + \nFirst1BasedOutputChan + ", \nNrOfDevOutputChans=" + \nNrOfDevOutputChans)
            nFirst1BasedOutputChan = \nFirst1BasedOutputChan
            nLast1BasedOutputChan = nFirst1BasedOutputChan + \nNrOfDevOutputChans - 1
            If (nLowest1BasedOutputChan = 0) Or (nFirst1BasedOutputChan < nLowest1BasedOutputChan)
              nLowest1BasedOutputChan = nFirst1BasedOutputChan
            EndIf
            If nLast1BasedOutputChan > nHighest1BasedOutputChan
              nHighest1BasedOutputChan = nLast1BasedOutputChan
            EndIf
            If nLast1BasedOutputChan > ArraySize(nOutputChan())
              ReDim nOutputChan(nLast1BasedOutputChan + 20)
            EndIf
            For d2 = nFirst1BasedOutputChan To nLast1BasedOutputChan
              nOutputChan(d2) = d2
              ; debugMsg(sProcName, "nOutputChan(" + d2 + ")=" + nOutputChan(d2))
            Next d2
          EndIf
        EndIf
      EndIf
      d1 = \nNextDevIndex
    EndWith
  Wend
  
  debugMsg(sProcName, "grMMedia\nSMSMaxOutputs=" + grMMedia\nSMSMaxOutputs)
  For d1 = nLowest1BasedOutputChan To nHighest1BasedOutputChan
    If nOutputChan(d1) <> 0
      nOutputCount + 1
      If nOutputCount > grMMedia\nSMSMaxOutputs
        nOutputChan(d1) = (d1 * -1)
        ; debugMsg(sProcName, "nOutputChan(" + d1 + ")=" + nOutputChan(d1))
      EndIf
    EndIf
  Next d1
  
  d1 = grMapsForChecker\aMap(nDevMapPtr)\nFirstDevIndex
  While d1 >= 0
    With grMapsForChecker\aDev(d1)
      If \nDevType = #SCS_DEVTYPE_AUDIO_OUTPUT
        If \sLogicalDev
          If \bNoDevice = #False
            If \nDevState = #SCS_DEVSTATE_ACTIVE
              nFirst1BasedOutputChan = \nFirst1BasedOutputChan
              nLast1BasedOutputChan = nFirst1BasedOutputChan + \nNrOfDevOutputChans - 1
              debugMsg(sProcName, "rDevMap\rAudioDev[" + d1 + "]\sLogicalDev=" + \sLogicalDev + ", \sPhysicalDev=" + \sPhysicalDev + ", \nPhysicalDevPtr=" + \nPhysicalDevPtr +
                                  ", \nFirst1BasedOutputChan=" + \nFirst1BasedOutputChan + ", \nNrOfDevOutputChans=" + \nNrOfDevOutputChans)
              For d2 = nFirst1BasedOutputChan To nLast1BasedOutputChan
                ; debugMsg(sProcName, "nOutputChan(" + d2 + ")=" + nOutputChan(d2))
                If nOutputChan(d2) <= 0
                  \nDevState = #SCS_DEVSTATE_INACTIVE
                  debugMsg(sProcName, "grMapsForChecker\aDev(" + d1 + ")\nDevState=" + decodeDevState(grMapsForChecker\aDev(d1)\nDevState))
                  bDevMapOutputsUsedOK = #False
                  debugMsg(sProcName, "bDevMapOutputsUsedOK=" + strB(bDevMapOutputsUsedOK))
                  Break
                EndIf
              Next d2
            EndIf
          EndIf
        EndIf
      EndIf
      d1 = \nNextDevIndex
    EndWith
  Wend
  
  debugMsg(sProcName, #SCS_END + ", returning " + strB(bDevMapOutputsUsedOK))
  ProcedureReturn bDevMapOutputsUsedOK
EndProcedure

Procedure checkDevMapForCheckerDSOutputsUsed(*rDev.tyDevMapDev)
  PROCNAMEC()
  ; note: 'DS' in the procedure name means 'DirectSound'
  Protected bCheckOK = #True
  Protected nNrOfOutputChans
  Protected nPhysicalDevPtr, nOutputs
  Protected sOutputRange.s, sSearchString.s
  Protected n
  
  ; debugMsg(sProcName, #SCS_START)
  
  With *rDev
    nNrOfOutputChans = \nNrOfDevOutputChans
    nPhysicalDevPtr = \nPhysicalDevPtr
    ; debugMsg(sProcName, "nPhysicalDevPtr=" + nPhysicalDevPtr + ", *rDev\sLogicalDev=" + \sLogicalDev + ", \nNrOfDevOutputChans=" + \nNrOfDevOutputChans)
    If nPhysicalDevPtr >= 0
      nOutputs = gaAudioDev(nPhysicalDevPtr)\nOutputs
      ; debugMsg(sProcName, "gaAudioDev(" + nPhysicalDevPtr + ")\nOutputs=" + nOutputs)
      sOutputRange = ";"
      If (gaAudioDev(nPhysicalDevPtr)\bASIO = #False) And (nOutputs = 2)
        If nNrOfOutputChans = 1
          sOutputRange + "L;R;1;2;"
        Else
          sOutputRange + "L-R;1-2;"
        EndIf
      Else
        For n = 1 To (nOutputs - nNrOfOutputChans + 1)
          If nNrOfOutputChans = 1
            sOutputRange + n + ";"
          Else
            sOutputRange + n + "-" + Str(n + nNrOfOutputChans - 1) + ";"
          EndIf
        Next n
        If nNrOfOutputChans = 1
          sOutputRange + "L;R;"
        Else
          sOutputRange + "L-R;"
        EndIf
      EndIf
    EndIf
    
    If \s1BasedOutputRange
      sSearchString = ";" + \s1BasedOutputRange + ";"
      If FindString(sOutputRange, sSearchString) = 0
        ; requested output(s) not found
        bCheckOK = #False
        debugMsg(sProcName, "nPhysicalDevPtr=" + nPhysicalDevPtr + ", *rDev\sLogicalDev=" + \sLogicalDev + ", \nNrOfDevOutputChans=" + \nNrOfDevOutputChans)
        debugMsg(sProcName, "gaAudioDev(" + nPhysicalDevPtr + ")\nOutputs=" + nOutputs)
        debugMsg(sProcName, "sOutputRange=" + sOutputRange + ", *rDev\s1BasedOutputRange=" + \s1BasedOutputRange)
      EndIf
    EndIf
    
  EndWith
  
  If bCheckOK = #False
    debugMsg(sProcName, #SCS_END + ", returning " + strB(bCheckOK))
  EndIf
  ProcedureReturn bCheckOK
  
EndProcedure

Procedure setBassInfoInDevMapForChecker(nDevMapPtr)
  PROCNAMEC()
  Protected d1
  Protected nPhysicalDevPtr, nPhysicalDevOutputs
  Protected nSpeakerPair, nLeftOrRight
  Protected nSpeakerFlags
  
  debugMsg(sProcName, #SCS_START + ", nDevMapPtr=" + getDevMapName(nDevMapPtr))
  
  d1 = grMapsForChecker\aMap(nDevMapPtr)\nFirstDevIndex
  While d1 >= 0
    With grMapsForChecker\aDev(d1)
      ; debugMsg(sProcName, "grMapsForChecker\aDev(" + d1 + ")\nDevMapId=" + \nDevMapId + ", \nNextDevIndex=" + \nNextDevIndex)
      Select \nDevType
        Case #SCS_DEVTYPE_AUDIO_OUTPUT  ; #SCS_DEVTYPE_AUDIO_OUTPUT
          \nBassDevice = -1
          \bBassASIO = #False
          \nBassASIODevice = -1
          \nBassSpeakerFlags = 0
          nSpeakerFlags = 0
          If \sLogicalDev
            If (\bNoDevice = #False) And (\bIgnoreDevThisRun = #False)
              nPhysicalDevPtr = \nPhysicalDevPtr
              If nPhysicalDevPtr >= 0
                \nBassDevice = gaAudioDev(nPhysicalDevPtr)\nBassDevice
                \bBassASIO = gaAudioDev(nPhysicalDevPtr)\bASIO
                \nBassASIODevice = gaAudioDev(nPhysicalDevPtr)\nDevBassASIODevice
                nPhysicalDevOutputs = gaAudioDev(nPhysicalDevPtr)\nOutputs
                If (\nFirst1BasedOutputChan > 0) And (\nNrOfDevOutputChans < nPhysicalDevOutputs) And (\nNrOfDevOutputChans >= 1) And (\nNrOfDevOutputChans <= 2)
                  nSpeakerPair = ((\nFirst1BasedOutputChan - 1) >> 1) + 1
                  ; swap 3/4 with 5/6 if required
                  If grDriverSettings\bSwap34with56
                    If (\bBassASIO = #False) And (nPhysicalDevOutputs = 6 Or nPhysicalDevOutputs = 8)
                      Select nSpeakerPair
                        Case 2
                          nSpeakerPair = 3
                        Case 3
                          nSpeakerPair = 2
                      EndSelect
                    EndIf
                  EndIf
                  nSpeakerFlags = BASS_SPEAKER_N(nSpeakerPair)
                  ; debugMsg3(sProcName, "BASS_SPEAKER_N(" + nSpeakerPair + ") returned $" + Hex(nSpeakerFlags) + ", \nFirst1BasedOutputChan=" + \nFirst1BasedOutputChan)
                  If \nNrOfDevOutputChans = 1
                    nLeftOrRight = (\nFirst1BasedOutputChan - 1) % 2
                    If nLeftOrRight = 0
                      nSpeakerFlags | #BASS_SPEAKER_LEFT
                    Else
                      nSpeakerFlags | #BASS_SPEAKER_RIGHT
                    EndIf
                  EndIf
                EndIf
              EndIf
            EndIf
            \nBassSpeakerFlags = nSpeakerFlags
            debugMsg(sProcName, "grMapsForChecker\aDev(" + d1 + ")\sLogicalDev=" + \sLogicalDev + ", \sPhysicalDev=" + \sPhysicalDev +
                                ", \s1BasedOutputRange=" + \s1BasedOutputRange + ", \nBassDevice=" + \nBassDevice + ", \nBassSpeakerFlags=$" + Hex(\nBassSpeakerFlags) +
                                ", \bBassASIO=" + strB(\bBassASIO) + ", \nBassASIODevice=" + \nBassASIODevice + ", \nFirst0BasedOutputChan=" + \nFirst0BasedOutputChan)
          EndIf
      EndSelect
      d1 = \nNextDevIndex
    EndWith
  Wend
  
EndProcedure

Procedure.s buildCueCtrlLogicalDev(nDevNo)
  ProcedureReturn "C" + Str(nDevNo+1)
EndProcedure

Procedure resetDevMapForDevChgsDevPtrs(bSkipRemovals=#False)
  PROCNAMEC()
  ; resets pointers in device maps, and remove old devices from device maps, if necessary
  Protected nDevMapPtr, nDevMapDevPtr, nDevMapId
  Protected d, nMaxDev, sLogicalDev.s, nDevNo, nDevMapDevNo
  Protected Dim bDevUsed(0)           ; will be one entry per device in grMapsForDevChgs\aDev()
  Protected Dim nPrevDevMapDevPtr(0)  ; will be one entry per device map in grMapsForDevChgs\aMap()
  Protected bFound
  Protected nDevGrp
  
  debugMsg(sProcName, #SCS_START + ", grMapsForDevChgs\nMaxDevIndex=" + grMapsForDevChgs\nMaxDevIndex + ", grMapsForDevChgs\nMaxMapIndex=" + grMapsForDevChgs\nMaxMapIndex)
  
  If grMapsForDevChgs\nMaxDevIndex < 0 Or grMapsForDevChgs\nMaxMapIndex < 0
    ProcedureReturn
  EndIf
  
  ReDim bDevUsed(grMapsForDevChgs\nMaxDevIndex)
  ReDim nPrevDevMapDevPtr(grMapsForDevChgs\nMaxMapIndex)
  For d = 0 To grMapsForDevChgs\nMaxMapIndex
    nPrevDevMapDevPtr(d) = -1
  Next d
  
  For nDevGrp = #SCS_DEVGRP_FIRST To #SCS_DEVGRP_LAST
    
    With grProdForDevChgs
      Select nDevGrp
        Case #SCS_DEVGRP_AUDIO_OUTPUT
          nMaxDev = \nMaxAudioLogicalDev
        Case #SCS_DEVGRP_VIDEO_AUDIO
          nMaxDev = \nMaxVidAudLogicalDev
        Case #SCS_DEVGRP_VIDEO_CAPTURE
          nMaxDev = \nMaxVidCapLogicalDev
        Case #SCS_DEVGRP_LIGHTING
          nMaxDev = \nMaxLightingLogicalDev
        Case #SCS_DEVGRP_CTRL_SEND
          nMaxDev = \nMaxCtrlSendLogicalDev
        Case #SCS_DEVGRP_CUE_CTRL
          nMaxDev = \nMaxCueCtrlLogicalDev
        Case #SCS_DEVGRP_LIVE_INPUT
          nMaxDev = \nMaxLiveInputLogicalDev
      EndSelect
    EndWith
    
    nDevNo = -1
    
    For d = 0 To nMaxDev
      Select nDevGrp
        Case #SCS_DEVGRP_AUDIO_OUTPUT
          sLogicalDev = grProdForDevChgs\aAudioLogicalDevs(d)\sLogicalDev
        Case #SCS_DEVGRP_VIDEO_AUDIO
          sLogicalDev = grProdForDevChgs\aVidAudLogicalDevs(d)\sVidAudLogicalDev
        Case #SCS_DEVGRP_VIDEO_CAPTURE
          sLogicalDev = grProdForDevChgs\aVidCapLogicalDevs(d)\sLogicalDev
        Case #SCS_DEVGRP_FIX_TYPE
          ; not recorded in device maps
        Case #SCS_DEVGRP_LIGHTING
          sLogicalDev = grProdForDevChgs\aLightingLogicalDevs(d)\sLogicalDev
        Case #SCS_DEVGRP_CTRL_SEND
          sLogicalDev = grProdForDevChgs\aCtrlSendLogicalDevs(d)\sLogicalDev
        Case #SCS_DEVGRP_CUE_CTRL
          sLogicalDev = buildCueCtrlLogicalDev(d)
        Case #SCS_DEVGRP_LIVE_INPUT
          sLogicalDev = grProdForDevChgs\aLiveInputLogicalDevs(d)\sLogicalDev
        Case #SCS_DEVGRP_IN_GRP
          ; not recorded in device maps
        Default
          sLogicalDev = ""
      EndSelect
      
      ; debugMsg0(sProcName, "d=" + d + ", nDevGrp=" + decodeDevGrp(nDevGrp) + ", sLogicalDev=" + sLogicalDev)
      
      If sLogicalDev
        nDevNo + 1
        For nDevMapPtr = 0 To grMapsForDevChgs\nMaxMapIndex
          nDevMapId = grMapsForDevChgs\aMap(nDevMapPtr)\nDevMapId
          nDevMapDevNo = -1
          For nDevMapDevPtr = 0 To grMapsForDevChgs\nMaxDevIndex
            With grMapsForDevChgs\aDev(nDevMapDevPtr)
              If \bExists And \nDevGrp = nDevGrp And \sLogicalDev = sLogicalDev And \nDevMapId = nDevMapId
                nDevMapDevNo + 1
                bDevUsed(nDevMapDevPtr) = #True
                If nPrevDevMapDevPtr(nDevMapPtr) = -1
                  grMapsForDevChgs\aMap(nDevMapPtr)\nFirstDevIndex = nDevMapDevPtr
                Else
                  grMapsForDevChgs\aDev(nPrevDevMapDevPtr(nDevMapPtr))\nNextDevIndex = nDevMapDevPtr
                EndIf
                grMapsForDevChgs\aDev(nDevMapDevPtr)\nPrevDevIndex = nPrevDevMapDevPtr(nDevMapPtr)
                grMapsForDevChgs\aDev(nDevMapDevPtr)\nNextDevIndex = -1
                nPrevDevMapDevPtr(nDevMapPtr) = nDevMapDevPtr
              EndIf
            EndWith
          Next nDevMapDevPtr
        Next nDevMapPtr
      EndIf
      
    Next d
    
  Next nDevGrp
  
  If bSkipRemovals = #False
    ; now remove any obsolete devices
    For nDevMapPtr = 0 To grMapsForDevChgs\nMaxMapIndex
      nDevMapId = grMapsForDevChgs\aMap(nDevMapPtr)\nDevMapId
      For nDevMapDevPtr = 0 To grMapsForDevChgs\nMaxDevIndex
        With grMapsForDevChgs\aDev(nDevMapDevPtr)
          ; debugMsg(sProcName, "grMapsForDevChgs\aDev(" + nDevMapDevPtr + ")\nDevGrp=" + decodeDevGrp(\nDevGrp) + ", \nDevType=" + decodeDevType(\nDevType) + ", \sLogicalDev=" + \sLogicalDev + ", \bExists=" + strB(\bExists))
          If \bExists And \nDevMapId = nDevMapId
            If bDevUsed(nDevMapDevPtr) = #False
              ; obsolete device
              debugMsg(sProcName, "removing obsolete device from device map " + getDevChgsDevMapName(nDevMapPtr) + ", nDevMapDevPtr=" + nDevMapDevPtr + ", \nDevGrp=" + decodeDevGrp(\nDevGrp) + ", \sLogicalDev=" + \sLogicalDev)
              grMapsForDevChgs\aDev(nDevMapDevPtr) = grDevMapDevDef
              \bExists = #False
            EndIf
          EndIf
        EndWith
      Next nDevMapDevPtr
    Next nDevMapPtr
  EndIf
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure changeDevChgsDevMapDevsLogicalDev(nDevGrp, sOldLogicalDev.s, sNewLogicalDev.s)
  PROCNAMEC()
  Protected nDevMapPtr, nDevMapId, nDevMapDevPtr
  
  debugMsg(sProcName, #SCS_START + ", nDevGrp=" + decodeDevGrp(nDevGrp) + ", sOldLogicalDev=" + sOldLogicalDev + ", sNewLogicalDev=" + sNewLogicalDev)
  
  For nDevMapPtr = 0 To grMapsForDevChgs\nMaxMapIndex
    debugMsg(sProcName, "grMapsForDevChgs\aMap(" + nDevMapPtr + ")\sDevMapName=" + grMapsForDevChgs\aMap(nDevMapPtr)\sDevMapName)
    nDevMapId = grMapsForDevChgs\aMap(nDevMapPtr)\nDevMapId
    For nDevMapDevPtr = 0 To grMapsForDevChgs\nMaxDevIndex
      With grMapsForDevChgs\aDev(nDevMapDevPtr)
        If \nDevGrp = nDevGrp And \nDevMapId = nDevMapId
          debugMsg(sProcName, "grMapsForDevChgs\aDev(" + nDevMapDevPtr + ")\nDevGrp=" + decodeDevGrp(\nDevGrp) + ", \nDevType=" + decodeDevType(\nDevType) + ", \sLogicalDev=" + \sLogicalDev + ", \bExists=" + strB(\bExists))
          If \bExists
            If \sLogicalDev = sOldLogicalDev
              \sLogicalDev = sNewLogicalDev
            EndIf
          EndIf
        EndIf
      EndWith
    Next nDevMapDevPtr
  Next nDevMapPtr
      

EndProcedure

Procedure resetDevMapForDevChgs(nDevMapId)
  PROCNAMEC()
  Protected nDevMapPtr=-1, nDevMapForDevChgsPtr=-1
  Protected d, d2, n
  Protected nPrevDevIndex=-1
  
  debugMsg(sProcName, #SCS_START + ", nDevMapId=" + nDevMapId)
  
  For n = 0 To grMaps\nMaxMapIndex
    If grMaps\aMap(n)\nDevMapId = nDevMapId
      nDevMapPtr = n
      Break
    EndIf
  Next n
  
  For n = 0 To grMapsForDevChgs\nMaxMapIndex
    If grMapsForDevChgs\aMap(n)\nDevMapId = nDevMapId
      nDevMapForDevChgsPtr = n
      Break
    EndIf
  Next n
  
  debugMsg(sProcName, "nDevMapPtr=" + nDevMapPtr + ", nDevMapForDevChgsPtr=" + nDevMapForDevChgsPtr)
  If nDevMapPtr = -1 Or nDevMapForDevChgsPtr = -1
    debugMsg(sProcName, "Exiting because nDevMapPtr = -1 Or nDevMapForDevChgsPtr = -1")
    ProcedureReturn #False
  EndIf
  
  ; 'delete' all existing devices for the device map in DevChgs
  d = grMapsForDevChgs\aMap(nDevMapForDevChgsPtr)\nFirstDevIndex
  While d >= 0
    grMapsForDevChgs\aDev(d)\bExists = #False
    d = grMapsForDevChgs\aDev(d)\nNextDevIndex
  Wend
  
  ; copy device map itself
  debugMsg(sProcName, "copying grMaps\aMap(" + nDevMapPtr + ") To grMapsForDevChgs\aMap(" + nDevMapForDevChgsPtr + "), sDevMapName=" + #DQUOTE$ + grMaps\aMap(nDevMapPtr)\sDevMapName + #DQUOTE$)
  grMapsForDevChgs\aMap(nDevMapForDevChgsPtr) = grMaps\aMap(nDevMapPtr)
  grMapsForDevChgs\aMap(nDevMapForDevChgsPtr)\nOrigAudioDriver = grMapsForDevChgs\aMap(nDevMapForDevChgsPtr)\nAudioDriver     ; used to check for changes in WEP_btnApplyDevChgs()
  
  ; copy devices for this device map
  d = grMaps\aMap(nDevMapPtr)\nFirstDevIndex
  d2 = grMapsForDevChgs\nMaxDevIndex
  While d >= 0
    d2 + 1
    If d2 > ArraySize(grMapsForDevChgs\aDev())
      REDIM_ARRAY(grMapsForDevChgs\aDev, d2+10, grDevMapDevDef, "grMapsForDevChgs\aDev()")
    EndIf
    With grMaps\aDev(d)
      debugMsg(sProcName, "copying grMaps\aDev(" + d + ") To grMapsForDevChgs\aDev(" + d2 + "), \nDevType=" + decodeDevType(\nDevType) + ", \sLogicalDev=" + \sLogicalDev)
    EndWith
    grMapsForDevChgs\aDev(d2) = grMaps\aDev(d)
    grMapsForDevChgs\aDev(d2)\sOrigPhysicalDev = grMapsForDevChgs\aDev(d2)\sPhysicalDev     ; used to check for changes in WEP_btnApplyDevChgs()
    If nPrevDevIndex = -1
      grMapsForDevChgs\aMap(nDevMapForDevChgsPtr)\nFirstDevIndex = d2
    Else
      grMapsForDevChgs\aDev(nPrevDevIndex)\nNextDevIndex = d2
    EndIf
    grMapsForDevChgs\aDev(d2)\nPrevDevIndex = nPrevDevIndex
    grMapsForDevChgs\aDev(d2)\nNextDevIndex = -1
    ; debugMsg(sProcName, "grMapsForDevChgs\aDev(" + d2 + ")\nPrevDevIndex=" + grMapsForDevChgs\aDev(d2)\nPrevDevIndex + ", grMapsForDevChgs\aDev(" + d2 + ")\nNextDevIndex=" + grMapsForDevChgs\aDev(d2)\nNextDevIndex)
    nPrevDevIndex = d2
    d = grMaps\aDev(d)\nNextDevIndex
  Wend
  grMapsForDevChgs\nMaxDevIndex = d2
  
  debugMsg(sProcName, #SCS_END)
  ProcedureReturn #True
  
EndProcedure

Procedure setDevChgsDevDefaults(nDevMapDevPtr, bIncludePort=#False)
  PROCNAMEC()
  Protected d
  
  ; debugMsg(sProcName, #SCS_START + ", nDevMapDevPtr=" + nDevMapDevPtr + ", bIncludePort=" + strB(bIncludePort))
  
  If nDevMapDevPtr >= 0
    With grMapsForDevChgs\aDev(nDevMapDevPtr)
      Select \nDevType
        Case #SCS_DEVTYPE_NONE  ; #SCS_DEVTYPE_NONE
          ;{
          If bIncludePort
            \sPhysicalDev = ""
            \bDummy = #False
            \nPhysicalDevPtr = -1
          EndIf
; debugMsg(sProcName, "grMapsForDevChgs\aDev(" + nDevMapDevPtr + ")\nDevType=" + decodeDevType(\nDevType) + ", setting \bExists=#False, was " + strB(\bExists))
          ; \bExists = #False ; Added 9Sep2024
          ;}
        Case #SCS_DEVTYPE_CC_MIDI_IN  ; #SCS_DEVTYPE_CC_MIDI_IN
          ;{
          If bIncludePort
            If gnNumMidiInDevs > 0
              For d = 0 To (gnNumMidiInDevs - 1)
                If gaMidiInDevice(d)\bIgnoreDev = #False
                  \sPhysicalDev = gaMidiInDevice(d)\sName
                  \bDummy = gaMidiInDevice(d)\bDummy
                  \nMidiInPhysicalDevPtr = d
                  \nPhysicalDevPtr = d
                  Break
                EndIf
              Next d
            EndIf
          EndIf
          ;}
        Case #SCS_DEVTYPE_CS_MIDI_OUT  ; #SCS_DEVTYPE_CS_MIDI_OUT
          ;{
          If bIncludePort
            If gnNumMidiOutDevs > 0
              For d = 0 To (gnNumMidiOutDevs - 1)
                If gaMidiOutDevice(d)\bIgnoreDev = #False
                  \sPhysicalDev = gaMidiOutDevice(d)\sName
                  \bDummy = gaMidiOutDevice(d)\bDummy
                  \nMidiOutPhysicalDevPtr = d
                  \nPhysicalDevPtr = d
                  Break
                EndIf
              Next d
            EndIf
          EndIf
          ;}
        Case #SCS_DEVTYPE_CS_MIDI_THRU  ; #SCS_DEVTYPE_CS_MIDI_THRU
          ;{
          If bIncludePort
            If gnNumMidiInDevs > 0
              For d = 0 To (gnNumMidiInDevs - 1)
                If gaMidiInDevice(d)\bIgnoreDev = #False
                  \sMidiThruInPhysicalDev = gaMidiInDevice(d)\sName
                  \bMidiThruInDummy = gaMidiInDevice(d)\bDummy
                  \nMidiThruInPhysicalDevPtr = d
                  Break
                EndIf
              Next d
            EndIf
            If gnNumMidiOutDevs > 0
              For d = 0 To (gnNumMidiOutDevs - 1)
                If gaMidiOutDevice(d)\bIgnoreDev = #False
                  \sPhysicalDev = gaMidiOutDevice(d)\sName
                  \bDummy = gaMidiOutDevice(d)\bDummy
                  \nMidiOutPhysicalDevPtr = d
                  \nPhysicalDevPtr = d
                  Break
                EndIf
              Next d
            EndIf
          EndIf
          ;}
        Case #SCS_DEVTYPE_CC_RS232_IN, #SCS_DEVTYPE_CS_RS232_OUT
          ;{
          If bIncludePort
            If gnMaxRS232Control >= 0
              \sPhysicalDev = gaRS232Control(0)\sRS232PortAddress
              \bDummy = gaRS232Control(0)\bDummy
              \nPhysicalDevPtr = 0
            EndIf
          EndIf
          ;           \nRS232BaudRate = grRS232ControlDefault\nRS232BaudRate
          ;           \nRS232DataBits = grRS232ControlDefault\nRS232DataBits
          ;           \nRS232Parity = grRS232ControlDefault\nRS232Parity
          ;           \fRS232StopBits = grRS232ControlDefault\fRS232StopBits
          ;           \nRS232Handshaking = grRS232ControlDefault\nRS232Handshaking
          ;           \nRS232RTSEnable = grRS232ControlDefault\nRS232RTSEnable
          ;           \nRS232DTREnable = grRS232ControlDefault\nRS232DTREnable
          ;}
        Case #SCS_DEVTYPE_CC_NETWORK_IN, #SCS_DEVTYPE_CS_NETWORK_OUT
          ;{
          ;           If \nLocalPort <= 0
          ;             \nLocalPort = #SCS_DEFAULT_NETWORK_LOCAL_PORT
          ;           EndIf
          ;}
        Case #SCS_DEVTYPE_CC_DMX_IN, #SCS_DEVTYPE_LT_DMX_OUT
          ;{
          ; no action
          ;}
        Case #SCS_DEVTYPE_CS_HTTP_REQUEST
          ;{
          ; no action
          ;}
      EndSelect
    EndWith
  EndIf
  
EndProcedure

Procedure getPhysDevPtrForLogicalDev(*rMaps.tyMaps, nDevGrp, sLogicalDev.s)
  ; PROCNAMEC()
  Protected nDevMapDevPtr
  
  nDevMapDevPtr = getDevMapDevPtrForLogicalDev(*rMaps, nDevGrp, sLogicalDev)
  If nDevMapDevPtr >= 0
    ProcedureReturn *rMaps\aDev(nDevMapDevPtr)\nPhysicalDevPtr
  Else
    ProcedureReturn -1
  EndIf
  
EndProcedure

Procedure getCtrlNetworkRemoteDevForPhysicalDevPtr(nCSPhysicalDevPtr)
  Protected nCtrlNetworkRemoteDev
  
  If nCSPhysicalDevPtr >= 0
    nCtrlNetworkRemoteDev = gaNetworkControl(nCSPhysicalDevPtr)\nCtrlNetworkRemoteDev
  Else
    nCtrlNetworkRemoteDev = -1
  EndIf
  ProcedureReturn nCtrlNetworkRemoteDev
EndProcedure

Macro macUpdateDevMapPhysicalDevPtrs(pDevMap, pDevMapDev, pMaxDevMap)
  
  ; update all device maps
  For nDevMapPtr = 0 To pMaxDevMap
    d2 = pDevMap(nDevMapPtr)\nFirstDevIndex
    While d2 >= 0
      If pDevMapDev(d2)\bExists
        If Len(pDevMapDev(d2)\sPhysicalDev) > 0
          Select pDevMapDev(d2)\nDevType
            Case #SCS_DEVTYPE_AUDIO_OUTPUT, #SCS_DEVTYPE_VIDEO_AUDIO, #SCS_DEVTYPE_LIVE_INPUT
              pDevMapDev(d2)\nPhysicalDevPtr = getPhysicalDevPtr(pDevMapDev(d2)\nDevType, pDevMapDev(d2)\sPhysicalDev, pDevMap(nDevMapPtr)\nAudioDriver, "", 0, pDevMapDev(d2)\bDummy, pDevMapDev(d2)\bDefaultDev)
              debugMsg(sProcName, "pDevMapDev(" + d2 + ")\nDevType=" + decodeDevType(pDevMapDev(d2)\nDevType) +
                                  ", \sPhysicalDev=" + pDevMapDev(d2)\sPhysicalDev +
                                  ", \bDefaultDev=" + strB(pDevMapDev(d2)\bDefaultDev) +
                                  ", \nPhysicalDevPtr=" + pDevMapDev(d2)\nPhysicalDevPtr)
              
            Case #SCS_DEVTYPE_CC_MIDI_IN
              pDevMapDev(d2)\nMidiInPhysicalDevPtr = getMidiInPhysicalDevPtr(pDevMapDev(d2)\sPhysicalDev, pDevMapDev(d2)\bDummy)
              debugMsg(sProcName, "pDevMapDev(" + d2 + ")\nDevType=" + decodeDevType(pDevMapDev(d2)\nDevType) +
                                  ", \sPhysicalDev=" + pDevMapDev(d2)\sPhysicalDev +
                                  ", \nMidiInPhysicalDevPtr=" + pDevMapDev(d2)\nMidiInPhysicalDevPtr)
              
              ;             Case #SCS_DEVTYPE_CS_MIDI_OUT  ; #SCS_DEVTYPE_CS_MIDI_OUT added 5Nov2015 11.4.1.2h
              ;               pDevMapDev(d2)\nMidiOutPort = getMidiOutPhysicalDevPtr(pDevMapDev(d2)\sPhysicalDev)
              ;               debugMsg(sProcName, "pDevMapDev(" + d2 + ")\nDevType=" + decodeDevType(pDevMapDev(d2)\nDevType) +
              ;                                   ", \sPhysicalDev=" + pDevMapDev(d2)\sPhysicalDev +
              ;                                   ", \nMidiOutPort=" + pDevMapDev(d2)\nMidiOutPort)
              
            Case #SCS_DEVTYPE_CS_MIDI_THRU
              pDevMapDev(d2)\nMidiThruInPhysicalDevPtr = getPhysicalDevPtr(#SCS_DEVTYPE_CC_MIDI_IN, pDevMapDev(d2)\sMidiThruInPhysicalDev, pDevMap(nDevMapPtr)\nAudioDriver, "", 0, pDevMapDev(d2)\bMidiThruInDummy)
              
            Case #SCS_DEVTYPE_CC_DMX_IN, #SCS_DEVTYPE_LT_DMX_OUT
              pDevMapDev(d2)\nPhysicalDevPtr = DMX_getDMXDevPtr(pDevMapDev(d2)\sPhysicalDev, pDevMapDev(d2)\sDMXSerial, pDevMapDev(d2)\nDMXSerial, pDevMapDev(d2)\bDummy)
              
          EndSelect
        Else
          pDevMapDev(d2)\nPhysicalDevPtr = -1
        EndIf
        ;         ; added 5Nov2015 11.4.1.2h
        ;         If pDevMapDev(d2)\nPhysicalDevPtr < 0
        ;           pDevMapDev(d2)\bDummy = #True
        ;         EndIf
        ;         ; end added 5Nov2015 11.4.1.2h
      EndIf
      d2 = pDevMapDev(d2)\nNextDevIndex
    Wend
  Next nDevMapPtr
EndMacro

Procedure updateDevMapPhysicalDevPtrs()
  PROCNAMEC()
  Protected nDevMapPtr
  Protected d2
  
  debugMsg(sProcName, #SCS_START)
  
  debugMsg(sProcName, "calling macUpdateDevMapPhysicalDevPtrs(grMaps\aMap, grMaps\aDev, grMaps\nMaxMapIndex)")
  macUpdateDevMapPhysicalDevPtrs(grMaps\aMap, grMaps\aDev, grMaps\nMaxMapIndex)
  
  debugMsg(sProcName, "calling macUpdateDevMapPhysicalDevPtrs(grMapsForDevChgs\aMap, grMapsForDevChgs\aDev, grMapsForDevChgs\nMaxMapIndex)")
  macUpdateDevMapPhysicalDevPtrs(grMapsForDevChgs\aMap, grMapsForDevChgs\aDev, grMapsForDevChgs\nMaxMapIndex)
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure adjustPhysDevsForNewAudioDriver()
  PROCNAMEC()
  Protected nDevMapPtr, d2, n
  Protected nAudioDriver
  Protected nPhysDevPtr
  Protected nPhysicalDevPtrOld, nPhysicalDevPtrNew
  Protected bChangeThis
  Protected nSortedPhysPtr, nLastOutputUsed, nOutputs
  Protected nLastSortedPhysPtr
  Protected bUsingNoDevice
  Protected bUsingMonitor
  Protected bGetNextDev
  Protected nDevType
  Protected Dim aDevTypeDevCount(#SCS_DEVTYPE_LAST)
  
  debugMsg(sProcName, #SCS_START)
  
  debugMsg(sProcName, "grProdForDevChgs\nSelectedDevMapPtr=" + grProdForDevChgs\nSelectedDevMapPtr)
  nDevMapPtr = grProdForDevChgs\nSelectedDevMapPtr
  If nDevMapPtr >= 0
    nAudioDriver = grMapsForDevChgs\aMap(nDevMapPtr)\nAudioDriver
    debugMsg(sProcName, "nAudioDriver=" + decodeDriver(nAudioDriver))
    
    debugMsg(sProcName, "calling sortAudioDevs(" + decodeDriver(nAudioDriver) + ")")
    sortAudioDevs(nAudioDriver)
    
    ; find last initialized physical device for this audio driver, in array gaAudioDevSorted()
    nLastSortedPhysPtr = -1
    For n = 0 To (gnSortedAudioDevs-1)
      If gaAudioDevSorted(n)\nAudioDriver = nAudioDriver
        nPhysDevPtr = gaAudioDevSorted(n)\nPhysDevPtr
        If gaAudioDev(nPhysDevPtr)\bInitialized
          nLastSortedPhysPtr = n
        EndIf
      EndIf
    Next n
    
    d2 = grMapsForDevChgs\aMap(nDevMapPtr)\nFirstDevIndex
    While d2 >= 0
      With grMapsForDevChgs\aDev(d2)
        If (\bExists) And (\nDevType >= 0)
          nDevType = \nDevType
          aDevTypeDevCount(nDevType) + 1
          bChangeThis = #True
          nPhysicalDevPtrOld = \nPhysicalDevPtr
          If nPhysicalDevPtrOld >= 0
            If gaAudioDev(nPhysicalDevPtrOld)\nAudioDriver = nAudioDriver
              bChangeThis = #False
            EndIf
          EndIf
          If bChangeThis  ; change this
            Select nDevType
              Case #SCS_DEVTYPE_AUDIO_OUTPUT  ; audio output
                If (aDevTypeDevCount(#SCS_DEVTYPE_AUDIO_OUTPUT) = 1) Or (((nLastOutputUsed + \nNrOfDevOutputChans) > nOutputs) And (bUsingNoDevice = #False) And (bUsingMonitor = #False))
                  ; first time, or insufficient remaining outputs on the current device so go to the next device
                  bGetNextDev = #True
                  While bGetNextDev
                    If nSortedPhysPtr < nLastSortedPhysPtr
                      nSortedPhysPtr + 1
                      If gaAudioDevSorted(nSortedPhysPtr)\nAudioDriver = nAudioDriver
                        debugMsg(sProcName, "nSortedPhysPtr=" + Str(nSortedPhysPtr))
                        nOutputs = gaAudioDevSorted(nSortedPhysPtr)\nOutputs
                        nLastOutputUsed = 0    ; reset nLastOutputUsed on change of device
                        If (nOutputs > 0) Or (gaAudioDevSorted(nSortedPhysPtr)\bNoDevice)
                          bGetNextDev = #False
                        EndIf
                      EndIf
                    Else
                      bGetNextDev = #False
                      nLastOutputUsed = 0    ; reset nLastOutputUsed if we've run out of devices, to re-use the first output(s) of the last device
                    EndIf
                  Wend
                EndIf
                debugMsg(sProcName, "using nSortedPhysPtr=" + nSortedPhysPtr)
                \nPhysicalDevPtr = gaAudioDevSorted(nSortedPhysPtr)\nPhysDevPtr
                debugMsg(sProcName, "grMapsForDevChgs\aDev(" + d2 + ")\nPhysicalDevPtr=" + \nPhysicalDevPtr)
                \sPhysicalDev = gaAudioDevSorted(nSortedPhysPtr)\sDesc
                \bNoDevice = gaAudioDevSorted(nSortedPhysPtr)\bNoDevice
                \bDefaultDev = gaAudioDevSorted(nSortedPhysPtr)\bDefaultDev
                debugMsg(sProcName, "grMapsForDevChgs\aDev(" + d2 + ")\sPhysicalDev=" + \sPhysicalDev)
                If \bNoDevice
                  bUsingNoDevice = #True
                  \nFirst1BasedOutputChan = 0
                  \s1BasedOutputRange = ""
                  \s0BasedOutputRangeAG = ""
                  nLastOutputUsed = 0
                Else
                  \nFirst1BasedOutputChan = nLastOutputUsed + 1
                  debugMsg(sProcName, "grMapsForDevChgs\aDev(" + d2 + ")\s1BasedOutputRange=" + \s1BasedOutputRange)
                  \s1BasedOutputRange = build1BasedOutputRangeString(\nFirst1BasedOutputChan, \nNrOfDevOutputChans, \nPhysicalDevPtr)
                  debugMsg(sProcName, "grMapsForDevChgs\aDev(" + d2 + ")\s1BasedOutputRange=" + \s1BasedOutputRange)
                  nLastOutputUsed + \nNrOfDevOutputChans
                EndIf
            EndSelect
            
          EndIf
        EndIf
        d2 = \nNextDevIndex
      EndWith
    Wend
  EndIf
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure setInputDevMapDevPtrs(pAudPtr)
  PROCNAMECA(pAudPtr)
  Protected d
  Protected sLogicalDev.s
  Protected nDevMapDevPtr
  
  If pAudPtr >= 0
    With aAud(pAudPtr)
      If \bAudTypeI
        For d = 0 To grLicInfo\nMaxLiveDevPerAud
          sLogicalDev = \sInputLogicalDev[d]
          If sLogicalDev
            nDevMapDevPtr = getDevMapDevPtrForLogicalDev(@grMaps, #SCS_DEVGRP_LIVE_INPUT, sLogicalDev)
          Else
            nDevMapDevPtr = -1
          EndIf
          \nInputDevMapDevPtr[d] = nDevMapDevPtr
        Next d
      EndIf
    EndWith
  EndIf
EndProcedure

Procedure holdDevMapFile(sDevMapFile.s)
  PROCNAMEC()
  Protected nHoldDevMapFile, nStringFormat
  Protected sLine.s
  
  debugMsg(sProcName, #SCS_START)
  
  gnDevMapLineCount = 0
  nHoldDevMapFile = ReadFile(#PB_Any, sDevMapFile, #PB_File_SharedRead)
  If nHoldDevMapFile
    nStringFormat = ReadStringFormat(nHoldDevMapFile)
    While Eof(nHoldDevMapFile) = 0
      sLine = ReadString(nHoldDevMapFile, nStringFormat)
      gnDevMapLineCount + 1
      If gnDevMapLineCount > ArraySize(gsDevMapLine())
        ReDim gsDevMapLine(gnDevMapLineCount+100)
      EndIf
      gsDevMapLine(gnDevMapLineCount-1) = sLine
    Wend
    CloseFile(nHoldDevMapFile)
  EndIf
  
  debugMsg(sProcName, #SCS_END + ", gnDevMapLineCount=" + Str(gnDevMapLineCount))
  
EndProcedure

Procedure deleteMarkedDevMaps()
  PROCNAMEC()
  Protected n1, n2
  
  ; remove any device maps to be deleted
  n1 = 0
  While n1 <= grMaps\nMaxMapIndex
    If grMaps\aMap(n1)\bDeleteThisDevMap
      debugMsg(sProcName, "deleting Device Map " + grMaps\aMap(n1)\sDevMapName)
      For n2 = n1+1 To grMaps\nMaxMapIndex
        grMaps\aMap(n2-1) = grMaps\aMap(n2)
      Next n2
      grMaps\nMaxMapIndex - 1
    Else
      n1 + 1
    EndIf
  Wend
  
EndProcedure

Procedure removeDeadDevMaps()
  PROCNAMEC()
  ; procedure to try to clean up some rubbish
  Protected d, nDevMapDevPtr
  Protected sDevMapName.s
  Protected sLogicalDev.s
  Protected n1, n2
  Protected d2
  Protected nDelCount
  Protected nDevType
  Protected nOrigDevMapPtr, sOrigDevMapName.s
  
  gbDevMapsDeleted = #False
  
  With grProd
    nOrigDevMapPtr = \nSelectedDevMapPtr
    If nOrigDevMapPtr >= 0
      sOrigDevMapName = grMaps\aMap(nOrigDevMapPtr)\sDevMapName
    EndIf
  EndWith
  
  nDelCount = 0
  For n1 = 0 To grMaps\nMaxMapIndex
    grMaps\aMap(n1)\bDeleteThisDevMap = #True
    ; debugMsg(sProcName, "grMaps\aMap(" + n1 + ")\bDeleteThisDevMap=" + strB(grMaps\aMap(n1)\bDeleteThisDevMap))
    nDevMapDevPtr = grMaps\aMap(n1)\nFirstDevIndex
    ; debugMsg(sProcName, "n1=" + n1 + ", nDevMapDevPtr=" + nDevMapDevPtr)
    While nDevMapDevPtr >= 0
      With grMaps\aDev(nDevMapDevPtr)
        ; debugMsg(sProcName, "grMaps\aDev(" + nDevMapDevPtr + ")\sLogicalDev=" + \sLogicalDev + ", \nDevType=" + decodeDevType(\nDevType))
        sLogicalDev = \sLogicalDev
        Select \nDevType
          Case #SCS_DEVTYPE_AUDIO_OUTPUT
            If sLogicalDev
              For d = 0 To grProd\nMaxAudioLogicalDev
                ; debugMsg(sProcName, "grProd\aAudioLogicalDevs(" + d + ")\sLogicalDev=" + \sLogicalDev + ", \sPhysicalDev=" + \sPhysicalDev)
                If grProd\aAudioLogicalDevs(d)\sLogicalDev = sLogicalDev
                  If \sPhysicalDev
                    grMaps\aMap(n1)\bDeleteThisDevMap = #False
                    ; debugMsg(sProcName, "grMaps\aMap(" + n1 + ")\bDeleteThisDevMap=" + strB(grMaps\aMap(n1)\bDeleteThisDevMap))
                    Break
                  EndIf
                EndIf
              Next d
            EndIf
          Case #SCS_DEVTYPE_VIDEO_AUDIO
            If sLogicalDev
              For d = 0 To grProd\nMaxVidAudLogicalDev
                ; debugMsg(sProcName, "grProd\aAudioLogicalDevs(" + d + ")\sLogicalDev=" + \sLogicalDev + ", \sPhysicalDev=" + \sPhysicalDev)
                If grProd\aVidAudLogicalDevs(d)\sVidAudLogicalDev = sLogicalDev
                  If \sPhysicalDev
                    grMaps\aMap(n1)\bDeleteThisDevMap = #False
                    ; debugMsg(sProcName, "grMaps\aMap(" + n1 + ")\bDeleteThisDevMap=" + strB(grMaps\aMap(n1)\bDeleteThisDevMap))
                    Break
                  EndIf
                EndIf
              Next d
            EndIf
          Case #SCS_DEVTYPE_NONE
            ; no action
          Default
            ; any other device type - make sure device map is kept
            grMaps\aMap(n1)\bDeleteThisDevMap = #False
            debugMsg(sProcName, "grMaps\aMap(" + n1 + ")\bDeleteThisDevMap=" + strB(grMaps\aMap(n1)\bDeleteThisDevMap))
        EndSelect
        nDevMapDevPtr = \nNextDevIndex
      EndWith
      If grMaps\aMap(n1)\bDeleteThisDevMap = #False
        Break
      EndIf
    Wend
    If grMaps\aMap(n1)\bDeleteThisDevMap
      debugMsg(sProcName, "Delete DevMap " + #DQUOTE$ + grMaps\aMap(n1)\sDevMapName + #DQUOTE$)
      nDelCount + 1
    EndIf
    ; debugMsg(sProcName, "nDelCount=" + nDelCount)
  Next n1
  
  If nDelCount
    deleteMarkedDevMaps()
    gbDevMapsDeleted = #True
  EndIf
  
  ; look for duplicate device maps
  ; clear deletion flags
  For n1 = 0 To grMaps\nMaxMapIndex
    grMaps\aMap(n1)\bDeleteThisDevMap = #False
  Next n1
  nDelCount = 0
  For n1 = 0 To grMaps\nMaxMapIndex
    If grMaps\aMap(n1)\bDeleteThisDevMap = #False  ; ignore if already marked for deletion
      sDevMapName = grMaps\aMap(n1)\sDevMapName
      For n2 = n1+1 To grMaps\nMaxMapIndex
        If grMaps\aMap(n2)\sDevMapName = sDevMapName
          ; duplicate found - delete the duplicate
          grMaps\aMap(n2)\bDeleteThisDevMap = #True
          nDelCount + 1
        EndIf
      Next n2
    EndIf
  Next n1
  
  If nDelCount
    deleteMarkedDevMaps()
    gbDevMapsDeleted = #True
  EndIf
  
  ; debugMsg(sProcName, "look for duplicate devices")
  ; look for duplicate devices
  ; clear deletion flags
  For n1 = 0 To grMaps\nMaxMapIndex
    nDevMapDevPtr = grMaps\aMap(n1)\nFirstDevIndex
    While nDevMapDevPtr >= 0
      With grMaps\aDev(nDevMapDevPtr)
        \bDeleteThisDev = #False
        nDevMapDevPtr = \nNextDevIndex
      EndWith
    Wend
  Next n1
  
  nDelCount = 0
  For n1 = 0 To grMaps\nMaxMapIndex
    nDevMapDevPtr = grMaps\aMap(n1)\nFirstDevIndex
    While nDevMapDevPtr >= 0
      With grMaps\aDev(nDevMapDevPtr)
        If \bDeleteThisDev = #False  ; ignore if already marked for deletion
          nDevType = \nDevType
          sLogicalDev = \sLogicalDev
          d2 = \nNextDevIndex
          While d2 >= 0
            If grMaps\aDev(d2)\nDevType = nDevType And grMaps\aDev(d2)\sLogicalDev = sLogicalDev
              grMaps\aDev(d2)\bDeleteThisDev = #True
              nDelCount + 1
            EndIf
            d2 = grMaps\aDev(d2)\nNextDevIndex
          Wend
        EndIf
        nDevMapDevPtr = \nNextDevIndex
      EndWith
    Wend
  Next n1
  
  For n1 = 0 To grMaps\nMaxMapIndex
    If grMaps\aMap(n1)\sDevMapName = sOrigDevMapName
      grProd\nSelectedDevMapPtr = n1
      Break
    EndIf
  Next n1
  
  ; debugMsg(sProcName, #SCS_END + ", gbDevMapsDeleted=" + strB(gbDevMapsDeleted) + ", grProd\nSelectedDevMapPtr=" + grProd\nSelectedDevMapPtr)
  
EndProcedure

Procedure validateDevMaps()
  PROCNAMEC()
  ; procedure created to try to trap some odd things that are happening
  Protected n1, n2, n3, d
  Protected nDevMapId, sDevMapName.s, sNewDevMapName.s
  Protected nNewNo
  Protected bFound
  Protected sMsg.s
  Protected bErrorFound
  Protected nDevNo
  
  debugMsg(sProcName, #SCS_START)
  
;   debugMsg(sProcName, "ArraySize(grMaps\aMap())=" + ArraySize(grMaps\aMap()) + ", calling listAllDevMaps()")
;   listAllDevMaps()
  debugMsg(sProcName, "calling removeDeadDevMaps()")
  removeDeadDevMaps()
;   debugMsg(sProcName, "ArraySize(grMaps\aMap())=" + ArraySize(grMaps\aMap()) + ", calling listAllDevMaps()")
;   listAllDevMaps()
  
  debugMsg(sProcName, "grMaps\nMaxMapIndex=" + Str(grMaps\nMaxMapIndex))
  
  ; make sure devmap names are unique (found duplicated devmap name in dump from John Hutchinson (25/9/2012))
  For n1 = 0 To grMaps\nMaxMapIndex
    sDevMapName = grMaps\aMap(n1)\sDevMapName
    For n2 = n1+1 To grMaps\nMaxMapIndex
      If grMaps\aMap(n2)\sDevMapName = sDevMapName
        ; duplicated entry found, so rename the duplicate
        ; generate a new name that is not already in use
        bFound = #True
        nNewNo = 0
        While bFound
          nNewNo + 1
          sNewDevMapName = sDevMapName + Str(nNewNo)
          bFound = #False
          For n3 = 0 To grMaps\nMaxMapIndex
            If grMaps\aMap(n3)\sDevMapName = sNewDevMapName
              bFound = #True
              Break
            EndIf
          Next n3
        Wend
        bErrorFound = #True
        If sMsg
          sMsg + Chr(10)
        EndIf
        sMsg + "Duplicate Device Map Name found: " + sDevMapName + Chr(10) + "Changing duplicate name to " + sNewDevMapName
        debugMsg(sProcName, ReplaceString(sMsg, Chr(10), " "))
      EndIf
    Next
  Next n1
  
  ; make sure devmapid's are in sync
  For n1 = 0 To grMaps\nMaxMapIndex
    nDevMapId = grMaps\aMap(n1)\nDevMapId
    sDevMapName = grMaps\aMap(n1)\sDevMapName
    nDevNo = 1
    d = grMaps\aMap(n1)\nFirstDevIndex
    While d >= 0
      CheckSubInRange(d, ArraySize(grMaps\aDev()), "grMaps\aDev() " + sDevMapName + ", nDevNo=" + nDevNo)
      With grMaps\aDev(d)
        If \nDevMapId <> nDevMapId
          bErrorFound = #True
          If sMsg
            sMsg + Chr(10)
          EndIf
          sMsg + "nDevMapId incorrect! Device Map " + sDevMapName + ", Device No. " + nDevNo + ", grMaps\aDev(" + d + ")\nDevId=" + \nDevId + ", \nDevMapId=" + \nDevMapId + ", grMaps\aMap(" + n1 + ")\nDevMapId=" + grMaps\aMap(n1)\nDevMapId
        EndIf
        d = \nNextDevIndex
        nDevNo + 1
      EndWith
    Wend
  Next n1
  
  ; display error message if necessary
  If bErrorFound
    debugMsg(sProcName, sMsg)
    sMsg + Chr(10) + Chr(10) + "Please email the file " + #DQUOTE$ + gsDebugFile + #DQUOTE$ + " to " + #SCS_EMAIL_SUPPORT
    ensureSplashNotOnTop()
    scsMessageRequester(sProcName, sMsg, #MB_ICONEXCLAMATION)
  EndIf
  
  debugMsg(sProcName, "bErrorFound=" + strB(bErrorFound))
  If bErrorFound
    ProcedureReturn #False
  Else
    ProcedureReturn #True
  EndIf
  
EndProcedure

Procedure setDevMapPtrs(bPrimaryFile=#True)
  PROCNAMEC()
  Protected n1
  
  If bPrimaryFile
    For n1 = 0 To grMaps\nMaxMapIndex
      If grMaps\aMap(n1)\sDevMapName = grMaps\sSelectedDevMapName ; gsSelectedDevMapName
        grProd\nSelectedDevMapPtr = n1
        Break
      EndIf
    Next n1
    debugMsg(sProcName, "grProd\nSelectedDevMapPtr=" + grProd\nSelectedDevMapPtr)
  Else
    For n1 = 0 To grMapsForImport\nMaxMapIndex
      If grMapsForImport\aMap(n1)\sDevMapName = grMapsForImport\sSelectedDevMapName ; gsSelectedDevMapName2
        gr2ndProd\nSelectedDevMapPtr = n1
        Break
      EndIf
    Next n1
    debugMsg(sProcName, "gr2ndProd\nSelectedDevMapPtr=" + gr2ndProd\nSelectedDevMapPtr)
  EndIf
  
EndProcedure

Procedure addMissingDevsToDevChgsDevMaps()
  PROCNAMEC()
  Protected nDevNo
  Protected nDevMapPtr, nDevMapDevPtr
  
  debugMsg(sProcName, #SCS_START)
  
  For nDevMapPtr = 0 To grMapsForDevChgs\nMaxMapIndex
    debugMsg(sProcName, "--- grMapsForDevChgs\aMap(" + nDevMapPtr + ")\sDevMapName=" + grMapsForDevChgs\aMap(nDevMapPtr)\sDevMapName)
    
    For nDevNo = 0 To grProdForDevChgs\nMaxAudioLogicalDev
      With grProdForDevChgs\aAudioLogicalDevs(nDevNo)
        If \sLogicalDev
          nDevMapDevPtr = getDevMapDevPtrForLogicalDev(@grMapsForDevChgs, #SCS_DEVGRP_AUDIO_OUTPUT, \sLogicalDev, nDevMapPtr)
          If nDevMapDevPtr < 0
            nDevMapDevPtr = addDevToDevChgsDevMap(#SCS_DEVGRP_AUDIO_OUTPUT, \nDevType, \nDevId, \sLogicalDev, \nNrOfOutputChans, 0, nDevMapPtr)
            debugMsg2(sProcName, "addDevToDevChgsDevMap(#SCS_DEVGRP_AUDIO_OUTPUT, " + decodeDevType(\nDevType) + ", " + \nDevId + ", " + \sLogicalDev + ", " + \nNrOfOutputChans + ", 0, " + nDevMapPtr + ")", nDevMapDevPtr)
          EndIf
        EndIf
      EndWith
    Next nDevNo
    
    For nDevNo = 0 To grProdForDevChgs\nMaxVidAudLogicalDev
      With grProdForDevChgs\aVidAudLogicalDevs(nDevNo)
        If \sVidAudLogicalDev
          nDevMapDevPtr = getDevMapDevPtrForLogicalDev(@grMapsForDevChgs, #SCS_DEVGRP_VIDEO_AUDIO, \sVidAudLogicalDev, nDevMapPtr)
          If nDevMapDevPtr < 0
            nDevMapDevPtr = addDevToDevChgsDevMap(#SCS_DEVGRP_VIDEO_AUDIO, \nDevType, \nDevId, \sVidAudLogicalDev, \nNrOfOutputChans, 0, nDevMapPtr)
            debugMsg2(sProcName, "addDevToDevChgsDevMap(#SCS_DEVGRP_VIDEO_AUDIO, " + decodeDevType(\nDevType) + ", " + \nDevId + ", " + \sVidAudLogicalDev + ", " + \nNrOfOutputChans + ", 0, " + nDevMapPtr + ")", nDevMapDevPtr)
          EndIf
        EndIf
      EndWith
    Next nDevNo
    
    For nDevNo = 0 To grProdForDevChgs\nMaxVidCapLogicalDev
      With grProdForDevChgs\aVidCapLogicalDevs(nDevNo)
        If \sLogicalDev
          nDevMapDevPtr = getDevMapDevPtrForLogicalDev(@grMapsForDevChgs, #SCS_DEVGRP_VIDEO_CAPTURE, \sLogicalDev, nDevMapPtr)
          If nDevMapDevPtr < 0
            nDevMapDevPtr = addDevToDevChgsDevMap(#SCS_DEVGRP_VIDEO_CAPTURE, \nDevType, \nDevId, \sLogicalDev, 0, 0, nDevMapPtr)
            debugMsg2(sProcName, "addDevToDevChgsDevMap(#SCS_DEVGRP_VIDEO_CAPTURE, " + decodeDevType(\nDevType) + ", " + \nDevId + ", " + \sLogicalDev + ", 0, 0, " + nDevMapPtr + ")", nDevMapDevPtr)
          EndIf
        EndIf
      EndWith
    Next nDevNo
    
    For nDevNo = 0 To grProdForDevChgs\nMaxLiveInputLogicalDev
      With grProdForDevChgs\aLiveInputLogicalDevs(nDevNo)
        If \sLogicalDev
          nDevMapDevPtr = getDevMapDevPtrForLogicalDev(@grMapsForDevChgs, #SCS_DEVGRP_LIVE_INPUT, \sLogicalDev, nDevMapPtr)
          If nDevMapDevPtr < 0
            nDevMapDevPtr = addDevToDevChgsDevMap(#SCS_DEVGRP_LIVE_INPUT, \nDevType, \nDevId, \sLogicalDev, 0, \nNrOfInputChans, nDevMapPtr)
            debugMsg2(sProcName, "addDevToDevChgsDevMap(#SCS_DEVGRP_LIVE_INPUT, " + decodeDevType(\nDevType) + ", " + \nDevId + ", " + \sLogicalDev + ", 0, " + \nNrOfInputChans + ", " + nDevMapPtr + ")", nDevMapDevPtr)
          EndIf
        EndIf
      EndWith
    Next nDevNo
    
    For nDevNo = 0 To grProdForDevChgs\nMaxLightingLogicalDev
      With grProdForDevChgs\aLightingLogicalDevs(nDevNo)
        If \sLogicalDev
          nDevMapDevPtr = getDevMapDevPtrForLogicalDev(@grMapsForDevChgs, #SCS_DEVGRP_LIGHTING, \sLogicalDev, nDevMapPtr)
          If nDevMapDevPtr < 0
            nDevMapDevPtr = addDevToDevChgsDevMap(#SCS_DEVGRP_LIGHTING, \nDevType, \nDevId, \sLogicalDev, 0, 0, nDevMapPtr)
            debugMsg2(sProcName, "addDevToDevChgsDevMap(#SCS_DEVGRP_LIGHTING, " + decodeDevType(\nDevType) + ", " + \nDevId + ", " + \sLogicalDev + ", 0, 0, " + nDevMapPtr + ")", nDevMapDevPtr)
          EndIf
        EndIf
      EndWith
    Next nDevNo
    
    For nDevNo = 0 To grProdForDevChgs\nMaxCtrlSendLogicalDev
      With grProdForDevChgs\aCtrlSendLogicalDevs(nDevNo)
        If \sLogicalDev
          nDevMapDevPtr = getDevMapDevPtrForLogicalDev(@grMapsForDevChgs, #SCS_DEVGRP_CTRL_SEND, \sLogicalDev, nDevMapPtr)
          If nDevMapDevPtr < 0
            nDevMapDevPtr = addDevToDevChgsDevMap(#SCS_DEVGRP_CTRL_SEND, \nDevType, \nDevId, \sLogicalDev, 0, 0, nDevMapPtr)
            debugMsg2(sProcName, "addDevToDevChgsDevMap(#SCS_DEVGRP_CTRL_SEND, " + decodeDevType(\nDevType) + ", " + \nDevId + ", " + \sLogicalDev + ", 0, 0, " + nDevMapPtr + ")", nDevMapDevPtr)
          EndIf
        EndIf
      EndWith
    Next nDevNo
    
    For nDevNo = 0 To grProdForDevChgs\nMaxCueCtrlLogicalDev
      With grProdForDevChgs\aCueCtrlLogicalDevs(nDevNo)
        If (\sCueCtrlLogicalDev) And (\nDevType <> #SCS_DEVTYPE_NONE)
          nDevMapDevPtr = getDevMapDevPtrForLogicalDev(@grMapsForDevChgs, #SCS_DEVGRP_CUE_CTRL, \sCueCtrlLogicalDev, nDevMapPtr)
          If nDevMapDevPtr < 0
            nDevMapDevPtr = addDevToDevChgsDevMap(#SCS_DEVGRP_CUE_CTRL, \nDevType, \nDevId, \sCueCtrlLogicalDev, 0, 0, nDevMapPtr)
          Else
            updateDevChgsDev(#SCS_DEVGRP_CUE_CTRL, \nDevType, nDevNo, \sCueCtrlLogicalDev)
          EndIf
        EndIf
      EndWith
    Next nDevNo
    
  Next nDevMapPtr
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure removeMissingDevsFromDevChgsDevMaps()
  PROCNAMEC()
  Protected d, nDevNo, bFound
  Protected nDevMapPtr, nDevMapDevPtr
  Protected nDelCount, nPrevDevIndex
  
  debugMsg(sProcName, #SCS_START)
  
  For nDevMapPtr = 0 To grMapsForDevChgs\nMaxMapIndex
    debugMsg(sProcName, "--- grMapsForDevChgs\aMap(" + nDevMapPtr + ")\sDevMapName=" + grMapsForDevChgs\aMap(nDevMapPtr)\sDevMapName)
    d = grMapsForDevChgs\aMap(nDevMapPtr)\nFirstDevIndex
    nPrevDevIndex = -1
    While d >= 0
      With grMapsForDevChgs\aDev(d)
        bFound = #False
        Select \nDevGrp
          Case #SCS_DEVGRP_AUDIO_OUTPUT
            For nDevNo = 0 To grProdForDevChgs\nMaxAudioLogicalDev
              If grProdForDevChgs\aAudioLogicalDevs(nDevNo)\sLogicalDev = \sLogicalDev : bFound = #True : Break : EndIf
            Next nDevNo
          Case #SCS_DEVGRP_VIDEO_AUDIO
            For nDevNo = 0 To grProdForDevChgs\nMaxVidAudLogicalDev
              If grProdForDevChgs\aVidAudLogicalDevs(nDevNo)\sVidAudLogicalDev = \sLogicalDev : bFound = #True : Break : EndIf
            Next nDevNo
          Case #SCS_DEVGRP_VIDEO_CAPTURE
            For nDevNo = 0 To grProdForDevChgs\nMaxVidCapLogicalDev
              If grProdForDevChgs\aVidCapLogicalDevs(nDevNo)\sLogicalDev = \sLogicalDev : bFound = #True : Break : EndIf
            Next nDevNo
          Case #SCS_DEVGRP_LIGHTING
            For nDevNo = 0 To grProdForDevChgs\nMaxLightingLogicalDev
              If grProdForDevChgs\aLightingLogicalDevs(nDevNo)\sLogicalDev = \sLogicalDev : bFound = #True : Break : EndIf
            Next nDevNo
          Case #SCS_DEVGRP_CTRL_SEND
            For nDevNo = 0 To grProdForDevChgs\nMaxCtrlSendLogicalDev
              If grProdForDevChgs\aCtrlSendLogicalDevs(nDevNo)\sLogicalDev = \sLogicalDev : bFound = #True : Break : EndIf
            Next nDevNo
          Case #SCS_DEVGRP_CUE_CTRL
            For nDevNo = 0 To grProdForDevChgs\nMaxCueCtrlLogicalDev
              If grProdForDevChgs\aCueCtrlLogicalDevs(nDevNo)\sCueCtrlLogicalDev = \sLogicalDev : bFound = #True : Break : EndIf
            Next nDevNo
        EndSelect
        If bFound = #False
          nDelCount + 1
          debugMsg(sProcName, "Deleting " + decodeDevType(grMapsForDevChgs\aDev(d)\nDevType) + ", \sLogicalDev=" + \sLogicalDev)
          ; Adjust appropriate pointer to bypss this now deleted device (ie delete from the device map)
          If nPrevDevIndex = -1
            grMapsForDevChgs\aMap(nDevMapPtr)\nFirstDevIndex = \nNextDevIndex
          Else
            grMapsForDevChgs\aDev(nPrevDevIndex)\nNextDevIndex = \nNextDevIndex
          EndIf
        Else
          nPrevDevIndex = d
        EndIf
        d = \nNextDevIndex
      EndWith
    Wend
  Next nDevMapPtr
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure copyDevStatesFromDevChgsToDev()
  PROCNAMEC()
  Protected d, n
  
  debugMsg(sProcName, #SCS_START)
  
  ; copy device \nDevState variables from grMapsForDevChgs\aDevMap to gaDevMap as some inactive devices may now be active
  ; debugMsg(sProcName, "grMapsForDevChgs\nMaxMapIndex=" + grMapsForDevChgs\nMaxMapIndex)
  For n = 0 To grMapsForDevChgs\nMaxMapIndex
    ; debugMsg(sProcName, "grMaps\aMap(" + n + ")\nDevMapId=" + grMaps\aMap(n)\nDevMapId + ", grMapsForDevChgs\aMap(" + n + ")\nDevMapId=" + grMapsForDevChgs\aMap(n)\nDevMapId)
    debugMsg(sProcName, "n=" + n + ", ArraySize(grMaps\aMap())=" + ArraySize(grMaps\aMap()) + ", ArraySize(grMapsForDevChgs\aMap())=" + ArraySize(grMapsForDevChgs\aMap()))
    If ArraySize(grMaps\aMap()) < grMapsForDevChgs\nMaxMapIndex
      debugMsg(sProcName, "calling ReDim grMaps\aMap(" + grMapsForDevChgs\nMaxMapIndex + ")")
      ReDim grMaps\aMap(grMapsForDevChgs\nMaxMapIndex)
    EndIf
    If grMaps\aMap(n)\nDevMapId = grMapsForDevChgs\aMap(n)\nDevMapId
      d = grMapsForDevChgs\aMap(n)\nFirstDevIndex
      While d >= 0
        If d <= ArraySize(grMaps\aDev())
          ; debugMsg(sProcName, "grMaps\aDev(" + d + ")\nDevId=" + grMaps\aDev(d)\nDevId + ", grMapsForDevChgs\aDev(" + d + ")\nDevId=" + grMapsForDevChgs\aDev(d)\nDevId)
          If grMaps\aDev(d)\nDevId = grMapsForDevChgs\aDev(d)\nDevId
            ; debugMsg(sProcName, "grMaps\aDev(" + d + ")\nDevState=" + decodeDevState(grMaps\aDev(d)\nDevState) + ", grMapsForDevChgs\aDev(" + d + ")\nDevState=" + decodeDevState(grMapsForDevChgs\aDev(d)\nDevState))
            If grMaps\aDev(d)\nDevState <> grMapsForDevChgs\aDev(d)\nDevState
              debugMsg(sProcName, "changing grMaps\aDev(" + d + ")\nDevState from " + decodeDevState(grMaps\aDev(d)\nDevState) + " To " + decodeDevState(grMapsForDevChgs\aDev(d)\nDevState))
            EndIf
            grMaps\aDev(d)\nDevState = grMapsForDevChgs\aDev(d)\nDevState
            ; debugMsg(sProcName, "grMapsForDevChgs\aDev(" + d + ")\nReassignDevMapDevPtr=" + grMapsForDevChgs\aDev(d)\nReassignDevMapDevPtr + ", \nMixerStreamPtr=" + grMapsForDevChgs\aDev(d)\nMixerStreamPtr)
          EndIf
        EndIf
        d = grMapsForDevChgs\aDev(d)\nNextDevIndex
      Wend
    EndIf
  Next n
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure openLightingAndCueCtrlDMXDevsIfReqd()
  PROCNAMEC()
  
  debugMsg(sProcName, #SCS_START)
  
  ASSERT_THREAD(#SCS_THREAD_MAIN)
  
  If gbDMXAvailable
    debugMsg(sProcName, "calling DMX_loadDMXControl()")
    DMX_loadDMXControl()
    debugMsg(sProcName, "calling DMX_openDMXDevs()")
    DMX_openDMXDevs()
    debugMsg(sProcName, "calling setDMXEnabled()")
    setDMXEnabled()
  EndIf
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure addCommonDevItems(*nDeviceNode, nDevIndex)
  PROCNAMEC()
  
  With grMaps\aDev(nDevIndex)
    addXMLItem(*nDeviceNode, "DevName", \sLogicalDev)
    Select \nDevType
      Case #SCS_DEVTYPE_AUDIO_OUTPUT, #SCS_DEVTYPE_VIDEO_AUDIO
        If \bDefaultDev = #False
          If \sPhysicalDev = grMMedia\sDefAudDevDesc
            debugMsg(sProcName, "setting \bDefaultDev=#True for \nDevType=" + decodeDevType(\nDevType) + ", \sLogicalDev=" + \sLogicalDev)
            \bDefaultDev = #True
          EndIf
        EndIf
    EndSelect
    If \bDefaultDev And (\sPhysicalDev = grMMedia\sDefAudDevDesc Or \sPhysicalDev = "Default Audio Device") ; Added \sPhysicalDev test 14Nov2022 11.9.7ae (NB language translation not necessarily applicable, as confirmed in log file from Michel Winogradoff)
      debugMsg(sProcName, "grMaps\aDev(" + nDevIndex + ")\sLogicalDev=" + \sLogicalDev + ", DefaultDev=" + strB(\bDefaultDev))
      addXMLItem(*nDeviceNode, "DefaultDev", booleanToString(\bDefaultDev))
    Else
      debugMsg(sProcName, "grMaps\aDev(" + nDevIndex + ")\sLogicalDev=" + \sLogicalDev + ", PhysDev=" + \sPhysicalDev)
      addXMLItem(*nDeviceNode, "PhysDev", \sPhysicalDev)
      addXMLItemIfReqd(*nDeviceNode, "Dummy", booleanToString(\bDummy), booleanToString(grDevMapDevDef\bDummy))  ; added 23Nov2016 11.5.2.4
    EndIf
  EndWith
  
EndProcedure

Procedure.s writeXMLDevMapFile(sSelectedDevMapName.s, sProdId.s, bSaveToProdFolder=#False, bSaveToExportFile=#False, bSaveToTemplateFolder=#False)
  PROCNAMEC()
  Protected xmlDevMaps
  Protected *nRootNode, *nHeadNode, *nDevMapNode, *nDeviceNode, *nFileSaveInfoNode, *nMidiCommandNode, *nDMXCommandNode
  Protected *nLiveGrpNode, *nCompNode, *nFixtureNode
  Protected *nEQBandNode
  Protected n1, n2, n3
  Protected nEQBand, nFixtureIndex
  Protected sCmd.s, sTmp.s
  Protected sDevMapFile.s
  Protected nResult
  Protected nDateTimeNow
  Protected bSelectedDevMapFound
  Protected nSelectedDevMapPtr ; Added 20Jun2022 11.9.4
  Protected bWantThisEQBand
  Protected nMsgResponseCount, *nMsgResponseNode
  Protected bSavePlugins
  Protected n, *nVSTGroupNode, *nVSTPluginNode
  
  debugMsg(sProcName, #SCS_START + ", sSelectedDevMapName=" + #DQUOTE$ + sSelectedDevMapName + #DQUOTE$ + ", sProdId=" + sProdId +
                      ", bSaveToProdFolder=" + strB(bSaveToProdFolder) + ", bSaveToExportFile=" + strB(bSaveToExportFile) + ", bSaveToTemplateFolder=" + strB(bSaveToTemplateFolder))
  
  If (bSaveToProdFolder = #False) And (bSaveToExportFile = #False) And (bSaveToTemplateFolder = #False)
    ; prevent recursion
    debugMsg(sProcName, "calling validateDevMaps()")
    validateDevMaps()
  EndIf
  
  ; Create xml tree
  xmlDevMaps = CreateXML(#PB_Any)
  *nRootNode = CreateXMLNode(RootXMLNode(xmlDevMaps), "DevMaps")
  
  *nHeadNode = addXMLNode(*nRootNode, "Head")
  addXMLItem(*nHeadNode, "Version", #SCS_FILE_VERSION)
  
  ; debugMsg(sProcName, "ArraySize(grMaps\aMap())=" + ArraySize(grMaps\aMap()))
  ; debugMsg(sProcName, "grMaps\nMaxMapIndex=" + grMaps\nMaxMapIndex)
  nSelectedDevMapPtr = -1 ; Added 20Jun2022 11.9.4
  For n1 = 0 To grMaps\nMaxMapIndex
    debugMsg(sProcName, "grMaps\aMap(" + n1 + ")\sDevMapName=" + grMaps\aMap(n1)\sDevMapName)
    If grMaps\aMap(n1)\sDevMapName
      If grMaps\aMap(n1)\sDevMapName = sSelectedDevMapName
        bSelectedDevMapFound = #True
        nSelectedDevMapPtr = n1 ; Added 20Jun2022 11.9.4
      EndIf
      *nDevMapNode = addXMLNodeWithAttributes(*nRootNode, "DevMap", "DevMapName", grMaps\aMap(n1)\sDevMapName)
      
      If grMaps\aMap(n1)\nAudioDriver > 0
        addXMLItem(*nDevMapNode, "AudioDriver", decodeDriver(grMaps\aMap(n1)\nAudioDriver))
      EndIf
      
      ; audio devices
      ;{
      n2 = grMaps\aMap(n1)\nFirstDevIndex
      While n2 >= 0
        With grMaps\aDev(n2)
          If \sLogicalDev And \sPhysicalDev
            If (\nDevGrp = #SCS_DEVGRP_AUDIO_OUTPUT) And (\bExists)
              *nDeviceNode = addXMLNodeWithAttributes(*nDevMapNode, "Device", "DevType", decodeDevType(\nDevType), "DevGrp", decodeDevGrp(\nDevGrp))
              addCommonDevItems(*nDeviceNode, n2)
              addXMLItem(*nDeviceNode, "Outputs", \s1BasedOutputRange)
              addXMLItemIfReqd(*nDeviceNode, "DelayTime", Str(\nDelayTime), "0")
              addXMLItemIfReqd(*nDeviceNode, "OutputGainDB", \sDevOutputGainDB, "0.0")
            EndIf
          EndIf
          n2 = \nNextDevIndex
        EndWith
      Wend
      ;}
      
      ; video audio devices
      ;{
      n2 = grMaps\aMap(n1)\nFirstDevIndex
      While n2 >= 0
        With grMaps\aDev(n2)
          If \sLogicalDev And \sPhysicalDev
            If (\nDevGrp = #SCS_DEVGRP_VIDEO_AUDIO) And (\bExists)
              *nDeviceNode = addXMLNodeWithAttributes(*nDevMapNode, "Device", "DevType", decodeDevType(\nDevType), "DevGrp", decodeDevGrp(\nDevGrp))
              addCommonDevItems(*nDeviceNode, n2)
              ; addXMLItem(*nDeviceNode, "Outputs", \s1BasedOutputRange)
              addXMLItemIfReqd(*nDeviceNode, "OutputGainDB", \sDevOutputGainDB, "0.0")
            EndIf
          EndIf
          n2 = \nNextDevIndex
        EndWith
      Wend
      ;}
      
      ; video capture devices
      ;{
      n2 = grMaps\aMap(n1)\nFirstDevIndex
      While n2 >= 0
        With grMaps\aDev(n2)
          If \sLogicalDev And \sPhysicalDev
            If (\nDevGrp = #SCS_DEVGRP_VIDEO_CAPTURE) And (\bExists)
              *nDeviceNode = addXMLNodeWithAttributes(*nDevMapNode, "Device", "DevType", decodeDevType(\nDevType), "DevGrp", decodeDevGrp(\nDevGrp))
              addCommonDevItems(*nDeviceNode, n2)
              addXMLItemIfReqd(*nDeviceNode, "VidCapFormat", \sVidCapFormat)
              If \dVidCapFrameRate > 0 ; 0 is 'default frame rate'
                addXMLItem(*nDeviceNode, "VidCapFrameRate", strDTrimmed(\dVidCapFrameRate,2))
              EndIf
            EndIf
          EndIf
          n2 = \nNextDevIndex
        EndWith
      Wend
      ;}
      
      ; live input devices
      ;{
      n2 = grMaps\aMap(n1)\nFirstDevIndex
      While n2 >= 0
        With grMaps\aDev(n2)
          If \sLogicalDev And \sPhysicalDev
            If (\nDevGrp = #SCS_DEVGRP_LIVE_INPUT) And (\bExists)
              *nDeviceNode = addXMLNodeWithAttributes(*nDevMapNode, "Device", "DevType", decodeDevType(\nDevType), "DevGrp", decodeDevGrp(\nDevGrp))
              addCommonDevItems(*nDeviceNode, n2)
              addXMLItem(*nDeviceNode, "Inputs", \s1BasedInputRange)
              addXMLItemIfReqd(*nDeviceNode, "InputDelayTime", Str(\nInputDelayTime), "0")
              If (\sInputGainDB <> "0") And (\sInputGainDB <> "0.0")
                addXMLItem(*nDeviceNode, "InputGainDB", \sInputGainDB)
              EndIf
              addXMLItemIfReqd(*nDeviceNode, "InputLowCutSelected", Str(\bInputLowCutSelected), "0")
              addXMLItem(*nDeviceNode, "InputLowCutFreq", Str(\nInputLowCutFreq))
              For nEQBand = 0 To #SCS_MAX_EQ_BAND
                bWantThisEQBand = #False
                If \aInputEQBand[nEQBand]\bEQBandSelected
                  bWantThisEQBand = #True
                ElseIf (\aInputEQBand[nEQBand]\sEQGainDB <> "0") And (\aInputEQBand[nEQBand]\sEQGainDB <> "0.0")
                  bWantThisEQBand = #True
                ElseIf \aInputEQBand[nEQBand]\nEQFreq <> grDevMapDevDef\aInputEQBand[nEQBand]\nEQFreq
                  bWantThisEQBand = #True
                ElseIf \aInputEQBand[nEQBand]\fEQQ <> grDevMapDevDef\aInputEQBand[nEQBand]\fEQQ
                  bWantThisEQBand = #True
                EndIf
                If bWantThisEQBand
                  *nEQBandNode = addXMLNodeWithAttributes(*nDeviceNode, "InputEQBand", "BandNo", Str(nEQBand+1))
                  addXMLItemIfReqd(*nEQBandNode, "InputEQBandSelected", Str(\aInputEQBand[nEQBand]\bEQBandSelected), "0")
                  If (\aInputEQBand[nEQBand]\sEQGainDB <> "0") And (\aInputEQBand[nEQBand]\sEQGainDB <> "0.0")
                    addXMLItem(*nEQBandNode, "InputEQGainDB", \aInputEQBand[nEQBand]\sEQGainDB)
                  EndIf
                  ; nb always save nEQFreq if band selected so nEQFreq is not affected by possible changes to the default frequency setting
                  addXMLItem(*nEQBandNode, "InputEQFreq", Str(\aInputEQBand[nEQBand]\nEQFreq))
                  ; nb always save fEQQ if band selected so fEQQ is not affected by possible changes to the default Q-Factor setting
                  addXMLItem(*nEQBandNode, "InputEQQ", StrF(\aInputEQBand[nEQBand]\fEQQ,2))
                EndIf
              Next nEQBand
            EndIf
          EndIf
          n2 = \nNextDevIndex
        EndWith
      Wend
      ;}
      
      ; lighting devices
      ;{
      n2 = grMaps\aMap(n1)\nFirstDevIndex
      While n2 >= 0
        With grMaps\aDev(n2)
          If \sLogicalDev And \sPhysicalDev
            If (\nDevGrp = #SCS_DEVGRP_LIGHTING) And (\bExists)
              *nDeviceNode = addXMLNodeWithAttributes(*nDevMapNode, "Device", "DevType", decodeDevType(\nDevType), "DevGrp", decodeDevGrp(\nDevGrp))
              Select \nDevType
                Case #SCS_DEVTYPE_LT_DMX_OUT
                  addCommonDevItems(*nDeviceNode, n2)
                  addXMLItemIfReqd(*nDeviceNode, "DMXNumSerial", Str(\nDMXSerial))
                  addXMLItemIfReqd(*nDeviceNode, "DMXSerial", \sDMXSerial)
                  addXMLItemIfReqd(*nDeviceNode, "DMXPort", Str(\nDMXPort))
                  ; addXMLItemIfReqd(*nDeviceNode, "DMXRefreshRate", Str(\nDMXRefreshRate), "0")
                  addXMLItemIfReqd(*nDeviceNode, "DMXIpAddress", \sDMXIpAddress, "0")
                  addXMLItemIfReqd(*nDeviceNode, "DMXRefreshRate", Str(\nDMXRefreshRate), Str(grDevMapDevDef\nDMXRefreshRate))
                  debugMsg(sProcName, "grMaps\aDev(" + n2 + ")\nMaxFixture=" + \nMaxDevFixture)
                  For nFixtureIndex = 0 To \nMaxDevFixture
                    *nFixtureNode = addXMLNodeWithAttributes(*nDeviceNode, "Fixture", "FixtureCode", \aDevFixture(nFixtureIndex)\sDevFixtureCode)
                    If \aDevFixture(nFixtureIndex)\nDevDMXStartChannel > 0
                      addXMLItem(*nFixtureNode, "DMXStartChannel", Str(\aDevFixture(nFixtureIndex)\nDevDMXStartChannel))
                    EndIf
                    If \aDevFixture(nFixtureIndex)\sDevDMXStartChannels
                      addXMLItem(*nFixtureNode, "DMXStartChannels", \aDevFixture(nFixtureIndex)\sDevDMXStartChannels)
                    EndIf
                  Next nFixtureIndex
              EndSelect
            EndIf
          EndIf
          n2 = \nNextDevIndex
        EndWith
      Wend
      ;}
      
      ; ctrl send devices
      ;{
      n2 = grMaps\aMap(n1)\nFirstDevIndex
      While n2 >= 0
        With grMaps\aDev(n2)
          debugMsg(sProcName, "grMaps\aDev(" + n2 + ")\sLogicalDev=" + \sLogicalDev + ", \sPhysicalDev=" + \sPhysicalDev + ", \nDevGrp=" + decodeDevGrp(\nDevGrp) + ", \nDevType=" + decodeDevType(\nDevType) + ", \bExists=" + strB(\bExists))
          If \sLogicalDev ; And \sPhysicalDev ; Deleted \sPhysicalDev test 18Jun2021 11.8.5al
            If (\nDevGrp = #SCS_DEVGRP_CTRL_SEND) And (\bExists)
              *nDeviceNode = addXMLNodeWithAttributes(*nDevMapNode, "Device", "DevType", decodeDevType(\nDevType), "DevGrp", decodeDevGrp(\nDevGrp))
              Select \nDevType
                Case #SCS_DEVTYPE_CS_MIDI_OUT  ; #SCS_DEVTYPE_CS_MIDI_OUT
                  addCommonDevItems(*nDeviceNode, n2)
                  
                Case #SCS_DEVTYPE_CS_MIDI_THRU ; #SCS_DEVTYPE_CS_MIDI_THRU
                  addCommonDevItems(*nDeviceNode, n2)
                  addXMLItem(*nDeviceNode, "MidiConnectName", \sMidiThruInPhysicalDev)   ; input to be connected if MIDI Out to be MIDI Thru
                  addXMLItemIfReqd(*nDeviceNode, "MidiConnectDummy", booleanToString(\bMidiThruInDummy), booleanToString(grDevMapDevDef\bMidiThruInDummy))
                  
                Case #SCS_DEVTYPE_CS_RS232_OUT ; #SCS_DEVTYPE_CS_RS232_OUT
                  addCommonDevItems(*nDeviceNode, n2)
                  
                Case #SCS_DEVTYPE_CS_NETWORK_OUT  ; #SCS_DEVTYPE_CS_NETWORK_OUT
                  addXMLItem(*nDeviceNode, "DevName", \sLogicalDev)
                  addXMLItemIfReqd(*nDeviceNode, "Dummy", booleanToString(\bDummy), booleanToString(grDevMapDevDef\bDummy))
                  If \bDummy = #False ; Added this test 8Nov2022 11.9.7ab following test of Dave Pursley's cue file where I switched device maps between an IP addresseed TCP server and a dummy TCP server
                    If \sRemoteHost
                      addXMLItemIfReqd(*nDeviceNode, "RemoteHost", \sRemoteHost)
                    EndIf
                    If \nRemotePort ; added 15Aug2018 11.7.0 (was previously under "If \sRemoteHost" but that test could ignore a pre-assigned port for dummy ports
                      addXMLItem(*nDeviceNode, "RemotePort", portIntToStr(\nRemotePort))
                    EndIf
                    If \nLocalPort >= 0
                      addXMLItem(*nDeviceNode, "LocalPort", Str(\nLocalPort))
                    EndIf
                  EndIf
                  If \nCtrlSendDelay >= 0
                    addXMLItemIfReqd(*nDeviceNode, "CtrlSendDelay", Str(\nCtrlSendDelay), Str(grDevMapDevDef\nCtrlSendDelay))
                  EndIf
                  
                Case #SCS_DEVTYPE_CS_HTTP_REQUEST  ; #SCS_DEVTYPE_CS_HTTP_REQUEST
                  addXMLItem(*nDeviceNode, "DevName", \sLogicalDev)
                  
              EndSelect
            EndIf
          EndIf
          n2 = \nNextDevIndex
        EndWith
      Wend
      ;}
      
      ; cue ctrl devices
      ;{
      n2 = grMaps\aMap(n1)\nFirstDevIndex
      While n2 >= 0
        With grMaps\aDev(n2)
          If (\nDevGrp = #SCS_DEVGRP_CUE_CTRL) And (\bExists)
            If (\nDevType <> #SCS_DEVTYPE_NONE) And (\sLogicalDev)
              If (\sPhysicalDev) Or (\nDevType = #SCS_DEVTYPE_CC_NETWORK_IN)
                *nDeviceNode = addXMLNodeWithAttributes(*nDevMapNode, "Device", "DevType", decodeDevType(\nDevType), "DevGrp", decodeDevGrp(\nDevGrp))
                addXMLItem(*nDeviceNode, "DevName", \sLogicalDev)   ; pseudo logical device name (C1/C2/etc)
                Select \nDevType
                  Case #SCS_DEVTYPE_CC_MIDI_IN
                    addXMLItem(*nDeviceNode, "PhysDev", \sPhysicalDev)
                    
                  Case #SCS_DEVTYPE_CC_RS232_IN
                    addXMLItem(*nDeviceNode, "PhysDev", \sPhysicalDev)
                    
                  Case #SCS_DEVTYPE_CC_NETWORK_IN
                    addXMLItemIfReqd(*nDeviceNode, "Dummy", booleanToString(\bDummy), booleanToString(grDevMapDevDef\bDummy))
                    If \sRemoteHost
                      addXMLItemIfReqd(*nDeviceNode, "RemoteHost", \sRemoteHost)
                    EndIf
                    If \nRemotePort > 0
                      addXMLItem(*nDeviceNode, "RemotePort", Str(\nRemotePort))
                    EndIf
                    If \nLocalPort > 0
                      addXMLItem(*nDeviceNode, "LocalPort", Str(\nLocalPort))
                    EndIf
                    
                  Case #SCS_DEVTYPE_CC_DMX_IN
                    addXMLItem(*nDeviceNode, "PhysDev", \sPhysicalDev)
                    addXMLItemIfReqd(*nDeviceNode, "DMXNumSerial", Str(\nDMXSerial))
                    addXMLItemIfReqd(*nDeviceNode, "DMXSerial", \sDMXSerial)
                    addXMLItemIfReqd(*nDeviceNode, "DMXPort", Str(\nDMXPort))
                    
                EndSelect
              EndIf ; EndIf (Len(\sPhysicalDev) > 0) Or (\nDevType = #SCS_DEVTYPE_CC_NETWORK_IN)
            EndIf   ; EndIf (\nDevType <> #SCS_DEVTYPE_NONE) And (Len(\sLogicalDev) > 0)
          EndIf     ; EndIf (\nDevGrp = #SCS_DEVGRP_CUE_CTRL) And (\bExists)
          n2 = \nNextDevIndex
        EndWith
      Wend
      ;}
      
      ; live input groups
      ;{
      n2 = grMaps\aMap(n1)\nFirstLiveGrpIndex
      While n2 >= 0
        With grMaps\aLiveGrp(n2)
          If \sLiveGrpName
            If (\nDevGrp = #SCS_DEVGRP_LIVE_INPUT) And (\bExists)
              *nLiveGrpNode = addXMLNodeWithAttributes(*nDevMapNode, "Group", "GrpName", \sLiveGrpName)
              addXMLItem(*nLiveGrpNode, "GrpDevType", decodeDevType(\nDevType))
              For n3 = 0 To \nCompCount
                If Len(\sCompName[n3]) > 0
                  addXMLItem(*nLiveGrpNode, "CompName", \sCompName[n3])
                EndIf
              Next n3
            EndIf
          EndIf
          n2 = \nNextLiveGrpIndex
        EndWith
      Wend
      ;}
      
    EndIf
  Next n1
  
  If grVST\nMaxLibVSTPlugin >= 0
    *nVSTGroupNode = addXMLNode(*nRootNode, "VSTPlugins")
    For n = 0 To grVST\nMaxLibVSTPlugin
      With grVST\aLibVSTPlugin(n)
        If \sLibVSTPluginName
          *nVSTPluginNode = addXMLNodeWithAttributes(*nVSTGroupNode, "Plugin", "Name", \sLibVSTPluginName)
          If \sLibVSTPluginFile32
            addXMLItem( *nVSTPluginNode, "PluginFile32", \sLibVSTPluginFile32)
          EndIf
          If \sLibVSTPluginFile64
            addXMLItem( *nVSTPluginNode, "PluginFile64", \sLibVSTPluginFile64)
          EndIf
        EndIf          
      EndWith
    Next n
  EndIf
  
  ; Added 18Jun2022 11.9.4
  ; External controller for Faders window
  If nSelectedDevMapPtr >= 0 ; Test added 20Jun2022 11.9.4
    n2 = grMaps\aMap(nSelectedDevMapPtr)\nFirstDevIndex
    While n2 >= 0
      With grMaps\aDev(n2)
        If \nDevGrp = #SCS_DEVGRP_EXT_CONTROLLER And \bExists
          *nDeviceNode = addXMLNodeWithAttributes(*nDevMapNode, "Device", "DevType", decodeDevType(\nDevType), "DevGrp", decodeDevGrp(\nDevGrp))
          addCommonDevItems(*nDeviceNode, n2)
        EndIf
        n2 = \nNextDevIndex
      EndWith
    Wend
  EndIf
  ; End added 17Jun2022 11.9.4
  
  If bSelectedDevMapFound
    addXMLItem(*nRootNode, "SelectedDevMap", sSelectedDevMapName)
  EndIf
  
  ; write file save info
  nDateTimeNow = Date()
  *nFileSaveInfoNode = addXMLNode(*nRootNode, "FileSaveInfo")
  addXMLItem(*nFileSaveInfoNode, "_Saved_", FormatDate("%yyyy/%mm/%dd %hh:%ii:%ss", nDateTimeNow))
  addXMLItem(*nFileSaveInfoNode, "_SCS_Version_", #SCS_VERSION)
  addXMLItem(*nFileSaveInfoNode, "_SCS_Build_", grProgVersion\sBuildDateTime)
  If bSaveToProdFolder
    addXMLItem(*nFileSaveInfoNode, "_Exported_From_", ComputerName())
    addXMLItem(*nFileSaveInfoNode, "_Export_DateTime_", FormatDate("%yyyy/%mm/%dd %hh:%ii:%ss", nDateTimeNow))
    If sProdId
      sDevMapFile = grWPF\sProdFolder + ignoreExtension(GetFilePart(gsCueFile)) + "_" + sProdId + ".scsdx"
    Else
      sDevMapFile = grWPF\sProdFolder + ignoreExtension(GetFilePart(gsCueFile)) + ".scsdx"
    EndIf
  ElseIf bSaveToExportFile
    addXMLItem(*nFileSaveInfoNode, "_Exported_From_", ComputerName())
    addXMLItem(*nFileSaveInfoNode, "_Export_DateTime_", FormatDate("%yyyy/%mm/%dd %hh:%ii:%ss", nDateTimeNow))
    If sProdId
      sDevMapFile = ignoreExtension(gsCueFile) + "_" + sProdId + ".scsdx"
    Else
      sDevMapFile = ignoreExtension(gsCueFile) + ".scsdx"
    EndIf
  ElseIf bSaveToTemplateFolder
    sDevMapFile = ignoreExtension(gsTemplateFile) + ".scstd"
  Else
    If sProdId
      ; file name will be cue file name with an extension of .scsd instead of .scs, but also with the ProdId appended to the cue file name
      sDevMapFile = gsDevMapsPath + ignoreExtension(GetFilePart(gsCueFile)) + "_" + sProdId + ".scsd"
    Else
      ; file name will be cue file name with an extension of .scsd instead of .scs
      sDevMapFile = gsDevMapsPath + ignoreExtension(GetFilePart(gsCueFile)) + ".scsd"
    EndIf
  EndIf
  nResult = saveFormattedXML(xmlDevMaps, sDevMapFile, 0, 2)
  
  FreeXML(xmlDevMaps)
  
  If bSaveToExportFile = #False
    WCN_resetOrigDevs()
  EndIf
  
  debugMsg(sProcName, #SCS_END + ", returning sDevMapFile=" + #DQUOTE$ + sDevMapFile + #DQUOTE$)
  ProcedureReturn sDevMapFile
  
EndProcedure

Macro macScanXMLDevMaps(prMaps, prProd, prVST, pPrimaryFile)
  Protected sNodeName.s, sNodeText.s
  Protected sParentNodeName.s
  Protected Dim sAttributeName.s(1), Dim sAttributeValue.s(1) ; Changed 18Jun2022 11.9.4
  Protected n, n2, n3, d, d2, g2, m, vstCounter
  Protected *nChildNode
  Protected nDevType
  Protected bNodeProcessed
  Protected sMyDevMapName.s
  Protected sDevGrpExt.s
  Protected sMsg.s
  Protected nMyPrevDevIndex, nMyPrevLiveGrpIndex
  Protected nPhysicalDevPtrNew
  Protected nIndex, nBandNo, nCtrlSendDelay
  Protected sDummyDev.s, sDummyDevENUS.s
  Protected sDummyDev2.s, sDummyDevENUS2.s
  Protected Dim sVersionParts.s(2)
  Protected sBuildDate.s
  Static nDevMapPtr
  Static nDevMapId
  Static rThisDev.tyDevMapDev
  Static rThisLiveGrp.tyLiveGrp
  Static rThisDevFixture.tyDevFixture
  Static nCmdIndex, nFixtureIndex
  Static bAudioDriverSet
  Static nAudioDriver
  Static bASIOFound
  Static bDMXTrgCtrlFound
  Static nEQBand
  Static rThisMsgResponse.tyNetworkMsgResponse
  Static nMsgResponseIndex
  Static bIgnoreDevMap
  Static nVersion
  Static nCurrentPluginIndex
  
  ; debugMsg(sProcName, #SCS_START)
  
  ; Ignore anything except normal nodes. See the manual for XMLNodeType() for an explanation of the other node types.
  If XMLNodeType(*CurrentNode) = #PB_XML_Normal
    
    sNodeName = GetXMLNodeName(*CurrentNode)
    If XMLChildCount(*CurrentNode) = 0
      sNodeText = GetXMLNodeText(*CurrentNode)
    EndIf
    gsXMLNodeName(CurrentSublevel) = sNodeName
    If CurrentSublevel > 0
      sParentNodeName = gsXMLNodeName(CurrentSublevel-1)
    EndIf
    
    If ExamineXMLAttributes(*CurrentNode)
      ; Changed 18Jun2022 11.9.4 to allow for more than one attribute
      n = -1
      While NextXMLAttribute(*CurrentNode)
        n + 1
        If n <= ArraySize(sAttributeName())
          sAttributeName(n) = XMLAttributeName(*CurrentNode)
          sAttributeValue(n) = XMLAttributeValue(*CurrentNode)
        Else
          Break
        EndIf
      Wend
      ; End changed 18Jun2022 11.9.4
    EndIf
    
    ; debugMsg(sProcName, ">> sNodeName=" + sNodeName + ", sNodeText=" + sNodeText + ", sAttributeName(0)=" + sAttributeName(0) + ", sAttributeValue(0)=" + sAttributeValue(0))
    If bIgnoreDevMap = #False ; see "DevMapC" regarding tyhe setting of bIgnore
      Select sNodeName
        Case "DevMaps"
          prMaps\nMaxMapIndex = -1
          prMaps\nMaxDevIndex = -1
          prMaps\nMaxLiveGrpIndex = -1
          prMaps\sSelectedDevMapName = ""
          nVersion = 0
          prMaps\nVersion = 0
          
        Case "Head"
          ; no action required
          
        Case "Version"
          For n = 1 To 3
            sVersionParts(n-1) = StringField(sNodeText, n, ".")
          Next n
          nVersion = (Val(sVersionParts(0)) * 10000) + (Val(sVersionParts(1)) * 100) + Val(sVersionParts(2))  ; nb nVersion is static so remains set during the remainder of scanning this devmap file
          prMaps\nVersion = nVersion
          
        Case "DevMap"
          bIgnoreDevMap = #False
          prMaps\nMaxMapIndex + 1
          nDevMapPtr = prMaps\nMaxMapIndex
          If nDevMapPtr > ArraySize(prMaps\aMap())
            REDIM_ARRAY(prMaps\aMap, nDevMapPtr, grDevMapDef, "prMaps\aMap()()")
          EndIf
          If sAttributeName(0) = "DevMapName"
            prMaps\aMap(nDevMapPtr)\sDevMapName = sAttributeValue(0)
          EndIf
          gnUniqueDevMapId + 1
          nDevMapId = gnUniqueDevMapId
          prMaps\aMap(nDevMapPtr)\nDevMapId = nDevMapId
          prMaps\aMap(nDevMapPtr)\nFirstDevIndex = -1
          prMaps\aMap(nDevMapPtr)\nFirstLiveGrpIndex = -1
          prMaps\aMap(nDevMapPtr)\nAudioDriver = gnDefaultAudioDriver
          d2 = prMaps\nMaxDevIndex
          g2 = prMaps\nMaxLiveGrpIndex
          nMyPrevDevIndex = -1
          nMyPrevLiveGrpIndex = -1
          
          bAudioDriverSet = #False
          bASIOFound = #False
          ; initialise devmap with audio devices defined in the production properties
          For d = 0 To prProd\nMaxAudioLogicalDev ; audio devs
            If Len(Trim(prProd\aAudioLogicalDevs(d)\sLogicalDev)) > 0
              d2 + 1
              If d2 > ArraySize(prMaps\aDev())
                REDIM_ARRAY(prMaps\aDev, d2+20, grDevMapDevDef, "prMaps\aDev()")
              EndIf
              If nMyPrevDevIndex < 0
                prMaps\aMap(nDevMapPtr)\nFirstDevIndex = d2
                ; debugMsg(sProcName, "prMaps\aMap()(" + nDevMapPtr + ")\nFirstDevIndex=" + prMaps\aMap(nDevMapPtr)\nFirstDevIndex)
              Else
                prMaps\aDev(nMyPrevDevIndex)\nNextDevIndex = d2
                ; debugmsg(sProcName, "prMaps\aDev(" + nMyPrevDevIndex + ")\nNextDevIndex=" + prMaps\aDev(nMyPrevDevIndex)\nNextDevIndex)
              EndIf
              ; With prMaps\aDev(d2)  ; can't use With in a Macro
              prMaps\aDev(d2)\bExists = #True
              prMaps\aDev(d2)\nDevMapId =  nDevMapId
              prMaps\aDev(d2)\nPrevDevIndex = nMyPrevDevIndex
              prMaps\aDev(d2)\nNextDevIndex = -1
              ; debugMsg(sProcName, "prMaps\aDev(" + d2 + ")\nPrevDevIndex=" + prMaps\aDev(d2)\nPrevDevIndex + ", prMaps\aDev(" + d2 + ")\nNextDevIndex=" + prMaps\aDev(d2)\nNextDevIndex)
              prMaps\aDev(d2)\nDevGrp = #SCS_DEVGRP_AUDIO_OUTPUT
              prMaps\aDev(d2)\nDevType = #SCS_DEVTYPE_AUDIO_OUTPUT
              prMaps\aDev(d2)\sLogicalDev = prProd\aAudioLogicalDevs(d)\sLogicalDev
              prMaps\aDev(d2)\nDevId = prProd\aAudioLogicalDevs(d)\nDevId
              ; debugMsg(sProcName, "prMaps\aDev(" + d2 + ")\nDevId=" + prMaps\aDev(d2)\nDevId)
              ; EndWith
              grCFH\nDevIndex = d2
              nMyPrevDevIndex = d2
            EndIf
          Next d
          
          ; initialise devmap with video audio devices defined in the production properties
          For d = 0 To prProd\nMaxVidAudLogicalDev ; video audio devs
            If Len(Trim(prProd\aVidAudLogicalDevs(d)\sVidAudLogicalDev)) > 0
              d2 + 1
              If d2 > ArraySize(prMaps\aDev())
                REDIM_ARRAY(prMaps\aDev, d2+20, grDevMapDevDef, "prMaps\aDev()")
              EndIf
              If nMyPrevDevIndex < 0
                prMaps\aMap(nDevMapPtr)\nFirstDevIndex = d2
                ; debugMsg(sProcName, "prMaps\aMap()(" + nDevMapPtr + ")\nFirstDevIndex=" + prMaps\aMap(nDevMapPtr)\nFirstDevIndex)
              Else
                prMaps\aDev(nMyPrevDevIndex)\nNextDevIndex = d2
                ; debugmsg(sProcName, "prMaps\aDev(" + nMyPrevDevIndex + ")\nNextDevIndex=" + prMaps\aDev(nMyPrevDevIndex)\nNextDevIndex)
              EndIf
              ; With prMaps\aDev(d2)  ; can't use With in a Macro
              prMaps\aDev(d2)\bExists = #True
              prMaps\aDev(d2)\nDevMapId =  nDevMapId
              prMaps\aDev(d2)\nPrevDevIndex = nMyPrevDevIndex
              prMaps\aDev(d2)\nNextDevIndex = -1
              ; debugMsg(sProcName, "prMaps\aDev(" + d2 + ")\nPrevDevIndex=" + prMaps\aDev(d2)\nPrevDevIndex + ", prMaps\aDev(" + d2 + ")\nNextDevIndex=" + prMaps\aDev(d2)\nNextDevIndex)
              prMaps\aDev(d2)\nDevGrp = #SCS_DEVGRP_VIDEO_AUDIO
              prMaps\aDev(d2)\nDevType = #SCS_DEVTYPE_VIDEO_AUDIO
              prMaps\aDev(d2)\sLogicalDev = prProd\aVidAudLogicalDevs(d)\sVidAudLogicalDev
              prMaps\aDev(d2)\nDevId = prProd\aVidAudLogicalDevs(d)\nDevId
              ; EndWith
              grCFH\nDevIndex = d2
              nMyPrevDevIndex = d2
            EndIf
          Next d
          
          ; initialise devmap with video capture devices defined in the production properties
          For d = 0 To prProd\nMaxVidCapLogicalDev  ; video audio devs
            If Len(Trim(prProd\aVidCapLogicalDevs(d)\sLogicalDev)) > 0
              d2 + 1
              If d2 > ArraySize(prMaps\aDev())
                REDIM_ARRAY(prMaps\aDev, d2+20, grDevMapDevDef, "prMaps\aDev()")
              EndIf
              If nMyPrevDevIndex < 0
                prMaps\aMap(nDevMapPtr)\nFirstDevIndex = d2
                ; debugMsg(sProcName, "prMaps\aMap()(" + nDevMapPtr + ")\nFirstDevIndex=" + prMaps\aMap(nDevMapPtr)\nFirstDevIndex)
              Else
                prMaps\aDev(nMyPrevDevIndex)\nNextDevIndex = d2
                ; debugmsg(sProcName, "prMaps\aDev(" + nMyPrevDevIndex + ")\nNextDevIndex=" + prMaps\aDev(nMyPrevDevIndex)\nNextDevIndex)
              EndIf
              ; With prMaps\aDev(d2)  ; can't use With in a Macro
              prMaps\aDev(d2)\bExists = #True
              prMaps\aDev(d2)\nDevMapId =  nDevMapId
              prMaps\aDev(d2)\nPrevDevIndex = nMyPrevDevIndex
              prMaps\aDev(d2)\nNextDevIndex = -1
              ; debugMsg(sProcName, "prMaps\aDev(" + d2 + ")\nPrevDevIndex=" + prMaps\aDev(d2)\nPrevDevIndex + ", prMaps\aDev(" + d2 + ")\nNextDevIndex=" + prMaps\aDev(d2)\nNextDevIndex)
              prMaps\aDev(d2)\nDevGrp = #SCS_DEVGRP_VIDEO_CAPTURE
              prMaps\aDev(d2)\nDevType = #SCS_DEVTYPE_VIDEO_CAPTURE
              prMaps\aDev(d2)\sLogicalDev = prProd\aVidCapLogicalDevs(d)\sLogicalDev
              prMaps\aDev(d2)\nDevId = prProd\aVidCapLogicalDevs(d)\nDevId
              ; EndWith
              grCFH\nDevIndex = d2
              nMyPrevDevIndex = d2
            EndIf
          Next d
          
          ; initialise devmap with live input devices defined in the production properties
          For d = 0 To prProd\nMaxLiveInputLogicalDev
            If Len(Trim(prProd\aLiveInputLogicalDevs(d)\sLogicalDev)) > 0
              d2 + 1
              If d2 > ArraySize(prMaps\aDev())
                REDIM_ARRAY(prMaps\aDev, d2+20, grDevMapDevDef, "prMaps\aDev()")
              EndIf
              If nMyPrevDevIndex < 0
                prMaps\aMap(nDevMapPtr)\nFirstDevIndex = d2
              Else
                prMaps\aDev(nMyPrevDevIndex)\nNextDevIndex = d2
              EndIf
              ; With prMaps\aDev(d2)  ; can't use With in a Macro
              prMaps\aDev(d2)\bExists = #True
              prMaps\aDev(d2)\nDevMapId =  nDevMapId
              prMaps\aDev(d2)\nPrevDevIndex = nMyPrevDevIndex
              prMaps\aDev(d2)\nNextDevIndex = -1
              prMaps\aDev(d2)\nDevGrp = #SCS_DEVGRP_LIVE_INPUT
              prMaps\aDev(d2)\nDevType = #SCS_DEVTYPE_LIVE_INPUT
              prMaps\aDev(d2)\sLogicalDev = prProd\aLiveInputLogicalDevs(d)\sLogicalDev
              prMaps\aDev(d2)\nDevId = prProd\aLiveInputLogicalDevs(d)\nDevId
              ; EndWith
              grCFH\nDevIndex = d2
              nMyPrevDevIndex = d2
            EndIf
          Next d
          
          ; initialise devmap with lighting devices defined in the production properties
          For d = 0 To prProd\nMaxLightingLogicalDev
            If Trim(prProd\aLightingLogicalDevs(d)\sLogicalDev)
              d2 + 1
              If d2 > ArraySize(prMaps\aDev())
                REDIM_ARRAY(prMaps\aDev, d2+20, grDevMapDevDef, "prMaps\aDev()")
              EndIf
              If nMyPrevDevIndex < 0
                prMaps\aMap(nDevMapPtr)\nFirstDevIndex = d2
              Else
                prMaps\aDev(nMyPrevDevIndex)\nNextDevIndex = d2
              EndIf
              ; With prMaps\aDev(d2)  ; can't use With in a Macro
              prMaps\aDev(d2)\bExists = #True
              prMaps\aDev(d2)\nDevMapId =  nDevMapId
              prMaps\aDev(d2)\nPrevDevIndex = nMyPrevDevIndex
              prMaps\aDev(d2)\nNextDevIndex = -1
              prMaps\aDev(d2)\nDevGrp = #SCS_DEVGRP_LIGHTING
              prMaps\aDev(d2)\nDevType = prProd\aLightingLogicalDevs(d)\nDevType
              prMaps\aDev(d2)\sLogicalDev = prProd\aLightingLogicalDevs(d)\sLogicalDev
              prMaps\aDev(d2)\nDevId = prProd\aLightingLogicalDevs(d)\nDevId
              prMaps\aDev(d2)\nMaxDevFixture = prProd\aLightingLogicalDevs(d)\nMaxFixture
              If prMaps\aDev(d2)\nMaxDevFixture >= 0
                ReDim prMaps\aDev(d2)\aDevFixture(prMaps\aDev(d2)\nMaxDevFixture)
                For n = 0 To prMaps\aDev(d2)\nMaxDevFixture
                  prMaps\aDev(d2)\aDevFixture(n)\sDevFixtureCode = prProd\aLightingLogicalDevs(d)\aFixture(n)\sFixtureCode
                  prMaps\aDev(d2)\aDevFixture(n)\nDevDMXStartChannel = 0 ; zero means 'not set'
                Next n
              EndIf
              ; If prMaps\aDev(d2)\nDevType <> #SCS_DEVTYPE_NONE
              ;   debugMsg(sProcName, "prMaps\aDev(" + d2 + ")\nDevGrp=" + decodeDevGrp(prMaps\aDev(d2)\nDevGrp) + ", \nDevType=" + decodeDevType(prMaps\aDev(d2)\nDevType) + ", \bExists=" + strB(prMaps\aDev(d2)\bExists))
              ; EndIf
              ; EndWith
              grCFH\nDevIndex = d2
              nMyPrevDevIndex = d2
            EndIf
          Next d
          
          ; initialise devmap with ctrl send devices defined in the production properties
          For d = 0 To prProd\nMaxCtrlSendLogicalDev
            If Trim(prProd\aCtrlSendLogicalDevs(d)\sLogicalDev)
              d2 + 1
              If d2 > ArraySize(prMaps\aDev())
                REDIM_ARRAY(prMaps\aDev, d2+20, grDevMapDevDef, "prMaps\aDev()")
              EndIf
              If nMyPrevDevIndex < 0
                prMaps\aMap(nDevMapPtr)\nFirstDevIndex = d2
              Else
                prMaps\aDev(nMyPrevDevIndex)\nNextDevIndex = d2
              EndIf
              ; With prMaps\aDev(d2)  ; can't use With in a Macro
              prMaps\aDev(d2)\bExists = #True
              prMaps\aDev(d2)\nDevMapId =  nDevMapId
              prMaps\aDev(d2)\nPrevDevIndex = nMyPrevDevIndex
              prMaps\aDev(d2)\nNextDevIndex = -1
              prMaps\aDev(d2)\nDevGrp = #SCS_DEVGRP_CTRL_SEND
              prMaps\aDev(d2)\nDevType = prProd\aCtrlSendLogicalDevs(d)\nDevType
              prMaps\aDev(d2)\sLogicalDev = prProd\aCtrlSendLogicalDevs(d)\sLogicalDev
              prMaps\aDev(d2)\nDevId = prProd\aCtrlSendLogicalDevs(d)\nDevId
              ; EndWith
              grCFH\nDevIndex = d2
              nMyPrevDevIndex = d2
            EndIf
          Next d
          
          ; initialise devmap with cue ctrl pseudo device entries
          For d = 0 To prProd\nMaxCueCtrlLogicalDev
            d2 + 1
            If d2 > ArraySize(prMaps\aDev())
              REDIM_ARRAY(prMaps\aDev, d2+20, grDevMapDevDef, "prMaps\aDev()")
            EndIf
            If nMyPrevDevIndex < 0
              prMaps\aMap(nDevMapPtr)\nFirstDevIndex = d2
            Else
              prMaps\aDev(nMyPrevDevIndex)\nNextDevIndex = d2
            EndIf
            ; With prMaps\aDev(d2)  ; can't use With in a Macro
            prMaps\aDev(d2)\bExists = #True
            prMaps\aDev(d2)\nDevMapId =  nDevMapId
            prMaps\aDev(d2)\nPrevDevIndex = nMyPrevDevIndex
            prMaps\aDev(d2)\nNextDevIndex = -1
            prMaps\aDev(d2)\nDevGrp = #SCS_DEVGRP_CUE_CTRL
            prMaps\aDev(d2)\nDevType = prProd\aCueCtrlLogicalDevs(d)\nDevType
            prMaps\aDev(d2)\sLogicalDev = prProd\aCueCtrlLogicalDevs(d)\sCueCtrlLogicalDev
            prMaps\aDev(d2)\nDevId = prProd\aCueCtrlLogicalDevs(d)\nDevId
            ; EndWith
            grCFH\nDevIndex = d2
            nMyPrevDevIndex = d2
          Next d
          
          prMaps\nMaxDevIndex = d2
          If nDevMapPtr > prMaps\nMaxMapIndex
            prMaps\nMaxMapIndex = nDevMapPtr
          EndIf
          ; debugMsg(sProcName, "sNodeName=" + sNodeName + ", nDevMapPtr=" + nDevMapPtr)
          
        Case "DevMapC"
          ; DevMapC (common devmap) obsolete so set bIgnoreDevMap to ignore any data for this obsolete device map
          bIgnoreDevMap = #True
          
        Case "AudioDriver"
          prMaps\aMap(nDevMapPtr)\nAudioDriver = encodeAudioDriver(sNodeText)
          If prMaps\aMap(nDevMapPtr)\nAudioDriver > 0
            bAudioDriverSet = #True
            nAudioDriver = prMaps\aMap(nDevMapPtr)\nAudioDriver
          EndIf
          
        Case "Device"
          ; debugMsg(sProcName, "processing Device, nDevMapPtr=" + nDevMapPtr)
          ; initialise variables for device fields
          rThisDev = grDevMapDevDef
          ; Changed 18Jun2022 11.9.4
          ; debugMsg(sProcName, "ArraySize(sAttributeName())=" + ArraySize(sAttributeName()))
          For n = 0 To ArraySize(sAttributeName())
            ; debugMsg(sProcName, "sAttributeName(" + n + ")=" + sAttributeName(n) + ", sAttributeValue(" + n + ")=" + sAttributeValue(n))
            If sAttributeName(n) = "DevType"
              rThisDev\nDevType = encodeDevType(sAttributeValue(n))
            ElseIf sAttributeName(n) = "DevGrp"
              rThisDev\nDevGrp = encodeDevGrp(sAttributeValue(n))
            EndIf
          Next n
          If rThisDev\nDevGrp = grDevMapDevDef\nDevGrp
            ; no "DevGrp" attribute included
            rThisDev\nDevGrp = getDevGrpFromDevDevType(rThisDev\nDevType)
          EndIf
          ; End changed 18Jun2022 11.9.4
          bDMXTrgCtrlFound = #False
          nFixtureIndex = -1
          ; debugMsg(sProcName, "rThisDev\nDevGrp=" + decodeDevGrp(rThisDev\nDevGrp) + ", rThisDev\nDevType=" + decodeDevType(rThisDev\nDevType) + ", rThisDev\bDummy=" + strB(rThisDev\bDummy))
          
        Case "DevName"
          rThisDev\sLogicalDev = sNodeText
          ; debugMsg(sProcName, "rThisDev\sLogicalDev=" + rThisDev\sLogicalDev)
          
        Case "PhysDev"
          rThisDev\sPhysicalDev = sNodeText
          Select rThisDev\nDevType
            Case #SCS_DEVTYPE_AUDIO_OUTPUT, #SCS_DEVTYPE_VIDEO_AUDIO
              Select rThisDev\sPhysicalDev
                Case "Windows Default Sound Device", "Default DirectSound Device"
                  rThisDev\sPhysicalDev = grMMedia\sDefAudDevDesc
                  rThisDev\bDefaultDev = #True
              EndSelect
          EndSelect
          If rThisDev\nDevType = #SCS_DEVTYPE_VIDEO_AUDIO
            If grLicInfo\nMaxVidAudDevPerProd = 0
              ; override PhysDev
              rThisDev\sPhysicalDev = gaVideoAudioDev(0)\sVidAudName
            EndIf
          EndIf
          ; debugMsg(sProcName, "rThisDev\sPhysicalDev=" + rThisDev\sPhysicalDev)
          If rThisDev\nDevType = #SCS_DEVTYPE_AUDIO_OUTPUT
            If FindString(UCase(rThisDev\sPhysicalDev), "ASIO") > 0
              bASIOFound = #True
            EndIf
          EndIf
          
        Case "DefaultDev"
          rThisDev\bDefaultDev = stringToBoolean(sNodeText)
          ; debugMsg(sProcName, "rThisDev\bDefaultDev=" + strB(rThisDev\bDefaultDev))
          
        Case "Dummy"
          rThisDev\bDummy = stringToBoolean(sNodeText)
          ; debugMsg(sProcName, "rThisDev\bDummy=" + strB(rThisDev\bDummy))
          
          ;- Audio Out
        Case "Outputs"
          rThisDev\s1BasedOutputRange = sNodeText
        Case "DelayTime"
          rThisDev\nDelayTime = Val(sNodeText)
        Case "OutputGainDB"
          sNodeText = readDBLevel(sNodeText)
          If ValF(sNodeText) < ValF(grLevels\sMinDBLevel)
            sNodeText = grLevels\sMinDBLevel
          EndIf
          rThisDev\sDevOutputGainDB = sNodeText
          rThisDev\fDevOutputGain = convertDBStringToBVLevel(sNodeText)
          ; debugMsg(sProcName, "rThisDev\sDevOutputGainDB=" + rThisDev\sDevOutputGainDB + ", rThisDev\fDevOutputGain=" + formatLevel(rThisDev\fDevOutputGain))
          
          ;- Video Capture
        Case "VidCapFormat"
          rThisDev\sVidCapFormat = sNodeText
          
        Case "VidCapFrameRate"
          rThisDev\dVidCapFrameRate = ValD(sNodeText)

          ;- Live Input
        Case "Inputs", "InputChan"
          rThisDev\s1BasedInputRange = sNodeText
        Case "InputDelayTime"
          rThisDev\nInputDelayTime = Val(sNodeText)
        Case "InputGainDB"
          sNodeText = readDBLevel(sNodeText)
          If ValF(sNodeText) < ValF(grLevels\sMinDBLevel)
            sNodeText = grLevels\sMinDBLevel
          EndIf
          rThisDev\sInputGainDB = sNodeText
          rThisDev\fInputGain = convertDBStringToBVLevel(sNodeText)
        Case "InputLowCutSelected"
          rThisDev\bInputLowCutSelected = stringToBoolean(sNodeText)
          If rThisDev\bInputLowCutSelected
            rThisDev\bInputEQOn = #True
          EndIf
        Case "InputLowCutFreq"
          rThisDev\nInputLowCutFreq = Val(sNodeText)
        Case "InputEQBand"
          nEQBand = Val(sAttributeValue(0))
          ; debugMsg(sProcName, "InputEQBand: sAttributeValue(0)=" + sAttributeValue(0) + ", nEQBand=" + nEQBand)
        Case "InputEQBandSelected"
          nIndex = nEQBand - 1
          If (nIndex >= 0) And (nIndex <= #SCS_MAX_EQ_BAND)
            rThisDev\aInputEQBand[nIndex]\bEQBandSelected = stringToBoolean(sNodeText)
            If rThisDev\aInputEQBand[nIndex]\bEQBandSelected
              rThisDev\bInputEQOn = #True
            EndIf
          EndIf
        Case "InputEQGainDB"
          sNodeText = readDBLevel(sNodeText)
          nIndex = nEQBand - 1
          If (nIndex >= 0) And (nIndex <= #SCS_MAX_EQ_BAND)
            rThisDev\aInputEQBand[nIndex]\sEQGainDB = sNodeText
          EndIf
        Case "InputEQFreq"
          nIndex = nEQBand - 1
          If (nIndex >= 0) And (nIndex <= #SCS_MAX_EQ_BAND)
            rThisDev\aInputEQBand[nIndex]\nEQFreq = Val(sNodeText)
          EndIf
        Case "InputEQQ"
          nIndex = nEQBand - 1
          If (nIndex >= 0) And (nIndex <= #SCS_MAX_EQ_BAND)
            rThisDev\aInputEQBand[nIndex]\fEQQ = ValF(sNodeText)
          EndIf
          
          ;- MIDI Thru
        Case "MidiConnectName"
          DEV_UPDATE(sMidiThruInPhysicalDev, sNodeText)
        Case "MidiConnectDummy"
          rThisDev\bMidiThruInDummy = stringToBoolean(sNodeText)
          ; debugMsg(sProcName, "rThisDev\bMidiThruInDummy=" + strB(rThisDev\bMidiThruInDummy))
          
          ;- MIDI In (cue ctrl)
          ; pre 20150401 fields
        Case "MidiCtrlMethod"
          DEV_UPDATE(nCtrlMethodx, encodeCtrlMethod(sNodeText))
        Case "MidiDevId"
          DEV_UPDATE(nMidiDevIdx, Val(sNodeText))
        Case "MscCommandFormat"
          DEV_UPDATE(nMscCommandFormatx, Val(sNodeText))
        Case "MidiGoMacro"
          DEV_UPDATE(nGoMacrox, Val(sNodeText))
        Case "MidiChannel"
          DEV_UPDATE(nMidiChannelx, Val(sNodeText))
        Case "MidiCommand"
          nCmdIndex = encodeMidiCommand(sAttributeValue(0), @prProd) ; sets nCmdIndex for child tags
        Case "MidiCmd"
          DEV_UPDATE(aMidiCommandx[nCmdIndex]\nCmd, Val(sNodeText))  ; decimal equivalent of MIDI command, eg 8 for Note Off, 9 for Note On, 15 for Pitch Bend
        Case "MidiCC"
          DEV_UPDATE(aMidiCommandx[nCmdIndex]\nCC, Val(sNodeText))
        Case "MidiVV"
          If sNodeText = "*"
            DEV_UPDATE(aMidiCommandx[nCmdIndex]\nVV, #SCS_MIDI_ANY_VALUE)
          Else
            DEV_UPDATE(aMidiCommandx[nCmdIndex]\nVV, Val(sNodeText))
          EndIf
          
          ;- RS232
          ; pre 20150401 fields
        Case "DataBits"
          DEV_UPDATE(nRS232DataBitsx, Val(sNodeText))
        Case "StopBits"
          DEV_UPDATE(fRS232StopBitsx, ValF(sNodeText))
        Case "BaudRate"
          DEV_UPDATE(nRS232BaudRatex, Val(sNodeText))
        Case "Parity"
          DEV_UPDATE(nRS232Parityx, encodeParity(sNodeText))
        Case "Handshaking"
          DEV_UPDATE(nRS232Handshakingx, encodeHandshaking(sNodeText))
        Case "RTSEnable"
          DEV_UPDATE(nRS232RTSEnablex, Val(sNodeText))
        Case "DTREnable"
          DEV_UPDATE(nRS232DTREnablex, Val(sNodeText))
          
          ;- Network (TCP/UDP)
        Case "RemoteHost"
          DEV_UPDATE(sRemoteHost, sNodeText)
        Case "RemotePort"
          DEV_UPDATE(nRemotePort, portStrToInt(sNodeText))
        Case "LocalPort"
          DEV_UPDATE(nLocalPort, portStrToInt(sNodeText))
          ; pre 20150401 fields
        Case "NetworkRole", "TelnetRole"
          DEV_UPDATE(nNetworkRolex, encodeNetworkRole(sNodeText))
        Case "NetworkSendAddCR", "TelnetSendAddCR"
          DEV_UPDATE(bReplyMsgAddCRx, Val(sNodeText))
        Case "NetworkSendAddLF", "TelnetSendAddLF"
          DEV_UPDATE(bReplyMsgAddLFx, Val(sNodeText))
        Case "NetworkMsgResponse", "TelnetMsgResponse"
          rThisMsgResponse = grMsgResponse
        Case "ReceiveMsg"
          rThisMsgResponse\sReceiveMsg = sNodeText
          rThisMsgResponse\sComparisonMsg = makeComparisonMsg(rThisMsgResponse\sReceiveMsg)
        Case "MsgAction"
          rThisMsgResponse\nMsgAction = encodeNetworkMsgAction(sNodeText)
        Case "ReplyMsg"
          rThisMsgResponse\sReplyMsg = sNodeText
        Case "CtrlSendDelay"
          DEV_UPDATE(nCtrlSendDelay, Val(sNodeText))
          
          ;- DMX
        Case "DMXReceiveSerial", "DMXSerial"
          DEV_UPDATE(sDMXSerial, sNodeText)
        Case "DMXNumSerial"
          DEV_UPDATE(nDMXSerial, Val(sNodeText))
        Case "DMXPort"
          DEV_UPDATE(nDMXPort, Val(sNodeText))
        Case "DMXRefreshRate"
          DEV_UPDATE(nDMXRefreshRate, Val(sNodeText))
        Case "DMXIpAddress"
          DEV_UPDATE(sDMXIpAddress, sNodeText)
          ; pre 20150401 fields
        Case "DMXPref"
          DEV_UPDATE(nDMXPrefx, encodeDMXPref(sNodeText))      
        Case "DMXTrgCtrl"
          bDMXTrgCtrlFound = #True
          DEV_UPDATE(nDMXTrgCtrlx, encodeDMXTrgCtrl(sNodeText))
          ; debugMsg(sProcName, "DMXTrgCtrl: sNodeText=" + sNodeText + ", rThisDev\nDMXTrgCtrlx=" + decodeDMXTrgCtrl(rThisDev\nDMXTrgCtrlx))
        Case "DMXTrgValue"
          DEV_UPDATE(nDMXTrgValuex, Val(sNodeText))
        Case "DMXCommand"
          nCmdIndex = encodeDMXCommand(sAttributeValue(0)) ; sets nCmdIndex for child tags
        Case "DMXChannel"
          DEV_UPDATE(aDMXCommandx[nCmdIndex]\nChannel, Val(sNodeText))
          
          ;- Fixtures
        Case "Fixture"
          rThisDevFixture = grDevFixtureDef
          If sAttributeName(0) = "FixtureCode"
            rThisDevFixture\sDevFixtureCode = sAttributeValue(0)
          EndIf
          
        Case "DMXStartChannel"
          If Val(sNodeText) > 0
            rThisDevFixture\nDevDMXStartChannel = Val(sNodeText)
          EndIf
          
        Case "DMXStartChannels"
          rThisDevFixture\sDevDMXStartChannels = sNodeText
          
          ;- Live Input Group
        Case "Group"
          ; initialise variables for live input group fields
          rThisLiveGrp = grLiveGrpDef
          If sAttributeName(0) = "GrpName"
            rThisLiveGrp\sLiveGrpName = sAttributeValue(0)
          EndIf
          
        Case "GrpDevType" ; group device type
          rThisLiveGrp\nDevType = encodeDevType(sNodeText)
          rThisLiveGrp\nDevGrp = getDevGrpFromDevDevType(rThisLiveGrp\nDevType)
          
        Case "GrpComp"  ; group component (logical dev or another group)
          If rThisLiveGrp\nCompCount <= #SCS_MAX_LIVE_INPUT_DEV_PER_AUD
            rThisLiveGrp\sCompName[rThisLiveGrp\nCompCount] = sNodeText
            rThisLiveGrp\nCompCount + 1
          EndIf
          
        Case "VSTPlugins"
          nCurrentPluginIndex = -1
          
        Case "Plugin" ; VST Plugin Name
          nCurrentPluginIndex = -1
          For n = 0 To prVST\nMaxLibVSTPlugin
            If prVST\aLibVSTPlugin(n)\sLibVSTPluginName = sAttributeValue(0)
              nCurrentPluginIndex = n
              Break
            EndIf
          Next n
          
        Case "PluginFile32"
          If nCurrentPluginIndex >= 0
            prVST\aLibVSTPlugin(nCurrentPluginIndex)\sLibVSTPluginFile32 = sNodeText
          EndIf
          
        Case "PluginFile64"
          If nCurrentPluginIndex >= 0
            prVST\aLibVSTPlugin(nCurrentPluginIndex)\sLibVSTPluginFile64 = sNodeText
          EndIf
          
          ;- HTTP Request
        Case "HTTPStart"
          rThisDev\sHTTPStartx = sNodeText
          
          ; Selected Device Map
        Case "SelectedDevMap"
          prMaps\sSelectedDevMapName = sNodeText
          
          ; File Save Info
        Case "FileSaveInfo", "_Saved_", "_SCS_Version_", "_SCS_Build_"
          ; no action
          
        Default
          debugMsg(sProcName, "!!!!!!!!!! unprocessed tag: sNodeName=" + sNodeName)
          
      EndSelect
    EndIf ; EndIf bIgnoreDevMap = #False
    
    ; Now get the first child node (if any)
    *nChildNode = ChildXMLNode(*CurrentNode)
    
    While *nChildNode <> 0
      ; Loop through all available child nodes and call this procedure again
      If pPrimaryFile
        scanXMLDevMaps(*nChildNode, CurrentSublevel + 1)
      Else
        scanXMLDevMaps2(*nChildNode, CurrentSublevel + 1)
      EndIf
      *nChildNode = NextXMLNode(*nChildNode)
    Wend        
    
    ; process any end-of-node requirements
    If bIgnoreDevMap = #False Or sNodeName = "DevMapC"
      Select sNodeName
        Case "Device"   ; /Device
          ; debugMsg(sProcName, "processing /Device, nDevMapPtr=" + nDevMapPtr)
          ; search for this logical device
          ; if device not found ignore the device map device
          ; debugMsg(sProcName, "rThisDev\nDevGrp=" + decodeDevGrp(rThisDev\nDevGrp) + ", rThisDev\sLogicalDev=" + rThisDev\sLogicalDev)
          If Trim(rThisDev\sLogicalDev)
            If rThisDev\bDefaultDev
              Select rThisDev\nDevType
                Case #SCS_DEVTYPE_AUDIO_OUTPUT
                  If (bAudioDriverSet) And (nAudioDriver = #SCS_DRV_BASS_DS Or nAudioDriver = #SCS_DRV_BASS_WASAPI)
                    rThisDev\sPhysicalDev = grMMedia\sDefAudDevDesc
                  EndIf
                Case #SCS_DEVTYPE_VIDEO_AUDIO
                  rThisDev\sPhysicalDev = grMMedia\sDefAudDevDesc
              EndSelect
            EndIf
            ; debugMsg(sProcName, "prMaps\aMap(" + nDevMapPtr + ")\nFirstDevIndex=" + prMaps\aMap(nDevMapPtr)\nFirstDevIndex)
            d = prMaps\aMap(nDevMapPtr)\nFirstDevIndex
            While d >= 0
              ; debugMsg(sProcName, "prMaps\aDev(" + d + ")\nDevGrp=" + decodeDevGrp(prMaps\aDev(d)\nDevGrp) + ", prMaps\aDev(" + d + ")\sLogicalDev=" + prMaps\aDev(d)\sLogicalDev)
              If (prMaps\aDev(d)\nDevGrp = rThisDev\nDevGrp) And (prMaps\aDev(d)\sLogicalDev = rThisDev\sLogicalDev)
                ; debugMsg(sProcName, "nDevGrp " + decodeDevGrp(rThisDev\nDevGrp) + ", sLogicalDev " + rThisDev\sLogicalDev + " found at d=" + d)
                ; debugmsg(sProcName, "prMaps\aDev(" + d + ")\nDevGrp=" + decodeDevGrp(prMaps\aDev(d)\nDevGrp) + ", rThisDev\nDevGrp=" + decodeDevGrp(rThisDev\nDevGrp) +
                ;                     ", \nDevType=" + decodeDevType(prMaps\aDev(d)\nDevType) + ", rThisDev\nDevType=" + decodeDevType(rThisDev\nDevType))
                If (prMaps\aDev(d)\nDevType = rThisDev\nDevType) Or (prMaps\aDev(d)\nDevGrp = #SCS_DEVGRP_CUE_CTRL)
                  prMaps\aDev(d)\bExists = #True
                  prMaps\aDev(d)\nDevMapId =  nDevMapId
                  prMaps\aDev(d)\nDevType = rThisDev\nDevType
                  ; added 23Nov2016 11.5.2.4.010
                  Select rThisDev\nDevType
                    Case #SCS_DEVTYPE_CC_DMX_IN, #SCS_DEVTYPE_LT_DMX_OUT
                      sDummyDev = Lang("DMX", "Dummy")
                      sDummyDevENUS = "Dummy DMX Port"
                    Case #SCS_DEVTYPE_CC_MIDI_IN
                      sDummyDev = Lang("MIDI", "DummyInPort")
                      sDummyDevENUS = "Dummy MIDI In Port"
                    Case #SCS_DEVTYPE_CS_MIDI_OUT
                      sDummyDev = Lang("MIDI", "DummyOutPort")
                      sDummyDevENUS = "Dummy MIDI Out Port"
                    Case #SCS_DEVTYPE_CS_MIDI_THRU
                      sDummyDev = Lang("MIDI", "DummyOutPort")
                      sDummyDevENUS = "Dummy MIDI Out Port"
                      sDummyDev2 = Lang("MIDI", "DummyInPort")
                      sDummyDevENUS2 = "Dummy MIDI In Port"
                    Case #SCS_DEVTYPE_CC_NETWORK_IN, #SCS_DEVTYPE_CS_NETWORK_OUT
                      sDummyDev = Lang("Network", "Dummy")
                      sDummyDevENUS = "Dummy Network Connection"
                    Case #SCS_DEVTYPE_CC_RS232_IN, #SCS_DEVTYPE_CS_RS232_OUT
                      sDummyDev = Lang("RS232", "Dummy")
                      sDummyDevENUS = "Dummy Serial Port"
                    Default
                      sDummyDev = ""
                      sDummyDevENUS = ""
                  EndSelect
                  ; debugMsg(sProcName, "rThisDev\nDevType=" + decodeDevType(rThisDev\nDevType) + ", rThisDev\sPhysicalDev=" + rThisDev\sPhysicalDev + ", sDummyDev=" + sDummyDev + ", sDummyDevENUS=" + sDummyDevENUS)
                  If sDummyDev
                    ; set \bDummy if required (for device map files created prior to SCS 11.5.2.4.010)
                    If (rThisDev\bDummy = #False) And ((rThisDev\sPhysicalDev = sDummyDev) Or (rThisDev\sPhysicalDev = sDummyDevENUS))
                      rThisDev\bDummy = #True
                    EndIf
                    ; (re)populate \sPhysicalDev for dummy devices - to provide language-independence in case user changed language since \sPhysicalDev was last set
                    If rThisDev\bDummy
                      rThisDev\sPhysicalDev = sDummyDev
                    EndIf
                    ; debugMsg(sProcName, "rThisDev\sPhysicalDev=" + rThisDev\sPhysicalDev + ", rThisDev\bDummy=" + strB(rThisDev\bDummy))
                  EndIf
                  ; end added 23Nov2016 11.5.2.4.010
                  prMaps\aDev(d)\bDummy = rThisDev\bDummy
                  prMaps\aDev(d)\bDefaultDev = rThisDev\bDefaultDev
                  prMaps\aDev(d)\sPhysicalDev = rThisDev\sPhysicalDev
                  ; debugMsg(sProcName, "prMaps\aDev(" + d + ")\sPhysicalDev=" + prMaps\aDev(d)\sPhysicalDev + ", \bDefaultDev=" + strB(prMaps\aDev(d)\bDefaultDev))
                  ; prMaps\aDev(d)\nDevId = rThisDev\nDevId
                  ; set nAudioDriver (if necessary) for getPhysicalDevPtr()
                  If bAudioDriverSet = #False
                    nAudioDriver = gnDefaultAudioDriver
                    If bASIOFound
                      If nAudioDriver = #SCS_DRV_BASS_DS Or nAudioDriver = #SCS_DRV_BASS_WASAPI
                        nAudioDriver = #SCS_DRV_BASS_ASIO
                      EndIf
                    EndIf
                  EndIf
                  prMaps\aDev(d)\nPhysicalDevPtr = getPhysicalDevPtr(prMaps\aDev(d)\nDevType, rThisDev\sPhysicalDev, nAudioDriver, rThisDev\sDMXSerial, rThisDev\nDMXSerial, rThisDev\bDummy)
                  ; If prMaps\aDev(d)\nDevType <> #SCS_DEVTYPE_NONE
                  ;   debugMsg(sProcName, "prMaps\aDev(" + d + ")\nPhysicalDevPtr=" + Str(prMaps\aDev(d)\nPhysicalDevPtr) + ", \nDevType=" + decodeDevType(prMaps\aDev(d)\nDevType))
                  ; EndIf
                  Select prMaps\aDev(d)\nDevType
                    Case #SCS_DEVTYPE_AUDIO_OUTPUT  ; #SCS_DEVTYPE_AUDIO_OUTPUT
                      If prMaps\aDev(d)\nPhysicalDevPtr >= 0
                        prMaps\aDev(d)\bNoDevice = gaAudioDev(prMaps\aDev(d)\nPhysicalDevPtr)\bNoDevice
                        If gaAudioDev(prMaps\aDev(d)\nPhysicalDevPtr)\bASIO
                          bASIOFound = #True
                        EndIf
                      EndIf
                      prMaps\aDev(d)\s1BasedOutputRange = rThisDev\s1BasedOutputRange
                      prMaps\aDev(d)\nFirst1BasedOutputChan = getFirst1BasedChanFromRange(prMaps\aDev(d)\s1BasedOutputRange)
                      prMaps\aDev(d)\nFirst0BasedOutputChan = prMaps\aDev(d)\nFirst1BasedOutputChan - 1
                      prMaps\aDev(d)\nNrOfDevOutputChans = getNumChansFromRange(prMaps\aDev(d)\s1BasedOutputRange)
                      ; debugMsg(sProcName, "prMaps\aDev(" + d + ")\s1BasedOutputRange=" + prMaps\aDev(d)\s1BasedOutputRange + ", \nNrOfDevOutputChans=" + prMaps\aDev(d)\nNrOfDevOutputChans)
                      prMaps\aDev(d)\nDelayTime = rThisDev\nDelayTime
                      prMaps\aDev(d)\sDevOutputGainDB = rThisDev\sDevOutputGainDB
                      prMaps\aDev(d)\fDevOutputGain = rThisDev\fDevOutputGain
                      
                    Case #SCS_DEVTYPE_VIDEO_AUDIO ; #SCS_DEVTYPE_VIDEO_AUDIO
                      prMaps\aDev(d)\nNrOfDevOutputChans = 2
                      prMaps\aDev(d)\sDevOutputGainDB = rThisDev\sDevOutputGainDB
                      prMaps\aDev(d)\fDevOutputGain = rThisDev\fDevOutputGain
                      If Len(prMaps\aDev(d)\s1BasedOutputRange) = 0
                        prMaps\aDev(d)\s1BasedOutputRange = "L-R"
                      EndIf
                      
                    Case #SCS_DEVTYPE_VIDEO_CAPTURE ; #SCS_DEVTYPE_VIDEO_CAPTURE
                      prMaps\aDev(d)\sVidCapFormat = rThisDev\sVidCapFormat
                      prMaps\aDev(d)\dVidCapFrameRate = rThisDev\dVidCapFrameRate
                      
                    Case #SCS_DEVTYPE_LIVE_INPUT  ; #SCS_DEVTYPE_LIVE_INPUT
                      If prMaps\aDev(d)\nPhysicalDevPtr >= 0
                        prMaps\aDev(d)\bNoDevice = gaAudioDev(prMaps\aDev(d)\nPhysicalDevPtr)\bNoDevice
                        If gaAudioDev(prMaps\aDev(d)\nPhysicalDevPtr)\bASIO
                          bASIOFound = #True
                        EndIf
                      EndIf
                      prMaps\aDev(d)\s1BasedInputRange = rThisDev\s1BasedInputRange
                      ; debugMsg(sProcName, "prMaps\aDev(" + d + ")\s1BasedInputRange=" + prMaps\aDev(d)\s1BasedInputRange) ; + ", \s0BasedInputRange=" + prMaps\aDev(d)\s0BasedInputRange)
                      prMaps\aDev(d)\nFirst1BasedInputChan = getFirst1BasedChanFromRange(prMaps\aDev(d)\s1BasedInputRange)
                      prMaps\aDev(d)\nFirst0BasedInputChan = prMaps\aDev(d)\nFirst1BasedInputChan - 1
                      ; debugMsg(sProcName, "prMaps\aDev(" + d + ")\nFirst1BasedInputChan=" + prMaps\aDev(d)\nFirst1BasedInputChan)
                      prMaps\aDev(d)\nNrOfInputChans = getNumChansFromRange(prMaps\aDev(d)\s1BasedInputRange)
                      prMaps\aDev(d)\nInputDelayTime = rThisDev\nInputDelayTime
                      prMaps\aDev(d)\sInputGainDB = rThisDev\sInputGainDB
                      prMaps\aDev(d)\fInputGain = rThisDev\fInputGain
                      ; debugMsg(sProcName, "prMaps\aDev(" + d + ")\sInputGainDB=" + prMaps\aDev(d)\sInputGainDB + ", \fInputGain=" + traceLevel(prMaps\aDev(d)\fInputGain))
                      prMaps\aDev(d)\bInputLowCutSelected = rThisDev\bInputLowCutSelected
                      prMaps\aDev(d)\nInputLowCutFreq = rThisDev\nInputLowCutFreq
                      For nBandNo = 0 To #SCS_MAX_EQ_BAND
                        prMaps\aDev(d)\aInputEQBand[nBandNo]\bEQBandSelected = rThisDev\aInputEQBand[nBandNo]\bEQBandSelected
                        prMaps\aDev(d)\aInputEQBand[nBandNo]\sEQGainDB = rThisDev\aInputEQBand[nBandNo]\sEQGainDB
                        prMaps\aDev(d)\aInputEQBand[nBandNo]\nEQFreq = rThisDev\aInputEQBand[nBandNo]\nEQFreq
                        prMaps\aDev(d)\aInputEQBand[nBandNo]\fEQQ = rThisDev\aInputEQBand[nBandNo]\fEQQ
                      Next nBandNo
                      prMaps\aDev(d)\bInputEQOn = rThisDev\bInputEQOn
                      
                    Case #SCS_DEVTYPE_CC_MIDI_IN   ; #SCS_DEVTYPE_CC_MIDI_IN
                      prMaps\aDev(d)\nMidiInPhysicalDevPtr = getMidiInPhysicalDevPtr(prMaps\aDev(d)\sPhysicalDev, prMaps\aDev(d)\bDummy)
                      ; debugMsg(sProcName, "#SCS_DEVTYPE_CC_MIDI_IN: prMaps\aDev(" + d + ")\sPhysicalDev=" + prMaps\aDev(d)\sPhysicalDev + ", \nMidiInPhysicalDevPtr=" + prMaps\aDev(d)\nMidiInPhysicalDevPtr)
                      
                    Case #SCS_DEVTYPE_CS_MIDI_THRU   ; #SCS_DEVTYPE_CS_MIDI_THRU
                      prMaps\aDev(d)\bMidiThruInDummy = rThisDev\bMidiThruInDummy
                      prMaps\aDev(d)\sMidiThruInPhysicalDev = rThisDev\sMidiThruInPhysicalDev
                      prMaps\aDev(d)\nMidiThruInPhysicalDevPtr = getPhysicalDevPtr(#SCS_DEVTYPE_CC_MIDI_IN, rThisDev\sMidiThruInPhysicalDev, nAudioDriver, "", 0, rThisDev\bMidiThruInDummy)
                      
                    Case #SCS_DEVTYPE_CC_RS232_IN, #SCS_DEVTYPE_CS_RS232_OUT
                      prMaps\aDev(d)\bReopenDevice = #True
                      
                    Case #SCS_DEVTYPE_CC_NETWORK_IN, #SCS_DEVTYPE_CS_NETWORK_OUT
                      prMaps\aDev(d)\sRemoteHost = rThisDev\sRemoteHost
                      prMaps\aDev(d)\nRemotePort = rThisDev\nRemotePort
                      prMaps\aDev(d)\nLocalPort = rThisDev\nLocalPort
                      prMaps\aDev(d)\nCtrlSendDelay = rThisDev\nCtrlSendDelay
                      
                    Case #SCS_DEVTYPE_CC_DMX_IN, #SCS_DEVTYPE_LT_DMX_OUT
                      If rThisDev\nDMXSerial = 0
                        If rThisDev\sDMXSerial
                          rThisDev\nDMXSerial = DMX_getDMXNumSerialForStrSerial(rThisDev\sDMXSerial)
                          debugMsg2(sProcName, "DMX_getDMXNumSerialForStrSerial(" + rThisDev\sDMXSerial + ")", rThisDev\nDMXSerial)
                        EndIf
                      EndIf
                      prMaps\aDev(d)\nDMXSerial = rThisDev\nDMXSerial
                      prMaps\aDev(d)\sDMXSerial = rThisDev\sDMXSerial
                      If prMaps\aDev(d)\nPhysicalDevPtr >= 0
                        prMaps\aDev(d)\nDMXPorts = gaDMXDevice(prMaps\aDev(d)\nPhysicalDevPtr)\nDMXPorts
                      EndIf
                      prMaps\aDev(d)\nDMXPort = rThisDev\nDMXPort
                      ; debugMsg(sProcName, "prMaps\aDev(" + d + ")\nDMXPort=" + prMaps\aDev(d)\nDMXPort)
                      If rThisDev\nDevType = #SCS_DEVTYPE_LT_DMX_OUT
                        ; debugMsg(sProcName, "processing rThisDev\nDevType=" + decodeDevType(rThisDev\nDevType) + ", nFixtureIndex=" + nFixtureIndex)
                        prMaps\aDev(d)\sDMXIpAddress = rThisDev\sDMXIpAddress
                        prMaps\aDev(d)\nDMXRefreshRate = rThisDev\nDMXRefreshRate
                        prMaps\aDev(d)\nMaxDevFixture = nFixtureIndex
                        ; debugMsg(sProcName, "prMaps\aDev(" + d + ")\nMaxDevFixture=" + prMaps\aDev(d)\nMaxDevFixture)
                        If nFixtureIndex >= 0
                          ReDim rThisDev\aDevFixture(nFixtureIndex)  ; array size may be larger than nFixtureIndex so redim before using CopyArray()
                          CopyArray(rThisDev\aDevFixture(), prMaps\aDev(d)\aDevFixture())
                        EndIf
                        ; debugMsg(sProcName, "prMaps\aDev(d=" + d + ")\nDMXSerial=" + prMaps\aDev(d)\nDMXSerial + ", \sDMXSerial=" + prMaps\aDev(d)\sDMXSerial + ", \nDMXPorts=" + prMaps\aDev(d)\nDMXPorts + ", \nDMXPort=" + prMaps\aDev(d)\nDMXPort +
                        ;                     ", \nDMXRefreshRate=" + prMaps\aDev(d)\nDMXRefreshRate + ", \nMaxDevFixture=" + prMaps\aDev(d)\nMaxDevFixture)
                      Else
                        ; debugMsg(sProcName, "prMaps\aDev(d=" + d + ")\nDMXSerial=" + prMaps\aDev(d)\nDMXSerial + ", \sDMXSerial=" + prMaps\aDev(d)\sDMXSerial + ", \nDMXPorts=" + prMaps\aDev(d)\nDMXPorts + ", \nDMXPort=" + prMaps\aDev(d)\nDMXPort)
                      EndIf
                      
                    Case #SCS_DEVTYPE_CS_HTTP_REQUEST  ; #SCS_DEVTYPE_CS_HTTP_REQUEST
                      grHTTPControl\bExists = #True
                      grHTTPControl\nDevMapId = nDevMapId
                      grHTTPControl\nDevType = prMaps\aDev(d)\nDevType
                      buildHTTPDevDesc(@grHTTPControl)
                      prMaps\aDev(d)\sPhysicalDev = grHTTPControl\sHTTPDevDesc
                      prMaps\aDev(d)\sHTTPStartx = rThisDev\sHTTPStartx
                      prMaps\aDev(d)\nPhysicalDevPtr = 0
                      prMaps\aDev(d)\bDummy = #False
                      ; debugMsg(sProcName, "prMaps\aDev(" + d + ")\sLogicalDev=" + prMaps\aDev(d)\sLogicalDev + ", \sPhysicalDev=" + prMaps\aDev(d)\sPhysicalDev + ", \nPhysicalDevPtr=" + prMaps\aDev(d)\nPhysicalDevPtr)
                      
                  EndSelect
                Else
                  debugMsg(sProcName, "d=" + d + ", " + decodeDevType(rThisDev\nDevType) + "NOT FOUND !!!!!!")
                EndIf
                Break
              EndIf
              d = prMaps\aDev(d)\nNextDevIndex
            Wend
          EndIf
          
        Case "Fixture" ; /Fixture (Lighting Fixture)
          ; debugMsg(sProcName, "processing /Fixture")
          nFixtureIndex + 1
          If nFixtureIndex > ArraySize(rThisDev\aDevFixture())
            ReDim rThisDev\aDevFixture(nFixtureIndex+10)
          EndIf
          rThisDev\aDevFixture(nFixtureIndex) = rThisDevFixture
          ; debugMsg(sProcName, "rThisDev\aDevFixture(" + nFixtureIndex + ")\sDevFixtureCode=" + rThisDev\aDevFixture(nFixtureIndex)\sDevFixtureCode + ", \nDevDMXStartChannel=" + rThisDev\aDevFixture(nFixtureIndex)\nDevDMXStartChannel)
          
        Case "Group" ; /Group (Live Input Group)
          ; debugMsg(sProcName, "processing /Group, nDevMapPtr=" + nDevMapPtr)
          g2 + 1
          If g2 > ArraySize(prMaps\aLiveGrp())
            REDIM_ARRAY(prMaps\aLiveGrp, g2+5, grLiveGrpDef, "prMaps\aLiveGrp()")
          EndIf
          If nMyPrevLiveGrpIndex < 0
            prMaps\aMap(nDevMapPtr)\nFirstLiveGrpIndex = g2
            ; debugMsg(sProcName, "prMaps\aMap()(" + nDevMapPtr + ")\nFirstLiveGrpIndex=" + prMaps\aMap(nDevMapPtr)\nFirstLiveGrpIndex)
          Else
            prMaps\aLiveGrp(nMyPrevLiveGrpIndex)\nNextLiveGrpIndex = g2
            ; debugmsg(sProcName, "prMaps\aLiveGrp(" + nMyPrevLiveGrpIndex + ")\nNextLiveGrpIndex=" + prMaps\aLiveGrp(nMyPrevLiveGrpIndex)\nNextLiveGrpIndex)
          EndIf
          prMaps\aLiveGrp(g2) = rThisLiveGrp
          prMaps\aLiveGrp(g2)\bExists = #True
          prMaps\aLiveGrp(g2)\nDevMapId =  nDevMapId
          prMaps\aLiveGrp(g2)\nPrevLiveGrpIndex = nMyPrevLiveGrpIndex
          prMaps\aLiveGrp(g2)\nNextLiveGrpIndex = -1
          nMyPrevLiveGrpIndex = g2
          
        Case "DevMap" ; /DevMap
          ; debugMsg(sProcName, "processing /" + sNodeName + ", nDevMapPtr=" + nDevMapPtr)
          If bAudioDriverSet = #False
            prMaps\aMap(nDevMapPtr)\nAudioDriver = gnDefaultAudioDriver
            If bASIOFound
              If prMaps\aMap(nDevMapPtr)\nAudioDriver = #SCS_DRV_BASS_DS Or prMaps\aMap(nDevMapPtr)\nAudioDriver = #SCS_DRV_BASS_WASAPI
                prMaps\aMap(nDevMapPtr)\nAudioDriver = #SCS_DRV_BASS_ASIO
              EndIf
            EndIf
          EndIf
          
          d = prMaps\aMap(nDevMapPtr)\nFirstDevIndex
          nAudioDriver = prMaps\aMap(nDevMapPtr)\nAudioDriver
          While d >= 0
            prMaps\aDev(d)\nPhysicalDevPtr = getPhysicalDevPtr(prMaps\aDev(d)\nDevType, prMaps\aDev(d)\sPhysicalDev, nAudioDriver, prMaps\aDev(d)\sDMXSerial, prMaps\aDev(d)\nDMXSerial, prMaps\aDev(d)\bDummy)
            d = prMaps\aDev(d)\nNextDevIndex
          Wend
          
          If pPrimaryFile
            ; debugMsg(sProcName, "calling setDevMapPtrs()")
            setDevMapPtrs()
            ; Added 19Sep2022 11.9.6
            ; debugMsg(sProcName, "calling setConnectWhenReqdForDevs()")
            setConnectWhenReqdForDevs()
            ; End added 19Sep2022 11.9.6
          EndIf
          
        Case "DevMapC" ; /DevMapC
          bIgnoreDevMap = #False
          
      EndSelect
    EndIf ; EndIf bIgnoreDevMap = #False Or sNodeName = "DevMapC"
    
  EndIf ; EndIf XMLNodeType(*CurrentNode) = #PB_XML_Normal
  
  ; debugMsg(sProcName, #SCS_END)
  
EndMacro

Procedure scanXMLDevMaps(*CurrentNode, CurrentSublevel)
  PROCNAMEC()
  
  ; macScanXMLDevMaps(grMaps\aMap, grMaps\aDev, grMaps\nMaxMapIndex, grProd, grVST, grMaps\aLiveGrp, #True)
  macScanXMLDevMaps(grMaps, grProd, grVST, #True)
  grMVUD\bDevMapDisplayed = #False
  grMVUD\bDevMapCurrentlyDisplayed = #False
  
EndProcedure

Procedure scanXMLDevMaps2(*CurrentNode, CurrentSublevel)
  PROCNAMEC()
  
  ; macScanXMLDevMaps(grMapsForImport\aMap, grMapsForImport\aDev, grMapsForImport\nMaxMapIndex, gr2ndProd, gr2ndVST, grMapsForImport\aLiveGrp, #False)
  macScanXMLDevMaps(grMapsForImport, gr2ndProd, gr2ndVST, #False)
  
EndProcedure

Macro macScanXMLDevMaps3(paDevMap, paDev, pnDevMapCount, prProd, prVST, paLiveGrp, pPrimaryFile)
  ; Added 11Nov2022 11.9.7ae
  Protected sNodeName.s, sNodeText.s
  Protected sParentNodeName.s
  Protected sAttributeName.s, sAttributeValue.s
  Protected n, n2, n3, d, m, vstCounter
  Protected *nChildNode
  Protected nDevType
  Protected bNodeProcessed
  Protected sMyDevMapName.s
  Protected sDevGrpExt.s
  Protected sMsg.s
  Protected nPhysicalDevPtrNew
  Protected nIndex, nBandNo, nCtrlSendDelay
  Protected sDummyDev.s, sDummyDevENUS.s
  Protected sDummyDev2.s, sDummyDevENUS2.s
  Protected sBuildDate.s
  Static nDevMapPtr
  Static nDevMapId
  Static rThisDev.tyDevMapDev
  Static rThisLiveGrp.tyLiveGrp
  Static rThisDevFixture.tyDevFixture
  Static nCmdIndex, nFixtureIndex
  Static bAudioDriverSet
  Static nAudioDriver
  Static bASIOFound
  Static bDMXTrgCtrlFound
  Static nEQBand
  Static rThisMsgResponse.tyNetworkMsgResponse
  Static nMsgResponseIndex
  Static bIgnoreDevMap
  Static nCurrentPluginIndex
  Static d2, g2
  Static nMyPrevDevIndex, nMyPrevLiveGrpIndex
  
  ; debugMsg(sProcName, #SCS_START)
  
  If CurrentSublevel = 0
    bIgnoreDevMap = #False
  EndIf
  
  ; Ignore anything except normal nodes. See the manual for XMLNodeType() for an explanation of the other node types.
  If XMLNodeType(*CurrentNode) = #PB_XML_Normal
    
    sNodeName = GetXMLNodeName(*CurrentNode)
    If XMLChildCount(*CurrentNode) = 0
      sNodeText = GetXMLNodeText(*CurrentNode)
    EndIf
    gsXMLNodeName(CurrentSublevel) = sNodeName
    If CurrentSublevel > 0
      sParentNodeName = gsXMLNodeName(CurrentSublevel-1)
    EndIf
    
    If ExamineXMLAttributes(*CurrentNode)
      While NextXMLAttribute(*CurrentNode)
        sAttributeName = XMLAttributeName(*CurrentNode)
        sAttributeValue = XMLAttributeValue(*CurrentNode)
        Break ; no more than one attribute is used for XML nodes in the Prod Devices file
      Wend
    EndIf
    
; debugMsg(sProcName, ">> sNodeName=" + sNodeName + ", sNodeText=" + sNodeText + ", sAttributeName=" + sAttributeName + ", sAttributeValue=" + sAttributeValue + ", bIgnoreDevMap=" + strB(bIgnoreDevMap))
    If bIgnoreDevMap = #False ; see "DevMapC" regarding the setting of bIgnoreDevMap
      Select sNodeName
        Case "DevMaps"
          ; no action required
          
        Case "Head"
          ; no action required
          
        Case "Version"
          ; no action required
          
        Case "DevMap"
          bIgnoreDevMap = #False
          pnDevMapCount + 1
          nDevMapPtr = pnDevMapCount - 1
          If nDevMapPtr > ArraySize(paDevMap())
            REDIM_ARRAY(paDevMap, nDevMapPtr+20, grDevMapDef, "paDevMap()")
          EndIf
          If sAttributeName = "DevMapName"
            paDevMap(nDevMapPtr)\sDevMapName = sAttributeValue
          EndIf
          gnUniqueDevMapId + 1
          nDevMapId = gnUniqueDevMapId
          paDevMap(nDevMapPtr)\sDevMapFileName = GetFilePart(sDevMapFile)
          paDevMap(nDevMapPtr)\nDevMapId = nDevMapId
          paDevMap(nDevMapPtr)\nFirstDevIndex = -1
          paDevMap(nDevMapPtr)\nFirstLiveGrpIndex = -1
          paDevMap(nDevMapPtr)\nAudioDriver = gnDefaultAudioDriver
          paDevMap(nDevMapPtr)\bIgnoreThisDevMap = #False
          d2 = gnLastDevForBestMatch
          g2 = gnLastLiveGrpForBestMatch
          nMyPrevDevIndex = -1
          nMyPrevLiveGrpIndex = -1
          bAudioDriverSet = #False
          bASIOFound = #False
          
        Case "DevMapC"
          ; DevMapC (common devmap) obsolete so set bIgnoreDevMap to ignore any data for this obsolete device map
          bIgnoreDevMap = #True
          
        Case "AudioDriver"
          paDevMap(nDevMapPtr)\nAudioDriver = encodeAudioDriver(sNodeText)
          If paDevMap(nDevMapPtr)\nAudioDriver > 0
            bAudioDriverSet = #True
            nAudioDriver = paDevMap(nDevMapPtr)\nAudioDriver
          EndIf
          
        Case "Device"
; debugMsg(sProcName, "(Device) d2=" + d2)
          ; debugMsg(sProcName, "processing Device, nDevMapPtr=" + nDevMapPtr)
          ; initialise variables for device fields
          rThisDev = grDevMapDevDef
          If sAttributeName = "DevType"
            rThisDev\nDevType = encodeDevType(sAttributeValue)
            rThisDev\nDevGrp = getDevGrpFromDevDevType(rThisDev\nDevType)
            rThisDev\nMaxDevFixture = -1
          EndIf
          bDMXTrgCtrlFound = #False
          nFixtureIndex = -1
          ; debugMsg(sProcName, "rThisDev\nDevGrp=" + decodeDevGrp(rThisDev\nDevGrp) + ", rThisDev\nDevType=" + decodeDevType(rThisDev\nDevType) + ", rThisDev\bDummy=" + strB(rThisDev\bDummy))
          
        Case "DevName"
          rThisDev\sLogicalDev = sNodeText
          ; debugMsg(sProcName, "rThisDev\sLogicalDev=" + rThisDev\sLogicalDev)
          
        Case "PhysDev"
          rThisDev\sPhysicalDev = sNodeText
          If rThisDev\nDevType = #SCS_DEVTYPE_AUDIO_OUTPUT
            If FindString(UCase(rThisDev\sPhysicalDev), "ASIO") > 0
              bASIOFound = #True
            EndIf
          EndIf
          
        Case "DefaultDev"
          rThisDev\bDefaultDev = stringToBoolean(sNodeText)
          ; debugMsg(sProcName, "rThisDev\bDefaultDev=" + strB(rThisDev\bDefaultDev))
          
        Case "Dummy"
          rThisDev\bDummy = stringToBoolean(sNodeText)
          ; debugMsg(sProcName, "rThisDev\bDummy=" + strB(rThisDev\bDummy))
          
          ;- Audio Out
        Case "Outputs"
          rThisDev\s1BasedOutputRange = sNodeText
        Case "DelayTime"
          rThisDev\nDelayTime = Val(sNodeText)
        Case "OutputGainDB"
          sNodeText = readDBLevel(sNodeText)
          If ValF(sNodeText) < ValF(grLevels\sMinDBLevel)
            sNodeText = grLevels\sMinDBLevel
          EndIf
          rThisDev\sDevOutputGainDB = sNodeText
          rThisDev\fDevOutputGain = convertDBStringToBVLevel(sNodeText)
          ; debugMsg(sProcName, "rThisDev\sDevOutputGainDB=" + rThisDev\sDevOutputGainDB + ", rThisDev\fDevOutputGain=" + formatLevel(rThisDev\fDevOutputGain))
          
          ;- Video Capture
        Case "VidCapFormat"
          rThisDev\sVidCapFormat = sNodeText
          
        Case "VidCapFrameRate"
          rThisDev\dVidCapFrameRate = ValD(sNodeText)

          ;- Live Input
        Case "Inputs", "InputChan"
          rThisDev\s1BasedInputRange = sNodeText
        Case "InputDelayTime"
          rThisDev\nInputDelayTime = Val(sNodeText)
        Case "InputGainDB"
          sNodeText = readDBLevel(sNodeText)
          If ValF(sNodeText) < ValF(grLevels\sMinDBLevel)
            sNodeText = grLevels\sMinDBLevel
          EndIf
          rThisDev\sInputGainDB = sNodeText
          rThisDev\fInputGain = convertDBStringToBVLevel(sNodeText)
        Case "InputLowCutSelected"
          rThisDev\bInputLowCutSelected = stringToBoolean(sNodeText)
          If rThisDev\bInputLowCutSelected
            rThisDev\bInputEQOn = #True
          EndIf
        Case "InputLowCutFreq"
          rThisDev\nInputLowCutFreq = Val(sNodeText)
        Case "InputEQBand"
          nEQBand = Val(sAttributeValue)
          ; debugMsg(sProcName, "InputEQBand: sAttributeValue=" + sAttributeValue + ", nEQBand=" + Str(nEQBand))
        Case "InputEQBandSelected"
          nIndex = nEQBand - 1
          If (nIndex >= 0) And (nIndex <= #SCS_MAX_EQ_BAND)
            rThisDev\aInputEQBand[nIndex]\bEQBandSelected = stringToBoolean(sNodeText)
            If rThisDev\aInputEQBand[nIndex]\bEQBandSelected
              rThisDev\bInputEQOn = #True
            EndIf
          EndIf
        Case "InputEQGainDB"
          sNodeText = readDBLevel(sNodeText)
          nIndex = nEQBand - 1
          If (nIndex >= 0) And (nIndex <= #SCS_MAX_EQ_BAND)
            rThisDev\aInputEQBand[nIndex]\sEQGainDB = sNodeText
          EndIf
        Case "InputEQFreq"
          nIndex = nEQBand - 1
          If (nIndex >= 0) And (nIndex <= #SCS_MAX_EQ_BAND)
            rThisDev\aInputEQBand[nIndex]\nEQFreq = Val(sNodeText)
          EndIf
        Case "InputEQQ"
          nIndex = nEQBand - 1
          If (nIndex >= 0) And (nIndex <= #SCS_MAX_EQ_BAND)
            rThisDev\aInputEQBand[nIndex]\fEQQ = ValF(sNodeText)
          EndIf
          
          ;- MIDI Thru
        Case "MidiConnectName"
          DEV_UPDATE(sMidiThruInPhysicalDev, sNodeText)
        Case "MidiConnectDummy"
          rThisDev\bMidiThruInDummy = stringToBoolean(sNodeText)
          ; debugMsg(sProcName, "rThisDev\bMidiThruInDummy=" + strB(rThisDev\bMidiThruInDummy))
          
          ;- MIDI In (cue ctrl)
          ; pre 20150401 fields
        Case "MidiCtrlMethod"
          DEV_UPDATE(nCtrlMethodx, encodeCtrlMethod(sNodeText))
        Case "MidiDevId"
          DEV_UPDATE(nMidiDevIdx, Val(sNodeText))
        Case "MscCommandFormat"
          DEV_UPDATE(nMscCommandFormatx, Val(sNodeText))
        Case "MidiGoMacro"
          DEV_UPDATE(nGoMacrox, Val(sNodeText))
        Case "MidiChannel"
          DEV_UPDATE(nMidiChannelx, Val(sNodeText))
        Case "MidiCommand"
          nCmdIndex = encodeMidiCommand(sAttributeValue, @prProd) ; sets nCmdIndex for child tags
        Case "MidiCmd"
          DEV_UPDATE(aMidiCommandx[nCmdIndex]\nCmd, Val(sNodeText))  ; decimal equivalent of MIDI command, eg 8 for Note Off, 9 for Note On, 15 for Pitch Bend
        Case "MidiCC"
          DEV_UPDATE(aMidiCommandx[nCmdIndex]\nCC, Val(sNodeText))
        Case "MidiVV"
          If sNodeText = "*"
            DEV_UPDATE(aMidiCommandx[nCmdIndex]\nVV, #SCS_MIDI_ANY_VALUE)
          Else
            DEV_UPDATE(aMidiCommandx[nCmdIndex]\nVV, Val(sNodeText))
          EndIf
          
          ;- RS232
          ; pre 20150401 fields
        Case "DataBits"
          DEV_UPDATE(nRS232DataBitsx, Val(sNodeText))
        Case "StopBits"
          DEV_UPDATE(fRS232StopBitsx, ValF(sNodeText))
        Case "BaudRate"
          DEV_UPDATE(nRS232BaudRatex, Val(sNodeText))
        Case "Parity"
          DEV_UPDATE(nRS232Parityx, encodeParity(sNodeText))
        Case "Handshaking"
          DEV_UPDATE(nRS232Handshakingx, encodeHandshaking(sNodeText))
        Case "RTSEnable"
          DEV_UPDATE(nRS232RTSEnablex, Val(sNodeText))
        Case "DTREnable"
          DEV_UPDATE(nRS232DTREnablex, Val(sNodeText))
          
          ;- Network (TCP/UDP)
        Case "RemoteHost"
          DEV_UPDATE(sRemoteHost, sNodeText)
        Case "RemotePort"
          DEV_UPDATE(nRemotePort, portStrToInt(sNodeText))
        Case "LocalPort"
          DEV_UPDATE(nLocalPort, portStrToInt(sNodeText))
          ; pre 20150401 fields
        Case "NetworkRole", "TelnetRole"
          DEV_UPDATE(nNetworkRolex, encodeNetworkRole(sNodeText))
        Case "NetworkSendAddCR", "TelnetSendAddCR"
          DEV_UPDATE(bReplyMsgAddCRx, Val(sNodeText))
        Case "NetworkSendAddLF", "TelnetSendAddLF"
          DEV_UPDATE(bReplyMsgAddLFx, Val(sNodeText))
        Case "NetworkMsgResponse", "TelnetMsgResponse"
          rThisMsgResponse = grMsgResponse
        Case "ReceiveMsg"
          rThisMsgResponse\sReceiveMsg = sNodeText
          rThisMsgResponse\sComparisonMsg = makeComparisonMsg(rThisMsgResponse\sReceiveMsg)
        Case "MsgAction"
          rThisMsgResponse\nMsgAction = encodeNetworkMsgAction(sNodeText)
        Case "ReplyMsg"
          rThisMsgResponse\sReplyMsg = sNodeText
        Case "CtrlSendDelay"
          DEV_UPDATE(nCtrlSendDelay, Val(sNodeText))
          
          ;- DMX
        Case "DMXReceiveSerial", "DMXSerial"
          DEV_UPDATE(sDMXSerial, sNodeText)
        Case "DMXNumSerial"
          DEV_UPDATE(nDMXSerial, Val(sNodeText))
        Case "DMXPort"
          DEV_UPDATE(nDMXPort, Val(sNodeText))
        Case "DMXRefreshRate"
          DEV_UPDATE(nDMXRefreshRate, Val(sNodeText))
          ; pre 20150401 fields
        Case "DMXPref"
          DEV_UPDATE(nDMXPrefx, encodeDMXPref(sNodeText))      
        Case "DMXTrgCtrl"
          bDMXTrgCtrlFound = #True
          DEV_UPDATE(nDMXTrgCtrlx, encodeDMXTrgCtrl(sNodeText))
          ; debugMsg(sProcName, "DMXTrgCtrl: sNodeText=" + sNodeText + ", rThisDev\nDMXTrgCtrlx=" + decodeDMXTrgCtrl(rThisDev\nDMXTrgCtrlx))
        Case "DMXTrgValue"
          DEV_UPDATE(nDMXTrgValuex, Val(sNodeText))
        Case "DMXCommand"
          nCmdIndex = encodeDMXCommand(sAttributeValue) ; sets nCmdIndex for child tags
        Case "DMXChannel"
          DEV_UPDATE(aDMXCommandx[nCmdIndex]\nChannel, Val(sNodeText))
          
          ;- Fixtures
        Case "Fixture"
          rThisDevFixture = grDevFixtureDef
          If sAttributeName = "FixtureCode"
            rThisDevFixture\sDevFixtureCode = sAttributeValue
          EndIf
          
        Case "DMXStartChannel"
          If Val(sNodeText) > 0
            rThisDevFixture\nDevDMXStartChannel = Val(sNodeText)
          EndIf
          
        Case "DMXStartChannels"
          rThisDevFixture\sDevDMXStartChannels = sNodeText
          
          ;- Live Input Group
        Case "Group"
          ; initialise variables for live input group fields
          rThisLiveGrp = grLiveGrpDef
          If sAttributeName = "GrpName"
            rThisLiveGrp\sLiveGrpName = sAttributeValue
          EndIf
          
        Case "GrpDevType" ; group device type
          rThisLiveGrp\nDevType = encodeDevType(sNodeText)
          rThisLiveGrp\nDevGrp = getDevGrpFromDevDevType(rThisLiveGrp\nDevType)
          
        Case "GrpComp"  ; group component (logical dev or another group)
          If rThisLiveGrp\nCompCount <= #SCS_MAX_LIVE_INPUT_DEV_PER_AUD
            rThisLiveGrp\sCompName[rThisLiveGrp\nCompCount] = sNodeText
            rThisLiveGrp\nCompCount + 1
          EndIf
          
        Case "VSTPlugins"
          nCurrentPluginIndex = -1
          
        Case "Plugin" ; VST Plugin Name
          nCurrentPluginIndex = -1
          For n = 0 To prVST\nMaxLibVSTPlugin
            If prVST\aLibVSTPlugin(n)\sLibVSTPluginName = sAttributeValue
              nCurrentPluginIndex = n
              Break
            EndIf
          Next n
          
        Case "PluginFile32"
          If nCurrentPluginIndex >= 0
            prVST\aLibVSTPlugin(nCurrentPluginIndex)\sLibVSTPluginFile32 = sNodeText
          EndIf
          
        Case "PluginFile64"
          If nCurrentPluginIndex >= 0
            prVST\aLibVSTPlugin(nCurrentPluginIndex)\sLibVSTPluginFile64 = sNodeText
          EndIf
          
          ;- HTTP Request
        Case "HTTPStart"
          rThisDev\sHTTPStartx = sNodeText
          
          ; Selected Device Map
        Case "SelectedDevMap"
          gsDevMapFileSelectedDevMap = sNodeText
          
          ; File Save Info
        Case "_Saved_"
          gsDevMapFileSaved = sNodeText
          
        Case "FileSaveInfo", "_SCS_Version_"
          ; no action
          
        Case "_SCS_Build_"
          ; no action
          
        Default
          ; debugMsg(sProcName, "!!!!!!!!!! unprocessed tag: sNodeName=" + sNodeName)
          
      EndSelect
    EndIf ; EndIf bIgnoreDevMap = #False
    
    ; Now get the first child node (if any)
    *nChildNode = ChildXMLNode(*CurrentNode)
    
    While *nChildNode <> 0
      ; Loop through all available child nodes and call this procedure again
      scanXMLDevMaps3(*nChildNode, CurrentSublevel + 1, sDevMapFile)
      *nChildNode = NextXMLNode(*nChildNode)
    Wend        
    
    ; process any end-of-node requirements
    If bIgnoreDevMap = #False Or sNodeName = "DevMapC"
      Select sNodeName
        Case "Device"   ; /Device
          ; debugMsg(sProcName, "processing /Device, nDevMapPtr=" + nDevMapPtr)
          ; search for this logical device
          ; if device not found ignore the device map device
          ; debugMsg(sProcName, "rThisDev\nDevGrp=" + decodeDevGrp(rThisDev\nDevGrp) + ", rThisDev\sLogicalDev=" + rThisDev\sLogicalDev)
          If Trim(rThisDev\sLogicalDev)
            If rThisDev\bDefaultDev
              Select rThisDev\nDevType
                Case #SCS_DEVTYPE_AUDIO_OUTPUT
                  If (bAudioDriverSet) And (nAudioDriver = #SCS_DRV_BASS_DS Or nAudioDriver = #SCS_DRV_BASS_WASAPI)
                    rThisDev\sPhysicalDev = grMMedia\sDefAudDevDesc
                  EndIf
                Case #SCS_DEVTYPE_VIDEO_AUDIO
                  rThisDev\sPhysicalDev = grMMedia\sDefAudDevDesc
              EndSelect
            EndIf
            d2 + 1
; debugMsg(sProcName, "(/Device) d2=" + d2)
            If d2 > ArraySize(paDev())
              REDIM_ARRAY(paDev, d2+20, grDevMapDevDef, "paDev()")
            EndIf
            paDev(d2) = rThisDev
            If nMyPrevDevIndex < 0
              paDevMap(nDevMapPtr)\nFirstDevIndex = d2
            Else
              paDev(nMyPrevDevIndex)\nNextDevIndex = d2
            EndIf
            ; With paDev(d2)  ; can't use With in a Macro
            paDev(d2)\bExists = #True
            paDev(d2)\nDevMapId =  nDevMapId
            paDev(d2)\nPrevDevIndex = nMyPrevDevIndex
            paDev(d2)\nNextDevIndex = -1
            ; paDev(d2)\nDevId = prProd\aAudioLogicalDevs[d]\nDevId
            ; debugMsg(sProcName, "paDev(" + d2 + ")\nDevId=" + paDev(d2)\nDevId)
            ; EndWith
            ; grCFH\nDevIndex = d2
            nMyPrevDevIndex = d2
            
            gnLastDevForBestMatch = d2
; debugMsg(sProcName, "(/Device) gnLastDevForBestMatch=" + gnLastDevForBestMatch + ", ArraySize(paDev())=" + ArraySize(paDev()))
            If nDevMapPtr > gnMaxDevMapForBestMatchPtr
              gnMaxDevMapForBestMatchPtr = nDevMapPtr
              ; debugMsg(sProcName, "gnMaxDevMapForBestMatchPtr=" + Str(gnMaxDevMapForBestMatchPtr))
            EndIf
            ; debugMsg(sProcName, "sNodeName=" + sNodeName + ", nDevMapPtr=" + nDevMapPtr)

            ; debugMsg(sProcName, "paDevMap(" + nDevMapPtr + ")\nFirstDevIndex=" + paDevMap(nDevMapPtr)\nFirstDevIndex)
            d = paDevMap(nDevMapPtr)\nFirstDevIndex
            While d >= 0
              ; debugMsg(sProcName, "paDev(" + d + ")\nDevGrp=" + decodeDevGrp(paDev(d)\nDevGrp) + ", paDev(" + d + ")\sLogicalDev=" + paDev(d)\sLogicalDev)
              If (paDev(d)\nDevGrp = rThisDev\nDevGrp) And (paDev(d)\sLogicalDev = rThisDev\sLogicalDev)
                ; debugMsg(sProcName, "nDevGrp " + decodeDevGrp(rThisDev\nDevGrp) + ", sLogicalDev " + rThisDev\sLogicalDev + " found at d=" + d)
                ; debugmsg(sProcName, "paDev(" + d + ")\nDevGrp=" + decodeDevGrp(paDev(d)\nDevGrp) + ", rThisDev\nDevGrp=" + decodeDevGrp(rThisDev\nDevGrp) +
                ;                     ", \nDevType=" + decodeDevType(paDev(d)\nDevType) + ", rThisDev\nDevType=" + decodeDevType(rThisDev\nDevType))
                If (paDev(d)\nDevType = rThisDev\nDevType) Or (paDev(d)\nDevGrp = #SCS_DEVGRP_CUE_CTRL)
                  paDev(d)\bExists = #True
                  paDev(d)\nDevMapId =  nDevMapId
                  paDev(d)\nDevType = rThisDev\nDevType
                  ; added 23Nov2016 11.5.2.4.010
                  Select rThisDev\nDevType
                    Case #SCS_DEVTYPE_CC_DMX_IN, #SCS_DEVTYPE_LT_DMX_OUT
                      sDummyDev = Lang("DMX", "Dummy")
                      sDummyDevENUS = "Dummy DMX Port"
                    Case #SCS_DEVTYPE_CC_MIDI_IN
                      sDummyDev = Lang("MIDI", "DummyInPort")
                      sDummyDevENUS = "Dummy MIDI In Port"
                    Case #SCS_DEVTYPE_CS_MIDI_OUT
                      sDummyDev = Lang("MIDI", "DummyOutPort")
                      sDummyDevENUS = "Dummy MIDI Out Port"
                    Case #SCS_DEVTYPE_CS_MIDI_THRU
                      sDummyDev = Lang("MIDI", "DummyOutPort")
                      sDummyDevENUS = "Dummy MIDI Out Port"
                      sDummyDev2 = Lang("MIDI", "DummyInPort")
                      sDummyDevENUS2 = "Dummy MIDI In Port"
                    Case #SCS_DEVTYPE_CC_NETWORK_IN, #SCS_DEVTYPE_CS_NETWORK_OUT
                      sDummyDev = Lang("Network", "Dummy")
                      sDummyDevENUS = "Dummy Network Connection"
                    Case #SCS_DEVTYPE_CC_RS232_IN, #SCS_DEVTYPE_CS_RS232_OUT
                      sDummyDev = Lang("RS232", "Dummy")
                      sDummyDevENUS = "Dummy Serial Port"
                    Default
                      sDummyDev = ""
                      sDummyDevENUS = ""
                  EndSelect
                  ; debugMsg(sProcName, "rThisDev\nDevType=" + decodeDevType(rThisDev\nDevType) + ", rThisDev\sPhysicalDev=" + rThisDev\sPhysicalDev + ", sDummyDev=" + sDummyDev + ", sDummyDevENUS=" + sDummyDevENUS)
                  If sDummyDev
                    ; set \bDummy if required (for device map files created prior to SCS 11.5.2.4.010)
                    If (rThisDev\bDummy = #False) And ((rThisDev\sPhysicalDev = sDummyDev) Or (rThisDev\sPhysicalDev = sDummyDevENUS))
                      rThisDev\bDummy = #True
                    EndIf
                    ; (re)populate \sPhysicalDev for dummy devices - to provide language-independence in case user changed language since \sPhysicalDev was last set
                    If rThisDev\bDummy
                      rThisDev\sPhysicalDev = sDummyDev
                    EndIf
                  EndIf
                  ; debugMsg(sProcName, "rThisDev\sPhysicalDev=" + rThisDev\sPhysicalDev + ", rThisDev\bDummy=" + strB(rThisDev\bDummy))
                  ; end added 23Nov2016 11.5.2.4.010
                  paDev(d)\bDummy = rThisDev\bDummy
                  paDev(d)\bDefaultDev = rThisDev\bDefaultDev
                  paDev(d)\sPhysicalDev = rThisDev\sPhysicalDev
                  ; debugMsg(sProcName, "paDev(" + d + ")\sPhysicalDev=" + paDev(d)\sPhysicalDev + ", \bDefaultDev=" + strB(paDev(d)\bDefaultDev))
                  ; paDev(d)\nDevId = rThisDev\nDevId
                  ; set nAudioDriver (if necessary) for getPhysicalDevPtr()
                  If bAudioDriverSet = #False
                    nAudioDriver = gnDefaultAudioDriver
                    If bASIOFound
                      If nAudioDriver = #SCS_DRV_BASS_DS Or nAudioDriver = #SCS_DRV_BASS_WASAPI
                        nAudioDriver = #SCS_DRV_BASS_ASIO
                      EndIf
                    EndIf
                  EndIf
                  paDev(d)\nPhysicalDevPtr = getPhysicalDevPtr(paDev(d)\nDevType, rThisDev\sPhysicalDev, nAudioDriver, rThisDev\sDMXSerial, rThisDev\nDMXSerial, rThisDev\bDummy)
                  Select paDev(d)\nDevType
                    Case #SCS_DEVTYPE_AUDIO_OUTPUT  ; #SCS_DEVTYPE_AUDIO_OUTPUT
                      If paDev(d)\nPhysicalDevPtr >= 0
                        paDev(d)\bNoDevice = gaAudioDev(paDev(d)\nPhysicalDevPtr)\bNoDevice
                        If gaAudioDev(paDev(d)\nPhysicalDevPtr)\bASIO
                          bASIOFound = #True
                        EndIf
                      EndIf
                      paDev(d)\s1BasedOutputRange = rThisDev\s1BasedOutputRange
                      paDev(d)\nFirst1BasedOutputChan = getFirst1BasedChanFromRange(paDev(d)\s1BasedOutputRange)
                      paDev(d)\nFirst0BasedOutputChan = paDev(d)\nFirst1BasedOutputChan - 1
                      paDev(d)\nNrOfDevOutputChans = getNumChansFromRange(paDev(d)\s1BasedOutputRange)
                      paDev(d)\nDelayTime = rThisDev\nDelayTime
                      paDev(d)\sDevOutputGainDB = rThisDev\sDevOutputGainDB
                      paDev(d)\fDevOutputGain = rThisDev\fDevOutputGain
                      
                    Case #SCS_DEVTYPE_VIDEO_AUDIO ; #SCS_DEVTYPE_VIDEO_AUDIO
                      paDev(d)\nNrOfDevOutputChans = 2
                      paDev(d)\sDevOutputGainDB = rThisDev\sDevOutputGainDB
                      paDev(d)\fDevOutputGain = rThisDev\fDevOutputGain
                      If Len(paDev(d)\s1BasedOutputRange) = 0
                        paDev(d)\s1BasedOutputRange = "L-R"
                      EndIf
                      
                    Case #SCS_DEVTYPE_VIDEO_CAPTURE ; #SCS_DEVTYPE_VIDEO_CAPTURE
                      paDev(d)\sVidCapFormat = rThisDev\sVidCapFormat
                      paDev(d)\dVidCapFrameRate = rThisDev\dVidCapFrameRate
                      
                    Case #SCS_DEVTYPE_LIVE_INPUT  ; #SCS_DEVTYPE_LIVE_INPUT
                      If paDev(d)\nPhysicalDevPtr >= 0
                        paDev(d)\bNoDevice = gaAudioDev(paDev(d)\nPhysicalDevPtr)\bNoDevice
                        If gaAudioDev(paDev(d)\nPhysicalDevPtr)\bASIO
                          bASIOFound = #True
                        EndIf
                      EndIf
                      paDev(d)\s1BasedInputRange = rThisDev\s1BasedInputRange
                      ; debugMsg(sProcName, "paDev(" + d + ")\s1BasedInputRange=" + paDev(d)\s1BasedInputRange) ; + ", \s0BasedInputRange=" + paDev(d)\s0BasedInputRange)
                      paDev(d)\nFirst1BasedInputChan = getFirst1BasedChanFromRange(paDev(d)\s1BasedInputRange)
                      paDev(d)\nFirst0BasedInputChan = paDev(d)\nFirst1BasedInputChan - 1
                      ; debugMsg(sProcName, "paDev(" + d + ")\nFirst1BasedInputChan=" + paDev(d)\nFirst1BasedInputChan)
                      paDev(d)\nNrOfInputChans = getNumChansFromRange(paDev(d)\s1BasedInputRange)
                      paDev(d)\nInputDelayTime = rThisDev\nInputDelayTime
                      paDev(d)\sInputGainDB = rThisDev\sInputGainDB
                      paDev(d)\fInputGain = rThisDev\fInputGain
                      ; debugMsg(sProcName, "paDev(" + d + ")\sInputGainDB=" + paDev(d)\sInputGainDB + ", \fInputGain=" + traceLevel(paDev(d)\fInputGain))
                      paDev(d)\bInputLowCutSelected = rThisDev\bInputLowCutSelected
                      paDev(d)\nInputLowCutFreq = rThisDev\nInputLowCutFreq
                      For nBandNo = 0 To #SCS_MAX_EQ_BAND
                        paDev(d)\aInputEQBand[nBandNo]\bEQBandSelected = rThisDev\aInputEQBand[nBandNo]\bEQBandSelected
                        paDev(d)\aInputEQBand[nBandNo]\sEQGainDB = rThisDev\aInputEQBand[nBandNo]\sEQGainDB
                        paDev(d)\aInputEQBand[nBandNo]\nEQFreq = rThisDev\aInputEQBand[nBandNo]\nEQFreq
                        paDev(d)\aInputEQBand[nBandNo]\fEQQ = rThisDev\aInputEQBand[nBandNo]\fEQQ
                      Next nBandNo
                      paDev(d)\bInputEQOn = rThisDev\bInputEQOn
                      
                    Case #SCS_DEVTYPE_CC_MIDI_IN   ; #SCS_DEVTYPE_CC_MIDI_IN
                      paDev(d)\nMidiInPhysicalDevPtr = getMidiInPhysicalDevPtr(paDev(d)\sPhysicalDev, paDev(d)\bDummy)
                      ; debugMsg(sProcName, "#SCS_DEVTYPE_CC_MIDI_IN: paDev(" + d + ")\sPhysicalDev=" + paDev(d)\sPhysicalDev + ", \nMidiInPhysicalDevPtr=" + paDev(d)\nMidiInPhysicalDevPtr)
                      
                    Case #SCS_DEVTYPE_CS_MIDI_THRU   ; #SCS_DEVTYPE_CS_MIDI_THRU
                      paDev(d)\bMidiThruInDummy = rThisDev\bMidiThruInDummy
                      paDev(d)\sMidiThruInPhysicalDev = rThisDev\sMidiThruInPhysicalDev
                      paDev(d)\nMidiThruInPhysicalDevPtr = getPhysicalDevPtr(#SCS_DEVTYPE_CC_MIDI_IN, rThisDev\sMidiThruInPhysicalDev, nAudioDriver, "", 0, rThisDev\bMidiThruInDummy)
                      
                    Case #SCS_DEVTYPE_CC_RS232_IN, #SCS_DEVTYPE_CS_RS232_OUT
                      paDev(d)\bReopenDevice = #True
                      
                    Case #SCS_DEVTYPE_CC_NETWORK_IN, #SCS_DEVTYPE_CS_NETWORK_OUT
                      paDev(d)\sRemoteHost = rThisDev\sRemoteHost
                      paDev(d)\nRemotePort = rThisDev\nRemotePort
                      paDev(d)\nLocalPort = rThisDev\nLocalPort
                      paDev(d)\nCtrlSendDelay = rThisDev\nCtrlSendDelay
                      
                    Case #SCS_DEVTYPE_CC_DMX_IN, #SCS_DEVTYPE_LT_DMX_OUT
                      If rThisDev\nDMXSerial = 0
                        If rThisDev\sDMXSerial
                          rThisDev\nDMXSerial = DMX_getDMXNumSerialForStrSerial(rThisDev\sDMXSerial)
                          ; debugMsg2(sProcName, "DMX_getDMXNumSerialForStrSerial(" + rThisDev\sDMXSerial + ")", rThisDev\nDMXSerial)
                        EndIf
                      EndIf
                      paDev(d)\nDMXSerial = rThisDev\nDMXSerial
                      paDev(d)\sDMXSerial = rThisDev\sDMXSerial
                      If paDev(d)\nPhysicalDevPtr >= 0
                        paDev(d)\nDMXPorts = gaDMXDevice(paDev(d)\nPhysicalDevPtr)\nDMXPorts
                      EndIf
                      paDev(d)\nDMXPort = rThisDev\nDMXPort
                      ; debugMsg(sProcName, "paDev(" + d + ")\nDMXPort=" + paDev(d)\nDMXPort)
                      If rThisDev\nDevType = #SCS_DEVTYPE_LT_DMX_OUT
                        ; debugMsg(sProcName, "processing rThisDev\nDevType=" + decodeDevType(rThisDev\nDevType) + ", nFixtureIndex=" + nFixtureIndex)
                        paDev(d)\sDMXIpAddress = rThisDev\sDMXIpAddress
                        paDev(d)\nDMXRefreshRate = rThisDev\nDMXRefreshRate
                        paDev(d)\nMaxDevFixture = nFixtureIndex
                        ; debugMsg(sProcName, "paDev(" + d + ")\nMaxDevFixture=" + paDev(d)\nMaxDevFixture)
                        If nFixtureIndex >= 0
                          ReDim rThisDev\aDevFixture(nFixtureIndex)  ; array size may be larger than nFixtureIndex so redim before using CopyArray()
                          CopyArray(rThisDev\aDevFixture(), paDev(d)\aDevFixture())
                        EndIf
                        ; debugMsg(sProcName, "paDev(d=" + d + ")\nDMXSerial=" + paDev(d)\nDMXSerial + ", \sDMXSerial=" + paDev(d)\sDMXSerial + ", \nDMXPorts=" + paDev(d)\nDMXPorts + ", \nDMXPort=" + paDev(d)\nDMXPort +
                        ;                     ", \nDMXRefreshRate=" + paDev(d)\nDMXRefreshRate + ", \nMaxDevFixture=" + paDev(d)\nMaxDevFixture)
                      Else
                        ; debugMsg(sProcName, "paDev(d=" + d + ")\nDMXSerial=" + paDev(d)\nDMXSerial + ", \sDMXSerial=" + paDev(d)\sDMXSerial + ", \nDMXPorts=" + paDev(d)\nDMXPorts + ", \nDMXPort=" + paDev(d)\nDMXPort)
                      EndIf
                      
                    Case #SCS_DEVTYPE_CS_HTTP_REQUEST  ; #SCS_DEVTYPE_CS_HTTP_REQUEST
                      grHTTPControl\bExists = #True
                      grHTTPControl\nDevMapId = nDevMapId
                      grHTTPControl\nDevType = paDev(d)\nDevType
                      buildHTTPDevDesc(@grHTTPControl)
                      paDev(d)\sPhysicalDev = grHTTPControl\sHTTPDevDesc
                      paDev(d)\sHTTPStartx = rThisDev\sHTTPStartx
                      paDev(d)\nPhysicalDevPtr = 0
                      paDev(d)\bDummy = #False
                      ; debugMsg(sProcName, "paDev(" + d + ")\sLogicalDev=" + paDev(d)\sLogicalDev + ", \sPhysicalDev=" + paDev(d)\sPhysicalDev + ", \nPhysicalDevPtr=" + paDev(d)\nPhysicalDevPtr)
                      
                  EndSelect
                EndIf
                Break
              EndIf
              d = paDev(d)\nNextDevIndex
            Wend
          EndIf
          
        Case "Fixture" ; /Fixture (Lighting Fixture)
          ; debugMsg(sProcName, "processing /Fixture")
          nFixtureIndex + 1
          If nFixtureIndex > ArraySize(rThisDev\aDevFixture())
            ReDim rThisDev\aDevFixture(nFixtureIndex+10)
          EndIf
          rThisDev\nMaxDevFixture + 1
          rThisDev\aDevFixture(nFixtureIndex) = rThisDevFixture
          
        Case "Group" ; /Group (Live Input Group)
          ; debugMsg(sProcName, "processing /Group, nDevMapPtr=" + nDevMapPtr)
          g2 + 1
          If g2 > ArraySize(paLiveGrp())
            REDIM_ARRAY(paLiveGrp, g2+5, grLiveGrpDef, "paLiveGrp()")
          EndIf
          If nMyPrevLiveGrpIndex < 0
            paDevMap(nDevMapPtr)\nFirstLiveGrpIndex = g2
            ; debugMsg(sProcName, "paDevMap(" + nDevMapPtr + ")\nFirstLiveGrpIndex=" + paDevMap(nDevMapPtr)\nFirstLiveGrpIndex)
          Else
            paLiveGrp(nMyPrevLiveGrpIndex)\nNextLiveGrpIndex = g2
            ; debugmsg(sProcName, "paLiveGrp(" + nMyPrevLiveGrpIndex + ")\nNextLiveGrpIndex=" + paLiveGrp(nMyPrevLiveGrpIndex)\nNextLiveGrpIndex)
          EndIf
          paLiveGrp(g2) = rThisLiveGrp
          paLiveGrp(g2)\bExists = #True
          paLiveGrp(g2)\nDevMapId =  nDevMapId
          paLiveGrp(g2)\nPrevLiveGrpIndex = nMyPrevLiveGrpIndex
          paLiveGrp(g2)\nNextLiveGrpIndex = -1
          nMyPrevLiveGrpIndex = g2
          
        Case "DevMap" ; /DevMap
          ; debugMsg(sProcName, "(/DevMap) d2=" + d2)
          If bAudioDriverSet = #False
            paDevMap(nDevMapPtr)\nAudioDriver = gnDefaultAudioDriver
            If bASIOFound
              If paDevMap(nDevMapPtr)\nAudioDriver = #SCS_DRV_BASS_DS Or paDevMap(nDevMapPtr)\nAudioDriver = #SCS_DRV_BASS_WASAPI
                paDevMap(nDevMapPtr)\nAudioDriver = #SCS_DRV_BASS_ASIO
              EndIf
            EndIf
          EndIf
          
          d = paDevMap(nDevMapPtr)\nFirstDevIndex
          nAudioDriver = paDevMap(nDevMapPtr)\nAudioDriver
          While d >= 0
            paDev(d)\nPhysicalDevPtr = getPhysicalDevPtr(paDev(d)\nDevType, paDev(d)\sPhysicalDev, nAudioDriver, paDev(d)\sDMXSerial, paDev(d)\nDMXSerial, paDev(d)\bDummy)
            d = paDev(d)\nNextDevIndex
          Wend
          
        Case "DevMapC" ; /DevMapC
          bIgnoreDevMap = #False
          
      EndSelect
    EndIf ; EndIf bIgnoreDevMap = #False Or sNodeName = "DevMapC"
    
  EndIf ; EndIf XMLNodeType(*CurrentNode) = #PB_XML_Normal
  
  ; debugMsg(sProcName, #SCS_END)
  
EndMacro

Procedure scanXMLDevMaps3(*CurrentNode, CurrentSublevel, sDevMapFile.s)
  PROCNAMEC()
  
  macScanXMLDevMaps3(gaDevMapForBestMatch, gaDevForBestMatch, gnDevMapForBestMatchCount, grProd, grVST, gaLiveGrpForBestMatch, #False)
  
EndProcedure

Macro MAC_addProdDevInfo(nParamDevType, sParamDevName)
  If sParamDevName And nParamDevType <> #SCS_DEVTYPE_NONE
    nMaxProdDevInfo + 1
    If nMaxProdDevInfo > ArraySize(aProdDevInfo())
      ReDim aProdDevInfo(nMaxProdDevInfo + 8)
    EndIf
    aProdDevInfo(nMaxProdDevInfo)\nDevType = nParamDevType
    aProdDevInfo(nMaxProdDevInfo)\sDevName = sParamDevName
    nDevCount + 1
  EndIf
EndMacro

Procedure.s lookForBestMatchingDevMapFile(sThisCueFile.s)
  PROCNAMEC()
  
  Structure tyBestMatchDevInfo
    nDevType.i
    sDevName.s
    bDevFound.i
  EndStructure
  Protected Dim aProdDevInfo.tyBestMatchDevInfo(0)
  Protected nMaxProdDevInfo
  
  Structure tyDevFixtureCode
    sDevName.s
    sFixtureCode.s
    bFixtureCodeFound.i
  EndStructure
  Protected Dim aProdDevFixtureCode.tyDevFixtureCode(0)
  Protected nMaxProdDevFixtureCode
  
  Protected nDevMapsDir, sDevMapFile.s, xmlDevMaps, *nRootNode
  Protected d, d2, d3, d4, d5, d6, d7
  Protected sThisCueFileLCase.s, sTempCueFileLCase.s, sSortKey.s, nMaxLengthOfMapId
  Protected sBestDevMapFile.s
  Protected bProceedWithSearchForBestMatch
  Protected nDevMapFileFirstDevMapPtr, nDevMapFileLastDevMapPtr
  Protected bAllFixtureCodesFound
  Protected bAllDevsForThisDevMapFoundInProd, bThisProdDevFound, bAllProdDevsFoundInThisDevMap, bThisProdFixtureCodeFound
  Protected bTrace = #False
  Protected nDevCount
  
  debugMsg(sProcName, #SCS_START + ", sThisCueFile=" + #DQUOTE$ + GetFilePart(sThisCueFile) + #DQUOTE$)
  
  ; INFO: PART 1 - Populate array aProdDevInfo() with the device type and name of each device in Production Properties of the cue file,
  ; INFO:          and array aProdDevFixtureCode() with device names and fixture code of any lighting fixture devices
  ;{
  nMaxProdDevInfo = -1
  nMaxProdDevFixtureCode = -1
  bProceedWithSearchForBestMatch = #True
  gbSCSDefaultDevsOnly = #True
  With grProd
    For d = 0 To \nMaxAudioLogicalDev
      MAC_addProdDevInfo(#SCS_DEVTYPE_AUDIO_OUTPUT, \aAudioLogicalDevs(d)\sLogicalDev)
    Next d
    If nDevCount > 1
      ; more than one audio output device, so this is not the SCS default
      gbSCSDefaultDevsOnly = #False
    EndIf
    nDevCount = 0 ; reset count
    For d = 0 To \nMaxVidAudLogicalDev
      MAC_addProdDevInfo(#SCS_DEVTYPE_VIDEO_AUDIO, \aVidAudLogicalDevs(d)\sVidAudLogicalDev)
    Next d
    If nDevCount > 1
      ; more than one video audio device, so this is not the SCS default
      gbSCSDefaultDevsOnly = #False
    EndIf
    nDevCount = 0 ; reset count, but now don't need to check until all devices types scanned, as ANY other device from here on is not in the SCS defaults
    For d = 0 To \nMaxVidCapLogicalDev
      MAC_addProdDevInfo(#SCS_DEVTYPE_VIDEO_CAPTURE, \aVidCapLogicalDevs(d)\sLogicalDev)
    Next d
    For d = 0 To \nMaxLightingLogicalDev
      MAC_addProdDevInfo(#SCS_DEVTYPE_LT_DMX_OUT, \aLightingLogicalDevs(d)\sLogicalDev)
      If \aLightingLogicalDevs(d)\sLogicalDev
        For d2 = 0 To \aLightingLogicalDevs(d)\nMaxFixture
          If \aLightingLogicalDevs(d)\aFixture(d2)\sFixtureCode
            nMaxProdDevFixtureCode + 1
            If nMaxProdDevFixtureCode > ArraySize(aProdDevFixtureCode())
              ReDim aProdDevFixtureCode(nMaxProdDevFixtureCode + 10)
            EndIf
            aProdDevFixtureCode(nMaxProdDevFixtureCode)\sDevName = \aLightingLogicalDevs(d)\sLogicalDev
            aProdDevFixtureCode(nMaxProdDevFixtureCode)\sFixtureCode = \aLightingLogicalDevs(d)\aFixture(d2)\sFixtureCode
          EndIf
        Next d2
      EndIf
    Next d
    For d = 0 To \nMaxCtrlSendLogicalDev
      MAC_addProdDevInfo(\aCtrlSendLogicalDevs(d)\nDevType, \aCtrlSendLogicalDevs(d)\sLogicalDev)
    Next d
    For d = 0 To \nMaxCueCtrlLogicalDev
      MAC_addProdDevInfo(\aCueCtrlLogicalDevs(d)\nDevType, \aCueCtrlLogicalDevs(d)\sCueCtrlLogicalDev)
    Next d
    For d = 0 To \nMaxLiveInputLogicalDev
      ; MAC_addProdDevInfo(\aLiveInputLogicalDevs(d)\nDevType, \aLiveInputLogicalDevs[d]\sLogicalDev)
      If \aLiveInputLogicalDevs(d)\sLogicalDev
        bProceedWithSearchForBestMatch = #False ; NOTE: To simplify subsequent processing, do not proceed if this cue file has live input devices. (Live inputs are rarely used and require SM-S.)
        Break
      EndIf
    Next d
    If nDevCount > 0
      ; at least one 'other' device type specified, so this is not the SCS default
      gbSCSDefaultDevsOnly = #False
    EndIf
  EndWith
  If bProceedWithSearchForBestMatch = #False
    ProcedureReturn ""
  EndIf
  
  CompilerIf 1=2
    For d = 0 To nMaxProdDevInfo
      debugMsg(sProcName, "aProdDevInfo(" + d + ")\nDevType=" + decodeDevType(aProdDevInfo(d)\nDevType) + ", \sDevName=" + aProdDevInfo(d)\sDevName)
    Next d
    For d = 0 To nMaxProdDevFixtureCode
      debugMsg(sProcName, "aProdDevFixtureCode(" + d + ")\sDevName=" + aProdDevFixtureCode(d)\sDevName + ", \sFixtureCode=" + aProdDevFixtureCode(d)\sFixtureCode)
    Next d
  CompilerEndIf
  ;}
  
  ; INFO: PART 2 - Populate the global array gaDevMapForBestMatch() with ALL device maps found in the DevMaps folder, and then sort the array to place the 'best match' items at the top of the array.
  ;{
  nDevMapsDir = ExamineDirectory(#PB_Any, gsDevMapsPath, "*.scsd")
  ; debugMsg(sProcName, "nDevMapsDir=" + nDevMapsDir)
  If nDevMapsDir
    While NextDirectoryEntry(nDevMapsDir)
      If DirectoryEntryType(nDevMapsDir) = #PB_DirectoryEntry_File
        If DirectoryEntrySize(nDevMapsDir) > 0
          sDevMapFile = gsDevMapsPath + DirectoryEntryName(nDevMapsDir)
          xmlDevMaps = LoadXML(#PB_Any, sDevMapFile)
          ; debugMsg(sProcName, "sDevMapFile=" + #DQUOTE$ + sDevMapFile + #DQUOTE$ + ", xmlDevMaps=" + xmlDevMaps)
          If xmlDevMaps
            If XMLStatus(xmlDevMaps) = #PB_XML_Success
              *nRootNode = MainXMLNode(xmlDevMaps)      
              If *nRootNode
                nDevMapFileFirstDevMapPtr = gnMaxDevMapForBestMatchPtr + 1
                gsDevMapFileSelectedDevMap = ""
                gsDevMapFileSaved = ""
                scanXMLDevMaps3(*nRootNode, 0, sDevMapFile) ; Note that scanXMLDevMaps3() is called for each device map file found in the folder
                nDevMapFileLastDevMapPtr = gnMaxDevMapForBestMatchPtr
                For d = nDevMapFileFirstDevMapPtr To nDevMapFileLastDevMapPtr
                  gaDevMapForBestMatch(d)\sDevMapFileSaved = gsDevMapFileSaved
                  If gaDevMapForBestMatch(d)\sDevMapName = gsDevMapFileSelectedDevMap
                    gaDevMapForBestMatch(d)\bDevMapFileSelectedDevMap = #True
                  Else
                    gaDevMapForBestMatch(d)\bDevMapFileSelectedDevMap = #False
                  EndIf
                Next d
                ; debugMsg(sProcName, "end of scan, gnMaxDevMapForBestMatchPtr=" + gnMaxDevMapForBestMatchPtr)
              EndIf
            EndIf
          EndIf
        EndIf
      EndIf
    Wend
  EndIf
  debugMsg(sProcName, "gnDevMapForBestMatchCount=" + gnDevMapForBestMatchCount + ", gnMaxDevMapForBestMatchPtr=" + gnMaxDevMapForBestMatchPtr)
  
  If gnMaxDevMapForBestMatchPtr >= 0
    sThisCueFileLCase = LCase(sThisCueFile)
    nMaxLengthOfMapId = Len(Str(gnUniqueDevMapId))
    For d2 = 0 To gnMaxDevMapForBestMatchPtr
      With gaDevMapForBestMatch(d2)
        If \sDevMapFileSaved
          ; When building the Sort Key, single spaces have been included for legibility in logging (if #cTraceDevMapBestMatch=#True). These single spaces have no significance in the sorting order.
          sTempCueFileLCase = LCase(deriveCueFileNameFromDevMapFileName(\sDevMapFileName))
          If sTempCueFileLCase = sThisCueFileLCase
            sSortKey = "1" ; high priority if the cue file name matches the device map name
          Else
            sSortKey = "0" ; low priority if not
          EndIf
          sSortKey + " " + \sDevMapFileSaved ; add the "_Saved_" value, ag "2022/11/08 22:54:48"
          sSortKey + " " + \sDevMapFileName  ; then the device map's file name
          If \bDevMapFileSelectedDevMap
            sSortKey + " 1" ; high priority (after file saved date/time) if this is the selected device map for this dev map file
          Else
            sSortKey + " 0" ; low priority if not the selected device map
            sSortKey + " " + RSet(Str(gnUniqueDevMapId - \nDevMapId), nMaxLengthOfMapId, "0") ; this ensures non-selected device maps retain their original order after the non-desconding sort
          EndIf
          \sDevMapSortKey = sSortKey
          \bIgnoreThisDevMap = #False
        Else
          ; very old device map files that do not have a 'file saved' entry will be sorted to the end (sort is descending)
          \sDevMapSortKey = ""
          \bIgnoreThisDevMap = #True
; debugMsg(sProcName, "gaDevMapForBestMatch(" + d2 + ")\sDevMapFileName=" + \sDevMapFileName + ", \sDevMapFileSaved=" + \sDevMapFileSaved)
        EndIf
      EndWith
    Next d2
    SortStructuredArray(gaDevMapForBestMatch(), #PB_Sort_Descending | #PB_Sort_NoCase, OffsetOf(tyDevMap\sDevMapSortKey), #PB_String, 0, gnMaxDevMapForBestMatchPtr)
    CompilerIf #cTraceDevMapBestMatch
      For d2 = 0 To gnMaxDevMapForBestMatchPtr
        With gaDevMapForBestMatch(d2)
          If \bIgnoreThisDevMap = #False
            debugMsg(sProcName, "gaDevMapForBestMatch(" + d2 + ")\sDevMapSortKey=" + \sDevMapSortKey + ", \sDevMapName=" + \sDevMapName + ", \nFirstDevIndex=" + \nFirstDevIndex + ", \nDevMapId=" + \nDevMapId)
          EndIf
        EndWith
      Next d2
    CompilerEndIf
  EndIf
  ;}
  
  ; INFO: PART 3 - Now step through the global array gaDevMapForBestMatch() to find the first device map the best fits the new cue file.
  ; INFO: PART 3 - The name of this device map file will be returned by this procedure via sBestDevMapFile, which will be blank if no suitable existing device map is found.
  ;{
  If gnMaxDevMapForBestMatchPtr >= 0
    For d = 0 To gnMaxDevMapForBestMatchPtr
      If gaDevMapForBestMatch(d)\bIgnoreThisDevMap
        Continue
      EndIf
      debugMsgC(sProcName, "nMaxProdDevInfo=" + nMaxProdDevInfo + ", nMaxProdDevFixtureCode=" + nMaxProdDevFixtureCode)
      For d2 = 0 To nMaxProdDevInfo
        aProdDevInfo(d2)\bDevFound = #False
      Next d2
      For d3 = 0 To nMaxProdDevFixtureCode
        aProdDevFixtureCode(d3)\bFixtureCodeFound = #False
      Next d3
      bAllDevsForThisDevMapFoundInProd = #True
      d4 = gaDevMapForBestMatch(d)\nFirstDevIndex
      While d4 >= 0
        With gaDevForBestMatch(d4)
          debugMsgC(sProcName, "gaDevForBestMatch(" + d4 + ")\nDevType=" + decodeDevType(\nDevType) + ", \sLogicalDev=" + \sLogicalDev)
          bThisProdDevFound = #False
          For d5 = 0 To nMaxProdDevInfo
            debugMsgC(sProcName, "aProdDevInfo(" + d5 + ")\nDevType=" + decodeDevType(aProdDevInfo(d5)\nDevType) + ", \sDevName=" + aProdDevInfo(d5)\sDevName +
                                 ", gaDevForBestMatch(" + d4 + ")\nDevType=" + decodeDevType(\nDevType) + ", \sLogicalDev=" + \sLogicalDev)
            If aProdDevInfo(d5)\nDevType = \nDevType And aProdDevInfo(d5)\sDevName = \sLogicalDev
              debugMsgC(sProcName, "gaDevForBestMatch(" + d4 + ")\nDevType=" + decodeDevType(\nDevType) + ", \sLogicalDev=" + \sLogicalDev)
              If \nDevType = #SCS_DEVTYPE_LT_DMX_OUT
                debugMsgC(sProcName, "nMaxProdDevFixtureCode=" + nMaxProdDevFixtureCode + ", gaDevForBestMatch(" + d4 + ")\nMaxDevFixture=" + \nMaxDevFixture)
                If nMaxProdDevFixtureCode = \nMaxDevFixture ; Test added 9Jun2023 11.10.0
                  bAllFixtureCodesFound = #True
                  For d6 = 0 To nMaxProdDevFixtureCode
                    bThisProdFixtureCodeFound = #False
                    For d7 = 0 To \nMaxDevFixture
                      ; debugMsgC(sProcName, "aProdDevFixtureCode(" + d6 + ")\sFixtureCode=" + aProdDevFixtureCode(d6)\sFixtureCode + ", gaDevForBestMatch(" + d4 + ")\aDevFixture(" + d7 + ")\sDevFixtureCode=" + \aDevFixture(d7)\sDevFixtureCode)
                      If aProdDevFixtureCode(d6)\sFixtureCode = \aDevFixture(d7)\sDevFixtureCode
                        bThisProdFixtureCodeFound = #True
                        debugMsgC(sProcName, "aProdDevFixtureCode(" + d6 + ")\sFixtureCode=" + aProdDevFixtureCode(d6)\sFixtureCode + ", bThisProdFixtureCodeFound=" + strB(bThisProdFixtureCodeFound))
                        Break ; Break d7
                      EndIf
                    Next d7
                    If bThisProdFixtureCodeFound = #False
                      bThisProdDevFound = #False
                      bAllFixtureCodesFound = #False
                      debugMsgC(sProcName, "Break 2")
                      Break 2 ; Break d6, d5
                    EndIf
                  Next d6
                  debugMsgC(sProcName, "bAllFixtureCodesFound=" + strB(bAllFixtureCodesFound))
                  If bAllFixtureCodesFound
                    aProdDevInfo(d5)\bDevFound = #True
                    bThisProdDevFound = #True
                    Break ; Break d5
                  EndIf
                EndIf
              Else
                aProdDevInfo(d5)\bDevFound = #True
                bThisProdDevFound = #True
                Break ; Break d5
              EndIf
            EndIf
          Next d5
          debugMsgC(sProcName, "bThisProdDevFound=" + strB(bThisProdDevFound))
          If bThisProdDevFound = #False
            bAllDevsForThisDevMapFoundInProd = #False
            Break ; Break d4
          EndIf
          d4 = \nNextDevIndex
        EndWith
      Wend
      debugMsgC(sProcName, "bAllDevsForThisDevMapFoundInProd=" + strB(bAllDevsForThisDevMapFoundInProd))
      If bAllDevsForThisDevMapFoundInProd
        ; All devices in this device map exist in the cue file's production properties.
        ; Now check if all the production properties devices were found in the device map.
        bAllProdDevsFoundInThisDevMap = #True
        For d2 = 0 To nMaxProdDevInfo
          If aProdDevInfo(d2)\bDevFound = #False
            bAllProdDevsFoundInThisDevMap = #False
            Break ; Break d2
          EndIf
        Next d2
        If bAllProdDevsFoundInThisDevMap
          ; We have found a device map with EXACTLY the same devices as specified in this cue file (not necessarily in the same order).
          sBestDevMapFile = gaDevMapForBestMatch(d)\sDevMapFileName
          Break ; Break d
        EndIf
      EndIf
    Next d
  EndIf
  ;}
  
  debugMsg(sProcName, #SCS_END + ", returning sBestDevMapFile=" + #DQUOTE$ + sBestDevMapFile + #DQUOTE$)
  ProcedureReturn sBestDevMapFile
EndProcedure

Procedure.s readXMLDevMapFile(bPrimaryFile, sDevMapFile.s)
  PROCNAMEC()
  Protected xmlDevMaps
  Protected sMsg.s
  Protected *nRootNode
  Protected sSelectedDevMapName.s
  Protected bValidationResult
  Protected n
  
  debugMsg(sProcName, #SCS_START + ", bPrimaryFile=" + strB(bPrimaryFile) + ", sDevMapFile=" + GetFilePart(sDevMapFile))
  
  ; debugMsg0(sProcName, "FileExists(" + sDevMapFile + ")=" + FileExists(sDevMapFile))
  If FileExists(sDevMapFile)
    
    If bPrimaryFile
      holdDevMapFile(sDevMapFile)
      ; reset gbMaxDevMapPtr (originally set in readXMLCueFile) if sDevMapFile exists
      grMaps\nMaxMapIndex = -1
    Else
      grMapsForImport\nMaxMapIndex = -1
    EndIf
    
    xmlDevMaps = LoadXML(#PB_Any, sDevMapFile)
    If xmlDevMaps
      ; Display an error message if there was a markup error
      If XMLStatus(xmlDevMaps) <> #PB_XML_Success
        sMsg = "Error in the XML file " + GetFilePart(sDevMapFile) + ":" + Chr(13)
        sMsg + "Message: " + XMLError(xmlDevMaps) + Chr(13)
        sMsg + "Line: " + XMLErrorLine(xmlDevMaps) + "   Character: " + XMLErrorPosition(xmlDevMaps)
        debugMsg(sProcName, sMsg)
        ensureSplashNotOnTop()
        scsMessageRequester(grText\sTextError, sMsg)
      Else
        *nRootNode = MainXMLNode(xmlDevMaps)      
        If *nRootNode
          If bPrimaryFile
            scanXMLDevMaps(*nRootNode, 0)
            sSelectedDevMapName = grMaps\sSelectedDevMapName
          Else
            scanXMLDevMaps2(*nRootNode, 0)
            sSelectedDevMapName = grMapsForImport\sSelectedDevMapName
          EndIf
        EndIf
      EndIf
      FreeXML(xmlDevMaps)
    EndIf
    
  EndIf
  
  If bPrimaryFile
    debugMsg(sProcName, "calling setConnectWhenReqdForDevs()")
    setConnectWhenReqdForDevs() ; Added 19Sep2022 11.9.6
    debugMsg(sProcName, "calling validateDevMaps()")
    bValidationResult = validateDevMaps()
    If (bValidationResult = #False) Or (gbDevMapsDeleted)
      ; resave the devmap file with changes made in validateDevMaps()
      debugMsg(sProcName, "calling writeXMLDevMapFile(" +  sSelectedDevMapName + ", " + grProd\sProdId + ")")
      grProd\sDevMapFile = writeXMLDevMapFile(sSelectedDevMapName, grProd\sProdId)
      debugMsg(sProcName, "grProd\sDevMapFile=" + #DQUOTE$ + grProd\sDevMapFile + #DQUOTE$)
    EndIf
  EndIf
  
  debugMsg(sProcName, #SCS_END + ", returning " + sSelectedDevMapName)
  ProcedureReturn sSelectedDevMapName
  
EndProcedure

Procedure importDeviceMapFile(sCueFile.s, sImportFile.s, sDevMapFile.s)
  PROCNAMEC()
  Protected nImportFile, nDevMapFile
  Protected sLine.s
  Protected sExportedFromTag.s = "<_Exported_From_>", sExportedFromETag.s = "</_Exported_From_>"
  Protected sExportDateTimeTag.s = "<_Export_DateTime_>", sExportDateTimeETag.s = "</_Export_DateTime_>"
  Protected sExportedFrom.s
  Protected sExportDateTime.s
  Protected nPtrStart, nPtrEnd
  Protected sMsg.s
  Protected nReply
  ;   Protected sDevMapFile.s
  Protected bImported
  
  debugMsg(sProcName, #SCS_START)
  
  If FileExists(sImportFile)
    nImportFile = ReadFile(#PB_Any, sImportFile)
    debugMsg(sProcName, "nImportFile=" + nImportFile)
    If nImportFile
      While Eof(nImportFile) = 0
        sLine = ReadString(nImportFile)
        nPtrStart = FindString(sLine, sExportedFromTag)
        If nPtrStart > 0
          nPtrStart + Len(sExportedFromTag)
          nPtrEnd = FindString(sLine, sExportedFromETag)
          If nPtrEnd > nPtrStart
            sExportedFrom = Mid(sLine, nPtrStart, (nPtrEnd - nPtrStart))
          EndIf
        EndIf
        nPtrStart = FindString(sLine, sExportDateTimeTag)
        If nPtrStart > 0
          nPtrStart + Len(sExportDateTimeTag)
          nPtrEnd = FindString(sLine, sExportDateTimeETag)
          If nPtrEnd > nPtrStart
            sExportDateTime = Mid(sLine, nPtrStart, (nPtrEnd - nPtrStart))
          EndIf
        EndIf
      Wend
      debugMsg(sProcName, "sExportedFrom=" + sExportedFrom + ", sExportDateTime=" + sExportDateTime)
      
      If sExportedFrom And sExportDateTime
        sMsg = LangPars("DevMap", "ImportDevMaps",
                        #DQUOTE$ + GetFilePart(sCueFile) + #DQUOTE$,
                        #DQUOTE$ + GetFilePart(sImportFile) + #DQUOTE$,
                        #DQUOTE$ + sExportedFrom + #DQUOTE$,
                        sExportDateTime)
        nReply = scsMessageRequester(#SCS_TITLE, sMsg, #PB_MessageRequester_YesNo + #MB_ICONQUESTION)
        If nReply = #PB_MessageRequester_Yes
          ; sDevMapFile = gsDevMapsPath + ignoreExtension(GetFilePart(sImportFile)) + ".scsd"
          nDevMapFile = CreateFile(#PB_Any, sDevMapFile)  ; nb 'CreateFile()' overwrites the file if it already exists
          debugMsg2(sProcName, "CreateFile(#PB_Any, " + #DQUOTE$ + sDevMapFile + #DQUOTE$ + ")", nDevMapFile)
          If nDevMapFile
            FileSeek(nImportFile, 0)
            While Eof(nImportFile) = 0
              sLine = ReadString(nImportFile)
              If (FindString(sLine, sExportedFromTag) = 0) And (FindString(sLine, sExportDateTimeTag) = 0)
                WriteString(nDevMapFile, sLine + #LF$)
              EndIf
            Wend
            CloseFile(nDevMapFile)
            bImported = #True
          EndIf
        EndIf
      EndIf
      
      CloseFile(nImportFile)
    EndIf ; EndIf nImportFile
  EndIf   ; EndIf FileExists(sImportFileName)
  
  debugMsg(sProcName, #SCS_END + ", returning " + strB(bImported))
  ProcedureReturn bImported
  
EndProcedure

Procedure scanXMLTemplateDevMapFile(*CurrentNode, CurrentSublevel)
  PROCNAMEC()
  Protected sNodeName.s, sNodeText.s
  Protected sParentNodeName.s
  Protected Dim sAttributeName.s(1), Dim sAttributeValue.s(1), n ; Changed 18Jun2022 11.9.4
  Protected *nChildNode
  Static rTmDevMap.tyTmDevMap
  Static nTmDevMapPtr
  
  ; Ignore anything except normal nodes. See the manual for XMLNodeType() for an explanation of the other node types.
  If XMLNodeType(*CurrentNode) = #PB_XML_Normal
    
    sNodeName = GetXMLNodeName(*CurrentNode)
    If XMLChildCount(*CurrentNode) = 0
      sNodeText = GetXMLNodeText(*CurrentNode)
    EndIf
    gsXMLNodeName(CurrentSublevel) = sNodeName
    If CurrentSublevel > 0
      sParentNodeName = gsXMLNodeName(CurrentSublevel-1)
    EndIf
    
    If ExamineXMLAttributes(*CurrentNode)
      ; Changed 18Jun2022 11.9.4 to allow for more than one attribute
      n = -1
      While NextXMLAttribute(*CurrentNode)
        n + 1
        If n <= ArraySize(sAttributeName())
          sAttributeName(n) = XMLAttributeName(*CurrentNode)
          sAttributeValue(n) = XMLAttributeValue(*CurrentNode)
        Else
          Break
        EndIf
      Wend
      ; End changed 18Jun2022 11.9.4
    EndIf
    
    ; debugMsg(sProcName, ">> sNodeName=" + sNodeName + ", sNodeText=" + sNodeText + ", sAttributeName(0)=" + sAttributeName(0) + ", sAttributeValue(0)=" + sAttributeValue(0))
    Select sNodeName
        
      Case "AudioDriver"
        rTmDevMap\nAudioDriver = encodeAudioDriver(sNodeText)
        
      Case "DevMap"
        rTmDevMap = grTmDevMapDef
        If sAttributeName(0) = "DevMapName"
          rTmDevMap\sDevMapName = sAttributeValue(0)
        EndIf
        rTmDevMap\nAudioDriver = gnDefaultAudioDriver
        
      Case "DevMaps"
        nTmDevMapPtr = -1
        
    EndSelect
    
    ; Now get the first child node (if any)
    *nChildNode = ChildXMLNode(*CurrentNode)
    
    While *nChildNode <> 0
      ; Loop through all available child nodes and call this procedure again
      scanXMLTemplateDevMapFile(*nChildNode, CurrentSublevel + 1)
      *nChildNode = NextXMLNode(*nChildNode)
    Wend        
    
    ; process any end-of-node requirements
    Select sNodeName
      Case "DevMap"
        With rTmDevMap
          \sAudioDriverL = decodeDriverL(\nAudioDriver)
          \nTextColor = grColorScheme\aItem[#SCS_COL_ITEM_PR]\nTextColor
          \nBackColor = grColorScheme\aItem[#SCS_COL_ITEM_PR]\nBackColor
        EndWith
        nTmDevMapPtr + 1
        If ArraySize(gaTmDevMap()) < nTmDevMapPtr
          REDIM_ARRAY(gaTmDevMap, nTmDevMapPtr+5, grTmDevMapDef, "gaTmDevMap()")
        EndIf
        gaTmDevMap(nTmDevMapPtr) = rTmDevMap
        debugMsg(sProcName, "gaTmDevMap(" + nTmDevMapPtr + ")\sDevMapName=" + gaTmDevMap(nTmDevMapPtr)\sDevMapName)
        
      Case "DevMaps"
        gnLastTmDevMap = nTmDevMapPtr
        
    EndSelect
    
  EndIf
  
EndProcedure

Procedure.s readXMLTemplateDevMapFile(sFileName.s)
  PROCNAMEC()
  ; sFileName may be either a template devmap file (*.scstd) or a regular devmap file (*.scsd)
  Protected xmlTemplate
  Protected sMsg.s
  Protected *nRootNode
  Protected n
  
  debugMsg(sProcName, #SCS_START + ", sFileName=" + GetFilePart(sFileName))
  
  ; initialize arrays
  gnLastTmDevMap = -1
  For n = 0 To ArraySize(gaTmDevMap())
    gaTmDevMap(n) = grTmDevMapDef
  Next n
  
  If FileExists(sFileName)
    xmlTemplate = LoadXML(#PB_Any, sFileName)
    If xmlTemplate
      ; Display an error message if there was a markup error
      If XMLStatus(xmlTemplate) <> #PB_XML_Success
        sMsg = "Error in the XML file " + GetFilePart(sFileName) + ":" + Chr(13)
        sMsg + "Message: " + XMLError(xmlTemplate) + Chr(13)
        sMsg + "Line: " + XMLErrorLine(xmlTemplate) + "   Character: " + XMLErrorPosition(xmlTemplate)
        debugMsg(sProcName, sMsg)
        ensureSplashNotOnTop()
        scsMessageRequester(grText\sTextError, sMsg)
      Else
        *nRootNode = MainXMLNode(xmlTemplate)      
        If *nRootNode
          scanXMLTemplateDevMapFile(*nRootNode, 0)
        EndIf
      EndIf
      FreeXML(xmlTemplate)
    EndIf
  EndIf
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure scanXMLTemplateDevMap(*CurrentNode, CurrentSublevel, nTemplatePtr)
  PROCNAMEC()
  Protected sNodeName.s, sNodeText.s
  Protected sParentNodeName.s
  Protected Dim sAttributeName.s(1), Dim sAttributeValue.s(1) ; Changed 18Jun2022 11.9.4
  Protected *nChildNode
  Protected n
  Protected nPrevNode
  Protected bIncludeDevMap
  Static rTMDevMap.tyTmDevMap, rTmDev.tyTmDev
  Static nDevMapsNode, nDevMapNode, nDevMapDevNode, bThisDevMapIncluded, bThisDevIncluded
  Static bIgnore
  
  ; Ignore anything except normal nodes. See the manual for XMLNodeType() for an explanation of the other node types.
  If XMLNodeType(*CurrentNode) = #PB_XML_Normal
    
    sNodeName = GetXMLNodeName(*CurrentNode)
    If XMLChildCount(*CurrentNode) = 0
      sNodeText = GetXMLNodeText(*CurrentNode)
    EndIf
    gsXMLNodeName(CurrentSublevel) = sNodeName
    If CurrentSublevel > 0
      sParentNodeName = gsXMLNodeName(CurrentSublevel-1)
    EndIf
    
    If ExamineXMLAttributes(*CurrentNode)
      ; Changed 18Jun2022 11.9.4 to allow for more than one attribute
      n = -1
      While NextXMLAttribute(*CurrentNode)
        n + 1
        If n <= ArraySize(sAttributeName())
          sAttributeName(n) = XMLAttributeName(*CurrentNode)
          sAttributeValue(n) = XMLAttributeValue(*CurrentNode)
        Else
          Break
        EndIf
      Wend
      ; End changed 18Jun2022 11.9.4
    EndIf
    
    If bIgnore And sNodeName <> "\DevMapC"
      sNodeName = "*** IGNORE ***"
    EndIf
    
    ; debugMsg(sProcName, ">> sNodeName=" + sNodeName + ", sNodeText=" + sNodeText + ", sAttributeName=" + sAttributeName + ", sAttributeValue=" + sAttributeValue)
    Select sNodeName
      Case "*** IGNORE ***"
        ; no action
        
      Case "Device"
        rTmDev = grTmDevDef
        For n = 0 To ArraySize(sAttributeName())
          If sAttributeName(n) = "DevType"
            rTmDev\nDevType = encodeDevType(sAttributeValue(n))
          ElseIf sAttributeName(n) = "DevGrp"
            rTmDev\nDevGrp = encodeDevGrp(sAttributeValue(n))
          EndIf
        Next n
        If rTmDev\nDevGrp = grDevMapDevDef\nDevGrp
          ; no "DevGrp" attribute included
          rTmDev\nDevGrp = getDevGrpFromDevDevType(rTmDev\nDevType)
        EndIf
        If sAttributeName(0) = "DevType"
          rTmDev\nDevType = encodeDevType(sAttributeValue(0))
        EndIf
        nDevMapDevNode = *CurrentNode
        
      Case "DevMap"
        bIgnore = #False
        rTMDevMap = grTmDevMapDef
        If sAttributeName(0) = "DevMapName"
          rTMDevMap\sDevMapName = sAttributeValue(0)
        EndIf
        nDevMapNode = *CurrentNode
        debugMsg(sProcName, "sNodeName=" + sNodeName + ", \sDevMapName=" + rTMDevMap\sDevMapName + ", nDevMapNode=" + nDevMapNode)
        
      Case "DevMapC"
        bIgnore = #True
        
      Case "\DevMapC"
        bIgnore = #False
        
      Case "DevMaps"
        nDevMapsNode = *CurrentNode
        
      Case "DevName"
        rTmDev\sLogicalDev = sNodeText
        debugMsg(sProcName, "rTmDev\nDevType=" + decodeDevType(rTmDev\nDevType) + ", \sLogicalDev=" + rTmDev\sLogicalDev + ", nDevMapDevNode=" + nDevMapDevNode)
        
      Case "SelectedDevMap"
        bIncludeDevMap = #False
        If sNodeText
          For n = 0 To gnLastTmDevMap
            If gaTmDevMap(n)\sDevMapName = sNodeText
              bIncludeDevMap = gaTmDevMap(n)\bIncludeDevMap
              Break
            EndIf
          Next n
        EndIf
        If bIncludeDevMap = #False
          debugMsg(sProcName, "sNodeName=" + sNodeName + ", sNodeText=" + sNodeText + ", calling DeleteXMLNode(" + *CurrentNode + ")")
          DeleteXMLNode(*CurrentNode)
        EndIf
        
    EndSelect
    
    ; Now get the first child node (if any)
    *nChildNode = ChildXMLNode(*CurrentNode)
    
    While *nChildNode <> 0
      ; Loop through all available child nodes and call this procedure again
      scanXMLTemplateDevMap(*nChildNode, CurrentSublevel+1, nTemplatePtr)
      *nChildNode = NextXMLNode(*nChildNode)
    Wend        
    
    ; process any end-of-node requirements
    Select sNodeName
      Case "Device"
        For n = 0 To gnLastTmDev
          If (gaTmDev(n)\nDevType = rTMDev\nDevType) And (gaTmDev(n)\sLogicalDev = rTmDev\sLogicalDev)
            If gaTmDev(n)\bIncludeDev = #False
              debugMsg(sProcName, "deleting " + decodeDevType(rTmDev\nDevType) + " device " + rTmDev\sLogicalDev)
              debugMsg(sProcName, "sNodeName=" + sNodeName + ", sNodeText=" + sNodeText + ", calling DeleteXMLNode(" + nDevMapDevNode + ")")
              DeleteXMLNode(nDevMapDevNode)
            EndIf
            Break
          EndIf
        Next n
        
      Case "DevMap"
        For n = 0 To gnLastTmDevMap
          If gaTmDevMap(n)\sDevMapName = rTMDevMap\sDevMapName
            If gaTmDevMap(n)\bIncludeDevMap = #False
              debugMsg(sProcName, "deleting devmap " + rTMDevMap\sDevMapName)
              debugMsg(sProcName, "sNodeName=" + sNodeName + ", sNodeText=" + sNodeText + ", calling DeleteXMLNode(" + nDevMapNode + ")")
              DeleteXMLNode(nDevMapNode)
            EndIf
            Break
          EndIf
        Next n
        
      Case "DevMaps"
        
    EndSelect
    
  EndIf
  
EndProcedure

Procedure saveXMLTemplateDevMapFile(nTemplatePtr, bCreateFromCueFile)
  PROCNAMEC()
  Protected xmlTemplateDevMap
  Protected sMsg.s
  Protected *nRootNode
  Protected nFileSaveNode, nPrevNode
  Protected sBaseFileName.s
  
  debugMsg(sProcName, #SCS_START + ", nTemplatePtr=" + nTemplatePtr)
  
  If nTemplatePtr >= 0
    With gaTemplate(nTemplatePtr)
      If bCreateFromCueFile
        sBaseFileName = \sDevMapFileName
      Else
        sBaseFileName = \sOrigTemplateDevMapFileName
      EndIf
      If FileExists(sBaseFileName, #False)
        xmlTemplateDevMap = LoadXML(#PB_Any, sBaseFileName)
        If xmlTemplateDevMap
          ; Display an error message if there was a markup error
          If XMLStatus(xmlTemplateDevMap) <> #PB_XML_Success
            sMsg = "Error in the XML file " + GetFilePart(sBaseFileName) + ":" + Chr(13)
            sMsg + "Message: " + XMLError(xmlTemplateDevMap) + Chr(13)
            sMsg + "Line: " + XMLErrorLine(xmlTemplateDevMap) + "   Character: " + XMLErrorPosition(xmlTemplateDevMap)
            debugMsg(sProcName, sMsg)
            scsMessageRequester(grText\sTextError, sMsg)
          Else
            *nRootNode = MainXMLNode(xmlTemplateDevMap)      
            If *nRootNode
              scanXMLTemplateDevMap(*nRootNode, 0, nTemplatePtr)
            EndIf
          EndIf
          nFileSaveNode = XMLNodeFromPath(*nRootNode, "/DevMaps/FileSaveInfo")
          If nFileSaveNode
            nPrevNode = updateOrCreateXMLNode(nFileSaveNode, "_Saved_", FormatDate("%yyyy/%mm/%dd %hh:%ii:%ss", Date()), nPrevNode)
            nPrevNode = updateOrCreateXMLNode(nFileSaveNode, "_SCS_Version_", #SCS_VERSION, nPrevNode)
            nPrevNode = updateOrCreateXMLNode(nFileSaveNode, "_SCS_Build_", grProgVersion\sBuildDateTime, nPrevNode)
          EndIf            
          FormatXML(xmlTemplateDevMap, #PB_XML_ReduceNewline|#PB_XML_ReFormat|#PB_XML_WindowsNewline, 2)
          SetXMLEncoding(xmlTemplateDevMap, #PB_UTF8)
          debugMsg(sProcName, "calling SaveXML(xmlTemplateDevMap, " + #DQUOTE$ + \sCurrTemplateDevMapFileName + ", #PB_XML_StringFormat)")
          SaveXML(xmlTemplateDevMap, \sCurrTemplateDevMapFileName, #PB_XML_StringFormat)
          FreeXML(xmlTemplateDevMap)
        EndIf
      EndIf
    EndWith
  EndIf
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure syncFixturesInDev(*rProd.tyProd, *rMaps.tyMaps)
  PROCNAMEC()
  Protected nDevMapPtr, nDevMapDevPtr
  Protected d, m
  Protected bFound
  Protected sLogicalDev.s, nMaxDevFixture, nProdMaxFixture
  Protected sThisFixtureCode.s, nFixtureIndex
  Protected Dim aWorkDevFixture.tyDevFixture(0)
  Protected rDevFixtureDef.tyDevFixture
  
  debugMsg(sProcName, #SCS_START)
  
  For d = 0 To *rProd\nMaxLightingLogicalDev
    sLogicalDev = *rProd\aLightingLogicalDevs(d)\sLogicalDev
    If sLogicalDev
      nProdMaxFixture = *rProd\aLightingLogicalDevs(d)\nMaxFixture
      For nDevMapPtr = 0 To *rMaps\nMaxMapIndex
        nDevMapDevPtr = getDevMapDevPtrForLogicalDev(*rMaps, #SCS_DEVGRP_LIGHTING, sLogicalDev, nDevMapPtr)
        If nDevMapDevPtr >= 0
          With *rMaps\aDev(nDevMapDevPtr)
            If nProdMaxFixture >= 0
              ReDim aWorkDevFixture(nProdMaxFixture)
              For nFixtureIndex = 0 To nProdMaxFixture
                aWorkDevFixture(nFixtureIndex) = rDevFixtureDef
              Next nFixtureIndex
              ; now sync the dev fixtures with the prod fixtures
              For nFixtureIndex = 0 To nProdMaxFixture
                sThisFixtureCode = *rProd\aLightingLogicalDevs(d)\aFixture(nFixtureIndex)\sFixtureCode
                ; debugMsg0(sProcName, "nFixtureIndex=" + nFixtureIndex + ", sThisFixtureCode=" + sThisFixtureCode)
                ; find this fixture code in the saved dev fixture settings
                bFound = #False
                For m = 0 To \nMaxDevFixture
                  If \aDevFixture(m)\sDevFixtureCode = sThisFixtureCode
                    aWorkDevFixture(nFixtureIndex) = \aDevFixture(m)
                    bFound = #True
                    Break
                  EndIf
                Next m
                If bFound = #False
                  aWorkDevFixture(nFixtureIndex) = grDevFixtureDef
                  aWorkDevFixture(nFixtureIndex)\sDevFixtureCode = sThisFixtureCode
                  ; Added 19Jun2023 11.10.0be
                  aWorkDevFixture(nFixtureIndex)\nDevDMXStartChannel = *rProd\aLightingLogicalDevs(d)\aFixture(nFixtureIndex)\nDefaultDMXStartChannel
                  aWorkDevFixture(nFixtureIndex)\sDevDMXStartChannels = Str(*rProd\aLightingLogicalDevs(d)\aFixture(nFixtureIndex)\nDefaultDMXStartChannel)
                  ; debugMsg0(sProcName, "aWorkDevFixture(" + nFixtureIndex + ")\nDevDMXStartChannel=" + aWorkDevFixture(nFixtureIndex)\nDevDMXStartChannel)
                  ; End added 19Jun2023 11.10.0be
                EndIf
              Next nFixtureIndex
              CopyArray(aWorkDevFixture(), \aDevFixture())
            EndIf ; EndIf nProdMaxFixture >= 0
            \nMaxDevFixture = nProdMaxFixture
          EndWith
        EndIf ; EndIf nDevMapDevPtr >= 0
      Next nDevMapPtr
    EndIf ; EndIf sLogicalDev
  Next d
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure getDevMapFixtureIndexForFixtureCode(*rMaps.tyMaps, sLogicalDev.s, sFixtureCode.s)
  PROCNAMEC()
  Protected nDevPtr
  Protected n
  Protected nFixtureIndex = -1
  
  nDevPtr = getDevMapDevPtrForLogicalDev(*rMaps, #SCS_DEVGRP_LIGHTING, sLogicalDev)
  If nDevPtr >= 0
    With *rMaps\aDev(nDevPtr)
      For n = 0 To \nMaxDevFixture
        If \aDevFixture(n)\sDevFixtureCode = sFixtureCode
          nFixtureIndex = n
          Break
        EndIf
      Next n
    EndWith
  EndIf
  ProcedureReturn nFixtureIndex
EndProcedure

Procedure syncOutputChans(bPrimaryFile)
  PROCNAMEC()
  ; procedure added 17May2019 11.8.1rc3 following emails from Andrew Charnley.
  ; error was caused by the device map being out of sync with the production properties due to device map changes being made off-site.
  ; off-site, an extra audio output device had been added, and an existing audio output device had been changed from stereo to mono.
  Protected d1, d2
  Protected nProdOutputChans, nDevOutputChans
  Protected sLogicalDev.s
  
  debugMsg(sProcName, #SCS_START + ", bPrimaryFile=" + strB(bPrimaryFile))
  
  If bPrimaryFile
    For d1 = 0 To grProd\nMaxAudioLogicalDev
      If grProd\aAudioLogicalDevs(d1)\sLogicalDev
        sLogicalDev = grProd\aAudioLogicalDevs(d1)\sLogicalDev
        nProdOutputChans = grProd\aAudioLogicalDevs(d1)\nNrOfOutputChans
        d2 = getDevMapDevPtrForLogicalDev(@grMaps, #SCS_DEVGRP_AUDIO_OUTPUT, sLogicalDev)
        If d2 >= 0
          nDevOutputChans = grMaps\aDev(d2)\nNrOfDevOutputChans
          ; debugMsg(sProcName, "sLogicalDev=" + sLogicalDev + ", nProdOutputChans=" + nProdOutputChans + ", nDevOutputChans=" + nDevOutputChans)
          If nDevOutputChans <> nProdOutputChans
            grMaps\aDev(d2)\nNrOfDevOutputChans = nProdOutputChans
            grMaps\aDev(d2)\s1BasedOutputRange = ""
          EndIf
          ; debugMsg(sProcName, "grMaps\aDev(" + d2 + ")\nNrOfDevOutputChans=" + grMaps\aDev(d2)\nNrOfDevOutputChans + ", \s1BasedOutputRange=" + grMaps\aDev(d2)\s1BasedOutputRange)
        EndIf
      EndIf
    Next d1
  EndIf
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure populateDevStartChannelArray(*rDev.tyDevMapDev)
  PROCNAMEC()
  Protected nFixtureIndex, sDMXStartChannels.s
  Protected nPart, nPartCount, nDashCount
  Protected sPart.s, sFrom.s, sUpTo.s, nFrom, nUpTo
  Protected nChannelCount, nChannelNo, nIndex
  Protected nErrorCode, n, sTraceMsg.s, bDMXChannelLimit
  
  debugMsg(sProcName, #SCS_START)
  
  For nFixtureIndex = 0 To *rDev\nMaxDevFixture
    With *rDev\aDevFixture(nFixtureIndex)
      ; debugMsg(sProcName, "*rDev\aDevFixture(" + nFixtureIndex + ")\nDevDMXStartChannel=" + \nDevDMXStartChannel)
      \nMaxDevStartChannelIndex = -1
      If \nDevDMXStartChannel > 0
        \nMaxDevStartChannelIndex = 0
        \aDevStartChannel(0) = \nDevDMXStartChannel
        ; Added 15Mar2022 11.9.1an
        If \nDevDMXStartChannel > grLicInfo\nMaxDMXChannel
          bDMXChannelLimit = #True
        EndIf
        ; End added 15Mar2022 11.9.1an
      Else
        sDMXStartChannels = \sDevDMXStartChannels
        While #True ; While loop to enable 'Break' out of the loop if error found
          If Len(sDMXStartChannels) = 0
            Break
          EndIf
          ; extract and process channels (nb must extract fade time and level before processing the channels, which is why they are extracted in the above code)
          nPartCount = CountString(sDMXStartChannels, ",") + 1
          For nPart = 1 To nPartCount
            sPart = StringField(sDMXStartChannels, nPart, ",")
            nDashCount = CountString(sPart, "-")
            Select nDashCount
              Case 0
                sFrom = sPart
                sUpTo = sPart
              Case 1
                sFrom = StringField(sPart, 1, "-")
                sUpTo = StringField(sPart, 2, "-")
              Default
                ; shouldn't get here
                nErrorCode = 401
                Break
            EndSelect
            nFrom = Val(sFrom)
            nUpTo = Val(sUpTo)
            ; Added 15Mar2022 11.9.1an
            If nUpTo > grLicInfo\nMaxDMXChannel
              bDMXChannelLimit = #True
            EndIf
            ; End added 15Mar2022 11.9.1an
            nChannelCount = (nUpTo - nFrom + 1)
            If nChannelCount > 0
              nIndex = \nMaxDevStartChannelIndex
              \nMaxDevStartChannelIndex + nChannelCount
              If \nMaxDevStartChannelIndex > ArraySize(\aDevStartChannel())
                ReDim \aDevStartChannel(\nMaxDevStartChannelIndex)
              EndIf
              For nChannelNo = nFrom To nUpTo
                nIndex + 1
                \aDevStartChannel(nIndex) = nChannelNo
              Next nChannelNo
            EndIf
          Next nPart
          Break
        Wend
        If nErrorCode > 0
          Break
        EndIf
      EndIf ; EndIf \nDevDMXStartChannel > 0 / Else
      ; start for debugging only
      sTraceMsg = ""
      For n = 0 To \nMaxDevStartChannelIndex
        If n = 0
          sTraceMsg + \aDevStartChannel(n)
        Else
          sTraceMsg + "," + \aDevStartChannel(n)
        EndIf
      Next n
      If sTraceMsg
        debugMsg(sProcName, "*rDev\aDevFixture(" + nFixtureIndex + ")\sDevFixtureCode=" + \sDevFixtureCode + ", StartChannels: " + sTraceMsg)
      EndIf
      ; end start for debugging only
      ; debugMsg(sProcName, "*rDev\aDevFixture(" + nFixtureIndex + ")\nDevDMXStartChannel=" + \nDevDMXStartChannel)
    EndWith
  Next nFixtureIndex
  If bDMXChannelLimit And nErrorCode = 0
    nErrorCode = 405 ; DMX Channel Limit
  EndIf
  
  debugMsg(sProcName, #SCS_END + ", returning nErrorCode=" + nErrorCode)
  ProcedureReturn nErrorCode
  
EndProcedure

Procedure populateAllDevStartChannelArrays()
  PROCNAMEC()
  Protected nDevMapPtr, nDevIndex, nErrorCode, bDMXChannelLimit
  
  debugMsg(sProcName, #SCS_START)
  
  For nDevMapPtr = 0 To grMaps\nMaxMapIndex
    nDevIndex = grMaps\aMap(nDevMapPtr)\nFirstDevIndex
    While nDevIndex >= 0
      If grMaps\aDev(nDevIndex)\nDevType = #SCS_DEVTYPE_LT_DMX_OUT ; Test added 11Apr2022 11.9.1ba
        ; debugMsg(sProcName, "grMaps\aDev(" + nDevIndex + ")\nDevType=" + decodeDevType(grMaps\aDev(nDevIndex)\nDevType))
        nErrorCode = populateDevStartChannelArray(@grMaps\aDev(nDevIndex))
        ; Added 15Mar2022 11.9.1an
        ; debugMsg0(sProcName, "nErrorCode=" + nErrorCode)
        If nErrorCode = 405
          bDMXChannelLimit = #True
        EndIf
        ; End added 15Mar2022 11.9.1an
      EndIf
      nDevIndex = grMaps\aDev(nDevIndex)\nNextDevIndex
    Wend
  Next nDevMapPtr
  
  ; Added 15Mar2022 11.9.1an
  If bDMXChannelLimit
    DMX_ChannelLimitWarning()
  EndIf
  ; End added 15Mar2022 11.9.1an
  
  debugMsg(sProcName, #SCS_END)

EndProcedure

Procedure setConnectWhenReqdForDevs()
  ; Added 19Sep2022 11.9.6
  PROCNAMEC()
  Protected nDevMapPtr, d, bConnectWhenReqd, nDevIndex, sLogicalDev.s, nDevType
  
  ; debugMsg(sProcName, #SCS_START)
  
  nDevMapPtr = grProd\nSelectedDevMapPtr
  If nDevMapPtr >= 0
    For d = 0 To grProd\nMaxCtrlSendLogicalDev
      With grProd\aCtrlSendLogicalDevs(d)
        nDevType = \nDevType
        sLogicalDev = \sLogicalDev
        If nDevType = #SCS_DEVTYPE_CS_NETWORK_OUT
          bConnectWhenReqd = \bConnectWhenReqd
        Else
          bConnectWhenReqd = #False
        EndIf
      EndWith
      If sLogicalDev
        nDevIndex = grMaps\aMap(nDevMapPtr)\nFirstDevIndex
        While nDevIndex >= 0
          With grMaps\aDev(nDevIndex)
            If \nDevGrp = #SCS_DEVGRP_CTRL_SEND And \nDevType = nDevType And \sLogicalDev = sLogicalDev
              \bConnectWhenReqd = bConnectWhenReqd
              If \bConnectWhenReqd
                debugMsg(sProcName, "gaDev(" + nDevIndex + ")\sLogicalDev=" + \sLogicalDev + ", \bConnectWhenReqd=" + strB(\bConnectWhenReqd))
              EndIf
            EndIf
            nDevIndex = \nNextDevIndex
          EndWith
        Wend
      EndIf
    Next d
  EndIf
  
EndProcedure

Procedure.s deriveCueFileNameFromDevMapFileName(sDevMapFileName.s)
  ; Added 12Nov2022 11.9.7ae
  PROCNAMEC()
  ; Converts something like "U3A 2022 Variety Concert_206D2DC4.scsd" to "U3A 2022 Variety Concert.scs11", regardless of the number of underscores in the filename
  Protected sCueFileName.s, nUnderScoreCount, sProdIdAndExt.s, nProdIdPtr
  
  nUnderScoreCount = CountString(sDevMapFileName, "_")
  sProdIdAndExt = "_" + StringField(sDevMapFileName, nUnderScoreCount + 1, "_") ; eg sets sProdIdAndExt to "_206D2DC4.scsd"
  sCueFileName = RemoveString(sDevMapFileName, sProdIdAndExt) + ".scs11" ; remove the ProdId and Ext (and preceding underscore), and append ".scs11"
  ProcedureReturn sCueFileName
  
EndProcedure

Procedure changeOfDevMap(nNewDevMapPtr)
  PROCNAMEC()
  Protected nAudioDriver
  
  debugMsg(sProcName, "calling loadNetworkControl(#True)")
  loadNetworkControl(#True)
  
  If nNewDevMapPtr >= 0
    nAudioDriver = grMaps\aMap(nNewDevMapPtr)\nAudioDriver
    debugMsg(sProcName, "nAudioDriver=" + decodeDriver(nAudioDriver))
    If gnCurrAudioDriver <> nAudioDriver
      debugMsg3(sProcName, "calling closeDevices(" + decodeDriver(gnCurrAudioDriver) + ")")
      closeDevices(gnCurrAudioDriver)
      setCurrAudioDriver(nAudioDriver)
      setMasterFader(grMasterLevel\fProdMasterBVLevel, #True)
      debugMsg(sProcName, "calling setAllInputGains(#True)")
      setAllInputGains(#True)
    EndIf
    updateDevMapPhysicalDevPtrs()
    debugMsg(sProcName, "calling setDefaultVidAudDeviceIfReqd(#True, #True)")
    setDefaultVidAudDeviceIfReqd(#True, #True)
  EndIf

EndProcedure

Procedure createNewDevMapFromExistingDevMap(nDevMapPtr)
  ; Procedure created 18Jan2025 following bug reported by John Hutchinson.
  ; The bug occurs if the existing device map(s) use SM-S and there is no BASS ASIO device map, and then the program is run in an environment in which SM-S is not loaded.
  ; What would happen was that SCS would fail to find a suitable device map but would then ty to start the cue file with SM-S even though it was not loaded.
  ; This could cause all sorts of problems, especially if Live Input devices are specified.
  ; So what this procedure does is attempt to create an equivalent BASSASIO device map, assigning dummy live inputs if necessary.
  ; Now having a BASSASIO device map, the program will use that and avoid those problems.
  ; The new device map will be named "BASSASIO" (or "BASSASIO_1"...)
  PROCNAMEC()
  Protected nNewDevMapPtr
  Protected d1, d2, d3, nDevCount, nReqdDevArraySize
  Protected g1, g2, g3, nLiveGrpCount, nReqdLiveGrpArraySize
  Protected sNewDevMapName.s, nSubscript, n
  
  debugMsg(sProcName, #SCS_START + ", nDevMapPtr=" + nDevMapPtr)
  
  ; Determine a unique name for this new device map
  sNewDevMapName = "BASSASIO"
  With grMaps
    n =  -1
    While #True
      n + 1
      If n > \nMaxMapIndex
        Break
      ElseIf UCase(\aMap(n)\sDevMapName) = UCase(sNewDevMapName)
        nSubscript + 1
        sNewDevMapName = "BASSAIO_" + Str(nSubscript)
        n = -1 ; start test again with changed sNewDevMapName
        Continue
      EndIf
    Wend
  EndWith
  debugMsg(sProcName, "sNewDevMapName=" + sNewDevMapName)
  
  nNewDevMapPtr = grMaps\nMaxMapIndex + 1
  If ArraySize(grMaps\aMap()) < nNewDevMapPtr
    ReDim grMaps\aMap(nNewDevMapPtr)
  EndIf
  grMaps\aMap(nNewDevMapPtr) = grMaps\aMap(nDevMapPtr)
  grMaps\nMaxMapIndex + 1
  With grMaps\aMap(nNewDevMapPtr)
    \nAudioDriver = #SCS_DRV_BASS_ASIO
    \sDevMapName = sNewDevMapName
    d1 = \nFirstDevIndex
    g1 = \nFirstLiveGrpIndex
  EndWith
  
  d3 = d1
  While d3 >= 0
    nDevCount + 1
    d3 = grMaps\aDev(d3)\nNextDevIndex
  Wend
  
  g3 = g1
  While g3 >= 0
    nLiveGrpCount + 1
    g3 = grMaps\aLiveGrp(g3)\nNextLiveGrpIndex
  Wend
  
  debugMsg(sProcName, "nDevCount=" + nDevCount + ", nLiveGrpCount=" + nLiveGrpCount)
  
  If nDevCount > 0
    nReqdDevArraySize = grMaps\nMaxDevIndex + nDevCount
    If ArraySize(grMaps\aDev()) < nReqdDevArraySize
      REDIM_ARRAY(grMaps\aDev, nReqdDevArraySize, grDevMapDevDef, "grMaps\aDev()")
    EndIf
    d2 = grMaps\nMaxDevIndex + 1
    grMaps\aMap(nNewDevMapPtr)\nFirstDevIndex = d2
    While d1 >= 0
      grMaps\aDev(d2) = grMaps\aDev(d1)
      If grMaps\aDev(d2)\nDevType = #SCS_DEVTYPE_LIVE_INPUT
        ; Live Inputs not available under BASS ASIO so set these devices to dummy
        grMaps\aDev(d2)\bDummy = #True
        grMaps\aDev(d2)\nFirst0BasedInputChan = 0
        grMaps\aDev(d2)\nFirst1BasedInputChan = 1
        grMaps\aDev(d2)\s1BasedInputRange = "1"
        grMaps\aDev(d2)\nPhysicalDevPtr = -1
        grMaps\aDev(d2)\sPhysicalDev = Lang("Misc", "DummyLiveInput")
      EndIf
      d1 = grMaps\aDev(d1)\nNextDevIndex
      If d1 >= 0
        grMaps\aDev(d2)\nNextDevIndex = d2 + 1
      EndIf
      d2 + 1
    Wend
    grMaps\nMaxDevIndex = d2 - 1
  EndIf
  
  If nLiveGrpCount > 0
    nReqdLiveGrpArraySize = grMaps\nMaxLiveGrpIndex + nLiveGrpCount
    If ArraySize(grMaps\aLiveGrp()) < nReqdLiveGrpArraySize
      REDIM_ARRAY(grMaps\aLiveGrp, nReqdLiveGrpArraySize, grLiveGrpDef, "grMaps\aLiveGrp()")
    EndIf
    g2 = grMaps\nMaxLiveGrpIndex + 1
    grMaps\aMap(nNewDevMapPtr)\nFirstLiveGrpIndex = g2
    While g1 >= 0
      grMaps\aLiveGrp(g2) = grMaps\aLiveGrp(g1)
      g1 = grMaps\aLiveGrp(g1)\nNextLiveGrpIndex
      If g1 >= 0
        grMaps\aLiveGrp(g2)\nNextLiveGrpIndex = g2 + 1
      EndIf
      g2 + 1
    Wend
    grMaps\nMaxLiveGrpIndex = g2 - 1
  EndIf
  
  grMaps\sSelectedDevMapName = grMaps\aMap(nNewDevMapPtr)\sDevMapName
  
  debugMsg(sProcName, "calling listAllDevMaps()")
  listAllDevMaps()
  
  debugMsg0(sProcName, "Changing grProd\sSelectedDevMapName from " + #DQUOTE$ + grProd\sSelectedDevMapName + #DQUOTE$ + " to " + #DQUOTE$ + grMaps\sSelectedDevMapName + #DQUOTE$)
  grProd\sSelectedDevMapName = grMaps\sSelectedDevMapName
  debugMsg(sProcName, "calling writeXMLDevMapFile(" + #DQUOTE$ + grProd\sSelectedDevMapName + #DQUOTE$ + ", " + grProd\sProdId + ", #True)")
  writeXMLDevMapFile(grProd\sSelectedDevMapName, grProd\sProdId)
  
  debugMsg(sProcName, #SCS_END + ", returning nNewDevMapPtr=" + nNewDevMapPtr)
  ProcedureReturn nNewDevMapPtr
  
EndProcedure

; EOF