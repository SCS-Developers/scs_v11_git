; File: fmPrintCueList.pbi

EnableExplicit

Procedure WPR_CreatePointFont(hdc, fontname.s, pointsize, style=0) 
  ; procedure supplied by srod in PB Coding Questions Forum under the topic 'Font size when using PrinterOutput?' 
  ;Returns a fontID (not a font#) for a given hdc.
  ;'pointsize' refers to proper points (1/72 inch).
  Protected logy, Height, font, weight=400, italic, underline, strikeout 
  ;Convert the required point size to device units. 
  ;Recall that each typographic point = 1/72 of an inch. 
  logy = GetDeviceCaps_(hdc,#LOGPIXELSY) 
  Height = -MulDiv_(pointsize, logy, 72) 
  If style & #PB_Font_Bold 
    weight = #FW_BOLD 
  EndIf 
  If style & #PB_Font_Italic 
    italic = 1 
  EndIf 
  If style & #PB_Font_Underline 
    underline = 1 
  EndIf 
  If style & #PB_Font_StrikeOut 
    strikeout = 1 
  EndIf 
  font = CreateFont_(Height, 0, 0, 0,weight,italic,underline,strikeout,0,0,0,0,0,fontname) 
  ProcedureReturn font 
EndProcedure

Procedure WPR_btnCopy_Click()
  
  WPR_copyToWindowsClipboard()
  scsMessageRequester(GWT(#WPR), Lang("WPR", "copied"))  ; "Cue List copied to Windows Clipboard"
  
EndProcedure

Procedure WPR_mnuColDefaults_Click()
  Protected n
  
  For n = 0 To grGrdCuePrintInfo\nMaxColNo
    With grGrdCuePrintInfo\aCol(n)
      \nCurWidth = \nDefWidth
      \nCurColNo = \nDefColNo
      If \nCurColNo >= 0
        \bColVisible = #True
      Else
        \bColVisible = #False
      EndIf
      \nCurColOrder = \nCurColNo
    EndWith
  Next n
  WPR_setupPrintGrid()
  WPR_loadPrintGrid()
EndProcedure

Procedure WPR_mnuColRevert_Click()
  Protected n
  
  For n = 0 To grGrdCuePrintInfo\nMaxColNo
    With grGrdCuePrintInfo\aCol(n)
      \nCurWidth = \nIniWidth
      \nCurColNo = \nIniColNo
      If \nCurColNo >= 0
        \bColVisible = #True
      Else
        \bColVisible = #False
      EndIf
      \nCurColOrder = \nCurColNo
    EndWith
  Next n
  WPR_setupPrintGrid()
  WPR_loadPrintGrid()
EndProcedure

Procedure WPR_btnPrint_Click()
  PROCNAMEC()
  Protected nPrintRequester
  
  debugMsg(sProcName, #SCS_START)
  
  nPrintRequester = PrintRequester()    ; returns 0 is no printer available or user cancelled
  debugMsg(sProcName, "PrintRequester() returned " + nPrintRequester)
  If nPrintRequester
    WPR_printCueList()
  EndIf
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WPR_Form_Load(nParentWindow)
  PROCNAMEC()
  
  debugMsg(sProcName, #SCS_START)

  rWPR\bFormLoading = #True
  
  If IsWindow(#WPR) = #False Or gaWindowProps(#WPR)\nParentWindow <> nParentWindow
    createfmPrintCueList(nParentWindow)
  EndIf
  
  WPR_setupGridDefaults()
  WPR_setupPrintGrid()
  
  With grPrintOptions
    setCheckboxStateFromBoolean(WPR\chkA, \bChkA)
    setCheckboxStateFromBoolean(WPR\chkE, \bChkE)
    setCheckboxStateFromBoolean(WPR\chkF, \bChkF)
    setCheckboxStateFromBoolean(WPR\chkG, \bChkG)
    setCheckboxStateFromBoolean(WPR\chkI, \bChkI)
    setCheckboxStateFromBoolean(WPR\chkJ, \bChkJ)
    setCheckboxStateFromBoolean(WPR\chkK, \bChkK)
    setCheckboxStateFromBoolean(WPR\chkL, \bChkL)
    setCheckboxStateFromBoolean(WPR\chkM, \bChkM)
    setCheckboxStateFromBoolean(WPR\chkN, \bChkN)
    setCheckboxStateFromBoolean(WPR\chkP, \bChkP)
    setCheckboxStateFromBoolean(WPR\chkQ, \bChkQ)
    setCheckboxStateFromBoolean(WPR\chkR, \bChkR)
    setCheckboxStateFromBoolean(WPR\chkS, \bChkS)
    setCheckboxStateFromBoolean(WPR\chkT, \bChkT)
    setCheckboxStateFromBoolean(WPR\chkU, \bChkU)
    setCheckboxStateFromBoolean(WPR\chkIncludeHotkeys, \bIncludeHotkeys)
    setCheckboxStateFromBoolean(WPR\chkIncludeSubCues, \bIncludeSubCues)
    setCheckboxStateFromBoolean(WPR\chkManualCuesOnly, \bManualCuesOnly)
  EndWith
  
  rWPR\bFormLoading = #False

  debugMsg(sProcName, "calling loadPrintGrid")
  WPR_loadPrintGrid()
  
  setFormPosition(#WPR, @grPrintCueListWindow)
  setWindowVisible(#WPR, #True)
  
  debugMsg(sProcName,#SCS_END)
  
EndProcedure

Procedure WPR_loadPrintGrid()
  PROCNAMEC()
  Protected i, j, nRow
  Protected bWantThis, bWantThisCue
  Protected sCol.s, nColNo, sColType.s
  Protected sActivation.s
  Protected bCueIncluded, nSubCount
  Protected sText.s
  Protected nMyMaxColNo, m, n
  Protected sLevel.s
  Protected nCueLengthsTotal, sCueLengthsTotal.s
  
  If rWPR\bFormLoading
    ProcedureReturn
  EndIf

  debugMsg(sProcName, #SCS_START)
  
  With grProd
    If Len(\sCueListTitle) = 0
      If \bTemplate
        \sCueListTitle = \sTmName
      Else
        \sCueListTitle = \sTitle
      EndIf
    EndIf
    SGT(WPR\txtCueListTitle, \sCueListTitle)
  EndWith
  
  debugMsg(sProcName, "txtCueListTitle=" + GGT(WPR\txtCueListTitle))

  ClearGadgetItems(WPR\grdCuePrint)
  
  nMyMaxColNo = -1
  For n = 0 To grGrdCuePrintInfo\nMaxColNo
    If grGrdCuePrintInfo\aCol(n)\nCurColNo > nMyMaxColNo
      nMyMaxColNo = grGrdCuePrintInfo\aCol(n)\nCurColNo
    EndIf
  Next n
  
  nRow = -1
  
  For i = 1 To gnLastCue
    If GGS(WPR\chkManualCuesOnly) = #PB_Checkbox_Checked
      Select aCue(i)\nActivationMethod
        Case #SCS_ACMETH_AUTO, #SCS_ACMETH_AUTO_PLUS_CONF, #SCS_ACMETH_MTC, #SCS_ACMETH_OCM, #SCS_ACMETH_TIME, #SCS_ACMETH_CALL_CUE
          Continue
      EndSelect
      If aCue(i)\nActivationMethod & #SCS_ACMETH_EXT_BIT
        Continue
      EndIf
    EndIf
    bWantThisCue = #False
    ; If (aCue(i)\bCueEnabled) And (aCue(i)\nCueState <> #SCS_CUE_IGNORED) And ((aCue(i)\nHideCueOpt <> #SCS_HIDE_ENTIRE_CUE) Or (grOperModeOptions(gnOperMode)\bShowHiddenAutoStartCues))
    If (aCue(i)\bCueEnabled) And (aCue(i)\nCueState <> #SCS_CUE_IGNORED) ; Changed 29Nov2022 11.9.7aq following test of Stuart Barry's cue file where some cues were not 'printed' but I expected them to be included.
      bCueIncluded = #False
      nSubCount = 0
      j = aCue(i)\nFirstSubIndex
      While j >= 0
        nSubCount = nSubCount + 1
        j = aSub(j)\nNextSubIndex
      Wend
      
      j = aCue(i)\nFirstSubIndex
      While j >= 0
        With aSub(j)
          
          bWantThis = #False
          If \bSubTypeA And GGS(WPR\chkA) = #PB_Checkbox_Checked
            bWantThis = #True
          EndIf
          If \bSubTypeE And GGS(WPR\chkE) = #PB_Checkbox_Checked
            bWantThis = #True
          EndIf
          If \bSubTypeF And GGS(WPR\chkF) = #PB_Checkbox_Checked
            bWantThis = #True
          EndIf
          If \bSubTypeG And GGS(WPR\chkG) = #PB_Checkbox_Checked
            bWantThis = #True
          EndIf
          If \bSubTypeI And GGS(WPR\chkI) = #PB_Checkbox_Checked
            bWantThis = #True
          EndIf
          If \bSubTypeJ And GGS(WPR\chkJ) = #PB_Checkbox_Checked
            bWantThis = #True
          EndIf
          If \bSubTypeK And GGS(WPR\chkK) = #PB_Checkbox_Checked
            bWantThis = #True
          EndIf
          If \bSubTypeL And GGS(WPR\chkL) = #PB_Checkbox_Checked
            bWantThis = #True
          EndIf
          If \bSubTypeM And GGS(WPR\chkM) = #PB_Checkbox_Checked
            bWantThis = #True
          EndIf
          If \bSubTypeN And GGS(WPR\chkN) = #PB_Checkbox_Checked
            bWantThis = #True
          EndIf
          If \bSubTypeP And GGS(WPR\chkP) = #PB_Checkbox_Checked
            bWantThis = #True
          EndIf
          If \bSubTypeQ And GGS(WPR\chkQ) = #PB_Checkbox_Checked
            bWantThis = #True
          EndIf
          If \bSubTypeR And GGS(WPR\chkR) = #PB_Checkbox_Checked
            bWantThis = #True
          EndIf
          If \bSubTypeS And GGS(WPR\chkS) = #PB_Checkbox_Checked
            bWantThis = #True
          EndIf
          If \bSubTypeT And GGS(WPR\chkT) = #PB_Checkbox_Checked
            bWantThis = #True
          EndIf
          If \bSubTypeU And GGS(WPR\chkU) = #PB_Checkbox_Checked
            bWantThis = #True
          EndIf
          If \bHotkey And GGS(WPR\chkIncludeHotkeys) = #PB_Checkbox_Unchecked
            bWantThis = #False
          EndIf
          If \nSubNo > 1 And GGS(WPR\chkIncludeSubCues) = #PB_Checkbox_Unchecked
            bWantThis = #False
          EndIf
          
          If bWantThis
            bWantThisCue = #True
            If (bCueIncluded = #False) And (nSubCount > 1) And (GGS(WPR\chkIncludeSubCues) = #PB_Checkbox_Checked)
              bCueIncluded = #True
              nRow + 1
              sText = ""
              If nMyMaxColNo >= 0
                For m = 0 To nMyMaxColNo
                  For n = 0 To grGrdCuePrintInfo\nMaxColNo
                    If grGrdCuePrintInfo\aCol(n)\nCurColNo = m
                      Select n
                        Case #SCS_GRDCUEPRINT_CU
                          sText + aCue(i)\sCue
                        Case #SCS_GRDCUEPRINT_PG
                          sText + aCue(i)\sPageNo
                        Case #SCS_GRDCUEPRINT_DE
                          sText + aCue(i)\sCueDescr
                        Case #SCS_GRDCUEPRINT_MC
                          sText + aCue(i)\sMidiCue
                        Case #SCS_GRDCUEPRINT_WR
                          sText + aCue(i)\sWhenReqd
                        Case #SCS_GRDCUEPRINT_AC
                          sText + getCueActivationMethodForDisplay(i)
                      EndSelect
                    EndIf
                  Next n
                  If m < nMyMaxColNo
                    sText + Chr(10)
                  EndIf
                Next m
              EndIf
              AddGadgetItem(WPR\grdCuePrint, nRow, sText)
            EndIf
            
            nRow + 1
            sText = ""
            If nMyMaxColNo >= 0
              For m = 0 To nMyMaxColNo
                For n = 0 To grGrdCuePrintInfo\nMaxColNo
                  If grGrdCuePrintInfo\aCol(n)\nCurColNo = m
                    Select n
                      Case #SCS_GRDCUEPRINT_CU  ; cue or <subno>
                        If bCueIncluded = #False
                          sText + aCue(i)\sCue
                        Else
                          sText + "<" + \nSubNo + ">"
                        EndIf
                        
                      Case #SCS_GRDCUEPRINT_PG  ; page
                        If bCueIncluded = #False
                          sText + aCue(i)\sPageNo
                        EndIf
                        
                      Case #SCS_GRDCUEPRINT_DE  ; description
                        If bCueIncluded = #False
                          sText + aCue(i)\sCueDescr
                        Else
                          sText + \sSubDescr
                        EndIf
                        
                      Case #SCS_GRDCUEPRINT_MC  ; midi cue number
                        If bCueIncluded = #False
                          sText + aCue(i)\sMidiCue
                        EndIf
                        
                      Case #SCS_GRDCUEPRINT_WR  ; when required
                        If bCueIncluded = #False
                          sText + aCue(i)\sWhenReqd
                        EndIf
                        
                      Case #SCS_GRDCUEPRINT_AC  ; activation
                        If bCueIncluded = #False
                          sText + getCueActivationMethodForDisplay(i)
;                         ElseIf \nRelStartTime >= 0
;                           sText + "rel " + timeToString(\nRelStartTime, \nRelStartTime)
                        ElseIf (\nRelStartTime > 0) Or (\nRelStartMode > #SCS_RELSTART_AS_CUE)
                          sText + "rel " + RelStartToString(\nRelStartTime, \nRelStartMode)
                        EndIf
                        
                      Case #SCS_GRDCUEPRINT_CT ; cue type
                        sText + decodeSubTypeL(\sSubType, j)
                        
                      Case #SCS_GRDCUEPRINT_FN ; file name
                        sText + getSubFileNameForGrid(j)
                        
                      Case #SCS_GRDCUEPRINT_DU ; length
                        sText + getSubLengthForGrid(j)
                        
                      Case #SCS_GRDCUEPRINT_FT ; file type
                        sText + getSubFileTypeForGrid(j)
                        
                      Case #SCS_GRDCUEPRINT_SD ; device
                        sText + loadDevInfoForSub(j)
                        
                      Case #SCS_GRDCUEPRINT_LV ; level (dB)
                        sLevel = getSubDBLevelForGrid(j)
                        If sLevel
                          sText + sLevel + "dB"
                        EndIf
                        
                    EndSelect
                  EndIf
                Next n
                If m < nMyMaxColNo
                  sText + Chr(10)
                EndIf
              Next m
            EndIf
            AddGadgetItem(WPR\grdCuePrint, nRow, sText)
            
          EndIf
          
          j = \nNextSubIndex
        EndWith
      Wend
    EndIf
    If bWantThisCue
      ; debugMsg(sProcName, "getCueLength(" + getCueLabel(i) + ")=" + getCueLength(i) + " (" + timeToString(getCueLength(i)) + ")")
      nCueLengthsTotal + getCueLength(i)
    EndIf

  Next i
  
  sCueLengthsTotal = "  " + Lang("WPR", "lblCueLengthsTotal") + " " + timeToStringT(nCueLengthsTotal) + " " ; double-space at start as it appears to look better
  SGT(WPR\lblCueLengthsTotal, sCueLengthsTotal)
  setGadgetWidth(WPR\lblCueLengthsTotal)
  
EndProcedure

Procedure WPR_Form_Unload()
  PROCNAMEC()

  debugMsg(sProcName, #SCS_START)

  getFormPosition(#WPR, @grPrintCueListWindow)

  With grPrintOptions
    \bChkA = GGS(WPR\chkA)
    \bChkE = GGS(WPR\chkE)
    \bChkF = GGS(WPR\chkF)
    \bChkG = GGS(WPR\chkG)
    \bChkI = GGS(WPR\chkI)
    \bChkJ = GGS(WPR\chkJ)
    \bChkK = GGS(WPR\chkK)
    \bChkL = GGS(WPR\chkL)
    \bChkM = GGS(WPR\chkM)
    \bChkN = GGS(WPR\chkN)
    \bChkP = GGS(WPR\chkP)
    \bChkQ = GGS(WPR\chkQ)
    \bChkR = GGS(WPR\chkR)
    \bChkS = GGS(WPR\chkS)
    \bChkT = GGS(WPR\chkT)
    \bChkU = GGS(WPR\chkU)
    \bIncludeHotkeys = GGS(WPR\chkIncludeHotkeys)
    \bIncludeSubCues = GGS(WPR\chkIncludeSubCues)
    \bManualCuesOnly = GGS(WPR\chkManualCuesOnly)
  EndWith

  WPR_savePrintRegSettings()
  
  unsetWindowModal(#WPR)
  setWindowVisible(#WPR, #False)
  scsCloseWindow(#WPR)

EndProcedure

Procedure WPR_txtCueListTitle_Validate()
  grProd\sCueListTitle = Trim(GGT(WPR\txtCueListTitle))
EndProcedure

Procedure WPR_setupPrintGrid()
  PROCNAMEC()
  Protected bGrdVisible
  Protected m, n
  Protected nMaxVisibleColNo
  
  debugMsg(sProcName, #SCS_START)
  
  ; this procedure clears any existing rows and columns in the grid, and then adds the 'current' visible columns
  ; the procedure does not populate the rows

  With WPR
    bGrdVisible = getVisible(\grdCuePrint)
    setVisible(\grdCuePrint, #False)
    
    ; clear cue list
    ClearGadgetItems(\grdCuePrint)
    
    ; remove existing columns
    removeAllGadgetColumns(\grdCuePrint)
    
    nMaxVisibleColNo = -1
    
    For m = 0 To grGrdCuePrintInfo\nMaxColNo
      grGrdCuePrintInfo\aCol(m)\nCurColNo = grGrdCuePrintInfo\aCol(m)\nCurColOrder
    Next m
    
    ; add the visible columns that have an 'nCurColNo'
    For m = 0 To grGrdCuePrintInfo\nMaxColNo
      For n = 0 To grGrdCuePrintInfo\nMaxColNo
        If grGrdCuePrintInfo\aCol(n)\nCurColNo = m
          ; add a column, setting the column title and the column width
          debugMsg(sProcName, "calling AddGadgetColumn(\grdCuePrint, "+ m + ", " + grGrdCuePrintInfo\aCol(n)\sTitle + ", " + grGrdCuePrintInfo\aCol(n)\nCurWidth + ")")
          AddGadgetColumn(\grdCuePrint, m, grGrdCuePrintInfo\aCol(n)\sTitle, grGrdCuePrintInfo\aCol(n)\nCurWidth)
          nMaxVisibleColNo = m
          Break ; break n loop
        EndIf
      Next n
    Next m
    
    grGrdCuePrintInfo\nMaxVisibleColNo = nMaxVisibleColNo
    debugMsg(sProcName, "\nMaxColNo=" + grGrdCuePrintInfo\nMaxColNo + ", \nMaxVisibleColNo=" + grGrdCuePrintInfo\nMaxVisibleColNo)
    
    setVisible(\grdCuePrint, bGrdVisible)
  EndWith
  
  WPR_setPrintColMenu()
  
EndProcedure

Procedure WPR_setPrintColMenu()
  PROCNAMEC()
  With grdCuePrint
    SetMenuItemState(#WPR_mnuWindowMenu, #WPR_mnuColCU, grGrdCuePrintInfo\aCol(#SCS_GRDCUEPRINT_CU)\bColVisible)
    SetMenuItemState(#WPR_mnuWindowMenu, #WPR_mnuColDE, grGrdCuePrintInfo\aCol(#SCS_GRDCUEPRINT_DE)\bColVisible)
    SetMenuItemState(#WPR_mnuWindowMenu, #WPR_mnuColPG, grGrdCuePrintInfo\aCol(#SCS_GRDCUEPRINT_PG)\bColVisible)
    SetMenuItemState(#WPR_mnuWindowMenu, #WPR_mnuColCT, grGrdCuePrintInfo\aCol(#SCS_GRDCUEPRINT_CT)\bColVisible)
    SetMenuItemState(#WPR_mnuWindowMenu, #WPR_mnuColAC, grGrdCuePrintInfo\aCol(#SCS_GRDCUEPRINT_AC)\bColVisible)
    SetMenuItemState(#WPR_mnuWindowMenu, #WPR_mnuColFN, grGrdCuePrintInfo\aCol(#SCS_GRDCUEPRINT_FN)\bColVisible)
    SetMenuItemState(#WPR_mnuWindowMenu, #WPR_mnuColDU, grGrdCuePrintInfo\aCol(#SCS_GRDCUEPRINT_DU)\bColVisible)
    SetMenuItemState(#WPR_mnuWindowMenu, #WPR_mnuColSD, grGrdCuePrintInfo\aCol(#SCS_GRDCUEPRINT_SD)\bColVisible)
    SetMenuItemState(#WPR_mnuWindowMenu, #WPR_mnuColWR, grGrdCuePrintInfo\aCol(#SCS_GRDCUEPRINT_WR)\bColVisible)
    SetMenuItemState(#WPR_mnuWindowMenu, #WPR_mnuColMC, grGrdCuePrintInfo\aCol(#SCS_GRDCUEPRINT_MC)\bColVisible)
    SetMenuItemState(#WPR_mnuWindowMenu, #WPR_mnuColFT, grGrdCuePrintInfo\aCol(#SCS_GRDCUEPRINT_FT)\bColVisible)
    SetMenuItemState(#WPR_mnuWindowMenu, #WPR_mnuColLV, grGrdCuePrintInfo\aCol(#SCS_GRDCUEPRINT_LV)\bColVisible)
  EndWith
EndProcedure

Procedure WPR_savePrintRegSettings()
  PROCNAMEC()
  Protected sPrefString.s
  Protected bPrefsOpenAtStart, sPrefGroupAtStart.s
  
  COND_OPEN_PREFS("Print")  ; COND_OPEN_PREFS("Print")
  
  updateGridInfoFromPhysicalLayout(@grGrdCuePrintInfo)
  sPrefString = grGrdCuePrintInfo\sLayoutString
  WritePreferenceString("PrintGridColLayout2", sPrefString)

  With grPrintOptions
    sPrefString = ""
    If \bChkA : sPrefString + "A" : EndIf
    If \bChkE : sPrefString + "E" : EndIf
    If \bChkF : sPrefString + "F" : EndIf
    If \bChkG : sPrefString + "G" : EndIf
    If \bChkI : sPrefString + "I" : EndIf
    If \bChkJ : sPrefString + "J" : EndIf
    If \bChkK : sPrefString + "K" : EndIf
    If \bChkL : sPrefString + "L" : EndIf
    If \bChkM : sPrefString + "M" : EndIf
    If \bChkN : sPrefString + "N" : EndIf
    If \bChkP : sPrefString + "P" : EndIf
    If \bChkQ : sPrefString + "Q" : EndIf
    If \bChkR : sPrefString + "R" : EndIf
    If \bChkS : sPrefString + "S" : EndIf
    If \bChkT : sPrefString + "T" : EndIf
    If \bChkU : sPrefString + "U" : EndIf
    WritePreferenceString("CueTypes", sPrefString)
    WritePreferenceInteger("IncludeHotkeys", \bIncludeHotkeys)
    WritePreferenceInteger("IncludeSubCues", \bIncludeSubCues)
    WritePreferenceInteger("ManualCuesOnly", \bManualCuesOnly)
  EndWith
  
  COND_CLOSE_PREFS()
  
EndProcedure

Procedure WPR_copyToWindowsClipboard()
  PROCNAMEC()
  Protected nMaxVisibleColNo
  Protected iRow, iCol
  Protected sClipString.s
  
  updateGridInfoFromPhysicalLayout(@grGrdCuePrintInfo)
  WPR_setupPrintGrid()
  WPR_loadPrintGrid()
  
  nMaxVisibleColNo = grGrdCuePrintInfo\nMaxVisibleColNo
  
  ; ------------ column headers
  For iCol = 0 To nMaxVisibleColNo
    sClipString + GetGadgetItemText(WPR\grdCuePrint, -1, iCol)
    If iCol < nMaxVisibleColNo
      sClipString + Chr(9)
    Else
      sClipString + #CRLF$
    EndIf
  Next iCol
  
  ; ------------ grid values
  For iRow = 0 To CountGadgetItems(WPR\grdCuePrint)-1
    For iCol = 0 To nMaxVisibleColNo
      sClipString + GetGadgetItemText(WPR\grdCuePrint, iRow, iCol)
      If iCol < nMaxVisibleColNo
        sClipString + Chr(9)
      Else
        sClipString + #CRLF$
      EndIf
    Next iCol
  Next iRow
  
  debugMsg(sProcName, "sClipString=" + sClipString)

  ClearClipboard()
  SetClipboardText(sClipString)

EndProcedure

Procedure WPR_Form_Show(nParentWindow, bModal=#True)
  
  ; If IsWindow(#WPR) = #False Or gaWindowProps(#WPR)\nParentWindow <> nParentWindow
    WPR_Form_Load(nParentWindow)
  ; EndIf
  setWindowModal(#WPR, bModal)
  setWindowVisible(#WPR, #True)
  SetActiveWindow(#WPR)
EndProcedure

Procedure WPR_setupGridDefaults()
  PROCNAMEC()
  Protected n, nColNo
  Protected nDefGrdWidth
  
  If StartDrawing(WindowOutput(#WPR))
      
      DrawingFont(GetGadgetFont(WPR\grdCuePrint))
      
      nColNo = -1
      
      With grGrdCuePrintInfo\aCol(#SCS_GRDCUEPRINT_CU) ; Cue
        nColNo + 1
        \nDefColNo = nColNo
        \nDefWidth = TextWidth("S/C 999S-")   ; note: no language translation required as these text strings are not displayed
        \sTitle = Lang("Common", "Cue")
      EndWith
      
      With grGrdCuePrintInfo\aCol(#SCS_GRDCUEPRINT_PG) ; Page
        nColNo + 1
        \nDefColNo = nColNo
        \nDefWidth = TextWidth("p1234xx")
        \sTitle = Lang("Common", "Page")
      EndWith
      
      With grGrdCuePrintInfo\aCol(#SCS_GRDCUEPRINT_DE) ; Description
        nColNo + 1
        \nDefColNo = nColNo
        \nDefWidth = TextWidth("This is a description of a show cue")
        \sTitle = Lang("Common", "Description")
      EndWith
      
      With grGrdCuePrintInfo\aCol(#SCS_GRDCUEPRINT_CT) ; Cue Type
        nColNo + 1
        \nDefColNo = nColNo
        \nDefWidth = TextWidth("Snd,LvlChg&Stp--")
        \sTitle = Lang("Common", "CueType")
      EndWith
      
      With grGrdCuePrintInfo\aCol(#SCS_GRDCUEPRINT_AC) ; Activation
        nColNo + 1
        \nDefColNo = nColNo
        \nDefWidth = TextWidth("HKey (Trig) F3--")
        \sTitle = Lang("Common", "Activation")
      EndWith
      
      With grGrdCuePrintInfo\aCol(#SCS_GRDCUEPRINT_FN) ; File / Info
        nColNo + 1
        \nDefColNo = nColNo
        \nDefWidth = TextWidth("wwwwwwwwwwwwwwwwww.wav")
        \sTitle = Lang("Common", "FileInfo")
      EndWith
      
      With grGrdCuePrintInfo\aCol(#SCS_GRDCUEPRINT_DU) ; Length (Duration)
        nColNo + 1
        \nDefColNo = nColNo
        \nDefWidth = TextWidth("88:88.888-")
        \sTitle = Lang("Common", "Length")
      EndWith
      
      With grGrdCuePrintInfo\aCol(#SCS_GRDCUEPRINT_SD) ; Device
        nColNo + 1
        \nDefColNo = nColNo
        \nDefWidth = TextWidth("Device xxx")
        \sTitle = grText\sTextDevice
      EndWith
      
      With grGrdCuePrintInfo\aCol(#SCS_GRDCUEPRINT_WR) ; When Required
        \nDefColNo=-1  ; not visible
        \nDefWidth = TextWidth("This is a when required desc")
        \sTitle = Lang("Common", "WhenReqd")
      EndWith
      
      With grGrdCuePrintInfo\aCol(#SCS_GRDCUEPRINT_MC) ; MIDI Cue #
        \nDefColNo = -1  ; not visible
        \nDefWidth = TextWidth("MIDI/DMX Cue")
        \sTitle = Lang("Common", "MIDICue")
      EndWith
      
      With grGrdCuePrintInfo\aCol(#SCS_GRDCUEPRINT_FT) ; File Type
        \nDefColNo = -1  ; not visible
        \nDefWidth = TextWidth("WAV (44100Hz, 16 Bit, Stereo)--")
        \sTitle = Lang("Common", "FileType")
      EndWith
      
      With grGrdCuePrintInfo\aCol(#SCS_GRDCUEPRINT_LV) ; Level (dB)
        \nDefColNo = -1  ; not visible
        \nDefWidth = TextWidth(" +12.4dB--")
        \sTitle = Lang("Common", "Level")
      EndWith
      
    StopDrawing()
  EndIf
  
  For n = 0 To grGrdCuePrintInfo\nMaxColNo
    With grGrdCuePrintInfo\aCol(n)
      \nCurWidth = \nDefWidth
      \nCurColNo = \nDefColNo
      If \nDefColNo >= 0
        nDefGrdWidth + \nDefWidth
      EndIf
    EndWith
  Next n
  debugMsg(sProcName, "nDefGrdWidth=" + nDefGrdWidth + ", GadgetWidth(WPR\grdCuePrint)=" + GadgetWidth(WPR\grdCuePrint))
  
  debugMsg(sProcName,"grGrdCuePrintInfo\sLayoutString=" + grGrdCuePrintInfo\sLayoutString)
  If grGrdCuePrintInfo\sLayoutString
    unpackGridLayoutString(@grGrdCuePrintInfo, #SCS_GT_GRDCUEPRINT)
  EndIf
  
  For n = 0 To grGrdCuePrintInfo\nMaxColNo
    With grGrdCuePrintInfo\aCol(n)
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

Procedure WPR_printCueList()
  PROCNAMEC()
  Protected nPrintWidth, nPrintHeight
  Protected nTopMargin, nLeftMargin
  Protected nMaxColNo
  Protected dXScale.d
  Protected nCols, nRows
  Protected sText.s, sTextTruncated.s
  Protected nX, nY
  Protected nCurrentX, nCurrentY
  Protected nLeft, nTop, nWidth, nHeight
  Protected nPageNo, nEOP
  Protected nRowHeight, nVertSpacing
  Protected nMaxVisibleColNo
  Protected nCol, j, nRow
  Protected nColWidth
  Protected bJustPrintedPageNo
  Protected sHeading.s
  Protected hdcPrinter
  Protected hFontIDNormal8, hFontIDBold8, hFontIDNormal12ul
  Protected nOneCharWidth8
  
  debugMsg(sProcName, #SCS_START)
  
  updateGridInfoFromPhysicalLayout(@grGrdCuePrintInfo)
  WPR_setupPrintGrid()
  WPR_loadPrintGrid()
  
  nMaxVisibleColNo = grGrdCuePrintInfo\nMaxVisibleColNo
  sHeading = GGT(WPR\txtCueListTitle)
  
  ; ----------- Establish print & screen metrics
  bJustPrintedPageNo = #False
  
  If StartPrinting("SCS_Cue_List")
    nPrintWidth = PrinterPageWidth()
    nPrintHeight = PrinterPageHeight()
    nTopMargin = 0
    nLeftMargin = 0
    
    hdcPrinter = StartDrawing(PrinterOutput())
    If hdcPrinter
      ; create printer fonts because the PB LoadFont() procedure doesn't handle printer font sizes very well
      hFontIDNormal8 = WPR_CreatePointFont(hdcPrinter, gsDefFontName, 8) 
      hFontIDBold8 = WPR_CreatePointFont(hdcPrinter, gsDefFontName, 8, #PB_Font_Bold) 
      hFontIDNormal12ul = WPR_CreatePointFont(hdcPrinter, gsDefFontName, 12, #PB_Font_Underline) 
      
      FrontColor(#SCS_Black)
      BackColor(#SCS_White)
      
      ; calculate horizontal scaling factor so printed cue list fits page width
      DrawingFont(hFontIDNormal8)
      nX = 0
      For nCol = 0 To nMaxVisibleColNo
        nColWidth = GetGadgetItemAttribute(WPR\grdCuePrint, 0, #PB_ListIcon_ColumnWidth, nCol)
        debugMsg(sProcName, "nCol=" + nCol + ", nColWidth=" + nColWidth)
        nX + nColWidth
      Next nCol
      nOneCharWidth8 = TextWidth(" ")
      nLeftMargin = nOneCharWidth8 * 8
      dXScale = (nPrintWidth - (nOneCharWidth8 * 16)) / nX
      debugMsg(sProcName, "nPrintWidth=" + nPrintWidth + ", nOneCharWidth8=" + nOneCharWidth8 + ", nLeftMargin=" + nLeftMargin + ", nX=" + nX + ", dXScale=" + StrD(dXScale, 4))
      
      ; calculate row height and end-of-page position
      nRowHeight = (TextHeight("Gg") * 1.5)
      nTopMargin = nRowHeight
      debugMsg(sProcName, "Printer nRowHeight=" + nRowHeight + ", nTopMargin=" + nTopMargin)
      nEOP = nPrintHeight - nRowHeight
      
      ; now ready to print report
      nCurrentY = nTopMargin
      
      ; print heading
      If Len(sHeading) > 0
        DrawingFont(hFontIDNormal12ul)
        nX = (nPrintWidth - TextWidth(sHeading)) / 2
        nY = nCurrentY
        DrawingMode(#PB_2DDrawing_Transparent)
        DrawText(nX, nY, sHeading)
        nCurrentY + (TextHeight("Gg") * 2)
      EndIf
      
      ; Print column headers with light gray background
      DrawingFont(hFontIDBold8)
      nOneCharWidth8 = TextWidth("g") ; don't use "w" as we want an 'average' width - just as a separator
      nCurrentX = nLeftMargin
      nY = nCurrentY + ((nRowHeight - TextHeight("Gg")) / 2) + 1
      nHeight = nRowHeight
      For nCol = 0 To nMaxVisibleColNo
        nX = nCurrentX
        nWidth = GetGadgetItemAttribute(WPR\grdCuePrint, 0, #PB_ListIcon_ColumnWidth, nCol) * dXScale
        DrawingMode(#PB_2DDrawing_Default)
        Box(nX, nCurrentY, nWidth, nHeight, #SCS_Very_Light_Grey)
        DrawingMode(#PB_2DDrawing_Outlined)
        Box(nX, nCurrentY, nWidth, nHeight, #SCS_Black)
        sText = GetGadgetItemText(WPR\grdCuePrint, -1, nCol)      ; get column header text
        
        ; If logicalAND(\ColHeaderTextFlags(j), igTextCenter) <> 0
        ; nX = nX + (((\ColWidth(j) * dXScale) - TextWidth(\ColHeaderText(j))) / 2)
        ; ElseIf logicalAND(\ColHeaderTextFlags(j), igTextRight) <> 0
        ; nX = nX + ((\ColWidth(j) * dXScale) - TextWidth(\ColHeaderText(j))) - (px * 5)
        ; Else ;If logicaland(.ColHeaderTextFlags(j), igTextLeft) <> 0& Then
        nX + nOneCharWidth8  ; make sure text doesn't overwrite left border line
                             ; EndIf
        
        DrawingMode(#PB_2DDrawing_Transparent)
        DrawText(nX, nY, sText)
        
        nCurrentX + nWidth
        
      Next nCol
      
      ; ------------ Print cue list
      DrawingFont(hFontIDNormal8)
      nOneCharWidth8 = TextWidth("g") ; don't use "w" as we want an 'average' width - just as a separator
      DrawingMode(#PB_2DDrawing_Outlined | #PB_2DDrawing_Transparent) ; boxes (grid cells) are to be outlined, not filled, and text background to be transparent
      For nRow = 0 To CountGadgetItems(WPR\grdCuePrint)-1
        If nCurrentY >= (nEOP - (nRowHeight * 4))
          ; ----------- Print page number
          nPageNo + 1
          nX = (nPrintWidth - TextWidth("Page " + nPageNo)) / 2
          nY = nEOP - (nRowHeight * 1.5)
          DrawText(nX, nY, "Page " + nPageNo)
          bJustPrintedPageNo = #True
          NewPrinterPage()
          nCurrentY = nTopMargin
        Else
          nCurrentY + nRowHeight
        EndIf
        
        ; print columns
        nCurrentX = nLeftMargin
        nY = nCurrentY + ((nRowHeight - TextHeight("Gg")) / 2) + 1
        For nCol = 0 To nMaxVisibleColNo
          nX = nCurrentX
          ; ------------- Make sure text fits
          nWidth = GetGadgetItemAttribute(WPR\grdCuePrint, 0, #PB_ListIcon_ColumnWidth, nCol) * dXScale
          sText = GetGadgetItemText(WPR\grdCuePrint, nRow, nCol)
          sTextTruncated = sText
          While TextWidth(sTextTruncated) > (nWidth-nOneCharWidth8) And Len(sText) > 0
            sText = Left(sText, Len(sText) - 1)
            sTextTruncated = sText + "..."
          Wend
          Box(nX, nCurrentY, nWidth, nHeight, #SCS_Black)
          
          ; If logicalAND(\CellTextFlags(nRow, j), igTextCenter) <> 0
          ; nX = nX + (((\ColWidth(j) * dXScale) - TextWidth(sTextTrun)) / 2)
          ; ElseIf logicalAND(\CellTextFlags(nRow, j), igTextRight) <> 0
          ; nX = nX + ((\ColWidth(j) * dXScale) - TextWidth(sTextTrun)) - (px * 5)
          ; Else ;If logicaland(.ColHeaderTextFlags(j), igTextLeft) <> 0& Then
          nX + nOneCharWidth8  ; make sure text doesn't overwrite left border line
                               ; EndIf
                               ; print one cell
          DrawText(nX, nY, sTextTruncated)
          bJustPrintedPageNo = #False
          
          nCurrentX + nWidth
          
        Next nCol
        
      Next nRow
      
      ; ------------ Print final page number
      If bJustPrintedPageNo = #False
        nPageNo + 1
        nX = (nPrintWidth - TextWidth("Page " + nPageNo)) / 2
        nY = nEOP - (nRowHeight * 1.5)
        DrawText(nX, nY, "Page " + nPageNo)
        bJustPrintedPageNo = #True
      EndIf
    EndIf
    
    ; destroy printer fonts created after StartDrawing()
    DeleteObject_(hFontIDNormal8)
    DeleteObject_(hFontIDBold8)
    DeleteObject_(hFontIDNormal12ul)
    
    StopDrawing()
    StopPrinting()
  EndIf ; EndIf StartPrinting("SCS_Cue_List")
  
  setMouseCursorNormal()

EndProcedure

Procedure WPR_btnSelectAll_Click()
  PROCNAMEC()
  
  With WPR
    SGS(\chkA, #PB_Checkbox_Checked)
    SGS(\chkE, #PB_Checkbox_Checked)
    SGS(\chkF, #PB_Checkbox_Checked)
    SGS(\chkG, #PB_Checkbox_Checked)
    SGS(\chkI, #PB_Checkbox_Checked)
    SGS(\chkJ, #PB_Checkbox_Checked)
    SGS(\chkK, #PB_Checkbox_Checked)
    SGS(\chkL, #PB_Checkbox_Checked)
    SGS(\chkM, #PB_Checkbox_Checked)
    SGS(\chkN, #PB_Checkbox_Checked)
    SGS(\chkP, #PB_Checkbox_Checked)
    SGS(\chkQ, #PB_Checkbox_Checked)
    SGS(\chkR, #PB_Checkbox_Checked)
    SGS(\chkS, #PB_Checkbox_Checked)
    SGS(\chkT, #PB_Checkbox_Checked)
    SGS(\chkU, #PB_Checkbox_Checked)
    SGS(\chkIncludeHotkeys, #PB_Checkbox_Checked)
    SGS(\chkIncludeSubCues, #PB_Checkbox_Checked)
    SGS(\chkManualCuesOnly, #PB_Checkbox_Checked)
    WPR_loadPrintGrid()
    SAG(-1)
  EndWith
EndProcedure

Procedure WPR_btnClearAll_Click()
  PROCNAMEC()
  
  updateGridInfoFromPhysicalLayout(@grGrdCuePrintInfo)
  With WPR
    SGS(\chkA, #PB_Checkbox_Unchecked)
    SGS(\chkE, #PB_Checkbox_Unchecked)
    SGS(\chkF, #PB_Checkbox_Unchecked)
    SGS(\chkG, #PB_Checkbox_Unchecked)
    SGS(\chkI, #PB_Checkbox_Unchecked)
    SGS(\chkJ, #PB_Checkbox_Unchecked)
    SGS(\chkK, #PB_Checkbox_Unchecked)
    SGS(\chkL, #PB_Checkbox_Unchecked)
    SGS(\chkM, #PB_Checkbox_Unchecked)
    SGS(\chkN, #PB_Checkbox_Unchecked)
    SGS(\chkP, #PB_Checkbox_Unchecked)
    SGS(\chkQ, #PB_Checkbox_Unchecked)
    SGS(\chkR, #PB_Checkbox_Unchecked)
    SGS(\chkS, #PB_Checkbox_Unchecked)
    SGS(\chkT, #PB_Checkbox_Unchecked)
    SGS(\chkU, #PB_Checkbox_Unchecked)
    SGS(\chkIncludeHotkeys, #PB_Checkbox_Unchecked)
    SGS(\chkIncludeSubCues, #PB_Checkbox_Unchecked)
    SGS(\chkManualCuesOnly, #PB_Checkbox_Unchecked)
    WPR_loadPrintGrid()
    SAG(-1)
  EndWith
EndProcedure

Procedure WPR_EventHandler()
  PROCNAMEC()
  
  With WPR
    Select gnWindowEvent
        
      Case #PB_Event_CloseWindow
        WPR_Form_Unload()
        
      Case #PB_Event_Gadget
        ;debugMsg(sProcName, "gnEventGadgetNo=G" + gnEventGadgetNo)
        Select gnEventGadgetNoForEvHdlr
          Case \btnClearAll
            WPR_btnClearAll_Click()
            
          Case \btnClose
            WPR_Form_Unload()
            
          Case \btnCopy
            WPR_btnCopy_Click()
            
          Case \btnHelp
            displayHelpTopic("scs_printing.htm")
            
          Case \btnPrint
            WPR_btnPrint_Click()
            
          Case \btnSelectAll
            WPR_btnSelectAll_Click()
            
          Case \chkA, \chkE, \chkF, \chkG, \chkI, \chkJ, \chkK, \chkL, \chkM, \chkN, \chkP, \chkQ, \chkR, \chkS, \chkT, \chkU, \chkIncludeHotkeys, \chkIncludeSubCues, \chkManualCuesOnly
            WPR_loadPrintGrid()
            SAG(-1)
            
          Case \txtCueListTitle
            WPR_txtCueListTitle_Validate()
            
          Default
            debugMsg(sProcName, "gnEventGadgetNo=G" + gnEventGadgetNo + ", gnEventType=" + decodeEventType())
            
        EndSelect
        
      Case #PB_Event_Menu
        gnEventMenu = EventMenu()
        Select gnEventMenu
            
          Case #SCS_mnuKeyboardReturn   ; Return
            WPR_btnPrint_Click()
            
          Case #SCS_mnuKeyboardEscape   ; Escape
            WPR_Form_Unload()
            
            ; 'File' menu
          Case #WPR_mnuFilePrint
            WPR_btnPrint_Click()
            
          Case #WPR_mnuFileClose
            WPR_Form_Unload()
            
            ; 'Columns' menu
          Case #WPR_mnuColAC
            WPR_colSelectionChange(#WPR_mnuColAC, #SCS_GRDCUEPRINT_AC)
            
          Case #WPR_mnuColCT
            WPR_colSelectionChange(#WPR_mnuColCT, #SCS_GRDCUEPRINT_CT)
            
          Case #WPR_mnuColCU
            WPR_colSelectionChange(#WPR_mnuColCU, #SCS_GRDCUEPRINT_CU)
            
          Case #WPR_mnuColDE
            WPR_colSelectionChange(#WPR_mnuColDE, #SCS_GRDCUEPRINT_DE)
            
          Case #WPR_mnuColDU
            WPR_colSelectionChange(#WPR_mnuColDU, #SCS_GRDCUEPRINT_DU)
            
          Case #WPR_mnuColFN
            WPR_colSelectionChange(#WPR_mnuColFN, #SCS_GRDCUEPRINT_FN)
            
          Case #WPR_mnuColFT
            WPR_colSelectionChange(#WPR_mnuColFT, #SCS_GRDCUEPRINT_FT)
            
          Case #WPR_mnuColLV
            WPR_colSelectionChange(#WPR_mnuColLV, #SCS_GRDCUEPRINT_LV)
            
          Case #WPR_mnuColMC
            WPR_colSelectionChange(#WPR_mnuColMC, #SCS_GRDCUEPRINT_MC)
            
          Case #WPR_mnuColPG
            WPR_colSelectionChange(#WPR_mnuColPG, #SCS_GRDCUEPRINT_PG)
            
          Case #WPR_mnuColSD
            WPR_colSelectionChange(#WPR_mnuColSD, #SCS_GRDCUEPRINT_SD)
            
          Case #WPR_mnuColWR
            WPR_colSelectionChange(#WPR_mnuColWR, #SCS_GRDCUEPRINT_WR)
            
          Case #WPR_mnuColRevert
            WPR_mnuColRevert_Click()
            
          Case #WPR_mnuColDefaults
            WPR_mnuColDefaults_Click()
            
        EndSelect
        
    EndSelect
  EndWith
  
EndProcedure

Procedure WPR_resetColNos()
  PROCNAMEC()
  Protected n, m, nColNo
  
  nColNo = -1
  For n = 0 To #SCS_GRDCUEPRINT_LAST
    For m = 0 To #SCS_GRDCUEPRINT_LAST
      If grGrdCuePrintInfo\aCol(m)\nCurColOrder = n
        nColNo + 1
        grGrdCuePrintInfo\aCol(m)\nCurColNo = nColNo
        grGrdCuePrintInfo\aCol(m)\nCurColOrder = grGrdCuePrintInfo\aCol(m)\nCurColNo
      EndIf
    Next m
  Next n
  grGrdCuePrintInfo\nMaxVisibleColNo = nColNo
  
EndProcedure

Procedure WPR_colSelectionChange(nMenuItem, nColIndex)
  PROCNAMEC()
  Protected bIncludeCol
  
  debugMsg(sProcName, #SCS_START)
  
  If GetMenuItemState(#WPR_mnuWindowMenu, nMenuItem)
    bIncludeCol = #False
  Else
    bIncludeCol = #True
  EndIf
  
  With grGrdCuePrintInfo\aCol(nColIndex)
    If bIncludeCol
      \bColVisible = #True
      grGrdCuePrintInfo\nMaxVisibleColNo + 1
      \nCurColNo = grGrdCuePrintInfo\nMaxVisibleColNo
    Else
      \bColVisible = #False
      \nCurColNo = -1
    EndIf
    \nCurColOrder = \nCurColNo
  EndWith
  
  WPR_resetColNos()
  WPR_setupPrintGrid()
  WPR_loadPrintGrid()
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WPR_buildWindowMenu()
  PROCNAMEC()
  
  debugMsg(sProcName, #SCS_START)
  
  If scsCreateMenu(#WPR_mnuWindowMenu, #WPR)
    ; File
    MenuTitle(Lang("Menu", "mnuFile"))
    scsMenuItem(#WPR_mnuFilePrint, "mnuFilePrint")
    MenuBar()
    scsMenuItem(#WPR_mnuFileClose, "mnuFileClose")
    
    ; Columns
    MenuTitle(Lang("Menu", "mnuColsForPrint"))
    scsMenuItemFast(#WPR_mnuColCU, grText\sTextCue)
    scsMenuItemFast(#WPR_mnuColPG, Lang("Common", "Page"))
    scsMenuItemFast(#WPR_mnuColDE, grText\sTextDescription)
    scsMenuItemFast(#WPR_mnuColCT, Lang("Common", "CueType"))
    scsMenuItemFast(#WPR_mnuColAC, Lang("Common", "Activation"))
    scsMenuItemFast(#WPR_mnuColFN, grText\sTextFile)
    scsMenuItemFast(#WPR_mnuColDU, Lang("Common", "Length"))
    scsMenuItemFast(#WPR_mnuColSD, grText\sTextDevice)
    scsMenuItemFast(#WPR_mnuColWR, Lang("Common", "WhenReqd"))
    scsMenuItemFast(#WPR_mnuColMC, Lang("Common", "MIDICue"))
    scsMenuItemFast(#WPR_mnuColFT, Lang("Common", "FileType"))
    scsMenuItemFast(#WPR_mnuColLV, Lang("Common", "Level") + " (dB)")
    MenuBar()
    scsMenuItem(#WPR_mnuColRevert, "mnuColRevert")
    scsMenuItem(#WPR_mnuColDefaults, "mnuColDefaults")
    
  EndIf
EndProcedure

; EOF
