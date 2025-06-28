; File: fmImport.pbi

EnableExplicit

Procedure WIM_btnAddSelected_Click()
  PROCNAMEC()
  Protected i, j, d, d2, h, n, n2, n3
  Protected nRow, nRow2, i2, i3, j2, k2
  Protected nNewCues, nStartCuePtr, nCurrCuePtr
  Protected sCue.s, nCounter, sOrigCue.s
  Protected sChar.s
  Protected nNumber, sMsg.s
  Protected bDoingPrefix, bFound, bFound2
  Protected nMyDevType, sMyLogicalDev.s, bAllMapped
  Protected sHotkey.s, sPartMsg.s, sAutoActCue.s
  Protected Dim sManual.s(0)
  Protected nManualPtr, nResponse, nManualCount, nOthersCount, nDisplayMax
  Protected nPass
  Protected nMyPrevSubIndex, nMyPrevAudIndex
  Protected bMissingCues, sTargetCue.s
  Protected bLockedMutex
  Protected nCtrlItem
  Protected nCheckDevMapResult
  Protected nNodeKey
  Protected bMissingDev
  Protected sLTFixtureCode.s, bDevFound, bFixtureFound
  Structure tyCueMissingFixtures
    sCue.s
    nMaxMissingFixture.i
    Array sMissingFixture.s(0)
  EndStructure
  Protected Dim aCueMissingFixtures.tyCueMissingFixtures(0), nMaxCueMissingFixtures, sCurrMissingFixturesCue.s, bDisplayCueMissingFixtures, bExcessCueMissingFixtures

  debugMsg(sProcName, #SCS_START)
  
  grWIM\bImportingCues = #True
  LockCueListMutex(701)
  
;   debugMsg(sProcName, "calling debugProd(@grProd)")
;   debugProd(@grProd)
;   debugMsg(sProcName, "calling debugProd(@gr2ndProd)")
;   debugProd(@gr2ndProd)
  
;   debugMsg(sProcName, "calling listAllDevMaps()")
;   listAllDevMaps()
  
  nPass = 1 ; first pass of the import code

  While #True
    
    If GGS(WIM\optPreserveCueNumbers)
      ; user requested preserve cue numbers, so check all required numbers available
      For nRow = 0 To (CountGadgetItems(WIM\grdAddCues)-1)
        If GetGadgetItemState(WIM\grdAddCues,nRow) & #PB_ListIcon_Checked
          i2 = nRow + 1
          For i = 1 To gnLastCue
            If UCase(aCue(i)\sCue) = UCase(a2ndCue(i2)\sCue)
              ; sMsg = "'" + GGT(WIM\optPreserveCueNumbers) + "' requested but cue number " + a2ndCue(i2)\sCue + " is already in use"
              sMsg = LangPars("WIM", "CueNumberAlreadyUsed", a2ndCue(i2)\sCue)
              debugMsg(sProcName, sMsg)
              scsMessageRequester(GWT(#WIM), sMsg, #PB_MessageRequester_Error)
              UnlockCueListMutex()
              grWIM\bImportingCues = #False
              ProcedureReturn
            EndIf
          Next i
        EndIf
      Next nRow
    EndIf
    
    ; count number of cues to be added
    nNewCues = 0
    For nRow = 0 To (CountGadgetItems(WIM\grdAddCues)-1)
      If GetGadgetItemState(WIM\grdAddCues,nRow) & #PB_ListIcon_Checked
        nNewCues + 1
      EndIf
    Next nRow
    
    If nNewCues = 0
      ; shouldn't happen as button should be disabled if no selected cues
      UnlockCueListMutex()
      grWIM\bImportingCues = #False
      ProcedureReturn
    EndIf
    
    ; check for any cues to be changed to Manual Start, ie auto-activate cue not imported, or hotkey already in use
    ;{
    nManualPtr = -1
    nDisplayMax = 10
    ReDim sManual(nNewCues-1)
    sMsg = Lang("WIM", "Manual1") ; "The following cues will be converted to 'Manual Start' when imported:"
    For nRow = 0 To (CountGadgetItems(WIM\grdAddCues)-1)
      If GetGadgetItemState(WIM\grdAddCues,nRow) & #PB_ListIcon_Checked
        i2 = nRow + 1
        sCue = a2ndCue(i2)\sCue
        sPartMsg = #CRLF$ + #CRLF$ + "  " + sCue + "  " + a2ndCue(i2)\sCueDescr + #CRLF$
        If a2ndCue(i2)\bHotkey
          sHotkey = a2ndCue(i2)\sHotkey
          For i = 1 To gnLastCue
            If (aCue(i)\bHotkey) And (aCue(i)\sHotkey = sHotkey)
              nManualCount + 1
              If nManualCount <= nDisplayMax
                nManualPtr + 1
                sManual(nManualPtr) = sCue
                sMsg + sPartMsg + "    (" + LangPars("WIM", "HotkeyAlreadyUsed", sHotkey, aCue(i)\sCue) + ")"
              Else
                nOthersCount + 1
              EndIf
              Break
            EndIf
          Next i
          
        ElseIf (a2ndCue(i2)\nActivationMethod = #SCS_ACMETH_AUTO Or a2ndCue(i2)\nActivationMethod = #SCS_ACMETH_AUTO_PLUS_CONF) And
               (a2ndCue(i2)\nAutoActCueSelType = #SCS_ACCUESEL_DEFAULT And a2ndCue(i2)\nAutoActPosn <> #SCS_ACPOSN_LOAD)
          sAutoActCue = a2ndCue(i2)\sAutoActCue
          bFound = #False
          For nRow2 = 0 To (CountGadgetItems(WIM\grdAddCues)-1)
            If GetGadgetItemState(WIM\grdAddCues,nRow2) & #PB_ListIcon_Checked
              i3 = nRow2 + 1
              If a2ndCue(i3)\sCue = sAutoActCue
                bFound = #True
                Break
              EndIf
            EndIf
          Next nRow2
          If bFound = #False
            nManualCount + 1
            If nManualCount <= nDisplayMax
              nManualPtr + 1
              sManual(nManualPtr) = sCue
              sMsg + sPartMsg + "    (" + LangPars("WIM", "AutoNotIncluded", sAutoActCue) + ")"
            Else
              nOthersCount + 1
            EndIf
          EndIf
        EndIf
      EndIf
    Next nRow
    
    If nManualPtr >= 0
      If nPass = 1
        If nOthersCount > 0
          If nOthersCount = 1
            sMsg + #CRLF$ + #CRLF$ + "and 1 other cue." + #CRLF$
          Else
            sMsg + #CRLF$ + #CRLF$ + "and " + nOthersCount + " other cues." + #CRLF$
          EndIf
        EndIf
        debugMsg(sProcName, "nPass=" + nPass + ", " + sMsg)
        sMsg + Chr(10) + Chr(10) + Lang("WIM", "Proceed?")
        nResponse = scsMessageRequester(GWT(#WIM), sMsg, #PB_MessageRequester_YesNo|#MB_ICONQUESTION)
        If nResponse <> #PB_MessageRequester_Yes
          debugMsg(sProcName, "abandon import")
          UnlockCueListMutex()
          grWIM\bImportingCues = #False
          ProcedureReturn ; abandon import !!!!!!!!!!!!!
        EndIf
      EndIf
    EndIf
    ;}
    
    ; check for any SFR or Level Change cues that 'control' cues that have not been included in the import
    ;{
    sMsg = Lang("WIM", "Manual2") ; "The import cannot proceed because the following selected cues control other cues that have not been selected for importing:"
    bMissingCues = #False
    For nRow = 0 To (CountGadgetItems(WIM\grdAddCues)-1)
      If GetGadgetItemState(WIM\grdAddCues,nRow) & #PB_ListIcon_Checked
        i2 = nRow + 1
        sCue = a2ndCue(i2)\sCue
        sPartMsg = #CRLF$ + #CRLF$ + "  " + sCue + "  " + a2ndCue(i2)\sCueDescr + #CRLF$
        j2 = a2ndCue(i2)\nFirstSubIndex
        While j2 >= 0
          If a2ndSub(j2)\bSubTypeG   ; bSubTypeG (Go To Cue)
            ;{
            sTargetCue = a2ndSub(j2)\sCueToGoTo
            If Len(Trim(sTargetCue)) > 0
              bFound = #False
              For nRow2 = 0 To CountGadgetItems(WIM\grdAddCues)-1
                If GetGadgetItemState(WIM\grdAddCues,nRow2) & #PB_ListIcon_Checked
                  i3 = nRow2 + 1
                  If a2ndCue(i3)\sCue = sTargetCue
                    bFound = #True
                    Break
                  EndIf
                EndIf
              Next nRow2
              If bFound = #False
                bMissingCues = #True
                sMsg + sPartMsg + "    (" + LangPars("WIM", "TargetNotIncluded", sTargetCue + ")")
              EndIf
            EndIf
            ;}
          ElseIf a2ndSub(j2)\bSubTypeL   ; bSubTypeL (Level Change)
            ;{
            sTargetCue = a2ndSub(j2)\sLCCue
            If Len(Trim(sTargetCue)) > 0
              bFound = #False
              For nRow2 = 0 To CountGadgetItems(WIM\grdAddCues)-1
                If GetGadgetItemState(WIM\grdAddCues,nRow2) & #PB_ListIcon_Checked
                  i3 = nRow2 + 1
                  If a2ndCue(i3)\sCue = sTargetCue
                    bFound = #True
                    Break
                  EndIf
                EndIf
              Next nRow2
              If bFound = #False
                bMissingCues = #True
                sMsg + sPartMsg + "    (" + LangPars("WIM", "TargetNotIncluded", sTargetCue + ")")
              EndIf
            EndIf
            ;}
          ElseIf a2ndSub(j2)\bSubTypeS   ; bSubTypeS (SFR - Stop, Fade Out, Loop Release)
            ;{
            For h = 0 To #SCS_MAX_SFR
              If a2ndSub(j2)\nSFRCueType[h] = #SCS_SFR_CUE_SEL
                sTargetCue = a2ndSub(j2)\sSFRCue[h]
                If Len(Trim(sTargetCue)) > 0
                  bFound = #False
                  For nRow2 = 0 To CountGadgetItems(WIM\grdAddCues)-1
                    If GetGadgetItemState(WIM\grdAddCues,nRow2) & #PB_ListIcon_Checked
                      i3 = nRow2 + 1
                      If a2ndCue(i3)\sCue = sTargetCue
                        bFound = #True
                        Break
                      EndIf
                    EndIf
                  Next nRow2
                  If bFound = #False
                    bMissingCues = #True
                    sMsg + sPartMsg + "    (" + LangPars("WIM", "TargetNotIncluded", sTargetCue + ")")
                  EndIf
                EndIf
              EndIf
            Next h
            ;}
          ElseIf a2ndSub(j2)\bSubTypeT   ; bSubTypeT (Set Position)
            ;{
            sTargetCue = a2ndSub(j2)\sSetPosCue
            If Len(Trim(sTargetCue)) > 0
              bFound = #False
              For nRow2 = 0 To CountGadgetItems(WIM\grdAddCues)-1
                If GetGadgetItemState(WIM\grdAddCues,nRow2) & #PB_ListIcon_Checked
                  i3 = nRow2 + 1
                  If a2ndCue(i3)\sCue = sTargetCue
                    bFound = #True
                    Break
                  EndIf
                EndIf
              Next nRow2
              If bFound = #False
                bMissingCues = #True
                sMsg + sPartMsg + "    (" + LangPars("WIM", "TargetNotIncluded", sTargetCue + ")")
              EndIf
            EndIf
            ;}
          EndIf
          j2 = a2ndSub(j2)\nNextSubIndex
        Wend
      EndIf
    Next nRow
    
    If bMissingCues
      debugMsg(sProcName, sMsg)
      scsMessageRequester(GWT(#WIM), sMsg, #PB_MessageRequester_Error)
      UnlockCueListMutex()
      grWIM\bImportingCues = #False
      ProcedureReturn ; abandon import !!!!!!!!!!!!!
    EndIf
    ;}
    
    ; check for any lighting cue that doesn't have a device in the current cue file
    ;{
    bMissingDev = #False
    For nRow = 0 To (CountGadgetItems(WIM\grdAddCues)-1)
      If GetGadgetItemState(WIM\grdAddCues,nRow) & #PB_ListIcon_Checked
        j2 = a2ndCue(i2)\nFirstSubIndex
        While j2 >= 0
          If a2ndSub(j2)\bSubTypeK   ; bSubTypeK (Lighting)
            sMyLogicalDev = a2ndSub(j2)\sLTLogicalDev
            If sMyLogicalDev
              bFound = #False
              For d = 0 To grProd\nMaxLightingLogicalDev
                If grProd\aLightingLogicalDevs(d)\sLogicalDev = sMyLogicalDev
                  bFound = #True
                  Break
                EndIf
              Next d
              If bFound = #False
                bMissingDev = #True
                sMsg = LangPars("WIM", "Devices3", grText\sTextCueTypeK, sMyLogicalDev, GetFilePart(gsCueFile) + ")")
                Break 2 ; Break j2, nRow
              EndIf
            EndIf
          EndIf
          j2 = aSub(j2)\nNextSubIndex
        Wend  
      EndIf
    Next nRow
    
    If bMissingDev
      debugMsg(sProcName, sMsg)
      scsMessageRequester(GWT(#WIM), sMsg, #PB_MessageRequester_Error)
      UnlockCueListMutex()
      grWIM\bImportingCues = #False
      ProcedureReturn ; abandon import !!!!!!!!!!!!!
    EndIf
    
    nMaxCueMissingFixtures = -1
    sCurrMissingFixturesCue = ""
    nDisplayMax = 10
    bExcessCueMissingFixtures = #False ; will be set #True if nMaxCueMissingFixtures would exceed nDisplayMax
    sMsg = LangPars("WIM", "Fixtures",  GetFilePart(gsCueFile) + ")")
    For nRow = 0 To (CountGadgetItems(WIM\grdAddCues)-1)
      If GetGadgetItemState(WIM\grdAddCues,nRow) & #PB_ListIcon_Checked
        i2 = nRow + 1
        j2 = a2ndCue(i2)\nFirstSubIndex
        While j2 >= 0
          If a2ndSub(j2)\bSubTypeK   ; bSubTypeK (Lighting)
            sMyLogicalDev = a2ndSub(j2)\sLTLogicalDev
            If sMyLogicalDev And a2ndSub(j2)\nLTEntryType = #SCS_LT_ENTRY_TYPE_FIXTURE_ITEMS
              For n = 0 To a2ndSub(j2)\nMaxFixture
                sLTFixtureCode = a2ndSub(j2)\aLTFixture(n)\sLTFixtureCode
                bFixtureFound = #False
                For d = 0 To grProd\nMaxLightingLogicalDev
                  If grProd\aLightingLogicalDevs(d)\sLogicalDev = sMyLogicalDev
                    For n2 = 0 To grProd\aLightingLogicalDevs(d)\nMaxFixture
                      If grProd\aLightingLogicalDevs(d)\aFixture(n2)\sFixtureCode = sLTFixtureCode
                        bFixtureFound = #True
                        Break
                      EndIf
                    Next n2
                    If bFixtureFound = #False
                      bDisplayCueMissingFixtures = #True
                      If a2ndCue(i2)\sCue <> sCurrMissingFixturesCue
                        If nMaxCueMissingFixtures <= nDisplayMax
                          nMaxCueMissingFixtures + 1
                          If nMaxCueMissingFixtures > ArraySize(aCueMissingFixtures())
                            ReDim aCueMissingFixtures(nMaxCueMissingFixtures + 5)
                          EndIf
                          sCurrMissingFixturesCue = a2ndCue(i2)\sCue
                          aCueMissingFixtures(nMaxCueMissingFixtures)\sCue = sCurrMissingFixturesCue
                          aCueMissingFixtures(nMaxCueMissingFixtures)\nMaxMissingFixture = -1
                        Else
                          bDisplayCueMissingFixtures = #False
                          bExcessCueMissingFixtures = #True
                        EndIf
                      EndIf
                      If bDisplayCueMissingFixtures
                        With aCueMissingFixtures(nMaxCueMissingFixtures)
                          \nMaxMissingFixture + 1
                          If \nMaxMissingFixture > ArraySize(\sMissingFixture())
                            ReDim \sMissingFixture(\nMaxMissingFixture + 5)
                          EndIf
                          \sMissingFixture(\nMaxMissingFixture) = sLTFixtureCode
                        EndWith
                      EndIf
                    EndIf
                  EndIf
                Next d
              Next n ; check next fixture code, if any more
            EndIf
          EndIf
          j2 = a2ndSub(j2)\nNextSubIndex
        Wend
      EndIf
    Next nRow
    
    If nMaxCueMissingFixtures >= 0
      ; SortArray(sMissingFixtures(),#PB_Sort_Ascending | #PB_Sort_NoCase, 0, nMaxMissingFixture)
      For n2 = 0 To nMaxCueMissingFixtures
        sMsg + #CRLF$ + "  " + grText\sTextCue + " " + aCueMissingFixtures(n2)\sCue + ": "
        For n3 = 0 To aCueMissingFixtures(n2)\nMaxMissingFixture
          If n3 = 0
            sMsg + aCueMissingFixtures(n2)\sMissingFixture(n3)
          Else
            sMsg + ", " + aCueMissingFixtures(n2)\sMissingFixture(n3)
          EndIf
        Next n3
      Next n2
      If bExcessCueMissingFixtures
        sMsg + #CRLF$ + "  ..."
      EndIf
      debugMsg(sProcName, sMsg)
      scsMessageRequester(GWT(#WIM), sMsg, #PB_MessageRequester_Error)
      UnlockCueListMutex()
      grWIM\bImportingCues = #False
      ProcedureReturn ; abandon import !!!!!!!!!!!!!
    EndIf
    ;}
    
    For d2 = 0 To ArraySize(gaImportDev())
      gaImportDev(d2)\b2ndUsedInCues = #False
      gaImportDev(d2)\s2ndCues = ""
    Next d2
    
    For d2 = 0 To ArraySize(gaImportMidiDev())
      gaImportMidiDev(d2)\b2ndUsedInCues = #False
      gaImportMidiDev(d2)\s2ndCues = ""
    Next d2
    
    For nRow = 0 To (CountGadgetItems(WIM\grdAddCues)-1)
      If GetGadgetItemState(WIM\grdAddCues,nRow) & #PB_ListIcon_Checked
        i2 = nRow + 1
        sCue = a2ndCue(i2)\sCue
        j2 = a2ndCue(i2)\nFirstSubIndex
        While j2 >= 0
          If a2ndSub(j2)\bSubTypeA ; bSubTypeA
            ;{
            sMyLogicalDev = a2ndSub(j2)\sVidAudLogicalDev
            If sMyLogicalDev
              For d2 = 0 To gnLastImportDev
                With gaImportDev(d2)
                  If (\nDevGrp = #SCS_DEVGRP_VIDEO_AUDIO) Or (\nDevGrp = #SCS_DEVGRP_VIDEO_CAPTURE)
                    If \s2ndLogicalDev = sMyLogicalDev
                      If \b2ndUsedInCues
                        \s2ndCues + ", " + sCue
                      Else
                        \b2ndUsedInCues = #True
                        \s2ndCues = sCue
                      EndIf
                    EndIf
                  EndIf
                EndWith
              Next d2
            EndIf
            ;}
          ElseIf a2ndSub(j2)\bSubTypeF ; bSubTypeF
            ;{
            k2 = a2ndSub(j2)\nFirstAudIndex
            While k2 >= 0
              If a2ndAud(k2)\nFileFormat = #SCS_FILEFORMAT_AUDIO
                ; can't use nFirstDev and nLastDev for secondary files as setFirstAndLastDev has not been called
                For d = 0 To grLicInfo\nMaxAudDevPerAud
                  sMyLogicalDev = a2ndAud(k2)\sLogicalDev[d]
                  If sMyLogicalDev
                    For d2 = 0 To gnLastImportDev
                      With gaImportDev(d2)
                        If \nDevGrp = #SCS_DEVGRP_AUDIO_OUTPUT
                          If \s2ndLogicalDev = sMyLogicalDev
                            If \b2ndUsedInCues
                              \s2ndCues + ", " + sCue
                            Else
                              \b2ndUsedInCues = #True
                              \s2ndCues = sCue
                            EndIf
                          EndIf
                        EndIf
                      EndWith
                    Next d2
                  EndIf
                Next d
              Else ; bMidiFile = True
                sMyLogicalDev = a2ndAud(k2)\sLogicalDev
                If sMyLogicalDev
                  For d2 = 0 To gnLastImportMidiDev
                    If gaImportMidiDev(d2)\s2ndLogicalDev = sMyLogicalDev
                      If gaImportMidiDev(d2)\b2ndUsedInCues
                        gaImportMidiDev(d2)\s2ndCues + ", " + sCue
                      Else
                        gaImportMidiDev(d2)\b2ndUsedInCues = #True
                        gaImportMidiDev(d2)\s2ndCues = sCue
                      EndIf
                    EndIf
                  Next d2
                EndIf
              EndIf
              k2 = a2ndAud(k2)\nNextAudIndex
            Wend
            ;}
          ElseIf a2ndSub(j2)\bSubTypeK ; bSubTypeK
            ;{
            sMyLogicalDev = a2ndSub(j2)\sLTLogicalDev
            If sMyLogicalDev
              nMyDevType = a2ndSub(j2)\nLTDevType
              For d2 = 0 To gnLastImportDev
                With gaImportDev(d2)
                  If \nDevGrp = #SCS_DEVGRP_LIGHTING And \nDevType = nMyDevType
                    If \s2ndLogicalDev = sMyLogicalDev
                      If \b2ndUsedInCues
                        \s2ndCues + ", " + sCue
                      Else
                        \b2ndUsedInCues = #True
                        \s2ndCues = sCue
                      EndIf
                    EndIf
                  EndIf
                EndWith
              Next d2
            EndIf
            ;}
          ElseIf a2ndSub(j2)\bSubTypeM ; bSubTypeM
            ;{
            For nCtrlItem = 0 To #SCS_MAX_CTRL_SEND
              sMyLogicalDev = a2ndSub(j2)\aCtrlSend[nCtrlItem]\sCSLogicalDev
              If sMyLogicalDev
                nMyDevType = a2ndSub(j2)\aCtrlSend[nCtrlItem]\nDevType
                For d2 = 0 To gnLastImportDev
                  With gaImportDev(d2)
                    If \nDevGrp = #SCS_DEVGRP_CTRL_SEND And \nDevType = nMyDevType
                      If \s2ndLogicalDev = sMyLogicalDev
                        If \b2ndUsedInCues
                          \s2ndCues + ", " + sCue
                        Else
                          \b2ndUsedInCues = #True
                          \s2ndCues = sCue
                        EndIf
                      EndIf
                    EndIf
                  EndWith
                Next d2
              EndIf
            Next nCtrlItem
            ;}
          ElseIf a2ndSub(j2)\bSubTypeP ; bSubTypeP
            ;{
            For d = 0 To grLicInfo\nMaxAudDevPerAud
              sMyLogicalDev = a2ndSub(j2)\sPLLogicalDev[d]
              If sMyLogicalDev
                For d2 = 0 To gnLastImportDev
                  With gaImportDev(d2)
                    If \nDevGrp = #SCS_DEVGRP_AUDIO_OUTPUT
                      If \s2ndLogicalDev = sMyLogicalDev
                        If \b2ndUsedInCues
                          \s2ndCues + ", " + sCue
                        Else
                          \b2ndUsedInCues = #True
                          \s2ndCues = sCue
                        EndIf
                      EndIf
                    EndIf
                  EndWith
                Next d2
              EndIf
            Next d
            ;}
          EndIf
          j2 = a2ndSub(j2)\nNextSubIndex
        Wend
      EndIf
      
    Next nRow
    
    bAllMapped = #True
    For d2 = 0 To gnLastImportDev
      debugMsg(sProcName, "nPass=" + nPass + ", gaImportDev(" + d2 + ")\b2ndUsedInCues=" + strB(gaImportDev(d2)\b2ndUsedInCues) + ", \s1stLogicalDev=" + gaImportDev(d2)\s1stLogicalDev)
      If gaImportDev(d2)\b2ndUsedInCues
        If Len(Trim(gaImportDev(d2)\s1stLogicalDev)) = 0
          bAllMapped = #False
          Break
        EndIf
      EndIf
    Next d2
    If bAllMapped
      For d2 = 0 To gnLastImportMidiDev
        If gaImportMidiDev(d2)\b2ndUsedInCues
          If Len(Trim(gaImportMidiDev(d2)\s1stLogicalDev)) = 0
            bAllMapped = #False
            Break
          EndIf
        EndIf
      Next d2
    EndIf
    
    debugMsg(sProcName, "calling WIM_listImportDevs()")
    WIM_listImportDevs()
    
    debugMsg(sProcName, "bAllMapped=" + strB(bAllMapped))
    If bAllMapped = #False
      If nPass = 1
        WIM_createDevices()
        ; debugMsg(sProcName, "grProd\nMaxLightingLogicalDev=" + grProd\nMaxLightingLogicalDev)
        WIM_setupDevices()
        ; debugMsg(sProcName, "grProd\nMaxLightingLogicalDev=" + grProd\nMaxLightingLogicalDev)
        nPass = 2 ; do a second pass of the import code
        Continue
        
      Else ; nPass = 2
        ; debugMsg(sProcName, "grProd\nMaxLightingLogicalDev=" + grProd\nMaxLightingLogicalDev)
        ; sMsg = "The following devices in " + GetFilePart(gs2ndCueFile) + " do not exist in " + GetFilePart(gsCueFile) + " and cannot be created as this would create too many devices:" + #CRLF$ + #CRLF$
        sMsg = LangPars("WIM", "Devices1", GetFilePart(gs2ndCueFile), GetFilePart(gsCueFile)) + Chr(10) + Chr(10)
        For d2 = 0 To gnLastImportDev
          If gaImportDev(d2)\b2ndUsedInCues
            If Len(Trim(gaImportDev(d2)\s1stLogicalDev)) = 0
              sMsg + "    " + gaImportDev(d2)\s2ndLogicalDev + #CRLF$
            EndIf
          EndIf
        Next d2
        For d2 = 0 To gnLastImportMidiDev
          If gaImportMidiDev(d2)\b2ndUsedInCues
            If Len(Trim(gaImportMidiDev(d2)\s1stLogicalDev)) = 0
              sMsg + "    " + gaImportMidiDev(d2)\s2ndLogicalDev + #CRLF$
            EndIf
          EndIf
        Next d2
        ; sMsg + #CRLF$ + "Please check the imported cues for use of the above device(s)."
        sMsg + Chr(10) + Lang("WIM", "Devices2")
        debugMsg(sProcName, sMsg)
        scsMessageRequester(GWT(#WIM), sMsg, #PB_MessageRequester_Ok|#MB_ICONEXCLAMATION)
        setMouseCursorNormal()
        WIM_Form_Unload()
        UnlockCueListMutex()
        grWIM\bImportingCues = #False
        ProcedureReturn
        
      EndIf
    EndIf
    Break
  Wend
  
  If checkMaxCue(gnLastCue + nNewCues) = #False
    ; cue limit exceeded - ignore this
    debugMsg(sProcName, "cue limit exceeded - ignore this")
    UnlockCueListMutex()
    grWIM\bImportingCues = #False
    ProcedureReturn ; abandon import !!!!!!!!!!!!!
  EndIf
  
  setMouseCursorBusy()
  
  nStartCuePtr = GGS(WIM\cboTargetCue) + 1
  
  For i = gnLastCue To nStartCuePtr Step -1
    i2 = i + nNewCues
    aCue(i2) = aCue(i)
    j2 = aCue(i2)\nFirstSubIndex
    While j2 >= 0
      aSub(j2)\nCueIndex = i2
      If aSub(j2)\bSubTypeHasAuds
        k2 = aSub(j2)\nFirstAudIndex
        While k2 >= 0
          aAud(k2)\nCueIndex = i2
          setMissingCueMarkerIds(k2)
          k2 = aAud(k2)\nNextAudIndex
        Wend
      EndIf
      j2 = aSub(j2)\nNextSubIndex
    Wend
  Next i
  
  For i = nStartCuePtr To (nStartCuePtr + nNewCues - 1)
    aCue(i) = grCueDef
  Next i
  
  gnLastCue + nNewCues
  gnCueEnd + nNewCues
  
  nCurrCuePtr = nStartCuePtr
  
  ReDim aCueChange(CountGadgetItems(WIM\grdAddCues))
  grWIM\nCueChangePtr = -1
  
  For nRow = 0 To (CountGadgetItems(WIM\grdAddCues)-1)
    If GetGadgetItemState(WIM\grdAddCues,nRow) & #PB_ListIcon_Checked
      i2 = nRow + 1
      aCue(nCurrCuePtr) = a2ndCue(i2)
      
      sOrigCue = a2ndCue(i2)\sCue
      grWIM\nCueChangePtr + 1
      aCueChange(grWIM\nCueChangePtr)\sOrigCue = sOrigCue
      
      sCue = sOrigCue
      debugMsg(sProcName, "selected " + sCue + ", nCurrCuePtr=" + nCurrCuePtr)
      If GGS(WIM\optGenerateCueNumbers)
        ; generate new cue number
        aCue(nCurrCuePtr)\sCue = grCueDef\sCue
        If nCurrCuePtr = 1
          sCue = generateNextCueLabel("", grProd\nCueLabelIncrement)
        Else
          sCue = generateNextCueLabel(aCue(nCurrCuePtr-1)\sCue, grProd\nCueLabelIncrement)
        EndIf
        
        ; now check if that cue label is already in use
        bFound = #False
        For i = 1 To gnLastCue
          If UCase(aCue(i)\sCue) = UCase(sCue)
            bFound = #True
            Break
          EndIf
        Next i
        
        If bFound
          ; generated label already in use so create a unique label
          nCounter = 0
          bFound = #True
          While bFound And nCounter < 10000 ; prevent endless loop
            nCounter + 1
            sCue = generateNextCueLabel(sCue, grProd\nCueLabelIncrement)
            bFound = #False
            For i = 1 To gnLastCue
              If UCase(aCue(i)\sCue) = UCase(sCue)
                bFound = #True
                Break
              EndIf
            Next i
          Wend
        EndIf
        
        aCue(nCurrCuePtr)\sCue = sCue
        aCue(nCurrCuePtr)\nPreEditPtr = grCueDef\nPreEditPtr
        aCue(nCurrCuePtr)\nOriginalCuePtr = grCueDef\nOriginalCuePtr
        
      EndIf
      
      aCueChange(grWIM\nCueChangePtr)\sNewCue = sCue
      
      ; check if cue activation to be changed to manual
      For n = 0 To nManualPtr
        If sManual(n) = sOrigCue
          ; change to manual
          aCue(nCurrCuePtr)\nActivationMethod = #SCS_ACMETH_MAN
          aCue(nCurrCuePtr)\nActivationMethodReqd = #SCS_ACMETH_MAN
          ; debugMsg(sProcName, "aCue(" + getCueLabel(nCurrCuePtr) + ")\nActivationMethodReqd=" + decodeActivationMethod(aCue(nCurrCuePtr)\nActivationMethodReqd))
          aCue(nCurrCuePtr)\nAutoActCueSelType = grCueDef\nAutoActCueSelType
          aCue(nCurrCuePtr)\sAutoActCue = grCueDef\sAutoActCue
          aCue(nCurrCuePtr)\nAutoActPosn = grCueDef\nAutoActPosn
          aCue(nCurrCuePtr)\bHotkey = #False
          aCue(nCurrCuePtr)\sHotkey = grCueDef\sHotkey
          aCue(nCurrCuePtr)\sHotkeyLabel = grCueDef\sHotkeyLabel
          aCue(nCurrCuePtr)\bExtAct = #False
          aCue(nCurrCuePtr)\bCallableCue = #False
        EndIf
      Next n
      
      aCue(nCurrCuePtr)\sAutoActCue = WIM_getNewCue(aCue(nCurrCuePtr)\sAutoActCue)
      aCue(nCurrCuePtr)\nFirstSubIndex = -1
      ; debugMsg(sProcName, "aCue(" + nCurrCuePtr + ")\nFirstSubIndex=" + aCue(nCurrCuePtr)\nFirstSubIndex)
      nMyPrevSubIndex = -1
      
      setDerivedCueFields(nCurrCuePtr, #False)
      
      j2 = a2ndCue(i2)\nFirstSubIndex
      While j2 >= 0
        gnLastSub + 1
        checkMaxSub(gnLastSub)
        aSub(gnLastSub) = a2ndSub(j2)
        aSub(gnLastSub)\sCue = sCue
        aSub(gnLastSub)\nCueIndex = nCurrCuePtr
        
        ; fix up indexes for cue's firstSubIndex, and for sub's prev and next pointers
        If aCue(nCurrCuePtr)\nFirstSubIndex = -1
          aCue(nCurrCuePtr)\nFirstSubIndex = gnLastSub
          ; debugMsg(sProcName, "aCue(" + nCurrCuePtr + ")\nFirstSubIndex=" + aCue(nCurrCuePtr)\nFirstSubIndex)
        EndIf
        aSub(gnLastSub)\nPrevSubIndex = nMyPrevSubIndex
        If nMyPrevSubIndex >= 0
          aSub(nMyPrevSubIndex)\nNextSubIndex = gnLastSub
        EndIf
        nMyPrevSubIndex = gnLastSub
        If aSub(gnLastSub)\nNextSubIndex >= 0
          aSub(gnLastSub)\nNextSubIndex = gnLastSub + 1
        EndIf
        ; debugMsg(sProcName, "aSub(" + gnLastSub + ")\sSubLabel=" + aSub(gnLastSub)\sSubLabel + ", \nPrevSubIndex=" + aSub(gnLastSub)\nPrevSubIndex + ", \nNextSubIndex=" + aSub(gnLastSub)\nNextSubIndex)
        
        aSub(gnLastSub)\bHotkey = aCue(nCurrCuePtr)\bHotkey           ; cue activation may have been changed to manual
        aSub(gnLastSub)\bExtAct = aCue(nCurrCuePtr)\bExtAct           ; cue activation may have been changed to manual
        aSub(gnLastSub)\bCallableCue = aCue(nCurrCuePtr)\bCallableCue ; cue activation may have been changed to manual
        
        aSub(gnLastSub)\nFirstAudIndex = -1
        
        With aSub(gnLastSub)
          If \nPrevSubIndex = -1 And \nNextSubIndex = -1
            \sSubLabel = \sCue
          Else
            \sSubLabel = \sCue + "<" + \nSubNo + ">"
          EndIf
        EndWith
        
        setDerivedSubFields(gnLastSub, #True)
        
        If aSub(gnLastSub)\bSubTypeHasAuds
          
          nMyPrevAudIndex = -1
          
          k2 = a2ndSub(j2)\nFirstAudIndex
          While k2 >= 0
            gnLastAud + 1
            checkMaxAud(gnLastAud)
            aAud(gnLastAud) = a2ndAud(k2)
            aAud(gnLastAud)\sCue = sCue
            aAud(gnLastAud)\nCueIndex = nCurrCuePtr
            aAud(gnLastAud)\nSubIndex = gnLastSub
            aAud(gnLastAud)\nFileDataPtr = grAudDef\nFileDataPtr
            
            ; fix up indexes for sub's firstAudIndex, and for aud's prev and next pointers
            If aSub(gnLastSub)\nFirstAudIndex = -1
              aSub(gnLastSub)\nFirstAudIndex = gnLastAud
            EndIf
            aAud(gnLastAud)\nPrevAudIndex = nMyPrevAudIndex
            If nMyPrevAudIndex >= 0
              aAud(nMyPrevAudIndex)\nNextAudIndex = gnLastAud
            EndIf
            nMyPrevAudIndex = gnLastAud
            If aAud(gnLastAud)\nNextAudIndex >= 0
              aAud(gnLastAud)\nNextAudIndex = gnLastAud + 1
            EndIf
            ; debugMsg(sProcName, "aAud(" + gnLastAud + ")\sAudLabel=" + aAud(gnLastAud)\sAudLabel + ", \nPrevAudIndex=" + aAud(gnLastAud)\nPrevAudIndex + ", \nNextAudIndex=" + aAud(gnLastAud)\nNextAudIndex)
            
            If aSub(gnLastSub)\bSubTypeM
              For n = 0 To #SCS_MAX_CTRL_SEND
                debugMsg(sProcName, "aSub(gnLastSub)\aCtrlSend(" + n + ")\nMSMsgType=" + decodeMsgType(aSub(gnLastSub)\aCtrlSend[n]\nMSMsgType) + ", \sDisplayInfo=" + aSub(gnLastSub)\aCtrlSend[n]\sDisplayInfo)
                debugMsg(sProcName, "aSub(gnLastSub)\aCtrlSend(" + n + ")\nAudPtr=" + aSub(gnLastSub)\aCtrlSend[n]\nAudPtr + ", k2=" + k2 + ", gnLastAud=" + gnLastAud)
                If aSub(gnLastSub)\aCtrlSend[n]\nAudPtr = k2
                  aSub(gnLastSub)\aCtrlSend[n]\nAudPtr = gnLastAud
                EndIf
              Next n
            EndIf
            
            aAud(gnLastAud)\sStoredFileName = encodeFileName(aAud(gnLastAud)\sFileName, #False, grProd\bTemplate)
            If aSub(gnLastSub)\bSubTypeF
              If aAud(gnLastAud)\nFileFormat = #SCS_FILEFORMAT_AUDIO
                For d = 0 To grLicInfo\nMaxAudDevPerAud
                  aAud(gnLastAud)\sLogicalDev[d] = WIM_getNewDevice(aAud(gnLastAud)\sLogicalDev[d])
                Next d
              Else ; bMidiFile = True
                aAud(gnLastAud)\sLogicalDev = WIM_getNewMidiDevice(aAud(gnLastAud)\sLogicalDev)
              EndIf
            EndIf
            
            With aAud(gnLastAud)
              \sFileExt = GetExtensionPart(\sFileName)
              \nFileFormat = getFileFormat(\sFileName)
              If aSub(\nSubIndex)\nAudCount <= 1
                \sAudLabel = aSub(gnLastSub)\sSubLabel
              ElseIf Right(aSub(gnLastSub)\sSubLabel, 1) = ">"
                \sAudLabel = Left(aSub(gnLastSub)\sSubLabel, Len(aSub(gnLastSub)\sSubLabel) - 1) + "." + \nAudNo + ">"
              Else
                \sAudLabel = aSub(gnLastSub)\sSubLabel + "<" + "." + \nAudNo + ">"
              EndIf
            EndWith
            
            setDerivedAudFields(gnLastAud)
            setMissingCueMarkerIds(gnLastAud)
            If aAud(gnLastAud)\nFileFormat = #SCS_FILEFORMAT_PICTURE
              saveLastPicInfo(gnLastAud)
            EndIf
            k2 = a2ndAud(k2)\nNextAudIndex
          Wend
          If aSub(gnLastSub)\bSubTypeP
            For d = 0 To grLicInfo\nMaxAudDevPerAud
              aSub(gnLastSub)\sPLLogicalDev[d] = WIM_getNewDevice(aSub(gnLastSub)\sPLLogicalDev[d])
            Next d
          EndIf
          ; call setDerivedSubFields() again as it sets \nPLTrackCount
          setDerivedSubFields(gnLastSub, #True)
          generatePlayOrder(gnLastSub)
          
        ElseIf aSub(gnLastSub)\bSubTypeG   ; bSubTypeG
          aSub(gnLastSub)\sCueToGoTo = WIM_getNewCue(aSub(gnLastSub)\sCueToGoTo)
          
        ElseIf aSub(gnLastSub)\bSubTypeL   ; bSubTypeL
          aSub(gnLastSub)\sLCCue = WIM_getNewCue(aSub(gnLastSub)\sLCCue)
          
        ElseIf aSub(gnLastSub)\bSubTypeS   ; bSubTypeS
          For h = 0 To #SCS_MAX_SFR
            aSub(gnLastSub)\sSFRCue[h] = WIM_getNewCue(aSub(gnLastSub)\sSFRCue[h])
          Next h
          
        ElseIf aSub(gnLastSub)\bSubTypeT   ; bSubTypeT
          aSub(gnLastSub)\sSetPosCue = WIM_getNewCue(aSub(gnLastSub)\sSetPosCue)
          
        EndIf
        j2 = a2ndSub(j2)\nNextSubIndex
      Wend
      setInitCueStates(nCurrCuePtr, -1, #False)
      nCurrCuePtr + 1
    EndIf
  Next nRow
  
  ; debugMsg(sProcName, "calling (c) debugProd()")
  ; debugProd()
  
  gbImportedCues = #True
  
  debugMsg(sProcName, "calling validateDevMaps()")
  validateDevMaps()
  
  debugMsg(sProcName, "calling setCuePtrs")
  setCuePtrs(#False)
  loadCueBrackets()
  
  debugProd(@grProd)
  debugCuePtrs()
  
  debugMsg(sProcName, "calling propagateFileInfo()")
  propagateFileInfo()
  debugMsg(sProcName, "calling setTimeBasedCues()")
  setTimeBasedCues()
  debugMsg(sProcName, "calling WED_enableTBTButton(#SCS_TBEB_SAVE, #True)")
  WED_enableTBTButton(#SCS_TBEB_SAVE, #True)
  debugMsg(sProcName, "calling WED_setEditorButtons()")
  WED_setEditorButtons()
  debugMsg(sProcName, "calling redoCueListTree(-1)")
  redoCueListTree(-1)
  debugMsg(sProcName, "calling WMN_loadHotkeyPanel()")
  WMN_loadHotkeyPanel()
  debugMsg(sProcName, "calling populateGrid()")
  populateGrid()
  debugMsg(sProcName, "calling clearVUDisplay()")
  clearVUDisplay()
  
  ; added 20Jan2016 11.4.2 to set 'active' indicators for new devices in device maps
  debugMsg(sProcName, "calling checkDevMap(" + getDevMapName(grProd\nSelectedDevMapPtr) + ")")
  nCheckDevMapResult = checkDevMap(grProd\nSelectedDevMapPtr)
  debugMsg(sProcName, "checkDevMap(" + getDevMapName(grProd\nSelectedDevMapPtr) + ") returned " + nCheckDevMapResult)
  ; end added 20Jan2016
  
;   debugMsg(sProcName, "calling listAllDevMaps()")
;   listAllDevMaps()
  
  WIM_loadTargetCueCombo()
  WIM_btnClearAll_Click()
  
  ; Added 8Nov2023 11.10.0cs
  If nStartCuePtr >= 0
    nNodeKey = aCue(nStartCuePtr)\nNodeKey
    debugMsg(sProcName, "nStartCuePtr=" + nStartCuePtr + ", aCue(" + nStartCuePtr + ")\sCue=" + aCue(nStartCuePtr)\sCue + ", \nNodeKey=" + aCue(nStartCuePtr)\nNodeKey)
    debugMsg(sProcName, "calling WED_doNodeClick(" + nNodeKey + ", #False, #True)")
    WED_doNodeClick(nNodeKey, #False, #True)
    ; debugMsg(sProcName, "returned from WED_doNodeClick(" + nNodeKey + ", #False, #True)")
  EndIf
  ; End added 8Nov2023 11.10.0cs
  
  gnCallOpenNextCues = 1
  gbCallLoadDispPanels = #True
  
  If nNewCues = 1
    sMsg = Lang("WIM", "Imported1")
  Else
    sMsg = LangPars("WIM", "Imported>1", Str(nNewCues))
  EndIf
  sMsg + Chr(10) + Chr(10) + Lang("WIM", "ProdFolderNote")
  setMouseCursorNormal()
  debugMsg(sProcName, sMsg)
  scsMessageRequester(GWT(#WIM), sMsg, #PB_MessageRequester_Ok|#MB_ICONINFORMATION)
  
  setMouseCursorNormal()
  WIM_Form_Unload()
  
  UnlockCueListMutex()
  
  ED_loadDevChgsFromProd()
  debugMsg(sProcName, "calling resetSessionOptions()")
  resetSessionOptions()
  
  grWIM\bImportingCues = #False
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WIM_DrawProgress(nCurrValue, nMaxValue)
  Protected nWidth, nHeight
  Protected nPos
  
  If StartDrawing(CanvasOutput(WIM\cvsProgress))
      nWidth = GadgetWidth(WIM\cvsProgress)
      nHeight = GadgetHeight(WIM\cvsProgress)
      ; Box(0,0,nWidth,nHeight,#SCS_Dark_Grey)
      Box(0,0,nWidth,nHeight,#SCS_Light_Grey)
      If nCurrValue > 0
        If nCurrValue >= nMaxValue
          nPos = nWidth
        Else
          nPos = Round((nCurrValue * nWidth) / nMaxValue, #PB_Round_Nearest)
        EndIf
        ; Box(0,0,nPos,nHeight,#SCS_Light_Green)
        Box(0,0,nPos,nHeight,#SCS_Green)
      EndIf
    StopDrawing()
  EndIf
EndProcedure

Procedure WIM_Form_Load()
  PROCNAMEC()
  
  If IsWindow(#WIM) = #False
    createfmImport()
  EndIf
  setFormPosition(#WIM, @grImportWindow)
  WIM_Form_Resized(#True)
  
  setEnabled(WIM\btnFavorites, #True)
  
  WIM_DrawProgress(0,0)
  WIM_setupGrdAddCues()
  WIM_setButtons()
  WIM_loadTargetCueCombo()

  setWindowVisible(#WIM, #True)

EndProcedure

Procedure WIM_Form_Unload()
  PROCNAMEC()
  getFormPosition(#WIM, @grImportWindow, #True)
  unsetWindowModal(#WIM)
  scsCloseWindow(#WIM)
  If IsWindow(#WED)
    SAW(#WED)
  EndIf
EndProcedure

Procedure WIM_setupDevices()
  PROCNAMEC()
  Protected d1, d2
  
  debugMsg(sProcName, #SCS_START)
  
  gnLastImportDev = -1
  gnLastImportMidiDev = -1
  
  ; Changed 15Dec2022 11.01.0ac
  If gr2ndProd\nMaxAudioLogicalDev > ArraySize(gaImportDev())
    ReDim gaImportDev(gr2ndProd\nMaxAudioLogicalDev)
  EndIf
  ; End changed 15Dec2022 11.01.0ac
  
  For d2 = 0 To gr2ndProd\nMaxAudioLogicalDev
    If Trim(gr2ndProd\aAudioLogicalDevs(d2)\sLogicalDev)
      gnLastImportDev + 1
      If gnLastImportDev > ArraySize(gaImportDev())
        ReDim gaImportDev(gnLastImportDev + 10)
      EndIf
      With gaImportDev(gnLastImportDev)
        \nDevGrp = #SCS_DEVGRP_AUDIO_OUTPUT
        \nDevType = #SCS_DEVTYPE_AUDIO_OUTPUT
        \s2ndLogicalDev = gr2ndProd\aAudioLogicalDevs(d2)\sLogicalDev
        \b2ndUsedInCues = #False
        \s2ndCues = ""
        \s1stLogicalDev = ""
      EndWith
    EndIf
  Next d2
  
  For d2 = 0 To gr2ndProd\nMaxVidAudLogicalDev
    If Trim(gr2ndProd\aVidAudLogicalDevs(d2)\sVidAudLogicalDev)
      gnLastImportDev + 1
      If gnLastImportDev > ArraySize(gaImportDev())
        ReDim gaImportDev(gnLastImportDev + 10)
      EndIf
      With gaImportDev(gnLastImportDev)
        \nDevGrp = #SCS_DEVGRP_VIDEO_AUDIO
        \nDevType = #SCS_DEVTYPE_VIDEO_AUDIO
        \s2ndLogicalDev = gr2ndProd\aVidAudLogicalDevs(d2)\sVidAudLogicalDev
        \b2ndUsedInCues = #False
        \s2ndCues = ""
        \s1stLogicalDev = ""
      EndWith
    EndIf
  Next d2
  
  For d2 = 0 To gr2ndProd\nMaxVidCapLogicalDev
    If Trim(gr2ndProd\aVidCapLogicalDevs(d2)\sLogicalDev)
      gnLastImportDev + 1
      If gnLastImportDev > ArraySize(gaImportDev())
        ReDim gaImportDev(gnLastImportDev + 10)
      EndIf
      With gaImportDev(gnLastImportDev)
        \nDevGrp = #SCS_DEVGRP_VIDEO_CAPTURE
        \nDevType = #SCS_DEVTYPE_VIDEO_CAPTURE
        \s2ndLogicalDev = gr2ndProd\aVidCapLogicalDevs(d2)\sLogicalDev
        \b2ndUsedInCues = #False
        \s2ndCues = ""
        \s1stLogicalDev = ""
      EndWith
    EndIf
  Next d2
  
  For d2 = 0 To gr2ndProd\nMaxLightingLogicalDev
    If Len(Trim(gr2ndProd\aLightingLogicalDevs(d2)\sLogicalDev)) > 0
      gnLastImportDev + 1
      If gnLastImportDev > ArraySize(gaImportDev())
        ReDim gaImportDev(gnLastImportDev + 10)
      EndIf
      With gaImportDev(gnLastImportDev)
        \nDevGrp = #SCS_DEVGRP_LIGHTING
        \nDevType = gr2ndProd\aLightingLogicalDevs(d2)\nDevType
        \s2ndLogicalDev = gr2ndProd\aLightingLogicalDevs(d2)\sLogicalDev
        \b2ndUsedInCues = #False
        \s2ndCues = ""
        \s1stLogicalDev = ""
      EndWith
    EndIf
  Next d2
  
  For d2 = 0 To gr2ndProd\nMaxCtrlSendLogicalDev
    If Len(Trim(gr2ndProd\aCtrlSendLogicalDevs(d2)\sLogicalDev)) > 0
      gnLastImportDev + 1
      If gnLastImportDev > ArraySize(gaImportDev())
        ReDim gaImportDev(gnLastImportDev + 10)
      EndIf
      With gaImportDev(gnLastImportDev)
        \nDevGrp = #SCS_DEVGRP_CTRL_SEND
        \nDevType = gr2ndProd\aCtrlSendLogicalDevs(d2)\nDevType
        \s2ndLogicalDev = gr2ndProd\aCtrlSendLogicalDevs(d2)\sLogicalDev
        \b2ndUsedInCues = #False
        \s2ndCues = ""
        \s1stLogicalDev = ""
      EndWith
    EndIf
  Next d2
  
  For d2 = 0 To gnLastImportDev
    With gaImportDev(d2)
      Select \nDevGrp
        Case #SCS_DEVGRP_AUDIO_OUTPUT
          For d1 = 0 To grProd\nMaxAudioLogicalDev
            If grProd\aAudioLogicalDevs(d1)\sLogicalDev = \s2ndLogicalDev
              \s1stLogicalDev = grProd\aAudioLogicalDevs(d1)\sLogicalDev
              Break
            EndIf
          Next d1
          
        Case #SCS_DEVGRP_VIDEO_AUDIO
          For d1 = 0 To gr2ndProd\nMaxVidAudLogicalDev
            If grProd\aVidAudLogicalDevs(d1)\sVidAudLogicalDev = \s2ndLogicalDev
              \s1stLogicalDev = grProd\aVidAudLogicalDevs(d1)\sVidAudLogicalDev
              Break
            EndIf
          Next d1
          
        Case #SCS_DEVGRP_VIDEO_CAPTURE
          For d1 = 0 To gr2ndProd\nMaxVidCapLogicalDev
            If grProd\aVidCapLogicalDevs(d1)\sLogicalDev = \s2ndLogicalDev
              \s1stLogicalDev = grProd\aVidCapLogicalDevs(d1)\sLogicalDev
              Break
            EndIf
          Next d1
          
        Case #SCS_DEVGRP_LIGHTING
          debugMsg(sProcName, "grProd\nMaxLightingLogicalDev=" + grProd\nMaxLightingLogicalDev + ", gaImportDev(" + d2 + ")\nDevType=" + decodeDevType(\nDevType) + ", \s2ndLogicalDev=" + \s2ndLogicalDev)
          For d1 = 0 To grProd\nMaxLightingLogicalDev
            If grProd\aLightingLogicalDevs(d1)\nDevType = \nDevType
              debugMsg(sProcName, "grProd\aLightingLogicalDevs(" + d1 + ")\sLogicalDev=" + grProd\aLightingLogicalDevs(d1)\sLogicalDev)
              If grProd\aLightingLogicalDevs(d1)\sLogicalDev = \s2ndLogicalDev
                \s1stLogicalDev = grProd\aLightingLogicalDevs(d1)\sLogicalDev
                Break
              EndIf
              debugMsg(sProcName, "gaImportDev(" + d2 + ")\s1stLogicalDev=" + \s1stLogicalDev)
            EndIf
          Next d1
          
        Case #SCS_DEVGRP_CTRL_SEND
          For d1 = 0 To grProd\nMaxCtrlSendLogicalDev
            If grProd\aCtrlSendLogicalDevs(d1)\nDevType = \nDevType
              If grProd\aCtrlSendLogicalDevs(d1)\sLogicalDev = \s2ndLogicalDev
                \s1stLogicalDev = grProd\aCtrlSendLogicalDevs(d1)\sLogicalDev
                Break
              EndIf
            EndIf
          Next d1
          
      EndSelect
    EndWith
  Next d2
  
  debugMsg(sProcName, "calling WIM_listImportDevs()")
  WIM_listImportDevs()
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WIM_setupGrdAddCues()
  PROCNAMEC()

  debugMsg(sProcName, #SCS_START)
  
  ClearGadgetItems(WIM\grdAddCues)

EndProcedure

Procedure WIM_btnBrowse_Click()
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
  sThisCueFile = OpenFileRequester(sTitle, sDefaultFile, gsPatternAllCueFiles, 0)
  If Len(sThisCueFile) = 0
    ; no file selected
    ProcedureReturn
  EndIf
  SGT(WIM\txtCueFile, GetFilePart(sThisCueFile))
  scsToolTip(WIM\txtCueFile, sThisCueFile)
  
  setMouseCursorBusy()
  
  gs2ndCueFile = sThisCueFile
  gs2ndCueFolder = GetPathPart(gs2ndCueFile)
  debugMsg(sProcName, "gs2ndCueFolder=" + gs2ndCueFolder)
  
  open2ndSCSCueFile()
  If gb2ndCueFileOpen
    If gb2ndXMLFormat
      WIM_clearDevMapsForImport()
      debugMsg(sProcName, "calling readXMLCueFile(" + Str(gn2ndCueFileNo) + ", #False, " + gn2ndCueFileStringFormat + ", " + GetFilePart(sThisCueFile) + ")")
      readXMLCueFile(gn2ndCueFileNo, #False, gn2ndCueFileStringFormat, sThisCueFile)
      debugMsg(sProcName, "returned from readXMLCueFile()")
    EndIf
    close2ndSCSCueFile(gn2ndCueFileNo)
;     debugMsg(sProcName, "calling debugCuePtrs2()")
;     debugCuePtrs2()
  EndIf
  
  debugMsg(sProcName, "calling WIM_displayOtherProdInfo()")
  WIM_displayOtherProdInfo()
  
  setMouseCursorNormal()
  
  SAW(#WIM)
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WIM_displayOtherProdInfo()
  PROCNAMEC()
  Protected i, j, nRow
  Protected sCue.s, sCueType.s

  debugMsg(sProcName, #SCS_START)
  
  debugMsg(sProcName, "gs2ndCueFile=" + gs2ndCueFile)
  
  ; SGT(WIM\txtCueFile, gs2ndCueFile)
  SGT(WIM\txtCueFile, GetFilePart(gs2ndCueFile))
  scsToolTip(WIM\txtCueFile, gs2ndCueFile)
  SGT(WIM\txtProdTitle, gr2ndProd\sTitle)

  ClearGadgetItems(WIM\grdAddCues) ; clear any existing content

  For i = 1 To gn2ndLastCue
    nRow = i-1
    sCue = a2ndCue(i)\sCue
    j = a2ndCue(i)\nFirstSubIndex
    If j >= 0
      sCueType = decode2ndSubType(a2ndSub(j)\sSubType, j)
      If a2ndSub(j)\nNextSubIndex >= 0
        sCue + "+"
      EndIf
    EndIf
    AddGadgetItem(WIM\grdAddCues, -1, "" + Chr(10) + sCue + Chr(10) + a2ndCue(i)\sPageNo + Chr(10) + a2ndCue(i)\sCueDescr + Chr(10) + sCueType)
    SetGadgetItemColor(WIM\grdAddCues, nRow, #PB_Gadget_BackColor, a2ndCue(i)\nBackColor, -1)
    SetGadgetItemColor(WIM\grdAddCues, nRow, #PB_Gadget_FrontColor, a2ndCue(i)\nTextColor, -1)
  Next i
  
  autoFitGridCol(WIM\grdAddCues, 3) ; autofit "Description" column
  
  WIM_setupDevices()

  WIM_setButtons()

EndProcedure

Procedure WIM_setButtons()
  Protected nRow
  Protected nRowCount, nRowsChecked

  nRowCount = CountGadgetItems(WIM\grdAddCues)
  For nRow = 0 To nRowCount-1
    If GetGadgetItemState(WIM\grdAddCues,nRow) & #PB_ListIcon_Checked
      nRowsChecked + 1
    EndIf
  Next nRow

  If nRowCount = 0 Or nRowsChecked = nRowCount
    setEnabled(WIM\btnSelectAll, #False)
  Else
    setEnabled(WIM\btnSelectAll, #True)
  EndIf

  If nRowsChecked = 0
    setEnabled(WIM\btnClearAll, #False)
    setEnabled(WIM\btnAddSelected, #False)
  Else
    setEnabled(WIM\btnClearAll, #True)
    setEnabled(WIM\btnAddSelected, #True)
  EndIf

EndProcedure

Procedure WIM_loadTargetCueCombo()
  PROCNAMEC()
  Protected i, nListIndex, nEndIndex
  Protected sTmp.s

  ClearGadgetItems(WIM\cboTargetCue)
  For i = 1 To gnLastCue
    sTmp = buildCueForCBO(i, "", #True)
    addGadgetItemWithData(WIM\cboTargetCue, sTmp, i)
  Next i
  addGadgetItemWithData(WIM\cboTargetCue, grText\sTextEnd, gnCueEnd)
  nEndIndex = CountGadgetItems(WIM\cboTargetCue)-1

  If (nEditCuePtr > 0) And (nEditCuePtr <= gnLastCue)
    nListIndex = indexForComboBoxData(WIM\cboTargetCue, nEditCuePtr, nEndIndex)
  Else
    nListIndex = indexForComboBoxData(WIM\cboTargetCue, gnCueEnd, nEndIndex)
  EndIf
  SGS(WIM\cboTargetCue, nListIndex)

EndProcedure

Procedure.s WIM_getNewCue(sOrigCue.s)
  Protected n, sNewCue.s
  
  sNewCue = sOrigCue
  For n = 0 To grWIM\nCueChangePtr
    If aCueChange(n)\sOrigCue = sOrigCue
      sNewCue = aCueChange(n)\sNewCue
      Break
    EndIf
  Next n
  ProcedureReturn sNewCue
EndProcedure

Procedure.s WIM_getNewDevice(sOrigDevice.s)
  Protected n, sNewDevice.s
  
  sNewDevice = sOrigDevice
  For n = 0 To gnLastImportDev
    If gaImportDev(n)\s2ndLogicalDev = sOrigDevice
      sNewDevice = gaImportDev(n)\s1stLogicalDev
      Break
    EndIf
  Next n
  ProcedureReturn sNewDevice
EndProcedure

Procedure.s WIM_getNewMidiDevice(sOrigDevice.s)
  Protected n, sNewDevice.s
  
  sNewDevice = sOrigDevice
  For n = 0 To gnLastImportMidiDev
    If gaImportMidiDev(n)\s2ndLogicalDev = sOrigDevice
      sNewDevice = gaImportMidiDev(n)\s1stLogicalDev
      Break
    EndIf
  Next n
  ProcedureReturn sNewDevice
EndProcedure

Procedure WIM_createFixtureTypesIfReqd(nLightingDevIndex)
  PROCNAMEC()
  Protected nFixtureIndex, sMyFixTypeName.s
  Protected nFixTypeIndex1, nFixTypeIndex2
  
  debugMsg(sProcName, #SCS_START + ", nLightingDevIndex=" + nLightingDevIndex)
  
  With gr2ndProd\aLightingLogicalDevs(nLightingDevIndex)
    For nFixtureIndex = 0 To \nMaxFixture
      sMyFixTypeName = \aFixture(nFixtureIndex)\sFixTypeName
      nFixTypeIndex1 = DMX_getFixTypeIndex(@grProd, sMyFixTypeName)
      If nFixTypeIndex1 < 0
        ; fixture type does not yet exist in grProd
        nFixTypeIndex2 = DMX_getFixTypeIndex(@gr2ndProd, sMyFixTypeName)
        If nFixTypeIndex2 >= 0
          ; should be #True!
          grProd\nMaxFixType + 1
          If grProd\nMaxFixType > ArraySize(grProd\aFixTypes())
            ReDim grProd\aFixTypes(grProd\nMaxFixType + 5)
          EndIf
          grProd\nMaxFixTypeDisplay = grProd\nMaxFixType + 1
          debugMsg0(sProcName, "Adding Fixture Type " + sMyFixTypeName + " to grProd")
          grProd\aFixTypes(grProd\nMaxFixType) = gr2ndProd\aFixTypes(nFixTypeIndex2)
        EndIf
      EndIf
    Next nFixtureIndex
  EndWith
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WIM_createDevices()
  PROCNAMEC()
  Protected i, j, k, d, m, n
  Protected sMyLogicalDev.s
  Protected bFound
  Protected nDevMapDevPtr
  Protected nImportDevMapPtr, nImportDevMapDevPtr
  
  debugMsg(sProcName, #SCS_START)
  
;   debugMsg(sProcName, "calling loadDevMapsForDevChgs()")
;   loadDevMapsForDevChgs()
  debugMsg(sProcName, "calling ED_loadDevChgsFromProd()")
  ED_loadDevChgsFromProd()
  
  ; first, remove any devices not currently used
  For n = 0 To grProd\nMaxAudioLogicalDev
    sMyLogicalDev = Trim(grProd\aAudioLogicalDevs(n)\sLogicalDev)
    If sMyLogicalDev
      bFound = #False
      For i = 1 To gnLastCue
        j = aCue(i)\nFirstSubIndex
        While j >= 0
          If aSub(j)\bSubTypeF
            k = aSub(j)\nFirstAudIndex
            While k >= 0
              For d = 0 To grLicInfo\nMaxAudDevPerAud
                If aAud(k)\sLogicalDev[d] = sMyLogicalDev
                  bFound = #True
                  Break
                EndIf
              Next d
              k = aAud(k)\nNextAudIndex
            Wend
          ElseIf aSub(j)\bSubTypeP
            For d = 0 To grLicInfo\nMaxAudDevPerAud
              If aSub(j)\sPLLogicalDev[d] = sMyLogicalDev
                bFound = #True
                Break
              EndIf
            Next d
          EndIf
          j = aSub(j)\nNextSubIndex
        Wend
        If bFound
          Break
        EndIf
      Next i
    EndIf
    If bFound = #False
      grProd\aAudioLogicalDevs(n)\sLogicalDev = ""
      grProd\aAudioLogicalDevs(n)\nBassDevice = -1
      grProd\aAudioLogicalDevs(n)\nBassASIODevice = -1
    EndIf
  Next n
  
  ; pack remaining devices
  m = 0
  For n = 0 To grProd\nMaxAudioLogicalDev
    If grProd\aAudioLogicalDevs(n)\sLogicalDev
      If m <> n
        grProd\aAudioLogicalDevs(m) = grProd\aAudioLogicalDevs(n)
      EndIf
      m + 1
    EndIf
  Next n
  While m <= grProd\nMaxAudioLogicalDev
    grProd\aAudioLogicalDevs(m)\sLogicalDev = ""
    grProd\aAudioLogicalDevs(m)\nBassDevice = -1
    grProd\aAudioLogicalDevs(m)\nBassASIODevice = -1
    m + 1
  Wend
  
  debugMsg(sProcName, "calling (e3) debugProd(@grProd)")
  debugProd(@grProd)
  debugMsg(sProcName, "calling (e3) debugProd(@gr2ndProd)")
  debugProd(@gr2ndProd)

  ; create new devices
  For n = 0 To gr2ndProd\nMaxAudioLogicalDev
    ;{
    sMyLogicalDev = Trim(gr2ndProd\aAudioLogicalDevs(n)\sLogicalDev)
    If sMyLogicalDev
      debugMsg(sProcName, "n=" + n + ", sMyLogicalDev=" + sMyLogicalDev)
      bFound = #False
      For m = 0 To grProd\nMaxAudioLogicalDev
        If grProd\aAudioLogicalDevs(m)\sLogicalDev = sMyLogicalDev
          bFound = #True
          Break
        EndIf
      Next m
      debugMsg(sProcName, "gr2ndProd\aAudioLogicalDevs(" + n + ")\sLogicalDev=" + gr2ndProd\aAudioLogicalDevs(n)\sLogicalDev + ", bFound=" + strB(bFound))
      If bFound = #False
        If grProd\nMaxAudioLogicalDev < grLicInfo\nMaxAudDevPerProd
          grProd\nMaxAudioLogicalDev + 1
          If grProd\nMaxAudioLogicalDev < grLicInfo\nMaxAudDevPerProd
            grProd\nMaxAudioLogicalDevDisplay = grProd\nMaxAudioLogicalDev + 1
          EndIf
          If grProd\nMaxAudioLogicalDevDisplay > ArraySize(grProd\aAudioLogicalDevs())
            ReDim grProd\aAudioLogicalDevs(grProd\nMaxAudioLogicalDevDisplay)
          EndIf
        EndIf
        For m = 0 To grProd\nMaxAudioLogicalDev
          If Len(Trim(grProd\aAudioLogicalDevs(m)\sLogicalDev)) = 0
            grProd\aAudioLogicalDevs(m) = gr2ndProd\aAudioLogicalDevs(n)
            debugMsg(sProcName, "grProd\aAudioLogicalDevs(" + m + ")\sLogicalDev=" + grProd\aAudioLogicalDevs(m)\sLogicalDev)
            With grProd\aAudioLogicalDevs(m)
              nDevMapDevPtr = addDevToDevChgsDevMap(#SCS_DEVGRP_AUDIO_OUTPUT, #SCS_DEVTYPE_AUDIO_OUTPUT, \nDevId, \sLogicalDev, \nNrOfOutputChans)
            EndWith
            setDevChgsPhysDevIfReqd(nDevMapDevPtr, m)
            Break
          EndIf
        Next m
      EndIf
    EndIf
    ;}
  Next n
  
  For n = 0 To gr2ndProd\nMaxLiveInputLogicalDev
    ;{
    sMyLogicalDev = gr2ndProd\aLiveInputLogicalDevs(n)\sLogicalDev
    If Len(Trim(sMyLogicalDev)) > 0
      bFound = #False
      For m = 0 To grProd\nMaxLiveInputLogicalDev
        If Trim(grProd\aLiveInputLogicalDevs(m)\sLogicalDev) = Trim(sMyLogicalDev)
          bFound = #True
          Break
        EndIf
      Next m
      debugMsg(sProcName, "gr2ndProd\aLiveInputLogicalDevs(" + n + ")\sLogicalDev=" + gr2ndProd\aLiveInputLogicalDevs(n)\sLogicalDev + ", bFound=" + strB(bFound))
      If bFound = #False
        If grProd\nMaxLiveInputLogicalDev < grLicInfo\nMaxLiveDevPerProd
          grProd\nMaxLiveInputLogicalDev + 1
          If grProd\nMaxLiveInputLogicalDev < grLicInfo\nMaxLiveDevPerProd
            grProd\nMaxLiveInputLogicalDevDisplay = grProd\nMaxLiveInputLogicalDev + 1
          EndIf
          If grProd\nMaxLiveInputLogicalDevDisplay > ArraySize(grProd\aLiveInputLogicalDevs())
            ReDim grProd\aLiveInputLogicalDevs(grProd\nMaxLiveInputLogicalDevDisplay)
          EndIf
        EndIf
        For m = 0 To grProd\nMaxLiveInputLogicalDev
          If Len(Trim(grProd\aLiveInputLogicalDevs(m)\sLogicalDev)) = 0
            grProd\aLiveInputLogicalDevs(m) = gr2ndProd\aLiveInputLogicalDevs(n)
            With grProd\aLiveInputLogicalDevs(m)
              nDevMapDevPtr = addDevToDevChgsDevMap(#SCS_DEVGRP_LIVE_INPUT, #SCS_DEVTYPE_LIVE_INPUT, \nDevId, \sLogicalDev)
            EndWith
            setDevChgsPhysDevIfReqd(nDevMapDevPtr, m)
            Break
          EndIf
        Next m
      EndIf
    EndIf
    ;}
  Next n
  
  For n = 0 To gr2ndProd\nMaxLightingLogicalDev
    ;{
    sMyLogicalDev = gr2ndProd\aLightingLogicalDevs(n)\sLogicalDev
    If Len(Trim(sMyLogicalDev)) > 0
      bFound = #False
      For m = 0 To grProd\nMaxLightingLogicalDev
        If Trim(grProd\aLightingLogicalDevs(m)\sLogicalDev) = Trim(sMyLogicalDev)
          bFound = #True
          Break
        EndIf
      Next m
      If bFound = #False
        If grProd\nMaxLightingLogicalDev < grLicInfo\nMaxLightingDevPerProd
          grProd\nMaxLightingLogicalDev + 1
          If grProd\nMaxLightingLogicalDev < grLicInfo\nMaxLightingDevPerProd
            grProd\nMaxLightingLogicalDevDisplay = grProd\nMaxLightingLogicalDev + 1
          EndIf
          If grProd\nMaxLightingLogicalDevDisplay > ArraySize(grProd\aLightingLogicalDevs())
            ReDim grProd\aLightingLogicalDevs(grProd\nMaxLightingLogicalDevDisplay)
          EndIf
        EndIf
        For m = 0 To grProd\nMaxLightingLogicalDev
          If Len(Trim(grProd\aLightingLogicalDevs(m)\sLogicalDev)) = 0
            grProd\aLightingLogicalDevs(m) = gr2ndProd\aLightingLogicalDevs(n)
            With grProd\aLightingLogicalDevs(m)
              nImportDevMapPtr = getDevMapPtrForSelectedDevMap(@grMapsForImport)
              nImportDevMapDevPtr = getDevMapDevPtrForLogicalDev(@grMapsForImport, #SCS_DEVGRP_LIGHTING, \sLogicalDev, nImportDevMapPtr)
              nDevMapDevPtr = addDevToDevChgsDevMap(#SCS_DEVGRP_LIGHTING, \nDevType, \nDevId, \sLogicalDev, 0, 0, -1, @grMapsForImport\aDev(nImportDevMapDevPtr))
              debugMsg0(sProcName, "nImportDevMapPtr=" + nImportDevMapPtr + ", nImportDevMapDevPtr=" + nImportDevMapDevPtr + ", nDevMapDevPtr=" + nDevMapDevPtr)
            EndWith
            If gr2ndProd\aLightingLogicalDevs(n)\nMaxFixture >= 0
              WIM_createFixtureTypesIfReqd(n)
            EndIf
            setDevChgsPhysDevIfReqd(nDevMapDevPtr, m)
            Break
          EndIf
        Next m
      EndIf
    EndIf
    ;}
  Next n
  
  For n = 0 To gr2ndProd\nMaxCtrlSendLogicalDev
    ;{
    sMyLogicalDev = gr2ndProd\aCtrlSendLogicalDevs(n)\sLogicalDev
    If Len(Trim(sMyLogicalDev)) > 0
      bFound = #False
      For m = 0 To grProd\nMaxCtrlSendLogicalDev
        If Trim(grProd\aCtrlSendLogicalDevs(m)\sLogicalDev) = Trim(sMyLogicalDev)
          bFound = #True
          Break
        EndIf
      Next m
      ; debugMsg(sProcName, "gr2ndProd\aCtrlSendLogicalDevs(" + n + ")\sLogicalDev=" + gr2ndProd\aCtrlSendLogicalDevs(n)\sLogicalDev + ", bFound=" + strB(bFound))
      If bFound = #False
        If grProd\nMaxCtrlSendLogicalDev < grLicInfo\nMaxCtrlSendDevPerProd
          grProd\nMaxCtrlSendLogicalDev + 1
          If grProd\nMaxCtrlSendLogicalDev < grLicInfo\nMaxCtrlSendDevPerProd
            grProd\nMaxCtrlSendLogicalDevDisplay = grProd\nMaxCtrlSendLogicalDev + 1
          EndIf
          If grProd\nMaxCtrlSendLogicalDevDisplay > ArraySize(grProd\aCtrlSendLogicalDevs())
            ReDim grProd\aCtrlSendLogicalDevs(grProd\nMaxCtrlSendLogicalDevDisplay)
          EndIf
        EndIf
        For m = 0 To grProd\nMaxCtrlSendLogicalDev
          If Len(Trim(grProd\aCtrlSendLogicalDevs(m)\sLogicalDev)) = 0
            grProd\aCtrlSendLogicalDevs(m) = gr2ndProd\aCtrlSendLogicalDevs(n)
            With grProd\aCtrlSendLogicalDevs(m)
              nDevMapDevPtr = addDevToDevChgsDevMap(#SCS_DEVGRP_CTRL_SEND, \nDevType, \nDevId, \sLogicalDev)
            EndWith
            setDevChgsPhysDevIfReqd(nDevMapDevPtr, m)
            Break
          EndIf
        Next m
      EndIf
    EndIf
    ;}
  Next n
  
  debugMsg(sProcName, "calling applyDevMapsForDevChgs()")
  applyDevMapsForDevChgs()
;   debugMsg(sProcName, "calling ED_applyDevChgs()")
;   ED_applyDevChgs()
  
  debugMsg(sProcName, "calling mapCtrlLogicalDevsToPhysicalDevs")
  mapCtrlLogicalDevsToPhysicalDevs()
  
  debugMsg(sProcName, "calling mapLiveLogicalDevsToPhysicalDevs")
  mapLiveLogicalDevsToPhysicalDevs()
  
  setDisplayPanFlags()
  
  ; debugMsg(sProcName, "calling debugProd()")
  ; debugProd()
  debugMsg(sProcName, #SCS_END)

EndProcedure

Procedure WIM_Form_Show(bModal=#False)
  PROCNAMEC()
  
  debugMsg(sProcName, #SCS_START)
  
  If IsWindow(#WIM) = #False
    WIM_Form_Load()
  EndIf
  
  setWindowModal(#WIM, bModal)
  setWindowVisible(#WIM, #True)
  SAW(#WIM)
EndProcedure

Procedure WIM_EventHandler()
  PROCNAMEC()
  Protected nRow
  
  With WIM
    Select gnWindowEvent
        
      Case #PB_Event_CloseWindow
        WIM_Form_Unload()
        
      Case #PB_Event_Menu
        gnEventMenu = EventMenu()
        debugMsg(sProcName, "gnEventMenu=" + decodeMenuItem(gnEventMenu))
        Select gnEventMenu
            
          Case #SCS_mnuKeyboardReturn   ; Return
            If getEnabled(\btnAddSelected)
              WIM_btnAddSelected_Click()
            EndIf
            
          Case #SCS_mnuKeyboardEscape   ; Escape
            WIM_Form_Unload()
            
        EndSelect
        
      Case #PB_Event_Gadget
        ;debugMsg(sProcName, "gnEventGadgetNo=G" + gnEventGadgetNo)
        Select gnEventGadgetNoForEvHdlr
            
          Case \btnAddSelected
            WIM_btnAddSelected_Click()
            
          Case \btnBrowse
            WIM_btnBrowse_Click()
            
          Case \btnClearAll
            WIM_btnClearAll_Click()
            
          Case \btnClose
            WIM_Form_Unload()
            
          Case \btnFavorites
            WFF_Form_Show(#WIM, #True, #SCS_MODRETURN_IMPORT, #False)
            
          Case \btnHelp
            displayHelpTopic("scs_import.htm")
            
          Case \btnSelectAll
            For nRow = 0 To (CountGadgetItems(WIM\grdAddCues)-1)
              SetGadgetItemState(WIM\grdAddCues, nRow, #PB_ListIcon_Checked)
            Next nRow
            WIM_setButtons()
            
          Case \cboTargetCue
            ; no action
            
          Case \cvsProgress
            ; ignore events
            
          Case \grdAddCues
            If gnEventType = #PB_EventType_LeftClick
              WIM_setButtons()
            EndIf
            
          Case \optGenerateCueNumbers
            ; no action
            
          Case \optPreserveCueNumbers
            ; no action
            
          Default
            debugMsg(sProcName, "gnEventGadgetNo=G" + gnEventGadgetNo + ", gnEventType=" + decodeEventType())
        EndSelect
        
      Case #PB_Event_SizeWindow
        WIM_Form_Resized()
        
    EndSelect
  EndWith
  
EndProcedure

Procedure WIM_load2ndCueFile()
  PROCNAMEC()
  
  debugMsg(sProcName, #SCS_START)
  
  open2ndSCSCueFile()
  If gb2ndXMLFormat
    WIM_clearDevMapsForImport()
    readXMLCueFile(gn2ndCueFileNo, #False, gn2ndCueFileStringFormat, gs2ndCueFile)
  EndIf
  
  If gb2ndCueFileOpen
    close2ndSCSCueFile(gn2ndCueFileNo)
  EndIf
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WIM_btnClearAll_Click()
  Protected nRow
  
  For nRow = 0 To (CountGadgetItems(WIM\grdAddCues)-1)
    SetGadgetItemState(WIM\grdAddCues, nRow, 0)
  Next nRow
  WIM_setButtons()
EndProcedure

Procedure WIM_Form_Resized(bForceProcessing=#False)
  PROCNAMEC()
  Protected nWindowWidth, nWindowHeight
  Static nPrevWindowWidth, nPrevWindowHeight
  Protected nLeft, nTop, nWidth, nHeight
  
  If IsWindow(#WIM) = #False
    ; appears this procedure can be called after the window has been closed
    ProcedureReturn
  EndIf
  
  With WIM
    nWindowWidth = WindowWidth(#WIM)
    nWindowHeight = WindowHeight(#WIM)
    If (nWindowWidth <> nPrevWindowWidth) Or (nWindowHeight <> nPrevWindowHeight) Or (bForceProcessing)
      nPrevWindowWidth = nWindowWidth
      nPrevWindowHeight = nWindowHeight
      
      ; resize \grdAddCues
      nLeft = GadgetX(\grdAddCues)
      nWidth = nWindowWidth - (nLeft << 1)
      nTop = GadgetY(\grdAddCues)
      nHeight = nWindowHeight - nTop - GadgetHeight(\cntBelowGrid)
      ResizeGadget(\grdAddCues, #PB_Ignore, #PB_Ignore, nWidth, nHeight)
      autoFitGridCol(\grdAddCues, 2) ; autofit "Description" column
      
      ; reposition and resize \cntBelowGrid
      nTop = nWindowHeight - GadgetHeight(\cntBelowGrid)
      ResizeGadget(\cntBelowGrid,#PB_Ignore,nTop,nWindowWidth,#PB_Ignore)
      
      ; resize \cvsProgress
      nLeft = GadgetX(\cvsProgress)
      nWidth = nWindowWidth - (nLeft << 1)
      ResizeGadget(\cvsProgress,#PB_Ignore,#PB_Ignore,nWidth,#PB_Ignore)
      WIM_DrawProgress(0,0)
      
    EndIf
  EndWith
  
EndProcedure

Procedure WIM_listImportDevs()
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

Procedure WIM_clearDevMapsForImport()
  PROCNAMEC()
  
  With grMapsForImport
    \nMaxMapIndex= -1
    \nMaxDevIndex = -1
    \nMaxLiveGrpIndex = -1
  EndWith
  
EndProcedure

;/EOF
