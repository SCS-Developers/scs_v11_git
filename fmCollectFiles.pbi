; File: fmCollectFiles.pbi

EnableExplicit

Enumeration
  #WPF_SR_Audio_Files
  #WPF_SR_Playlist_Files
  #WPF_SR_Image_Files
  #WPF_SR_Video_Files
  #WPF_SR_Other_Files
  #WPF_SR_Total_Files
  #WPF_SR_Total_Size
EndEnumeration
#WPF_SR_Max = #PB_Compiler_EnumerationValue - 1

Enumeration
  #WPF_COL_Type
  #WPF_COL_Files
  #WPF_COL_Already
  #WPF_COL_To_Copy
  #WPF_COL_Excluded
EndEnumeration
#WPF_COL_Max = #PB_Compiler_EnumerationValue - 1

Procedure WPF_saveCollectPrefs()
  PROCNAMEC()
  Protected bPrefsOpenAtStart, sPrefGroupAtStart.s
  
  COND_OPEN_PREFS("Collect")
  With grCollectOptions
    WritePreferenceInteger("CopyColorFile", \bCopyColorFile)
    WritePreferenceInteger("ExcludePlaylists", \bExcludePlaylists)
    WritePreferenceInteger("Switch", \bSwitchToCollected)
  EndWith
  COND_CLOSE_PREFS()
  
EndProcedure

Procedure WPF_checkColorFileAlreadyExists()
  PROCNAMEC()
  Protected bColorFileAlreadyExists
  
  With grWPF
    If \sProdFolder
      \sColorFile = \sProdFolder + "scs_colors.scsc"   ; SCS 11 color file
      If FileExists(\sColorFile)
        bColorFileAlreadyExists = #True
      Else
        \sColorFile = ""
      EndIf
    EndIf
  EndWith
  ProcedureReturn bColorFileAlreadyExists
EndProcedure

