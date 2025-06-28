; File: fmFileOpener.pbi

; See also AudFileRequester.pbi

; AudFileRequester handles file opens using the Windows Open File dialog, eg using the PB OpenFileRequester function,
; but fmFileOpener handles audio file opens using the 'SCS Open Audio File Dialog', which includes facilities to preview the file.
; Although the 'SCS Open Audio File Dialog' is more versatile, it's not very efficient so is not the default setting under 'Editing Options'.

EnableExplicit

#TVGN_LASTVISIBLE = 10

Procedure WFO_AddItem(gadget.l, text.s)
  Protected hRoot
  Protected lpis.TV_INSERTSTRUCT
  
  hRoot = SendMessage_(GadgetID(gadget), #TVM_GETNEXTITEM, #TVGN_LASTVISIBLE, 0)
  lpis\hParent = SendMessage_(GadgetID(gadget), #TVM_GETNEXTITEM, #TVGN_PARENT, hRoot)
  lpis\hInsertAfter = hRoot
  lpis\item\mask =  #TVIF_TEXT
  lpis\item\cchTextMax = Len(text)
  lpis\item\pszText = @text
  lpis\hParent = SendMessage_(GadgetID(gadget), #TVM_INSERTITEM, 0, @lpis)
EndProcedure

Procedure WFO_Form_Unload(nFileOpenerAction)
  PROCNAMEC()
  
  stopPreview()
  
  updateGridInfoFromPhysicalLayout(@grWFO\rExpListInfo)
  getFormPosition(#WFO, @grFileOpenerWindow, #True)
  unsetWindowModal(#WFO, nFileOpenerAction)
  HideWindow(#WFO, #True) ; nb hide, don't close
  If IsWindow(#WED)
    SAW(#WED)
  EndIf
  
EndProcedure

Procedure WFO_setExpListText()
  PROCNAMEC()
  Protected sFileTypes.s, sFileTypes2.s, sDirectory.s
  
  Select grWFO\sType
    Case "AddQF", "AddSF", "AddQP", "AddSP", "AudioFile", "AudioFileMulti"
      sFileTypes = gsAudioFileTypes
  EndSelect
  If sFileTypes
    sFileTypes2 = "*." + ReplaceString(sFileTypes, ",", ";*.")
  EndIf
  sDirectory = grWFO\sFolder + sFileTypes2
  debugMsg(sProcName, "sDirectory=" + sDirectory)
  SGT(WFO\expListMulti, sDirectory)
  SGT(WFO\expListSingle, sDirectory)
  
EndProcedure

Procedure WFO_populateForm()
  PROCNAMEC()
  Protected d, nListIndex
  Protected nLeft
  Protected sDev.s
  Static bOwnLibrariesAdded
  
  ;INFO -- about files added twice
  ; Some audio files may appear twice in the explorer list.
  ; The file pattern used is dynamically built, but typically will be "*.wav;*.mp3;*.wma;*.aac;*.m4a;*.ogg;*.aif;*.aiff;*.flac;*.fla;*.oga".
  ; On searching the PB Forum for the reason for files being listed twice, I came across the topic "[PB 5.61-64x] ExplorerListGadget duplicate files listing" - https://www.purebasic.fr/english/viewtopic.php?f=4&t=69563
  ; This included replies from Freak and Fred. Freak's reply: "I think that is a Windows "feature": The DOS name of the file "test.1234" is "test.123" this is why it matches both filterpatterns."
  ; In our pattern we have "*.aif;*.aiff;" and "*.flac;*.fla;". so any file with an extension of .aiff or .flac will appear twice in the list. Seems to be nothing we can do about that.
  
  debugMsg(sProcName, #SCS_START)
  
  With WFO
    SGT(\expTree, grWFO\sFolder)
    
    ; Reason for the following code:
    ; The PB ExplorerTreeGadget does not (as at PB 5.46) include the Music library, which is very likely to be a requirement as this module is used for opening audio files.
    ; Using the ExplorerTreeGadget as-is, users would have to navigate through the tree, eg to C:\Users\ then to C:\Users\Mike\, and utimately to C:\Users\Mike\Music\.
    ; I therefore posted this topic to the PB Windows Forum: "Add libraries (eg Music) to ExplorerTreeGadget?" - see https://www.purebasic.fr/english/viewtopic.php?f=5&t=70778
    ; Forum user RASHAD provided some useful assistance, but as noted in the topic, no additional code was able to successfully add the Music library plus all it's sub-directories
    ; to the ExplorerTreeGadget.
    ; The most satisfactory solution was to let the Music library by added to the end of the list and be treated by SCS as a shortcut, and that is what the following code, plus
    ; the code in WFO_expTree_Change() achieves.
    ; btw, although ExplorerTreeGadget does correctly handle the Documents library, it was decided to omit Documents from the initial ExplorerTreeGadget and to add it in the
    ; same way as addding the Music library, so that these two libraries are displayed in the same way.
    ; The Pictures and Videos libaries have not been included here as these libraries are not expected to be require for adding an Audio file.
    If bOwnLibrariesAdded = #False
      SetWindowLongPtr_(GadgetID(\expTree), #GWL_STYLE, GetWindowLongPtr_(GadgetID(\expTree), #GWL_STYLE) | #TVS_CHECKBOXES|#TVS_TRACKSELECT)
      If OSVersion() >= #PB_OS_Windows_7
        WFO_AddItem(\expTree, gsMyDocsPath)
        If grWFO\sMyMusicPath
          WFO_AddItem(\expTree, grWFO\sMyMusicPath)
        EndIf
        ; WFO_AddItem(\expTree, "C:\Users\Mike\Pictures")
        ; WFO_AddItem(\expTree, "C:\Users\Mike\Videos")
      EndIf
      bOwnLibrariesAdded = #True
    EndIf
    ; End of code added for own libraries - but see also WFO_expTree_Change()
    
    WFO_setExpListText()
    WFO_populateOwnCols()
    If grWFO\nSplitterPos <= 0
      grWFO\nSplitterPos = GadgetWidth(\splOpenerV) / 3
    EndIf
    SGS(\splOpenerV, grWFO\nSplitterPos)
    nLeft = GadgetX(\splOpenerV) + GGS(\splOpenerV) + gnVSplitterSeparatorWidth + (GadgetX(\lblFolders) - GadgetX(\splOpenerV) + GadgetX(\expTree))
    ResizeGadget(\lblFiles, nLeft, #PB_Ignore, #PB_Ignore, #PB_Ignore)
    
    ; add devices to the combo box
    ClearGadgetItems(\cboDevice)
    nListIndex = 0
    For d = 0 To grProd\nMaxAudioLogicalDev ; grLicInfo\nMaxAudDevPerProd
      sDev = Trim(grProd\aAudioLogicalDevs(d)\sLogicalDev)
      If sDev
        AddGadgetItem(\cboDevice, -1, sDev)
        If sDev = grProd\sPreviewDevice
          nListIndex = d
        EndIf
      EndIf
    Next d
    If CountGadgetItems(\cboDevice) > 0
      SGS(\cboDevice, nListIndex)
    EndIf
    
    ; set the level trackbar
    SLD_setLevel(\sldLevel, grProd\fPreviewBVLevel)

  EndWith
  
EndProcedure

Procedure WFO_Form_Show(bModal, nReturnFunction, sType.s, bAllowMultiSelect)
  PROCNAMEC()
  
  debugMsg(sProcName, #SCS_START + ", sType=" + sType + ", bAllowMultiSelect=" + strB(bAllowMultiSelect))
  
  With grWFO
    \sType = sType
    \sOwnLastFolder = ""
    \nOwnLastExpListGadget = 0
    
    \tvi\mask = #TVIF_TEXT
    \sBuffer = Space(#MAX_PATH)
    \tvi\pszText = @\sBuffer
    \tvi\cchTextMax = #MAX_PATH
    \sMyMusicPath = GetUserDirectory(#PB_Directory_Musics)
    
    If IsWindow(#WFO) = #False
      createfmFileOpener()
      WFO_setupExpListDefaults()
      WFO_setupExpList(WFO\expListMulti)
      WFO_setupExpList(WFO\expListSingle)
    EndIf
    
    If bAllowMultiSelect
      \nExpListGadgetNo = WFO\expListMulti
      If getVisible(WFO\expListSingle)
        setVisible(WFO\expListSingle, #False)
      EndIf
    Else
      \nExpListGadgetNo = WFO\expListSingle
      If getVisible(WFO\expListMulti)
        setVisible(WFO\expListMulti, #False)
      EndIf
    EndIf
    setVisible(\nExpListGadgetNo, #True)
    SetGadgetAttribute(WFO\splOpenerV, #PB_Splitter_SecondGadget, \nExpListGadgetNo)
    
    ; nb grWFO\sfolder may have been preset in readXMLCueFile() when processing "/AUDIOFILE"
    If Len(\sFolder) = 0
      \sFolder = grGeneralOptions\sInitDir
    EndIf
    
    SetWindowTitle(#WFO, Lang("Requesters", sType))
    setFormPosition(#WFO, @grFileOpenerWindow)
    WFO_Form_Resized(#True)
    setWindowModal(#WFO, bModal, nReturnFunction)
    WFO_populateForm()
    setWindowVisible(#WFO, #True)
    SAW(#WFO)
  EndWith
  
  debugMsg(sProcName, #SCS_END)
  ProcedureReturn #True
  
EndProcedure

Procedure WFO_updatePreviewProgressTrackbar(bForceUpdate=#False)
  PROCNAMEC()
  Protected qChannelBytePosition.q
  Protected dValue.d
  Protected nValue, nCurrentValue
  Protected bUpdateProgressTrackbar
  Protected nTrackTime
  
  ; nb MUST be called from the main thread as it updates the 'position' (or 'progress') trackbar gadget
  ASSERT_THREAD(#SCS_THREAD_MAIN)
  
  ; debugMsg(sProcName, #SCS_START)
  
  With grWFO
    If gbUseBASS  ; BASS
      If grPreview\nPreviewChannel <> 0
        If \bProgressManual = #False
          If gbPreviewPlaying
            qChannelBytePosition = BASS_ChannelGetPosition(grPreview\nPreviewChannel, #BASS_POS_BYTE)
            ; Added 25Nov2022 11.9.7am
            If qChannelBytePosition = -1
              debugMsg(sProcName, "BASS_ChannelGetPosition(" + decodeHandle(grPreview\nPreviewChannel) + ", BASS_POS_BYTE) returned " + qChannelBytePosition)
              debugMsg(sProcName, "Error " + BASS_ErrorGetCode() + ": " + getBassErrorDesc(BASS_ErrorGetCode()))
              qChannelBytePosition = 0
            EndIf
            ; End added 25Nov2022 11.9.7am
            dValue = (qChannelBytePosition / grPreview\qPreviewLengthInBytes) * \nPosSliderMax
            nValue = dValue
            bUpdateProgressTrackbar = #True
          EndIf
        EndIf
      EndIf
      
    Else  ; SM-S
      If grPreview\sPPrimaryChan
        If \bProgressManual = #False
          If gbPreviewPlaying
            nTrackTime = getSMSTrackTimeInMS(grPreview\sPPrimaryChan)
            dValue = (nTrackTime / grPreview\nPreviewTrackLengthInMS) * \nPosSliderMax
            nValue = dValue
            bUpdateProgressTrackbar = #True
          EndIf
        EndIf
      EndIf
    EndIf
    
    ; debugMsg(sProcName, "bUpdateProgressTrackbar=" + strB(bUpdateProgressTrackbar) + ", bForceUpdate=" + strB(bForceUpdate) + ", nValue=" + nValue)
    If bUpdateProgressTrackbar Or bForceUpdate
      If nValue < 0
        nValue = 0
      EndIf
      If nValue > \nPosSliderMax
        nValue = \nPosSliderMax
      EndIf
      nCurrentValue = SLD_getValue(WFO\sldPosition)
      If nValue <> nCurrentValue
        SLD_setValue(WFO\sldPosition, nValue, #True)
      EndIf
    EndIf
  EndWith

  ; debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WFO_previewStarted()
  PROCNAMEC()
  
  gbPreviewPlaying = #True
  gbPreviewEnded = #False
  debugMsg(sProcName, "gbPreviewPlaying=" + strB(gbPreviewPlaying))
  WFO_setPreviewEnabledStates()
EndProcedure

Procedure WFO_previewEnded()
  PROCNAMEC()
  
  debugMsg(sProcName, #SCS_START)
  
  gbPreviewPlaying = #False
  debugMsg(sProcName, "gbPreviewPlaying=" + strB(gbPreviewPlaying))
  WFO_updatePreviewProgressTrackbar(#True)
  WFO_setPreviewEnabledStates()
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WFO_endSyncPreview(Handle.l, channel.l, nData, user)
  PROCNAME("WFO_endSyncPreview handle=" + decodeHandle(Handle) + ", channel=" + decodeHandle(channel) + ", user=" + user)

  ;========================================
  ; no system calls in callback procedures!
  ;========================================

  ; samAddRequest(#SCS_SAM_PREVIEW_ENDED)
  gbPreviewEnded = #True
  
  debugMsg(sProcName, #SCS_END)

EndProcedure

Procedure WFO_setPreviewEnabledStates()
  PROCNAMEC()
  Protected nReturn
  
  debugMsg(sProcName, #SCS_START)
  
  With grWFO
    
    If Len(\sFullPathName) = 0 Or \bLastFilePlayable = #False
      ; no file selected, or unsupported file format (eg MIDI)
      \bPlayEnabled = #False
      \bStopEnabled = #False
      \bDeviceEnabled = #True
      \bLevelEnabled = #True
      \bProgressEnabled = #False
      
    ElseIf gbPreviewPlaying = #False
      ; preview not playing
      \bPlayEnabled = #True
      \bStopEnabled = #False
      \bDeviceEnabled = #True
      \bLevelEnabled = #True
      \bProgressEnabled = #True
      
    Else
      ; preview is playing
      \bPlayEnabled = #False
      \bStopEnabled = #True
      \bDeviceEnabled = #False
      \bLevelEnabled = #True
      \bProgressEnabled = #True
    EndIf
    
    debugMsg(sProcName, "\bPlayEnabled=" + strB(\bPlayEnabled) + ", \bStopEnabled=" + strB(\bStopEnabled))
    
    setEnabled(WFO\btnPlay, \bPlayEnabled)
    setEnabled(WFO\btnStop, \bStopEnabled)
    setEnabled(WFO\cboDevice, \bDeviceEnabled)
    SLD_setEnabled(WFO\sldLevel, \bLevelEnabled)
    SLD_setEnabled(WFO\sldPosition, \bProgressEnabled)
    
  EndWith
  
EndProcedure

Procedure WFO_setPreviewPosAtTrackbarPos()
  PROCNAMEC()
  Protected nPosition, nBassResult.l, nErrorCode.l
  Protected qBytePosition.q
  Protected dBytePosition.d
  Protected fTimePos.f
  Protected sStatus.s
  Protected sTrackStatus.s
  
  debugMsg(sProcName, #SCS_START)
  
  With grPreview
    
    grWFO\bProgressManual = #True  ; stops trackbar being updated by actual position
    
    Select gnCurrAudioDriver
      Case #SCS_DRV_BASS_DS, #SCS_DRV_BASS_WASAPI, #SCS_DRV_BASS_ASIO ; BASS_DS, BASS_WASAPI, BASS_ASIO
        If \nPreviewChannel <> 0
          nPosition = SLD_getValue(WFO\sldPosition)
          dBytePosition = \qPreviewLengthInBytes * (nPosition / grWFO\nPosSliderMax)
          qBytePosition = dBytePosition
          If qBytePosition > \qPreviewLengthInBytes
            qBytePosition = \qPreviewLengthInBytes
          EndIf
          nBassResult = BASS_ChannelSetPosition(\nPreviewChannel, qBytePosition, #BASS_POS_BYTE)
          debugMsg2(sProcName, "BASS_ChannelSetPosition(" + \nPreviewChannel + ", " + qBytePosition + ", BASS_POS_BYTE)", nBassResult)
          If nBassResult = #BASSFALSE
            nErrorCode = BASS_ErrorGetCode()
            ; debugMsg3(sProcName, "Error " + Str(nErrorCode) + ": " + getBassErrorDesc(nErrorCode))
            If nErrorCode = #BASS_ERROR_POSITION
              If gbPreviewPlaying
                debugMsg(sProcName, "calling stopPreview()")
                stopPreview()
              EndIf
            EndIf
          EndIf
        EndIf
        
      Case #SCS_DRV_SMS_ASIO ; SM-S
        nPosition = SLD_getValue(WFO\sldPosition)
        If \sPPrimaryChan
          If nPosition = 0
            sendSMSCommand("set chan " + \sPChanList + " track start clear")
          Else
            fTimePos = \nPreviewTrackLengthInMS * (nPosition / grWFO\nPosSliderMax)
            sendSMSCommand("set chan " + \sPChanList + " track start time " + makeSMSTimeString(fTimePos))
          EndIf
          sTrackStatus = getSMSTrackStatus(grPreview\sPPrimaryChan)
          debugMsg(sProcName, "sTrackStatus=" + sTrackStatus)
          If sTrackStatus = "play"
            sendSMSCommand("stop " + \sPChanList)
            sendSMSCommand("play " + \sPChanList)
          EndIf
        EndIf
        
    EndSelect
    
    grWFO\bProgressManual = #False  ; re-starts trackbar being updated by actual position
    
  EndWith
EndProcedure

Procedure WFO_setPreviewPosAtParamPos(nPosition)
  PROCNAMEC()
  Protected qBytePosition.q, nBassResult.l, nErrorCode.l
  Protected fTimePos.f
  
  debugMsg(sProcName, #SCS_START)
  
  With grPreview
    
    If (nPosition >= 0) And (nPosition <= grWFO\nPosSliderMax)
      SLD_setValue(WFO\sldPosition, nPosition, #True)
    EndIf
    
    If gbUseBASS  ; BASS
      If \nPreviewChannel <> 0
        qBytePosition = nPosition / #SCS_TB_PROGRESS_MAX * \qPreviewLengthInBytes
        If qBytePosition > \qPreviewLengthInBytes
          qBytePosition = \qPreviewLengthInBytes
        EndIf
        nBassResult = BASS_ChannelSetPosition(\nPreviewChannel, qBytePosition, #BASS_POS_BYTE)
        debugMsg2(sProcName, "BASS_ChannelSetPosition(" + \nPreviewChannel + ", " + qBytePosition + ", BASS_POS_BYTE)", nBassResult)
        If nBassResult = #BASSFALSE
          nErrorCode = BASS_ErrorGetCode()
          ; debugMsg3(sProcName, "Error " + nErrorCode + ": " + getBassErrorDesc(nErrorCode))
          If nErrorCode = #BASS_ERROR_POSITION
            If gbPreviewPlaying
              debugMsg(sProcName, "calling stopPreview()")
              stopPreview()
            EndIf
          EndIf
        EndIf
      EndIf
      
    Else  ; SM-S
      If \sPPrimaryChan
        If nPosition = 0
          sendSMSCommand("set chan " + \sPChanList + " track start clear")
        Else
          fTimePos = nPosition / #SCS_TB_PROGRESS_MAX * \nPreviewTrackLengthInMS
          sendSMSCommand("set chan " + \sPChanList + " track start time " + StrF(fTimePos,3))
        EndIf
        If getSMSTrackStatus(\sPPrimaryChan) = "play"
          sendSMSCommand("stop " + \sPChanList)
          sendSMSCommand("play " + \sPChanList)
        EndIf
      EndIf
      
    EndIf
  EndWith
EndProcedure

Procedure WFO_fcFile()
  PROCNAMEC()
  Protected sText.s, nFileDuration, sFileInfo.s, sFileTitle.s, sFileExt.s
  Static sPreview.s
  Static bStaticLoaded
  
  If bStaticLoaded = #False
    sPreview = Lang("WFO", "lblPreview")
    bStaticLoaded = #True
  EndIf
  
  With grWFO
    If (\sFolder) And (\sFile)
      \sFullPathName = \sFolder + \sFile
      debugMsg(sProcName, "grWFO\sFullPathName=" + #DQUOTE$ + \sFullPathName + #DQUOTE$)
      
      debugMsg(sProcName, "calling WFO_stopPreview()")
      stopPreview()
      WFO_setPreviewPosAtParamPos(#SCS_TB_PROGRESS_MIN)
      
      sText = sPreview
      sFileTitle = ""
      If \sFullPathName
        sFileExt = LCase(GetExtensionPart(\sFullPathName))
        If sFileExt
          If FindString(gsAudioFileTypes, sFileExt) > 0
            If FileExists(\sFullPathName)
              sText = RTrim(sPreview + ": " + \sFile)
              \bLastFilePlayable = getInfoAboutFile(\sFullPathName)
              If \bLastFilePlayable
                nFileDuration = grInfoAboutFile\nFileDuration
                sFileInfo = grInfoAboutFile\sFileInfo
                sFileTitle = grInfoAboutFile\sFileTitle
                sText + " (" + timeToString(nFileDuration) + ", " + sFileInfo + ")"
                If nFileDuration > 0
                  \nPosSliderMax = nFileDuration - 1
                EndIf
              EndIf
            EndIf
          EndIf
        EndIf
      EndIf
      SGT(WFO\lblPreview, sText)
      setGadgetWidth(WFO\lblPreview)
      SGT(WFO\lblTitle, sFileTitle)
      setGadgetWidth(WFO\lblTitle)
      SLD_setMax(WFO\sldPosition, \nPosSliderMax)
      WFO_setPreviewEnabledStates()
    EndIf
  EndWith
  
EndProcedure

Procedure WFO_btnOpen_Click()
  PROCNAMEC()
  Protected n, n2, nState
  
  With grWFO
    ; build array gsSelectedFile
    gsSelectedDirectory = \sFolder
    debugMsg(sProcName, "gsSelectedDirectory=" + gsSelectedDirectory)
    gnSelectedFileCount = 0
    For n = 0 To CountGadgetItems(\nExpListGadgetNo)-1
      nState = GetGadgetItemState(\nExpListGadgetNo, n)
      If (nState & #PB_Explorer_Selected) And (nState & #PB_Explorer_File)
        gnSelectedFileCount + 1
      EndIf
    Next n
    n2 = -1
    If gnSelectedFileCount > 0
      ReDim gsSelectedFile(gnSelectedFileCount-1)
      For n = 0 To CountGadgetItems(\nExpListGadgetNo)-1
        nState = GetGadgetItemState(\nExpListGadgetNo, n)
        If (nState & #PB_Explorer_Selected) And (nState & #PB_Explorer_File)
          n2 + 1
          gsSelectedFile(n2) = GetGadgetItemText(\nExpListGadgetNo, n)
        EndIf
      Next n
    EndIf
  EndWith
  
  WFO_Form_Unload(#PB_MessageRequester_Ok)
  
EndProcedure

Procedure WFO_btnPlay_Click()
  PROCNAMEC()
  
  If getEnabled(WFO\btnPlay)
    debugMsg(sProcName, "calling playPreview(" + GetFilePart(grWFO\sFullPathName))
    playPreview(grWFO\sFullPathName)
  EndIf
EndProcedure

Procedure WFO_btnStop_Click()
  PROCNAMEC()
  
  If getEnabled(WFO\btnStop)
    debugMsg(sProcName, "calling stopPreview()")
    stopPreview()
    ; set progress bar position back to start
    SLD_setValue(WFO\sldPosition, 0, #True)
  EndIf
EndProcedure

Procedure WFO_cboDevice_Click()
  Protected sDevice.s
  
  sDevice = GetGadgetText(WFO\cboDevice)
  If sDevice
    grProd\sPreviewDevice = sDevice
  EndIf

EndProcedure

Procedure WFO_populateOwnCols()
  PROCNAMEC()
  Protected bDoPopulate
  Protected n, nState
  Protected sThisFile.s, sFullPathName.s
  Protected qStartTime.q, qEndTime.q, nFileCount
  Protected nLengthCol, nTitleCol
  
  ; debugMsg(sProcName, #SCS_START)
  
  qStartTime = ElapsedMilliseconds()
  
  With grWFO
    If (\sFolder <> \sOwnLastFolder) Or (\nExpListGadgetNo <> \nOwnLastExpListGadget)
      bDoPopulate = #True
    EndIf
    ; debugMsg(sProcName, "bDoPopulate=" + strB(bDoPopulate))
    If bDoPopulate
      \sOwnLastFolder = \sFolder
      \nOwnLastExpListGadget = \nExpListGadgetNo
      nLengthCol = grWFO\rExpListInfo\aCol(#SCS_WFOLIST_LN)\nCurColNo
      nTitleCol = grWFO\rExpListInfo\aCol(#SCS_WFOLIST_TI)\nCurColNo
      ; debugMsg(sProcName, "nLengthCol=" + nLengthCol + ", nTitleCol=" + nTitleCol)
      If (nLengthCol >= 0) Or (nTitleCol >= 0)
        For n = 0 To CountGadgetItems(\nExpListGadgetNo)-1
          nState = GetGadgetItemState(\nExpListGadgetNo, n)
          If nState & #PB_Explorer_File
            nFileCount + 1
            sThisFile = GetGadgetItemText(\nExpListGadgetNo, n)
            sFullPathName = \sFolder + sThisFile
            If getInfoAboutFile(sFullPathName, #False)
              ; debugMsg(sProcName, "sThisFile=" + sThisFile + ", \nFileDuration=" + grInfoAboutFile\nFileDuration + ", \sFileTitle=" + grInfoAboutFile\sFileTitle)
              If nLengthCol >= 0
                SetGadgetItemText(\nExpListGadgetNo, n, timeToStringHHMMSS(grInfoAboutFile\nFileDuration), nLengthCol)
              EndIf
              If nTitleCol >= 0
                SetGadgetItemText(\nExpListGadgetNo, n, grInfoAboutFile\sFileTitle, nTitleCol)
              EndIf
            Else
              If grInfoAboutFile\sErrorMsg
                If nTitleCol >= 0
                  SetGadgetItemText(\nExpListGadgetNo, n, "(" + Trim(grInfoAboutFile\sErrorMsg) + ")", nTitleCol)
                EndIf
              EndIf
            EndIf
          EndIf
          debugMsg(sProcName, "GetGadgetItemText(\nExpListGadgetNo, " + n + ", " + nTitleCol + ")=" + GetGadgetItemText(\nExpListGadgetNo, n, nTitleCol))
        Next n
      EndIf
    EndIf
  EndWith
  
  qEndTime = ElapsedMilliseconds()
  ; debugMsg(sProcName, #SCS_END + ", time=" + Str(qEndTime - qStartTime) + ", nFileCount=" + nFileCount)
  
EndProcedure

Procedure WFO_expList_Change()
  ; PROCNAMEC()
  Protected n, nState
  
  ; debugMsg(sProcName, #SCS_START)
  
  With grWFO
    \sFolder = GGT(\nExpListGadgetNo)
    ; debugMsg(sProcName, "grWFO\sFolder=" + #DQUOTE$ + \sFolder + #DQUOTE$)
    \sFile = ""
    For n = 0 To CountGadgetItems(\nExpListGadgetNo)-1
      nState = GetGadgetItemState(\nExpListGadgetNo, n)
      If nState & #PB_Explorer_File
        If nState & #PB_Explorer_Selected
          \sFile = GetGadgetItemText(\nExpListGadgetNo, n)
        EndIf
      EndIf
    Next n
    WFO_populateOwnCols()
    SGT(WFO\txtFileName, \sFile)
    WFO_fcFile()
  EndWith
  
  ; debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WFO_expTree_Change()
  ; PROCNAMEC()
  Protected sDirName.s
  
  ; debugMsg(sProcName, #SCS_START)
  
  ; IMPORTANT: see the comments in WFO_populateForm() regarding the shortcuts for own libaries (Documents and Music)
  
  With grWFO
    sDirName = GGT(WFO\expTree)
    ; Debug sDirName
    ; Debug "FileSize(sDirName)=" + FileSize(sDirName)
    Select FileSize(sDirName)
      Case -2
        ; the selected item is an ExplorerTreeGadget directory
        \sFolder = sDirName
        ; debugMsg(sProcName, "grWFO\sFolder=" + #DQUOTE$ + \sFolder + #DQUOTE$)
        setMouseCursorBusy()
        WFO_setExpListText()
        WFO_populateOwnCols()
        setMouseCursorNormal()
      Case -1
        ; a FileSize() of -1 means 'file not found', and in this context this must therefore be an 'own library' shortcut, so get
        ; the text of this shortcut and use SetGadgetText() to set this as the current item in the main part of the ExplorerTreeGadget
        \tvi\hItem = SendMessage_(GadgetID(WFO\expTree), #TVM_GETNEXTITEM, #TVGN_CARET, 0)
        SendMessage_(GadgetID(WFO\expTree), #TVM_GETITEM, 0, \tvi)
        ; Debug \sBuffer
        SetGadgetText(WFO\expTree, \sBuffer + "\")
        ProcedureReturn
    EndSelect
  EndWith
  
  ; debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WFO_sldLevel_Common()
  PROCNAMEC()
  Protected fBVLevel.f, nBassResult.l
  Protected sSMSCommand.s
  
  With WFO
    fBVLevel = SLD_getLevel(\sldLevel)
    If fBVLevel <= grLevels\fMinBVLevel
      fBVLevel = #SCS_MINVOLUME_SINGLE
    ElseIf fBVLevel > grLevels\fMaxBVLevel
      fBVLevel = grLevels\fMaxBVLevel
    EndIf
    grProd\fPreviewBVLevel = fBVLevel
    If gbPreviewPlaying
      If gbUseBASS  ; BASS
        nBassResult = BASS_ChannelSetAttribute(grPreview\nPreviewChannel, #BASS_ATTRIB_VOL, fBVLevel)
      Else  ; SM-S
        sSMSCommand = "set chan " + grPreview\sPXChanList + " gain " + makeSMSGainString(fBVLevel)
        samAddRequest(#SCS_SAM_SPECIFIC_SMS_COMMAND, #SCS_SAM_SMS_PREVIEW_LEVEL, 0, 0, sSMSCommand)
      EndIf
    EndIf
  EndWith
  
EndProcedure

Procedure WFO_splOpenerV_Event()
  PROCNAMEC()
  Protected nLeft
  
  With WFO
    grWFO\nSplitterPos = GGS(WFO\splOpenerV)
    If grWFO\nSplitterPos <= 0
      grWFO\nSplitterPos = GadgetWidth(\splOpenerV) / 3
    EndIf
    SGS(\splOpenerV, grWFO\nSplitterPos)
    nLeft = GadgetX(\splOpenerV) + GGS(\splOpenerV) + gnVSplitterSeparatorWidth + (GadgetX(\lblFolders) - GadgetX(\splOpenerV) + GadgetX(\expTree))
    ResizeGadget(\lblFiles, nLeft, #PB_Ignore, #PB_Ignore, #PB_Ignore)
  EndWith

EndProcedure

Procedure WFO_Form_Resized(bForceProcessing=#False)
  PROCNAMEC()
  Protected nWindowWidth, nWindowHeight
  Static nPrevWindowWidth, nPrevWindowHeight
  Protected nLeft, nTop, nWidth, nHeight
  
  If IsWindow(#WFO) = #False
    ; appears this procedure can be called after the window has been closed
    ProcedureReturn
  EndIf
  
  With WFO
    nWindowWidth = WindowWidth(#WFO)
    nWindowHeight = WindowHeight(#WFO)
    If (nWindowWidth <> nPrevWindowWidth) Or (nWindowHeight <> nPrevWindowHeight) Or (bForceProcessing)
      nPrevWindowWidth = nWindowWidth
      nPrevWindowHeight = nWindowHeight
      ; resize \splOpenerV
      nLeft = GadgetX(\splOpenerV)
      nWidth = nWindowWidth - (nLeft << 1)
      nTop = GadgetY(\splOpenerV)
      nHeight = nWindowHeight - nTop - GadgetHeight(\cntSouth)
      ResizeGadget(\splOpenerV, #PB_Ignore, #PB_Ignore, nWidth, nHeight)
      ; reposition \cntSouth
      nTop = nWindowHeight - GadgetHeight(\cntSouth)
      ResizeGadget(\cntSouth, #PB_Ignore, nTop, #PB_Ignore, #PB_Ignore)
    EndIf
  EndWith
  
EndProcedure

Procedure WFO_EventHandler()
  PROCNAMEC()
  Protected sMsg.s
  
  With WFO
    Select gnWindowEvent
        
      Case #PB_Event_CloseWindow
        WFO_Form_Unload(#PB_MessageRequester_Cancel)   ; user clicking the 'X' close window icon is equivalent to clicking the 'Cancel' button
        
      Case #PB_Event_SizeWindow
        WFO_Form_Resized()
        
      Case #PB_Event_Menu
        gnEventMenu = EventMenu()
        Select gnEventMenu
            
          Case #SCS_mnuKeyboardReturn   ; Return
            If getEnabled(\btnOpen)
              WFO_btnOpen_Click()
            EndIf
            
          Case #SCS_mnuKeyboardEscape   ; Escape
            If getEnabled(\btnCancel)
              WFO_Form_Unload(#PB_MessageRequester_Cancel)   ; #PB_MessageRequester_Cancel indicates 'Cancel' button pressed
            EndIf
            
        EndSelect
        
      Case #PB_Event_Gadget
        If gnEventSliderNo > 0
          Select gnEventSliderNo
            Case \sldLevel
              Select gnSliderEvent
                Case #SCS_SLD_EVENT_MOUSE_DOWN, #SCS_SLD_EVENT_SCROLL, #SCS_SLD_EVENT_MOUSE_UP
                  WFO_sldLevel_Common()
                Default
                  ; ignore other slider events
              EndSelect
            Case \sldPosition
              Select gnSliderEvent
                Case #SCS_SLD_EVENT_MOUSE_DOWN, #SCS_SLD_EVENT_SCROLL, #SCS_SLD_EVENT_MOUSE_UP
                  WFO_setPreviewPosAtTrackbarPos()
                Default
                  ; ignore other slider events
              EndSelect
              ProcedureReturn
          EndSelect
        EndIf
        
        Select gnEventGadgetNoForEvHdlr
            
          Case \btnCancel
            WFO_Form_Unload(#PB_MessageRequester_Cancel)   ; #PB_MessageRequester_Cancel indicates 'Cancel' button pressed
            
          Case \btnOpen
            WFO_btnOpen_Click()
            
          Case \btnPlay
            WFO_btnPlay_Click()
            
          Case \btnStop
            WFO_btnStop_Click()
            
          Case \cboDevice
            WFO_cboDevice_Click()
            
          Case \expListMulti, \expListSingle
            Select gnEventType
              Case #PB_EventType_Change
                WFO_expList_Change()
              Case #PB_EventType_LeftDoubleClick
                WFO_btnOpen_Click()
            EndSelect
                
          Case \expTree
            Select gnEventType
              Case #PB_EventType_Change
                WFO_expTree_Change()
            EndSelect
            
          Case \splOpenerV
            WFO_splOpenerV_Event()
            
          Default
            debugMsg(sProcName, "gnEventGadgetNo=G" + gnEventGadgetNo + ", gnEventType=" + decodeEventType())
        EndSelect
        
    EndSelect
  EndWith
  
EndProcedure

Procedure WFO_setupExpListDefaults()
  PROCNAMEC()
  Protected n, nColNo
  
  If StartDrawing(WindowOutput(#WFO))
    DrawingFont(GetGadgetFont(WFO\expListMulti))
    nColNo = -1
    
    With grWFO\rExpListInfo\aCol(#SCS_WFOLIST_NM) ; Name
      nColNo + 1
      \nDefColNo = nColNo
      \nDefWidth = TextWidth("xxxxxxxxxxxxxxxxxxxxxxxx.xxx")
      \sTitle = #PB_Explorer_Name
    EndWith
    
    With grWFO\rExpListInfo\aCol(#SCS_WFOLIST_TI) ; Title
      nColNo + 1
      \nDefColNo = nColNo
      \nDefWidth = TextWidth("xxxxxxxxxxxxxxxxxxxxxx")
      \sTitle = Lang("WQF", "Title")
    EndWith
    
    With grWFO\rExpListInfo\aCol(#SCS_WFOLIST_LN) ; Length
      nColNo + 1
      \nDefColNo = nColNo
      \nDefWidth = TextWidth("00:00:00x")
      \sTitle = Lang("Common", "Length")
    EndWith
    
    With grWFO\rExpListInfo\aCol(#SCS_WFOLIST_SZ) ; Size
      nColNo + 1
      \nDefColNo = nColNo
      \nDefWidth = TextWidth("1234 KBxx")
      \sTitle = #PB_Explorer_Size
    EndWith
    
    With grWFO\rExpListInfo\aCol(#SCS_WFOLIST_TY) ; Type
      nColNo + 1
      \nDefColNo = nColNo
      \nDefWidth = TextWidth("WMA Filexx")
      \sTitle = #PB_Explorer_Type
    EndWith
    
    With grWFO\rExpListInfo\aCol(#SCS_WFOLIST_DM) ; Date Modified
      nColNo + 1
      \nDefColNo = nColNo
      \nDefWidth = TextWidth("2017/12/31 23:59:59xx")
      \sTitle = #PB_Explorer_Modified
    EndWith
    
    StopDrawing()
  EndIf
  
  For n = 0 To grWFO\rExpListInfo\nMaxColNo
    With grWFO\rExpListInfo\aCol(n)
      \nCurWidth = \nDefWidth
      \nCurColNo = \nDefColNo
    EndWith
  Next n
  
  debugMsg(sProcName,"grWFO\rExpListInfo\sLayoutString=" + grWFO\rExpListInfo\sLayoutString)
  If grWFO\rExpListInfo\sLayoutString
    unpackGridLayoutString(@grWFO\rExpListInfo, #SCS_GT_EXPWFO)
  EndIf
  
  For n = 0 To grWFO\rExpListInfo\nMaxColNo
    With grWFO\rExpListInfo\aCol(n)
      \nIniWidth = \nCurWidth
      \nIniColNo = \nCurColNo
      If \nCurColNo >= 0
        \bColVisible = #True
      Else
        \bColVisible = #False
      EndIf
      \nCurColOrder = \nCurColNo
    EndWith
  Next n

EndProcedure

Procedure WFO_setupExpList(nExpListGadget)
  PROCNAMEC()
  Protected bExpListVisible
  Protected m, n
  Protected nMaxVisibleColNo
  Protected nPass, nExpList
  
  debugMsg(sProcName, #SCS_START)
  
  ; this procedure clears any existing columns in the list, and then adds the 'current' visible columns
  
  bExpListVisible = getVisible(nExpListGadget)
  setVisible(nExpListGadget, #False)
  
  ; remove existing columns
  removeAllGadgetColumns(nExpListGadget)
  
  nMaxVisibleColNo = -1
  
  For m = 0 To grWFO\rExpListInfo\nMaxColNo
    grWFO\rExpListInfo\aCol(m)\nCurColNo = grWFO\rExpListInfo\aCol(m)\nCurColOrder
  Next m
  
  ; add the visible columns that have an 'nCurColNo'
  For m = 0 To grWFO\rExpListInfo\nMaxColNo
    For n = 0 To grWFO\rExpListInfo\nMaxColNo
      If grWFO\rExpListInfo\aCol(n)\nCurColNo = m
        ; add a column, setting the column title and the column width
        debugMsg(sProcName, "calling AddGadgetColumn(nExpListGadget, "+ m + ", " + grWFO\rExpListInfo\aCol(n)\sTitle + ", " + Str(grWFO\rExpListInfo\aCol(n)\nCurWidth) + ")")
        AddGadgetColumn(nExpListGadget, m, grWFO\rExpListInfo\aCol(n)\sTitle, grWFO\rExpListInfo\aCol(n)\nCurWidth)
        nMaxVisibleColNo = m
        Break ; break n loop
      EndIf
    Next n
  Next m
  
  grWFO\rExpListInfo\nMaxVisibleColNo = nMaxVisibleColNo
  debugMsg(sProcName, "\nMaxColNo=" + Str(grWFO\rExpListInfo\nMaxColNo) + ", \nMaxVisibleColNo=" + Str(grWFO\rExpListInfo\nMaxVisibleColNo))
  
  setVisible(nExpListGadget, bExpListVisible)
  
EndProcedure

Procedure WFO_ModReturn(nFileOpenerAction)
  PROCNAMEC()
  Protected nFileCount
  Protected bQuit, bCreatePlaceHolder, sFileName.s
  Protected sMsgTitle.s, sMsgText.s, bAskAboutPlaceHolder
  Protected nResponse
  
  debugMsg(sProcName, #SCS_START)
  
  Select nFileOpenerAction
    Case #PB_MessageRequester_Ok
      debugMsg(sProcName, "nFileOpenerAction=Ok, gnSelectedFileCount=" + gnSelectedFileCount)
      nFileCount = gnSelectedFileCount
    Case #PB_MessageRequester_Cancel
      debugMsg(sProcName, "nFileOpenerAction=Cancel")
      gnSelectedFileCount = 0
  EndSelect
  
  If nFileCount = 0
    sMsgTitle = Lang("Requesters", grWFO\sType)
    Select grWFO\sType
      Case "AddQF", "AddSF"
        sMsgText = Lang("Requesters", "PlaceHolderF")
        bAskAboutPlaceHolder = #True
      Case "AddQP", "AddSP"
        sMsgText = Lang("Requesters", "PlaceHolderP")
        bAskAboutPlaceHolder = #True
    EndSelect
    If bAskAboutPlaceHolder
      nResponse = scsMessageRequester(sMsgTitle, sMsgText, #PB_MessageRequester_YesNo | #MB_ICONQUESTION)
      If nResponse = #PB_MessageRequester_Yes
        bCreatePlaceHolder = #True
      EndIf
    EndIf
    
  ElseIf nFileCount > 50
    If checkManyFilesOK(nFileCount) = #False
      bQuit = #True
    EndIf
    
  EndIf
  
  debugMsg(sProcName, "bQuit=" + strB(bQuit) + ", nFileCount=" + nFileCount + ", bCreatePlaceHolder=" + strB(bCreatePlaceHolder) + ", grWFO\sType=" + grWFO\sType)
  If bQuit = #False
    If (nFileCount > 0) Or (bCreatePlaceHolder)
      Select grWFO\sType
        Case "AddQF"
          WED_importAudioFiles(#SCS_IMPORT_AUDIO_CUES, Lang("WED", "FavAddQF"), #False, "", bCreatePlaceHolder)
          
        Case "AudioFile"
          sFileName = gsSelectedDirectory + gsSelectedFile(0)
          debugMsg(sProcName, "sFileName=" + sFileName)
          WQF_setPropertyFileName(sFileName)
          SAG(-1)
          
        Case "AddQP"
          addCueWithSubCue("P", #True, #True, "", #True)
          
        Case "AudioFileMulti"
          WQP_btnBrowse_ModReturn(nFileCount)
          
        Case "AddSF"
          If bCreatePlaceHolder
            sFileName = grText\sTextPlaceHolder
          Else
            sFileName = gsSelectedDirectory + gsSelectedFile(0)
          EndIf
          debugMsg(sProcName, "sFileName=" + sFileName)
          addSubCue("F", #True, sFileName, #True)
          
        Case "AddSP"
          addSubCue("P", #True, "", #True)
          
      EndSelect
      
      THR_createOrResumeAThread(#SCS_THREAD_GET_FILE_STATS)
      
    EndIf
  EndIf
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

; EOF
