; File: fmImportDevs.pbi

EnableExplicit

Procedure WID_Form_Load()
  PROCNAMEC()
  
  If IsWindow(#WID) = #False
    createfmImportDevs()
  EndIf
  setFormPosition(#WID, @grImportDevsWindow)
  WID_Form_Resized(#True)
  WID_setupGrdDevs()
  WID_setButtons()

  setWindowVisible(#WID, #True)

EndProcedure

Procedure WID_Form_Unload()
  getFormPosition(#WID, @grImportDevsWindow)
  unsetWindowModal(#WID)
  scsCloseWindow(#WID)
  If IsWindow(#WED)
    SetActiveWindow(#WED)
  EndIf
EndProcedure

Procedure WID_btnBrowse_Click()
  PROCNAMEC()
  Protected sTitle.s, sDefaultFile.s
  Protected sThisCueFile.s
  
  debugMsg(sProcName, #SCS_START)
  
  sTitle = Lang("Common", "OpenSCSCueFile")
  If Len(Trim(gs2ndCueFolder)) > 0
    sDefaultFile = Trim(gs2ndCueFolder)
  ElseIf Len(Trim(gsCueFolder)) > 0
    sDefaultFile = Trim(gsCueFolder)
  ElseIf Len(Trim(grGeneralOptions\sInitDir)) > 0
    sDefaultFile = Trim(grGeneralOptions\sInitDir)
  EndIf
  
  ; Open the file for reading
  ; debugMsg(sProcName, "gsPatternAllCueFiles=" + gsPatternAllCueFiles)
  sThisCueFile = OpenFileRequester(sTitle, sDefaultFile, gsPatternAllCueFiles, 0)
  If Len(sThisCueFile) = 0
    ; no file selected
    ProcedureReturn
  EndIf
  ; SGT(WID\txtCueFile, sThisCueFile)
  SGT(WID\txtCueFile, GetFilePart(sThisCueFile))
  scsToolTip(WID\txtCueFile, sThisCueFile)
  
  setMouseCursorBusy()
  
  gs2ndCueFile = sThisCueFile
  gs2ndCueFolder = GetPathPart(gs2ndCueFile)
  debugMsg(sProcName, "gs2ndCueFolder=" + gs2ndCueFolder)
  
  open2ndSCSCueFile()
  If gb2ndCueFileOpen
    If gb2ndXMLFormat
      WID_clearDevMapsForImport()
      debugMsg(sProcName, "calling readXMLCueFile(" + gn2ndCueFileNo + ", #False, " + gn2ndCueFileStringFormat + ", " + GetFilePart(sThisCueFile) + ")")
      readXMLCueFile(gn2ndCueFileNo, #False, gn2ndCueFileStringFormat, sThisCueFile)
      debugMsg(sProcName, "returned from readXMLCueFile()")
    EndIf
    close2ndSCSCueFile(gn2ndCueFileNo)
    ; debugMsg(sProcName, "calling listAllDevMapsForImport()")
    ; listAllDevMapsForImport()
  EndIf
  
  debugMsg(sProcName, "calling WID_displayOtherProdInfo()")
  WID_displayOtherProdInfo()
  
  setMouseCursorNormal()
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WID_setupGrdDevs()
  PROCNAMEC()
  Protected nGrdDevs
  Protected nStyleSelect, nStyleDescr
  Protected *mg._MyGrid_Type = GetGadgetData(WID\grdDevs)
  Protected nPageSize
  
  debugMsg(sProcName, #SCS_START)
  
  nGrdDevs = WID\grdDevs
  
  MyGrid_NoRedraw(nGrdDevs)
  MyGrid_SetColorAttribute(nGrdDevs, #MyGrid_Color_FocusBorder, -1) ; hides focus rectangle
  
  If nStyleSelect = 0
    nStyleSelect = MyGrid_AddNewStyle(nGrdDevs, 0, 1)
    MyGrid_LastStyle_Font(nGrdDevs, #SCS_FONT_GEN_BOLD)
    MyGrid_LastStyle_BackColor(nGrdDevs, $F5F5F5)
    MyGrid_LastStyle_CellType(nGrdDevs, #MyGrid_CellType_Normal)
    MyGrid_LastStyle_Align(nGrdDevs, #MyGrid_Align_Center)
    MyGrid_LastStyle_Editable(nGrdDevs, #False)
  Else
    MyGrid_AssignStyle(nGrdDevs, 0, 1, nStyleSelect)
  EndIf
  MyGrid_SetText(nGrdDevs,0,1,grText\sTextSelect)
  
  If nStyleDescr = 0
    nStyleDescr = MyGrid_AddNewStyle(nGrdDevs, 0, 2)
    MyGrid_LastStyle_Font(nGrdDevs, #SCS_FONT_GEN_BOLD)
    MyGrid_LastStyle_BackColor(nGrdDevs, $F5F5F5)
    MyGrid_LastStyle_CellType(nGrdDevs, #MyGrid_CellType_Normal)
    MyGrid_LastStyle_Align(nGrdDevs, #MyGrid_Align_Left)
    MyGrid_LastStyle_Editable(nGrdDevs, #False)
  Else
    MyGrid_AssignStyle(nGrdDevs, 0, 2, nStyleDescr)
  EndIf
  MyGrid_SetText(nGrdDevs,0,2,grText\sTextDevice)
  MyGrid_Col_ChangeWidth(nGrdDevs,2,400)
  
  nPageSize = Round(GadgetHeight(nGrdDevs) / MyGrid_GetAttribute(nGrdDevs, #MyGrid_Att_RowHeight), #PB_Round_Down)
  debugMsg(sProcName, "nPageSize=" + nPageSize)
  MyGrid_SetAttribute(nGrdDevs, #MyGrid_Att_RowScrollPageSize, nPageSize)
  
  MyGrid_Col_Hide(nGrdDevs,0,#True)
  MyGrid_Resize(nGrdDevs, #PB_Ignore, #PB_Ignore, #PB_Ignore, #PB_Ignore)
  MyGrid_Redraw(nGrdDevs)
  MyGrid_FocusCell(nGrdDevs,0,0)
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WID_countImportDevices(nDevGroup)
  PROCNAMEC()
  Protected nDevCount
  Protected d
  
  Select nDevGroup
    Case #SCS_DEVGRP_AUDIO_OUTPUT
      For d = 0 To gr2ndProd\nMaxAudioLogicalDev
        If gr2ndProd\aAudioLogicalDevs(d)\sLogicalDev
          nDevCount + 1
        EndIf
      Next d
      
    Case #SCS_DEVGRP_VIDEO_AUDIO
      For d = 0 To gr2ndProd\nMaxVidAudLogicalDev
        If gr2ndProd\aVidAudLogicalDevs(d)\sVidAudLogicalDev
          nDevCount + 1
        EndIf
      Next d
      
    Case #SCS_DEVGRP_VIDEO_CAPTURE
      For d = 0 To gr2ndProd\nMaxVidCapLogicalDev
        If gr2ndProd\aVidCapLogicalDevs(d)\sLogicalDev
          nDevCount + 1
        EndIf
      Next d
      
    Case #SCS_DEVGRP_FIX_TYPE
      For d = 0 To gr2ndProd\nMaxFixType
        If gr2ndProd\aFixTypes(d)\sFixTypeName
          nDevCount + 1
        EndIf
      Next d
      
    Case #SCS_DEVGRP_LIGHTING
      For d = 0 To gr2ndProd\nMaxLightingLogicalDev
        If gr2ndProd\aLightingLogicalDevs(d)\sLogicalDev
          nDevCount + 1
        EndIf
      Next d
      
    Case #SCS_DEVGRP_CTRL_SEND
      For d = 0 To gr2ndProd\nMaxCtrlSendLogicalDev
        If gr2ndProd\aCtrlSendLogicalDevs(d)\sLogicalDev
          nDevCount + 1
        EndIf
      Next d
      
    Case #SCS_DEVGRP_CUE_CTRL
      For d = 0 To gr2ndProd\nMaxCueCtrlLogicalDev
        If gr2ndProd\aCueCtrlLogicalDevs(d)\sCueCtrlLogicalDev
          If gr2ndProd\aCueCtrlLogicalDevs(d)\nDevType <> #SCS_DEVTYPE_NONE
            nDevCount + 1
          EndIf
        EndIf
      Next d
      
    Case #SCS_DEVGRP_LIVE_INPUT
      For d = 0 To gr2ndProd\nMaxLiveInputLogicalDev
        If gr2ndProd\aLiveInputLogicalDevs(d)\sLogicalDev
          nDevCount + 1
        EndIf
      Next d
      
    Case #SCS_DEVGRP_IN_GRP
      For d = 0 To gr2ndProd\nMaxInGrp
        If gr2ndProd\aInGrps(d)\sInGrpName
          nDevCount + 1
        EndIf
      Next d
      
  EndSelect
  
  ; debugMsg(sProcName, #SCS_END + ", nDevGrp=" + decodeDevGrp(nDevGroup) + ", nDevCount=" + nDevCount)
  ProcedureReturn nDevCount
EndProcedure

Procedure WID_storeRowInfo(nRow, nRowType, nDevGrp=0, nDevNo=-1, sLogicalDev.s="", sDevMapName.s="", nDevMapForImportPtr=-1)
  PROCNAMEC()
  
  ; debugMsg(sProcName, #SCS_START + ", nRow=" + nRow + ", nRowType=" + nRowType + ", nDevGrp=" + decodeDevGrp(nDevGrp) + ", nDevNo=" + nDevNo + ", sLogicalDev=" + sLogicalDev + ", sDevMapName=" + sDevMapName + ", nDevMapForImportPtr=" + nDevMapForImportPtr)
  
  If nRow > ArraySize(grWID\aRowInfo())
    ReDim grWID\aRowInfo(nRow + 10)
  EndIf
  With grWID\aRowInfo(nRow)
    \nRow = nRow
    \nRowType = nRowType
    \nDevGrp = nDevGrp
    \nDevNo = nDevNo
    \sLogicalDev = sLogicalDev
    \sDevMapName = sDevMapName
    \nDevMapForImportPtr = nDevMapForImportPtr
  EndWith
  If nRow > grWID\nMaxRowNo
    grWID\nMaxRowNo = nRow
  EndIf
  
EndProcedure

Procedure WID_calcRowsReqd()
  PROCNAMEC()
  Protected nRows
  Protected d, n
  
  debugMsg(sProcName, #SCS_START)
  
  nRows + 1  ; for devmap header
  nRows + (grMapsForImport\nMaxMapIndex + 1) ; Modified 1Nov2021 11.8.6bn: added +1 as grMapsForImport\nMaxMapIndex is 0-based
  
  If grLicInfo\nMaxAudDevPerProd > 0
    If WID_countImportDevices(#SCS_DEVGRP_AUDIO_OUTPUT) > 0
      nRows + 1  ; for audio devices
      For d = 0 To gr2ndProd\nMaxAudioLogicalDev
        With gr2ndProd\aAudioLogicalDevs(d)
          If \nDevType = #SCS_DEVTYPE_AUDIO_OUTPUT
            If \sLogicalDev
              nRows + 1
            EndIf
          EndIf
        EndWith
      Next d
    EndIf
  EndIf
  
  If grLicInfo\nMaxVidAudDevPerProd > 0
    If WID_countImportDevices(#SCS_DEVGRP_VIDEO_AUDIO) > 0
      nRows + 1  ; for video audio header
      For d = 0 To gr2ndProd\nMaxVidAudLogicalDev
        With gr2ndProd\aVidAudLogicalDevs(d)
          If \sVidAudLogicalDev
            nRows + 1
          EndIf
        EndWith
      Next d
    EndIf
  EndIf
  
  If grLicInfo\nMaxVidCapDevPerProd > 0
    If WID_countImportDevices(#SCS_DEVGRP_VIDEO_CAPTURE) > 0
      nRows + 1  ; for video capture header
      For d = 0 To gr2ndProd\nMaxVidCapLogicalDev
        With gr2ndProd\aVidCapLogicalDevs(d)
          If \sLogicalDev
            nRows + 1
          EndIf
        EndWith
      Next d
    EndIf
  EndIf
  
  If grLicInfo\nMaxLiveDevPerProd > 0
    If WID_countImportDevices(#SCS_DEVGRP_LIVE_INPUT) > 0
      nRows + 1  ; for live inputs header
      For d = 0 To gr2ndProd\nMaxLiveInputLogicalDev
        With gr2ndProd\aLiveInputLogicalDevs(d)
          If \sLogicalDev
            nRows + 1
          EndIf
        EndWith
      Next d
    EndIf
  EndIf
  
  If grLicInfo\nMaxInGrpPerProd > 0
    If WID_countImportDevices(#SCS_DEVGRP_IN_GRP) > 0
      nRows + 1  ; for input groups header
      For d = 0 To gr2ndProd\nMaxInGrp
        With gr2ndProd\aInGrps(d)
          If \sInGrpName
            nRows + 1
          EndIf
        EndWith
      Next d
    EndIf
  EndIf
  
  If grLicInfo\nMaxFixTypePerProd > 0
    If WID_countImportDevices(#SCS_DEVGRP_FIX_TYPE) > 0
      nRows + 1  ; for fixture type header
      For d = 0 To gr2ndProd\nMaxFixType
        With gr2ndProd\aFixTypes(d)
          If \sFixTypeName
            nRows + 1
          EndIf
        EndWith
      Next d
    EndIf
  EndIf
  
  If grLicInfo\nMaxLightingDevPerProd > 0
    If WID_countImportDevices(#SCS_DEVGRP_LIGHTING) > 0
      nRows + 1  ; for lighting header
      For d = 0 To gr2ndProd\nMaxLightingLogicalDev
        With gr2ndProd\aLightingLogicalDevs(d)
          If \sLogicalDev
            nRows + 1
          EndIf
        EndWith
      Next d
    EndIf
  EndIf
  
  If grLicInfo\nMaxCtrlSendDevPerProd > 0
    If WID_countImportDevices(#SCS_DEVGRP_CTRL_SEND) > 0
      nRows + 1  ; for control send header
      For d = 0 To gr2ndProd\nMaxCtrlSendLogicalDev
        With gr2ndProd\aCtrlSendLogicalDevs(d)
          If \sLogicalDev
            nRows + 1
          EndIf
        EndWith
      Next d
    EndIf
  EndIf
  
  If grLicInfo\nMaxCueCtrlDev > 0
    If WID_countImportDevices(#SCS_DEVGRP_CUE_CTRL) > 0
      nRows + 1  ; for cue control header
      For d = 0 To gr2ndProd\nMaxCueCtrlLogicalDev
        With gr2ndProd\aCueCtrlLogicalDevs(d)
          If \nDevType <> #SCS_DEVTYPE_NONE
            nRows + 1
          EndIf
        EndWith
      Next d
    EndIf
  EndIf
  
  debugMsg(sProcName, #SCS_END + ", nRows=" + nRows)
  ProcedureReturn nRows
  
EndProcedure

Procedure WID_loadGrdDevs()
  PROCNAMEC()
  Protected nGrdDevs
  Protected nRowsReqd
  Protected nRow
  Protected d, n
  Protected sText.s
  Protected nPass, bWantThis
  Protected nStyleChkSelect, nStyleGroupHeader
  Protected nFirstSelectedDevMapPtr
  Protected nDevMapDevPtr
  Protected sShowingDevmap.s
  Static sMono.s, sStereo.s, sChannels.s
  Static sShowing.s
  Static bStaticLoaded
  
  debugMsg(sProcName, #SCS_START)
  
  If bStaticLoaded = #False
    sMono = LCase(Lang("Common", "mono"))
    sStereo = LCase(Lang("Common", "stereo"))
    sChannels = LCase(Lang("Common", "channels"))
    sShowing = " (" + Lang("WID", "showing") + ")"
    bStaticLoaded = #True
  EndIf
  
  nGrdDevs = WID\grdDevs
  For nRow = 1 To grWID\nMaxRowNo
    Select grWID\aRowInfo(nRow)\nRowType
      Case #SCS_IMD_HEADER
        MyGrid_UnMergeCells(nGrdDevs, nRow, 1)
    EndSelect
  Next nRow
  
  grWID\nMaxRowNo = 0
  
  nRowsReqd = WID_calcRowsReqd()
  MyGrid_ReDefineRows(nGrdDevs, 1)
  MyGrid_ReDefineRows(nGrdDevs, nRowsReqd)
  
  nRow = 1
  If nStyleGroupHeader = 0
    nStyleGroupHeader = MyGrid_AddNewStyle(nGrdDevs, nRow, 1)
    MyGrid_LastStyle_BackColor(nGrdDevs, #SCS_Very_Light_Grey) ; $F5F5F5)
    MyGrid_LastStyle_CellType(nGrdDevs, #MyGrid_CellType_Normal)
    MyGrid_LastStyle_Align(nGrdDevs, #MyGrid_Align_Left)
    MyGrid_LastStyle_Editable(nGrdDevs, #False)
  Else
    MyGrid_AssignStyle(nGrdDevs, nRow, 1, nStyleGroupHeader)
  EndIf
  MyGrid_SetText(nGrdDevs, nRow, 1, Lang("Common","DevMaps"))
  MyGrid_MergeCells(nGrdDevs,nRow,1,nRow,2)
  WID_storeRowInfo(nRow, #SCS_IMD_HEADER)
  
  debugMsg(sProcName, "grMapsForImport\sSelectedDevMapName=" + grMapsForImport\sSelectedDevMapName + ", \nMaxMapIndex=" + grMapsForImport\nMaxMapIndex)
  For nPass = 1 To 2
    debugMsg(sProcName, "nPass=" + nPass)
    For n = 0 To grMapsForImport\nMaxMapIndex
      bWantThis = #False
      With grMapsForImport\aMap(n)
        Select nPass
          Case 1
            ; display selected device map first
            If \sDevMapName = grMapsForImport\sSelectedDevMapName ; gsSelectedDevMapName2
              bWantThis = #True
            EndIf
          Case 2
            ; display non-selected device maps next
            If \sDevMapName <> grMapsForImport\sSelectedDevMapName ; gsSelectedDevMapName2
              bWantThis = #True
            EndIf
        EndSelect
        debugMsg(sProcName, "grMapsForImport\aMap(" + n + ")\sDevMapName=" + \sDevMapName + ", bWantThis=" + strB(bWantThis))
        If bWantThis
          sText = \sDevMapName
          If \sDevMapName = grMapsForImport\sSelectedDevMapName ; gsSelectedDevMapName2
            sText + " (" + LCase(Lang("Common", "Selected")) + ")"
          EndIf
          sText + " [" + decodeDriverL(\nAudioDriver) + "]"
          nRow + 1
          If nStyleChkSelect = 0
            nStyleChkSelect = MyGrid_AddNewStyle(nGrdDevs, nRow, 1)
            MyGrid_LastStyle_CellType(nGrdDevs, #MyGrid_CellType_Checkbox)
            MyGrid_LastStyle_Align(nGrdDevs, #MyGrid_Align_Center)
            MyGrid_LastStyle_Editable(nGrdDevs, #True)
          Else
            MyGrid_AssignStyle(nGrdDevs, nRow, 1, nStyleChkSelect)
          EndIf
          MyGrid_SetText(nGrdDevs, nRow, 1, "1")  ; tick checkbox
          MyGrid_SetText(nGrdDevs, nRow, 2, sText)
          WID_storeRowInfo(nRow, #SCS_IMD_DEVMAP, 0, -1, "", \sDevMapName, n)
        EndIf
      EndWith
    Next n
  Next nPass
  
  nFirstSelectedDevMapPtr = WID_getFirstSelectedDevMapPtr()
  debugMsg(sProcName, "nFirstSelectedDevMapPtr=" + nFirstSelectedDevMapPtr)
  
;   debugMsg(sProcName, "calling listAllDevMapsForImport()")
;   listAllDevMapsForImport()
;   debugMsg(sProcName, "calling debugProd(@gr2ndProd)")
;   debugProd(@gr2ndProd)
  
  nRow + 1
  MyGrid_AssignStyle(nGrdDevs, nRow, 1, nStyleGroupHeader)
  MyGrid_SetText(nGrdDevs, nRow, 1, LangPars("WEP","tbsDevices", Lang("DevGrp", "AudioOutput")))
  MyGrid_MergeCells(nGrdDevs,nRow,1,nRow,2)
  WID_storeRowInfo(nRow, #SCS_IMD_HEADER, #SCS_DEVGRP_AUDIO_OUTPUT)
  For d = 0 To gr2ndProd\nMaxAudioLogicalDev
    With gr2ndProd\aAudioLogicalDevs(d)
      If \nDevType = #SCS_DEVTYPE_AUDIO_OUTPUT
        If \sLogicalDev
          nRow + 1
          If nStyleChkSelect = 0
            nStyleChkSelect = MyGrid_AddNewStyle(nGrdDevs, nRow, 1)
            MyGrid_LastStyle_CellType(nGrdDevs, #MyGrid_CellType_Checkbox)
            MyGrid_LastStyle_Align(nGrdDevs, #MyGrid_Align_Center)
            MyGrid_LastStyle_Editable(nGrdDevs, #True)
          Else
            MyGrid_AssignStyle(nGrdDevs, nRow, 1, nStyleChkSelect)
          EndIf
          MyGrid_SetText(nGrdDevs, nRow, 1, "1")  ; tick checkbox
          ; debugMsg(sProcName, "\nDevType=" + decodeDevType(\nDevType) + ", nRow=" + nRow + ", sText=" + sText)
          WID_storeRowInfo(nRow, #SCS_IMD_DEVICE, #SCS_DEVGRP_AUDIO_OUTPUT, d, \sLogicalDev)
        EndIf
      EndIf
    EndWith
  Next d
  
  If grLicInfo\nMaxVidAudDevPerProd > 0
    ;{
    If WID_countImportDevices(#SCS_DEVGRP_VIDEO_AUDIO) > 0
      nRow + 1
      MyGrid_AssignStyle(nGrdDevs, nRow, 1, nStyleGroupHeader)
      MyGrid_SetText(nGrdDevs, nRow, 1, LangPars("WEP","tbsDevices", Lang("DevGrp", "VideoAudio")))
      ; debugMsg(sProcName, "MyGrid_SetText(nGrdDevs, " + nRow + ", 1, " + LangPars("WEP","tbsDevices", Lang("DevGrp", "VideoAudio")) + ")")
      MyGrid_MergeCells(nGrdDevs,nRow,1,nRow,2)
      WID_storeRowInfo(nRow, #SCS_IMD_HEADER, #SCS_DEVGRP_VIDEO_AUDIO)
      For d = 0 To gr2ndProd\nMaxVidAudLogicalDev
        With gr2ndProd\aVidAudLogicalDevs(d)
          If \sVidAudLogicalDev
            sText = \sVidAudLogicalDev
            nDevMapDevPtr = getDevMapDevPtrForLogicalDev(@grMapsForImport, #SCS_DEVGRP_VIDEO_AUDIO, \sVidAudLogicalDev, nFirstSelectedDevMapPtr)
            If nDevMapDevPtr >= 0
              sText + ": " + grMapsForImport\aDev(nDevMapDevPtr)\sPhysicalDev
            EndIf
            nRow + 1
            MyGrid_AssignStyle(nGrdDevs, nRow, 1, nStyleChkSelect)
            MyGrid_SetText(nGrdDevs, nRow, 1, "1")  ; tick checkbox
            MyGrid_SetText(nGrdDevs, nRow, 2, sText)
            ; debugMsg(sProcName, "MyGrid_SetText(nGrdDevs, " + nRow + ", 2, " + sText + ")")
            WID_storeRowInfo(nRow, #SCS_IMD_DEVICE, #SCS_DEVGRP_VIDEO_AUDIO, d, \sVidAudLogicalDev)
          EndIf
        EndWith
      Next d
    EndIf
    ;}
  EndIf
  
  If grLicInfo\nMaxVidCapDevPerProd > 0
    ;{
    If WID_countImportDevices(#SCS_DEVGRP_VIDEO_CAPTURE) > 0
      nRow + 1
      MyGrid_AssignStyle(nGrdDevs, nRow, 1, nStyleGroupHeader)
      MyGrid_SetText(nGrdDevs, nRow, 1, LangPars("WEP","tbsDevices", Lang("DevGrp", "VideoCapture")))
      ; debugMsg(sProcName, "MyGrid_SetText(nGrdDevs, " + nRow + ", 1, " + LangPars("WEP","tbsDevices", Lang("DevGrp", "VideoCapture")) + ")")
      MyGrid_MergeCells(nGrdDevs,nRow,1,nRow,2)
      WID_storeRowInfo(nRow, #SCS_IMD_HEADER, #SCS_DEVGRP_VIDEO_CAPTURE)
      For d = 0 To gr2ndProd\nMaxVidCapLogicalDev
        With gr2ndProd\aVidCapLogicalDevs(d)
          If \sLogicalDev
            sText = \sLogicalDev
            nDevMapDevPtr = getDevMapDevPtrForLogicalDev(@grMapsForImport, #SCS_DEVGRP_VIDEO_CAPTURE, \sLogicalDev, nFirstSelectedDevMapPtr)
            If nDevMapDevPtr >= 0
              sText + ": " + grMapsForImport\aDev(nDevMapDevPtr)\sPhysicalDev
            EndIf
            nRow + 1
            MyGrid_AssignStyle(nGrdDevs, nRow, 1, nStyleChkSelect)
            MyGrid_SetText(nGrdDevs, nRow, 1, "1")  ; tick checkbox
            MyGrid_SetText(nGrdDevs, nRow, 2, sText)
            ; debugMsg(sProcName, "MyGrid_SetText(nGrdDevs, " + nRow + ", 2, " + sText + ")")
            WID_storeRowInfo(nRow, #SCS_IMD_DEVICE, #SCS_DEVGRP_VIDEO_CAPTURE, d, \sLogicalDev)
          EndIf
        EndWith
      Next d
    EndIf
    ;}
  EndIf
  
  If grLicInfo\nMaxFixTypePerProd > 0
    ;{
    If WID_countImportDevices(#SCS_DEVGRP_FIX_TYPE) > 0
      nRow + 1
      MyGrid_AssignStyle(nGrdDevs, nRow, 1, nStyleGroupHeader)
      MyGrid_SetText(nGrdDevs, nRow, 1, LangPars("WEP","tbsDevices", Lang("DevGrp", "FixType")))
      ; debugMsg(sProcName, "MyGrid_SetText(nGrdDevs, " + nRow + ", 1, " + LangPars("WEP","tbsDevices", Lang("DevGrp", "FixType")) + ")")
      MyGrid_MergeCells(nGrdDevs,nRow,1,nRow,2)
      WID_storeRowInfo(nRow, #SCS_IMD_HEADER, #SCS_DEVGRP_FIX_TYPE)
      For d = 0 To gr2ndProd\nMaxFixType
        With gr2ndProd\aFixTypes(d)
          If \sFixTypeName
            sText = \sFixTypeName
            nRow + 1
            MyGrid_AssignStyle(nGrdDevs, nRow, 1, nStyleChkSelect)
            MyGrid_SetText(nGrdDevs, nRow, 1, "1")  ; tick checkbox
            MyGrid_SetText(nGrdDevs, nRow, 2, sText)
            ; debugMsg(sProcName, "MyGrid_SetText(nGrdDevs, " + nRow + ", 2, " + sText + ")")
            WID_storeRowInfo(nRow, #SCS_IMD_DEVICE, #SCS_DEVGRP_FIX_TYPE, d, \sFixTypeName)
          EndIf
        EndWith
      Next d
    EndIf
    ;}
  EndIf
  
  If grLicInfo\nMaxLightingDevPerProd > 0
    ;{
    If WID_countImportDevices(#SCS_DEVGRP_LIGHTING) > 0
      nRow + 1
      MyGrid_AssignStyle(nGrdDevs, nRow, 1, nStyleGroupHeader)
      MyGrid_SetText(nGrdDevs, nRow, 1, LangPars("WEP","tbsDevices", Lang("DevGrp", "Lighting")))
      ; debugMsg(sProcName, "MyGrid_SetText(nGrdDevs, " + nRow + ", 1, " + LangPars("WEP","tbsDevices", Lang("DevGrp", "Lighting")) + ")")
      MyGrid_MergeCells(nGrdDevs, nRow, 1, nRow, 2)
      WID_storeRowInfo(nRow, #SCS_IMD_HEADER, #SCS_DEVGRP_LIGHTING)
      For d = 0 To gr2ndProd\nMaxLightingLogicalDev
        With gr2ndProd\aLightingLogicalDevs(d)
          debugMsg(sProcName, "gr2ndProd\aLightingLogicalDevs(" + d + ")\sLogicalDev=" + \sLogicalDev + ", \nDevType=" + decodeDevType(\nDevType))
          If \sLogicalDev
            sText = \sLogicalDev + ": " + decodeDevTypeL(\nDevType)
            nDevMapDevPtr = getDevMapDevPtrForLogicalDev(@grMapsForImport, #SCS_DEVGRP_LIGHTING, \sLogicalDev, nFirstSelectedDevMapPtr) ; Added nFirstSelectedDevMapPtr 3Mar2023 11.10.0
            If nDevMapDevPtr >= 0
              If grMapsForImport\aDev(nDevMapDevPtr)\sPhysicalDev
                sText + ": " + grMapsForImport\aDev(nDevMapDevPtr)\sPhysicalDev
              EndIf
            EndIf
            nRow + 1
            MyGrid_AssignStyle(nGrdDevs, nRow, 1, nStyleChkSelect)
            MyGrid_SetText(nGrdDevs, nRow, 1, "1")  ; tick checkbox
            MyGrid_SetText(nGrdDevs, nRow, 2, sText)
            debugMsg(sProcName, "MyGrid_SetText(nGrdDevs, " + nRow + ", 2, " + sText + ")")
            WID_storeRowInfo(nRow, #SCS_IMD_DEVICE, #SCS_DEVGRP_LIGHTING, d, \sLogicalDev)
          EndIf
        EndWith
      Next d
    EndIf
    ;}
  EndIf
  
  If grLicInfo\nMaxCtrlSendDevPerProd > 0
    ;{
    If WID_countImportDevices(#SCS_DEVGRP_CTRL_SEND) > 0
      nRow + 1
      MyGrid_AssignStyle(nGrdDevs, nRow, 1, nStyleGroupHeader)
      MyGrid_SetText(nGrdDevs, nRow, 1, LangPars("WEP","tbsDevices", Lang("DevGrp", "CtrlSend")))
      ; debugMsg(sProcName, "MyGrid_SetText(nGrdDevs, " + nRow + ", 1, " + LangPars("WEP","tbsDevices", Lang("DevGrp", "CtrlSend")) + ")")
      MyGrid_MergeCells(nGrdDevs,nRow,1,nRow,2)
      WID_storeRowInfo(nRow, #SCS_IMD_HEADER, #SCS_DEVGRP_CTRL_SEND)
      For d = 0 To gr2ndProd\nMaxCtrlSendLogicalDev
        With gr2ndProd\aCtrlSendLogicalDevs(d)
          If \sLogicalDev
            sText = \sLogicalDev + ": " + decodeDevTypeL(\nDevType)
            nDevMapDevPtr = getDevMapDevPtrForLogicalDev(@grMapsForImport, #SCS_DEVGRP_CTRL_SEND, \sLogicalDev, nFirstSelectedDevMapPtr) ; Added nFirstSelectedDevMapPtr 3Mar2023 11.10.0
            If nDevMapDevPtr >= 0
              If grMapsForImport\aDev(nDevMapDevPtr)\sPhysicalDev
                sText + ": " + grMapsForImport\aDev(nDevMapDevPtr)\sPhysicalDev
              Else
                If \nCtrlNetworkRemoteDev <> #SCS_CS_NETWORK_REM_ANY
                  sText + ": " + decodeCtrlNetworkRemoteDevL(\nCtrlNetworkRemoteDev)
                Else
                  Select \nDevType
                    Case #SCS_DEVTYPE_CS_NETWORK_OUT
                      Select \nNetworkRole
                        Case #SCS_NETWORK_ROLE_SCS_IS_A_CLIENT
                          sText + ": " + grMapsForImport\aDev(nDevMapDevPtr)\sRemoteHost + ":" + grMapsForImport\aDev(nDevMapDevPtr)\nRemotePort
                        Case #SCS_NETWORK_ROLE_SCS_IS_A_SERVER
                          sText + ": " + grMapsForImport\aDev(nDevMapDevPtr)\nLocalPort
                      EndSelect
                  EndSelect
                EndIf
              EndIf
            EndIf
            nRow + 1
            MyGrid_AssignStyle(nGrdDevs, nRow, 1, nStyleChkSelect)
            MyGrid_SetText(nGrdDevs, nRow, 1, "1")  ; tick checkbox
            MyGrid_SetText(nGrdDevs, nRow, 2, sText)
            ; debugMsg(sProcName, "MyGrid_SetText(nGrdDevs, " + nRow + ", 2, " + sText + ")")
            WID_storeRowInfo(nRow, #SCS_IMD_DEVICE, #SCS_DEVGRP_CTRL_SEND, d, \sLogicalDev)
          EndIf
        EndWith
      Next d
    EndIf
    ;}
  EndIf
  
  If grLicInfo\nMaxCueCtrlDev > 0
    ;{
    If WID_countImportDevices(#SCS_DEVGRP_CUE_CTRL) > 0
      nRow + 1
      MyGrid_AssignStyle(nGrdDevs, nRow, 1, nStyleGroupHeader)
      MyGrid_SetText(nGrdDevs, nRow, 1, LangPars("WEP","tbsDevices", Lang("DevGrp", "CueCtrl")))
      ; debugMsg(sProcName, "MyGrid_SetText(nGrdDevs, " + nRow + ", 1, " + LangPars("WEP","tbsDevices", Lang("DevGrp", "CueCtrl")) + ")")
      MyGrid_MergeCells(nGrdDevs,nRow,1,nRow,2)
      WID_storeRowInfo(nRow, #SCS_IMD_HEADER, #SCS_DEVGRP_CUE_CTRL)
      For d = 0 To gr2ndProd\nMaxCueCtrlLogicalDev
        With gr2ndProd\aCueCtrlLogicalDevs(d)
          If \nDevType <> #SCS_DEVTYPE_NONE
            sText = \sCueCtrlLogicalDev + ": " + decodeDevTypeL(\nDevType)
            nDevMapDevPtr = getDevMapDevPtrForLogicalDev(@grMapsForImport, #SCS_DEVGRP_CUE_CTRL, \sCueCtrlLogicalDev, nFirstSelectedDevMapPtr) ; Added nFirstSelectedDevMapPtr 3Mar2023 11.10.0
            If nDevMapDevPtr >= 0
              If grMapsForImport\aDev(nDevMapDevPtr)\sPhysicalDev
                sText + ": " + grMapsForImport\aDev(nDevMapDevPtr)\sPhysicalDev
              Else
                If \nCueNetworkRemoteDev <> #SCS_CC_NETWORK_REM_ANY
                  sText + ": " + decodeCueNetworkRemoteDevL(\nCueNetworkRemoteDev)
                Else
                  Select \nDevType
                    Case #SCS_DEVTYPE_CC_NETWORK_IN
                      Select \nNetworkRole
                        Case #SCS_NETWORK_ROLE_SCS_IS_A_CLIENT
                          sText + ": " + grMapsForImport\aDev(nDevMapDevPtr)\sRemoteHost + ":" + grMapsForImport\aDev(nDevMapDevPtr)\nRemotePort
                        Case #SCS_NETWORK_ROLE_SCS_IS_A_SERVER
                          sText + ": " + grMapsForImport\aDev(nDevMapDevPtr)\nLocalPort
                      EndSelect
                  EndSelect
                EndIf
              EndIf
            EndIf
            nRow + 1
            MyGrid_AssignStyle(nGrdDevs, nRow, 1, nStyleChkSelect)
            MyGrid_SetText(nGrdDevs, nRow, 1, "1")  ; tick checkbox
            MyGrid_SetText(nGrdDevs, nRow, 2, sText)
            ; debugMsg(sProcName, "MyGrid_SetText(nGrdDevs, " + nRow + ", 2, " + sText + ")")
            WID_storeRowInfo(nRow, #SCS_IMD_DEVICE, #SCS_DEVGRP_CUE_CTRL, d, \sCueCtrlLogicalDev)
          EndIf
        EndWith
      Next d
    EndIf
    ;}
  EndIf
  
  If grLicInfo\nMaxLiveDevPerProd > 0
    ;{
    If WID_countImportDevices(#SCS_DEVGRP_LIVE_INPUT) > 0
      nRow + 1
      MyGrid_AssignStyle(nGrdDevs, nRow, 1, nStyleGroupHeader)
      MyGrid_SetText(nGrdDevs, nRow, 1, LangPars("WEP","tbsDevices", Lang("DevGrp", "LiveInput")))
      ; debugMsg(sProcName, "MyGrid_SetText(nGrdDevs, " + nRow + ", 1, " + LangPars("WEP","tbsDevices", Lang("DevGrp", "LiveInput")) + ")")
      MyGrid_MergeCells(nGrdDevs,nRow,1,nRow,2)
      WID_storeRowInfo(nRow, #SCS_IMD_HEADER, #SCS_DEVGRP_LIVE_INPUT)
      For d = 0 To gr2ndProd\nMaxLiveInputLogicalDev
        With gr2ndProd\aLiveInputLogicalDevs(d)
          If \sLogicalDev
            sText = \sLogicalDev
            nDevMapDevPtr = getDevMapDevPtrForLogicalDev(@grMapsForImport, #SCS_DEVGRP_LIVE_INPUT, \sLogicalDev, nFirstSelectedDevMapPtr)
            If nDevMapDevPtr >= 0
              sText + ": " + grMapsForImport\aDev(nDevMapDevPtr)\sPhysicalDev
              If grMapsForImport\aDev(nDevMapDevPtr)\s1BasedInputRange
                sText + ": " + grMapsForImport\aDev(nDevMapDevPtr)\s1BasedInputRange
              EndIf
            EndIf
            nRow + 1
            MyGrid_AssignStyle(nGrdDevs, nRow, 1, nStyleChkSelect)
            MyGrid_SetText(nGrdDevs, nRow, 1, "1")  ; tick checkbox
            MyGrid_SetText(nGrdDevs, nRow, 2, sText)
            ; debugMsg(sProcName, "MyGrid_SetText(nGrdDevs, " + nRow + ", 2, " + sText + ")")
            WID_storeRowInfo(nRow, #SCS_IMD_DEVICE, #SCS_DEVGRP_LIVE_INPUT, d, \sLogicalDev)
          EndIf
        EndWith
      Next d
    EndIf
    ;}
  EndIf
  
  If grLicInfo\nMaxInGrpPerProd > 0
    ;{
    If WID_countImportDevices(#SCS_DEVGRP_IN_GRP) > 0
      nRow + 1
      MyGrid_AssignStyle(nGrdDevs, nRow, 1, nStyleGroupHeader)
      MyGrid_SetText(nGrdDevs, nRow, 1, LangPars("WEP","tbsDevices", Lang("DevGrp", "InGrp")))
      ; debugMsg(sProcName, "MyGrid_SetText(nGrdDevs, " + nRow + ", 1, " + LangPars("WEP","tbsDevices", Lang("DevGrp", "InGrp")) + ")")
      MyGrid_MergeCells(nGrdDevs,nRow,1,nRow,2)
      WID_storeRowInfo(nRow, #SCS_IMD_HEADER, #SCS_DEVGRP_IN_GRP)
      For d = 0 To gr2ndProd\nMaxInGrp
        With gr2ndProd\aInGrps(d)
          If \sInGrpName
            sText = \sInGrpName
            nRow + 1
            MyGrid_AssignStyle(nGrdDevs, nRow, 1, nStyleChkSelect)
            MyGrid_SetText(nGrdDevs, nRow, 1, "1")  ; tick checkbox
            MyGrid_SetText(nGrdDevs, nRow, 2, sText)
            ; debugMsg(sProcName, "MyGrid_SetText(nGrdDevs, " + nRow + ", 2, " + sText + ")")
            WID_storeRowInfo(nRow, #SCS_IMD_DEVICE, #SCS_DEVGRP_IN_GRP, d, \sInGrpName)
          EndIf
        EndWith
      Next d
    EndIf
    ;}
  EndIf
  
  WID_refreshGrdDevs()
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WID_displayOtherProdInfo()
  PROCNAMEC()
  Protected i, j, nRow
  Protected sCue.s, sCueType.s

  debugMsg(sProcName, #SCS_START)
  
  debugMsg(sProcName, "gs2ndCueFile=" + gs2ndCueFile)
  
  ; SGT(WID\txtCueFile, gs2ndCueFile)
  SGT(WID\txtCueFile, GetFilePart(gs2ndCueFile))
  scsToolTip(WID\txtCueFile, gs2ndCueFile)
  SGT(WID\txtProdTitle, gr2ndProd\sTitle)
  
  WID_loadGrdDevs()

  WID_setButtons()

EndProcedure

Procedure WID_displayOrHideInfoMsg()
  PROCNAMEC()
  Protected bDisplayMsg, nMapIndex, nDevIndex
  
  
EndProcedure

Procedure WID_getFirstSelectedDevMapPtr()
  PROCNAMEC()
  Protected nDevMapPtr = -1
  Protected nRow
  Protected nGrdDevs
  Protected sText.s
  
  ; debugMsg(sProcName, #SCS_START)
  
  nGrdDevs = WID\grdDevs
  For nRow = 1 To grWID\nMaxRowNo
    With grWID\aRowInfo(nRow)
      If \nRowType = #SCS_IMD_DEVMAP
        sText = MyGrid_GetText(nGrdDevs, nRow, 1)
        If sText = "1" And \nDevMapForImportPtr >= 0
          nDevMapPtr = \nDevMapForImportPtr
          Break
        EndIf
      EndIf
    EndWith
  Next nRow
  
  ProcedureReturn nDevMapPtr
  
EndProcedure

Procedure WID_setButtons()
  PROCNAMEC()
  Protected nRow
  Protected nRowCount, nRowsChecked, nDevsChecked
  Protected nGrdDevs
  Protected sText.s
  Protected nFirstSelectedDevMap
  
  ; debugMsg(sProcName, #SCS_START)
  
  nFirstSelectedDevMap = WID_getFirstSelectedDevMapPtr()
  
  nGrdDevs = WID\grdDevs
  For nRow = 1 To grWID\nMaxRowNo
    With grWID\aRowInfo(nRow)
      Select \nRowType
        Case #SCS_IMD_DEVMAP, #SCS_IMD_DEVICE
          nRowCount + 1
          sText = MyGrid_GetText(nGrdDevs, nRow, 1)
          If sText = "1"
            nRowsChecked + 1
            If \nRowType = #SCS_IMD_DEVICE
              nDevsChecked + 1
            EndIf
          EndIf
      EndSelect
    EndWith
  Next nRow
  
  If nRowCount = 0 Or nRowsChecked = nRowCount
    setEnabled(WID\btnSelectAll, #False)
  Else
    setEnabled(WID\btnSelectAll, #True)
  EndIf

  If nRowsChecked = 0
    setEnabled(WID\btnClearAll, #False)
  Else
    setEnabled(WID\btnClearAll, #True)
  EndIf
  
  If nDevsChecked = 0 And nFirstSelectedDevMap < 0
    setEnabled(WID\btnImportDevs, #False)
  Else
    setEnabled(WID\btnImportDevs, #True)
  EndIf
  
  ; debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WID_Form_Show(bModal=#False)
  PROCNAMEC()
  
  debugMsg(sProcName, #SCS_START)
  
  If IsWindow(#WID) = #False
    WID_Form_Load()
  EndIf
  
  setWindowModal(#WID, bModal)
  setWindowVisible(#WID, #True)
  SetActiveWindow(#WID)
EndProcedure

Procedure WID_btnImportDevs_Click()
  PROCNAMEC()
  Protected nRow
  Protected sMessage.s
  Protected nImportCount
  Protected sDevMap.s
  Protected nDevGrp, nDevNo, nDevPtr, nMaxDev
  Protected nNodeKey
  Protected nNewDevMapCount, sLastImportedDevMapName.s
  Protected sButtons.s, nOption, nListIndex
  
  debugMsg(sProcName, #SCS_START)
  
  For nRow = 1 To grWID\nMaxRowNo
    grWID\aRowInfo(nRow)\bImported = #False
  Next nRow
  
  debugMsg(sProcName, "calling WID_importDevs()")
  WID_importDevs()
  
  debugMsg(sProcName, "calling WID_importDevMaps()")
  WID_importDevMaps()
  
  ; debugMsg(sProcName, "calling listAllDevMapsForDevChgs()")
  ; listAllDevMapsForDevChgs()
  
  ; Added 27Jan2023
  For nDevGrp = #SCS_DEVGRP_FIRST To #SCS_DEVGRP_VERY_LAST
    nMaxDev = getMaxDevForDevGrp(@grProdForDevChgs, nDevGrp)
    ; debugMsg(sProcName, "getMaxDevForDevGrp(@grProdForDevChgs, " + decodeDevGrp(nDevGrp) + ") returned " + nMaxDev)
    For nDevNo = 0 To nMaxDev
      nDevPtr = getDevChgsDevPtrForDevNo(nDevGrp, nDevNo)
      ; debugMsg(sProcName, "getDevChgsDevPtrForDevNo(" + decodeDevGrp(nDevGrp) + ", " + nDevNo + ") returned " + nDevPtr)
      If nDevPtr >= 0
        debugMsg(sProcName, "calling setDevChgsPhysDevIfReqd(" + nDevPtr + ", " + nDevNo + ")")
        setDevChgsPhysDevIfReqd(nDevPtr, nDevNo)
      EndIf
    Next nDevNo
  Next nDevGrp
  ; End added 27Jan2023
  
  For nRow = 1 To grWID\nMaxRowNo
    With grWID\aRowInfo(nRow)
      If \bImported Or \bUpdated
        nImportCount + 1
        If nImportCount > 1
          sMessage + Chr(13)
        EndIf
        Select \nRowType
          Case #SCS_IMD_DEVICE
            Select \nDevGrp
              Case #SCS_DEVGRP_FIX_TYPE
                If \bImported
                  sMessage + LangPars("WID", "Imported", decodeDevGrpL(\nDevGrp), \sLogicalDev)
                Else
                  sMessage + LangPars("WID", "Updated", decodeDevGrpL(\nDevGrp), \sLogicalDev)
                EndIf
              Default
                If \bImported
                  sMessage + LangPars("WID", "ImportedDev", decodeDevGrpL(\nDevGrp), \sLogicalDev)
                Else
                  sMessage + LangPars("WID", "UpdatedDev", decodeDevGrpL(\nDevGrp), \sLogicalDev)
                EndIf
            EndSelect
            
          Case #SCS_IMD_DEVMAP
            If \bImported
              sMessage + LangPars("WID", "ImportedDevMap", \sDevMapName)
              nNewDevMapCount + 1
              sLastImportedDevMapName = \sDevMapName
            Else
              sMessage + LangPars("WID", "UpdatedDevMap", \sDevMapName)
            EndIf
        EndSelect
      EndIf
    EndWith
  Next nRow
  
  ; debugMsg(sProcName, "calling addMissingDevsToDevChgsDevMaps()")
  addMissingDevsToDevChgsDevMaps()
  
  ; debugMsg(sProcName, "calling removeMissingDevsFromDevChgsDevMaps()")
  removeMissingDevsFromDevChgsDevMaps()
  
  debugMsg(sProcName, "nImportCount=" + nImportCount + ", sMessage=" + ReplaceString(sMessage,Chr(13),"; "))
  If nImportCount > 0
    scsMessageRequester(Lang("WID","Completed"), sMessage)
    WID_Form_Unload()
    ; Added 3Oct2023 11.10.0cf
    If gbEditProdFormLoaded = #False
      displayProd()
    EndIf
    ; End added 3Oct2023 11.10.0cf
    If gbEditProdFormLoaded And IsGadget(WEP\cboDevMap)
      ; Changed 3Oct2023 11.10.0cf
      ; Reinstated 25Jan2024 11.10.2
      debugMsg(sProcName, "calling WEP_loadAndDisplayDevsForProd()")
      WEP_loadAndDisplayDevsForProd()
      debugMsg(sProcName, "calling WEP_setDevChgsBtns()")
      WEP_setDevChgsBtns()
      ; End reinstated 25Jan2024
      nNodeKey = GetGadgetItemData(WED\tvwProdTree, 0) ; 'item'=0, which is the first node, which is production properties
      debugMsg(sProcName, "calling WED_doNodeClick(" + nNodeKey + ")")
      WED_doNodeClick(nNodeKey)
      setGadgetItemByData(WEP\pnlProd, #SCS_PROD_TAB_DEVS)
      ; End changed 3Oct2023 11.10.0cf
      ; Added 26Jan2024 11.10.2
      If nNewDevMapCount > 0
        nListIndex = indexForComboBoxRow(WEP\cboDevMap, sLastImportedDevMapName)
        ; debugMsg(sProcName, "indexForComboBoxRow(WEP\cboDevMap, " + #DQUOTE$ + sLastImportedDevMapName + #DQUOTE$ + ") returned " + nListIndex)
        If nListIndex >= 0
          sMessage = Lang("WID", "Window") + "|" + LangPars("WID", "ChangeDevMap", sLastImportedDevMapName)
          sButtons = Lang("Common", "Yes") + "|" + Lang("Common", "No")
          nOption = OptionRequester(0, 0, sMessage, sButtons, 200, #IDI_QUESTION)
          debugMsg(sProcName, "nOption=" + nOption)
          Select (nOption & $FFFF)
            Case 1
              ; user clicked 'Yes'
              setComboBoxForText(WEP\cboDevMap, sLastImportedDevMapName)
              WEP_cboDevMap_Click()
          EndSelect
        EndIf
      EndIf
      ; End added 26Jan2024 11.10.2
    EndIf
    
  EndIf
  
  ; debugMsg(sProcName, "calling debugProd(@grProdForDevChgs)")
  ; debugProd(@grProdForDevChgs)
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WID_EventHandler()
  PROCNAMEC()
  Protected nRow, nCol
  
  With WID
    Select gnWindowEvent
        
      Case #PB_Event_CloseWindow
        WID_Form_Unload()
        
      Case #PB_Event_Menu
        gnEventMenu = EventMenu()
        debugMsg(sProcName, "gnEventMenu=" + decodeMenuItem(gnEventMenu))
        Select gnEventMenu
            
          Case #SCS_mnuKeyboardReturn   ; Return
            If getEnabled(\btnImportDevs)
              WID_btnImportDevs_Click()
            EndIf
            
          Case #SCS_mnuKeyboardEscape   ; Escape
            WID_Form_Unload()
            
        EndSelect
        
      Case #MyGrid_Event_Change
        If gnEventGadgetNoForEvHdlr = \grdDevs
          nRow = MyGrid_GetAttribute(\grdDevs, #MyGrid_Att_ChangedRow)
          nCol = MyGrid_GetAttribute(\grdDevs, #MyGrid_Att_ChangedCol)
          If nRow <= grWID\nMaxRowNo
            If grWID\aRowInfo(nRow)\nRowType = #SCS_IMD_DEVMAP Or grWID\aRowInfo(nRow)\nRowType = #SCS_IMD_DEVICE
              WID_refreshGrdDevs()
            EndIf
          EndIf
          WID_setButtons()
        EndIf

      Case #PB_Event_Gadget
        ;debugMsg(sProcName, "gnEventGadgetNo=G" + gnEventGadgetNo)
        Select gnEventGadgetNoForEvHdlr
            
          Case \btnBrowse
            WID_btnBrowse_Click()
            
          Case \btnCancel
            WID_Form_Unload()
            
          Case \btnClearAll
            WID_btnClearAll_Click()
            
          Case \btnFavorites
            WFS_setupFavFileSelectorForm(#WID, #False)
            WFS_Form_Show(#WID, #True, #SCS_MODRETURN_IMPORT_DEVS)
            
          Case \btnHelp
            displayHelpTopic("scs_import_devs.htm")
            
          Case \btnImportDevs
            WID_btnImportDevs_Click()
            
          Case \btnSelectAll
            WID_btnSelectAll_Click()
            
          Case \grdDevs
            MyGrid_ManageEvent(gnEventGadgetNo, gnEventType)
            
          Default
            debugMsg(sProcName, "gnEventGadgetNo=G" + gnEventGadgetNo + ", gnEventType=" + decodeEventType())
        EndSelect
        
      Case #PB_Event_SizeWindow
        WID_Form_Resized()
        
    EndSelect
  EndWith
  
EndProcedure

Procedure WID_load2ndCueFile()
  PROCNAMEC()
  
  debugMsg(sProcName, #SCS_START)
  
  open2ndSCSCueFile()
  If gb2ndXMLFormat
    WID_clearDevMapsForImport()
    readXMLCueFile(gn2ndCueFileNo, #False, gn2ndCueFileStringFormat, gs2ndCueFile)
  EndIf
  
  If gb2ndCueFileOpen
    close2ndSCSCueFile(gn2ndCueFileNo)
  EndIf
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WID_Form_Resized(bForceProcessing=#False)
  PROCNAMEC()
  Protected nWindowWidth, nWindowHeight
  Static nPrevWindowWidth, nPrevWindowHeight
  Protected nLeft, nTop, nWidth, nHeight
  
  If IsWindow(#WID) = #False
    ; appears this procedure can be called after the window has been closed
    ProcedureReturn
  EndIf
  
  With WID
    nWindowWidth = WindowWidth(#WID)
    nWindowHeight = WindowHeight(#WID)
    If (nWindowWidth <> nPrevWindowWidth) Or (nWindowHeight <> nPrevWindowHeight) Or (bForceProcessing)
      nPrevWindowWidth = nWindowWidth
      nPrevWindowHeight = nWindowHeight
      
      CompilerIf 1=2
        ; resize \grdAddCues
        nLeft = GadgetX(\grdAddCues)
        nWidth = nWindowWidth - (nLeft << 1)
        nTop = GadgetY(\grdAddCues)
        nHeight = nWindowHeight - nTop - GadgetHeight(\cntBelowGrid)
        ResizeGadget(\grdAddCues, #PB_Ignore, #PB_Ignore, nWidth, nHeight)
        autoFitGridCol(\grdAddCues, 2) ; autofit "Description" column
        
        ; reposition and resize \cntBelowGrid
        nTop = nWindowHeight - GadgetHeight(\cntBelowGrid)
        ResizeGadget(\cntBelowGrid, #PB_Ignore,nTop,nWindowWidth, #PB_Ignore)
      CompilerEndIf
    EndIf
  EndWith
  
EndProcedure

Procedure WID_listImportDevs()
  PROCNAMEC()
  Protected d
  Protected sLine.s
  
  For d = 0 To gnLastImportDev
    With gaImportDev(d)
      sLine = "gaImportDev(" + d + ")\nDevGrp=" + decodeDevGrp(\nDevGrp) + ", \nDevType=" + decodeDevType(\nDevType) +
              ", \b2ndUsedInCues=" + strB(\b2ndUsedInCues) +
              ", \s1stLogicalDev=" + \s1stLogicalDev +
              ", \s2ndLogicalDev=" + \s2ndLogicalDev +
              ", \s2ndCues=" + \s2ndCues
      debugMsg(sProcName, sLine)
    EndWith
  Next d
  
  For d = 0 To gnLastImportMidiDev
    With gaImportMidiDev(d)
      sLine = "gaImportMidiDev(" + d + ")\" + strB(\b2ndUsedInCues) +
              ", \s1stLogicalDev=" + \s1stLogicalDev +
              ", \s2ndLogicalDev=" + \s2ndLogicalDev +
              ", \s2ndCues=" + \s2ndCues
      debugMsg(sProcName, sLine)
    EndWith
  Next d

EndProcedure

Procedure WID_clearDevMapsForImport()
  PROCNAMEC()
  
  With grMapsForImport
    \nMaxMapIndex= -1
    \nMaxDevIndex = -1
    \nMaxLiveGrpIndex = -1
  EndWith
  
EndProcedure

Procedure WID_btnSelectAll_Click()
  PROCNAMEC()
  Protected nRow
  Protected nGrdDevs
  
  debugMsg(sProcName, #SCS_START)
  
  nGrdDevs = WID\grdDevs
  For nRow = 1 To grWID\nMaxRowNo
    With grWID\aRowInfo(nRow)
      Select \nRowType
        Case #SCS_IMD_DEVMAP, #SCS_IMD_DEVICE
          MyGrid_SetText(nGrdDevs, nRow, 1, "1")
      EndSelect
    EndWith
  Next nRow
  WID_refreshGrdDevs()
  ; MyGrid_Redraw(nGrdDevs)
  
  WID_setButtons()
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WID_btnClearAll_Click()
  PROCNAMEC()
  Protected nRow
  Protected nGrdDevs
  
  debugMsg(sProcName, #SCS_START)
  
  nGrdDevs = WID\grdDevs
  For nRow = 1 To grWID\nMaxRowNo
    With grWID\aRowInfo(nRow)
      Select \nRowType
        Case #SCS_IMD_DEVMAP, #SCS_IMD_DEVICE
          MyGrid_SetText(nGrdDevs, nRow, 1, "0")
      EndSelect
    EndWith
  Next nRow
  WID_refreshGrdDevs()
  ; MyGrid_Redraw(nGrdDevs)
  
  WID_setButtons()
  
  debugMsg(sProcName, #SCS_END)
  
  
EndProcedure

Procedure WID_refreshGrdDevs()
  PROCNAMEC()
  Protected nRow
  Protected nGrdDevs
  Protected nFirstSelectedDevMapPtr
  Protected sText.s
  Protected bRefreshThis
  Protected rRowInfo.tyWIDRowInfo
  Protected d
  Protected nDevMapDevPtr, sDevMapName.s
  Protected sShowingDevmap.s
  Protected nSelectedDevMaps, nSelectedDevs, sInfoMsg.s, sSamplePhysical.s, sSampleLogical.s
  Static sMono.s, sStereo.s, sChannels.s
  Static sShowing.s
  Static bStaticLoaded
  
  ; debugMsg(sProcName, #SCS_START)
  
  If bStaticLoaded = #False
    sMono = LCase(Lang("Common", "mono"))
    sStereo = LCase(Lang("Common", "stereo"))
    sChannels = LCase(Lang("Common", "channels"))
    sShowing = " (" + Lang("WID", "showing") + ")"
    bStaticLoaded = #True
  EndIf
  
  nGrdDevs = WID\grdDevs
  nFirstSelectedDevMapPtr = WID_getFirstSelectedDevMapPtr()
  If nFirstSelectedDevMapPtr >= 0
    sDevMapName = grMapsForImport\aMap(nFirstSelectedDevMapPtr)\sDevMapName
    sShowingDevmap = ReplaceString(sShowing, "$1", #DQUOTE$ + sDevMapName + #DQUOTE$)
  EndIf
  
  ; debugMsg(sProcName, "grWID\nMaxRowNo=" + grWID\nMaxRowNo + ", nFirstSelectedDevMapPtr=" + nFirstSelectedDevMapPtr)
  For nRow = 1 To grWID\nMaxRowNo
    rRowInfo = grWID\aRowInfo(nRow)
    ; debugMsg(sProcName, "nRow=" + nRow + ", rRowInfo\nRowType=" + rRowInfo\nRowType)
    Select rRowInfo\nRowType
      Case #SCS_IMD_HEADER
        Select rRowInfo\nDevGrp
          Case #SCS_DEVGRP_AUDIO_OUTPUT, #SCS_DEVGRP_LIVE_INPUT, #SCS_DEVGRP_VIDEO_AUDIO, #SCS_DEVGRP_VIDEO_CAPTURE
            sText = LangPars("WEP","tbsDevices", decodeDevGrpL(rRowInfo\nDevGrp)) + RTrim(sShowingDevmap)
            MyGrid_SetText(nGrdDevs, nRow, 1, sText)
            ; debugMsg(sProcName, "MyGrid_SetText(nGrdDevs, " + nRow + ", 1, " + sText + ")")
        EndSelect
        
      Case #SCS_IMD_DEVMAP
        If MyGrid_GetText(nGrdDevs, nRow, 1) = "1"
          nSelectedDevMaps + 1
        EndIf

      Case #SCS_IMD_DEVICE
        bRefreshThis = #False
        sText = ""
        Select rRowInfo\nDevGrp
          Case #SCS_DEVGRP_AUDIO_OUTPUT
            ;{
            d = grWID\aRowInfo(nRow)\nDevNo
            With gr2ndProd\aAudioLogicalDevs(d)
              sText = \sLogicalDev + " ("
              Select \nNrOfOutputChans
                Case 1
                  sText + sMono
                Case 2
                  sText + sStereo
                Default
                  sText + \nNrOfOutputChans + " " + sChannels
              EndSelect
              sText + ")"
              If nFirstSelectedDevMapPtr >= 0 Or sSampleLogical = ""
                nDevMapDevPtr = getDevMapDevPtrForLogicalDev(@grMapsForImport, #SCS_DEVGRP_AUDIO_OUTPUT, \sLogicalDev, nFirstSelectedDevMapPtr)
                If nDevMapDevPtr >= 0
                  If nFirstSelectedDevMapPtr >= 0
                    sText + ": " + grMapsForImport\aDev(nDevMapDevPtr)\sPhysicalDev
                    If grMapsForImport\aDev(nDevMapDevPtr)\s1BasedOutputRange
                      sText + ": " + grMapsForImport\aDev(nDevMapDevPtr)\s1BasedOutputRange
                    EndIf
                  ElseIf MyGrid_GetText(nGrdDevs, nRow, 1) = "1" ; sSampleLogical = ""
                    sSampleLogical = decodeDevGrpL(rRowInfo\nDevGrp) + " " + \sLogicalDev
                    sSamplePhysical = grMapsForImport\aDev(nDevMapDevPtr)\sPhysicalDev
                    If grMapsForImport\aDev(nDevMapDevPtr)\s1BasedOutputRange
                      sSamplePhysical + ": " + grMapsForImport\aDev(nDevMapDevPtr)\s1BasedOutputRange
                    EndIf
                  EndIf
                EndIf
              EndIf
              bRefreshThis = #True
            EndWith
            ;}
          Case #SCS_DEVGRP_VIDEO_AUDIO
            ;{
            d = grWID\aRowInfo(nRow)\nDevNo
            With gr2ndProd\aVidAudLogicalDevs(d)
              sText = \sVidAudLogicalDev
              If nFirstSelectedDevMapPtr >= 0 Or sSampleLogical = ""
                nDevMapDevPtr = getDevMapDevPtrForLogicalDev(@grMapsForImport, #SCS_DEVGRP_VIDEO_AUDIO, \sVidAudLogicalDev, nFirstSelectedDevMapPtr)
                If nDevMapDevPtr >= 0
                  If nFirstSelectedDevMapPtr >= 0
                    sText + ": " + grMapsForImport\aDev(nDevMapDevPtr)\sPhysicalDev
                    If grMapsForImport\aDev(nDevMapDevPtr)\s1BasedOutputRange
                      sText + ": " + grMapsForImport\aDev(nDevMapDevPtr)\s1BasedOutputRange
                    EndIf
                  ElseIf MyGrid_GetText(nGrdDevs, nRow, 1) = "1" ; sSampleLogical = ""
                    sSampleLogical = decodeDevGrpL(rRowInfo\nDevGrp) + " " + \sVidAudLogicalDev
                    sSamplePhysical = grMapsForImport\aDev(nDevMapDevPtr)\sPhysicalDev
                    If grMapsForImport\aDev(nDevMapDevPtr)\s1BasedOutputRange
                      sSamplePhysical + ": " + grMapsForImport\aDev(nDevMapDevPtr)\s1BasedOutputRange
                    EndIf
                  EndIf
                EndIf
              EndIf
              bRefreshThis = #True
            EndWith
            ;}
          Case #SCS_DEVGRP_VIDEO_CAPTURE
            ;{
            d = grWID\aRowInfo(nRow)\nDevNo
            With gr2ndProd\aVidCapLogicalDevs(d)
              sText = \sLogicalDev
              If nFirstSelectedDevMapPtr >= 0 Or sSampleLogical = ""
                nDevMapDevPtr = getDevMapDevPtrForLogicalDev(@grMapsForImport, #SCS_DEVGRP_VIDEO_CAPTURE, \sLogicalDev, nFirstSelectedDevMapPtr)
                If nDevMapDevPtr >= 0
                  If nFirstSelectedDevMapPtr >= 0
                    sText + ": " + grMapsForImport\aDev(nDevMapDevPtr)\sPhysicalDev
                  ElseIf MyGrid_GetText(nGrdDevs, nRow, 1) = "1" ; sSampleLogical = ""
                    sSampleLogical = decodeDevGrpL(rRowInfo\nDevGrp) + " " + \sLogicalDev
                    sSamplePhysical = grMapsForImport\aDev(nDevMapDevPtr)\sPhysicalDev
                  EndIf
                EndIf
              EndIf
              bRefreshThis = #True
            EndWith
            ;}
          Case #SCS_DEVGRP_FIX_TYPE
            ;{
            d = grWID\aRowInfo(nRow)\nDevNo
            With gr2ndProd\aFixTypes(d)
              sText = \sFixTypeName
              If nFirstSelectedDevMapPtr >= 0
                nDevMapDevPtr = getDevMapDevPtrForLogicalDev(@grMapsForImport, #SCS_DEVGRP_FIX_TYPE, \sFixTypeName, nFirstSelectedDevMapPtr)
              EndIf
              bRefreshThis = #True
            EndWith
            ;}
          Case #SCS_DEVGRP_LIGHTING
            ;{
            d = grWID\aRowInfo(nRow)\nDevNo
            With gr2ndProd\aLightingLogicalDevs(d)
              sText = \sLogicalDev + ": " + decodeDevTypeL(\nDevType)
              If nFirstSelectedDevMapPtr >= 0 Or sSampleLogical = ""
                nDevMapDevPtr = getDevMapDevPtrForLogicalDev(@grMapsForImport, #SCS_DEVGRP_LIGHTING, \sLogicalDev, nFirstSelectedDevMapPtr)
                If nDevMapDevPtr >= 0
                  If nFirstSelectedDevMapPtr >= 0
                    sText + ": " + grMapsForImport\aDev(nDevMapDevPtr)\sPhysicalDev
                  ElseIf MyGrid_GetText(nGrdDevs, nRow, 1) = "1" ; sSampleLogical = ""
                    sSampleLogical = decodeDevGrpL(rRowInfo\nDevGrp) + " " + \sLogicalDev
                    sSamplePhysical = grMapsForImport\aDev(nDevMapDevPtr)\sPhysicalDev
                  EndIf
                EndIf
              EndIf
              bRefreshThis = #True
            EndWith
            ;}
          Case #SCS_DEVGRP_CTRL_SEND
            ;{
            d = grWID\aRowInfo(nRow)\nDevNo
            With gr2ndProd\aCtrlSendLogicalDevs(d)
              sText = \sLogicalDev + ": " + decodeDevTypeL(\nDevType)
              If nFirstSelectedDevMapPtr >= 0 Or sSampleLogical = ""
                nDevMapDevPtr = getDevMapDevPtrForLogicalDev(@grMapsForImport, #SCS_DEVGRP_CTRL_SEND, \sLogicalDev, nFirstSelectedDevMapPtr)
                If nDevMapDevPtr >= 0
                  If nFirstSelectedDevMapPtr >= 0
                    If grMapsForImport\aDev(nDevMapDevPtr)\sPhysicalDev
                      sText + ": " + grMapsForImport\aDev(nDevMapDevPtr)\sPhysicalDev
                    Else
                      If \nCtrlNetworkRemoteDev <> #SCS_CS_NETWORK_REM_ANY
                        sText + ": " + decodeCtrlNetworkRemoteDevL(\nCtrlNetworkRemoteDev)
                      Else
                        Select \nDevType
                          Case #SCS_DEVTYPE_CS_NETWORK_OUT
                            Select \nNetworkRole
                              Case #SCS_NETWORK_ROLE_SCS_IS_A_CLIENT
                                sText + ": " + grMapsForImport\aDev(nDevMapDevPtr)\sRemoteHost + ":" + grMapsForImport\aDev(nDevMapDevPtr)\nRemotePort
                              Case #SCS_NETWORK_ROLE_SCS_IS_A_SERVER
                                sText + ": " + grMapsForImport\aDev(nDevMapDevPtr)\nLocalPort
                            EndSelect
                        EndSelect
                      EndIf
                    EndIf
                  ElseIf MyGrid_GetText(nGrdDevs, nRow, 1) = "1" ; sSampleLogical = ""
                    sSampleLogical = decodeDevGrpL(rRowInfo\nDevGrp) + " " + \sLogicalDev
                    sSamplePhysical = grMapsForImport\aDev(nDevMapDevPtr)\sPhysicalDev
                  EndIf
                EndIf
              EndIf
              bRefreshThis = #True
            EndWith
            ;}
          Case #SCS_DEVGRP_CUE_CTRL
            ;{
            d = grWID\aRowInfo(nRow)\nDevNo
            With gr2ndProd\aCueCtrlLogicalDevs(d)
              sText = \sCueCtrlLogicalDev + ": " + decodeDevTypeL(\nDevType)
              If nFirstSelectedDevMapPtr >= 0 Or sSampleLogical = ""
                nDevMapDevPtr = getDevMapDevPtrForLogicalDev(@grMapsForImport, #SCS_DEVGRP_CUE_CTRL, \sCueCtrlLogicalDev, nFirstSelectedDevMapPtr)
                If nDevMapDevPtr >= 0
                  If nFirstSelectedDevMapPtr >= 0
                    If grMapsForImport\aDev(nDevMapDevPtr)\sPhysicalDev
                      sText + ": " + grMapsForImport\aDev(nDevMapDevPtr)\sPhysicalDev
                    Else
                      If \nCueNetworkRemoteDev <> #SCS_CC_NETWORK_REM_ANY
                        sText + ": " + decodeCueNetworkRemoteDevL(\nCueNetworkRemoteDev)
                      Else
                        Select \nDevType
                          Case #SCS_DEVTYPE_CC_NETWORK_IN
                            Select \nNetworkRole
                              Case #SCS_NETWORK_ROLE_SCS_IS_A_CLIENT
                                sText + ": " + grMapsForImport\aDev(nDevMapDevPtr)\sRemoteHost + ":" + grMapsForImport\aDev(nDevMapDevPtr)\nRemotePort
                              Case #SCS_NETWORK_ROLE_SCS_IS_A_SERVER
                                sText + ": " + grMapsForImport\aDev(nDevMapDevPtr)\nLocalPort
                            EndSelect
                        EndSelect
                      EndIf
                    EndIf
                  ElseIf MyGrid_GetText(nGrdDevs, nRow, 1) = "1" ; sSampleLogical = ""
                    sSampleLogical = decodeDevGrpL(rRowInfo\nDevGrp) + " " + \sCueCtrlLogicalDev
                    sSamplePhysical = grMapsForImport\aDev(nDevMapDevPtr)\sPhysicalDev
                  EndIf
                EndIf
              EndIf
              bRefreshThis = #True
            EndWith
            ;}
          Case #SCS_DEVGRP_LIVE_INPUT
            ;{
            d = grWID\aRowInfo(nRow)\nDevNo
            With gr2ndProd\aLiveInputLogicalDevs(d)
              sText = \sLogicalDev + " ("
              Select \nNrOfInputChans
                Case 1
                  sText + sMono
                Case 2
                  sText + sStereo
                Default
                  sText + \nNrOfInputChans + " " + sChannels
              EndSelect
              sText + ")"
              If nFirstSelectedDevMapPtr >= 0 Or sSampleLogical = ""
                nDevMapDevPtr = getDevMapDevPtrForLogicalDev(@grMapsForImport, #SCS_DEVGRP_LIVE_INPUT, \sLogicalDev, nFirstSelectedDevMapPtr)
                If nDevMapDevPtr >= 0
                  If nFirstSelectedDevMapPtr >= 0
                    sText + ": " + grMapsForImport\aDev(nDevMapDevPtr)\sPhysicalDev
                    If grMapsForImport\aDev(nDevMapDevPtr)\s1BasedInputRange
                      sText + ": " + grMapsForImport\aDev(nDevMapDevPtr)\s1BasedInputRange
                    EndIf
                  ElseIf MyGrid_GetText(nGrdDevs, nRow, 1) = "1" ; sSampleLogical = ""
                    sSampleLogical = decodeDevGrpL(rRowInfo\nDevGrp) + " " + \sLogicalDev
                    sSamplePhysical = grMapsForImport\aDev(nDevMapDevPtr)\sPhysicalDev
                  EndIf
                EndIf
              EndIf
              bRefreshThis = #True
            EndWith
            ;}
          Case #SCS_DEVGRP_IN_GRP
            ;{
            d = grWID\aRowInfo(nRow)\nDevNo
            With gr2ndProd\aInGrps(d)
              sText = \sInGrpName
              If nFirstSelectedDevMapPtr >= 0
                nDevMapDevPtr = getDevMapDevPtrForLogicalDev(@grMapsForImport, #SCS_DEVGRP_IN_GRP, \sInGrpName, nFirstSelectedDevMapPtr)
              EndIf
              bRefreshThis = #True
            EndWith
            ;}
        EndSelect
        If bRefreshThis
          MyGrid_SetText(nGrdDevs, nRow, 2, sText)
          ; debugMsg(sProcName, "MyGrid_SetText(nGrdDevs), " + nRow + ", 2, " + sText + ")")
        EndIf
        If MyGrid_GetText(nGrdDevs, nRow, 1) = "1"
          Select rRowInfo\nDevGrp
            Case #SCS_DEVGRP_FIX_TYPE, #SCS_DEVGRP_IN_GRP
              ; these device groups have no details stored in device maps, so ignore them for this count
            Default
              nSelectedDevs + 1
          EndSelect
        EndIf
    EndSelect
  Next nRow
  MyGrid_Redraw(nGrdDevs)
  
  If nSelectedDevMaps = 0 And nSelectedDevs > 0
    SGT(WID\lblInfoMsg, LangPars("WID", "InfoMsg", sSampleLogical, sSamplePhysical))
  Else
    SGT(WID\lblInfoMsg, "")
  EndIf
  
  ; debugMsg0(sProcName, "nSelectedDevMaps=" + nSelectedDevMaps + ", nSelectedDevs=" + nSelectedDevs)
  ; debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WID_clearAllDevsAndDevMaps()
  PROCNAMEC()
  Protected n ; used by macro INIT_ARRAY()
  
  With grProdForDevChgs
    INIT_ARRAY(\aAudioLogicalDevs, grAudioLogicalDevsDef)
    INIT_ARRAY(\aVidAudLogicalDevs, grVidAudLogicalDevsDef)
    INIT_ARRAY(\aVidCapLogicalDevs, grVidCapLogicalDevsDef)
    INIT_ARRAY(\aLiveInputLogicalDevs, grLiveInputLogicalDevsDef)
    INIT_ARRAY(\aInGrps, grInGrpsDef)
    INIT_ARRAY(\aFixTypes, grFixTypesDef)
    INIT_ARRAY(\aLightingLogicalDevs, grLightingLogicalDevsDef)
    INIT_ARRAY(\aCtrlSendLogicalDevs, grCtrlSendLogicalDevsDef)
    INIT_ARRAY(\aCueCtrlLogicalDevs, grCueCtrlLogicalDevsDef)
  EndWith
  
EndProcedure

Procedure WID_importDevs()
  PROCNAMEC()
  Protected nGrdDevs
  Protected nRow
  Protected sText.s
  Protected nNewDevNo
  Protected nHoldDevId
  Protected d1, d2
  Protected nDevMapForImportPtr
  Protected nDevMapPtr = -1
  Protected nAudDevPtr = -1
  Protected bReplaceExisting
  Protected sLine.s, n
  Protected nDevPtr
  Protected sMsg.s
  
  debugMsg(sProcName, #SCS_START)
  
  nGrdDevs = WID\grdDevs
  
  debugMsg(sProcName, "grWID\nMaxRowNo=" + grWID\nMaxRowNo)
  For nRow = 1 To grWID\nMaxRowNo
    bReplaceExisting = #False
    With grWID\aRowInfo(nRow)
      debugMsg(sProcName, "grWID\aRowInfo(" + nRow + ")\nRowType=" + \nRowType + ", \nDevGrp=" + decodeDevGrp(\nDevGrp) + ", \sLogicalDev=" + \sLogicalDev)
      Select \nRowType
        Case #SCS_IMD_DEVICE
          sText = MyGrid_GetText(nGrdDevs, nRow, 1)
          ; debugMsg(sProcName, "grWID\aRowInfo(" + nRow + ")\nRowType=#SCS_IMD_DEVICE, sText(selected)=" + sText + ", \nDevGrp=" + decodeDevGrp(\nDevGrp) + ", \sLogicalDev=" + \sLogicalDev)
          If (sText = "1") And (\sLogicalDev)
            nNewDevNo = getDevNoForLogicalDev(@grProdForDevChgs, \nDevGrp, \sLogicalDev)
            If nNewDevNo >= 0
              bReplaceExisting = #True
            Else
              nNewDevNo = getDevNoForFreeDev(@grProdForDevChgs, \nDevGrp)
            EndIf
            If nNewDevNo < 0
              ; no free slot available
              Continue
            EndIf
            
            Select \nDevGrp
              Case #SCS_DEVGRP_AUDIO_OUTPUT
                ;{
                If bReplaceExisting
                  If grProdForDevChgs\aAudioLogicalDevs(nNewDevNo)\nChannelCount = gr2ndProd\aAudioLogicalDevs(\nDevNo)\nChannelCount
                    nHoldDevId = grProdForDevChgs\aAudioLogicalDevs(nNewDevNo)\nDevId
                    grProdForDevChgs\aAudioLogicalDevs(nNewDevNo) = gr2ndProd\aAudioLogicalDevs(\nDevNo)
                    grProdForDevChgs\aAudioLogicalDevs(nNewDevNo)\nDevId = nHoldDevId
                    \bUpdated = #True
                    debugMsg(sProcName, "(update) grProdForDevChgs\aAudioLogicalDevs(" + nNewDevNo + ")\sLogicalDev=" + grProdForDevChgs\aAudioLogicalDevs(nNewDevNo)\sLogicalDev +
                                        ", \nDevId=" + grProdForDevChgs\aAudioLogicalDevs(nNewDevNo)\nDevId)
                  EndIf
                Else
                  grProdForDevChgs\aAudioLogicalDevs(nNewDevNo) = gr2ndProd\aAudioLogicalDevs(\nDevNo)
                  \bImported = #True
                  debugMsg(sProcName, "(import) grProdForDevChgs\aAudioLogicalDevs(" + nNewDevNo + ")\sLogicalDev=" + grProdForDevChgs\aAudioLogicalDevs(nNewDevNo)\sLogicalDev +
                                      ", \nDevId=" + grProdForDevChgs\aAudioLogicalDevs(nNewDevNo)\nDevId)
                EndIf
                ;}
              Case #SCS_DEVGRP_VIDEO_AUDIO
                ;{
                If bReplaceExisting
                  nHoldDevId = grProdForDevChgs\aVidAudLogicalDevs(nNewDevNo)\nDevId
                  grProdForDevChgs\aVidAudLogicalDevs(nNewDevNo) = gr2ndProd\aVidAudLogicalDevs(\nDevNo)
                  grProdForDevChgs\aVidAudLogicalDevs(nNewDevNo)\nDevId = nHoldDevId
                  \bUpdated = #True
                Else
                  grProdForDevChgs\aVidAudLogicalDevs(nNewDevNo) = gr2ndProd\aVidAudLogicalDevs(\nDevNo)
                  \bImported = #True
                  debugMsg(sProcName, "grProdForDevChgs\aVidAudLogicalDevs(" + nNewDevNo + ")\sVidAudLogicalDev=" + grProdForDevChgs\aVidAudLogicalDevs(nNewDevNo)\sVidAudLogicalDev +
                                      ", \nDevId=" + grProdForDevChgs\aVidAudLogicalDevs(nNewDevNo)\nDevId)
                EndIf
                ;}
              Case #SCS_DEVGRP_VIDEO_CAPTURE
                ;{
                If bReplaceExisting
                  nHoldDevId = grProdForDevChgs\aVidCapLogicalDevs(nNewDevNo)\nDevId
                  grProdForDevChgs\aVidCapLogicalDevs(nNewDevNo) = gr2ndProd\aVidCapLogicalDevs(\nDevNo)
                  grProdForDevChgs\aVidCapLogicalDevs(nNewDevNo)\nDevId = nHoldDevId
                  \bUpdated = #True
                Else
                  grProdForDevChgs\aVidCapLogicalDevs(nNewDevNo) = gr2ndProd\aVidCapLogicalDevs(\nDevNo)
                  \bImported = #True
                  debugMsg(sProcName, "grProdForDevChgs\aVidCapLogicalDevs(" + nNewDevNo + ")\sLogicalDev=" + grProdForDevChgs\aVidCapLogicalDevs(nNewDevNo)\sLogicalDev +
                                      ", \nDevId=" + grProdForDevChgs\aVidCapLogicalDevs(nNewDevNo)\nDevId)
                EndIf
                ;}
              Case #SCS_DEVGRP_FIX_TYPE
                ;{
                If bReplaceExisting
                  nHoldDevId = grProdForDevChgs\aFixTypes(nNewDevNo)\nFixTypeId
                  grProdForDevChgs\aFixTypes(nNewDevNo) = gr2ndProd\aFixTypes(\nDevNo)
                  grProdForDevChgs\aFixTypes(nNewDevNo)\nFixTypeId = nHoldDevId
                  \bUpdated = #True
                Else
                  grProdForDevChgs\aFixTypes(nNewDevNo) = gr2ndProd\aFixTypes(\nDevNo)
                  \bImported = #True
                EndIf
                grProdForDevChgs\nMaxFixType = -1
                For n = 0 To ArraySize(grProdForDevChgs\aFixTypes())
                  If grProdForDevChgs\aFixTypes(n)\sFixTypeName
                    grProdForDevChgs\nMaxFixType = n
                  EndIf
                Next n
                debugMsg(sProcName, "grProdForDevChgs\aFixTypes(" + nNewDevNo + ")\sFixTypeName=" + grProdForDevChgs\aFixTypes(nNewDevNo)\sFixTypeName  + ", \nMaxFixType=" + grProdForDevChgs\nMaxFixType +
                                    ", \bImported=" + strB(\bImported) + ", \bUpdated=" + strB(\bUpdated))
                ;}
              Case #SCS_DEVGRP_LIGHTING
                ;{
                ; debugMsg(sProcName, "grProdForDevChgs\aLightingLogicalDevs(" + nNewDevNo + ")\nMaxFixture=" + grProdForDevChgs\aLightingLogicalDevs(nNewDevNo)\nMaxFixture + ", gr2ndProd\aLightingLogicalDevs(" + \nDevNo + ")\nMaxFixture=" + gr2ndProd\aLightingLogicalDevs(\nDevNo)\nMaxFixture)
                If bReplaceExisting And grProdForDevChgs\aLightingLogicalDevs(nNewDevNo)\nMaxFixture >= 0 ; Added nMaxFixture test 10Jan2025 11.10.6-b03 following attempt at MTG to copy fixtures into a cue file that had a lighting device but as yet no fixture.
                  If grProdForDevChgs\aLightingLogicalDevs(nNewDevNo)\nMaxFixture = gr2ndProd\aLightingLogicalDevs(\nDevNo)\nMaxFixture
                    nHoldDevId = grProdForDevChgs\aLightingLogicalDevs(nNewDevNo)\nDevId
                    grProdForDevChgs\aLightingLogicalDevs(nNewDevNo) = gr2ndProd\aLightingLogicalDevs(\nDevNo)
                    grProdForDevChgs\aLightingLogicalDevs(nNewDevNo)\nDevId = nHoldDevId
                    \bUpdated = #True
                  ElseIf gr2ndProd\aLightingLogicalDevs(\nDevNo)\nMaxFixture >= 0
                    sMsg + LangPars("WID", "CannotImportFixtures", grProdForDevChgs\aLightingLogicalDevs(nNewDevNo)\sLogicalDev) + Chr(13)
                  EndIf
                Else
                  grProdForDevChgs\aLightingLogicalDevs(nNewDevNo) = gr2ndProd\aLightingLogicalDevs(\nDevNo)
                  \bImported = #True
                EndIf
                debugMsg(sProcName, "grProdForDevChgs\aLightingLogicalDevs(" + nNewDevNo + ")\sLogicalDev=" + grProdForDevChgs\aLightingLogicalDevs(nNewDevNo)\sLogicalDev + ", \bImported=" + strB(\bImported) + ", \bUpdated=" + strB(\bUpdated))
                For n = 0 To grProdForDevChgs\aLightingLogicalDevs(nNewDevNo)\nMaxFixture
                  debugMsg(sProcName, "grProdForDevChgs\aLightingLogicalDevs(" + nNewDevNo + ")\aFixture(" + n + ")\sFixtureCode=" + grProdForDevChgs\aLightingLogicalDevs(nNewDevNo)\aFixture(n)\sFixtureCode +
                                      ", \sFixTypeName=" + grProdForDevChgs\aLightingLogicalDevs(nNewDevNo)\aFixture(n)\sFixTypeName +
                                      ", \nDefaultDMXStartChannel=" + grProdForDevChgs\aLightingLogicalDevs(nNewDevNo)\aFixture(n)\nDefaultDMXStartChannel)
                Next n
                ;}
              Case #SCS_DEVGRP_CTRL_SEND
                ;{
                If bReplaceExisting
                  If grProdForDevChgs\aCtrlSendLogicalDevs(nNewDevNo)\nDevType = gr2ndProd\aCtrlSendLogicalDevs(\nDevNo)\nDevType
                    nHoldDevId = grProdForDevChgs\aCtrlSendLogicalDevs(nNewDevNo)\nDevId
                    grProdForDevChgs\aCtrlSendLogicalDevs(nNewDevNo) = gr2ndProd\aCtrlSendLogicalDevs(\nDevNo)
                    grProdForDevChgs\aCtrlSendLogicalDevs(nNewDevNo)\nDevId = nHoldDevId
                    \bUpdated = #True
                  EndIf
                Else
                  grProdForDevChgs\aCtrlSendLogicalDevs(nNewDevNo) = gr2ndProd\aCtrlSendLogicalDevs(\nDevNo)
                  \bImported = #True
                  debugMsg(sProcName, "grProdForDevChgs\aCtrlSendLogicalDevs(" + nNewDevNo + ")\sLogicalDev=" + grProdForDevChgs\aCtrlSendLogicalDevs(nNewDevNo)\sLogicalDev +
                                      ", \nDevId=" + grProdForDevChgs\aCtrlSendLogicalDevs(nNewDevNo)\nDevId)
                  debugMsg(sProcName, "ArraySize(grProdForDevChgs\aCtrlSendLogicalDevs())=" + ArraySize(grProdForDevChgs\aCtrlSendLogicalDevs()) + ", grProdForDevChgs\nMaxCtrlSendLogicalDev=" + grProdForDevChgs\nMaxCtrlSendLogicalDev + ", nNewDevNo=" + nNewDevNo)
                EndIf
                ;}
              Case #SCS_DEVGRP_CUE_CTRL
                ;{
                debugMsg(sProcName, "bReplaceExisting=" + strB(bReplaceExisting))
                If bReplaceExisting
                  If grProdForDevChgs\aCueCtrlLogicalDevs(nNewDevNo)\nDevType = #SCS_DEVTYPE_NONE
                    grProdForDevChgs\aCueCtrlLogicalDevs(nNewDevNo) = gr2ndProd\aCueCtrlLogicalDevs(\nDevNo)
                    \bImported = #True
                    debugMsg(sProcName, "grProdForDevChgs\aCueCtrlLogicalDevs(" + nNewDevNo + ")\sCueCtrlLogicalDev=" + grProdForDevChgs\aCueCtrlLogicalDevs(nNewDevNo)\sCueCtrlLogicalDev +
                                        ", \nDevId=" + grProdForDevChgs\aCueCtrlLogicalDevs(nNewDevNo)\nDevId +
                                        ", \nDevType=" + decodeDevType(grProdForDevChgs\aCueCtrlLogicalDevs(nNewDevNo)\nDevType))
                  ElseIf grProdForDevChgs\aCueCtrlLogicalDevs(nNewDevNo)\nDevType = gr2ndProd\aCueCtrlLogicalDevs(\nDevNo)\nDevType
                    nHoldDevId = grProdForDevChgs\aCueCtrlLogicalDevs(nNewDevNo)\nDevId
                    grProdForDevChgs\aCueCtrlLogicalDevs(nNewDevNo) = gr2ndProd\aCueCtrlLogicalDevs(\nDevNo)
                    grProdForDevChgs\aCueCtrlLogicalDevs(nNewDevNo)\nDevId = nHoldDevId
                    \bUpdated = #True
                  EndIf
                Else
                  grProdForDevChgs\aCueCtrlLogicalDevs(nNewDevNo) = gr2ndProd\aCueCtrlLogicalDevs(\nDevNo)
                  \bImported = #True
                  debugMsg(sProcName, "grProdForDevChgs\aCueCtrlLogicalDevs(" + nNewDevNo + ")\sCueCtrlLogicalDev=" + grProdForDevChgs\aCueCtrlLogicalDevs(nNewDevNo)\sCueCtrlLogicalDev +
                                      ", \nDevId=" + grProdForDevChgs\aCueCtrlLogicalDevs(nNewDevNo)\nDevId +
                                      ", \nDevType=" + decodeDevType(grProdForDevChgs\aCueCtrlLogicalDevs(nNewDevNo)\nDevType))
                EndIf
                ;}
              Case #SCS_DEVGRP_LIVE_INPUT
                ;{
                If bReplaceExisting
                  If grProdForDevChgs\aLiveInputLogicalDevs(nNewDevNo)\nNrOfInputChans = gr2ndProd\aLiveInputLogicalDevs(\nDevNo)\nNrOfInputChans
                    nHoldDevId = grProdForDevChgs\aLiveInputLogicalDevs(nNewDevNo)\nDevId
                    grProdForDevChgs\aLiveInputLogicalDevs(nNewDevNo) = gr2ndProd\aLiveInputLogicalDevs(\nDevNo)
                    grProdForDevChgs\aLiveInputLogicalDevs(nNewDevNo)\nDevId = nHoldDevId
                    \bUpdated = #True
                  EndIf
                Else
                  grProdForDevChgs\aLiveInputLogicalDevs(nNewDevNo) = gr2ndProd\aLiveInputLogicalDevs(\nDevNo)
                  \bImported = #True
                EndIf
                ;}
              Case #SCS_DEVGRP_IN_GRP
                ;{
                If bReplaceExisting
                  nHoldDevId = grProdForDevChgs\aInGrps(nNewDevNo)\nInGrpId
                  grProdForDevChgs\aInGrps(nNewDevNo) = gr2ndProd\aInGrps(\nDevNo)
                  grProdForDevChgs\aInGrps(nNewDevNo)\nInGrpId = nHoldDevId
                  \bUpdated = #True
                Else
                  grProdForDevChgs\aInGrps(nNewDevNo) = gr2ndProd\aInGrps(\nDevNo)
                  \bImported = #True
                EndIf
                ;}
              Default
                debugMsg(sProcName, "not processed: \nDevGrp=" + decodeDevGrp(\nDevGrp))
            EndSelect
            If \bImported
              debugMsg(sProcName, "imported " + decodeDevGrp(\nDevGrp) + ", " + \sLogicalDev + ", nNewDevNo=" + nNewDevNo)
            ElseIf \bUpdated
              debugMsg(sProcName, "updated " + decodeDevGrp(\nDevGrp) + ", " + \sLogicalDev + ", nNewDevNo=" + nNewDevNo)
            EndIf
            
            nDevPtr = getDevChgsDevPtrForDevNo(\nDevGrp, nNewDevNo)
            debugMsg(sProcName, "getDevChgsDevPtrForDevNo(" + decodeDevGrp(\nDevGrp) + ", " + nNewDevNo + ") returned " + nDevPtr)
            If nDevPtr >= 0
              debugMsg(sProcName, "calling setDevChgsPhysDevIfReqd(" + nDevPtr + ", " + nNewDevNo + ")")
              setDevChgsPhysDevIfReqd(nDevPtr, nNewDevNo)
            EndIf
        
          EndIf
          
      EndSelect
    EndWith
  Next nRow
  
  If sMsg
    scsMessageRequester(GetWindowTitle(#WID), sMsg)
  EndIf
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WID_importDevMapDevs(nDevMapPtr, nImportDevMapPtr, nGrpTypes=0)
  PROCNAMEC()
  Protected nDevPtr, nImportDevPtr
  Protected rHoldDev.tyDevMapDev
  Protected nDevMapId
  Protected nNewDevMapDevPtr, nThisDevPtr
  Protected bWantThis
  Protected nDevId
  Protected n
  
  debugMsg(sProcName, #SCS_START + ", nDevMapPtr=" + nDevMapPtr + ", nImportDevMapPtr=" + nImportDevMapPtr + ", (" + getDevMapForImportName(nImportDevMapPtr) + "), nGrpTypes=" + nGrpTypes)
  
  CheckSubInRange(nImportDevMapPtr, ArraySize(grMapsForImport\aMap()), "grMapsForImport\aMap()")
  
  CheckSubInRange(nDevMapPtr, ArraySize(grMapsForDevChgs\aMap()), "grMapsForDevChgs\aMap()")
  debugMsg(sProcName, "grMapsForDevChgs\aMap(" + nDevMapPtr + ")\nDevMapId=" + grMapsForDevChgs\aMap(nDevMapPtr)\nDevMapId)
  nDevMapId = grMapsForDevChgs\aMap(nDevMapPtr)\nDevMapId
  
  ; listAllDevMapsForImport() ; TEMP !!!!!!!
  
  nImportDevPtr = grMapsForImport\aMap(nImportDevMapPtr)\nFirstDevIndex
  While nImportDevPtr >= 0
    debugMsg(sProcName, "nImportDevPtr=" + nImportDevPtr)
    CheckSubInRange(nImportDevPtr, ArraySize(grMapsForImport\aDev()), "grMapsForImport\aDev()")
    With grMapsForImport\aDev(nImportDevPtr)
      debugMsg(sProcName, ">>> grMapsForImport\aDev(" + nImportDevPtr + ")\nDevGrp=" + decodeDevGrp(\nDevGrp) + ", \nDevType=" + decodeDevType(\nDevType) + ", \sPhysicalDev=" + \sPhysicalDev)
      bWantThis = #False
      Select nGrpTypes
        Case 0  ; all device groups
          Select \nDevGrp
            Case #SCS_DEVGRP_AUDIO_OUTPUT, #SCS_DEVGRP_LIVE_INPUT, #SCS_DEVGRP_IN_GRP, #SCS_DEVGRP_VIDEO_AUDIO, #SCS_DEVGRP_VIDEO_CAPTURE, #SCS_DEVGRP_CTRL_SEND, #SCS_DEVGRP_CUE_CTRL, #SCS_DEVGRP_LIGHTING, #SCS_DEVGRP_FIX_TYPE
              bWantThis = #True
          EndSelect
        Case 1  ; non-control device groups
          Select \nDevGrp
            Case #SCS_DEVGRP_AUDIO_OUTPUT, #SCS_DEVGRP_LIVE_INPUT, #SCS_DEVGRP_IN_GRP, #SCS_DEVGRP_VIDEO_AUDIO, #SCS_DEVGRP_VIDEO_CAPTURE, #SCS_DEVGRP_FIX_TYPE, #SCS_DEVGRP_LIGHTING ; Added #SCS_DEVGRP_LIGHTING 14Mar2022 11.9.1am
              bWantThis = #True
          EndSelect
      EndSelect
      
      debugMsg(sProcName, "grMapsForImport\aDev(" + nImportDevPtr + ")\nDevGrp=" + decodeDevGrp(\nDevGrp) + ", \nDevType=" + decodeDevType(\nDevType) + ", bWantThis=" + strB(bWantThis))
      If bWantThis
        nThisDevPtr = -1
        nDevPtr = getDevMapDevPtrForLogicalDev(@grMapsForDevChgs, \nDevGrp, \sLogicalDev, nDevMapPtr)
        ;debugMsg(sProcName, "getDevMapDevPtrForLogicalDev(@grMapsForDevChgs, " + decodeDevGrp(\nDevGrp) + ", " + \sLogicalDev + ", " + nDevMapPtr + ") returned nDevPtr=" + nDevPtr)
        If nDevPtr >= 0
          If (grMapsForDevChgs\aDev(nDevPtr)\nDevType = \nDevType) Or (grMapsForDevChgs\aDev(nDevPtr)\nDevType = #SCS_DEVTYPE_NONE)
            debugMsg(sProcName, "replacing \nDevGrp=" + decodeDevGrp(\nDevGrp) + ", \sLogicalDev=" + \sLogicalDev)
            rHoldDev = grMapsForDevChgs\aDev(nDevPtr)
            grMapsForDevChgs\aDev(nDevPtr) = grMapsForImport\aDev(nImportDevPtr)
            debugMsg(sProcName, "setting grMapsForDevChgs\aDev(" + nDevPtr + ")\nDevMapId=" + nDevMapId + " (was " + grMapsForDevChgs\aDev(nDevPtr)\nDevMapId + ")")
            grMapsForDevChgs\aDev(nDevPtr)\nDevMapId = nDevMapId
            grMapsForDevChgs\aDev(nDevPtr)\nDevId = getDevIdForLogicalDev(@grProdForDevChgs, \nDevGrp, \sLogicalDev)
            debugMsg(sProcName, "grMapsForDevChgs\aDev(" + nNewDevMapDevPtr + ")\nDevId=" + grMapsForDevChgs\aDev(nNewDevMapDevPtr)\nDevId)
            grMapsForDevChgs\aDev(nDevPtr)\nPrevDevIndex = rHoldDev\nPrevDevIndex
            grMapsForDevChgs\aDev(nDevPtr)\nNextDevIndex = rHoldDev\nNextDevIndex
            nThisDevPtr = nDevPtr
          EndIf
        Else
          debugMsg(sProcName, "adding \nDevGrp=" + decodeDevGrp(\nDevGrp) + ", \nDevType=" + decodeDevType(\nDevType) + ", \sLogicalDev=" + \sLogicalDev)
          nNewDevMapDevPtr = addDevToDevChgsDevMap(\nDevGrp, \nDevType, \nDevId, \sLogicalDev, \nNrOfDevOutputChans, \nNrOfInputChans, nDevMapPtr)
          debugMsg(sProcName, "nNewDevMapDevPtr=" + nNewDevMapDevPtr)
          If nNewDevMapDevPtr >= 0
            rHoldDev = grMapsForDevChgs\aDev(nNewDevMapDevPtr)
            grMapsForDevChgs\aDev(nNewDevMapDevPtr) = grMapsForImport\aDev(nImportDevPtr)
            ; debugMsg(sProcName, "grMapsForDevChgs\aDev(" + nNewDevMapDevPtr + ")\nDevId=" + grMapsForDevChgs\aDev(nNewDevMapDevPtr)\n
            debugMsg(sProcName, "setting grMapsForDevChgs\aDev(" + nNewDevMapDevPtr + ")\nDevMapId=" + nDevMapId + " (was " + grMapsForDevChgs\aDev(nNewDevMapDevPtr)\nDevMapId + ")")
            grMapsForDevChgs\aDev(nNewDevMapDevPtr)\nDevMapId = nDevMapId
            grMapsForDevChgs\aDev(nNewDevMapDevPtr)\nDevId = getDevIdForLogicalDev(@grProdForDevChgs, \nDevGrp, \sLogicalDev)
            debugMsg(sProcName, "grMapsForDevChgs\aDev(" + nNewDevMapDevPtr + ")\nDevId=" + grMapsForDevChgs\aDev(nNewDevMapDevPtr)\nDevId)
            grMapsForDevChgs\aDev(nNewDevMapDevPtr)\nPrevDevIndex = rHoldDev\nPrevDevIndex
            grMapsForDevChgs\aDev(nNewDevMapDevPtr)\nNextDevIndex = rHoldDev\nNextDevIndex
            nThisDevPtr = nNewDevMapDevPtr
          EndIf
        EndIf
        
        If nThisDevPtr >= 0
          If \nDevGrp = #SCS_DEVGRP_LIGHTING
            For n = 0 To grMapsForDevChgs\aDev(nThisDevPtr)\nMaxDevFixture
              If grMapsForDevChgs\aDev(nThisDevPtr)\aDevFixture(n)\nDevDMXStartChannel < 1
                grMapsForDevChgs\aDev(nThisDevPtr)\aDevFixture(n)\nDevDMXStartChannel = getFixtureDfltStartChanForLightingDeviceFixtureCode(@grProdForDevChgs, grMapsForDevChgs\aDev(nThisDevPtr)\sLogicalDev, grMapsForDevChgs\aDev(nThisDevPtr)\aDevFixture(n)\sDevFixtureCode)
                ; debugMsg(sProcName, "grMapsForDevChgs\aDev(" + nThisDevPtr + ")\aDevFixture(" + n + ")\nDevDMXStartChannel=" + grMapsForDevChgs\aDev(nThisDevPtr)\aDevFixture(n)\nDevDMXStartChannel)
              EndIf
            Next n
          EndIf
        EndIf
        
      EndIf
      nImportDevPtr = \nNextDevIndex
    EndWith
  Wend
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WID_importDevMaps()
  PROCNAMEC()
  Protected nGrdDevs
  Protected nRow
  Protected sText.s
  Protected nNewDevMapPtr
  Protected bImported, bUpdated, sDevMapName.s
  
  debugMsg(sProcName, #SCS_START)
  
  nGrdDevs = WID\grdDevs
  
  For nRow = 1 To grWID\nMaxRowNo
    ; bReplaceExisting = #False
    With grWID\aRowInfo(nRow)
      Select \nRowType
        Case #SCS_IMD_DEVMAP
          sText = MyGrid_GetText(nGrdDevs, nRow, 1)
          If sText = "1" And \sDevMapName
            nNewDevMapPtr = getDevMapPtr(@grMapsForDevChgs, \sDevMapName)
            If nNewDevMapPtr >= 0
              debugMsg(sProcName, "updating device map " + #DQUOTE$ + \sDevMapName + #DQUOTE$ + ", nNewDevMapPtr=" + nNewDevMapPtr)
              ; do not try to 'replace' an existing device map, apart from adding any new devices (performed separately)
              ; because the only meaningful change could be the audio driver, and changing that could cause other issues
              ; due to the different output names, etc
              debugMsg(sProcName, "calling WID_importDevMapDevs(" + nNewDevMapPtr + ", " + \nDevMapForImportPtr + ", 0)")
              WID_importDevMapDevs(nNewDevMapPtr, \nDevMapForImportPtr, 0)
              \bUpdated = #True
            Else
              ; importing a new device map
              debugMsg(sProcName, "importing device map " + \sDevMapName)
              grMapsForDevChgs\nMaxMapIndex + 1
              If grMapsForDevChgs\nMaxMapIndex > ArraySize(grMapsForDevChgs\aMap())
                REDIM_ARRAY(grMapsForDevChgs\aMap, grMapsForDevChgs\nMaxMapIndex, grDevMapDef, "grMapsForDevChgs\aMap()")
              EndIf
              nNewDevMapPtr = grMapsForDevChgs\nMaxMapIndex
              debugMsg(sProcName, "nNewDevMapPtr=" + nNewDevMapPtr)
              gnUniqueDevMapId + 1
              grMapsForDevChgs\aMap(nNewDevMapPtr) = grMapsForImport\aMap(\nDevMapForImportPtr)
              grMapsForDevChgs\aMap(nNewDevMapPtr)\nDevMapId = gnUniqueDevMapId
              ; clear the device and input group pointers as these will be populated later as required
              grMapsForDevChgs\aMap(nNewDevMapPtr)\nFirstDevIndex = -1
              grMapsForDevChgs\aMap(nNewDevMapPtr)\nFirstLiveGrpIndex = -1
              debugMsg(sProcName, "calling WID_importDevMapDevs(" + nNewDevMapPtr + ", " + \nDevMapForImportPtr + ")")
              WID_importDevMapDevs(nNewDevMapPtr, \nDevMapForImportPtr)
              \bImported = #True
            EndIf
          EndIf
          If \bImported
            debugMsg(sProcName, "imported device map " + \sDevMapName)
          ElseIf \bUpdated
            debugMsg(sProcName, "updated device map " + \sDevMapName)
          EndIf
      EndSelect
    EndWith
  Next nRow
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

;EOF