Procedure WPF_checkDevMapsFileAlreadyExists()
  PROCNAMEC()
  Protected bDevMapsFileAlreadyExists
  
  With grWPF
    If \sProdFolder
      If grProd\sProdId
        \sDevMapFile = grWPF\sProdFolder + ignoreExtension(GetFilePart(gsCueFile)) + "_" + grProd\sProdId + ".scsdx"
      Else
        \sDevMapFile = grWPF\sProdFolder + ignoreExtension(GetFilePart(gsCueFile)) + ".scsdx"
      EndIf
      If FileExists(\sDevMapFile)
        bDevMapsFileAlreadyExists = #True
      Else
        \sDevMapFile = ""
      EndIf
    EndIf
    debugMsg(sProcName, "\sDevMapFile=" + #DQUOTE$ + \sDevMapFile + #DQUOTE$ + ", bDevMapsFileAlreadyExists=" + strB(bDevMapsFileAlreadyExists))
  EndWith
  ProcedureReturn bDevMapsFileAlreadyExists
EndProcedure

Procedure WPF_checkSameFile(pAudPtr, sCollectedFileName.s)
  PROCNAMECA(pAudPtr)
  Protected sAudFileName.s
  Protected qAudFileSize.q, qCollectedFileSize.q
  Protected nAudDateModified, nCollectedDateModified
  Protected bSameFile
  
  debugMsg(sProcName, #SCS_START)
  
  If pAudPtr >= 0
    With aAud(pAudPtr)
      sAudFileName = \sFileName
      debugMsg(sProcName, "sAudFileName=" + #DQUOTE$ + sAudFileName + #DQUOTE$ + ", sCollectedFileName=" + #DQUOTE$ + sCollectedFileName + #DQUOTE$)
      If GetFilePart(sAudFileName) = GetFilePart(sCollectedFileName)
        qAudFileSize = FileSize(sAudFileName)
        qCollectedFileSize = FileSize(sCollectedFileName)
        debugMsg(sProcName, "qAudFileSize=" + qAudFileSize + ", qCollectedFileSize=" + qCollectedFileSize)
        If (qAudFileSize = qCollectedFileSize) And (qAudFileSize > 0)
          nAudDateModified = GetFileDate(sAudFileName, #PB_Date_Modified)
          nCollectedDateModified = GetFileDate(sCollectedFileName, #PB_Date_Modified)
          debugMsg(sProcName, "nAudDateModified=" + FormatDate(#SCS_CUE_FILE_DATE_FORMAT, nAudDateModified) + ", nCollectedDateModified=" + FormatDate(#SCS_CUE_FILE_DATE_FORMAT, nCollectedDateModified))
          If (nAudDateModified = nCollectedDateModified) And (nAudDateModified > 0)
            bSameFile = #True
          EndIf
        EndIf
      EndIf
    EndWith
  EndIf
  
  debugMsg(sProcName, #SCS_END + ", returning bSameFile=" + strB(bSameFile))
  ProcedureReturn bSameFile
EndProcedure

Procedure WPF_DrawProgress(nCurrValue, nMaxValue)
  ; PROCNAMEC()
  Protected nWidth, nHeight
  Protected nPos
  
  ; debugMsg(sProcName, #SCS_START + ", nCurrValue=" + nCurrValue + ", nMaxValue=" + nMaxValue)
  
  With WPF
    If StartDrawing(CanvasOutput(\cvsProgress))
      nWidth = GadgetWidth(\cvsProgress)
      nHeight = GadgetHeight(\cvsProgress)
      Box(0,0,nWidth,nHeight,#SCS_Light_Grey)
      If nCurrValue > 0
        If nCurrValue >= nMaxValue
          nPos = nWidth
        Else
          nPos = Round((nCurrValue * nWidth) / nMaxValue, #PB_Round_Nearest)
        EndIf
        Box(0,0,nPos,nHeight,#SCS_Green)
      EndIf
      StopDrawing()
    EndIf
  EndWith
EndProcedure

Procedure WPF_drawSpaceReqdCanvas()
  PROCNAMEC()
  Protected i, j, k, n
  Protected nIndex
  Protected sItem.s
  Protected Dim sFileType.s(#WPF_SR_Max)
  Protected Dim qFiles.q(#WPF_SR_Max)   ; nb these arrays are quads because FileSize() returns quad
  Protected Dim qAlreadyInFolder.q(#WPF_SR_Max)
  Protected Dim qToBeCopied.q(#WPF_SR_Max)
  Protected Dim qSameButDifferent.q(#WPF_SR_Max)
  Protected Dim qExcluded.q(#WPF_SR_Max)
  Protected Dim nColLeft(#WPF_COL_Max)
  Protected Dim nColWidth(#WPF_COL_Max)
  Protected nItemTextWidth, nMaxItemTextWidth
  Protected nLeft, nTop, nWidth, nHeight
  Protected sText.s, nTextLeft
  Protected nLineColor = #SCS_Light_Grey
  Protected nFrontColor = $303030
  Protected nBackColor = #SCS_White
  Protected nHdgBackColor = $EEEEEE
  Protected nHdgHeight, nLineHeight
  Protected nReqdCanvasWidth, nReqdCanvasHeight
  Protected qFileSize.q
  Protected bProdFolderSet
  Protected sProdFolderCueFile.s
  Protected bEnableCollectButton
  Protected bColorFileAlreadyExists
  Protected bDevMapsFileAlreadyExists
  Protected sFileName.s, sFilePart.s
  Protected bFound, bFilePartClash
  Protected bSameButDifferent
  Protected sTargetFileName.s
  Protected nHdgTextHeight
  
  nHdgHeight = 30
  nLineHeight = 18
  
  If grWPF\sProdFolder
    If FolderExists(grWPF\sProdFolder)
      bProdFolderSet = #True
    EndIf
  EndIf
  
  grWPF\nFileCount = 0
  For i = 1 To gnLastCue
    j = aCue(i)\nFirstSubIndex
    While j >= 0
      If aSub(j)\bSubTypeHasAuds
        k = aSub(j)\nFirstAudIndex
        While k >= 0
          With aAud(k)
            ; Added 4May2022 11.9.1
            If \bAudPlaceHolder
              k = \nNextAudIndex
              Continue
            EndIf
            ; End added 4May2022 11.9.1
            sFileName = \sFileName
            sFilePart = GetFilePart(sFileName)
            bFound = #False
            bFilePartClash = #False
            bSameButDifferent = #False
            For n = 1 To grWPF\nFileCount
              If LCase(grWPF\sFileName(n)) = LCase(sFileName)
                bFound = #True
                Break
              EndIf
            Next n
            If bFound
              k = \nNextAudIndex
              Continue
            EndIf
            sTargetFileName = grWPF\sProdFolder + GetFilePart(sFileName)
            If LCase(sTargetFileName) <> LCase(sFileName)
              bSameButDifferent = WPF_checkSameFile(k, sTargetFileName)
              If bSameButDifferent = #False
                If LCase(sTargetFileName) <> LCase(sFileName)
                  If FileExists(sTargetFileName, #False)
                    ; a file with this file part already exists in the production folder but it is not \sFileName
                    bFilePartClash = #True
                    debugMsg(sProcName, "bFilePartClash=" + strB(bFilePartClash) +
                                        ", sTargetFileName=" + #DQUOTE$ + sTargetFileName + #DQUOTE$ +
                                        ", sFileName=" + #DQUOTE$ + sFileName + #DQUOTE$)
                  EndIf
                EndIf
                If bFilePartClash = #False
                  For n = 1 To grWPF\nFileCount
                    If grWPF\bFilePartClash(n) = #False ; nb if bFilePartClash(n) #True then sFileName(n) will not be copied so no need to check for a file part clash
                      If LCase(GetFilePart(grWPF\sFileName(n))) = LCase(sFilePart)
                        bFilePartClash = #True
                        debugMsg(sProcName, "bFilePartClash=" + strB(bFilePartClash) +
                                            ", grWPF\sFileName(" + n + ")=" + #DQUOTE$ + grWPF\sFileName(n) + #DQUOTE$ +
                                            ", sFileName=" + #DQUOTE$ + sFileName + #DQUOTE$)
                        Break
                      EndIf
                    EndIf
                  Next n
                EndIf
              EndIf
            EndIf
            grWPF\nFileCount + 1
            If grWPF\nFileCount > ArraySize(grWPF\sFileName())
              ReDim grWPF\sFileName(grWPF\nFileCount + 20)
              ReDim grWPF\bSameButDifferent(grWPF\nFileCount + 20)
              ReDim grWPF\bFilePartClash(grWPF\nFileCount + 20)
            EndIf
            grWPF\sFileName(grWPF\nFileCount) = sFileName
            grWPF\bSameButDifferent(grWPF\nFileCount) = bSameButDifferent
            grWPF\bFilePartClash(grWPF\nFileCount) = bFilePartClash
            nIndex = -1
            If \bAudTypeF
              nIndex = #WPF_SR_Audio_Files
            ElseIf \bAudTypeP
              If grCollectOptions\bExcludePlaylists = #False
                nIndex = #WPF_SR_Playlist_Files
              EndIf
            ElseIf \bAudTypeA
              Select \nFileFormat
                Case #SCS_FILEFORMAT_PICTURE
                  nIndex = #WPF_SR_Image_Files
                Case #SCS_FILEFORMAT_VIDEO
                  nIndex = #WPF_SR_Video_Files
              EndSelect
            EndIf
            If nIndex >= 0
              qFileSize = FileSize(\sFileName)
              debugMsg(sProcName, "FileSize(" + GetFilePart(\sFileName) + ")=" + qFileSize + ", bSameButDifferent=" + strB(bSameButDifferent) + ", bFilePartClash=" + strB(bFilePartClash))
              qFiles(nIndex) + 1
              qFiles(#WPF_SR_Total_Files) + 1
              qFiles(#WPF_SR_Total_Size) + qFileSize
              If bProdFolderSet
                sTargetFileName = grWPF\sProdFolder + GetFilePart(\sFileName)
                If bSameButDifferent
                  qSameButDifferent(nIndex) + 1
                  ; debugMsg(sProcName, "qSameButDifferent(" + nIndex + ")=" + qSameButDifferent(nIndex))
                  qSameButDifferent(#WPF_SR_Total_Files) + 1
                  qSameButDifferent(#WPF_SR_Total_Size) + qFileSize
                ElseIf bFilePartClash
                  ; filepart clashes with an existing file but for a different file
                  qExcluded(nIndex) + 1
                  qExcluded(#WPF_SR_Total_Files) + 1
                  qExcluded(#WPF_SR_Total_Size) + qFileSize
                ElseIf FileExists(sTargetFileName, #False)
                  ; file already in
                  qAlreadyInFolder(nIndex) + 1
                  qAlreadyInFolder(#WPF_SR_Total_Files) + 1
                  qAlreadyInFolder(#WPF_SR_Total_Size) + qFileSize
                ElseIf LCase(Left(\sFileName, Len(grWPF\sProdFolder))) = LCase(grWPF\sProdFolder)
                  ; file already in or below the prod folder
                  qAlreadyInFolder(nIndex) + 1
                  qAlreadyInFolder(#WPF_SR_Total_Files) + 1
                  qAlreadyInFolder(#WPF_SR_Total_Size) + qFileSize
                Else
                  qToBeCopied(nIndex) + 1
                  ; debugMsg(sProcName, "qToBeCopied(" + nIndex + ")=" + qToBeCopied(nIndex))
                  qToBeCopied(#WPF_SR_Total_Files) + 1
                  qToBeCopied(#WPF_SR_Total_Size) + qFileSize
                EndIf
              EndIf
            EndIf
            k = \nNextAudIndex
          EndWith
        Wend
      EndIf
      j = aSub(j)\nNextSubIndex
    Wend
  Next i
  debugMsg(sProcName, "grWPF\nFileCount=" + grWPF\nFileCount + ", qFiles(" + #WPF_SR_Total_Files + ")=" + qFiles(#WPF_SR_Total_Files))
  
  nIndex = #WPF_SR_Other_Files
  ; NOTE: cue file
  If FileExists(gsCueFile, #False)
    qFileSize = FileSize(gsCueFile)
    qFiles(nIndex) + 1
    qFiles(#WPF_SR_Total_Files) + 1
    qFiles(#WPF_SR_Total_Size) + qFileSize
    If bProdFolderSet
      sProdFolderCueFile = grWPF\sProdFolder + GetFilePart(gsCueFile)
      If gsCueFile = sProdFolderCueFile
        qAlreadyInFolder(nIndex) + 1
        qAlreadyInFolder(#WPF_SR_Total_Files) + 1
        qAlreadyInFolder(#WPF_SR_Total_Size) + qFileSize
      Else
        qToBeCopied(nIndex) + 1
        qToBeCopied(#WPF_SR_Total_Files) + 1
        qToBeCopied(#WPF_SR_Total_Size) + qFileSize
      EndIf
    EndIf
  EndIf
  
  nIndex = #WPF_SR_Other_Files
  
  With grWPF
    ; NOTE: color file
    If grCollectOptions\bCopyColorFile
      bColorFileAlreadyExists = WPF_checkColorFileAlreadyExists()
      If FileExists(\sColorFile, #False)
        qFileSize = FileSize(\sColorFile)
      Else
        qFileSize = 4096  ; approx size that the default color file will be
      EndIf
      qFiles(nIndex) + 1
      qFiles(#WPF_SR_Total_Files) + 1
      qFiles(#WPF_SR_Total_Size) + qFileSize
      If bColorFileAlreadyExists
        qAlreadyInFolder(nIndex) + 1
        qAlreadyInFolder(#WPF_SR_Total_Files) + 1
        qAlreadyInFolder(#WPF_SR_Total_Size) + qFileSize
      Else
        qToBeCopied(nIndex) + 1
        qToBeCopied(#WPF_SR_Total_Files) + 1
        qToBeCopied(#WPF_SR_Total_Size) + qFileSize
      EndIf
    EndIf
    
    ; NOTE: device map file
    If grCollectOptions\bIncludeDevMaps
      bDevMapsFileAlreadyExists = WPF_checkDevMapsFileAlreadyExists()
      qFileSize = 2048  ; approx size that the default DevMaps file will be
      If bDevMapsFileAlreadyExists
        qFileSize = FileSize(\sDevMapFile)
        debugMsg(sProcName, "\sDevMapFile=" + \sDevMapFile + ", qFileSize=" + qFileSize)
      ElseIf grProd\sDevMapFile
        If FileExists(grProd\sDevMapFile, #False)
          qFileSize = FileSize(grProd\sDevMapFile)
          debugMsg(sProcName, "grProd\sDevMapFile=" + grProd\sDevMapFile + ", qFileSize=" + qFileSize)
        EndIf
      EndIf
      qFiles(nIndex) + 1
      qFiles(#WPF_SR_Total_Files) + 1
      qFiles(#WPF_SR_Total_Size) + qFileSize
      If bDevMapsFileAlreadyExists
        qAlreadyInFolder(nIndex) + 1
        qAlreadyInFolder(#WPF_SR_Total_Files) + 1
        qAlreadyInFolder(#WPF_SR_Total_Size) + qFileSize
      EndIf
      ; note: if 'Include Device Map File' is selected then the file is ALWAYS copied as the 'export' file is not the file used by productions, so could be out-of-date
      qToBeCopied(nIndex) + 1
      qToBeCopied(#WPF_SR_Total_Files) + 1
      qToBeCopied(#WPF_SR_Total_Size) + qFileSize
    EndIf
  EndWith
  
  grWPF\nFilesToBeCopied = qToBeCopied(#WPF_SR_Total_Files)
  grWPF\nFilesSameButDifferent = qSameButDifferent(#WPF_SR_Total_Files)
  grWPF\nFilesToBeExcluded = qExcluded(#WPF_SR_Total_Files)
  If (grWPF\nFilesToBeCopied > 0) Or (grWPF\nFilesSameButDifferent > 0)
    bEnableCollectButton = #True
  EndIf
  
  With WPF
    
    If StartDrawing(CanvasOutput(\cvsSpaceReqd))
      scsDrawingFont(#SCS_FONT_GEN_NORMAL)
      For nIndex = 0 To #WPF_SR_Max
        Select nIndex
          Case #WPF_SR_Audio_Files
            sItem = Lang("WPF", "TypeF")
          Case #WPF_SR_Playlist_Files
            sItem = Lang("WPF", "TypeP")
          Case #WPF_SR_Image_Files
            sItem = Lang("WPF", "TypeAI")
          Case #WPF_SR_Video_Files
            sItem = Lang("WPF", "TypeAV")
          Case #WPF_SR_Other_Files
            sItem = Lang("WPF", "Other")
          Case #WPF_SR_Total_Files
            scsDrawingFont(#SCS_FONT_GEN_BOLD)
            sItem = Lang("WPF", "TotalFiles")
          Case #WPF_SR_Total_Size
            sItem = Lang("WPF", "TotalSize")
        EndSelect
        sFileType(nIndex) = sItem
        nItemTextWidth = TextWidth(sItem)
        If nItemTextWidth > nMaxItemTextWidth
          nMaxItemTextWidth = nItemTextWidth
        EndIf
      Next nIndex
      StopDrawing()
    EndIf
    
    nLeft = 0
    nWidth = nMaxItemTextWidth + 20
    nColLeft(#WPF_COL_Type) = nLeft
    nColWidth(#WPF_COL_Type) = nWidth
    nLeft + nWidth
    nWidth = 80
    nColLeft(#WPF_COL_Files) = nLeft
    nColWidth(#WPF_COL_Files) = nWidth
    nLeft + nWidth
    nColLeft(#WPF_COL_Already) = nLeft
    nColWidth(#WPF_COL_Already) = nWidth
    nLeft + nWidth
    nColLeft(#WPF_COL_To_Copy) = nLeft
    nColWidth(#WPF_COL_To_Copy) = nWidth
    nLeft + nWidth
    nWidth = 88
    nColLeft(#WPF_COL_Excluded) = nLeft
    nColWidth(#WPF_COL_Excluded) = nWidth
    nLeft + nWidth
    
    ; calculate required heading height by 'drawing' the ColExcluded heading, but drawing it out of site (to the left of the displayed canvas)
    If StartDrawing(CanvasOutput(\cvsSpaceReqd))
      DrawingMode(#PB_2DDrawing_Transparent)
      scsDrawingFont(#SCS_FONT_GEN_NORMAL)
      nWidth = nColWidth(#WPF_COL_Excluded)-2
      WrapTextInit()
      WrapTextCenter(0-nWidth, 0, Lang("WPF","ColExcluded")+" *", nWidth, nHdgBackColor, nHdgBackColor)
      ; debugMsg(sProcName, "gnWrapTextTotalHeight=" + gnWrapTextTotalHeight + ", gnWrapTextLineCount=" + gnWrapTextLineCount)
      nHdgHeight = gnWrapTextTotalHeight + 4
      StopDrawing()
    EndIf
    
    nReqdCanvasWidth = nLeft + gl3DBorderAllowanceX + gl3DBorderAllowanceX + 2
    nReqdCanvasHeight = nHdgHeight + (nLineHeight * (#WPF_SR_Max + 1)) + gl3DBorderAllowanceY + gl3DBorderAllowanceY
    debugMsg(sProcName, "nReqdCanvasWidth=" + nReqdCanvasWidth + ", nReqdCanvasHeight=" + nReqdCanvasHeight)
    ResizeGadget(\cvsSpaceReqd, #PB_Ignore, #PB_Ignore, nReqdCanvasWidth, nReqdCanvasHeight)
    ResizeGadget(\cntBelowSpaceReqd, #PB_Ignore, GadgetY(\cvsSpaceReqd) + GadgetHeight(\cvsSpaceReqd) + 6, #PB_Ignore, #PB_Ignore)
    ResizeWindow(#WPF, #PB_Ignore, #PB_Ignore, #PB_Ignore, GadgetY(\cntBelowSpaceReqd) + GadgetHeight(\cntBelowSpaceReqd))
    
    If StartDrawing(CanvasOutput(\cvsSpaceReqd))
      DrawingMode(#PB_2DDrawing_Transparent)
      scsDrawingFont(#SCS_FONT_GEN_NORMAL)
      nWidth = GadgetWidth(\cvsSpaceReqd)
      nHeight = GadgetHeight(\cvsSpaceReqd)
      Box(0,0,nWidth,nHdgHeight,nHdgBackColor)
      Box(0,nHdgHeight,nWidth,nHeight-nHdgHeight,nBackColor)
      
      nTop = 2
      nLeft = nColLeft(#WPF_COL_Type)
      sItem = Lang("WPF","ColFileType")
      DrawText(nLeft+4, nTop, sItem, nFrontColor)
      
      nLeft = nColLeft(#WPF_COL_Files)
      LineXY(nLeft, 0, nLeft, nHeight, nLineColor)
      WrapTextCenter(nLeft+1, nTop, Lang("WPF","ColFiles"), nColWidth(#WPF_COL_Files)-2, nFrontColor, nHdgBackColor)
      
      nLeft = nColLeft(#WPF_COL_Already)
      LineXY(nLeft, 0, nLeft, nHeight, nLineColor)
      WrapTextCenter(nLeft+1, nTop, Lang("WPF","ColAlready"), nColWidth(#WPF_COL_Already)-2, nFrontColor, nHdgBackColor)
      
      nLeft = nColLeft(#WPF_COL_To_Copy)
      LineXY(nLeft, 0, nLeft, nHeight, nLineColor)
      WrapTextCenter(nLeft+1, nTop, Lang("WPF","colToCopy"), nColWidth(#WPF_COL_To_Copy)-2, nFrontColor, nHdgBackColor)
      
      nLeft = nColLeft(#WPF_COL_Excluded)
      LineXY(nLeft, 0, nLeft, nHeight, nLineColor)
      WrapTextCenter(nLeft+1, nTop, Lang("WPF","ColExcluded")+" *", nColWidth(#WPF_COL_Excluded)-2, nFrontColor, nHdgBackColor)
      grWPF\nExcludedLeft = nLeft+1
      grWPF\nExcludedRight = grWPF\nExcludedLeft + (nColWidth(#WPF_COL_Excluded)-2)
      
      For nIndex = 0 To #WPF_SR_Max
        nTop = (nIndex * nLineHeight) + nHdgHeight
        If nIndex = 0
          grWPF\nExcludedTop = nTop + 1
        EndIf
        If nIndex = #WPF_SR_Total_Files
          scsDrawingFont(#SCS_FONT_GEN_BOLD)  ; bold for 'total files' and 'total size'
          LineXY(0, nTop, nWidth, nTop, #SCS_Dark_Grey) ; stronger line above the totals
        Else
          LineXY(0, nTop, nWidth, nTop, nLineColor)
        EndIf
        nTop + 2
        DrawText(nColLeft(#WPF_COL_Type)+4, nTop, sFileType(nIndex), nFrontColor)
        
        If (nIndex = #WPF_SR_Playlist_Files) And (grCollectOptions\bExcludePlaylists)
          WrapTextCenter(nColLeft(#WPF_COL_Files)+1, nTop, "x", nColWidth(#WPF_COL_Files)-2, nFrontColor, nBackColor)
          
        ElseIf nIndex < #WPF_SR_Total_Size
          WrapTextInit()
          WrapTextCenter(nColLeft(#WPF_COL_Files)+1, nTop, Str(qFiles(nIndex)), nColWidth(#WPF_COL_Files)-2, nFrontColor, nBackColor)
          If bProdFolderSet
            WrapTextInit()
            WrapTextCenter(nColLeft(#WPF_COL_Already)+1, nTop, Str(qAlreadyInFolder(nIndex)), nColWidth(#WPF_COL_Already)-2, nFrontColor, nBackColor)
            WrapTextInit()
;             WrapTextCenter(nColLeft(#WPF_COL_To_Copy)+1, nTop, Str(qToBeCopied(nIndex)), nColWidth(#WPF_COL_To_Copy)-2, nFrontColor, nBackColor)
            WrapTextCenter(nColLeft(#WPF_COL_To_Copy)+1, nTop, Str(qToBeCopied(nIndex)+qSameButDifferent(nIndex)), nColWidth(#WPF_COL_To_Copy)-2, nFrontColor, nBackColor)
            WrapTextInit()
            WrapTextCenter(nColLeft(#WPF_COL_Excluded)+1, nTop, Str(qExcluded(nIndex)), nColWidth(#WPF_COL_Excluded)-2, nFrontColor, nBackColor)
          EndIf
          
        Else
          debugMsg(sProcName, "bProdFolderSet=" + strB(bProdFolderSet) +
                              ", qFiles(" + nIndex + ")=" + qFiles(nIndex) +
                              ", qAlreadyInFolder(" + nIndex + ")=" + qAlreadyInFolder(nIndex) +
                              ", qSameButDifferent(" + nIndex + ")=" + qSameButDifferent(nIndex) +
                              ", qToBeCopied(" + nIndex + ")=" + qToBeCopied(nIndex))
          sText = SizeIt(qFiles(nIndex))
          WrapTextInit()
          WrapTextCenter(nColLeft(#WPF_COL_Files)+1, nTop, sText, nColWidth(#WPF_COL_Files)-2, nFrontColor, nBackColor)
          If bProdFolderSet
            sText = SizeIt(qAlreadyInFolder(nIndex))
            WrapTextInit()
            WrapTextCenter(nColLeft(#WPF_COL_Already)+1, nTop, sText, nColWidth(#WPF_COL_Already)-2, nFrontColor, nBackColor)
;             sText = SizeIt(qToBeCopied(nIndex))
            sText = SizeIt(qToBeCopied(nIndex)+qSameButDifferent(nIndex))
            WrapTextInit()
            WrapTextCenter(nColLeft(#WPF_COL_To_Copy)+1, nTop, sText, nColWidth(#WPF_COL_To_Copy)-2, nFrontColor, nBackColor)
            sText = SizeIt(qExcluded(nIndex))
            WrapTextInit()
            WrapTextCenter(nColLeft(#WPF_COL_Excluded)+1, nTop, sText, nColWidth(#WPF_COL_Excluded)-2, nFrontColor, nBackColor)
          EndIf
        EndIf
      Next nIndex
      grWPF\nExcludedBottom = GadgetHeight(\cvsSpaceReqd) - 1
      
      StopDrawing()
    EndIf
    
    grWPF\qDriveSpaceRequired = qToBeCopied(#WPF_SR_Total_Size) + qSameButDifferent(#WPF_SR_Total_Size)
    debugMsg(sProcName, "grWPF\qDriveSpaceRequired=" + grWPF\qDriveSpaceRequired)
    
    If grWPF\nFilesToBeExcluded > 0
      setEnabled(\btnShowExclusions, #True)
    Else
      setEnabled(\btnShowExclusions, #False)
    EndIf
    
    If bEnableCollectButton
      setVisible(\cvsProgress, #True)
      WPF_DrawProgress(0, 100)  ; arbitrary max for initial 'no progress' drawing
    Else
      setVisible(\cvsProgress, #False)
    EndIf
    setEnabled(\btnCollect, bEnableCollectButton)
    
  EndWith
  
EndProcedure

Procedure WPF_drawForm()
  PROCNAMEC()
  Protected sColorFile.s
;   Protected bColorFileExists
;   Protected bProdFolderExists
  Protected sProdFolder.s
  Protected bDevMapsFileExists
  
  With WPF
    
    SGT(\lblStatus, "")
    
    grWPF\sCueFile = gsCueFile
    grWPF\sProdFolder = GetPathPart(gsCueFile)
    
    SGT(\txtProdFolder, grWPF\sProdFolder)
    scsToolTip(\txtProdFolder, grWPF\sProdFolder)
    
    ; Mod 19Dec2023 11.10.0dr - do NOT assume color file is to be collected just because it exists - I (Mike) found that annoying every time I collect files!
;     sColorFile = gsCueFolder + "scs_colors.scsc"   ; SCS 11 color file
;     If FileExists(sColorFile)
;       bColorFileExists = #True
;     EndIf
;     
;     If (bColorFileExists) Or (gbDfltColorFile = #False)
;       grCollectOptions\bCopyColorFile = #True
;     Else
;       grCollectOptions\bCopyColorFile = #False
;     EndIf
    ; End of Mod 19Dec2023 11.10.0dr
    
    SGS(\chkCopyColorFile, grCollectOptions\bCopyColorFile)
    SGS(\chkExclPlaylists, grCollectOptions\bExcludePlaylists)
    If grCollectOptions\bSwitchToCollected
      SGS(\optSwitch[0], #True)
    Else
      SGS(\optSwitch[1], #True)
    EndIf
    
    bDevMapsFileExists = WPF_checkDevMapsFileAlreadyExists()
    If bDevMapsFileExists
      grCollectOptions\bIncludeDevMaps = #True
    Else
      grCollectOptions\bIncludeDevMaps = #False
    EndIf
    SGS(\chkInclDevMaps, grCollectOptions\bIncludeDevMaps)
    
    WPF_drawSpaceReqdCanvas()
    
    setEnabled(WPF\btnCancel, #True)
    setEnabled(WPF\btnHelp, #True)
    setEnabled(WPF\btnBrowse, #True)
    
    SAG(-1)
    
  EndWith
  
EndProcedure

Procedure WPF_Form_Unload(nProdFolderAction)
  getFormPosition(#WPF, @grProdFolderWindow)
  
  With grCollectOptions
    \bCopyColorFile = GGS(WPF\chkCopyColorFile)
    \bExcludePlaylists = GGS(WPF\chkExclPlaylists)
    If GGS(WPF\optSwitch[0])
      \bSwitchToCollected = #True
    Else
      \bSwitchToCollected = #False
    EndIf
  EndWith
  WPF_saveCollectPrefs()
  
  unsetWindowModal(#WPF, nProdFolderAction)
  scsCloseWindow(#WPF)
EndProcedure

Procedure WPF_setFormEnabled(bEnable)
  
  With WPF
    setEnabled(\chkCopyColorFile, bEnable)
    setEnabled(\chkExclPlaylists, bEnable)
    setEnabled(\btnCollect, bEnable)
    ; setEnabled(\btnCancel, bEnable)
    ; setEnabled(\btnHelp, bEnable)
    setEnabled(\btnBrowse, bEnable)
  EndWith
EndProcedure

Procedure WPF_buildUniqueFileArray()
  PROCNAMEC()
  Protected i, j, k, n
  Protected sInitialFileName.s, bFound
  
  With grWPF
    \nMaxUniqueFile = -1
    For i = 1 To gnLastCue
      j = aCue(i)\nFirstSubIndex
      While j >= 0
        If aSub(j)\bSubTypeI
          ; ignore live input sub-cues
        ElseIf (grCollectOptions\bExcludePlaylists) And (aSub(j)\bSubTypeP)
          ; ignore playlist files if user asks to
        ElseIf aSub(j)\bSubPlaceHolder
          ; ignore place holders
        Else
          k = aSub(j)\nFirstAudIndex
          While k >= 0
            debugMsg(sProcName, ">>>> k=" + getAudLabel(k))
            If aAud(k)\bAudPlaceHolder = #False
              sInitialFileName = aAud(k)\sFileName
              bFound = #False
              For n = 0 To \nMaxUniqueFile
                If LCase(\aUniqueFile(n)\sOldFile) = LCase(sInitialFileName)
                  bFound = #True
                  Break
                EndIf
              Next n
              If bFound = #False
                \nMaxUniqueFile + 1
                If \nMaxUniqueFile > ArraySize(\aUniqueFile())
                  ReDim \aUniqueFile(\nMaxUniqueFile+20)
                EndIf
                \aUniqueFile(\nMaxUniqueFile)\sOldFile = sInitialFileName
                \aUniqueFile(\nMaxUniqueFile)\sNewFile = ""
              EndIf
            EndIf
            k = aAud(k)\nNextAudIndex
          Wend
        EndIf
        j = aSub(j)\nNextSubIndex
      Wend
    Next i
  EndWith
  
EndProcedure

Procedure WPF_collectFiles(*null)
  PROCNAMEC()
  ; this procedure is run as a separate thread, started in WPF_btnCollect_Click()
  ; see my PB Forum question "When is a disabled button disabled?" for more info
  Protected i, j, k, nCount
  Protected sTmp1.s, sTmp2.s, sTmp3.s
;   Protected sFile1Modified.s, qFile1Size.q
;   Protected sFile2Modified.s, qFile2Size.q
  Protected bIgnoreThisFile
  Protected sMsg.s
  Protected n, nNotCopiedIndex
  Protected bFileCopied, bProcessed
  Protected nFilePass, sInitialFileName.s, sProdFolderFileName.s
  Protected nFilesCopied, bCueFileCopied, bColorFileCopied, bDevMapsFileCopied
  Protected bExcludeDueToNameClash, bSameButDifferent
  
  setThreadNo(#SCS_THREAD_COLLECT_FILES)  ; preferably set this before calling debugMsg()

  debugMsg(sProcName, #SCS_START)
  
  With grWPF
    
    debugMsg(sProcName, "grWPF\sProdFolder=" + \sProdFolder)
    
    \bCopyThreadRunning = #True
    \bCopyCancelRequested = #False
    
    nNotCopiedIndex = 0
    ReDim gaFileNotCopied(nNotCopiedIndex)
    debugMsg(sProcName, "ArraySize(gaFileNotCopied())=" + ArraySize(gaFileNotCopied()))
    
    setMouseCursorBusy()
    
    debugMsg(sProcName, "calling WPF_buildUniqueFileArray()")
    WPF_buildUniqueFileArray()
    
    For i = 1 To gnLastCue
      j = aCue(i)\nFirstSubIndex
      While (j >= 0) And (\bCopyCancelRequested = #False)
        If aSub(j)\bSubTypeHasAuds
          If aSub(j)\bSubTypeI
            ; ignore live input sub-cues
          ElseIf (grCollectOptions\bExcludePlaylists) And (aSub(j)\bSubTypeP)
            ; ignore playlist files if user asks to
          ElseIf aSub(j)\bSubPlaceHolder
            ; ignore place holders
          Else
            k = aSub(j)\nFirstAudIndex
            While (k >= 0) And (\bCopyCancelRequested = #False)
              bProcessed = #False
              If aAud(k)\bAudPlaceHolder = #False
                debugMsg(sProcName, "aAud(" + getAudLabel(k) + ")\sFileName=" + #DQUOTE$ + aAud(k)\sFileName + #DQUOTE$)
                sInitialFileName = aAud(k)\sFileName
                For n = 0 To \nMaxUniqueFile
                  If LCase(\aUniqueFile(n)\sOldFile) = LCase(sInitialFileName)
                    If (Len(\aUniqueFile(n)\sNewFile) > 0) And (LCase(\aUniqueFile(n)\sNewFile) <> LCase(\aUniqueFile(n)\sOldFile))
                      If FileExists(\aUniqueFile(n)\sNewFile, #False)
                        debugMsg(sProcName, #DQUOTE$ + sInitialFileName + #DQUOTE$ + " found with \aUniqueFile(" + n + ")\sNewFile=" + #DQUOTE$ + \aUniqueFile(n)\sNewFile + #DQUOTE$)
                        debugMsg(sProcName, "changing aAud(" + getAudLabel(k) + ")\sFileName from " + #DQUOTE$ + aAud(k)\sFileName + #DQUOTE$ + " to " + #DQUOTE$ + sTmp2 + #DQUOTE$)
                        aAud(k)\sFileName = \aUniqueFile(n)\sNewFile
                        aAud(k)\sStoredFileName = encodeFileName(aAud(k)\sFileName)
                        debugMsg(sProcName, "aAud(" + getAudLabel(k) + ")\sStoredFileName=" + #DQUOTE$ + aAud(k)\sStoredFileName + #DQUOTE$)
                        bProcessed = #True
                        Break
                      EndIf
                    EndIf
                  EndIf
                Next n
                If bProcessed = #False
                  bExcludeDueToNameClash = #False
                  bSameButDifferent = #False
                  ; debugMsg(sProcName, "grWPF\nFileCount=" + grWPF\nFileCount + ", sInitialFileName=" + #DQUOTE$ + sInitialFileName + #DQUOTE$)
                  For n = 1 To grWPF\nFileCount
                    ; debugMsg(sProcName, "grWPF\sFileName(" + n + ")=" + #DQUOTE$ + grWPF\sFileName(n) + #DQUOTE$ + ", grWPF\bFilePartClash(" + n + ")=" + strB(grWPF\bFilePartClash(n)))
                    If grWPF\sFileName(n) = sInitialFileName
                      If grWPF\bSameButDifferent(n)
                        bSameButDifferent = #True
                        debugMsg(sProcName, "bSameButDifferent=" + strB(bSameButDifferent) + ", sInitialFileName=" + #DQUOTE$ + sInitialFileName + #DQUOTE$)
                      ElseIf grWPF\bFilePartClash(n)
                        bExcludeDueToNameClash = #True
                        debugMsg(sProcName, "bExcludeDueToNameClash=" + strB(bExcludeDueToNameClash) + ", sInitialFileName=" + #DQUOTE$ + sInitialFileName + #DQUOTE$)
                      EndIf
                      Break
                    EndIf
                  Next n
                  If bExcludeDueToNameClash = #False
                    sProdFolderFileName = \sProdFolder + GetFilePart(sInitialFileName)
                    bFileCopied = #False
                    For nFilePass = 1 To 2
                      debugMsg(sProcName, "nFilePass=" + nFilePass)
                      ; file pass 1: process the audio file
                      ; file pass 2: process the Wavelab marker file (mrk) if it exists
                      bIgnoreThisFile = #False
                      If nFilePass = 1
                        sTmp1 = sInitialFileName
                        sTmp2 = sProdFolderFileName
                        If LCase(Left(sTmp1, Len(\sProdFolder))) = LCase(\sProdFolder)
                          ; file already in or below the prod folder
                          Break ; break out of the nFilePass loop, going to the next aAud(k)
                        EndIf
                      Else
                        sTmp1 = ignoreExtension(sInitialFileName) + ".mrk"
                        sTmp2 = \sProdFolder + GetFilePart(sTmp1)
                        debugMsg(sProcName, "calling FileExists() for sTmp2 and sProdFolderName")
                        If (FileExists(sTmp2)) And (FileExists(sProdFolderFileName))
                          ; mrk file and audio file both exist in prod folder
                          debugMsg(sProcName, "calling FileExists() for sTmp1 and sInitialFileName")
                          If (FileExists(sTmp1) = #False) And (FileExists(sInitialFileName)) And (bFileCopied)
                            ; mrk file does NOT exist in original location even though audio file still exists, and file was re-synced
                            ; so delete mrk file (rename with .bak) from the prod folder
                            sTmp3 = ignoreExtension(sTmp2) + ".bak"
                            ; if a .bak file already exists then delete it
                            debugMsg(sProcName, "calling FileExists() for sTmp3")
                            If FileExists(sTmp3)
                              DeleteFile(sTmp3)
                            EndIf
                            ; now rename the presumably-obsolete .mrk file to .bak
                            RenameFile(sTmp2, sTmp3)
                          EndIf
                        EndIf
                        If FileExists(sTmp1) = #False
                          bIgnoreThisFile = #True
                        EndIf
                      EndIf
                      
                      debugMsg(sProcName, "bIgnoreThisFile=" + strB(bIgnoreThisFile))
                      If bIgnoreThisFile = #False
                        If LCase(Left(sTmp1, Len(\sProdFolder))) = LCase(\sProdFolder)
                          bIgnoreThisFile = #True
                        Else
                          debugMsg(sProcName, "calling FileExists() for sTmp2")
                          If FileExists(sTmp2)
                            ; file of this name already exists in the Audio folder, so check if it appears to be the same file
                            ; qFile1Size = FileSize(sTmp1)
                            ; sFile1Modified = FormatDate(#SCS_CUE_FILE_DATE_FORMAT, GetFileDate(sTmp1, #PB_Date_Modified))
                            ; qFile2Size = FileSize(sTmp2)
                            ; sFile2Modified = FormatDate(#SCS_CUE_FILE_DATE_FORMAT, GetFileDate(sTmp2, #PB_Date_Modified))
                            ; If (sFile1Modified <> sFile2Modified) Or (qFile1Size <> qFile2Size)
                            If bSameButDifferent = #False
                              ; not the same file (because the sizes or dates modified are different)
                              If nNotCopiedIndex > ArraySize(gaFileNotCopied())
                                ReDim gaFileNotCopied(nNotCopiedIndex + 10)
                                debugMsg(sProcName, "ArraySize(gaFileNotCopied())=" + ArraySize(gaFileNotCopied()))
                              EndIf
                              gaFileNotCopied(nNotCopiedIndex)\sFileName = sTmp1
                              debugMsg(sProcName, "gaFileNotCopied(" + nNotCopiedIndex + ")\sFileName=" + gaFileNotCopied(nNotCopiedIndex)\sFileName)
                              gaFileNotCopied(nNotCopiedIndex)\sCue = aAud(k)\sCue
                              nNotCopiedIndex + 1
                              bIgnoreThisFile = #True
                            EndIf
                          EndIf
                        EndIf
                      EndIf
                      
                      If bIgnoreThisFile
                        debugMsg(sProcName, "bIgnoreThisFile=" + strB(bIgnoreThisFile))
                      EndIf
                      If bIgnoreThisFile = #False
                        ; debugMsg(sProcName, "calling FileExists() for sTmp2")
                        If FileExists(sTmp2, #False) = #False
                          SGT(WPF\lblStatus, LangPars("WPF", "Copying", Str(nFilesCopied+1) + "/" + Str(grWPF\nFilesToBeCopied) + ": " + GetFilePart(sTmp1)))
                          CopyFile(sTmp1, sTmp2)
                          ; debugMsg(sProcName, "calling FileExists() for sTmp2")
                          If FileExists(sTmp2, #False)
                            nCount + 1
                            If nFilePass = 1
                              bFileCopied = #True
                            EndIf
                            nFilesCopied + 1
                            WPF_DrawProgress(nFilesCopied, grWPF\nFilesToBeCopied)
                          EndIf
                          SGT(WPF\lblStatus, "")
                        EndIf
                        If nFilePass = 1
                          If sTmp2 <> sTmp1
                            For n = 0 To \nMaxUniqueFile
                              If LCase(\aUniqueFile(n)\sOldFile) = LCase(aAud(k)\sFileName)
                                \aUniqueFile(n)\sNewFile = sTmp2
                                Break
                              EndIf
                            Next n
                            debugMsg(sProcName, "changing aAud(" + getAudLabel(k) + ")\sFileName from " + #DQUOTE$ + aAud(k)\sFileName + #DQUOTE$ + " to " + #DQUOTE$ + sTmp2 + #DQUOTE$)
                            aAud(k)\sFileName = sTmp2
                            aAud(k)\sStoredFileName = encodeFileName(sTmp2)
                            debugMsg(sProcName, "aAud(" + getAudLabel(k) + ")\sStoredFileName=" + #DQUOTE$ + aAud(k)\sStoredFileName + #DQUOTE$)
                          EndIf
                        EndIf
                      EndIf
                      
                    Next nFilePass
                  EndIf ; EndIf bExcludeDueToNameClash = #False
                EndIf ; EndIf aAud(k)\bAudPlaceHolder = #False
              EndIf ; EndIf bProcessed
              k = aAud(k)\nNextAudIndex
            Wend
          EndIf
        EndIf ; EndIf aSub(j)\bSubTypeHasAuds
        j = aSub(j)\nNextSubIndex
      Wend
      If \bCopyCancelRequested
        Break
      EndIf
    Next i
    
    If \bCopyCancelRequested = #False
      SGT(WPF\lblStatus, LangPars("WPF", "Saving", \sCueFile))
      gbSaveAs = #False
      debugMsg(sProcName, "calling writeXMLCueFile(#False, #False, #False, #True)")
      writeXMLCueFile(#False, #False, #False, #True)
      WED_setWindowTitle()
      nFilesCopied + 1
      bCueFileCopied = #True
      WPF_DrawProgress(nFilesCopied, grWPF\nFilesToBeCopied)
      SGT(WPF\lblStatus, "")
    EndIf
    
    If \bCopyCancelRequested = #False
      If grCollectOptions\bCopyColorFile
        saveXMLColorFile(\sProdFolder)
        bColorFileCopied = #True
      EndIf
    EndIf
    
    If \bCopyCancelRequested = #False
      If grCollectOptions\bIncludeDevMaps
        writeXMLDevMapFile(grProd\sSelectedDevMapName, grProd\sProdId, #True)
        bDevMapsFileCopied = #True
      EndIf
    EndIf
    
    setMouseCursorNormal()
    
    If nCount > 0
      sMsg = LangPars("WPF", "FilesCopied", Str(nCount))
    EndIf
    If bCueFileCopied
      If sMsg
        sMsg + Chr(10)
      EndIf
      sMsg + LangPars("WPF", "CueFileCopied", GetFilePart(gsCueFile))
    EndIf
    If bColorFileCopied
      If sMsg
        sMsg + Chr(10)
      EndIf
      sMsg + Lang("WPF", "ColorFileCopied")
    EndIf
    If bDevMapsFileCopied
      If sMsg
        sMsg + Chr(10)
      EndIf
      sMsg + Lang("DevMap", "DevMapFileExported")
    EndIf
    CompilerIf 1=2
      If nNotCopiedIndex > 0
        If sMsg
          sMsg + Chr(10)
        EndIf
        ; sMsg + vbCrLf + "The following files were not copied because files of the same name already exist in the Production folder but appear to be different files (different size or date modified):"
        sMsg + Chr(10) + Lang("WPF", "NotCopied")
        For n = 0 To (nNotCopiedIndex-1)
          sMsg + Chr(10) + "    " + grText\sTextCue + " " + gaFileNotCopied(n)\sCue + ":  " + gaFileNotCopied(n)\sFileName
        Next n
      EndIf
    CompilerEndIf
    
    If \bCopyCancelRequested
      scsMessageRequester(GWT(#WPF), Lang("WPF", "Canceled") + Chr(10) + sMsg, #PB_MessageRequester_Ok|#MB_ICONEXCLAMATION)
    Else
      scsMessageRequester(GWT(#WPF), Lang("WPF", "Done") + Chr(10) + sMsg, #PB_MessageRequester_Ok|#MB_ICONINFORMATION)
    EndIf
    
    \bCopyThreadRunning = #False
    
  EndWith
  
  PostEvent(#SCS_Event_CollectThreadEnd, #WPF, 0)
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WPF_btnCollect_Click()
  PROCNAMEC()
  Protected sDriveRootFolder.s, sMsg.s
  
  debugMsg(sProcName, #SCS_START)
  
  sDriveRootFolder = getDriveRootFolder(grWPF\sProdFolder)
  getDriveFreeSpace(sDriveRootFolder) ; nb results returned in grCFH (CFH = Cue File Handler)
  
  With grCFH
    debugMsg(sProcName, "sDriveRootFolder=" + sDriveRootFolder + ", \bDriveFreeSpaceResult=" + strB(\bDriveFreeSpaceResult) +
                         ", grWPF\qDriveSpaceRequired=" + grWPF\qDriveSpaceRequired + ", \qDriveFreeSpaceBytes=" + \qDriveFreeSpaceBytes)
    If \bDriveFreeSpaceResult = #False
      sMsg = LangPars("WPF", "DriveSpaceError", sDriveRootFolder, \sDriveFreeSpaceMsg)
      scsMessageRequester(GWT(#WPF), sMsg, #PB_MessageRequester_Error)
      ProcedureReturn
    Else
      If grWPF\qDriveSpaceRequired > \qDriveFreeSpaceBytes
        sMsg = LangPars("WPF", "InsufficientSpace", sDriveRootFolder, SizeIt(grWPF\qDriveSpaceRequired), SizeIt(\qDriveFreeSpaceBytes))
        scsMessageRequester(GWT(#WPF), sMsg, #PB_MessageRequester_Warning)
        ProcedureReturn
      EndIf
    EndIf
  EndWith
  
  With grWPF
    
    WPF_setFormEnabled(#False)
    
    \sHoldCueFolder = gsCueFolder
    \sHoldCueFile = gsCueFile
    
    \sCueFile = \sProdFolder + GetFilePart(gsCueFile)
    
    gsCueFolder = \sProdFolder
    gsCueFile = \sCueFile
    
    If grCollectOptions\bSwitchToCollected
      updateRFL()
      WMN_setWindowTitle()
    EndIf
    
    \bCopyCancelRequested = #False
    CreateThread(@WPF_collectFiles(), 0)
    
  EndWith
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WPF_btnBrowse_Click()
  PROCNAMEC()
  Protected sProdFolder.s
  Protected bColorFileAlreadyExists
  Protected sDriveRootFolder.s
  Protected nDriveType
  Protected sMsg.s
  Protected nResponse
  Protected sCueFile.s
  
  debugMsg(sProcName, #SCS_START)
  
  With WPF
    
    sProdFolder = PathRequester(Lang("WPF", "PathRequester"), grGeneralOptions\sInitDir) ; See also comment near the end of this Procedure regarding PathRequester()
    If sProdFolder
      
      sDriveRootFolder = getDriveRootFolder(sProdFolder)
      debugMsg(sProcName, "sDriveRootFolder=" + sDriveRootFolder)
      nDriveType = getDriveType(sDriveRootFolder)
      debugMsg(sProcName, "nDriveType=" + decodeDriveType(nDriveType))
      Select nDriveType
        Case #DRIVE_FIXED, #DRIVE_RAMDISK
          ; OK
        Default
          grCollectOptions\bSwitchToCollected = #False
          SGS(\optSwitch[1], #True)
      EndSelect
      
      SGT(\txtProdFolder, sProdFolder)
      scsToolTip(\txtProdFolder, sProdFolder)
      grWPF\sProdFolder = sProdFolder
      sCueFile = sProdFolder + GetFilePart(grWPF\sCueFile)
      grWPF\sCueFile = sCueFile
      
      bColorFileAlreadyExists = WPF_checkColorFileAlreadyExists()
      
      setEnabled(\btnCollect, #True)
      GadgetToolTip(\btnCollect, LangPars("WPF", "btnCollectTT", RemoveString(getLeafName(sProdFolder),"\")))
    Else
      setEnabled(\btnCollect, #False)
    EndIf
    
    ; Mod 19Dec2023 11.10.0dr - do NOT assume color file is to be collected just because it exists - I (Mike) found that annoying every time I collect files!
;     If (bColorFileAlreadyExists) Or (gbDfltColorFile = #False)
;       grCollectOptions\bCopyColorFile = #True
;     Else
;       grCollectOptions\bCopyColorFile = #False
;     EndIf
    ; End of Mod 19Dec2023 11.10.0dr
    SGS(\chkCopyColorFile, grCollectOptions\bCopyColorFile)
    
    ; Added 01Jan2020 11.8.2au following bug report from Peter Holmes where the focus went back to the main window.
    ; On observing the video file he sent, it seems that activating PathRequester at the start of this Procedure briefly set focs back to the main window before returning focus to #WPF.
    ; That doesn't happen in my tests, and focus stays on #WPF.
    ; Added "SAW(#WPF)" to ensure focus stays on #WPF.
    SAW(#WPF)
    ; End added 01Jan2020 11.8.2au
    
    SAG(-1)
    
  EndWith
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WPF_Form_Show(bModal, nReturnFunction)
  PROCNAMEC()
  Protected bCancel
  
  debugMsg(sProcName, #SCS_START)
  
  debugMsg(sProcName, "calling checkDataChanged(#True)")
  bCancel = checkDataChanged(#True)
  If bCancel
    ; either user cancelled when asked about saving, or an error was detected during validation, so do not open new file
    ProcedureReturn #False
  EndIf

  If IsWindow(#WPF) = #False
    createfmCollectFiles()
  EndIf
  setFormPosition(#WPF, @grProdFolderWindow)
  setWindowModal(#WPF, bModal, nReturnFunction)
  WPF_drawForm()
  setWindowVisible(#WPF, #True)
  SAW(#WPF)
  
  debugMsg(sProcName, #SCS_END)
  ProcedureReturn #True
  
EndProcedure

Procedure WPF_btnShowExclusions_Click()
  PROCNAMEC()
  Protected n, sTitle.s, sMessage.s
  
  With grWPF
    For n = 1 To \nFileCount
      If \bFilePartClash(n)
        If sMessage
          sMessage + Chr(10)
        EndIf
        sMessage + #DQUOTE$ + \sFileName(n) + #DQUOTE$
      EndIf
    Next n
    If sMessage
      sTitle = Lang("WPF", "ColExcluded")
      scsMessageRequester(sTitle, sMessage)
    EndIf
  EndWith
  
EndProcedure

Procedure WPF_EventHandler()
  PROCNAMEC()
  Protected sMsg.s
  
  With WPF
    Select gnWindowEvent
        
      Case #PB_Event_CloseWindow
        WPF_Form_Unload(#PB_MessageRequester_Cancel)   ; user clicking the 'X' close window icon is equivalent to clicking the 'Cancel' button
        
      Case #PB_Event_Menu
        gnEventMenu = EventMenu()
        Select gnEventMenu
            
          Case #SCS_mnuKeyboardReturn   ; Return
            If getEnabled(\btnCollect)
              WPF_btnCollect_Click()
            EndIf
            
          Case #SCS_mnuKeyboardEscape   ; Escape
            If getEnabled(\btnCancel)
              If grWPF\bCopyThreadRunning
                grWPF\bCopyCancelRequested = #True
              Else
                WPF_Form_Unload(#PB_MessageRequester_Cancel)   ; #PB_MessageRequester_Cancel indicates 'Cancel' button pressed
              EndIf
            EndIf
            
        EndSelect
        
      Case #PB_Event_Gadget
        ; debugMsg(sProcName, "gnEventGadgetNo=G" + gnEventGadgetNo)
        Select gnEventGadgetNoForEvHdlr
            
          Case \btnBrowse
            WPF_btnBrowse_Click()
            WPF_drawSpaceReqdCanvas()
            
          Case \btnCancel
            If grWPF\bCopyThreadRunning
              grWPF\bCopyCancelRequested = #True
            Else
              WPF_Form_Unload(#PB_MessageRequester_Cancel)   ; #PB_MessageRequester_Cancel indicates 'Cancel' button pressed
            EndIf
            
          Case \btnCollect
            WPF_btnCollect_Click()
            
          Case \btnHelp
            displayHelpTopic("scs_collect.htm")
            
          Case \btnShowExclusions
            WPF_btnShowExclusions_Click()
            
          Case \chkCopyColorFile
            grCollectOptions\bCopyColorFile = GGS(\chkCopyColorFile)
            WPF_drawSpaceReqdCanvas()
            
          Case \chkExclPlaylists
            grCollectOptions\bExcludePlaylists = GGS(\chkExclPlaylists)
            WPF_drawSpaceReqdCanvas()
            
          Case \chkInclDevMaps
            grCollectOptions\bIncludeDevMaps = GGS(\chkInclDevMaps)
            WPF_drawSpaceReqdCanvas()
          
          Case \cntSwitch
            ; ignore events
            
          Case \cvsProgress
            ; ignore events
            
          Case \cvsSpaceReqd
            ; ignore events
            
          Case \optSwitch[0]
            If GGS(\optSwitch[0])
              grCollectOptions\bSwitchToCollected = #True
            Else
              grCollectOptions\bSwitchToCollected = #False
            EndIf
            
          Case \txtProdFolder
            ; no action
            
          Default
            debugMsg(sProcName, "gnEventGadgetNo=G" + gnEventGadgetNo + ", gnEventType=" + decodeEventType())
        EndSelect
        
      Case #SCS_Event_CollectThreadEnd
        debugMsg(sProcName, "processing #SCS_Event_CollectThreadEnd, grWPF\bCopyCancelRequested=" + strB(grWPF\bCopyCancelRequested))
        If grWPF\bCopyCancelRequested
          grWPF\bCopyCancelRequested = #False
          WPF_setFormEnabled(#True)
          WPF_drawSpaceReqdCanvas()
        Else
          WPF_Form_Unload(#PB_MessageRequester_Ok)   ; #PB_MessageRequester_Ok indicates 'OK' button pressed
          debugMsg(sProcName, "grCollectOptions\bSwitchToCollected=" + strB(grCollectOptions\bSwitchToCollected))
          If grCollectOptions\bSwitchToCollected = #False
            gsCueFile = grWPF\sHoldCueFile
            gsCueFolder = grWPF\sHoldCueFolder
            sMsg = LangPars("WPF", "Reopening", gsCueFile)
            debugMsg(sProcName, sMsg)
            scsMessageRequester(Lang("WPF", "Window"), sMsg)
            debugMsg(sProcName, "calling closeAndReopenCurrCueFile()")
            closeAndReopenCurrCueFile()
            debugMsg(sProcName, "returned from closeAndReopenCurrCueFile()")
          EndIf
        EndIf
        
    EndSelect
  EndWith
  
EndProcedure

; EOF