; File CueCommon.pbi

EnableExplicit

; ==============================================================================================================================
; The purpose of CueCommon.pbi is to keep in one place procedures that may need to be changed when a new cue type is added.
; Some procedures, however, cannot easily be kept here, and constants, globals and field defintions will also be held elsewhere.
; By keeping as much as possible in this file, the introduction of a new cue type is made easier.
; ==============================================================================================================================

Procedure populateCueTypeArray()
  PROCNAMEC()
  
  ;- SCS Cue Types
  ;  A  video/image
  ;  B  subroutine
  ;  C  end subroutine
  ;  D  call subroutine
  ;  E  memo
  ;  F  audio file
  ;  G  goto cue
  ;  H  multi-file cue (multiple audio files) (not yet implemented)
  ;  I  live input
  ;  J  enable/disable cues
  ;  K  lighting
  ;  L  level change
  ;  M  control send
  ;  N  note
  ;  P  playlist
  ;  Q  call cue
  ;  R  run program
  ;  S  SFR (stop/fade-out/loop-release)
  ;  T  set position
  ;  U  MIDI time code (MTC)
  
  Protected sCueTypes.s = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
  Protected sCueType.s
  Protected n, nIndex
  Protected nCurrLicLevel
  
  If grLicInfo\sLicType = "D"
    nCurrLicLevel = #SCS_LIC_DEMO
  Else
    nCurrLicLevel = grLicInfo\nLicLevel
  EndIf
  
  For n = 1 To Len(sCueTypes)
    sCueType = Mid(sCueTypes,n,1)
    nIndex = Asc(sCueType) - Asc("A") ; returns 0 for "A", 1 for "B", etc
    With gaCueType(nIndex)
      \sCueType = sCueType
      Select sCueType
        Case "A", "L", "N", "P"
          \nMinLicLevel = #SCS_LIC_STD
          
        Case "B", "C", "D", "E", "G", "I", "J", "K", "M", "Q", "T", "U"
          \nMinLicLevel = #SCS_LIC_PRO
          
        Default
          \nMinLicLevel = #SCS_LIC_LITE
          
      EndSelect
      If nCurrLicLevel >= \nMinLicLevel
        \bCueTypeAvailable = #True
      Else
        \bCueTypeAvailable = #False
      EndIf
      ; debugMsg(sProcName, "sCueType=" + sCueType + ", gaCueType(" + nIndex + ")\bCueTypeAvailable=" + strB(\bCueTypeAvailable))
    EndWith
  Next n
  
EndProcedure

Procedure createfmEditSubIfReqd(pSubType.s)
  PROCNAMEC()
  Protected bWaitDisplayed
  
  ASSERT_THREAD(#SCS_THREAD_MAIN)
  
  With grCED
    Select pSubType
      Case "A"
        If \bQACreated = #False
          WQA_Form_Load()
        EndIf
        
      Case "B"
        ; no action - no subcue info kept for Subroutine cues
        
      Case "C"
        ; no action - no subcue info kept for End Subroutine cues
        
      Case "E"
        If \bQECreated = #False
          WQE_Form_Load()
        EndIf
        
      Case "F"
        If \bQFCreated = #False
          WQF_Form_Load()
        EndIf
        
      Case "G"
        If \bQGCreated = #False
          WQG_Form_Load()
        EndIf
        
      Case "I"
        If \bQICreated = #False
          WQI_Form_Load()
        EndIf
        
      Case "J"
        If \bQJCreated = #False
          WQJ_Form_Load()
        EndIf
        
      Case "K"
        If \bQKCreated = #False
          WMI_displayInfoMsg1(LangPars("WMI", "InitEditCueProps", grText\sTextCueTypeK)) ; "Initializing Editor Lighting Cue Properties"
          bWaitDisplayed = #True
          WQK_Form_Load()
        EndIf
        
      Case "L"
        If \bQLCreated = #False
          WQL_Form_Load()
        EndIf
        
      Case "M"
        If \bQMCreated = #False
          WQM_Form_Load()
        EndIf
        
      Case "N"
        ; no action - no subcue info kept for Note cues
        
      Case "P"
        If \bQPCreated = #False
          WQP_Form_Load()
        EndIf
        
      Case "Q"
        If \bQQCreated = #False
          WQQ_Form_Load()
        EndIf
        
      Case "R"
        If \bQRCreated = #False
          WQR_Form_Load()
        EndIf
        
      Case "S"
        If \bQSCreated = #False
          WQS_Form_Load()
        EndIf
        
      Case "T"
        If \bQTCreated = #False
          WQT_Form_Load()
        EndIf
        
      Case "U"
        If \bQUCreated = #False
          WQU_Form_Load()
        EndIf
        
      Default
        scsMessageRequester(#SCS_TITLE, "unhandled pSubType in createfmEditSubIfReqd: " + pSubType)
        
    EndSelect
  EndWith
  
  If bWaitDisplayed
    WMI_clearInfoMsgs()
  EndIf
  
EndProcedure

Procedure commonValidation()
  PROCNAMEC()
  Protected bValidationOK = #True
  Protected nGadgetPropsIndex, nGWindowNo, nEditorComponent
  Protected nHoldEventGadgetNoForEvHdlr
  Protected nActiveGadget
  
  If gnValidateGadgetNo > 0
    nGadgetPropsIndex = getGadgetPropsIndex(gnValidateGadgetNo)
    If nGadgetPropsIndex >= 0
      ; active gadget test added 18Mar2016 11.5.0p to avoid repeated displays of error messages when try to click on the item in error
      ; (same reason as active gadget is checked in the 'lost focus' event in handleWindowEvents())
      nActiveGadget = GetActiveGadget()
      ; debugMsg(sProcName, "nActiveGadget=" + getGadgetName( nActiveGadget) + ", gnValidateGadgetNo=" + getGadgetName( gnValidateGadgetNo))
      If nActiveGadget <> gnValidateGadgetNo ; Or 1=1
        ; save gnEventGadgetNoForEvHdlr so we can reset it for gnValidateGadgetNo
        nHoldEventGadgetNoForEvHdlr = gnEventGadgetNoForEvHdlr
        gnEventGadgetNoForEvHdlr = gaGadgetProps(nGadgetPropsIndex)\nGadgetNoForEvHdlr
        nGWindowNo = gaGadgetProps(nGadgetPropsIndex)\nGWindowNo
        ; debugMsg(sProcName, "nGWindowNo=" + decodeWindow(nGWindowNo))
        Select nGWindowNo
          Case #WED
            nEditorComponent = gaGadgetProps(nGadgetPropsIndex)\nEditorComponent
            Select nEditorComponent
              Case #WEP
                bValidationOK = WEP_valGadget(gnValidateGadgetNo)
              Case #WEC
                bValidationOK = WEC_valGadget(gnValidateGadgetNo)
              Case #WQA
                bValidationOK = WQA_valGadget(gnValidateGadgetNo)
              Case #WQE
                bValidationOK = WQE_valGadget(gnValidateGadgetNo)
              Case #WQF
                bValidationOK = WQF_valGadget(gnValidateGadgetNo)
              Case #WQG
                bValidationOK = WQG_valGadget(gnValidateGadgetNo)
              Case #WQI
                bValidationOK = WQI_valGadget(gnValidateGadgetNo)
              Case #WQJ
                bValidationOK = WQJ_valGadget(gnValidateGadgetNo)
              Case #WQK
                bValidationOK = WQK_valGadget(gnValidateGadgetNo)
              Case #WQL
                bValidationOK = WQL_valGadget(gnValidateGadgetNo)
              Case #WQM
                bValidationOK = WQM_valGadget(gnValidateGadgetNo)
              Case #WQP
                bValidationOK = WQP_valGadget(gnValidateGadgetNo)
              Case #WQQ
                bValidationOK = WQQ_valGadget(gnValidateGadgetNo)
              Case #WQR
                bValidationOK = WQR_valGadget(gnValidateGadgetNo)
              Case #WQS
                bValidationOK = WQS_valGadget(gnValidateGadgetNo)
              Case #WQT
                bValidationOK = WQT_valGadget(gnValidateGadgetNo)
              Case #WQU
                bValidationOK = WQU_valGadget(gnValidateGadgetNo)
            EndSelect
            
          Case #WOP
            bValidationOK = WOP_valGadget(gnValidateGadgetNo)
            
        EndSelect
        
        ; reinstate gnGadgetNoForEvHdlr
        gnEventGadgetNoForEvHdlr = nHoldEventGadgetNoForEvHdlr
        
      EndIf ; EndIf nActiveGadget <> gnValidateGadgetNo
      
    EndIf ; EndIf nGadgetPropsIndex >= 0
    
    If bValidationOK
      gnValidateGadgetNo = 0
      gnValidateSubPtr = -1
    Else
      debugMsg(sProcName, "bValidationOK=" + strB(bValidationOK) + ", gnValidateGadgetNo=G" + gnValidateGadgetNo + ", gnValidateSubPtr=" + gnValidateSubPtr)
      SAG(gnValidateGadgetNo)
      debugMsg(sProcName, "returned from SAG()")
    EndIf
    
  EndIf ; EndIf gnValidateGadgetNo > 0
  
  ProcedureReturn bValidationOK
  
EndProcedure

Procedure sanityCheck()
  PROCNAMEC()
  Protected d, i, j, k, n
  Protected i2, bFound
  Protected bSubTypeA, bSubTypeE, bSubTypeF, bSubTypeG, bSubTypeI, bSubTypeJ, bSubTypeK, bSubTypeL, bSubTypeM, bSubTypeN, bSubTypeP, bSubTypeQ, bSubTypeR, bSubTypeS, bSubTypeT, bSubTypeU
  Protected sCue.s, sSub.s, sMsg.s, sMsg2.s, nSubNo
  Protected nPrevSubIndex, nPrevAudIndex, nPrevPlayIndex
  Protected nAudCount
  Protected nManPlusConfCuePtr
  Protected bSanityCheckFailed
  
  debugMsg(sProcName, #SCS_START)
  
  While #True
    
    For i = 1 To gnLastCue
      sCue = aCue(i)\sCue
      ; debugMsg(sProcName, "checking cue #" + i + ": " + sCue)
      bSubTypeA = #False
      bSubTypeE = #False
      bSubTypeF = #False
      bSubTypeG = #False
      bSubTypeI = #False
      bSubTypeJ = #False
      bSubTypeK = #False
      bSubTypeL = #False
      bSubTypeM = #False
      bSubTypeN = #False
      bSubTypeP = #False
      bSubTypeQ = #False
      bSubTypeR = #False
      bSubTypeS = #False
      bSubTypeT = #False
      bSubTypeU = #False
      
      If aCue(i)\nActivationMethod = #SCS_ACMETH_MAN_PLUS_CONF
        If nManPlusConfCuePtr = 0
          nManPlusConfCuePtr = i
        EndIf
      EndIf
      
      nSubNo = 0
      j = aCue(i)\nFirstSubIndex
      nPrevSubIndex = -1
      While (j >= 1) And (bSanityCheckFailed = #False)
        With aSub(j)
          sSub = aSub(j)\sSubLabel
          ; debugMsg(sProcName, "checking sub #" + j + ": " + \sSubLabel)
          nSubNo + 1
          If \nSubNo <> nSubNo
            sMsg = "Incorrect nSubNo for Sub " + \sSubLabel
            sMsg2 = "\nSubNo=" + \nSubNo + ", nSubNo=" + nSubNo
            bSanityCheckFailed = #True
            Break
          EndIf
          
          If \bExists = #False
            sMsg = "bExists=False for Sub " + \sSubLabel
            bSanityCheckFailed = #True
            Break
          EndIf
          
          If \nPrevSubIndex <> nPrevSubIndex
            sMsg = "Incorrect nPrevSubIndex for Sub " + \sSubLabel
            sMsg2 = "\nPrevSubIndex=" + \nPrevSubIndex + ", nPrevSubIndex=" + nPrevSubIndex
            bSanityCheckFailed = #True
            Break
          EndIf
          nPrevSubIndex = j
          
          If (\bSubTypeA And \sSubType <> "A") Or
             (\bSubTypeE And \sSubType <> "E") Or
             (\bSubTypeF And \sSubType <> "F") Or
             (\bSubTypeG And \sSubType <> "G") Or
             (\bSubTypeI And \sSubType <> "I") Or
             (\bSubTypeJ And \sSubType <> "J") Or
             (\bSubTypeK And \sSubType <> "K") Or
             (\bSubTypeL And \sSubType <> "L") Or
             (\bSubTypeM And \sSubType <> "M") Or
             (\bSubTypeN And \sSubType <> "N") Or
             (\bSubTypeP And \sSubType <> "P") Or
             (\bSubTypeQ And \sSubType <> "Q") Or
             (\bSubTypeR And \sSubType <> "R") Or
             (\bSubTypeS And \sSubType <> "S") Or
             (\bSubTypeT And \sSubType <> "T") Or
             (\bSubTypeU And \sSubType <> "U")
            sMsg = "bSubType and sSubType incompatible for Sub " + \sSubLabel
            bSanityCheckFailed = #True
            Break
          EndIf
          
          Select \sSubType
            Case "A"
              bSubTypeA = #True
            Case "E"
              bSubTypeE = #True
            Case "F"
              bSubTypeF = #True
            Case "G"
              bSubTypeG = #True
            Case "I"
              bSubTypeI = #True
            Case "J"
              bSubTypeJ = #True
            Case "K"
              bSubTypeK = #True
            Case "L"
              bSubTypeL = #True
            Case "M"
              bSubTypeM = #True
            Case "N"
              bSubTypeN = #True
            Case "P"
              bSubTypeP = #True
            Case "Q"
              bSubTypeQ = #True
            Case "R"
              bSubTypeR = #True
            Case "S"
              bSubTypeS = #True
            Case "T"
              bSubTypeT = #True
            Case "U"
              bSubTypeU = #True
            Default
              sMsg = "Unknown sSubType for Sub " + \sSubLabel
              sMsg2 = "\sSubType=" + \sSubType
              bSanityCheckFailed = #True
              Break
          EndSelect
          
          If \sCue <> sCue
            sMsg = "Incorrect sCue for Sub " + \sSubLabel
            sMsg2 = "\sCue=" + \sCue + ", sCue=" + sCue
            bSanityCheckFailed = #True
            Break
          EndIf
          
          If \nCueIndex <> i
            sMsg = "Incorrect nCueIndex for Sub " + \sSubLabel
            sMsg2 = "\nCueIndex=" + \nCueIndex + ", i=" + i
            bSanityCheckFailed = #True
            Break
          EndIf
          
          If Not (\bSubTypeA Or \bSubTypeF Or \bSubTypeP Or \bSubTypeI Or \bSubTypeM)
            If \nFirstAudIndex >= 0
              sMsg = "nFirstAudIndex invalid for this sSubType for Sub " + \sSubLabel
              sMsg2 = "\nFirstAudIndex=" + \nFirstAudIndex
              bSanityCheckFailed = #True
              Break
            EndIf
            If \nFirstPlayIndex >= 0
              sMsg = "nFirstPlayIndex invalid for this sSubType for Sub " + \sSubLabel
              sMsg2 = "\nFirstPlayIndex=" + \nFirstPlayIndex
              bSanityCheckFailed = #True
              Break
            EndIf
          EndIf
          
          k = \nFirstAudIndex
          nPrevAudIndex = -1
          nAudCount = 0
          While (k >= 1) And (bSanityCheckFailed = #False)
            ; debugMsg(sProcName, "checking aud #" + k + ": " + aAud(k)\sAudLabel)
            nAudCount + 1
            
            If aAud(k)\bExists = #False
              sMsg = "bExists=False for Aud " + k + "(" + aAud(k)\sAudLabel + ")"
              sMsg2 = "\sCue=" + aAud(k)\sCue + ", sCue=" + sCue + ", \nSubIndex=" + aAud(k)\nSubIndex + ", sSub=" + sSub
              bSanityCheckFailed = #True
              Break
            EndIf
            
            If aAud(k)\nPrevAudIndex <> nPrevAudIndex
              sMsg = "Incorrect nPrevAudIndex for Aud " + aAud(k)\sAudLabel
              sMsg2 = "\nPrevAudIndex=" + aAud(k)\nPrevAudIndex + ", nPrevAudIndex=" + Str(nPrevAudIndex)
              bSanityCheckFailed = #True
              Break
            EndIf
            nPrevAudIndex = k
            
            If aAud(k)\sCue <> sCue
              sMsg = "Incorrect sCue for Aud " + aAud(k)\sAudLabel
              sMsg2 = "\sCue=" + aAud(k)\sCue + ", sCue=" + sCue
              bSanityCheckFailed = #True
              Break
            EndIf
            
            If aAud(k)\nCueIndex <> i
              sMsg = "Incorrect nCueIndex for Aud " + aAud(k)\sAudLabel
              sMsg2 = "\nCueIndex=" + Str(aAud(k)\nCueIndex) + ", i=" + i
              bSanityCheckFailed = #True
              Break
            EndIf
            
            If aAud(k)\nSubIndex <> j
              sMsg = "Incorrect nSubIndex for Aud " + aAud(k)\sAudLabel
              sMsg2 = "\nSubIndex=" + Str(aAud(k)\nSubIndex) + ", j=" + j
              bSanityCheckFailed = #True
              Break
            EndIf
            
            If aAud(k)\nSubNo <> nSubNo
              sMsg = "Incorrect nSubNo for Aud " + aAud(k)\sAudLabel
              sMsg2 = "\nSubNo=" + aAud(k)\nSubNo + ", nSubNo=" + nSubNo
              bSanityCheckFailed = #True
              Break
            EndIf
            
            k = aAud(k)\nNextAudIndex
          Wend
          If bSanityCheckFailed
            Break
          EndIf
          
          If \bSubTypeF Or \bSubTypeI
            If nAudCount > 1
              sMsg = "sSubType " + \sSubType + " has " + nAudCount + " files (Sub " + \sSubLabel + ")"
              bSanityCheckFailed = #True
              Break
            EndIf
          EndIf
          
          If \bSubTypeL
            bFound = #False
            If Len(Trim(\sLCCue)) <> 0
              For i2 = 1 To gnLastCue
                If aCue(i2)\sCue = \sLCCue
                  bFound = #True
                  If \nLCCuePtr <> i2
                    sMsg = "nLCCuePtr incorrect for Sub " + \sSubLabel
                    sMsg2 = "\nLCCuePtr=" + \nLCCuePtr + ", i2=" + i2
                    bSanityCheckFailed = #True
                    Break
                  EndIf
                  Break
                EndIf
              Next i2
              If bFound = #False
                sMsg = "sLCCue not found for Sub " + \sSubLabel
                sMsg2 = "\sLCCue=" + \sLCCue
                bSanityCheckFailed = #True
                Break
              EndIf
              
              If \nLCSubPtr < 1 Or \nLCSubPtr > ArraySize(aSub())
                sMsg = "nLCSubPtr out of range for Sub " + \sSubLabel
                sMsg2 = "\nLCSubPtr=" + \nLCSubPtr
                bSanityCheckFailed = #True
                Break
              EndIf
              
              If \nLCSubNo <> aSub(\nLCSubPtr)\nSubNo
                sMsg = "nLCSubNo incorrect for Sub " + \sSubLabel
                sMsg2 = "aSub(" + \nLCSubPtr + ")\nSubNo=" + aSub(\nLCSubPtr)\nSubNo + ", \nLCSubNo=" + \nLCSubNo
                bSanityCheckFailed = #True
                Break
              EndIf
              
              If \nLCSubRef <> aSub(\nLCSubPtr)\nSubRef
                sMsg = "nLCSubRef incorrect for Sub " + \sSubLabel
                sMsg2 = "aSub(\nLCSubPtr)\nSubRef=" + aSub(\nLCSubPtr)\nSubRef + ", \nLCSubRef=" + \nLCSubRef
                bSanityCheckFailed = #True
                Break
              EndIf
              
              If aSub(\nLCSubPtr)\sCue <> \sLCCue
                sMsg = "aSub(\nLCSubPtr)\sCue incorrect for Sub " + \sSubLabel
                sMsg2 = "aSub(" + \nLCSubPtr + ")\sCue=" + aSub(\nLCSubPtr)\sCue + ", .sLCCue=" + \sLCCue
                bSanityCheckFailed = #True
                Break
              EndIf
              
              If \bLCTargetIsF Or \bLCTargetIsI
                If \nLCAudPtr < 1 Or \nLCAudPtr > ArraySize(aAud())
                  sMsg = "nLCAudPtr out of range for Sub " + \sSubLabel
                  sMsg2 = "\nLCAudPtr=" + \nLCAudPtr
                  bSanityCheckFailed = #True
                  Break
                EndIf
                
                If aAud(\nLCAudPtr)\nSubIndex <> \nLCSubPtr
                  sMsg = "\nLCSubPtr incorrect for Sub " + \sSubLabel
                  sMsg2 = "aAud(" + \nLCAudPtr + ")\nSubIndex=" + aAud(\nLCAudPtr)\nSubIndex + ", \nLCSubPtr=" + \nLCSubPtr
                  bSanityCheckFailed = #True
                  Break
                EndIf
              EndIf
              
              bFound = #False
            EndIf
          EndIf
          
          If \bSubTypeS
            For n = 0 To #SCS_MAX_SFR
              If \nSFRCueType[n] = #SCS_SFR_CUE_SEL
                If \sSFRCue[n]
                  bFound = #False
                  For i2 = 1 To gnLastCue
                    If aCue(i2)\sCue = \sSFRCue[n]
                      bFound = #True
                      If \nSFRCuePtr[n] <> i2
                        sMsg = "Incorrect nSFRCuePtr(" + n + ") for Sub " + \sSubLabel
                        sMsg2 = "\nSFRCuePtr(" + n + ")=" + \nSFRCuePtr[n] + ", i2=" + i2
                        bSanityCheckFailed = #True
                        Break
                      EndIf
                      Break
                    EndIf
                  Next i2
                  If bSanityCheckFailed
                    Break
                  EndIf
                  If bFound = #False
                    sMsg = "\sSFRCue(" + n + ") not found for Sub " + \sSubLabel
                    sMsg2 = "\sSFRCue(" + n + ")=" + \sSFRCue[n]
                    bSanityCheckFailed = #True
                    Break
                  EndIf
                EndIf
              EndIf
            Next n
            If bSanityCheckFailed
              Break
            EndIf
          EndIf
          
          j = \nNextSubIndex
        EndWith
      Wend
      If bSanityCheckFailed
        Break
      EndIf
      
      With aCue(i)
        If (\nActivationMethod = #SCS_ACMETH_AUTO Or \nActivationMethod = #SCS_ACMETH_AUTO_PLUS_CONF) And (\nAutoActPosn <> #SCS_ACPOSN_LOAD) And (\nAutoActCueSelType = #SCS_ACCUESEL_DEFAULT)
          bFound = #False
          For i2 = 1 To gnLastCue
            If aCue(i2)\sCue = \sAutoActCue
              bFound = #True
              If \nAutoActCuePtr <> i2
                sMsg = "nAutoActCuePtr incorrect for Cue " + \sCue
                sMsg2 = "\nAutoActCuePtr=" + \nAutoActCuePtr + ", i2=" + i2
                bSanityCheckFailed = #True
                Break
              EndIf
              Break
            EndIf
          Next i2
          If bSanityCheckFailed
            Break
          EndIf
          If bFound = #False
            sMsg = "sAutoActCue not found for Cue " + \sCue
            sMsg2 = "\sAutoActCue=" + \sAutoActCue
            bSanityCheckFailed = #True
            Break
          EndIf
        EndIf
      EndWith
      
      ; debugMsg0(sProcName, "calling checkCallableCueParamsValid(" + getCueLabel(i) + ")")
      If checkCallableCueParamsValid(i) = #False
        sMsg = gsError
        bSanityCheckFailed = #True
        Break
      EndIf
      
    Next i
    Break
  Wend
  
  If bSanityCheckFailed
    ; sanity check failed
    debugMsg(sProcName, "sanity check failed")
    debugMsg(sProcName, "---------------------")
    If sMsg2
      debugMsg(sProcName, sMsg + ", " + sMsg2)
    Else
      debugMsg(sProcName, sMsg)
    EndIf
    debugMsg(sProcName, "---------------------")
    debugMsg(sProcName, "calling debugCuePtrs()")
    debugCuePtrs()
    setMouseCursorNormal()
    ensureSplashNotOnTop()
    If sMsg2
      scsMessageRequester("SCS Sanity Check", sMsg + Chr(10) + sMsg2, #PB_MessageRequester_Error)
    Else
      scsMessageRequester("SCS Sanity Check", sMsg, #PB_MessageRequester_Error)
    EndIf
    debugMsg(sProcName, #SCS_END + " sanity check failed")
    ProcedureReturn #False
    
  Else
    ; sanity check passed
    debugMsg(sProcName, #SCS_END + " sanity check passed")
    ProcedureReturn #True
    
  EndIf
  
EndProcedure

Procedure setEditorComponentVisible(sType.s)
  ; PROCNAMEC()
  Protected sPrevDisplayedSubType.s, bWaitDisplayed
  
  ; debugMsg(sProcName, #SCS_START + ", sType=" + sType)
  
  With grCED
    sPrevDisplayedSubType = \sDisplayedSubType
    \sDisplayedSubType = ""
    
    ; phase 1: hide unwanted components
    If (\bProdDisplayed) And (sType <> "Prod")
      setVisible(WEP\scaProdProperties, #False)
      \bProdDisplayed = #False
    EndIf
    
    ; debugMsg(sProcName, "\bCueDisplayed=" + strB(\bCueDisplayed))
    If \bCueDisplayed
      Select sType
        Case "QA", "QE", "QF", "QG", "QI", "QJ", "QK", "QL", "QM", "QN", "QP", "QQ", "QR", "QS", "QT", "QU"
          ; do nothing
        Default
          setVisible(WEC\splEditH, #False)
          \bCueDisplayed = #False
      EndSelect
    EndIf
    
    If \bQADisplayed And sType <> "QA"
      setVisible(WQA\scaSlideShow, #False)
      setVisible(WED\cntSpecialQA, #False)
      \bQADisplayed = #False
    EndIf
    
    If \bQEDisplayed And sType <> "QE"
      setVisible(WQE\scaMemo, #False)
      \bQEDisplayed = #False
    EndIf
    
    If \bQFDisplayed And sType <> "QF"
      setVisible(WQF\scaSoundFile, #False)
      setVisible(WED\cntSpecialQF, #False)
      \bQFDisplayed = #False
    EndIf
    
    If \bQGDisplayed And sType <> "QG"
      setVisible(WQG\scaGoTo, #False)
      \bQGDisplayed = #False
    EndIf
    
    If \bQIDisplayed And sType <> "QI"
      setVisible(WQI\scaLiveInput, #False)
      \bQIDisplayed = #False
    EndIf
    
    If \bQJDisplayed And sType <> "QJ"
      setVisible(WQJ\scaEnableDisable, #False)
      \bQJDisplayed = #False
    EndIf
    
    If \bQKDisplayed And sType <> "QK"
      setVisible(WQK\scaLighting, #False)
      \bQKDisplayed = #False
    EndIf
    
    If \bQLDisplayed And sType <> "QL"
      setVisible(WQL\scaLevelChange, #False)
      \bQLDisplayed = #False
    EndIf
    
    If \bQMDisplayed And sType <> "QM"
      setVisible(WQM\scaCtrlSend, #False)
      \bQMDisplayed = #False
    EndIf
    
    If \bQPDisplayed And sType <> "QP"
      setVisible(WQP\scaPlaylist, #False)
      \bQPDisplayed = #False
    EndIf
    
    If \bQQDisplayed And sType <> "QQ"
      setVisible(WQQ\scaCallCue, #False)
      \bQQDisplayed = #False
    EndIf
    
    If \bQRDisplayed And sType <> "QR"
      setVisible(WQR\scaRunProg, #False)
      \bQRDisplayed = #False
    EndIf
    
    If \bQSDisplayed And sType <> "QS"
      setVisible(WQS\scaSFRCues, #False)
      \bQSDisplayed = #False
    EndIf
    
    If \bQTDisplayed And sType <> "QT"
      setVisible(WQT\scaSetPos, #False)
      \bQTDisplayed = #False
    EndIf
    
    If \bQUDisplayed And sType <> "QU"
      setVisible(WQU\scaMTCCue, #False)
      \bQUDisplayed = #False
    EndIf
    
    ; phase 2: display wanted components
    If sType = "Prod"
      If \bProdCreated = #False
        WEP_Form_Load()
      EndIf
      setVisible(WEP\scaProdProperties, #True)
      \bProdDisplayed = #True
    EndIf
    
    If FindString("QA QE QF QG QI QJ QK QL QM QN QP QQ QR QS QT QU", sType, 1) > 0
      If \bCueDisplayed = #False
        If \bCueCreated = #False
          WEC_Form_Load()
        EndIf
        ; setVisible(WEC\scaCueProperties, #True)
        setVisible(WEC\splEditH, #True)
        \bCueDisplayed = #True
      EndIf
    EndIf
    
    Select sType
      Case "QA"
        If \bQACreated = #False
          WQA_Form_Load()
        EndIf
        If \bQADisplayed = #False
          SetGadgetAttribute(WEC\splEditH, #PB_Splitter_SecondGadget, WQA\scaSlideShow)
          setVisible(WQA\scaSlideShow, #True)
          setVisible(WED\cntSpecialQA, #True)
          \bQADisplayed = #True
          WQA_adjustForSplitterSize()
        EndIf
        \sDisplayedSubType = "A"  ; must be outside 'If \bQADisplayed = #False' because \sDisplayedSubType was cleared at start of procedure
        
      Case "QE"
        If \bQECreated = #False
          WQE_Form_Load()
        EndIf
        If \bQEDisplayed = #False
          SetGadgetAttribute(WEC\splEditH, #PB_Splitter_SecondGadget, WQE\scaMemo)
          setVisible(WQE\scaMemo, #True)
          \bQEDisplayed = #True
          WQE_adjustForSplitterSize()
        EndIf
        grCED\sDisplayedSubType = "E"
        
      Case "QF"
        If \bQFCreated = #False
          WQF_Form_Load()
        EndIf
        If \bQFDisplayed = #False
          SetGadgetAttribute(WEC\splEditH, #PB_Splitter_SecondGadget, WQF\scaSoundFile)
          setVisible(WQF\scaSoundFile, #True)
          setVisible(WED\cntSpecialQF, #True)
          \bQFDisplayed = #True
          WQF_adjustForSplitterSize()
        EndIf
        \sDisplayedSubType = "F"
        
      Case "QG"
        If \bQGCreated = #False
          WQG_Form_Load()
        EndIf
        If \bQGDisplayed = #False
          SetGadgetAttribute(WEC\splEditH, #PB_Splitter_SecondGadget, WQG\scaGoTo)
          setVisible(WQG\scaGoTo, #True)
          \bQGDisplayed = #True
          WQG_adjustForSplitterSize()
        EndIf
        \sDisplayedSubType = "G"
        
      Case "QI"
        If \bQICreated = #False
          WQI_Form_Load()
        EndIf
        If \bQIDisplayed = #False
          SetGadgetAttribute(WEC\splEditH, #PB_Splitter_SecondGadget, WQI\scaLiveInput)
          setVisible(WQI\scaLiveInput, #True)
          \bQIDisplayed = #True
          WQI_adjustForSplitterSize()
        EndIf
        \sDisplayedSubType = "I"
        
      Case "QJ"
        If \bQJCreated = #False
          WQJ_Form_Load()
        EndIf
        If \bQJDisplayed = #False
          SetGadgetAttribute(WEC\splEditH, #PB_Splitter_SecondGadget, WQJ\scaEnableDisable)
          setVisible(WQJ\scaEnableDisable, #True)
          \bQJDisplayed = #True
          WQJ_adjustForSplitterSize()
        EndIf
        \sDisplayedSubType = "J"
        
      Case "QK"
        If \bQKCreated = #False
          WMI_displayInfoMsg1(LangPars("WMI", "InitEditCueProps", grText\sTextCueTypeK)) ; "Initializing Editor Lighting Cue Properties"
          bWaitDisplayed = #True
          WQK_Form_Load()
        EndIf
        If \bQKDisplayed = #False
          SetGadgetAttribute(WEC\splEditH, #PB_Splitter_SecondGadget, WQK\scaLighting)
          setVisible(WQK\scaLighting, #True)
          \bQKDisplayed = #True
          WQK_adjustForSplitterSize()
        EndIf
        \sDisplayedSubType = "K"
        
      Case "QL"
        If \bQLCreated = #False
          WQL_Form_Load()
        EndIf
        If \bQLDisplayed = #False
          SetGadgetAttribute(WEC\splEditH, #PB_Splitter_SecondGadget, WQL\scaLevelChange)
          setVisible(WQL\scaLevelChange, #True)
          \bQLDisplayed = #True
          WQL_adjustForSplitterSize()
        EndIf
        \sDisplayedSubType = "L"
        
      Case "QM"
        If \bQMCreated = #False
          WQM_Form_Load()
        EndIf
        If \bQMDisplayed = #False
          SetGadgetAttribute(WEC\splEditH, #PB_Splitter_SecondGadget, WQM\scaCtrlSend)
          setVisible(WQM\scaCtrlSend, #True)
          \bQMDisplayed = #True
          WQM_adjustForSplitterSize()
        EndIf
        \sDisplayedSubType = "M"
        
      Case "QP"
        If \bQPCreated = #False
          WQP_Form_Load()
        EndIf
        If \bQPDisplayed = #False
          SetGadgetAttribute(WEC\splEditH, #PB_Splitter_SecondGadget, WQP\scaPlaylist)
          setVisible(WQP\scaPlaylist, #True)
          \bQPDisplayed = #True
          WQP_adjustForSplitterSize()
        EndIf
        \sDisplayedSubType = "P"
        
      Case "QQ"
        If \bQQCreated = #False
          WQQ_Form_Load()
        EndIf
        If \bQQDisplayed = #False
          SetGadgetAttribute(WEC\splEditH, #PB_Splitter_SecondGadget, WQQ\scaCallCue)
          setVisible(WQQ\scaCallCue, #True)
          \bQQDisplayed = #True
          WQQ_adjustForSplitterSize()
        EndIf
        \sDisplayedSubType = "Q"
        
      Case "QR"
        If \bQRCreated = #False
          WQR_Form_Load()
        EndIf
        If \bQRDisplayed = #False
          SetGadgetAttribute(WEC\splEditH, #PB_Splitter_SecondGadget, WQR\scaRunProg)
          setVisible(WQR\scaRunProg, #True)
          \bQRDisplayed = #True
          WQR_adjustForSplitterSize()
        EndIf
        \sDisplayedSubType = "R"
        
      Case "QS"
        If \bQSCreated = #False
          WQS_Form_Load()
        EndIf
        If \bQSDisplayed = #False
          SetGadgetAttribute(WEC\splEditH, #PB_Splitter_SecondGadget, WQS\scaSFRCues)
          setVisible(WQS\scaSFRCues, #True)
          \bQSDisplayed = #True
          WQS_adjustForSplitterSize()
        EndIf
        \sDisplayedSubType = "S"
        
      Case "QT"
        If \bQTCreated = #False
          WQT_Form_Load()
        EndIf
        If \bQTDisplayed = #False
          SetGadgetAttribute(WEC\splEditH, #PB_Splitter_SecondGadget, WQT\scaSetPos)
          setVisible(WQT\scaSetPos, #True)
          \bQTDisplayed = #True
          WQT_adjustForSplitterSize()
        EndIf
        \sDisplayedSubType = "T"
        
      Case "QU"
        If \bQUCreated = #False
          WQU_Form_Load()
        EndIf
        If \bQUDisplayed = #False
          SetGadgetAttribute(WEC\splEditH, #PB_Splitter_SecondGadget, WQU\scaMTCCue)
          setVisible(WQU\scaMTCCue, #True)
          \bQUDisplayed = #True
          WQU_adjustForSplitterSize()
        EndIf
        \sDisplayedSubType = "U"
        
    EndSelect
    
    If bWaitDisplayed
      WMI_clearInfoMsgs()
    EndIf
    
    If (\sDisplayedSubType <> sPrevDisplayedSubType) Or (sType = "Prod")
      WED_Form_Resized(#True)
    EndIf
    gbCallEditUpdateDisplay = #True
    
  EndWith
  
  ; debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure.s debugCueTypes(pCuePtr)
  PROCNAMEC()
  Protected sTypes.s

  With aCue(pCuePtr)
    If \bSubTypeA
      sTypes + "A"
    EndIf
    If \bSubTypeE
      sTypes + "E"
    EndIf
    If \bSubTypeF
      sTypes + "F"
    EndIf
    If \bSubTypeG
      sTypes + "G"
    EndIf
    If \bSubTypeI
      sTypes + "I"
    EndIf
    If \bSubTypeJ
      sTypes + "J"
    EndIf
    If \bSubTypeK
      sTypes + "K"
    EndIf
    If \bSubTypeL
      sTypes + "L"
    EndIf
    If \bSubTypeM
      sTypes + "M"
    EndIf
    If \bSubTypeN
      sTypes + "N"
    EndIf
    If \bSubTypeP
      sTypes + "P"
    EndIf
    If \bSubTypeQ
      sTypes + "Q"
    EndIf
    If \bSubTypeR
      sTypes + "R"
    EndIf
    If \bSubTypeS
      sTypes + "S"
    EndIf
    If \bSubTypeT
      sTypes + "T"
    EndIf
    If \bSubTypeU
      sTypes + "U"
    EndIf
  EndWith
  ProcedureReturn sTypes
EndProcedure

Procedure.s debugCueTypes2(pCuePtr)
  PROCNAMEC()
  Protected sTypes.s
  
  With a2ndCue(pCuePtr)
    If \bSubTypeA
      sTypes + "A"
    EndIf
    If \bSubTypeE
      sTypes + "E"
    EndIf
    If \bSubTypeF
      sTypes + "F"
    EndIf
    If \bSubTypeG
      sTypes + "G"
    EndIf
    If \bSubTypeI
      sTypes + "I"
    EndIf
    If \bSubTypeJ
      sTypes + "J"
    EndIf
    If \bSubTypeK
      sTypes + "K"
    EndIf
    If \bSubTypeL
      sTypes + "L"
    EndIf
    If \bSubTypeM
      sTypes + "M"
    EndIf
    If \bSubTypeN
      sTypes + "N"
    EndIf
    If \bSubTypeP
      sTypes + "P"
    EndIf
    If \bSubTypeQ
      sTypes + "Q"
    EndIf
    If \bSubTypeR
      sTypes + "R"
    EndIf
    If \bSubTypeS
      sTypes + "S"
    EndIf
    If \bSubTypeT
      sTypes + "T"
    EndIf
    If \bSubTypeU
      sTypes + "U"
    EndIf
  EndWith
  ProcedureReturn sTypes
EndProcedure

Procedure.s debugSubTypes(pSubPtr)
  PROCNAMEC()
  Protected sTypes.s

  With aSub(pSubPtr)
    If \bSubTypeA
      sTypes + "A"
    EndIf
    If \bSubTypeE
      sTypes + "E"
    EndIf
    If \bSubTypeF
      sTypes + "F"
    EndIf
    If \bSubTypeG
      sTypes + "G"
    EndIf
    If \bSubTypeI
      sTypes + "I"
    EndIf
    If \bSubTypeJ
      sTypes + "J"
    EndIf
    If \bSubTypeK
      sTypes + "K"
    EndIf
    If \bSubTypeL
      sTypes + "L"
    EndIf
    If \bSubTypeM
      sTypes + "M"
    EndIf
    If \bSubTypeN
      sTypes + "N"
    EndIf
    If \bSubTypeP
      sTypes + "P"
    EndIf
    If \bSubTypeQ
      sTypes + "Q"
    EndIf
    If \bSubTypeR
      sTypes + "R"
    EndIf
    If \bSubTypeS
      sTypes + "S"
    EndIf
    If \bSubTypeT
      sTypes + "T"
    EndIf
    If \bSubTypeU
      sTypes + "U"
    EndIf
  EndWith
  ProcedureReturn sTypes
EndProcedure

Procedure.s debugSubTypes2(pSubPtr)
  PROCNAMEC()
  Protected sTypes.s
  
  With a2ndSub(pSubPtr)
    If \bSubTypeA
      sTypes + "A"
    EndIf
    If \bSubTypeE
      sTypes + "E"
    EndIf
    If \bSubTypeF
      sTypes + "F"
    EndIf
    If \bSubTypeG
      sTypes + "G"
    EndIf
    If \bSubTypeI
      sTypes + "I"
    EndIf
    If \bSubTypeJ
      sTypes + "J"
    EndIf
    If \bSubTypeK
      sTypes + "K"
    EndIf
    If \bSubTypeL
      sTypes + "L"
    EndIf
    If \bSubTypeM
      sTypes + "M"
    EndIf
    If \bSubTypeN
      sTypes + "N"
    EndIf
    If \bSubTypeP
      sTypes + "P"
    EndIf
    If \bSubTypeQ
      sTypes + "Q"
    EndIf
    If \bSubTypeR
      sTypes + "R"
    EndIf
    If \bSubTypeS
      sTypes + "S"
    EndIf
    If \bSubTypeT
      sTypes + "T"
    EndIf
    If \bSubTypeU
      sTypes + "U"
    EndIf
  EndWith
  ProcedureReturn sTypes
EndProcedure

Procedure colorEditorComponent(nEditorComponent, nFirstGadgetNo=-1, nLastGadgetNo=-1)
  ; PROCNAMEC()
  Protected nMyEditorComponent, nBackColor, nTextColor
  Protected n
  Protected nGadgetPropsIndex
  Protected nItemIndex
  Protected nMyFirstGadgetNo, nMyLastGadgetNo
  
  ; debugMsg(sProcName, #SCS_START + ", nEditorComponent=" + nEditorComponent)
  
  nMyEditorComponent = nEditorComponent
  Select nMyEditorComponent
    Case #WEP
      nItemIndex = #SCS_COL_ITEM_PR
    Case #WEC
      nItemIndex = #SCS_COL_ITEM_CP
    Case #WQA
      nItemIndex = #SCS_COL_ITEM_QA
    Case #WQE
      nItemIndex = #SCS_COL_ITEM_QE
    Case #WQF
      nItemIndex = #SCS_COL_ITEM_QF
    Case #WQG
      nItemIndex = #SCS_COL_ITEM_QG
    Case #WQI
      nItemIndex = #SCS_COL_ITEM_QI
    Case #WQJ
      nItemIndex = #SCS_COL_ITEM_QJ
    Case #WQK
      nItemIndex = #SCS_COL_ITEM_QK
    Case #WQL
      nItemIndex = #SCS_COL_ITEM_QL
    Case #WQM
      nItemIndex = #SCS_COL_ITEM_QM
    Case #WQP
      nItemIndex = #SCS_COL_ITEM_QP
    Case #WQQ
      nItemIndex = #SCS_COL_ITEM_QQ
    Case #WQR
      nItemIndex = #SCS_COL_ITEM_QR
    Case #WQS
      nItemIndex = #SCS_COL_ITEM_QS
    Case #WQT
      nItemIndex = #SCS_COL_ITEM_QT
    Case #WQU
      nItemIndex = #SCS_COL_ITEM_QU
    Default
      nItemIndex = #SCS_COL_ITEM_MW
  EndSelect
  
  nBackColor = getBackColorFromColorScheme(nItemIndex)
  nTextColor = getTextColorFromColorScheme(nItemIndex)
  
  If nFirstGadgetNo > 0
    nMyFirstGadgetNo = nFirstGadgetNo
    If nLastGadgetNo > 0
      nMyLastGadgetNo = nLastGadgetNo
    Else
      nMyLastGadgetNo = nMyFirstGadgetNo
    EndIf
  Else
    nFirstGadgetNo = #SCS_GADGET_BASE_NO + 1
    nLastGadgetNo = gnMaxGadgetNo
  EndIf
  
  For n = nFirstGadgetNo To nLastGadgetNo
    If IsGadget(n)
      nGadgetPropsIndex = getGadgetPropsIndex(n)
      With gaGadgetProps(nGadgetPropsIndex)
        ; debugMsg(sProcName, "n=" + n + ", nGadgetPropsIndex=" + Str(nGadgetPropsIndex) + ", \sName=" + \sName)
        If \nEditorComponent = nMyEditorComponent
          ; debugMsg(sProcName, "n=G" + n + ", nGadgetPropsIndex=" + Str(nGadgetPropsIndex) + ", \sName=" + \sName + ", \nSliderNo=" + Str(\nSliderNo) + ", \bAllowEditorColors=" + strB(\bAllowEditorColors))
          If \nSliderNo <= 0
            If \bAllowEditorColors
              Select \nGType
                Case #SCS_GTYPE_CHECKBOX2, #SCS_GTYPE_OPTION2, #SCS_GTYPE_BUTTON2
                  If \bReverseEditorColors
                    setOwnColor(n, #PB_Gadget_BackColor, nTextColor)
                    setOwnColor(n, #PB_Gadget_FrontColor, nBackColor)
                  Else
                    setOwnColor(n, #PB_Gadget_BackColor, nBackColor)
                    setOwnColor(n, #PB_Gadget_FrontColor, nTextColor)
                  EndIf
                Default
                  If \bReverseEditorColors
                    SetGadgetColor(n, #PB_Gadget_BackColor, nTextColor)
                    SetGadgetColor(n, #PB_Gadget_FrontColor, nBackColor)
                  Else
                    SetGadgetColor(n, #PB_Gadget_BackColor, nBackColor)
                    SetGadgetColor(n, #PB_Gadget_FrontColor, nTextColor)
                  EndIf
              EndSelect
            EndIf
          EndIf
        EndIf
      EndIf
    EndWith
  Next n
  
  ; debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure.s buildDefaultSubDescr(pSubPtr=-5)
  PROCNAMECS(pSubPtr)
  Protected nSubPtr
  Protected sDescr.s, sAction.s, nOtherCuePtr, nOtherSubPtr, nLCAction
  Static sDfltDescrA.s, sDfltDescrG.s, sDfltDescrG2.s, sDfltDescrK.s, sDfltDescrL.s, sDfltDescrP.s, sDfltDescrQ.s, sDfltDescrR.s, sDfltDescrT.s, sDfltDescrU.s, sBlackout.s, sFadeToBlack.s
  Static sChangeLevelPan.s, sChangeTempo.s, sChangePitch.s, sChangeFreq.s
  Static bStaticLoaded
  
  ; debugMsg(sProcName, #SCS_START)
  
  If pSubPtr = -5
    nSubPtr = nEditSubPtr
  Else
    nSubPtr = pSubPtr
  EndIf
  
  If bStaticLoaded = #False
    sDfltDescrA = Lang("WQA", "dfltDescr")
    sDfltDescrG = Lang("WQG", "dfltDescr")
    sDfltDescrG2 = Lang("WQG", "dfltDescr2")
    sDfltDescrK = Lang("WQK", "dfltDescr")
    sDfltDescrL = Lang("WQL", "dfltDescr2")
    sDfltDescrP = Lang("WQP", "dfltDescr")
    sDfltDescrQ = Lang("WQQ", "dfltDescr")
    sDfltDescrR = Lang("WQR", "dfltDescr")
    sDfltDescrT = Lang("WQT", "dfltDescr")
    sDfltDescrU = Lang("WQU", "dfltDescr")
    sBlackout = Lang("DMX", "Blackout")
    sFadeToBlack = Lang("DMX", "FadeToBlack")
    sChangeLevelPan = Lang("WQL", "Level/Pan")
    sChangeFreq = Lang("WQL", "Freq")
    sChangeTempo = Lang("WQL", "Tempo")
    sChangePitch = Lang("WQL", "Pitch")
    bStaticLoaded = #True
  EndIf
  
  If nSubPtr >= 0
    With aSub(nSubPtr)
      If \bSubTypeA   ; \bSubTypeA
        If (\nAudCount = 1) And (\nFirstAudIndex >= 0)
          sDescr = aAud(\nFirstAudIndex)\sAudDescr
        ElseIf (\nAudCount > 1)
          sDescr = sDfltDescrA
        EndIf
        ; debugMsg(sProcName, "\bSubTypeA, aSub(" + getSubLabel(nSubPtr) + ")\nAudCount=" + \nAudCount + ", \nFirstAudIndex=" + getAudLabel(\nFirstAudIndex) + ", sDescr=" + sDescr)
        
      ElseIf \bSubTypeF   ; \bSubTypeF
        If \nFirstAudIndex >= 0
          sDescr = aAud(\nFirstAudIndex)\sAudDescr
        EndIf
        ; debugMsg(sProcName, "\bSubTypeF, aSub(" + getSubLabel(nSubPtr) + ")\nFirstAudIndex=" + getAudLabel(\nFirstAudIndex) + ", sDescr=" + sDescr)
        
      ElseIf \bSubTypeG   ; \bSubTypeG
        If \sCueToGoTo
          nOtherCuePtr = getCuePtr(\sCueToGoTo)
          If nOtherCuePtr >= 0
            If \bGoToCueButDoNotStartIt
              sDescr = ReplaceString(sDfltDescrG, "$1", \sCueToGoTo + " (" + aCue(nOtherCuePtr)\sCueDescr + ")")
            Else
              sDescr = ReplaceString(sDfltDescrG2, "$1", \sCueToGoTo + " (" + aCue(nOtherCuePtr)\sCueDescr + ")")
            EndIf
          EndIf
        EndIf
        
      ElseIf \bSubTypeI   ; \bSubTypeI
        sDescr = buildLiveInputDescr(nSubPtr)
        
      ElseIf \bSubTypeJ   ; \bSubTypeJ
        sDescr = WQJ_buildEnableDisableDesc(nSubPtr)
        
      ElseIf \bSubTypeK   ; \bSubTypeK
        If \nLTEntryType = #SCS_LT_ENTRY_TYPE_BLACKOUT
          Select \nLTBLFadeAction
            Case #SCS_DMX_BL_FADE_ACTION_NONE
              sDescr = sBlackout
            Case #SCS_DMX_BL_FADE_ACTION_USER_DEFINED_TIME
              If \nLTBLFadeUserTime > 0
                sDescr = ReplaceString(sFadeToBlack, "$1", timeToString(\nLTBLFadeUserTime))
              Else
                sDescr = sBlackout
              EndIf
            Default ; should be just #SCS_DMX_BL_FADE_ACTION_USE_PROD_RUNTIME_DEFAULT
              sDescr = Trim(ReplaceString(sFadeToBlack, "$1", ""))
          EndSelect
        Else
          sDescr = sDfltDescrK
        EndIf
        
      ElseIf \bSubTypeL   ; \bSubTypeL
        ; If \sLCCue
        ;   nOtherCuePtr = getCuePtr(\sLCCue)
        ;   If nOtherCuePtr >= 0
        ;     sDescr = ReplaceString(sDfltDescrL, "$1", \sLCCue + " (" + aCue(nOtherCuePtr)\sCueDescr + ")")
        ;   EndIf
        ; EndIf
        ; Changed the above 9Dec2020 11.8.3.3au
        If \nLCSubPtr >= 0
          nLCAction = \nLCAction
          Select nLCAction
            Case #SCS_LC_ACTION_FREQ
              sAction = sChangeFreq
            Case #SCS_LC_ACTION_TEMPO
              sAction = sChangeTempo
            Case #SCS_LC_ACTION_PITCH
              sAction = sChangePitch
            Default
              sAction = sChangeLevelPan
          EndSelect
          If sAction
            sDescr = ReplaceString(sDfltDescrL, "$1", LCase(sAction))
            sDescr = ReplaceString(sDescr, "$2", getSubLabel(\nLCSubPtr) + " (" + aSub(\nLCSubPtr)\sSubDescr + ")")
          EndIf
        EndIf
        
      ElseIf \bSubTypeM   ; \bSubTypeM
        ; see WQM_resetSubDescrIfReqd()
        
      ElseIf \bSubTypeP   ; \bSubTypeP
        If (\nAudCount = 1) And (\nFirstAudIndex >= 0)
          sDescr = aAud(\nFirstAudIndex)\sAudDescr
        Else
          sDescr = sDfltDescrP
        EndIf
        
      ElseIf \bSubTypeQ   ; \bSubTypeQ
        Select \nCallCueAction
          Case #SCS_QQ_CALLCUE
            If \sCallCue
              nOtherCuePtr = getCuePtr(\sCallCue)
              If nOtherCuePtr >= 0
                ; sDescr = ReplaceString(sDfltDescrQ, "$1", \sCallCue + " (" + aCue(nOtherCuePtr)\sCueDescr + ")")
                sDescr = aCue(nOtherCuePtr)\sCueDescr
              EndIf
            EndIf
          Case #SCS_QQ_SELHKBANK
            If \nSelHKBank
              sDescr = LangSpace("WQQ", "lblSelHKBank") + \nSelHKBank
            EndIf
        EndSelect
        
      ElseIf \bSubTypeR   ; \bSubTypeR
        sDescr = sDfltDescrR
        
      ElseIf \bSubTypeS   ; \bSubTypeS
        sAction = gaSFRAction(\nSFRAction[0])\sActDescr2
        Select \nSFRAction[0]
          Case #SCS_SFR_ACT_NA, #SCS_SFR_ACT_STOPALL, #SCS_SFR_ACT_FADEALL, #SCS_SFR_ACT_PAUSEALL, #SCS_SFR_ACT_STOPMTC
            sDescr = Trim(sAction)
          Default
            Select \nSFRCueType[0]
              Case #SCS_SFR_CUE_SEL
                nOtherSubPtr = \nSFRSubPtr[0]
                If nOtherSubPtr >= 0
                  sDescr = sAction + " " + aSub(nOtherSubPtr)\sSubDescr
                Else
                  nOtherCuePtr = \nSFRCuePtr[0]
                  If nOtherCuePtr >= 0
                    sDescr = sAction + " " + aCue(nOtherCuePtr)\sCueDescr
                  EndIf
                EndIf
              Default ; "all", "play", "prev".  nb "allexcept" and "playexcept" will not occur in the first position as there are no 'cues listed above'
                sDescr = Trim(sAction) + " " + gaSFRCueType(\nSFRCueType[0])\sCueType2
            EndSelect
        EndSelect
        
      ElseIf \bSubTypeT   ; \bSubTypeT
        If \sSetPosCue
          nOtherCuePtr = getCuePtr(\sSetPosCue)
          If nOtherCuePtr >= 0
            If (\nSetPosAbsRel = #SCS_SETPOS_CUE_MARKER) And (\sSetPosCueMarker)
              sDescr = ReplaceString(sDfltDescrT, "$1", \sSetPosCue + " [" + \sSetPosCueMarker + "] (" + aCue(nOtherCuePtr)\sCueDescr + ")")
            Else
              sDescr = ReplaceString(sDfltDescrT, "$1", \sSetPosCue + " (" + aCue(nOtherCuePtr)\sCueDescr + ")")
            EndIf
          EndIf
        EndIf
        
      ElseIf \bSubTypeU   ; \bSubTypeU
        sDescr = ReplaceString(sDfltDescrU, "$1", decodeMTCTime(\nMTCStartTime))
        If \nMTCType = #SCS_MTC_TYPE_LTC
          sDescr = ReplaceString(sDescr, "MTC", "LTC")
        EndIf
        
      EndIf
      
    EndWith
  EndIf
  
  ProcedureReturn sDescr
  ; debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure setDefaultSubDescr(pSubPtr=-5, bUpdateScreen=#True)
  PROCNAMECS(pSubPtr)
  Protected nSubPtr
  Protected sDescr.s, sAction.s, nOtherCuePtr, nOtherSubPtr
  
  ; debugMsg(sProcName, #SCS_START)
  
  If pSubPtr = -5
    nSubPtr = nEditSubPtr
  Else
    nSubPtr = pSubPtr
  EndIf
  
  If nSubPtr >= 0
    With aSub(nSubPtr)
      ; debugMsg(sProcName, "\bDefaultSubDescrMayBeSet=" + strB(\bDefaultSubDescrMayBeSet))
      If \bDefaultSubDescrMayBeSet
        sDescr = buildDefaultSubDescr(nSubPtr)
        
        If sDescr
          \sSubDescr = sDescr
          If bUpdateScreen
            If \bSubTypeA
              If IsGadget(WQA\txtSubDescr)
                SGT(WQA\txtSubDescr, \sSubDescr)
                setSubDescrToolTip(WQA\txtSubDescr)
              EndIf
            ElseIf \bSubTypeE
              If IsGadget(WQE\txtSubDescr)
                SGT(WQE\txtSubDescr, \sSubDescr)
                setSubDescrToolTip(WQE\txtSubDescr)
              EndIf
            ElseIf \bSubTypeG
              If IsGadget(WQG\txtSubDescr)
                SGT(WQG\txtSubDescr, \sSubDescr)
                setSubDescrToolTip(WQG\txtSubDescr)
              EndIf
            ElseIf \bSubTypeI
              If IsGadget(WQI\txtSubDescr)
                SGT(WQI\txtSubDescr, \sSubDescr)
                setSubDescrToolTip(WQI\txtSubDescr)
              EndIf
            ElseIf \bSubTypeJ
              If IsGadget(WQJ\txtSubDescr)
                SGT(WQJ\txtSubDescr, \sSubDescr)
                setSubDescrToolTip(WQJ\txtSubDescr)
              EndIf
            ElseIf \bSubTypeK
              If IsGadget(WQK\txtSubDescr)
                SGT(WQK\txtSubDescr, \sSubDescr)
                setSubDescrToolTip(WQK\txtSubDescr)
              EndIf
            ElseIf \bSubTypeL
              If IsGadget(WQL\txtSubDescr)
                SGT(WQL\txtSubDescr, \sSubDescr)
                setSubDescrToolTip(WQL\txtSubDescr)
              EndIf
            ElseIf \bSubTypeM
              If IsGadget(WQM\txtSubDescr)
                SGT(WQM\txtSubDescr, \sSubDescr)
                setSubDescrToolTip(WQM\txtSubDescr)
              EndIf
            ElseIf \bSubTypeP
              If IsGadget(WQP\txtSubDescr)
                SGT(WQP\txtSubDescr, \sSubDescr)
                setSubDescrToolTip(WQP\txtSubDescr)
              EndIf
            ElseIf \bSubTypeQ
              If IsGadget(WQQ\txtSubDescr)
                SGT(WQQ\txtSubDescr, \sSubDescr)
                setSubDescrToolTip(WQQ\txtSubDescr)
              EndIf
            ElseIf \bSubTypeR
              If IsGadget(WQR\txtSubDescr)
                SGT(WQR\txtSubDescr, \sSubDescr)
                setSubDescrToolTip(WQR\txtSubDescr)
              EndIf
            ElseIf \bSubTypeS
              If IsGadget(WQS\txtSubDescr)
                SGT(WQS\txtSubDescr, \sSubDescr)
                setSubDescrToolTip(WQS\txtSubDescr)
              EndIf
            ElseIf \bSubTypeT
              If IsGadget(WQT\txtSubDescr)
                SGT(WQT\txtSubDescr, \sSubDescr)
                setSubDescrToolTip(WQT\txtSubDescr)
              EndIf
            ElseIf \bSubTypeU
              If IsGadget(WQU\txtSubDescr)
                SGT(WQU\txtSubDescr, \sSubDescr)
                setSubDescrToolTip(WQU\txtSubDescr)
              EndIf
            EndIf
            ; debugMsg(sProcName, "calling setSubNodeText(" + nSubPtr + ")")
            WED_setSubNodeText(nSubPtr)
          EndIf
        EndIf
        
      EndIf ; EndIf \bDefaultSubDescrMayBeSet
    EndWith
  EndIf
  
  ; debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure setDefaultCueDescr(pCuePtr=-5, pSubPtr=-5)
  PROCNAMECQ(pCuePtr)
  Protected nCuePtr, nSubPtr
  Protected sDescr.s, sAction.s, nOtherCuePtr
  Protected bTrace
  
  debugMsgC(sProcName, #SCS_START)
  
  If gbInApplyLabelChanges = #False
    bTrace = #True
  EndIf
  
  If pCuePtr = -5
    nCuePtr = nEditCuePtr
  Else
    nCuePtr = pCuePtr
  EndIf
  If pSubPtr = -5
    nSubPtr = nEditSubPtr
  Else
    nSubPtr = pSubPtr
  EndIf
  
  debugMsgC(sProcName, "nCuePtr=" + nCuePtr + ", nSubPtr=" + nSubPtr)
  
  If nCuePtr < 0
    ProcedureReturn
  EndIf

  With aCue(nCuePtr)
    debugMsgC(sProcName, "\bDefaultCueDescrMayBeSet=" + strB(\bDefaultCueDescrMayBeSet) + ", current \sCueDescr=" + \sCueDescr)
    If \bDefaultCueDescrMayBeSet
      
      If nSubPtr < 0
        nSubPtr = \nFirstSubIndex
      EndIf
      
      If nSubPtr < 0
        ; no subs - may be a Note cue
        debugMsgC(sProcName, "aCue(" + getCueLabel(nCuePtr) + ")\sCueDescr=" + aCue(nCuePtr)\sCueDescr)
        ProcedureReturn
        
      ElseIf aSub(nSubPtr)\nSubNo = 1
        sDescr = aSub(nSubPtr)\sSubDescr
        
      EndIf
      
      If sDescr
        \sCueDescr = sDescr
        If nCuePtr = nEditCuePtr  ; added this test 7May2018 11.7.1ag because screens could be updated incorrectly if we are not currently editing this cue
          SGT(WEC\txtDescr, sDescr)
          debugMsgC(sProcName, "WEC\txtDescr=" + GGT(WEC\txtDescr))
        EndIf
        WED_setCueNodeText(nCuePtr)
      EndIf
    EndIf ; EndIf \bDefaultCueDescrMayBeSet
  EndWith

  debugMsgC(sProcName, #SCS_END + ", aCue(" + getCueLabel(nCuePtr) + ")\sCueDescr=" + aCue(nCuePtr)\sCueDescr)
  
EndProcedure

Macro macSetSubTypeBooleansForSub(pSub)
  
  pSub\bSubTypeA = #False
  pSub\bSubTypeE = #False
  pSub\bSubTypeF = #False
  pSub\bSubTypeG = #False
  pSub\bSubTypeI = #False
  pSub\bSubTypeJ = #False
  pSub\bSubTypeK = #False
  pSub\bSubTypeL = #False
  pSub\bSubTypeM = #False
  pSub\bSubTypeN = #False
  pSub\bSubTypeP = #False
  pSub\bSubTypeQ = #False
  pSub\bSubTypeR = #False
  pSub\bSubTypeS = #False
  pSub\bSubTypeT = #False
  pSub\bSubTypeU = #False
  pSub\bSubTypeHasAuds = #False
  pSub\bSubTypeHasDevs = #False
  pSub\bSubTypeAorF = #False
  pSub\bSubTypeAorP = #False
  pSub\bSubTypeForP = #False
  pSub\bLiveInput = #False
  
  Select pSub\sSubType
    Case "A"  ; A (video/image/capture sub-cue)
      pSub\bSubTypeA = #True
      pSub\bSubTypeAorF = #True
      pSub\bSubTypeAorP = #True
      pSub\bSubTypeHasAuds = #True
      pSub\bSubTypeHasDevs = #True
      
    Case "E"  ; E (memo sub-cue)
      pSub\bSubTypeE = #True
      
    Case "F"  ; F ( audio file sub-cue)
      pSub\bSubTypeF = #True
      pSub\bSubTypeAorF = #True
      pSub\bSubTypeForP = #True
      pSub\bSubTypeHasAuds = #True
      pSub\bSubTypeHasDevs = #True
      
    Case "G"  ; G ('go to cue' sub-cue)
      pSub\bSubTypeG = #True
      
    Case "I"  ; I (live input sub-cue)
      pSub\bSubTypeI = #True
      pSub\bSubTypeHasAuds = #True
      pSub\bSubTypeHasDevs = #True
      pSub\bLiveInput = #True
      
    Case "J"  ; J ('enable/disable cue' sub-cue)
      pSub\bSubTypeJ = #True
      
    Case "K"  ; K (lighting sub-cue)
      pSub\bSubTypeK = #True
      
    Case "L"  ; L (level change sub-cue)
      pSub\bSubTypeL = #True
      Select pSub\nLCAction
        Case #SCS_LC_ACTION_ABSOLUTE, #SCS_LC_ACTION_RELATIVE
          pSub\bSubTypeHasDevs = #True
      EndSelect
      
    Case "M"  ; M (control send sub-cue)
      pSub\bSubTypeM = #True
      pSub\bSubTypeHasAuds = #True ; Note that if a control send sub-cue has a MIDI file then this will be saved as an 'Aud'
      pSub\bSubTypeHasDevs = #True
      
    Case "N"  ; N (note cue)
      pSub\bSubTypeN = #True
      
    Case "P"  ; P (playlist sub-cue)
      pSub\bSubTypeP = #True
      pSub\bSubTypeAorP = #True
      pSub\bSubTypeForP = #True
      pSub\bSubTypeHasAuds = #True
      pSub\bSubTypeHasDevs = #True
      
    Case "Q"    ; Q (call cue)
      pSub\bSubTypeQ = #True
      
    Case "R"  ; R (run external program sub-cue)
      pSub\bSubTypeR = #True
      
    Case "S"  ; S (SFR (stop/fade-out/loop-release) sub-cue)
      pSub\bSubTypeS = #True
      
    Case "T"  ; T (set position sub-cue)
      pSub\bSubTypeT = #True
      
    Case "U"  ; U (MIDI time code (MTC) and Linear Time Code (LTC) sub-cue)
      pSub\bSubTypeU = #True
      
  EndSelect
  
EndMacro

Macro macSetSubTypeBooleansForCue(pCue, pSub)
  
  pCue\bSubTypeA = #False
  pCue\bSubTypeE = #False
  pCue\bSubTypeF = #False
  pCue\bSubTypeG = #False
  pCue\bSubTypeI = #False
  pCue\bSubTypeJ = #False
  pCue\bSubTypeK = #False
  pCue\bSubTypeL = #False
  pCue\bSubTypeM = #False
  pCue\bSubTypeN = #False
  pCue\bSubTypeP = #False
  pCue\bSubTypeQ = #False
  pCue\bSubTypeR = #False
  pCue\bSubTypeS = #False
  pCue\bSubTypeT = #False
  pCue\bSubTypeU = #False
  pCue\bSubTypeAorF = #False
  pCue\bSubTypeAorP = #False
  pCue\bSubTypeForP = #False
  pCue\bLiveInput = #False
  
  j = pCue\nFirstSubIndex
  While j >= 0
    pCue\bSubTypeA | pSub(j)\bSubTypeA
    pCue\bSubTypeE | pSub(j)\bSubTypeE
    pCue\bSubTypeF | pSub(j)\bSubTypeF
    pCue\bSubTypeG | pSub(j)\bSubTypeG
    pCue\bSubTypeI | pSub(j)\bSubTypeI
    pCue\bSubTypeJ | pSub(j)\bSubTypeJ
    pCue\bSubTypeK | pSub(j)\bSubTypeK
    pCue\bSubTypeL | pSub(j)\bSubTypeL
    pCue\bSubTypeM | pSub(j)\bSubTypeM
    pCue\bSubTypeN | pSub(j)\bSubTypeN
    pCue\bSubTypeP | pSub(j)\bSubTypeP
    pCue\bSubTypeQ | pSub(j)\bSubTypeQ
    pCue\bSubTypeR | pSub(j)\bSubTypeR
    pCue\bSubTypeS | pSub(j)\bSubTypeS
    pCue\bSubTypeT | pSub(j)\bSubTypeT
    pCue\bSubTypeU | pSub(j)\bSubTypeU
    pCue\bSubTypeAorF | pSub(j)\bSubTypeAorF
    pCue\bSubTypeAorP | pSub(j)\bSubTypeAorP
    pCue\bSubTypeForP | pSub(j)\bSubTypeForP
    pCue\bLiveInput | pSub(j)\bLiveInput
    j = pSub(j)\nNextSubIndex
  Wend
  
EndMacro

Macro macSetDerivedCueFields(pCuePtr, pColorsOnly, pProd, pCue, pSub, pAud)
  Protected d, j, k, h
  Protected bCueHotkey, bCueSetStandby, bCueExtAct, bCueCallableCue
  Protected bUseCasForThisCue
  Protected nAudCount
  Protected nDevCount
  Protected nMaxDevCount
  Protected nTotalAudLinkCount
  Protected nItemIndex = -1
  Protected sColorCode.s
  
  ; note: cannot use 'With' inside PB macros
  
  ; debugMsg(sProcName, "pCuePtr=" + pCuePtr + ", pColorsOnly=" + strB(pColorsOnly))
  
  If pCue(pCuePtr)\nActivationMethod & #SCS_ACMETH_HK_BIT
    pCue(pCuePtr)\bHotkey = #True
  Else
    pCue(pCuePtr)\bHotkey = #False
  EndIf
  If pCue(pCuePtr)\nActivationMethod & #SCS_ACMETH_EXT_BIT
    pCue(pCuePtr)\bExtAct = #True
  Else
    pCue(pCuePtr)\bExtAct = #False
  EndIf
  If pCue(pCuePtr)\nActivationMethod = #SCS_ACMETH_CALL_CUE
    pCue(pCuePtr)\bCallableCue = #True
    populateCallableCueParamArray(@pCue(pCuePtr))
  Else
    pCue(pCuePtr)\bCallableCue = #False
  EndIf
  
  Select pProd\nRunMode
    Case #SCS_RUN_MODE_LINEAR
      pCue(pCuePtr)\bNonLinearCue = #False
    Case #SCS_RUN_MODE_NON_LINEAR_OPEN_ON_DEMAND, #SCS_RUN_MODE_NON_LINEAR_PREOPEN_ALL
      pCue(pCuePtr)\bNonLinearCue = #True
    Case #SCS_RUN_MODE_BOTH_OPEN_ON_DEMAND, #SCS_RUN_MODE_BOTH_PREOPEN_ALL
      If Len(Trim(pCue(pCuePtr)\sMidiCue)) > 0
        pCue(pCuePtr)\bNonLinearCue = #True
      Else
        pCue(pCuePtr)\bNonLinearCue = #False
      EndIf
  EndSelect
  
  If (pCue(pCuePtr)\bHotkey And pCue(pCuePtr)\nActivationMethod <> #SCS_ACMETH_HK_STEP) Or (pCue(pCuePtr)\bExtAct) Or (pCue(pCuePtr)\bCallableCue) Or ((pCue(pCuePtr)\bNonLinearCue) And (pProd\bPreOpenNonLinearCues) And pCue(pCuePtr)\nActivationMethod <> #SCS_ACMETH_TIME)
    pCue(pCuePtr)\bKeepOpen = #True
    If pProd\bNoPreLoadVideoHotkeys
      If pCue(pCuePtr)\bSubTypeA
        pCue(pCuePtr)\bKeepOpen = #False
      EndIf
    EndIf
  Else
    pCue(pCuePtr)\bKeepOpen = #False
  EndIf
  
  If (pCue(pCuePtr)\bHotkey) Or (pCue(pCuePtr)\bExtAct)
    sColorCode = "HK"
  ElseIf pCue(pCuePtr)\bCallableCue
    sColorCode = "CC"
  Else
    j = pCue(pCuePtr)\nFirstSubIndex
    If j >= 0
      sColorCode = "Q" + pSub(j)\sSubType
    Else
      sColorCode = "QF"
    EndIf
  EndIf
  
  nItemIndex = encodeColorItemCode(sColorCode)
  If nItemIndex >= 0
    pCue(pCuePtr)\sColorCode = sColorCode
    pCue(pCuePtr)\nBackColor = getBackColorFromColorScheme(nItemIndex)
    pCue(pCuePtr)\nTextColor = getTextColorFromColorScheme(nItemIndex)
  EndIf
  
  If pColorsOnly = #False
    
    bCueHotkey = pCue(pCuePtr)\bHotkey
    bCueExtAct = pCue(pCuePtr)\bExtAct
    bCueCallableCue = pCue(pCuePtr)\bCallableCue
    If (pCue(pCuePtr)\nStandby = #SCS_STANDBY_SET)
      bCueSetStandby = #True
    Else
      bCueSetStandby = #False
    EndIf
    pCue(pCuePtr)\bUsingCuePoints = #False
    
    j = pCue(pCuePtr)\nFirstSubIndex
    While j >= 0
      pSub(j)\bHotkey = bCueHotkey
      pSub(j)\bExtAct = bCueExtAct
      pSub(j)\bCallableCue = bCueCallableCue
      pSub(j)\bSetStandby = bCueSetStandby
      macSetSubTypeBooleansForSub(pSub(j))
      ; NOTE: A lot of this has already been processed in macSetDerivedSubFields(), but we need to review all cases carefully before rationalising the code.
      
      Select UCase(pSub(j)\sSubType)
        Case "I"
          If j = pCue(pCuePtr)\nFirstSubIndex
            pCue(pCuePtr)\bLiveInput = #True
          EndIf
      EndSelect
      
      If pSub(j)\bSubTypeP
        nDevCount = 0
        For d = 0 To grLicInfo\nMaxAudDevPerAud
          If pSub(j)\nPLBassDevice[d] <> 0
            nDevCount + 1
          EndIf
        Next d
        If nDevCount > nMaxDevCount
          nMaxDevCount = nDevCount
        EndIf
      EndIf
      
      If pCue(pCuePtr)\nActivationMethod = #SCS_ACMETH_HK_TOGGLE
        pCue(pCuePtr)\bDoNotResetToggleStateAtCueEnd = #False
        If pSub(j)\bSubTypeK
          pCue(pCuePtr)\bDoNotResetToggleStateAtCueEnd = #True
          If bPrimaryFile
            debugMsg(sProcName, "aCue(" + getCueLabel(pCuePtr) + ")\bDoNotResetToggleStateAtCueEnd=" + strB(pCue(pCuePtr)\bDoNotResetToggleStateAtCueEnd))
          EndIf
        ElseIf pSub(j)\bSubTypeS
          For h = 0 To #SCS_MAX_SFR
            Select pSub(j)\nSFRAction[h]
              Case #SCS_SFR_ACT_FADEOUTHIB, #SCS_SFR_ACT_PAUSEHIB
                pCue(pCuePtr)\bDoNotResetToggleStateAtCueEnd = #True
                If bPrimaryFile
                  debugMsg(sProcName, "aCue(" + getCueLabel(pCuePtr) + ")\bDoNotResetToggleStateAtCueEnd=" + strB(pCue(pCuePtr)\bDoNotResetToggleStateAtCueEnd))
                EndIf
                Break
            EndSelect
          Next h
        EndIf
      EndIf
      
      If pSub(j)\bSubTypeHasAuds
        k = pSub(j)\nFirstAudIndex
        While k >= 0
          pAud(k)\bAudTypeA = pSub(j)\bSubTypeA
          pAud(k)\bAudTypeF = pSub(j)\bSubTypeF
          pAud(k)\bAudTypeI = pSub(j)\bSubTypeI
          pAud(k)\bAudTypeM = pSub(j)\bSubTypeM
          pAud(k)\bAudTypeP = pSub(j)\bSubTypeP
          pAud(k)\bAudTypeAorF = pSub(j)\bSubTypeAorF
          pAud(k)\bAudTypeAorP = pSub(j)\bSubTypeAorP
          pAud(k)\bAudTypeForP = pSub(j)\bSubTypeForP
          pAud(k)\bLiveInput = pSub(j)\bLiveInput
          nAudCount + 1
          nTotalAudLinkCount + pAud(k)\nAudLinkCount
          If (pSub(j)\bSubTypeA) Or (pSub(j)\bSubTypeM)
            nDevCount = 1
            If nDevCount > nMaxDevCount
              nMaxDevCount = nDevCount
            EndIf
          ElseIf (pSub(j)\bSubTypeF) Or (pSub(j)\bSubTypeI)
            If pAud(k)\nFirstSoundingDev >= 0
              nDevCount = pAud(k)\nLastSoundingDev - pAud(k)\nFirstSoundingDev + 1
              If nDevCount > nMaxDevCount
                nMaxDevCount = nDevCount
              EndIf
            EndIf
          EndIf
          
          k = pAud(k)\nNextAudIndex
        Wend
      EndIf
      j = pSub(j)\nNextSubIndex
    Wend
    
    macSetSubTypeBooleansForCue(pCue(pCuePtr), pSub) ; sets fields like pCue(pCuePtr)\bSubTypeA, derived by scanning the associated pSub sub-cues
    
    pCue(pCuePtr)\bNoPreLoad = #False
    If pProd\bNoPreLoadVideoHotkeys
      If pCue(pCuePtr)\bHotkey
        If pCue(pCuePtr)\bSubTypeA
          pCue(pCuePtr)\bNoPreLoad = #True
        EndIf
      EndIf
    EndIf
    
    If nAudCount = 0
      pCue(pCuePtr)\bUseCasForThisCue = #False
    ElseIf gbUseSMS
      pCue(pCuePtr)\bUseCasForThisCue = #False
    ElseIf gbUseBASSMixer = #False
      pCue(pCuePtr)\bUseCasForThisCue = #False
    ElseIf (nAudCount = 1) And (nDevCount = 1) ; And nTotalAudLinkCount = 0
      ; 1 aud, 1 device, no linked auds, so no need to use cas
      pCue(pCuePtr)\bUseCasForThisCue = #False
    Else
      pCue(pCuePtr)\bUseCasForThisCue = #True
    EndIf
    ; debugMsg(sProcName, "nAudCount=" + nAudCount + ", gbUseSMS=" + strB(gbUseSMS) + ", gbUseBASSMixer=" + strB(gbUseBASSMixer) + ", nDevCount=" + nDevCount + ", nMaxDevCount=" + nMaxDevCount)
    ; debugMsg(sProcName, "pCue(" + getCueLabel(pCuePtr) + ")\bUseCasForThisCue=" + strB(pCue(pCuePtr)\bUseCasForThisCue))
    
    ; debugMsg(sProcName, "gbUseSMS=" + strB(gbUseSMS) + ", pCue(" + pCue(pCuePtr)\sCue + ")\bUseCasForThisCue=" + strB(pCue(pCuePtr)\bUseCasForThisCue))
    
  EndIf ; not pColorsOnly
  
EndMacro

Procedure setDerivedCueFields(pCuePtr, pColorsOnly)
  PROCNAMECQ(pCuePtr)
  Protected bPrimaryFile = #True

  macSetDerivedCueFields(pCuePtr, pColorsOnly, grProd, aCue, aSub, aAud)
  setCueSubsAllDisabledFlag(pCuePtr)
  setCueLength(pCuePtr)
  If pColorsOnly = #False
    setGoOkIfExclPlaying(pCuePtr)
  EndIf
  
EndProcedure

Procedure setDerivedCueFields2(pCuePtr, pColorsOnly)
  PROCNAMEC()
  Protected bPrimaryFile = #False
  
  macSetDerivedCueFields(pCuePtr, pColorsOnly, gr2ndProd, a2ndCue, a2ndSub, a2ndAud)
  
EndProcedure

Procedure.s loadOtherInfoTextForSub(pSubPtr)
  PROCNAMECS(pSubPtr)
  Protected sOtherInfoText.s
  Protected n, nMsgCount
  Protected sCueList.s
  Protected sAction.s, nSFRCueCount, nSFRSubCount, nSFRCuePtr, nSFRSubPtr
  Protected nSFRLoopNo
  Protected h, j
  Protected bFound
  Protected sPreRollTime.s
  Protected nOtherCuePtr
  Protected nCueMarkerPosition
  Protected sTempValue.s
  Protected sParamDefault.s
  Protected nTimeOverride
  Static sLoop.s, sCallCue.s, sDfltDescrL.s, sChangeLevelPan.s, sChangeTempo.s, sChangePitch.s, sChangeFreq.s
  Static bStaticLoaded
  
  If bStaticLoaded = #False
    sLoop = " " + Lang("Common", "Loop") + " #$1"
    sCallCue = Lang("WQQ", "dfltDescr")
    sDfltDescrL = Lang("WQL", "dfltDescr2")
    sChangeLevelPan = Lang("WQL", "Level/Pan")
    sChangeFreq = Lang("WQL", "Freq")
    sChangeTempo = Lang("WQL", "Tempo")
    sChangePitch = Lang("WQL", "Pitch")
    bStaticLoaded = #True
  EndIf
  
  nSFRCuePtr = -1
  nSFRSubPtr = -1
  nSFRLoopNo = -1
  
  With aSub(pSubPtr)
    
    If \bSubTypeG   ; \bSubTypeG
      If \bGoToCueButDoNotStartIt
        sOtherInfoText = LangPars("OtherInfo", "G", \sCueToGoTo)
      Else
        sOtherInfoText = LangPars("OtherInfo", "G2", \sCueToGoTo)
      EndIf
      
    ElseIf \bSubTypeI   ; \bSubTypeI
      If \nFirstAudIndex >= 0
        sOtherInfoText = buildLiveInputDescr(pSubPtr)
      EndIf
      
    ElseIf \bSubTypeJ   ; \bSubTypeJ
      sOtherInfoText = WQJ_buildEnableDisableDesc(pSubPtr)
      
    ElseIf \bSubTypeK   ; \bSubTypeK
      ; debugMsg0(sProcName, "aSub(" + getSubLabel(pSubPtr) + ")\sLTDisplayInfo=" + \sLTDisplayInfo)
      sOtherInfoText = \sLTDisplayInfo
      
    ElseIf \bSubTypeL   ; \bSubTypeL
      Select \nLCAction
        Case #SCS_LC_ACTION_FREQ
          sAction = sChangeFreq + ": " + strFTrimmed(\fLCActionValue, 2)
        Case #SCS_LC_ACTION_TEMPO
          sAction = sChangeTempo + ": " + strFTrimmed(\fLCActionValue, 2)
        Case #SCS_LC_ACTION_PITCH
          sTempValue = strFTrimmed(\fLCActionValue, 1)
          If \fLCActionValue > 0
            sAction = sChangePitch + ": +" + sTempValue
          Else
            sAction = sChangePitch + ": " + sTempValue
          EndIf
        Default
          sAction = sChangeLevelPan
      EndSelect
      If sAction
        sOtherInfoText = ReplaceString(sDfltDescrL, "$1", LCase(sAction))
        If \nLCSubPtr >= 0
          sOtherInfoText = ReplaceString(sOtherInfoText, "$2", getSubLabel(\nLCSubPtr) + " (" + aSub(\nLCSubPtr)\sSubDescr + ")")
        Else
          sOtherInfoText = ReplaceString(sOtherInfoText, "$2", "")
        EndIf
      EndIf
      
    ElseIf \bSubTypeM   ; \bSubTypeM
      For n = 0 To #SCS_MAX_CTRL_SEND
        If Trim(\aCtrlSend[n]\sDisplayInfo)
          nMsgCount + 1
          If nMsgCount = 1
            ; first message
            sOtherInfoText = \aCtrlSend[n]\sDisplayInfo
          EndIf
        EndIf
      Next n
      If nMsgCount > 1
        sOtherInfoText + ", ..."
      EndIf
      
    ElseIf \bSubTypeQ   ; \bSubTypeQ
      Select \nCallCueAction
        Case #SCS_QQ_CALLCUE
          If \sCallCue
            nOtherCuePtr = getCuePtr(\sCallCue)
            If nOtherCuePtr >= 0
              sOtherInfoText = ReplaceString(sCallCue, "$1", \sCallCue + " (" + aCue(nOtherCuePtr)\sCueDescr + ")")
            EndIf
          EndIf
        Case #SCS_QQ_SELHKBANK
          If \nSelHKBank > 0
            sOtherInfoText = LangPars("HKeys", "Bank", Str(\nSelHKBank))
          EndIf
      EndSelect
      
    ElseIf \bSubTypeR   ; \bSubTypeR
      sOtherInfoText = GetFilePart(\sRPFileName)
      
    ElseIf \bSubTypeS   ; \bSubTypeS
      sAction = gaSFRAction(\nSFRAction[0])\sActDescr2
      nSFRCueCount = 0
      nSFRSubCount = 0
      sOtherInfoText = Trim(sAction)
      Select \nSFRCueType[0]
        Case #SCS_SFR_CUE_ALL_FIRST To #SCS_SFR_CUE_ALL_LAST
          sOtherInfoText + " " + gaSFRCueType(\nSFRCueType[0])\sCueType2
          
        Case #SCS_SFR_CUE_PLAY_FIRST To #SCS_SFR_CUE_PLAY_LAST
          sOtherInfoText + " " + gaSFRCueType(\nSFRCueType[0])\sCueType2
          
        Case #SCS_SFR_CUE_PREV
          If \nSFRCuePtr[0] = -1
            setCuePtrForSFRPrevCueType(pSubPtr, 0)
          EndIf
          sOtherInfoText + " " + gaSFRCueType(#SCS_SFR_CUE_PREV)\sCueType2 + " (" + \sSFRCue[0] + ")"
          sCueList + " " + \sSFRCue[0]
          
        Default
          For h = 0 To #SCS_MAX_SFR
            Select \nSFRCueType[h]
              Case #SCS_SFR_CUE_SEL
                If \nSFRSubPtr[h] >= 0
                  sOtherInfoText + " " + getSubLabel(\nSFRSubPtr[h])
                  sCueList + " " + \sSFRCue[h]
                  nSFRSubCount + 1
                  nSFRSubPtr = \nSFRSubPtr[h]
                  nSFRLoopNo = \nSFRLoopNo[h]
                  If nSFRLoopNo > 0
                    sOtherInfoText + ReplaceString(sLoop, "$1", Str(nSFRLoopNo))
                  EndIf
                ElseIf \nSFRCuePtr[h] >= 0
                  sOtherInfoText + " " + \sSFRCue[h]
                  sCueList + " " + \sSFRCue[h]
                  nSFRCueCount + 1
                  nSFRCuePtr = \nSFRCuePtr[h]
                EndIf
                
              Case #SCS_SFR_CUE_ALLEXCEPT
                sOtherInfoText + " " + gaSFRCueType(#SCS_SFR_CUE_ALLEXCEPT)\sCueType2 + " " + Trim(sCueList)
                sCueList = ""
                
              Case #SCS_SFR_CUE_PLAYEXCEPT
                sOtherInfoText + " " + gaSFRCueType(#SCS_SFR_CUE_PLAYEXCEPT)\sCueType2 + " " + Trim(sCueList)
                sCueList = ""
            EndSelect
          Next h
      EndSelect
      
      If \nSFRTimeOverride >= 0
        nTimeOverride = \nSFRTimeOverride
        If \sSFRTimeOverride
          If isNumericValueACallCueParamId(\sSFRTimeOverride, pSubPtr)
            sParamDefault = getCallableCueParamDefault(@aCue(\nCueIndex), \sSFRTimeOverride)
            If sParamDefault
              nTimeOverride = stringToTime(sParamDefault)
            EndIf
          EndIf
        EndIf
        ; debugMsg0(sProcName, "\sSFRTimeOverride=" + \sSFRTimeOverride + ", \nSFRTimeOverride=" + \nSFRTimeOverride + ", nTimeOverride=" + nTimeOverride)
        sOtherInfoText + "  (" + LangPars("OtherInfo", "FadeTimeOver", timeToString(nTimeOverride)) + ")"
        
      ElseIf \nSFRAction[0] = #SCS_SFR_ACT_FADEOUT
        If (nSFRCueCount = 1) And (nSFRSubCount = 0)
          CheckSubInRange(nSFRCuePtr, aCue(), "aCue()")
          j = aCue(nSFRCuePtr)\nFirstSubIndex
          bFound = #False
          While (j >= 0) And (bFound = #False)
            If aSub(j)\bSubTypeAorP
              If aSub(j)\nPLFadeOutTime > 0
                sOtherInfoText + "  (PL fade out " + timeToStringBWZ(aSub(j)\nPLFadeOutTime) + ")"
                bFound = #True
              EndIf
            EndIf
            j = aSub(j)\nNextSubIndex
          Wend
          
        ElseIf (nSFRSubCount = 1) And (nSFRCueCount = 0)
          CheckSubInRange(nSFRSubPtr, aSub(), "aSub()")
          j = nSFRSubPtr
          If aSub(j)\bSubTypeAorP
            If aSub(j)\nPLFadeOutTime > 0
              sOtherInfoText + "  (PL fade out " + timeToStringBWZ(aSub(j)\nPLFadeOutTime) + ")"
            EndIf
          EndIf
          
        EndIf
      EndIf
      
      If \bSFRGoNext
        If \nSFRGoNextDelay <= 0
          sOtherInfoText + ", and Go Next"
        Else
          sOtherInfoText + ", and Go Next after " + timeToString(\nSFRGoNextDelay)
        EndIf
      EndIf
      
    ElseIf \bSubTypeT   ; \bSubTypeT
      If \nSetPosAbsRel = #SCS_SETPOS_RELATIVE
        sOtherInfoText = LangPars("WQT", "DfltDescr", \sSetPosCue) + " " + timeToString(\nSetPosTime, 0, #False, #True)
      ElseIf \sSetPosCueMarker        
        For n = 0 To gnMaxCueMarkerInfo
          If (gaCueMarkerInfo(n)\sHostCue = \sSetPosCue) And (gaCueMarkerInfo(n)\nHostSubNo = \nSetPosCueMarkerSubNo) And (gaCueMarkerInfo(n)\sCueMarkerName = \sSetPosCueMarker)
            nCueMarkerPosition = gaCueMarkerInfo(n)\nCueMarkerPosition
            Break ; Cue Marker found at index n
          ElseIf n = gnMaxCueMarkerInfo
            ; We have reached the end of the array without finding our Cue Marker
            debugMsg(sProcName, "ERROR: sSetPosCueMarker " + \sSetPosCueMarker + " does not exist in gaCueMarkerInfo array! gnMaxCueMarkerInfo = " + gnMaxCueMarkerInfo) 
          EndIf
        Next n
        
        sOtherInfoText = LangPars("OtherInfo", "T", \sSetPosCue, \sSetPosCueMarker + " (" + timeToString(nCueMarkerPosition) + ")")
      Else
        sOtherInfoText = LangPars("OtherInfo", "T", \sSetPosCue, timeToString(\nSetPosTime))
      EndIf
      
    ElseIf \bSubTypeU   ; \bSubTypeU
      If \nMTCType = #SCS_MTC_TYPE_LTC
        sOtherInfoText = "LTC "
      Else
        sOtherInfoText = "MTC "
      EndIf
      sOtherInfoText + decodeMTCTime(\nMTCStartTime)
      If \nMTCFrameRate <> #SCS_MTC_FR_NOT_SET
        sOtherInfoText + " @" + decodeMTCFrameRateL(\nMTCFrameRate)
        If \nMTCPreRoll > 0
          sPreRollTime = RTrim(RTrim(RTrim(timeToStringT(\nMTCPreRoll), "0"), "."), ",")
          sOtherInfoText + ", " + sPreRollTime + " " + grText\sTextPreRoll
        EndIf
      EndIf
      
    EndIf
    
    Select aCue(\nCueIndex)\nProdTimerAction
      Case #SCS_PTA_NO_ACTION
        ; no action
      Case #SCS_PTA_START_S, #SCS_PTA_PAUSE_S, #SCS_PTA_RESUME_S
        If \nPrevSubIndex = -1
          ; first sub for this cue
          sOtherInfoText + "  " + decodeProdTimerActionAbbr(aCue(\nCueIndex)\nProdTimerAction)
        EndIf
      CompilerIf #c_prod_timer_extra_actions
        Case #SCS_PTA_SHOW_TIMER, #SCS_PTA_HIDE_TIMER, #SCS_PTA_SHOW_CLOCK, #SCS_PTA_HIDE_CLOCK
          If \nPrevSubIndex = -1
            ; first sub for this cue
            sOtherInfoText + "  " + decodeProdTimerActionAbbr(aCue(\nCueIndex)\nProdTimerAction)
          EndIf
      CompilerEndIf
      Case #SCS_PTA_START_E, #SCS_PTA_PAUSE_E, #SCS_PTA_RESUME_E
        If \nNextSubIndex = -1
          ; last sub for this cue
          sOtherInfoText + "  " + decodeProdTimerActionAbbr(aCue(\nCueIndex)\nProdTimerAction)
        EndIf
    EndSelect
    ; debugMsg(sProcName, "aCue(" + getCueLabel(\nCueIndex) + ")\nProdTimerAction=" + decodeProdTimerAction(aCue(\nCueIndex)\nProdTimerAction) + ", sOtherInfoText=" + Trim(sOtherInfoText))
    
  EndWith
  
  ProcedureReturn Trim(sOtherInfoText)
  
EndProcedure

Procedure validateAll()
  PROCNAMEC()
  Protected bValidationResult
  
  ; debugMsg(sProcName, #SCS_START)
  
  bValidationResult = #True

  If grCED\bProdDisplayed And bValidationResult
    ; debugMsg(sProcName, "calling WEP_formValidation")
    bValidationResult = WEP_formValidation()
  EndIf

  If grCED\bCueDisplayed And bValidationResult
    ; debugMsg(sProcName, "calling WEC_formValidation")
    bValidationResult = WEC_formValidation()
  EndIf
  
  If grCED\bQADisplayed And bValidationResult
    ; debugMsg(sProcName, "calling WQA_formValidation")
    bValidationResult = WQA_formValidation()
  EndIf
  
  If grCED\bQFDisplayed And bValidationResult
    ; debugMsg(sProcName, "calling WQF_formValidation")
    bValidationResult = WQF_formValidation()
  EndIf
  
  If grCED\bQGDisplayed And bValidationResult
    ; debugMsg(sProcName, "calling WQG_formValidation")
    bValidationResult = WQG_formValidation()
  EndIf
  
  If grCED\bQIDisplayed And bValidationResult
    ; debugMsg(sProcName, "calling WQI_formValidation")
    bValidationResult = WQI_formValidation()
  EndIf
  
  If grCED\bQJDisplayed And bValidationResult
    ; debugMsg(sProcName, "calling WQJ_formValidation")
    bValidationResult = WQJ_formValidation()
  EndIf

  If grCED\bQKDisplayed And bValidationResult
    ; debugMsg(sProcName, "calling WQK_formValidation")
    bValidationResult = WQK_formValidation()
  EndIf

  If grCED\bQLDisplayed And bValidationResult
    ; debugMsg(sProcName, "calling WQL_formValidation")
    bValidationResult = WQL_formValidation()
  EndIf

  If grCED\bQMDisplayed And bValidationResult
    ; debugMsg(sProcName, "calling WQM_formValidation")
    bValidationResult = WQM_formValidation()
  EndIf

  If grCED\bQPDisplayed And bValidationResult
    ; debugMsg(sProcName, "calling WQP_formValidation")
    bValidationResult = WQP_formValidation()
  EndIf
  
  If grCED\bQQDisplayed And bValidationResult
    ; debugMsg(sProcName, "calling WQQ_formValidation")
    bValidationResult = WQQ_formValidation()
  EndIf
  
  If grCED\bQRDisplayed And bValidationResult
    ; debugMsg(sProcName, "calling WQR_formValidation")
    bValidationResult = WQR_formValidation()
  EndIf
  
  If grCED\bQSDisplayed And bValidationResult
    ; debugMsg(sProcName, "calling WQS_formValidation")
    bValidationResult = WQS_formValidation()
  EndIf
  
  If grCED\bQTDisplayed And bValidationResult
    ; debugMsg(sProcName, "calling WQT_formValidation")
    bValidationResult = WQT_formValidation()
  EndIf
  
  If grCED\bQUDisplayed And bValidationResult
    ; debugMsg(sProcName, "calling WQU_formValidation")
    bValidationResult = WQU_formValidation()
  EndIf
  
  debugMsg(sProcName, #SCS_END + " returning " + strB(bValidationResult))
  ProcedureReturn bValidationResult
  
EndProcedure

Procedure loadCueTypeText()
  
  With grText
    \sTextCueTypeA = Lang("CueType", "A")
    \sTextCueTypeE = Lang("CueType", "E")
    \sTextCueTypeF = Lang("CueType", "F")
    \sTextCueTypeG = Lang("CueType", "G")
    \sTextCueTypeI = Lang("CueType", "I")
    \sTextCueTypeJ = Lang("CueType", "J")
    \sTextCueTypeK = Lang("CueType", "K")
    \sTextCueTypeL = Lang("CueType", "L")
    \sTextCueTypeM = Lang("CueType", "M")
    \sTextCueTypeN = Lang("CueType", "N")
    \sTextCueTypeP = Lang("CueType", "P")
    \sTextCueTypeQ = Lang("CueType", "Q")
    \sTextCueTypeR = Lang("CueType", "R")
    \sTextCueTypeS = Lang("CueType", "S")
    \sTextCueTypeT = Lang("CueType", "T")
    \sTextCueTypeU = Lang("CueType", "U")
    \sTextEnd = Lang("CueType", "End")
  EndWith
  
EndProcedure

Procedure changeCueLabel(pOldCue.s, pNewCue.s, bCallChangeSubs, pOrigCue.s="", sUndoDescr.s="")
  PROCNAMEC()
  Protected i, j, k, n, bRepeatForThisCue
  Protected u
  
  ; debugMsg(sProcName, #SCS_START + ", pOldCue=" + pOldCue + ", pNewCue=" + pNewCue + ", bCallChangeSubs=" + strB(bCallChangeSubs) + ", pOrigCue=" + pOrigCue + ", sUndoDescr=" + #DQUOTE$ + sUndoDescr + #DQUOTE$)
  
  If Trim(pOldCue)
    
    For i = 1 To gnLastCue
      
      With aCue(i)
        ; debugMsg(sProcName, "aCue(" + i + ")\sAutoActCue=" + \sAutoActCue)
        If UCase(\sAutoActCue) = UCase(pOldCue)
          If bCallChangeSubs
            u = preChangeCueS(pOrigCue, sUndoDescr, i, #SCS_UNDO_ACTION_CHANGE, #SCS_UNDO_FLAG_SET_CUE_NODE_TEXT | #SCS_UNDO_FLAG_REDO_TREE)
            \sAutoActCue = pNewCue
            postChangeCueS(u, \sAutoActCue, i)
          Else
            \sAutoActCue = pNewCue
          EndIf
          \bCallLoadGridRow = #True
        EndIf
      EndWith
      
      j = aCue(i)\nFirstSubIndex
      While j >= 0
        
        With aSub(j)
          
          If UCase(\sCue) = UCase(pOldCue)
            If bCallChangeSubs
              u = preChangeSubS(pOrigCue, sUndoDescr, j, #SCS_UNDO_ACTION_CHANGE, #SCS_UNDO_FLAG_SET_SUB_NODE_TEXT | #SCS_UNDO_FLAG_REDO_TREE)
              ; debugMsg(sProcName, "changing aSub(" + j + ")\sCue from " + \sCue + " to " + pNewCue)
              \sCue = pNewCue
              postChangeSubS(u, \sCue, j)
            Else
              \sCue = pNewCue
            EndIf
          EndIf
          
          ; Added 17Apr2024 11.10.2bz
          If \bSubTypeF   ; \bSubTypeF (see also code for \bSubTypeHasAuds)
            k = \nFirstAudIndex
            If k >= 0
              If UCase(aAud(k)\sVSTPluginSameAsCue) = UCase(pOldCue)
                If bCallChangeSubs
                  u = preChangeAudS(pOrigCue, sUndoDescr, k, #SCS_UNDO_ACTION_CHANGE)
                  aAud(k)\sVSTPluginSameAsCue = pNewCue
                  postChangeAudS(u, aAud(k)\sVSTPluginSameAsCue, k)
                Else
                  aAud(k)\sVSTPluginSameAsCue = pNewCue
                EndIf
              EndIf
            EndIf
          EndIf
          ; End added 17Apr2024 11.10.2bz
          
          If \bSubTypeG   ; \bSubTypeG
            If UCase(\sCueToGoTo) = UCase(pOldCue)
              If bCallChangeSubs
                u = preChangeSubS(pOrigCue, sUndoDescr, j, #SCS_UNDO_ACTION_CHANGE, #SCS_UNDO_FLAG_SET_SUB_NODE_TEXT | #SCS_UNDO_FLAG_REDO_TREE)
                \sCueToGoTo = pNewCue
                setDefaultSubDescr(j)
                postChangeSubS(u, \sCueToGoTo, j)
              Else
                \sCueToGoTo = pNewCue
              EndIf
            EndIf
          EndIf
          
          If \bSubTypeJ   ; \bSubTypeJ
            For n = 0 To #SCS_MAX_ENABLE_DISABLE
              If UCase(\aEnableDisable[n]\sFirstCue) = UCase(pOldCue)
                If bCallChangeSubs
                  u = preChangeSubS(pOrigCue, sUndoDescr, j, #SCS_UNDO_ACTION_CHANGE, #SCS_UNDO_FLAG_SET_SUB_NODE_TEXT | #SCS_UNDO_FLAG_REDO_TREE, n)
                  \aEnableDisable[n]\sFirstCue = pNewCue
                  setDefaultSubDescr(j)
                  postChangeSubS(u, \aEnableDisable[n]\sFirstCue, j, n)
                Else
                  \aEnableDisable[n]\sFirstCue = pNewCue
                EndIf
              EndIf
              If UCase(\aEnableDisable[n]\sLastCue) = UCase(pOldCue)
                If bCallChangeSubs
                  u = preChangeSubS(pOrigCue, sUndoDescr, j, #SCS_UNDO_ACTION_CHANGE, #SCS_UNDO_FLAG_SET_SUB_NODE_TEXT | #SCS_UNDO_FLAG_REDO_TREE, n)
                  \aEnableDisable[n]\sLastCue = pNewCue
                  setDefaultSubDescr(j)
                  postChangeSubS(u, \aEnableDisable[n]\sLastCue, j, n)
                Else
                  \aEnableDisable[n]\sLastCue = pNewCue
                EndIf
              EndIf
            Next n
          EndIf
          
          If \bSubTypeL   ; \bSubTypeL
            ; debugMsg(sProcName, "\sLCCue=" + \sLCCue + ", pOldCue=" + pOldCue)
            If UCase(\sLCCue) = UCase(pOldCue)
              If bCallChangeSubs
                u = preChangeSubS(pOrigCue, sUndoDescr, j, #SCS_UNDO_ACTION_CHANGE, #SCS_UNDO_FLAG_SET_SUB_NODE_TEXT | #SCS_UNDO_FLAG_REDO_TREE)
                \sLCCue = pNewCue
                ; debugMsg(sProcName, "calling setDefaultSubDescr(" + getSubLabel(j) + ")")
                setDefaultSubDescr(j)
                postChangeSubS(u, \sLCCue, j)
              Else
                \sLCCue = pNewCue
              EndIf
            EndIf
            ; debugMsg(sProcName, "aSub(" + getSubLabel(j) + ")\bSubTypeL done, \sSubDescr=" + \sSubDescr)
          EndIf
          
          If \bSubTypeQ   ; \bSubTypeQ
            If UCase(\sCallCue) = UCase(pOldCue)
              If bCallChangeSubs
                u = preChangeSubS(pOrigCue, sUndoDescr, j, #SCS_UNDO_ACTION_CHANGE, #SCS_UNDO_FLAG_SET_SUB_NODE_TEXT | #SCS_UNDO_FLAG_REDO_TREE)
                \sCallCue = pNewCue
                setDefaultSubDescr(j)
                postChangeSubS(u, \sCallCue, j)
              Else
                \sCallCue = pNewCue
              EndIf
            EndIf
          EndIf
          
          If \bSubTypeS   ; \bSubTypeS
            For n = 0 To #SCS_MAX_SFR
              If UCase(\sSFRCue[n]) = UCase(pOldCue)
                If bCallChangeSubs
                  u = preChangeSubS(pOrigCue, sUndoDescr, j, #SCS_UNDO_ACTION_CHANGE, #SCS_UNDO_FLAG_SET_SUB_NODE_TEXT | #SCS_UNDO_FLAG_REDO_TREE, n)
                  \sSFRCue[n] = pNewCue
                  setDefaultSubDescr(j)
                  postChangeSubS(u, \sSFRCue[n], j, n)
                Else
                  \sSFRCue[n] = pNewCue
                EndIf
              EndIf
            Next n
          EndIf
          
          If \bSubTypeT   ; \bSubTypeT
            If UCase(\sSetPosCue) = UCase(pOldCue)
              If bCallChangeSubs
                u = preChangeSubS(pOrigCue, sUndoDescr, j, #SCS_UNDO_ACTION_CHANGE, #SCS_UNDO_FLAG_SET_SUB_NODE_TEXT | #SCS_UNDO_FLAG_REDO_TREE)
                \sSetPosCue = pNewCue
                setDefaultSubDescr(j)
                postChangeSubS(u, \sSetPosCue, j)
              Else
                \sSetPosCue = pNewCue
              EndIf
            EndIf
          EndIf
          
          ; debugMsg(sProcName, "aSub(" + j + ")\bSubTypeHasAuds=" + strB(\bSubTypeHasAuds) + ", \nFirstAudIndex=" + \nFirstAudIndex)
          If \bSubTypeHasAuds   ; \bSubTypeHasAuds
            k = \nFirstAudIndex
            While k >= 0
              ; debugMsg(sProcName, "aAud(" + k + ")\sCue=" + aAud(k)\sCue + ", pOldCue=" + pOldCue + ", pNewCue=" + pNewCue)
              If UCase(aAud(k)\sCue) = UCase(pOldCue)
                If bCallChangeSubs
                  u = preChangeAudS(aAud(k)\sCue, sUndoDescr, k)
                  aAud(k)\sCue = pNewCue
                  postChangeAudS(u, aAud(k)\sCue, k)
                Else
                  aAud(k)\sCue = pNewCue
                EndIf
                ; debugMsg(sProcName, "aAud(" + k + ")\sCue=" + aAud(k)\sCue + ", getAudLabel(k)=" + getAudLabel(k))
              EndIf
              k = aAud(k)\nNextAudIndex
            Wend
          EndIf
          
          j = \nNextSubIndex
          
        EndWith
      Wend
      setLabels(i)
      If aCue(i)\bDefaultCueDescrMayBeSet
        setDefaultCueDescr(i, aCue(i)\nFirstSubIndex)
      EndIf
    Next i
  EndIf
  
  ; debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure checkDelCueRI(pCuePtr, sMsgStart.s, nAction=0, nCalledFromWindow=#WED)
  PROCNAMECQ(pCuePtr)
  Protected i, j, n
  Protected sThisCue.s, sRICue.s, sTmpCue.s, sMsg.s, sCheckCue.s
  Protected bThisCueEnabled
  Protected bCheckThisCue, bCheckThisSub
  Protected nFirstCueToDelete=-1, nLastCueToDelete=-1 ; used for #WMC delete action
  Protected bCheckMore, nPrevCuePtr, bAllSubsDisabled
  
  ; nAction:
  ;  0 = Check if Delete allowed
  ;  1 = Check if Disable allowed
  ;  2 = Check if Enable allowed
  
  ; NB 'RI' in 'checkDelCueRI' stands for Referential Integrity - a term we used years ago in database handling.
  ; Wikipedia: Referential integrity is a property of data stating that all its references are valid. In the context of relational databases,
  ; it requires that if a value of one attribute of a relation references a value of another attribute, then the referenced value must exist.

  ; debugMsg(sProcName, #SCS_START + ", sMsgStart=" + sMsgStart + ", nAction=" + nAction + ", nCalledFromWindow=" + decodeWindow(nCalledFromWindow))
  
  sThisCue = aCue(pCuePtr)\sCue
  
  If nCalledFromWindow = #WMC
    If IsGadget(WMC\cboFirstCue)
      nFirstCueToDelete = getCurrentItemData(WMC\cboFirstCue, -1)
      nLastCueToDelete = getCurrentItemData(WMC\cboLastCue, -1)
    EndIf
  EndIf

  Select nAction
    Case 0, 1
      ;  0 = Check if Delete allowed
      ;  1 = Check if Disable allowed
      For i = 1 To gnLastCue
        If i <> pCuePtr
          bCheckThisCue = #True
          If nCalledFromWindow = #WMC ; #WMC = fmMultiCueCopyEtc
            If (i >= nFirstCueToDelete) And (i <= nLastCueToDelete)
              bCheckThisCue = #False
            EndIf
          EndIf
          ; debugMsg(sProcName, "i=" + getCueLabel(i) + ", bCheckThisCue=" + strB(bCheckThisCue))
          If bCheckThisCue
            With aCue(i)
              bCheckMore = #False
              sCheckCue = ""
              ; debugMsg(sProcName, "aCue(" + getCueLabel(i) + ")\nActivationMethod=" + decodeActivationMethod(\nActivationMethod) + ", \nAutoActCueSelType=" + \nAutoActCueSelType)
              If \nActivationMethod = #SCS_ACMETH_AUTO Or \nActivationMethod = #SCS_ACMETH_AUTO_PLUS_CONF
                Select \nAutoActCueSelType
                  Case #SCS_ACCUESEL_DEFAULT
                    sCheckCue = \sAutoActCue
                    bCheckMore = #True
                  Case #SCS_ACCUESEL_PREV
                    CompilerIf 1=2 ; Blocked out 16Jan2025 11.10.6-b05 so that deleting a cue is accepted if auto-start just refers to 'previous cue' rather than to a specific cue number (reported by Scott Siegwald)
                      setCuePtrForAutoStartPrevCueType(i) ; Force re-population of aCue(i)\sAutoActCue
                      sCheckCue = \sAutoActCue
                      bCheckMore = #True
                    CompilerEndIf
                EndSelect
              ElseIf \nActivationMethod = #SCS_ACMETH_OCM ; OCM test added 7May2024 11.10.2cn
                ; debugMsg0(sProcName, "aCue(" + getCueLabel(i) + ")\nAutoActCuePtr=" + getCueLabel(\nAutoActCuePtr) + ", \nAutoActCueMarkerId=" + \nAutoActCueMarkerId)
                sCheckCue = \sAutoActCue
                bCheckMore = #True
              EndIf
              If bCheckMore
                ; debugMsg(sProcName, "sCheckCue=" + sCheckCue)
                If sCheckCue = sThisCue
                  If nAction = 0
                    sRICue = \sCue
                    ; debugMsg(sProcName, "sRICue=" + sRICue)
                  Else ; nAction = 1
                    If nCalledFromWindow = #WBE ; #WBE = fmBulkEdit
                      bThisCueEnabled = WBE_getNewEnabledForCue(\sCue)
                    Else
                      bThisCueEnabled = \bCueEnabled
                    EndIf
                    If bThisCueEnabled
                      ; If all subs disabled then treat the cue as disabled
                      bAllSubsDisabled = #True
                      j = \nFirstSubIndex
                      While j >= 0
                        If aSub(j)\bSubEnabled
                          bAllSubsDisabled = #False
                          Break
                        EndIf
                        j = aSub(j)\nNextSubIndex
                      Wend
                      If bAllSubsDisabled
                        bThisCueEnabled = #False
                      EndIf
                    EndIf
                    If bThisCueEnabled
                      sRICue = \sCue
                      ; debugMsg(sProcName, "sRICue=" + sRICue)
                    EndIf
                  EndIf
                EndIf
              EndIf
            EndWith
          EndIf
          If sRICue
            Break
          EndIf
        EndIf
      Next i
      
      If Len(sRICue) = 0
        For j = 1 To gnLastSub
          If aSub(j)\bExists And (aSub(j)\bSubEnabled Or nAction = 0) ; "And (aSub(j)\bSubEnabled Or nAction = 0)" added 21May2019 11.8.1rc5 following bug report from Dave Korman
            bCheckThisSub = #True
            With aSub(j)
              If \nCueIndex <> pCuePtr
                If nCalledFromWindow = #WMC ; #WMC = fmMultiCueCopyEtc
                  If (\nCueIndex >= nFirstCueToDelete) And (\nCueIndex <= nLastCueToDelete)
                    bCheckThisSub = #False
                  EndIf
                EndIf
                If bCheckThisSub
                  If nCalledFromWindow = #WBE ; #WBE = fmBulkEdit
                    bThisCueEnabled = WBE_getNewEnabledForCue(\sCue)
                  Else
                    bThisCueEnabled = aCue(\nCueIndex)\bCueEnabled
                  EndIf
                  
                  If \bSubTypeQ   ; \bSubTypeQ
                    If \sCallCue = sThisCue
                      If (nAction = 0) Or (nAction = 1 And bThisCueEnabled)
                        sRICue = \sCue
                        ; debugMsg(sProcName, "sRICue=" + sRICue)
                      EndIf
                    EndIf
                  EndIf
                  
                  If \bSubTypeG   ; \bSubTypeG
                    If \sCueToGoTo = sThisCue
                      If (nAction = 0) Or (nAction = 1 And bThisCueEnabled)
                        sRICue = \sCue
                      EndIf
                    EndIf
                    
                  ElseIf \bSubTypeJ   ; \bSubTypeJ
                    For n = 0 To #SCS_MAX_ENABLE_DISABLE
                      If \aEnableDisable[n]\sFirstCue = sThisCue
                        If (nAction = 0) Or (nAction = 1 And bThisCueEnabled)
                          sRICue = \sCue
                        EndIf
                      ElseIf \aEnableDisable[n]\sLastCue = sThisCue
                        If (nAction = 0) Or (nAction = 1 And bThisCueEnabled)
                          sRICue = \sCue
                        EndIf
                      EndIf
                    Next n
                    
                  ElseIf \bSubTypeL   ; \bSubTypeL
                    If \sLCCue = sThisCue
                      If (nAction = 0) Or (nAction = 1 And bThisCueEnabled)
                        sRICue = \sCue
                      EndIf
                    EndIf
                    
                  ElseIf \bSubTypeS   ; \bSubTypeS
                    For n = 0 To #SCS_MAX_SFR
                      If \nSFRCueType[n] = #SCS_SFR_CUE_SEL Or \nSFRCueType[n] = #SCS_SFR_CUE_PREV ; Added #SCS_SFR_CUE_PREV test 2Feb2024 11.10.2ae - note that \sSFRCue[n] will have been auto-populated for #SCS_SFR_CUE_PREV
                        If \sSFRCue[n] = sThisCue
                          If (nAction = 0) Or (nAction = 1 And bThisCueEnabled)
                            sRICue = \sCue
                          EndIf
                        EndIf
                      EndIf
                    Next n
                    
                  ElseIf \bSubTypeT   ; \bSubTypeT
                    If \sSetPosCue = sThisCue
                      If (nAction = 0) Or (nAction = 1 And bThisCueEnabled)
                        sRICue = \sCue
                      EndIf
                    EndIf
                    
                  EndIf
                EndIf
              EndWith
              
              If sRICue
                Break
              EndIf
            EndIf
            
          EndIf
        Next j
      EndIf
      
    Case 2
      ;{  2 = Check if Enable Cue allowed
      
  EndSelect
  
  ; debugMsg0(sProcName, "sRICue=" + sRICue + ", sThisCue=" + sThisCue + ", nAction=" + nAction)
  If (sRICue) And (sRICue <> sThisCue)
    If nAction = 0
      sMsg = sMsgStart + " " + LangPars("Errors", "ReferredToByCue", sRICue)
    ElseIf nAction = 1
      sMsg = sMsgStart + " " + LangPars("Errors", "ReferredToByCueEn", sRICue)
    ElseIf nAction = 2
      sMsg = sMsgStart + " " + LangPars("Errors", "RefersToCueDi", sRICue)
    EndIf
    debugMsg(sProcName, sMsg)
    scsMessageRequester(grText\sTextEditor, sMsg, #MB_ICONEXCLAMATION | #PB_MessageRequester_Ok)
    ; debugMsg(sProcName, #SCS_END + ", returning #False")
    ProcedureReturn #False
  Else
    ; debugMsg(sProcName, #SCS_END + ", returning #True")
    ProcedureReturn #True
  EndIf

EndProcedure

Procedure checkDelSubRI(pSubPtr, sMsgStart.s, nAction=0)
  PROCNAMECS(pSubPtr)
  Protected i, j, j2, k, h, n
  Protected sCue.s, nSubNo, nCuePtr, nAudPtr, nThisCueMarkerId
  Protected sSubLabel.s, sRISubLabel.s, sRICueLabel.s
  Protected sMsg.s
  Protected bThisCueEnabled, bThisSubEnabled
  Protected bAllOtherSubsDisabled

  ; nAction:
  ;  0 = Check if Delete allowed
  ;  1 = Check if Disable allowed
  ;  2 = Check if Enable allowed
  
  ; NB 'RI' in 'checkDelSubRI' stands for Referential Integrity - a term we used years ago in database handling.
  ; Wikipedia: Referential integrity is a property of data stating that all its references are valid. In the context of relational databases,
  ; it requires that if a value of one attribute of a relation references a value of another attribute, then the referenced value must exist.
  
  debugMsg(sProcName, #SCS_START + ", sMsgStart=" + sMsgStart + ", nAction=" + nAction)
  
  nCuePtr = aSub(pSubPtr)\nCueIndex
  sCue = aSub(pSubPtr)\sCue
  nSubNo = aSub(pSubPtr)\nSubNo
  sSubLabel = aSub(pSubPtr)\sSubLabel
  
  ; Added 2Feb2024 11.10.2ae
  If nAction = 1
    ; If 'check if disable allowed' then check if all other subs in this cue (if any others) are currently disabled, because if so then that means the whole cue would be disabled
    bAllOtherSubsDisabled = #True
    j = aCue(nCuePtr)\nFirstSubIndex
    While j >= 0
      If j <> pSubPtr
        If aSub(j)\bSubEnabled
          bAllOtherSubsDisabled = #False
          Break
        EndIf
      EndIf
      j = aSub(j)\nNextSubIndex
    Wend
    If bAllOtherSubsDisabled
      If checkDelCueRI(nCuePtr, sMsgStart, nAction) = #False
        ProcedureReturn #False
      EndIf
    EndIf
  EndIf
  ; End added 2Feb2024 11.10.2ae
  
  Select nAction
    Case 0, 1
      ;  0 = Check if Delete allowed
      ;  1 = Check if Disable allowed
      If aSub(pSubPtr)\bSubTypeAorF
        nAudPtr = aSub(pSubPtr)\nFirstAudIndex
        While nAudPtr >= 0
          If aAud(nAudPtr)\nMaxCueMarker >= 0
            ; this sub contains at least one cue marker, so check that no cues are set to auto-start on a cue marker in this aud
            For i = 1 To gnLastCue
              If i <> nCuePtr
                With aCue(i)
                  If \bCueEnabled And \nActivationMethod = #SCS_ACMETH_OCM
                    nThisCueMarkerId = \nAutoActCueMarkerId
                    For n = 0 To aAud(nAudPtr)\nMaxCueMarker
                      If aAud(nAudPtr)\aCueMarker(n)\nCueMarkerId = nThisCueMarkerId
                        sRICueLabel = \sCue
                        Break 3 ; Break n, i, nAudPtr
                      EndIf
                    Next n
                  EndIf ; EndIf \bCueEnabled And \nActivationMethod = #SCS_ACMETH_OCM
                EndWith
              EndIf ; EndIf i <> nCuePtr
            Next i
          EndIf ; EndIf aAud(nAudPtr)\nMaxCueMarker >= 0
          
          ; Added 16Apr2024 11.10.2bz
          If aAud(nAudPtr)\sVSTPluginName
            For i = 1 To gnLastCue
              j = aCue(i)\nFirstSubIndex
              While j >= 0
                If j <> pSubPtr
                  If aSub(j)\bSubTypeF
                    k = aSub(j)\nFirstAudIndex
                    If k >= 0
                      If aAud(k)\sVSTPluginSameAsCue = sCue And aAud(k)\nVSTPluginSameAsSubNo = nSubNo
                        sRISubLabel = aSub(j)\sSubLabel
                        Break 3 ; Break j, i, nAudPtr 
                      EndIf
                    EndIf
                  EndIf
                EndIf
                j = aSub(j)\nNextSubIndex
              Wend
            Next i
          EndIf
          ; End dded 16Apr2024 11.10.2bz
          
          nAudPtr = aAud(nAudPtr)\nNextAudIndex
        Wend
      EndIf ; EndIf aSub(pSubPtr)\bSubTypeAorF
      
      If Len(sRICueLabel) = 0 And Len(sRISubLabel) = 0
        For j = 1 To gnLastSub
          If aSub(j)\bExists
            If j <> pSubPtr
              With aSub(j)
                bThisCueEnabled = aCue(\nCueIndex)\bCueEnabled
                If bThisCueEnabled = #False
                  ; if cue disabled then all sub-cues of the cue are therefore disabled
                  bThisSubEnabled = #False
                Else
                  bThisSubEnabled = \bSubEnabled
                EndIf
                If \bSubTypeL ; bSubTypeL
                  If (\sLCCue = sCue) And (\nLCSubNo = nSubNo)
                    If (nAction = 0) Or (nAction = 1 And bThisSubEnabled)
                      sRISubLabel = \sSubLabel
                    EndIf
                  EndIf
                ElseIf \bSubTypeS ; bSubTypeS
                  For h = 0 To #SCS_MAX_SFR
                    If \nSFRCueType[h] = #SCS_SFR_CUE_SEL
                      If (\sSFRCue[h] = sCue) And (\nSFRSubNo[h] = nSubNo)
                        If (nAction = 0) Or (nAction = 1 And bThisSubEnabled)
                          sRISubLabel = \sSubLabel
                          Break
                        EndIf
                      EndIf
                    EndIf
                  Next h
                EndIf
              EndWith
              If sRISubLabel
                Break
              EndIf
            EndIf ; EndIf j <> pSubPtr
          EndIf ; EndIf aSub(j)\bExists
        Next j
      EndIf ; EndIf Len(sRICueLabel) = 0
      
    Case 2
      ;  2 = Check if Enable Cue allowed
      j = pSubPtr
      debugMsg(sProcName, "aSub(" + getSubLabel(j) + ")\sSubType=" + aSub(j)\sSubType)
      
      If aSub(j)\bSubTypeG  ; bSubTypeG
        i = getCuePtr(aSub(j)\sCueToGoTo)
        If i >= 0
          bThisCueEnabled = aCue(i)\bCueEnabled
          If bThisCueEnabled = #False
            sRISubLabel = aCue(i)\sCue
          EndIf
        EndIf
        
      ElseIf aSub(j)\bSubTypeJ  ; bSubTypeJ
        For n = 0 To #SCS_MAX_ENABLE_DISABLE
          If aSub(j)\aEnableDisable[n]\sFirstCue
            i = getCuePtr(aSub(j)\aEnableDisable[n]\sFirstCue)
            If i >= 0
              bThisCueEnabled = aCue(i)\bCueEnabled
              If bThisCueEnabled = #False
                sRISubLabel = aCue(i)\sCue
              EndIf
            EndIf
          EndIf
          If sRISubLabel
            Break
          EndIf
          If aSub(j)\aEnableDisable[n]\sLastCue
            i = getCuePtr(aSub(j)\aEnableDisable[n]\sLastCue)
            If i >= 0
              bThisCueEnabled = aCue(i)\bCueEnabled
              If bThisCueEnabled = #False
                sRISubLabel = aCue(i)\sCue
              EndIf
            EndIf
          EndIf
          If sRISubLabel
            Break
          EndIf
        Next n
        
      ElseIf aSub(j)\bSubTypeL  ; bSubTypeL
        i = aSub(j)\nLCCuePtr
        j2 = aSub(j)\nLCSubPtr
        If i >= 0
          If aCue(i)\bCueEnabled = #False
            sRISubLabel = aCue(i)\sCue
          ElseIf j2 >= 0
            If aSub(j2)\bSubEnabled = #False
              sRISubLabel = getSubLabel(j2)
            EndIf
          EndIf
        EndIf
        
      ElseIf aSub(j)\bSubTypeQ  ; bSubTypeQ
        i = getCuePtr(aSub(j)\sCallCue)
        If i >= 0
          bThisCueEnabled = aCue(i)\bCueEnabled
          If bThisCueEnabled = #False
            sRISubLabel = aCue(i)\sCue
          EndIf
        EndIf
        
      ElseIf aSub(j)\bSubTypeS  ; bSubTypeS
        For n = 0 To #SCS_MAX_SFR
          If aSub(j)\nSFRCueType[n] = #SCS_SFR_CUE_SEL
            If Len(aSub(j)\sSFRCue[n]) > 0
              i = aSub(j)\nSFRCuePtr[n]
              If i >= 0
                bThisCueEnabled = aCue(i)\bCueEnabled
                If bThisCueEnabled = #False
                  sRISubLabel = aCue(i)\sCue
                EndIf
              EndIf
            EndIf
            If sRISubLabel
              Break
            EndIf
          EndIf
        Next n
        
      ElseIf aSub(j)\bSubTypeT  ; bSubTypeT
        i = getCuePtr(aSub(j)\sSetPosCue)
        If i >= 0
          bThisCueEnabled = aCue(i)\bCueEnabled
          If bThisCueEnabled = #False
            sRISubLabel = aCue(i)\sCue
          EndIf
        EndIf
        
      EndIf
      
  EndSelect
  
  If sRICueLabel
    If nAction = 0
      sMsg = sMsgStart + " " + LangPars("Errors", "ReferredToByCue", sRICueLabel)
    ElseIf nAction = 1
      sMsg = sMsgStart + " " + LangPars("Errors", "ReferredToByCueEn", sRICueLabel)
    ElseIf nAction = 2
      sMsg = sMsgStart + " " + LangPars("Errors", "RefersToCueDi", sRICueLabel)
    EndIf
  ElseIf sRISubLabel
    If nAction = 0
      sMsg = sMsgStart + " " + LangPars("Errors", "ReferredToBySub", sRISubLabel)
    ElseIf nAction = 1
      sMsg = sMsgStart + " " + LangPars("Errors", "ReferredToBySubEn", sRISubLabel)
    ElseIf nAction = 2
      sMsg = sMsgStart + " " + LangPars("Errors", "RefersToSubDi", sRISubLabel)
    EndIf
  EndIf
  If sMsg
    debugMsg(sProcName, sMsg)
    scsMessageRequester(grText\sTextEditor, sMsg, #MB_ICONEXCLAMATION | #PB_MessageRequester_Ok)
    ProcedureReturn #False
  Else
    ProcedureReturn #True
  EndIf

EndProcedure

Procedure checkExportCueRI(pCuePtr)
  PROCNAMECQ(pCuePtr)
  Protected i, j, n
  Protected sMsg.s
  Protected bErrorFound
  
  While #True
    
    j = aCue(pCuePtr)\nFirstSubIndex
    While (j >= 0) And (bErrorFound = #False)
      If aSub(j)\bSubTypeG  ; bSubTypeG
        i = getCuePtr(aSub(j)\sCueToGoTo)
        If i >= 0
          If WEX_exportThisCue(i) = #False
            bErrorFound = #True
            Break
          EndIf
        EndIf
        
      ElseIf aSub(j)\bSubTypeJ  ; bSubTypeJ
        For n = 0 To #SCS_MAX_ENABLE_DISABLE
          If Len(aSub(j)\aEnableDisable[n]\sFirstCue) > 0
            i = getCuePtr(aSub(j)\aEnableDisable[n]\sFirstCue)
            If i >= 0
              If WEX_exportThisCue(i) = #False
                bErrorFound = #True
                Break
              EndIf
            EndIf
          EndIf
          If Len(aSub(j)\aEnableDisable[n]\sLastCue) > 0
            i = getCuePtr(aSub(j)\aEnableDisable[n]\sLastCue)
            If i >= 0
              If WEX_exportThisCue(i) = #False
                bErrorFound = #True
                Break
              EndIf
            EndIf
          EndIf
        Next n
        
      ElseIf aSub(j)\bSubTypeL  ; bSubTypeL
        i = aSub(j)\nLCCuePtr
        If i >= 0
          If WEX_exportThisCue(i) = #False
            bErrorFound = #True
            Break
          EndIf
        EndIf
        
      ElseIf aSub(j)\bSubTypeQ  ; bSubTypeQ
        i = getCuePtr(aSub(j)\sCallCue)
        If i >= 0
          If WEX_exportThisCue(i) = #False
            bErrorFound = #True
            Break
          EndIf
        EndIf
      
      ElseIf aSub(j)\bSubTypeS  ; bSubTypeS
        For n = 0 To #SCS_MAX_SFR
          If aSub(j)\nSFRCueType[n] = #SCS_SFR_CUE_SEL
            If Len(aSub(j)\sSFRCue[n]) > 0
              i = aSub(j)\nSFRCuePtr[n]
              If i >= 0
                If WEX_exportThisCue(i) = #False
                  bErrorFound = #True
                  Break
                EndIf
              EndIf
            EndIf
          EndIf
        Next n
        
      ElseIf aSub(j)\bSubTypeT  ; bSubTypeT
        i = getCuePtr(aSub(j)\sSetPosCue)
        If i >= 0
          If WEX_exportThisCue(i) = #False
            bErrorFound = #True
            Break
          EndIf
        EndIf
        
      EndIf
      j = aSub(j)\nNextSubIndex
    Wend
    Break
  Wend
  
  If bErrorFound
    sMsg = LangPars("Errors", "CannotExportCue", aCue(pCuePtr)\sCue, aCue(i)\sCue)
    debugMsg(sProcName, sMsg)
    scsMessageRequester(grText\sTextEditor, sMsg, #MB_ICONEXCLAMATION | #PB_MessageRequester_Ok)
    ProcedureReturn #False
  Else
    ProcedureReturn #True
  EndIf
  
EndProcedure

Procedure createEditorToolBar(nLeft, nTop, nWidth, nHeight, nHostId)
  PROCNAMEC()
  Protected n
  
  debugMsg(sProcName, #SCS_START)
  
  WED\tbEditor = addToolBar(#SCS_TBE_EDITOR, nLeft, nTop, nWidth, nHeight, nHostId)
  
  ; File group
  addToolBarCat(#SCS_TBEC_FILE, #SCS_TBE_EDITOR, Lang("Menu", "mnuFile"), 40)
  addToolBarBtn(#SCS_TBEB_SAVE, #SCS_TBEC_FILE, hToolSaveEn, hToolSaveDi, Lang("Menu", "mnuSave"), "", -2, 24, 24)
  addToolBarBtn(#SCS_TBEB_OTHER_ACTIONS, #SCS_TBEC_FILE, hToolOtherActionsEn, hToolOtherActionsEn, Lang("Menu", "mnuOtherActions"), "", -3, 24, 24, #True)
  
  ; Editing group
  addToolBarCat(#SCS_TBEC_EDIT, #SCS_TBE_EDITOR, Lang("Menu", "mnuEditing"), 40)
  addToolBarBtn(#SCS_TBEB_UNDO, #SCS_TBEC_EDIT, hToolUndoEn, hToolUndoDi, Lang("Menu", "mnuUndo"), "", -2, 24, 24, #True)
  addToolBarBtn(#SCS_TBEB_REDO, #SCS_TBEC_EDIT, hToolRedoEn, hToolRedoDi, Lang("Menu", "mnuRedo"), "", -2, 24, 24, #True)
  addToolBarBtn(#SCS_TBEB_PROD, #SCS_TBEC_EDIT, hToolProdEn, 0, Lang("Menu", "mnuProdMenu"), "", -265, 24, 24, #True)
  addToolBarBtn(#SCS_TBEB_CUES, #SCS_TBEC_EDIT, hToolCueEn, hToolCueDi, Lang("Menu", "mnuCuesMenu"), "", -265, 24, 24, #True)
  addToolBarBtn(#SCS_TBEB_SUBS, #SCS_TBEC_EDIT, hToolSubEn, hToolSubDi, Lang("Menu", "mnuSubsMenu"), "", -265, 24, 24, #True)
  
  ; Favorites group
  addToolBarCat(#SCS_TBEC_FAV, #SCS_TBE_EDITOR, Lang("Menu", "mnuFav"), 40, #True, #True)
  ; buttons are created hidden and then the required favorites will be displayed in the order requested
  addToolBarBtnH(#SCS_TBEB_ADD_QA, #SCS_TBEC_FAV, hToolAddQAEn, hToolAddQADi, Lang("WED", "FavAddQA"), "", -365)
  addToolBarBtnH(#SCS_TBEB_ADD_QF, #SCS_TBEC_FAV, hToolAddQFEn, hToolAddQFDi, Lang("WED", "FavAddQF"), "", -365)
  addToolBarBtnH(#SCS_TBEB_ADD_QG, #SCS_TBEC_FAV, hToolAddQGEn, hToolAddQGDi, Lang("WED", "FavAddQG"), "", -365)
  addToolBarBtnH(#SCS_TBEB_ADD_QI, #SCS_TBEC_FAV, hToolAddQIEn, hToolAddQIDi, Lang("WED", "FavAddQI"), "", -365)
  addToolBarBtnH(#SCS_TBEB_ADD_QK, #SCS_TBEC_FAV, hToolAddQKEn, hToolAddQKDi, Lang("WED", "FavAddQK"), "", -365)
  addToolBarBtnH(#SCS_TBEB_ADD_QL, #SCS_TBEC_FAV, hToolAddQLEn, hToolAddQLDi, Lang("WED", "FavAddQL"), "", -365)
  addToolBarBtnH(#SCS_TBEB_ADD_QM, #SCS_TBEC_FAV, hToolAddQMEn, hToolAddQMDi, Lang("WED", "FavAddQM"), "", -365)
  addToolBarBtnH(#SCS_TBEB_ADD_QN, #SCS_TBEC_FAV, hToolAddQNEn, hToolAddQNDi, Lang("WED", "FavAddQN"), "", -365)
  addToolBarBtnH(#SCS_TBEB_ADD_QE, #SCS_TBEC_FAV, hToolAddQEEn, hToolAddQEDi, Lang("WED", "FavAddQE"), "", -365)
  addToolBarBtnH(#SCS_TBEB_ADD_QP, #SCS_TBEC_FAV, hToolAddQPEn, hToolAddQPDi, Lang("WED", "FavAddQP"), "", -365)
  addToolBarBtnH(#SCS_TBEB_ADD_QR, #SCS_TBEC_FAV, hToolAddQREn, hToolAddQRDi, Lang("WED", "FavAddQR"), "", -365)
  addToolBarBtnH(#SCS_TBEB_ADD_QS, #SCS_TBEC_FAV, hToolAddQSEn, hToolAddQSDi, Lang("WED", "FavAddQS"), "", -365)
  addToolBarBtnH(#SCS_TBEB_ADD_QT, #SCS_TBEC_FAV, hToolAddQTEn, hToolAddQTDi, Lang("WED", "FavAddQT"), "", -365)
  addToolBarBtnH(#SCS_TBEB_ADD_QQ, #SCS_TBEC_FAV, hToolAddQQEn, hToolAddQQDi, Lang("WED", "FavAddQQ"), "", -365)
  addToolBarBtnH(#SCS_TBEB_ADD_QU, #SCS_TBEC_FAV, hToolAddQUEn, hToolAddQUDi, Lang("WED", "FavAddQU"), "", -365)
  
  addToolBarBtnH(#SCS_TBEB_ADD_SA, #SCS_TBEC_FAV, hToolAddSAEn, hToolAddSADi, Lang("WED", "FavAddSA"), "", -375)
  addToolBarBtnH(#SCS_TBEB_ADD_SF, #SCS_TBEC_FAV, hToolAddSFEn, hToolAddSFDi, Lang("WED", "FavAddSF"), "", -375)
  addToolBarBtnH(#SCS_TBEB_ADD_SG, #SCS_TBEC_FAV, hToolAddSGEn, hToolAddSGDi, Lang("WED", "FavAddSG"), "", -375)
  addToolBarBtnH(#SCS_TBEB_ADD_SI, #SCS_TBEC_FAV, hToolAddSIEn, hToolAddSIDi, Lang("WED", "FavAddSI"), "", -375)
  addToolBarBtnH(#SCS_TBEB_ADD_SK, #SCS_TBEC_FAV, hToolAddSKEn, hToolAddSKDi, Lang("WED", "FavAddSK"), "", -375)
  addToolBarBtnH(#SCS_TBEB_ADD_SL, #SCS_TBEC_FAV, hToolAddSLEn, hToolAddSLDi, Lang("WED", "FavAddSL"), "", -375)
  addToolBarBtnH(#SCS_TBEB_ADD_SM, #SCS_TBEC_FAV, hToolAddSMEn, hToolAddSMDi, Lang("WED", "FavAddSM"), "", -375)
  addToolBarBtnH(#SCS_TBEB_ADD_SE, #SCS_TBEC_FAV, hToolAddSEEn, hToolAddSEDi, Lang("WED", "FavAddSE"), "", -375)
  addToolBarBtnH(#SCS_TBEB_ADD_SP, #SCS_TBEC_FAV, hToolAddSPEn, hToolAddSPDi, Lang("WED", "FavAddSP"), "", -375)
  addToolBarBtnH(#SCS_TBEB_ADD_SR, #SCS_TBEC_FAV, hToolAddSREn, hToolAddSRDi, Lang("WED", "FavAddSR"), "", -375)
  addToolBarBtnH(#SCS_TBEB_ADD_SS, #SCS_TBEC_FAV, hToolAddSSEn, hToolAddSSDi, Lang("WED", "FavAddSS"), "", -375)
  addToolBarBtnH(#SCS_TBEB_ADD_ST, #SCS_TBEC_FAV, hToolAddSTEn, hToolAddSTDi, Lang("WED", "FavAddST"), "", -375)
  addToolBarBtnH(#SCS_TBEB_ADD_SQ, #SCS_TBEC_FAV, hToolAddSQEn, hToolAddSQDi, Lang("WED", "FavAddSQ"), "", -375)
  addToolBarBtnH(#SCS_TBEB_ADD_SU, #SCS_TBEC_FAV, hToolAddSUEn, hToolAddSUDi, Lang("WED", "FavAddSU"), "", -375)
  
  addToolBarBtnH(#SCS_TBEB_FAV_NONE, #SCS_TBEC_FAV, 0, 0, "", "", 75) ; blank dummy button used as a place holder if no favorites have been selected
  
  showEditorFavorites(#True)  ; sets visible state and display order of required favorites
  
  ; Help group
  addToolBarCat(#SCS_TBEC_HELP, #SCS_TBE_EDITOR, Lang("Menu", "mnuHelp"), 40)
  addToolBarBtn(#SCS_TBEB_HELP, #SCS_TBEC_HELP, hToolHelpEn, 0, Lang("Menu", "mnuHelp"))
  
  debugMsg(sProcName, "calling drawToolBar(#SCS_TBE_EDITOR)")
  drawToolBar(#SCS_TBE_EDITOR)
  
  gaWindowProps(#WED)\nToolBarHeight = nHeight
  
  debugMsg(sProcName, #SCS_END)

EndProcedure

Procedure adjustEditorDetailsForSplitterSize()
  PROCNAMEC()
  
  With grCED
    If \bQADisplayed
      WQA_adjustForSplitterSize()
    ElseIf \bQEDisplayed
      WQE_adjustForSplitterSize()
    ElseIf \bQFDisplayed
      WQF_adjustForSplitterSize()
    ElseIf \bQGDisplayed
      WQG_adjustForSplitterSize()
    ElseIf \bQIDisplayed
      WQI_adjustForSplitterSize()
    ElseIf \bQJDisplayed
      WQJ_adjustForSplitterSize()
    ElseIf \bQKDisplayed
      WQK_adjustForSplitterSize()
    ElseIf \bQLDisplayed
      WQL_adjustForSplitterSize()
    ElseIf \bQMDisplayed
      WQM_adjustForSplitterSize()
    ElseIf \bQPDisplayed
      WQP_adjustForSplitterSize()
    ElseIf \bQQDisplayed
      WQQ_adjustForSplitterSize()
    ElseIf \bQRDisplayed
      WQR_adjustForSplitterSize()
    ElseIf \bQSDisplayed
      WQS_adjustForSplitterSize()
    ElseIf \bQTDisplayed
      WQT_adjustForSplitterSize()
    ElseIf \bQUDisplayed
      WQU_adjustForSplitterSize()
    EndIf
  EndWith
EndProcedure

Procedure setSubHeader(nGadgetNo, pSubPtr)
  Protected sTitle.s
  
  With aSub(pSubPtr)
    If \bSubTypeA
      sTitle = Lang("WQA", "lblVideoFile")
    ElseIf \bSubTypeE
      sTitle = Lang("WQE", "lblMemo")
    ElseIf \bSubTypeF
      sTitle = Lang("WQF", "lblSoundFile")
    ElseIf \bSubTypeG
      sTitle = Lang("WQG", "lblGoTo")
    ElseIf \bSubTypeI
      sTitle = Lang("WQI", "lblLiveInput")
    ElseIf \bSubTypeJ
      sTitle = Trim(LangPars("WQJ", "dfltDescr", ""))
    ElseIf \bSubTypeK
      sTitle = Lang("WQK", "dfltDescr")
    ElseIf \bSubTypeL
      sTitle = Lang("WQL", "lblLevelChange")
    ElseIf \bSubTypeM
      sTitle = Lang("WQM", "lblMidiSend")
    ElseIf \bSubTypeP
      sTitle = Lang("WQP", "lblPlaylist")
    ElseIf \bSubTypeQ
      sTitle = Trim(LangPars("WQQ", "dfltDescr", \sCallCue))
    ElseIf \bSubTypeR
      sTitle = Lang("WQR", "dfltDescr")
    ElseIf \bSubTypeS
      sTitle = Lang("WQS", "lblSFRCues")
    ElseIf \bSubTypeT
      sTitle = Lang("WQT", "lblSetPos")
    ElseIf \bSubTypeU
      sTitle = Lang("WQU", "lblMTCStartTime")
      If \nMTCType = #SCS_MTC_TYPE_LTC
        sTitle = ReplaceString(sTitle, "MTC", "LTC")
      EndIf
    EndIf
  EndWith
  
  SGT(nGadgetNo, " " + LangSpace("Common", "SubCue") + aSub(pSubPtr)\sCue + " <" + aSub(pSubPtr)\nSubNo + "> : " + sTitle)
  
EndProcedure

Procedure setProdGlobalLevels(bFirstTime=#False)
  PROCNAMEC()
  Protected nCurrMaxDBLevel, nCurrMinDBLevel
  
  With grLevels
    If bFirstTime Or grProd\nProdId = grProdDef\nProdId
      ; first time - no cue file yet opened
      nCurrMaxDBLevel = grProdDef\nMaxDBLevel ; grProdDef\nMaxDBLevel is currently 0 (ie 0dB)
      nCurrMinDBLevel = grProdDef\nMinDBLevel
    Else
      ; not first time - a cue file has been opened or created
      nCurrMaxDBLevel = grProd\nMaxDBLevel ; grProd\nMaxDBLevel may be 0 (0dB) or 12 (+12dB), and is held in the cue file in the "nMaxDBLevel" field
      nCurrMinDBLevel = grProd\nMinDBLevel
    EndIf
    Select nCurrMaxDBLevel ; maximum dB level
      Case 12 ; ie +12dB
        \nMaxDBLevel = 12
        \sDefaultDBLevel = StrF(0, 1) ; = "0.0" or "0,0"
        \bSMSUseGainMidi = #False   ; in SMS, GAINMIDI cannot be used for levels > 0dB, so don't use GAINMIDI at all
      Default ; only other valid value for grProd\nMaxDBLevel currently is 0, ie +0dB
        \nMaxDBLevel = 0
        \sDefaultDBLevel = StrF(-3, 1)  ; = "-3.0" or "-3,0"
        \bSMSUseGainMidi = #True
    EndSelect
    \fMaxBVLevel = convertDBLevelToBVLevel(\nMaxDBLevel)
    \sMaxDBLevel = convertDBLevelToDBString(\nMaxDBLevel)
    
    \nMinDBLevel = nCurrMinDBLevel
    \fMinBVLevel = convertDBLevelToBVLevel(\nMinDBLevel)
    \sMinDBLevel = convertDBLevelToDBString(\nMinDBLevel)
    
    ; debugMsg(sProcName,"grLevels\sDefaultDBLevel=" + \sDefaultDBLevel + ", \nMinDBLevel=" + \nMinDBLevel + ", \fMinBVLevel=" + traceLevel(\fMinBVLevel) + ", \sMinDBLevel=" + \sMinDBLevel)
    
  EndWith
  
EndProcedure

Procedure setProdGlobals(bInSetIndependantDefaults=#False, bFirstTime=#False)
  PROCNAMEC()
  Protected nDevNo
  Static nSldMaxDBLevel

  ; debugMsg(sProcName, #SCS_START)
  
  setProdGlobalLevels(bFirstTime)
  
  ; (re)initialise fader constants
  gbInitFaderConstantsDone = #False
  SLD_initFaderConstants()
  
  If bInSetIndependantDefaults = #False
    If grLevels\nMaxDBLevel <> nSldMaxDBLevel
      ; debugMsg(sProcName, "calling redrawAllLevelSliders()")
      SLD_redrawAllLevelSliders()
      nSldMaxDBLevel = grLevels\nMaxDBLevel
    EndIf
  EndIf
  
  ; debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure setDerivedProdFields()
  PROCNAMEC()
  Protected i
  
  ; debugMsg(sProcName, #SCS_START)
  
  ; debugMsg(sProcName, "calling setProdGlobals()")
  setProdGlobals()
  
  ; debugMsg(sProcName, "calling setAutoIncludeDefaults(@grProd)")
  setAutoIncludeDefaults(@grProd)
  
  With grProd
    
    Select \nRunMode
      Case #SCS_RUN_MODE_NON_LINEAR_PREOPEN_ALL, #SCS_RUN_MODE_BOTH_PREOPEN_ALL
        \bPreOpenNonLinearCues = #True
      Default
        \bPreOpenNonLinearCues = #False
    EndSelect
    
    \bUsingMidiCueNumbers = #False
    For i = 1 To gnLastCue
      If Trim(aCue(i)\sMidiCue)
        \bUsingMidiCueNumbers = #True
        Break
      EndIf
    Next i
    
  EndWith
  
  setNonLinearCueFlags()
  CSRD_SetRemDevUsedInProd()
  
  ; debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure setLTSubArrays(*rProd.tyProd, *rSub.tySub, bPrimeArrays=#False)
  ; PROCNAMEC()
  Protected nChaseStepIndex, nFixtureIndex, sLTFixtureCode.s, nTotalChans, nChanIndex
  
  ; debugMsg(sProcName, #SCS_START + ": " + *rSub\sSubLabel)
  
;   debugMsg(sProcName, "calling listLTSubArraySizes(*rSub)")
;   listLTSubArraySizes(*rSub)
  
  With *rSub
    If \nMaxChaseStepIndex > ArraySize(\aChaseStep())
      ReDim \aChaseStep(\nMaxChaseStepIndex)
      ; debugMsg(sProcName, "ReDim \aChaseStep(" + \nMaxChaseStepIndex + ")")
    EndIf
    ; debugMsg(sProcName, "ArraySize(\aChaseStep())=" + ArraySize(\aChaseStep()))
    For nChaseStepIndex = 0 To \nMaxChaseStepIndex
      If bPrimeArrays
        \aChaseStep(nChaseStepIndex) = grChaseStepDef
      EndIf
      If \nMaxFixture > ArraySize(\aChaseStep(nChaseStepIndex)\aFixtureItem())
        ReDim \aChaseStep(nChaseStepIndex)\aFixtureItem(\nMaxFixture)
        ; debugMsg(sProcName, "ReDim \aChaseStep(" + nChaseStepIndex + ")\aFixtureItem(" + \nMaxFixture + ")")
      EndIf
      ; debugMsg(sProcName, "ArraySize(\aChaseStep(" + nChaseStepIndex + ")\aFixtureItem())=" + ArraySize(\aChaseStep(nChaseStepIndex)\aFixtureItem()))
      For nFixtureIndex = 0 To \nMaxFixture
        sLTFixtureCode = \aLTFixture(nFixtureIndex)\sLTFixtureCode
        nTotalChans = getTotalChansForFixture(*rProd, *rSub, sLTFixtureCode)
        If bPrimeArrays
          \aChaseStep(nChaseStepIndex)\aFixtureItem(nFixtureIndex)\sFixtureCode = sLTFixtureCode
        EndIf
        If (nTotalChans-1) > ArraySize(\aChaseStep(nChaseStepIndex)\aFixtureItem(nFixtureIndex)\aFixChan())
          ReDim \aChaseStep(nChaseStepIndex)\aFixtureItem(nFixtureIndex)\aFixChan(nTotalChans-1)
          ; debugMsg(sProcName, "ReDim \aChaseStep(" + nChaseStepIndex + ")\aFixtureItem(" + nFixtureIndex + ")\aFixChan(" + Str(nTotalChans-1) + ")")
        EndIf
        ; debugMsg(sProcName, "ArraySize(\aChaseStep(" + nChaseStepIndex + ")\aFixtureItem(" + nFixtureIndex + ")\aFixChan())=" + ArraySize(\aChaseStep(nChaseStepIndex)\aFixtureItem(nFixtureIndex)\aFixChan()))
        If bPrimeArrays
          For nChanIndex = 0 To nTotalChans-1
            \aChaseStep(nChaseStepIndex)\aFixtureItem(nFixtureIndex)\aFixChan(nChanIndex) = grLTFixChanDef
            \aChaseStep(nChaseStepIndex)\aFixtureItem(nFixtureIndex)\aFixChan(nChanIndex)\nRelChanNo = nChanIndex+1
          Next nChanIndex
        EndIf
      Next nFixtureIndex
    Next nChaseStepIndex
  EndWith
  
;   debugMsg(sProcName, "calling listLTSubArraySizes(*rSub)")
;   listLTSubArraySizes(*rSub)
  
  ; debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure setLTMaxChaseStepIndex(*rProd.tyProd, *rSub.tySub)
  PROCNAMEC()
  Protected nOldMaxChaseStepIndex, nNewMaxChaseStepIndex, nFirstNewChaseStepIndex
  Protected nChaseStepIndex
  
  ; debugMsg(sProcName, #SCS_START + ": " + *rSub\sSubLabel)
  
  With *rSub
    nOldMaxChaseStepIndex = \nMaxChaseStepIndex
    If \bChase
      nNewMaxChaseStepIndex = \nChaseSteps - 1
    Else
      nNewMaxChaseStepIndex = 0
    EndIf
    \nMaxChaseStepIndex = nNewMaxChaseStepIndex
    If nNewMaxChaseStepIndex > ArraySize(\aChaseStep())
      ReDim \aChaseStep(nNewMaxChaseStepIndex)
      debugMsg(sProcName, "ReDim \aChaseStep(" + nNewMaxChaseStepIndex + ")")
    EndIf
    If *rProd\bLightingPre118 = #False
      nFirstNewChaseStepIndex = nOldMaxChaseStepIndex + 1
      For nChaseStepIndex = nFirstNewChaseStepIndex To nNewMaxChaseStepIndex
        If nChaseStepIndex > 0
          \aChaseStep(nChaseStepIndex) = \aChaseStep(nChaseStepIndex-1)
          debugMsg(sProcName, "\aChaseStep(" + nChaseStepIndex + ") = \aChaseStep(" + Str(nChaseStepIndex-1) + ")")
        EndIf
      Next nChaseStepIndex
    EndIf
    
  EndWith
  
  ; debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure listLTSubArraySizes(*rSub.tySub)
  PROCNAMEC()
  Protected nChaseStepIndex, nFixtureIndex
  
  With *rSub
    debugMsg(sProcName, "ArraySize(\aChaseStep())=" + ArraySize(\aChaseStep()))
    For nChaseStepIndex = 0 To \nMaxChaseStepIndex
      debugMsg(sProcName, "ArraySize(\aChaseStep(" + nChaseStepIndex + ")\aFixtureItem()=" + ArraySize(\aChaseStep(nChaseStepIndex)\aFixtureItem()))
      For nFixtureIndex = 0 To \nMaxFixture
        debugMsg(sProcName, "ArraySize(\aChaseStep(" + nChaseStepIndex + ")\aFixtureItem(" + nFixtureIndex + ")\aFixChan())=" + ArraySize(\aChaseStep(nChaseStepIndex)\aFixtureItem(nFixtureIndex)\aFixChan()))
      Next nFixtureIndex
    Next nChaseStepIndex
  EndWith
  
EndProcedure

Procedure setLCDevPresentInds(pSubPtr)
  PROCNAMECS(pSubPtr)
  Protected d, k
  Protected nLCSubPtr
  
  If pSubPtr >= 0
    With aSub(pSubPtr)
      nLCSubPtr = \nLCSubPtr
      If nLCSubPtr >= 0
        If (\bLCTargetIsF) Or (\bLCTargetIsI)
          k = aSub(nLCSubPtr)\nFirstAudIndex
          If k >= 0
            For d = 0 To grLicInfo\nMaxAudDevPerAud
              If Trim(aAud(k)\sLogicalDev[d])
                \bLCDevPresent[d] = #True
                ; debugMsg(sProcName, "\bLCDevPresent[" + d + "]=" + strB(\bLCDevPresent[d]))
              EndIf
            Next d
          EndIf
        ElseIf \bLCTargetIsA
          \bLCDevPresent[0] = #True
        ElseIf \bLCTargetIsP
          For d = 0 To grLicInfo\nMaxAudDevPerAud
            If Trim(aSub(nLCSubPtr)\sPLLogicalDev[d])
              \bLCDevPresent[d] = #True
              ; debugMsg(sProcName, "\bLCDevPresent[" + d + "]=" + strB(\bLCDevPresent[d]))
            EndIf
          Next d
        EndIf
      EndIf
    EndWith
  EndIf

EndProcedure

Macro macSetDerivedSubFields(pProd, pSub, pLCSub, pAud)
  
  nItemIndex = -1
  macSetSubTypeBooleansForSub(pSub)
  Select UCase(pSub\sSubType)
    Case "A"
      nItemIndex = #SCS_COL_ITEM_QA
    Case "E"
      nItemIndex = #SCS_COL_ITEM_QE
    Case "F"
      nItemIndex = #SCS_COL_ITEM_QF
    Case "G"
      nItemIndex = #SCS_COL_ITEM_QG
    Case "I"
      nItemIndex = #SCS_COL_ITEM_QI
    Case "J"
      nItemIndex = #SCS_COL_ITEM_QJ
    Case "K"
      nItemIndex = #SCS_COL_ITEM_QK
      setLTMaxChaseStepIndex(@pProd, @pSub)
    Case "L"
      nItemIndex = #SCS_COL_ITEM_QL
    Case "M"
      nItemIndex = #SCS_COL_ITEM_QM
    Case "N"
      nItemIndex = #SCS_COL_ITEM_QN
    Case "P"
      nItemIndex = #SCS_COL_ITEM_QP
    Case "Q"
      nItemIndex = #SCS_COL_ITEM_QQ
    Case "R"
      nItemIndex = #SCS_COL_ITEM_QR
    Case "S"
      nItemIndex = #SCS_COL_ITEM_QS
    Case "T"
      nItemIndex = #SCS_COL_ITEM_QT
    Case "U"
      nItemIndex = #SCS_COL_ITEM_QU
  EndSelect
  
  If nItemIndex >= 0
    pSub\nBackColor = grColorScheme\aItem[nItemIndex]\nBackColor
    pSub\nTextColor = grColorScheme\aItem[nItemIndex]\nTextColor
  EndIf
  
  If pSub\bSubTypeHasAuds ; \bSubTypeHasAuds
    setDerivedFieldsForSubAuds(pSubPtr, bPrimaryFile)
  EndIf
  
  If pSub\bSubTypeK ; bSubTypeK
    If grLicInfo\bDMXSendAvailable
      pSub\bDMXSend = #True
      pSub\sDMXSendString = DMX_buildDMXValuesString(pSubPtr, bPrimaryFile)
      Select pSub\nLTEntryType
        Case #SCS_LT_ENTRY_TYPE_DMX_ITEMS, #SCS_LT_ENTRY_TYPE_DMX_CAPTURE_SEQ, #SCS_LT_ENTRY_TYPE_DMX_CAPTURE_SNAP
          pSub\sLTDisplayInfo = pSub\sDMXSendString
      EndSelect
    EndIf
    
  ElseIf pSub\bSubTypeL ; bSubTypeL
    If pSub\nLCSubPtr >= 0
      pSub\bLCTargetIsA = pLCSub\bSubTypeA
      pSub\bLCTargetIsF = pLCSub\bSubTypeF
      pSub\bLCTargetIsI = pLCSub\bSubTypeI
      pSub\bLCTargetIsP = pLCSub\bSubTypeP
      If (pSub\bLCTargetIsF) Or (pSub\bLCTargetIsI)
        k = pLCSub\nFirstAudIndex
        If k >= 0
          For d = 0 To grLicInfo\nMaxAudDevPerAud
            If Trim(pAud\sLogicalDev[d])
              pSub\bLCDevPresent[d] = #True
            Else
              pSub\bLCInclude[d] = #False
            EndIf
          Next d
        EndIf
      ElseIf pSub\bLCTargetIsA
        pSub\bLCDevPresent[0] = #True
      ElseIf pSub\bLCTargetIsP
        For d = 0 To grLicInfo\nMaxAudDevPerAud
          If Trim(pLCSub\sPLLogicalDev[d])
            pSub\bLCDevPresent[d] = #True
          Else
            pSub\bLCInclude[d] = #False
          EndIf
        Next d
      EndIf
    EndIf
    
    Select pSub\nLCAction
      Case #SCS_LC_ACTION_ABSOLUTE, #SCS_LC_ACTION_RELATIVE
        bLCSameLevel = #True
        nFirstIncludedDev = -1
        For d = 0 To grLicInfo\nMaxAudDevPerAud
          If pSub\bLCInclude[d]
            If nFirstIncludedDev = -1
              nFirstIncludedDev = d
              sFirstLevelDB = pSub\sLCReqdDBLevel[d]
              fFirstPan = pSub\fLCReqdPan[d]
            Else
              If (pSub\sLCReqdDBLevel[d] <> sFirstLevelDB) Or (pSub\fLCReqdPan[d] <> fFirstPan)
                bLCSameLevel = #False
              EndIf
            EndIf
          EndIf
        Next d
        If pSub\bLCCalcSameLevelInd
          pSub\bLCSameLevel = bLCSameLevel
          pSub\bLCCalcSameLevelInd = #False
        EndIf
        If pSub\bLCSameLevel
          For d = 0 To grLicInfo\nMaxAudDevPerAud
            pSub\sLCReqdDBLevel[d] = sFirstLevelDB
            pSub\fLCReqdBVLevel[d] = convertDBStringToBVLevel(pSub\sLCReqdDBLevel[d])
            pSub\fLCReqdPan[d] = fFirstPan
          Next d
        EndIf
        pSub\nLCTimeMax = 0
        bLCSameTime = #True
        nFirstIncludedDev = -1
        For d = 0 To grLicInfo\nMaxAudDevPerAud
          If (pSub\bLCInclude[d]) And (pSub\nLCTime[d] >= 0)
            If nFirstIncludedDev = -1
              nFirstIncludedDev = d
              nFirstTime = pSub\nLCTime[d]
            Else
              If pSub\nLCTime[d] <> nFirstTime
                bLCSameTime = #False
              EndIf
            EndIf
            If pSub\nLCTime[d] > pSub\nLCTimeMax
              pSub\nLCTimeMax = pSub\nLCTime[d]
            EndIf
          EndIf
        Next d
        If pSub\bLCCalcSameTimeInd
          pSub\bLCSameTime = bLCSameTime
          pSub\bLCCalcSameTimeInd = #False
        EndIf
        If pSub\bLCSameTime
          For d = 0 To grLicInfo\nMaxAudDevPerAud
            pSub\nLCTime[d] = nFirstTime
          Next d
        EndIf
        
      Case #SCS_LC_ACTION_TEMPO, #SCS_LC_ACTION_PITCH, #SCS_LC_ACTION_FREQ
        pSub\nLCTimeMax = pSub\nLCActionTime
    EndSelect
    
  ElseIf pSub\bSubTypeM ; bSubTypeM
    ; debugMsg(sProcName, "\bSubTypeM start")
    For n = 0 To #SCS_MAX_CTRL_SEND
      pSub\aCtrlSend[n]\bMIDISend = #False
      pSub\aCtrlSend[n]\bRS232Send = #False
      pSub\aCtrlSend[n]\bNetworkSend = #False
      pSub\aCtrlSend[n]\bHTTPSend = #False
      Select pSub\aCtrlSend[n]\nDevType
        Case #SCS_DEVTYPE_CS_MIDI_OUT, #SCS_DEVTYPE_CS_NETWORK_OUT
          ; nb MUST populate \nRemDevId before \nRemDevMsgType as \nRemDevId is required in the call to CSRD_EncodeRemDevMsgType()
          ; debugMsg(sProcName, "pSub\aCtrlSend[" + n + "]\nDevType=" + decodeDevType(pSub\aCtrlSend[n]\nDevType) + ", \sCSLogicalDev=" + pSub\aCtrlSend[n]\sCSLogicalDev)
          pSub\aCtrlSend[n]\nRemDevId = CSRD_GetRemDevIdForLogicalDev(pSub\aCtrlSend[n]\nDevType, pSub\aCtrlSend[n]\sCSLogicalDev)
          If pSub\aCtrlSend[n]\nRemDevId > 0
            If pSub\aCtrlSend[n]\sRemDevMsgType
              pSub\aCtrlSend[n]\nRemDevMsgType = CSRD_EncodeRemDevMsgType(pSub\aCtrlSend[n]\nRemDevId, pSub\aCtrlSend[n]\sRemDevMsgType)
            EndIf
            ; debugMsg(sProcName, "pSub\aCtrlSend[" + n + "]\nRemDevId=" + pSub\aCtrlSend[n]\nRemDevId + ", \sRemDevMsgType=" + pSub\aCtrlSend[n]\sRemDevMsgType +
            ;                     ", \sRemDevValue=" + #DQUOTE$ + pSub\aCtrlSend[n]\sRemDevValue + #DQUOTE$ + ", \sRemDevValue2=" + #DQUOTE$ + pSub\aCtrlSend[n]\sRemDevValue2 + #DQUOTE$)
          EndIf
      EndSelect
      Select pSub\aCtrlSend[n]\nDevType
        Case #SCS_DEVTYPE_CS_MIDI_OUT, #SCS_DEVTYPE_CS_MIDI_THRU
          pSub\aCtrlSend[n]\bMIDISend = #True
          
        Case #SCS_DEVTYPE_CS_RS232_OUT
          pSub\aCtrlSend[n]\bRS232Send = #True
          buildSendString(pSubPtr, n, bPrimaryFile)
          
        Case #SCS_DEVTYPE_CS_NETWORK_OUT
          If grLicInfo\nLicLevel >= #SCS_LIC_PRO
            pSub\aCtrlSend[n]\bNetworkSend = #True
            If pSub\aCtrlSend[n]\bIsOSC
              If pSub\aCtrlSend[n]\bOSCItemPlaceHolder
                pSub\aCtrlSend[n]\sOSCItemString = grText\sTextPlaceHolder
              EndIf
            EndIf
            ; debugMsg(sProcName," pSub\aCtrlSend[" + n + "]\sOSCItemString=" + pSub\aCtrlSend[n]\sOSCItemString + ", \nOSCCmdType=" + decodeOSCCmdType(pSub\aCtrlSend[n]\nOSCCmdType))
            buildNetworkSendString(pSubPtr, n, bPrimaryFile)
          EndIf
          
        Case #SCS_DEVTYPE_CS_HTTP_REQUEST
          If grLicInfo\nLicLevel >= #SCS_LIC_PRO
            pSub\aCtrlSend[n]\bHTTPSend = #True
            buildHTTPSendString(pSubPtr, n, bPrimaryFile)
          EndIf
          
      EndSelect
      ; debugMsg(sProcName, "Calling buildDisplayInfoForCtrlSend n="+n)
      buildDisplayInfoForCtrlSend(@pSub, n, bPrimaryFile)
      
    Next n
    ; debugMsg(sProcName, "\bSubTypeM end")
    
  EndIf
  
EndMacro

Procedure setDerivedSubFields(pSubPtr, bPrimaryFile=#True)
  PROCNAMECS(pSubPtr, bPrimaryFile)
  Protected d, k, n
  Protected nAudCount
  Protected bLCSameTime, nPrevTime
  Protected bLCSameLevel, sPrevLevelDB.s, fPrevPan.f
  Protected nFirstTime, sFirstLevelDB.s, fFirstPan.f
  Protected nFirstIncludedDev
  Protected nItemIndex
  
  ; debugMsg(sProcName, #SCS_START + ", bPrimaryFile=" + strB(bPrimaryFile))
  
  If pSubPtr >= 0
    If bPrimaryFile
      With aSub(pSubPtr)
        macSetDerivedSubFields(grProd, aSub(pSubPtr), aSub(\nLCSubPtr), aAud(k)) ; nb "aSub(\nLCSubPtr)" and "aAud(k)" only used in macro for \bSubTypeL (k is set within the macro)
        \nSubDuration = getSubLength(pSubPtr, #True)
        If \nSubStart = #SCS_SUBSTART_REL_MTC
          \nCalcMTCStartTimeForSub = calcMTCStartTimeForSub(pSubPtr)
        EndIf
        Select \sSubType
          Case "A", "E"
            loadArrayOutputScreenReqd(pSubPtr)
          Case "M"
            If grLicInfo\bCSRDAvailable
              updateSubCtrlSendMsgsForScribbleStripItemNames(pSubPtr)
            EndIf
          Case "Q"
            \nCallCuePtr = getCuePtr(\sCallCue)
            ; must call populateCallCueParamArray() AFTER setting \nCallCuePtr
            populateCallCueParamArray(@aSub(pSubPtr), bPrimaryFile)
        EndSelect
      EndWith
    Else
      With a2ndSub(pSubPtr)
        macSetDerivedSubFields(gr2ndProd, a2ndSub(pSubPtr), a2ndSub(\nLCSubPtr), a2ndAud(k)) ; nb "a2ndSub(\nLCSubPtr)" and "a2ndAud(k)" only used in macro for \bSubTypeL (k is set within the macro)
        Select \sSubType
          Case "Q"
            \nCallCuePtr = getCuePtr2(\sCallCue)
            ; must call populateCallCueParamArray() AFTER setting \nCallCuePtr
            populateCallCueParamArray(@a2ndSub(pSubPtr), bPrimaryFile)
        EndSelect
      EndWith
    EndIf
  EndIf
  
  ; debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure setDerivedLoopInfo(pAudPtr, nLoopInfoIndex=-1, bPrimaryFile=#True)
  PROCNAMECA(pAudPtr)
  Protected l2, nFirstIndex, nLastIndex
  
  If bPrimaryFile
    With aAud(pAudPtr)
      If nLoopInfoIndex < 0
        nFirstIndex = 0
        nLastIndex = \nMaxLoopInfo
      Else
        nFirstIndex = nLoopInfoIndex
        nLastIndex = nLoopInfoIndex
      EndIf
      For l2 = nFirstIndex To nLastIndex
        \aLoopInfo(l2)\nAbsLoopStart = getAbsTime(pAudPtr, "LS", l2)
        \aLoopInfo(l2)\nAbsLoopEnd = getAbsTime(pAudPtr, "LE", l2)
        If \aLoopInfo(l2)\nAbsLoopStart < \nAbsStartAt
          \nAbsMin = \aLoopInfo(l2)\nAbsLoopStart
        EndIf
        If \aLoopInfo(l2)\nAbsLoopEnd > \nAbsEndAt
          \nAbsMax = \aLoopInfo(l2)\nAbsLoopEnd
        EndIf
        If \aLoopInfo(l2)\nAbsLoopStart >= 0
          If \aLoopInfo(l2)\qLoopStartSamplePos >= 0
            \aLoopInfo(l2)\qLoopStartBytePos = \aLoopInfo(l2)\qLoopStartSamplePos * \nBytesPerSamplePos
          Else
            \aLoopInfo(l2)\qLoopStartBytePos = \aLoopInfo(l2)\nAbsLoopStart * \nSampleRate * \nBytesPerSamplePos / 1000
          EndIf
        EndIf
        If \aLoopInfo(l2)\nAbsLoopEnd >= 0
          If \aLoopInfo(l2)\qLoopEndSamplePos >= 0
            \aLoopInfo(l2)\qLoopEndBytePos = \aLoopInfo(l2)\qLoopEndSamplePos * \nBytesPerSamplePos
          Else
            \aLoopInfo(l2)\qLoopEndBytePos = \aLoopInfo(l2)\nAbsLoopEnd * \nSampleRate * \nBytesPerSamplePos / 1000
          EndIf
        EndIf
        \aLoopInfo(l2)\nRelLoopStart = \aLoopInfo(l2)\nAbsLoopStart - \nAbsMin
        \aLoopInfo(l2)\nRelLoopEnd = \aLoopInfo(l2)\nAbsLoopEnd - \nAbsMin
        debugMsg(sProcName, "\aLoopInfo(" + l2 + ")\nRelLoopStart=" + \aLoopInfo(l2)\nRelLoopStart + ", \nRelLoopEnd=" + \aLoopInfo(l2)\nRelLoopEnd +
                            ", \nAbsLoopStart=" + \aLoopInfo(l2)\nAbsLoopStart + ", \nAbsLoopEnd=" + \aLoopInfo(l2)\nAbsLoopEnd)
      Next l2
    EndWith
  Else
    With a2ndAud(pAudPtr)
      If nLoopInfoIndex < 0
        nFirstIndex = 0
        nLastIndex = \nMaxLoopInfo
      Else
        nFirstIndex = nLoopInfoIndex
        nLastIndex = nLoopInfoIndex
      EndIf
      For l2 = nFirstIndex To nLastIndex
        \aLoopInfo(l2)\nAbsLoopStart = getAbsTime(pAudPtr, "LS", l2)
        \aLoopInfo(l2)\nAbsLoopEnd = getAbsTime(pAudPtr, "LE", l2)
        If \aLoopInfo(l2)\nAbsLoopStart < \nAbsStartAt
          \nAbsMin = \aLoopInfo(l2)\nAbsLoopStart
        EndIf
        If \aLoopInfo(l2)\nAbsLoopEnd > \nAbsEndAt
          \nAbsMax = \aLoopInfo(l2)\nAbsLoopEnd
        EndIf
        If \aLoopInfo(l2)\nAbsLoopStart >= 0
          If \aLoopInfo(l2)\qLoopStartSamplePos >= 0
            \aLoopInfo(l2)\qLoopStartBytePos = \aLoopInfo(l2)\qLoopStartSamplePos * \nBytesPerSamplePos
          Else
            \aLoopInfo(l2)\qLoopStartBytePos = \aLoopInfo(l2)\nAbsLoopStart * \nSampleRate * \nBytesPerSamplePos / 1000
          EndIf
        EndIf
        If \aLoopInfo(l2)\nAbsLoopEnd >= 0
          If \aLoopInfo(l2)\qLoopEndSamplePos >= 0
            \aLoopInfo(l2)\qLoopEndBytePos = \aLoopInfo(l2)\qLoopEndSamplePos * \nBytesPerSamplePos
          Else
            \aLoopInfo(l2)\qLoopEndBytePos = \aLoopInfo(l2)\nAbsLoopEnd * \nSampleRate * \nBytesPerSamplePos / 1000
          EndIf
        EndIf
        \aLoopInfo(l2)\nRelLoopStart = \aLoopInfo(l2)\nAbsLoopStart - \nAbsMin
        \aLoopInfo(l2)\nRelLoopEnd = \aLoopInfo(l2)\nAbsLoopEnd - \nAbsMin
        debugMsg(sProcName, "\aLoopInfo(" + l2 + ")\nRelLoopStart=" + \aLoopInfo(l2)\nRelLoopStart + ", \nRelLoopEnd=" + \aLoopInfo(l2)\nRelLoopEnd +
                            ", \nAbsLoopStart=" + \aLoopInfo(l2)\nAbsLoopStart + ", \nAbsLoopEnd=" + \aLoopInfo(l2)\nAbsLoopEnd)
      Next l2
    EndWith
  EndIf
  
EndProcedure

Procedure setDerivedAudScreenInfoFields(pAudPtr)
  PROCNAMECA(pAudPtr)
  Protected nSubPtr, sScreens.s, nOutputScreenCount, nReqdArraySize, nOneOutputScreen, nOneVidPicTarget, n
  Protected rScreenInfoDef.tyAudScreenInfo
  
  With aAud(pAudPtr)
    If \bAudTypeA
      nSubPtr = \nSubIndex
      sScreens = aSub(nSubPtr)\sScreens
      If sScreens
        nOutputScreenCount = CountString(sScreens, ",") + 1
      EndIf
    EndIf
    If nOutputScreenCount > 0
      nReqdArraySize = nOutputScreenCount - 1
    EndIf
    If ArraySize(\aScreenInfo()) < nReqdArraySize
      REDIM_ARRAY(\aScreenInfo, nReqdArraySize, rScreenInfoDef, "\aScreenInfo()")
    EndIf
    \nMaxScreenInfo = nOutputScreenCount - 1
    If \bAudTypeA
      For n = 0 To \nMaxScreenInfo
        nOneOutputScreen = Val(StringField(sScreens, (n+1), ","))
        If nOneOutputScreen >= 2
          nOneVidPicTarget = #SCS_VID_PIC_TARGET_F2 + (nOneOutputScreen - 2)
          If (\aScreenInfo(n)\nAudOutputScreen <> nOneOutputScreen) Or (\aScreenInfo(n)\nAudVidPicTarget <> nOneVidPicTarget)
            \aScreenInfo(n) = rScreenInfoDef
            \aScreenInfo(n)\nAudOutputScreen = nOneOutputScreen
            \aScreenInfo(n)\nAudVidPicTarget = nOneVidPicTarget
          EndIf
        EndIf
      Next n
    EndIf
  EndWith
  
EndProcedure

Macro macSetDerivedAudFields(pAud)
  
  ; debugMsg(sProcName, "calling setFirstAndLastDev(" + getAudLabel(pAudPtr) + ")")
  setFirstAndLastDev(pAudPtr, bPrimaryFile)
  
  If pAud\bAudTypeI ; pAud\bAudTypeI
    pAud\nCueDuration = 0
    setInputOnOffCounts(pAudPtr, bPrimaryFile)
    If pAud\nInputOnCount = 0
      pAud\nCurrFadeInTime = 0
      pAud\nCurrFadeOutTime = 0
    EndIf
    ProcedureReturn
  EndIf
  
  ; other aud types
  ; debugMsg0(sProcName, "(a) pAud\nEndAt=" + pAud\nEndAt + ", pAud\nAbsEndAt=" + pAud\nAbsEndAt + ", pAud\bContinuous=" + strB(pAud\bContinuous) + ", pAud\bDoContinuous=" + strB(pAud\bDoContinuous) + ", pAud\nCueDuration=" + pAud\nCueDuration)
  
  Select pAud\nFileFormat
    Case #SCS_FILEFORMAT_AUDIO
      
      If pAud\sStartAtCPName
        nCPIndex = getCuePointIndex(pAud\sFileName, pAud\sStartAtCPName)
        If nCPIndex >= 0
          pAud\dStartAtCPTime = gaCuePoint(nCPIndex)\dTimePos
          pAud\qStartAtSamplePos = gaCuePoint(nCPIndex)\qSamplePos
          If pAud\dStartAtCPTime >= 0.0
            pAud\nStartAt = Int(pAud\dStartAtCPTime * 1000)
          EndIf
        EndIf
        ; debugMsg(sProcName, "\sStartAtCPName=" + pAud\sStartAtCPName + ", \qStartAtSamplePos=" + pAud\qStartAtSamplePos + ", \dStartAtCPTime=" + StrD(pAud\dStartAtCPTime,5))
      EndIf
      
      For l2 = 0 To ArraySize(pAud\aLoopInfo())
        If pAud\aLoopInfo(l2)\sLoopStartCPName
          nCPIndex = getCuePointIndex(pAud\sFileName, pAud\aLoopInfo(l2)\sLoopStartCPName)
          If nCPIndex >= 0
            pAud\aLoopInfo(l2)\dLoopStartCPTime = gaCuePoint(nCPIndex)\dTimePos
            pAud\aLoopInfo(l2)\qLoopStartSamplePos = gaCuePoint(nCPIndex)\qSamplePos
            If pAud\aLoopInfo(l2)\dLoopStartCPTime >= 0.0
              pAud\aLoopInfo(l2)\nLoopStart = Int(pAud\aLoopInfo(l2)\dLoopStartCPTime * 1000)
            EndIf
          EndIf
        EndIf
        
        If pAud\aLoopInfo(l2)\sLoopEndCPName
          nCPIndex = getCuePointIndex(pAud\sFileName, pAud\aLoopInfo(l2)\sLoopEndCPName)
          If nCPIndex >= 0
            pAud\aLoopInfo(l2)\dLoopEndCPTime = gaCuePoint(nCPIndex)\dTimePos
            pAud\aLoopInfo(l2)\qLoopEndSamplePos = gaCuePoint(nCPIndex)\qSamplePos
            If pAud\aLoopInfo(l2)\dLoopEndCPTime >= 0.0
              pAud\aLoopInfo(l2)\nLoopEnd = Int(pAud\aLoopInfo(l2)\dLoopEndCPTime * 1000)
            EndIf
          EndIf
        EndIf
      Next l2
      
      If pAud\sEndAtCPName
        nCPIndex = getCuePointIndex(pAud\sFileName, pAud\sEndAtCPName)
        If nCPIndex >= 0
          pAud\dEndAtCPTime = gaCuePoint(nCPIndex)\dTimePos
          pAud\qEndAtSamplePos = gaCuePoint(nCPIndex)\qSamplePos
          If pAud\dEndAtCPTime >= 0.0
            pAud\nEndAt = Int(pAud\dEndAtCPTime * 1000)
            ; debugMsg(sProcName, "pAud\nEndAt=" + pAud\nEndAt + ", \dEndAtCPTime=" + pAud\dEndAtCPTime)
          EndIf
        EndIf
      EndIf
      
    Case #SCS_FILEFORMAT_VIDEO
      ; no action
      
    Case #SCS_FILEFORMAT_PICTURE
      If (pAud\nEndAt <= 0) And (pAud\bDoContinuous = #False) And (pAud\bLogo = #False)
        pAud\nEndAt = grLastPicInfo\nLastPicEndAt
      EndIf
      If pAud\bContinuous
        pAud\nEndAt = grAudDef\nEndAt
      EndIf
      pAud\nFileDuration = grAudDef\nFileDuration ; added 27Apr2017 11.6.1at following email from Lluís Vilarrasa about image display time changes not being accepted
                                                  ; which was due to a > 0 pAud\nFileDuration overriding pAud\nEndAt in the coding below
                                                  ; eg a 5-seconds file duration overriding a 10-seconds display time
      
    Case #SCS_FILEFORMAT_CAPTURE
      If (pAud\nEndAt <= 0) And (pAud\bDoContinuous = #False) And (pAud\bLogo = #False)
        pAud\nEndAt = grLastPicInfo\nLastPicEndAt
      EndIf
      If pAud\bContinuous
        pAud\nEndAt = grAudDef\nEndAt
      EndIf
      pAud\nFileDuration = grAudDef\nFileDuration
      
  EndSelect
  
  If pAud\bAudPlaceHolder
    pAud\nAbsStartAt = grAudDef\nAbsStartAt
    pAud\nAbsEndAt = grAudDef\nAbsEndAt
    pAud\nMaxLoopInfo = grAudDef\nMaxLoopInfo
    pAud\rCurrLoopInfo = grAudDef\rCurrLoopInfo
    pAud\aLoopInfo(0) = grAudDef\aLoopInfo(0)
  Else
    ; added 20Oct2016 11.5.2.4 to allow for old cue files that had fields like 'loop end' set to pAud\nFileDuration instead of (pAud\nFileDuration - 1)
    If pAud\nFileDuration > 0
      For l2 = 0 To  pAud\nMaxLoopInfo
        If (pAud\aLoopInfo(l2)\bContainsLoop) And (pAud\aLoopInfo(l2)\nLoopEnd >= pAud\nFileDuration)
          debugMsg(sProcName, "adjusting pAud\aLoopInfo(" + l2 + ")\nLoopEnd")
          pAud\aLoopInfo(l2)\nLoopEnd = pAud\nFileDuration - 1
        EndIf
      Next l2
      If pAud\nEndAt >= pAud\nFileDuration
        debugMsg(sProcName, "adjusting pAud\nEndAt")
        pAud\nEndAt = pAud\nFileDuration - 1
      EndIf
    EndIf
    ; end added 20Oct2016 11.5.2.4
    pAud\nAbsStartAt = getAbsTime(pAudPtr, "ST")
    pAud\nAbsEndAt = getAbsTime(pAudPtr, "EN")
    ; debugMsg(sProcName, "pAud\nAbsStartAt=" + pAud\nAbsStartAt + ", pAud\nAbsEndAt=" + pAud\nAbsEndAt)
  EndIf
  
  pAud\nAbsMin = pAud\nAbsStartAt
  pAud\nAbsMax = pAud\nAbsEndAt
  For l2 = 0 To pAud\nMaxLoopInfo
    If pAud\aLoopInfo(l2)\bContainsLoop
      If pAud\aLoopInfo(l2)\nAbsLoopStart < pAud\nAbsStartAt
        pAud\nAbsMin = pAud\aLoopInfo(l2)\nAbsLoopStart
      EndIf
      If pAud\aLoopInfo(l2)\nAbsLoopEnd > pAud\nAbsEndAt
        pAud\nAbsMax = pAud\aLoopInfo(l2)\nAbsLoopEnd
      EndIf
    EndIf
  Next l2
  
  If pAud\nAbsStartAt >= 0
    If pAud\qStartAtSamplePos >= 0
      pAud\qStartAtBytePos = pAud\qStartAtSamplePos * pAud\nBytesPerSamplePos
    Else
      pAud\qStartAtBytePos = pAud\nAbsStartAt * pAud\nSampleRate * pAud\nBytesPerSamplePos / 1000
    EndIf
  EndIf
  If pAud\nAbsEndAt >= 0
    If pAud\qEndAtSamplePos >= 0
      pAud\qEndAtBytePos = pAud\qEndAtSamplePos * pAud\nBytesPerSamplePos
    Else
      pAud\qEndAtBytePos = pAud\nAbsEndAt * pAud\nSampleRate * pAud\nBytesPerSamplePos / 1000
    EndIf
  EndIf
  
  ; debugMsg(sProcName, "calling setDerivedLoopInfo(" + getAudLabel(pAudPtr) + ")")
  setDerivedLoopInfo(pAudPtr)
  
  ; debugMsg0(sProcName, "(b) pAud\nEndAt=" + pAud\nEndAt + ", pAud\nAbsEndAt=" + pAud\nAbsEndAt + ", pAud\bContinuous=" + strB(pAud\bContinuous) + ", pAud\bDoContinuous=" + strB(pAud\bDoContinuous) + ", pAud\nCueDuration=" + pAud\nCueDuration)
  If pAud\bAudPlaceHolder
    pAud\nCueDuration = 0
  ElseIf pAud\nFileFormat = #SCS_FILEFORMAT_PICTURE
    pAud\nCueDuration = pAud\nAbsEndAt + 1
  ElseIf pAud\nFileFormat = #SCS_FILEFORMAT_CAPTURE
    pAud\nCueDuration = pAud\nAbsEndAt + 1
  Else
    pAud\nCueDuration = pAud\nAbsMax - pAud\nAbsMin + 1
  EndIf
  ; debugMsg0(sProcName, "(e) pAud\nEndAt=" + pAud\nEndAt + ", pAud\nAbsEndAt=" + pAud\nAbsEndAt + ", pAud\bContinuous=" + strB(pAud\bContinuous) + ", pAud\bDoContinuous=" + strB(pAud\bDoContinuous) + ", pAud\nCueDuration=" + pAud\nCueDuration)
  ; debugMsg(sProcName, "aAud(" + getAudLabel(pAudPtr) + "\nAbsMax=" + pAud\nAbsMax + ", pAud\nAbsMin=" + pAud\nAbsMin + ", pAud\nCueDuration=" + pAud\nCueDuration + ", pAud\nFileDuration=" + pAud\nFileDuration)
  ; debugMsg(sProcName, "\nAbsStartAt=" + pAud\nAbsStartAt + ", pAud\nAbsEndAt=" + pAud\nAbsEndAt)
  pAud\nRelStartAt = pAud\nAbsStartAt - pAud\nAbsMin
  pAud\nRelEndAt = pAud\nAbsEndAt - pAud\nAbsMin
  
;   debugMsg(sProcName, "\nFileDuration=" + pAud\nFileDuration + ", pAud\nCueDuration=" + pAud\nCueDuration + ", pAud\nAbsMin=" + pAud\nAbsMin + ", pAud\nAbsMax=" + pAud\nAbsMax +
;                       ", pAud\nStartAt=" + pAud\ nStartAt + ", pAud\nEndAt=" + pAud\nEndAt + ", pAud\nAbsStartAt=" + pAud\nAbsStartAt + ", pAud\nAbsEndAt=" + pAud\nAbsEndAt + ", pAud\nRelEndAt=" + pAud\nRelEndAt +
;                       ", pAud\nFadeInTime=" + pAud\nFadeInTime + ", pAud\nFadeOutTime=" + pAud\nFadeOutTime)
  
  If pAud\nCueDuration < 0
    ; indicates something's wrong, but display Cue Length as 0.00, not as a negative time
    pAud\nCueDuration = 0
  EndIf
  
  If pAud\nAudState <= #SCS_CUE_READY
    pAud\bTimeForNextFadeCheckSet = #False
    pAud\bTimeFadeInStartedSet = #False
    pAud\bTimeFadeOutStartedSet = #False
    ; debugMsg(sProcName, "aAud(" + getAudLabel(pAudPtr) + ")\nAudState=" + decodeCueState(pAud\nAudState) + ", pAud\bTimeFadeInStartedSet=" + strB(pAud\bTimeFadeInStartedSet))
  EndIf
  
  If pAud\bAudTypeF
    ; added 06/11/2014 11.3.5.2 to prevent sanityCheckLevelPoints() failing (see emails from Dave Fitzpatrick 06/11/2014)
    If pAud\nFadeInTime > 0
      nAudFadeInTime = pAud\nFadeInTime
    EndIf
    If pAud\nFadeOutTime > 0
      nAudFadeOutTime = pAud\nFadeOutTime
    EndIf
    If (pAud\bAudPlaceHolder) Or (((nAudFadeInTime + nAudFadeOutTime) >= pAud\nCueDuration) And (pAud\nCueDuration > 0))
      ; " And (pAud\nCueDuration > 0)" added 17Nov2016 11.5.2.4.005 following emails from Philipp Schmidt regarding located files losing their fade-in and fade-out times
      debugMsg(sProcName, "clearing pAud\nFadeInTime and pAud\nFadeOutTime")
      pAud\nFadeInTime = grAudDef\nFadeInTime
      pAud\nFadeOutTime = grAudDef\nFadeOutTime
      pAud\nCurrFadeInTime = pAud\nFadeInTime
      pAud\nCurrFadeOutTime = pAud\nFadeOutTime
      ; debugMsg(sProcName, "\nFadeInTime=" + pAud\nFadeInTime + ", pAud\nCurrFadeInTime=" + pAud\nCurrFadeInTime + ", pAud\nFadeOutTime=" + pAud\nFadeOutTime + ", pAud\nCurrFadeOutTime=" + pAud\nCurrFadeOutTime)
    EndIf
    ; added 21Sep2016 11.5.2.2 to reset pAud\nRelFilePos which in turn affects the 'current position' displayed and used in the Editor
    ; debugMsg(sProcName, "calling calcCuePositionForAud(" + getAudLabel(pAudPtr) + ")")
    calcCuePositionForAud(pAudPtr)
    ; end added 21Sep2016 11.5.2.2
    ; end of added 06/11/2014 11.3.5.2
    ; debugMsg(sProcName, "calling setDerivedLevelPointInfo2(" + getAudLabel(pAudPtr) + ")")
    setDerivedLevelPointInfo2(pAudPtr)
    ; debugMsg(sProcName, "calling loadCurrLoopInfo(" + getAudLabel(pAudPtr) + ", " + aAud(pAudPtr)\nCuePos + ")")
    loadCurrLoopInfo(pAudPtr, pAud\nCuePos)
    ; debugMsg(sProcName, "(4224) calling listLoopInfoArray(" + getAudLabel(nEditAudPtr) + ")")
    ; listLoopInfoArray(pAudPtr) ; commented out 1Aug2023 11.10.0bt to reduce logging
  EndIf
  
  ; debugMsg0(sProcName, "(z) pAud\nEndAt=" + pAud\nEndAt + ", pAud\nAbsEndAt=" + pAud\nAbsEndAt + ", pAud\bContinuous=" + strB(pAud\bContinuous) + ", pAud\bDoContinuous=" + strB(pAud\bDoContinuous) + ", pAud\nCueDuration=" + pAud\nCueDuration)
  
EndMacro

Procedure setDerivedAudFields(pAudPtr, bPrimaryFile=#True)
  PROCNAMECA(pAudPtr)
  Protected nCPIndex
  Protected nAudFadeInTime, nAudFadeOutTime
  Protected l2
  
  ; debugMsg(sProcName, #SCS_START + ", bPrimaryFile=" + strB(bPrimaryFile))
  
  If bPrimaryFile
    macSetDerivedAudFields(aAud(pAudPtr))
    If aAud(pAudPtr)\bAudTypeA
      setVideoFilePresent()
    EndIf
  Else
    macSetDerivedAudFields(a2ndAud(pAudPtr))
  EndIf
  
EndProcedure

Macro macSetDerivedFieldsForSubAuds(pCue, pSub, pAud)
  ; macro for setDerivedFieldsForSubAuds()
  If pSub\bSubTypeHasAuds
    k = pSub\nFirstAudIndex
    While k >= 0
      
      If pAud\bExists
        
        nAudCount + 1
        pAud\nAudNo = nAudCount
        pAud\nSubIndex = pSubPtr
        pAud\nCueIndex = pSub\nCueIndex
        ; debugMsg(sProcName, "pAud\nCueIndex=" + pAud\nCueIndex + ", \nSubIndex=" + pAud\nSubIndex)
        
        pAud\bDoContinuous = #False
        
        ; the following is to minimize sending unnecessary /_cue/setpos messages to the remote app, especially if there are multiple sub-cues
        If k = nFirstReqdAudPtr
          pAud\bRAISendProgressPosMsgs = #True
        Else
          pAud\bRAISendProgressPosMsgs = #False
        EndIf
        ; debugMsg(sProcName, "(c2) " + pAud\sAudLabel + " \bRAISendProgressPosMsgs=" + StrB(pAud\bRAISendProgressPosMsgs))
        
        If pSub\bSubTypeAorP   ; bSubTypeP or bSubTypeA
          
          For d = 0 To grLicInfo\nMaxAudDevPerAud
            If pAud\fPLRelLevel = 100.0
              pAud\fAudPlayBVLevel[d] = pSub\fSubMastBVLevel[d]
            Else
              pAud\fAudPlayBVLevel[d] = pSub\fSubMastBVLevel[d] * pAud\fPLRelLevel / 100.0
            EndIf
            pAud\fAudPlayPan[d] = pSub\fPLPan[d]
            ; debugMsg(sProcName, getAudLabel(k) + ", \fAudPlayBVLevel(" + Str(d) + ")=" + formatLevel(pAud\fAudPlayBVLevel[d]) + ", \fAudPlayPan(" + Str(d) + ")=" + Str(pAud\fAudPlayPan[d]))
          Next d
          
          ; pAud\bDoContinuous is to be set = #True ONLY IF there is ONLY ONE AUD in the Sub and that the Sub has \bPLRepeat = #True
          ; OR if the last Aud is a picture file and has no play length nominated
          Select pAud\nFileFormat
            Case #SCS_FILEFORMAT_PICTURE
              nImageCount + 1
            Case #SCS_FILEFORMAT_VIDEO
              nVideoCount + 1
          EndSelect
          If (pAud\nPrevAudIndex = -1) And (pAud\nNextAudIndex = -1)
            ; only one Aud for this Sub
            Select pAud\nFileFormat
              Case #SCS_FILEFORMAT_PICTURE, #SCS_FILEFORMAT_CAPTURE
                If pSub\bPLRepeat
                  pAud\bDoContinuous = #True
                Else
                  pAud\bDoContinuous = pAud\bContinuous
                EndIf
              Case #SCS_FILEFORMAT_VIDEO
                If pSub\bPLRepeat
                  pAud\bDoContinuous = #True
                EndIf
            EndSelect
            
          ElseIf pAud\nNextAudIndex >= 0
            pAud\bDoContinuous = #False
          EndIf
          If pAud\nNextAudIndex = -1
            ; last Aud for this Sub
            Select pAud\nFileFormat
              Case #SCS_FILEFORMAT_PICTURE, #SCS_FILEFORMAT_CAPTURE
                If pAud\nEndAt <= 0
                  ; no play length nominated
                  pAud\bDoContinuous = #True
                EndIf
                ; Added 26Sep2024 11.10.6ab following problem reported by Paul Tumminello 'image cue fade ins' 23Sep2024
                If pSub\bPauseAtEnd
                  pAud\bDoContinuous = #True
                EndIf
                ; End added 26Sep2024 11.10.6ab
            EndSelect
          EndIf
          ; debugMsg(sProcName, "" + pAud\sAudLabel + " \nEndAt=" + Str(pAud\nEndAt) + ", \bDoContinuous=" + strB(pAud\bDoContinuous))
          
        ElseIf pSub\bSubTypeF ; \bSubTypeF
          For d = 0 To grLicInfo\nMaxAudDevPerAud
            pAud\fAudPlayBVLevel[d] = pAud\fBVLevel[d]
            pAud\fAudPlayPan[d] = pAud\fPan[d]
;             If pAud\sLogicalDev[d]
;               debugMsg(sProcName, "" + pAud\sAudLabel + " \fAudPlayBVLevel[" + d + "]=" + traceLevel(pAud\fAudPlayBVLevel[d]))
;             EndIf
          Next d
          
        ElseIf pSub\bSubTypeI ; \bSubTypeI
          pAud\bDoContinuous = #True
          If bPrimaryFile
            setInputDevMapDevPtrs(k)
          EndIf
          ; debugMsg(sProcName, "" + pAud\sAudLabel + " \nEndAt=" + Str(pAud\nEndAt) + ", \bDoContinuous=" + strB(pAud\bDoContinuous))
          
        Else ; not \SubTypeP or \bSubTypeA
          pAud\bDoContinuous = #False
          ; debugMsg(sProcName, "" + pAud\sAudLabel + " \nEndAt=" + Str(pAud\nEndAt) + ", \bDoContinuous=" + strB(pAud\bDoContinuous))
          
        EndIf
        
        If bPrimaryFile
          If pSub\bSubTypeA
            setDerivedAudScreenInfoFields(k)
          EndIf
        EndIf

      EndIf
      
      k = pAud\nNextAudIndex
    Wend
  EndIf
  pSub\nAudCount = nAudCount
  If nAudCount > 1
    debugMsg(sProcName, "pSub\nAudCount=" + pSub\nAudCount)
  EndIf
  pSub\nImageCount = nImageCount
  pSub\nVideoCount = nVideoCount
  
EndMacro

Procedure setDerivedFieldsForSubAuds(pSubPtr, bPrimaryFile=#True)
  PROCNAMECS(pSubPtr, bPrimaryFile)
  Protected d, k
  Protected nAudCount
  Protected nImageCount, nVideoCount
  Protected nCuePtr
  Protected nFirstReqdAudPtr = -1
  
  ; debugMsg(sProcName, #SCS_START + ", bPrimaryFile=" + strB(bPrimaryFile))
  
  If pSubPtr >= 0
    If bPrimaryFile ; primary file
      nCuePtr = aSub(pSubPtr)\nCueIndex
      ; debugMsg(sProcName, "calling getFirstReqdAudForCue(" + nCuePtr + "), ArraySize(aAud())=" + ArraySize(aAud()))
      nFirstReqdAudPtr = getFirstReqdAudForCue(nCuePtr)
      ; debugMsg(sProcName, "calling macSetDerivedFieldsForSubAuds(aCue(" + nCuePtr + "), aSub(" + pSubPtr + "), aAud(" + k + ")), ArraySize(aAud())=" + ArraySize(aAud()))
      macSetDerivedFieldsForSubAuds(aCue(nCuePtr), aSub(pSubPtr), aAud(k))
      ; debugMsg(sProcName, "returned from macSetDerivedFieldsForSubAuds(aCue(" + nCuePtr + "), aSub(" + pSubPtr + "), aAud(" + k + ")), ArraySize(aAud())=" + ArraySize(aAud()))
    Else  ; secondary file
      nCuePtr = a2ndSub(pSubPtr)\nCueIndex
      macSetDerivedFieldsForSubAuds(a2ndCue(nCuePtr), a2ndSub(pSubPtr), a2ndAud(k))
    EndIf
  EndIf
  
  ; debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure closeEditorForms()
  PROCNAMEC()

  debugMsg(sProcName, #SCS_START)

  With grCED
    \bProdDisplayed = #False
    \bCueDisplayed = #False
    \bQADisplayed = #False
    \bQEDisplayed = #False
    \bQFDisplayed = #False
    \bQGDisplayed = #False
    \bQIDisplayed = #False
    \bQJDisplayed = #False
    \bQKDisplayed = #False
    \bQLDisplayed = #False
    \bQMDisplayed = #False
    \bQPDisplayed = #False
    \bQQDisplayed = #False
    \bQRDisplayed = #False
    \bQSDisplayed = #False
    \bQTDisplayed = #False
    \bQUDisplayed = #False
    
    \bProdCreated = #False
    \bCueCreated = #False
    \bQACreated = #False
    \bQECreated = #False
    \bQFCreated = #False
    \bQGCreated = #False
    \bQICreated = #False
    \bQJCreated = #False
    \bQKCreated = #False
    \bQLCreated = #False
    \bQMCreated = #False
    \bQPCreated = #False
    \bQQCreated = #False
    \bQRCreated = #False
    \bQSCreated = #False
    \bQTCreated = #False
    \bQUCreated = #False
    
  EndWith

  debugMsg(sProcName, #SCS_END)

EndProcedure

Procedure setAutoIncludeDefaults(*rProd.tyProd)
  PROCNAMEC()
  Protected nDevCount, nAutoIncludeCount, nFirstDev
  Protected d
  
  ; audio output devices
  nDevCount = 0
  nAutoIncludeCount = 0
  nFirstDev = -1
  For d = 0 To *rProd\nMaxAudioLogicalDev ; grLicInfo\nMaxAudDevPerProd
    With *rProd\aAudioLogicalDevs(d)
      If \sLogicalDev
        nDevCount + 1
        If nFirstDev = -1
          nFirstDev = d
        EndIf
        If \bAutoInclude
          nAutoIncludeCount + 1
        EndIf
      EndIf
    EndWith
  Next d
  If nAutoIncludeCount = 0 And nDevCount > 0 And nFirstDev >= 0 And nFirstDev <= *rProd\nMaxAudioLogicalDev
    *rProd\aAudioLogicalDevs(nFirstDev)\bAutoInclude = #True
  EndIf
  
  ; video audio devices
  nDevCount = 0
  nAutoIncludeCount = 0
  nFirstDev = -1
  For d = 0 To *rProd\nMaxVidAudLogicalDev ; grLicInfo\nMaxVidAudDevPerProd
    With *rProd\aVidAudLogicalDevs(d)
      If \sVidAudLogicalDev
        nDevCount + 1
        If nFirstDev = -1
          nFirstDev = d
        EndIf
        If \bAutoInclude
          nAutoIncludeCount + 1
        EndIf
      EndIf
    EndWith
  Next d
  If nAutoIncludeCount = 0 And nDevCount > 0 And nFirstDev >= 0 And nFirstDev <= *rProd\nMaxAudioLogicalDev
    *rProd\aVidAudLogicalDevs(nFirstDev)\bAutoInclude = #True
  EndIf
  
EndProcedure

Procedure getFirstPlayingCue()
  PROCNAMEC()
  Protected nFirstPlayingCue = -1
  Protected i
  
  For i = 1 To gnLastCue
    With aCue(i)
      If (\nCueState >= #SCS_CUE_COUNTDOWN_TO_START) And (\nCueState <= #SCS_CUE_FADING_OUT)
        If (\bCueCurrentlyEnabled) And (\bCueSubsAllDisabled = #False)
          nFirstPlayingCue = i
          Break
        EndIf
      EndIf
    EndWith
  Next i
  
  ProcedureReturn nFirstPlayingCue
EndProcedure

Procedure getFirstEnabledCue()
  ; PROCNAMEC()
  Protected i, nCuePtr
  
  nCuePtr = 1
  For i = 1 To gnLastCue
    If aCue(i)\bCueCurrentlyEnabled
      nCuePtr = i
      ; debugMsg(sProcName, "nCuePtr=" + getCueLabel(nCuePtr))
      Break
    EndIf
  Next i
  ProcedureReturn nCuePtr
EndProcedure

Procedure getFirstEnabledSubForCue(pCuePtr)
  ; PROCNAMECQ(pCuePtr)
  Protected j, nSubPtr
  
  nSubPtr = -1
  If pCuePtr >= 0
    If aCue(pCuePtr)\bCueEnabled
      j = aCue(pCuePtr)\nFirstSubIndex
      While j >= 0
        If aSub(j)\bSubEnabled
          nSubPtr = j
          Break
        EndIf
        j = aSub(j)\nNextSubIndex
      Wend
    EndIf
  EndIf
  ProcedureReturn nSubPtr
EndProcedure

Procedure getFirstReqdAudForCue(pCuePtr)
  PROCNAMECQ(pCuePtr)
  Protected j, k
  Protected nFirstReqdAud = -1
  
  If pCuePtr >= 0
    j = aCue(pCuePtr)\nFirstSubIndex
    While j >= 0
      ; debugMsg(sProcName, "j=" + j + ", ArraySize(aSub())=" + ArraySize(aSub())) ; Changed 02Jul2022
      CheckSubInRange(j, ArraySize(aSub()), "aSub()") ; Added 02Jul2022
      If aSub(j)\bSubTypeAorF And aSub(j)\bSubEnabled
        k = aSub(j)\nFirstAudIndex
        If k >= 0
          If aAud(k)\bAudPlaceHolder = #False
            nFirstReqdAud = k
            Break
          EndIf
        EndIf
      EndIf
      If aSub(j)\nNextSubIndex = j
        debugMsg(sProcName, " FAILED !!!!!!!!!!!!!!!!! aSub(" + j + ")\nNextSubIndex=" + aSub(j)\nNextSubIndex)
        Break
      EndIf
      j = aSub(j)\nNextSubIndex
    Wend
  EndIf
  ProcedureReturn nFirstReqdAud
EndProcedure

Procedure getFirstEnabledAudTypeForCue(pCuePtr, sSubTypes.s="F")
  PROCNAMECQ(pCuePtr)
  Protected j, k
  Protected nFirstEnabledAud = -1
  
  If pCuePtr >= 0
    j = aCue(pCuePtr)\nFirstSubIndex
    While j >= 0
      ; debugMsg(sProcName, "j=" + j + ", ArraySize(aSub())=" + ArraySize(aSub())) ; Changed 02Jul2022
      CheckSubInRange(j, ArraySize(aSub()), "aSub()") ; Added 02Jul2022
      If aSub(j)\bSubEnabled
        If FindString(sSubTypes, aSub(j)\sSubType) ; eg check only type F sub-cues
          k = aSub(j)\nFirstAudIndex
          If k >= 0
            If aAud(k)\bAudPlaceHolder = #False
              nFirstEnabledAud = k
              Break
            EndIf
          EndIf
        EndIf
      EndIf
      If aSub(j)\nNextSubIndex = j
        debugMsg(sProcName, " FAILED !!!!!!!!!!!!!!!!! aSub(" + j + ")\nNextSubIndex=" + aSub(j)\nNextSubIndex)
        Break
      EndIf
      j = aSub(j)\nNextSubIndex
    Wend
  EndIf
  ProcedureReturn nFirstEnabledAud
EndProcedure

Procedure getNextEnabledSub(pSubPtr)
  ; Procedure added 10May2021 11.8.4.2bb following email from Rainer Schön
  Protected j
  Protected nNextEnabledSub = -1
  
  If pSubPtr >= 0
    j = aSub(pSubPtr)\nNextSubIndex
    While j >= 0
      If aSub(j)\bSubEnabled
        nNextEnabledSub = j
        Break
      EndIf
      j = aSub(j)\nNextSubIndex
    Wend
  EndIf
  ProcedureReturn nNextEnabledSub
EndProcedure

Procedure loadArrayOutputScreenReqd(pSubPtr)
  PROCNAMECS(pSubPtr)
  Protected sScreens.s, nScreenCount
  Protected n, nThisOutputScreen, nMyMaxOutputScreen
  Protected bTrace = #False
  
  debugMsgC(sProcName, #SCS_START)
  
  ; ensure \nOutputScreen and \sScreens are consistent, ie that the first or only screen in \sScreens matches \nOutputScreen
  ; \nOutputScreen is now (since 11.7.0) considered to be the 'primary' screen for the sub-cue, and is the one that will (or may) have a monitor image displayed
  ; in this procedure, \sScreens takes precedence if set
  ; the array \bOutputScreenReqd() is also populated for the selected output screens

  With aSub(pSubPtr)
    For n = 0 To ArraySize(\bOutputScreenReqd())
      \bOutputScreenReqd(n) = #False
    Next n
    If \bSubTypeA
      sScreens = Trim(\sScreens)
      If Len(sScreens) = 0
        sScreens = Str(\nOutputScreen)
      EndIf
    ElseIf \bSubTypeE
      sScreens = Str(\nMemoScreen)
    EndIf
    \nOutputScreen = Val(StringField(sScreens, 1, ","))
    debugMsgC(sProcName, "\nOutputScreen=" + \nOutputScreen + ", \sScreens=" + \sScreens)
    nScreenCount = CountString(sScreens, ",") + 1
    For n = 1 To nScreenCount
      nThisOutputScreen = Val(StringField(sScreens, n, ","))
      debugMsgC(sProcName, "n=" + n + ", nThisOutputScreen=" + nThisOutputScreen)
      If nThisOutputScreen >= 2
        \bOutputScreenReqd(nThisOutputScreen) = #True
        debugMsgC(sProcName, "aSub(" + getSubLabel(pSubPtr) + ")\bOutputScreenReqd(" + nThisOutputScreen + ")=" + strB(\bOutputScreenReqd(nThisOutputScreen)))
        If nThisOutputScreen > nMyMaxOutputScreen
          nMyMaxOutputScreen = nThisOutputScreen
        EndIf
      EndIf
    Next n
    \sScreens = sScreens
    \nSubMaxOutputScreen = nMyMaxOutputScreen
  EndWith
  
  debugMsgC(sProcName, #SCS_END)
  
EndProcedure

Procedure setCueSubsAllDisabledFlag(pCuePtr)
  PROCNAMECQ(pCuePtr)
  Protected j, bAllDisabled = #True
  
  j = aCue(pCuePtr)\nFirstSubIndex
  While j >= 0
    If aSub(j)\bSubEnabled
      bAllDisabled = #False
      Break
    EndIf
    j = aSub(j)\nNextSubIndex
  Wend
  aCue(pCuePtr)\bCueSubsAllDisabled = bAllDisabled
EndProcedure

Procedure calcRealPrevSubIndex(pSubPtr)
  PROCNAMECS(pSubPtr)
  Protected j, nRealPrevSubIndex
  
  j = pSubPtr
  While j >= 0
    nRealPrevSubIndex = aSub(j)\nPrevSubIndex
    If nRealPrevSubIndex < 0
      Break
    ElseIf aSub(nRealPrevSubIndex)\bSubEnabled
      Break
    EndIf
    j = aSub(j)\nPrevSubIndex
  Wend
  
  ProcedureReturn nRealPrevSubIndex
EndProcedure

Procedure loadCueBrackets(bTrace=#False)
  PROCNAMEC()
  ; for info on 'cue brackets', see the comments for the Structure tyCueBracket
  Protected i, n, nBracketFirstCue, nBracketLastCue
  
  gnLastCueBracket = -1
  
  If grProd\bPreLoadNextManualOnly ; note: cue brackets are currently only used in conjunction with 'preload only the next manual cue'
    nBracketFirstCue = -1
    nBracketLastCue = -1
    For i = 1 To gnLastCue
      With aCue(i)
        If (\bCueEnabled) And (\bHotkey = #False)
          Select \nActivationMethod
            Case #SCS_ACMETH_AUTO, #SCS_ACMETH_AUTO_PLUS_CONF
              nBracketLastCue = i
            Default
              ; some form of manual start reached, so save the bracket just ended, unless this manual start cue is the very first manual-start cue
              If nBracketFirstCue >= 0
                gnLastCueBracket + 1
                If gnLastCueBracket > ArraySize(gaCueBracket())
                  ReDim gaCueBracket(gnLastCueBracket + 20)
                EndIf
                gaCueBracket(gnLastCueBracket)\nBracketFirstCue = nBracketFirstCue
                gaCueBracket(gnLastCueBracket)\nBracketLastCue = nBracketLastCue
              EndIf
              nBracketFirstCue = i
              nBracketLastCue = i
          EndSelect
        EndIf
      EndWith
    Next i
    ; now save the final bracket found
    If nBracketFirstCue >= 0
      gnLastCueBracket + 1
      If gnLastCueBracket > ArraySize(gaCueBracket())
        ReDim gaCueBracket(gnLastCueBracket)
      EndIf
      gaCueBracket(gnLastCueBracket)\nBracketFirstCue = nBracketFirstCue
      gaCueBracket(gnLastCueBracket)\nBracketLastCue = nBracketLastCue
    EndIf
    If bTrace
      For n = 0 To gnLastCueBracket
        debugMsg(sProcName, "gaCueBracket(" + n + ")\nBracketFirstCue=" + getCueLabel(gaCueBracket(n)\nBracketFirstCue) + ", \nBracketLastCue=" + getCueLabel(gaCueBracket(n)\nBracketLastCue))
      Next n
    EndIf
  EndIf ; EndIf grProd\bPreLoadNextManualOnly
EndProcedure

Procedure getCueBracket(pCuePtr)
  Protected n, nCueBacket = -1
  
  For n = 0 To gnLastCueBracket
    If (pCuePtr >= gaCueBracket(n)\nBracketFirstCue) And (pCuePtr <= gaCueBracket(n)\nBracketLastCue)
      nCueBacket = n
      Break
    EndIf
  Next n
  ProcedureReturn nCueBacket
EndProcedure

Procedure getFirstActiveCueBracket()
  ; PROCNAMEC()
  Protected i, n, nCueBacket = -1
  Protected nCueState, nMinCueState, nMaxCueState, bCueActive
  
  ; debugMsg(sProcName, #SCS_START)
  
  For n = 0 To gnLastCueBracket
    nMinCueState = #SCS_LAST_CUE_STATE
    nMaxCueState = 0
    For i = gaCueBracket(n)\nBracketFirstCue To gaCueBracket(n)\nBracketLastCue
      nCueState = aCue(i)\nCueState
      If nCueState < nMinCueState
        nMinCueState = nCueState
      EndIf
      If nCueState > nMaxCueState
        nMaxCueState = nCueState
      EndIf
      ; debugMsg(sProcName, "n=" + n + ", aCue(" + getCueLabel(i) + ")\nCueState=" + decodeCueState(aCue(i)\nCueState))
    Next i
    If nMaxCueState < #SCS_CUE_FADING_IN
      bCueActive = #False
    ElseIf nMinCueState > #SCS_CUE_FADING_OUT
      bCueActive = #False
    Else
      bCueActive = #True
    EndIf
    ; debugMsg(sProcName, "n=" + n + ", nMinCueState=" + decodeCueState(nMinCueState) + ", nMaxCueState=" + decodeCueState(nMaxCueState) + ", bCueActive=" + strB(bCueActive))
    If bCueActive
      nCueBacket = n
      Break
    EndIf
  Next n
  ; debugMsg(sProcName, #SCS_END + ", returning nCueBacket=" + nCueBacket)
  ProcedureReturn nCueBacket
EndProcedure

Procedure getHideCueOpt(pCuePtr)
  PROCNAMECQ(pCuePtr)
  Protected nHideCueOpt
  
  With aCue(pCuePtr)
    nHideCueOpt = \nHideCueOpt
    If nHideCueOpt = #SCS_HIDE_NO
      If (\bHotkey) And (grOperModeOptions(gnOperMode)\bShowHotkeyCuesInPanels = #False)
        nHideCueOpt = #SCS_HIDE_CUE_PANEL
      EndIf
    EndIf
  EndWith
  ProcedureReturn nHideCueOpt
  
EndProcedure

Procedure calcHeightFromWidthAndAspectRation(nWidth, nAspectRatio)
  Protected nHeight
  
  Select nAspectRatio
    Case #SCS_AR_16_9
      nHeight = nWidth * 9 / 16
    Case #SCS_AR_4_3
      nHeight = nWidth * 3 / 4
    Case #SCS_AR_185_1
      nHeight = nWidth * 100 / 185
    Case #SCS_AR_235_1
      nHeight = nWidth * 100 / 235
    Default
      nHeight = nWidth * 9 / 16
  EndSelect
  ProcedureReturn nHeight
EndProcedure

Procedure setSubLTDisplayInfo(*rSub.tySub)
  ; PROCNAMEC()
  Protected nFadeTime
  Static sChase.s, sTap.s, sBlackout.s, sFadeToBlack.s
  Static bStaticLoaded
  
  If bStaticLoaded = #False
    sChase = " (" + Lang("DMX", "Chase") + ") " ; nb deliberately add a space at the beginning and end
    sTap = " (" + Lang("DMX", "Tap") + ") "     ; ditto
    sBlackout = Lang("DMX", "Blackout")
    sFadeToBlack = Lang("DMX", "FadeToBlack")
    bStaticLoaded = #True
  EndIf
  
  With *rSub
    Select \sSubType
      Case "K"  ; lighting
        Select \nLTDevType
          Case #SCS_DEVTYPE_LT_DMX_OUT ; #SCS_DEVTYPE_LT_DMX_OUT
            Select \nLTEntryType
              Case #SCS_LT_ENTRY_TYPE_DMX_ITEMS
                CompilerIf 1=2
                  If \bChase
                    If \bMonitorTapDelay
                      \sLTDisplayInfo = Trim(\sLTLogicalDev + sTap + DMX_buildDMXDisplayInfo(*rSub))
                    Else
                      \sLTDisplayInfo = Trim(\sLTLogicalDev + sChase + DMX_buildDMXDisplayInfo(*rSub))
                    EndIf
                  Else
                    \sLTDisplayInfo = Trim(\sLTLogicalDev + " " + DMX_buildDMXDisplayInfo(*rSub))
                  EndIf
                CompilerElse
                  If \bChase
                    If \bMonitorTapDelay
                      \sLTDisplayInfo = Trim(sTap + DMX_buildDMXDisplayInfo(*rSub))
                    Else
                      \sLTDisplayInfo = Trim(sChase + DMX_buildDMXDisplayInfo(*rSub))
                    EndIf
                  Else
                    \sLTDisplayInfo = Trim(DMX_buildDMXDisplayInfo(*rSub))
                  EndIf
                CompilerEndIf
              Case #SCS_LT_ENTRY_TYPE_DMX_CAPTURE_SEQ, #SCS_LT_ENTRY_TYPE_DMX_CAPTURE_SNAP
                \sLTDisplayInfo = \sDMXSendString
              Case #SCS_LT_ENTRY_TYPE_FIXTURE_ITEMS
                \sLTDisplayInfo = DMX_buildDMXString(@grProd, *rSub, 0)
              Case #SCS_LT_ENTRY_TYPE_BLACKOUT
                nFadeTime = DMX_getDefFadeTimeForSub(*rSub, @grProd)
                If nFadeTime > 0
                  \sLTDisplayInfo = ReplaceString(sFadeToBlack, "$1", timeToString(nFadeTime))
                Else
                  \sLTDisplayInfo = sBlackout
                EndIf
            EndSelect
            ; debugMsg0(sProcName, \sSubLabel + ", \sSubType=" + \sSubType + ", \nLTDevType=" + decodeDevType(\nLTDevType) + ", \nLTEntryType=" + decodeLTEntryType(\nLTEntryType) + ", \sLTDisplayInfo=" + \sLTDisplayInfo)
        EndSelect
    EndSelect
    ; debugMsg0(sProcName, \sSubLabel + ", \sSubType=" + \sSubType + ", \nLTDevType=" + decodeDevType(\nLTDevType) + ", \nLTEntryType=" + decodeLTEntryType(\nLTEntryType) + ", \sLTDisplayInfo=" + \sLTDisplayInfo)
  EndWith
  
EndProcedure

Procedure resetLastSubAndLastAud()
  PROCNAMEC()
  Protected i, j, k
  
  debugMsg(sProcName, #SCS_START + ", gnLastCue=" + gnLastCue + ", gnLastSub=" + gnLastSub + ", gnLastAud=" + gnLastAud)
  
  gnLastSub = 0
  gnLastAud = 0
  
  For i = 1 To gnLastCue
    j = aCue(i)\nFirstSubIndex
    While j >= 0
      If j > gnLastSub
        gnLastSub = j
      EndIf
      If aSub(j)\bSubTypeHasAuds
        k = aSub(j)\nFirstAudIndex
        While k >= 0
          If k > gnLastAud
            gnLastAud = k
          EndIf
          k = aAud(k)\nNextAudIndex
        Wend
      EndIf
      j = aSub(j)\nNextSubIndex
    Wend
  Next i
  
  debugMsg(sProcName, #SCS_END + ", gnLastCue=" + gnLastCue + ", gnLastSub=" + gnLastSub + ", gnLastAud=" + gnLastAud)
  
EndProcedure

Procedure calcMaxArrySizeForX32NWData(nNetworkControlPtr)
  Protected nReqdArraySize
  With gaNetworkControl(nNetworkControlPtr)\rX32NWData
;     debugMsg(sProcName, "\nMaxAuxIn=" + \nMaxAuxIn + ", \nMaxBus=" + \nMaxBus + ", \nMaxChannel=" + \nMaxChannel + ", \nMaxCue=" + \nMaxCue + ", \nMaxDCAGroup=" + \nMaxDCAGroup + ", \nMaxFXReturn=" + \nMaxFXReturn +
;                         ", \nMaxMain=" + \nMaxMain + ", \nMaxMatrix=" + \nMaxMatrix + ", \nMaxMuteGroup=" + \nMaxMuteGroup + ", \nMaxScene=" + \nMaxScene + ", \nMaxSnippet=" + \nMaxSnippet)
    If \nMaxAuxIn >= 0      : nReqdArraySize + \nMaxAuxIn + 1     : EndIf
    If \nMaxBus >= 0        : nReqdArraySize + \nMaxBus + 1       : EndIf
    If \nMaxChannel >= 0    : nReqdArraySize + \nMaxChannel + 1   : EndIf
    If \nMaxCue >= 0        : nReqdArraySize + \nMaxCue + 1       : EndIf
    If \nMaxDCAGroup >= 0   : nReqdArraySize + \nMaxDCAGroup + 1  : EndIf
    If \nMaxFXReturn >= 0   : nReqdArraySize + \nMaxFXReturn + 1  : EndIf
    If \nMaxMain >= 0       : nReqdArraySize + \nMaxMain + 1      : EndIf
    If \nMaxMatrix >= 0     : nReqdArraySize + \nMaxMatrix + 1    : EndIf
    If \nMaxMuteGroup >= 0  : nReqdArraySize + \nMaxMuteGroup + 1 : EndIf
    If \nMaxScene >= 0      : nReqdArraySize + \nMaxScene + 1     : EndIf
    If \nMaxSnippet >= 0    : nReqdArraySize + \nMaxSnippet + 1   : EndIf
    ; If \nMaxUSBIn >= 0      : nReqdArraySize + \nMaxUSBIn + 1     : EndIf
;     debugMsg(sProcName, "nReqdArraySize=" + nReqdArraySize)
  EndWith
  ProcedureReturn nReqdArraySize
EndProcedure

Macro macLoadX32ScribbleStripData(nMaxIndex, sItemName, sValType, nDataValueBase)
  For n = 0 To nMaxIndex
    nArrayIndex + 1
    If sItemName
      grCurrScribbleStrip\aScribbleStripItem(nArrayIndex)\sSSItemName = sItemName
      grCurrScribbleStrip\aScribbleStripItem(nArrayIndex)\sSSValType = sValType
      grCurrScribbleStrip\aScribbleStripItem(nArrayIndex)\nSSDataValue = (n + nDataValueBase)
      ; debugMsg(sProcName, "(macro) \aScribbleStripItem(" + nArrayIndex + ")\sSSItemName=" + grCurrScribbleStrip\aScribbleStripItem(nArrayIndex)\sSSItemName +
      ;                     ", \sSSValType=" + grCurrScribbleStrip\aScribbleStripItem(nArrayIndex)\sSSValType +
      ;                     ", \nSSDataValue=" + grCurrScribbleStrip\aScribbleStripItem(nArrayIndex)\nSSDataValue)
    EndIf
  Next n
EndMacro

Procedure loadCurrScribbleStrip(pCuePtr, pSubNo, pCtrlSendIndex)
  PROCNAMEC()
  Protected i, j, n, nMaxCtrlSendIndex
  Protected nReqdSubPtr, nReqdCtrlSendIndex, nReqdPhysicalDevPtr, nReqdDevType, nNetworkControlPtr, nCtrlPtr
  Protected nReqdArraySize, nArrayIndex
  
  nReqdSubPtr = -1
  nReqdCtrlSendIndex = -1
  nReqdPhysicalDevPtr = -1
  nReqdDevType = -1
  
  j = aCue(pCuePtr)\nFirstSubIndex
  While j >= 0
    If aSub(j)\nSubNo = pSubNo
      If aSub(j)\bSubTypeM
        nReqdPhysicalDevPtr = aSub(j)\aCtrlSend[pCtrlSendIndex]\nCSPhysicalDevPtr
        nReqdDevType = aSub(j)\aCtrlSend[pCtrlSendIndex]\nDevType
      EndIf
      Break
    EndIf
    j = aSub(j)\nNextSubIndex
  Wend
  
  nMaxCtrlSendIndex = #SCS_MAX_CTRL_SEND
  For i = 1 To pCuePtr
    If aCue(i)\bCueEnabled And aCue(i)\bSubTypeM
      j = aCue(i)\nFirstSubIndex
      While j >= 0
        If aSub(j)\bSubEnabled
          If i = pCuePtr
            If aSub(j)\nSubNo > pSubNo
              Break 2 ; Break j, i
            ElseIf aSub(j)\nSubNo = pSubNo
              nMaxCtrlSendIndex = pCtrlSendIndex
            EndIf
          EndIf
          If aSub(j)\bSubTypeM
            For n = 0 To nMaxCtrlSendIndex
              If aSub(j)\aCtrlSend[n]\nMSMsgType = #SCS_MSGTYPE_SCRIBBLE_STRIP And aSub(j)\aCtrlSend[n]\nCSPhysicalDevPtr = nReqdPhysicalDevPtr And aSub(j)\aCtrlSend[n]\nMaxScribbleStripItem >= 0
                nReqdSubPtr = j
                nReqdCtrlSendIndex = n
              EndIf
            Next n
          EndIf
        EndIf ; EndIf aSub(j)\bSubEnabled
        j = aSub(j)\nNextSubIndex
      Wend
    EndIf ; EndIf aCue(i)\bCueEnabled And aCue(i)\bSubTypeM
  Next i
  
  With grCurrScribbleStrip
    \nMaxScribbleStripItem = -1
    If nReqdSubPtr >= 0 And nReqdCtrlSendIndex >= 0
      \nMaxScribbleStripItem = aSub(nReqdSubPtr)\aCtrlSend[nReqdCtrlSendIndex]\nMaxScribbleStripItem
      If \nMaxScribbleStripItem > ArraySize(\aScribbleStripItem())
        ReDim \aScribbleStripItem(\nMaxScribbleStripItem)
      EndIf
      For n = 0 To \nMaxScribbleStripItem
        \aScribbleStripItem(n) = aSub(nReqdSubPtr)\aCtrlSend[nReqdCtrlSendIndex]\aScribbleStripItem(n)
      Next n
    EndIf
  EndWith
  
  If grCurrScribbleStrip\nMaxScribbleStripItem = -1
    ; NOTE: If no ScribbleStrip Control Send cue, then try to load scribble strip data from a network-connected X32
    nNetworkControlPtr = -1
    For n = 0 To gnMaxNetworkControl
      With gaNetworkControl(n)
        If \nDevType = #SCS_DEVTYPE_CS_NETWORK_OUT
          Select \nCtrlNetworkRemoteDev
            Case #SCS_CS_NETWORK_REM_OSC_X32, #SCS_CS_NETWORK_REM_OSC_X32_COMPACT
              ; NOTE: Network-connected X32 control send device found
              nNetworkControlPtr = n
              Break
          EndSelect
        EndIf
      EndWith
    Next n
    ; debugMsg(sProcName, "nNetworkControlPtr=" + nNetworkControlPtr)
    If nNetworkControlPtr >= 0
      ; NOTE: Network-connected X32 control send device found
      nReqdArraySize = calcMaxArrySizeForX32NWData(nNetworkControlPtr)
      debugMsg(sProcName, "nReqdArraySize=" + nReqdArraySize)
      With grCurrScribbleStrip
        \nMaxScribbleStripItem = nReqdArraySize
        If \nMaxScribbleStripItem > ArraySize(\aScribbleStripItem())
          ReDim \aScribbleStripItem(\nMaxScribbleStripItem)
        EndIf
        nCtrlPtr = nNetworkControlPtr ; to shorten name for macro calls
        nArrayIndex = -1
        macLoadX32ScribbleStripData(gaNetworkControl(nCtrlPtr)\rX32NWData\nMaxAuxIn, gaNetworkControl(nCtrlPtr)\rX32NWData\sAuxIn(n), "AuxIn", 1)
        macLoadX32ScribbleStripData(gaNetworkControl(nCtrlPtr)\rX32NWData\nMaxBus, gaNetworkControl(nCtrlPtr)\rX32NWData\sBus(n), "Bus", 1)
        macLoadX32ScribbleStripData(gaNetworkControl(nCtrlPtr)\rX32NWData\nMaxChannel, gaNetworkControl(nCtrlPtr)\rX32NWData\sChannel(n), "Chan", 1)
        macLoadX32ScribbleStripData(gaNetworkControl(nCtrlPtr)\rX32NWData\nMaxCue, gaNetworkControl(nCtrlPtr)\rX32NWData\sCue(n), "Cue", 0)
        macLoadX32ScribbleStripData(gaNetworkControl(nCtrlPtr)\rX32NWData\nMaxDCAGroup, gaNetworkControl(nCtrlPtr)\rX32NWData\sDCAGroup(n), "DCA", 1)
        macLoadX32ScribbleStripData(gaNetworkControl(nCtrlPtr)\rX32NWData\nMaxFXReturn, gaNetworkControl(nCtrlPtr)\rX32NWData\sFXReturn(n), "FXRtn", 1)
        macLoadX32ScribbleStripData(gaNetworkControl(nCtrlPtr)\rX32NWData\nMaxMatrix, gaNetworkControl(nCtrlPtr)\rX32NWData\sMatrix(n), "Matrix", 1)
        macLoadX32ScribbleStripData(gaNetworkControl(nCtrlPtr)\rX32NWData\nMaxMuteGroup, gaNetworkControl(nCtrlPtr)\rX32NWData\sMuteGroup(n), "MuteGrp", 1)
        macLoadX32ScribbleStripData(gaNetworkControl(nCtrlPtr)\rX32NWData\nMaxScene, gaNetworkControl(nCtrlPtr)\rX32NWData\sScene(n), "Scene", 0)
        macLoadX32ScribbleStripData(gaNetworkControl(nCtrlPtr)\rX32NWData\nMaxSnippet, gaNetworkControl(nCtrlPtr)\rX32NWData\sSnippet(n), "Snippet", 0)
      EndWith
    EndIf ; EndIf nNetworkControlPtr >= 0
  EndIf ; EndIf grCurrScribbleStrip\nMaxScribbleStripItem = -1
  
EndProcedure

Procedure.s getScribbleStripItemName(*rScribbleStrip.tyScribbleStrip, sValType.s, nDataValue)
  PROCNAMEC()
  Protected n, sItemName.s
  
  With *rScribbleStrip
    For n = 0 To \nMaxScribbleStripItem
      If \aScribbleStripItem(n)\sSSValType = sValType And \aScribbleStripItem(n)\nSSDataValue = nDataValue
        sItemName = \aScribbleStripItem(n)\sSSItemName
        Break
      EndIf
    Next n
  EndWith
  ; debugMsg(sProcName, "sValType=" + sValType + ", nDataValue=" + nDataValue + ", returning sItemName=" + sItemName)
  ProcedureReturn sItemName
  
EndProcedure

Procedure setScribbleStripItemName(*rScribbleStrip.tyScribbleStrip, sValType.s, nDataValue, sItemName.s)
  PROCNAMEC()
  Protected n, bFound, sItemNameTrimmed.s
  
debugMsg(sProcName, #SCS_START + ", sValType=" + sValType + ", nDataValue=" + nDataValue + ", sItemName=" + sItemName)
  
  With *rScribbleStrip
    sItemNameTrimmed = Trim(sItemName)
    For n = 0 To \nMaxScribbleStripItem
      If \aScribbleStripItem(n)\sSSValType = sValType And \aScribbleStripItem(n)\nSSDataValue = nDataValue
        \aScribbleStripItem(n)\sSSItemName = sItemNameTrimmed
        ; debugMsg(sProcName, "\aScribbleStripItem(" + n + ")\sSSItemName=" + \aScribbleStripItem(n)\sSSItemName)
        bFound = #True
        Break
      EndIf
    Next n
    If bFound = #False
      If sItemNameTrimmed
        \nMaxScribbleStripItem + 1
        If \nMaxScribbleStripItem > ArraySize(\aScribbleStripItem())
          ReDim \aScribbleStripItem(\nMaxScribbleStripItem)
        EndIf
        n = \nMaxScribbleStripItem
        \aScribbleStripItem(n)\sSSValType = sValType
        \aScribbleStripItem(n)\nSSDataValue = nDataValue
        \aScribbleStripItem(n)\sSSItemName = sItemNameTrimmed
        ; debugMsg(sProcName, "\aScribbleStripItem(" + n + ")\sSSItemName=" + \aScribbleStripItem(n)\sSSItemName)
      EndIf
    EndIf
  EndWith
  
EndProcedure

Procedure sortScribbleStripItems(nRemDevId, *rScribbleStrip.tyScribbleStrip)
  PROCNAMEC()
  Protected n, sValType.s, nDataValue, nValidValueIndex
  
  With *rScribbleStrip
    If \nMaxScribbleStripItem > 0
      ; debugMsg0(sProcName, "\nMaxScribbleStripItem=" + \nMaxScribbleStripItem + ", ArraySize(\aScribbleStripItem())=" + ArraySize(\aScribbleStripItem()))
      For n = 0 To \nMaxScribbleStripItem
        ; debugMsg0(sProcName, "n=" + n)
        sValType = \aScribbleStripItem(n)\sSSValType
        nDataValue = \aScribbleStripItem(n)\nSSDataValue
        nValidValueIndex = CSRD_GetValidValueIndexForValType(nRemDevId, sValType)
        \aScribbleStripItem(n)\nSSSortKey = (nValidValueIndex * 10000) + nDataValue
      Next n
      SortStructuredArray(\aScribbleStripItem(), #PB_Sort_Ascending, OffsetOf(tyScribbleStripItem\nSSSortKey), #PB_Integer, 0, \nMaxScribbleStripItem)
    EndIf
  EndWith
  
EndProcedure

Procedure updateSubCtrlSendMsgsForScribbleStripItemNames(pSubPtr)
  PROCNAMEC()
  Protected nCtrlSendIndex
  
  With aSub(pSubPtr)
    If \bSubEnabled And \bSubTypeM
      For nCtrlSendIndex = 0 To #SCS_MAX_CTRL_SEND
        If \aCtrlSend[nCtrlSendIndex]\nRemDevMsgType > #SCS_MSGTYPE_DUMMY_LAST
          loadCurrScribbleStrip(\nCueIndex, \nSubNo, nCtrlSendIndex)
          CSRD_buildRemDisplayInfoForCtrlSendItem(@aSub(pSubPtr), nCtrlSendIndex)
        EndIf
      Next nCtrlSendIndex
    EndIf
  EndWith
  
EndProcedure

Procedure updateCtrlSendMsgsForScribbleStripItemNames(pCuePtr=-1, pSubNo=-1, pCtrlSendIndex=-1)
  PROCNAMEC()
  Protected nFirstCuePtr, nLastCuePtr
  Protected i, j, nCtrlSendIndex, bSubChanged, bCueChanged
  
  If pCuePtr >= 0
    nFirstCuePtr = pCuePtr
    nLastCuePtr = pCuePtr
  Else
    nFirstCuePtr = 0
    nLastCuePtr = gnLastCue
  EndIf
  For i = nFirstCuePtr To nLastCuePtr
    If aCue(i)\bCueEnabled And aCue(i)\bSubTypeM
      bCueChanged = #False
      j = aCue(i)\nFirstSubIndex
      While j >= 0
        With aSub(j)
          If \bSubEnabled And \bSubTypeM
            If \nSubNo = pSubNo Or pSubNo < 0
              For nCtrlSendIndex = 0 To #SCS_MAX_CTRL_SEND
                If nCtrlSendIndex = pCtrlSendIndex Or pCtrlSendIndex < 0
                  If \aCtrlSend[nCtrlSendIndex]\nRemDevMsgType > #SCS_MSGTYPE_DUMMY_LAST
                    loadCurrScribbleStrip(i, \nSubNo, nCtrlSendIndex)
                    bSubChanged = CSRD_buildRemDisplayInfoForCtrlSendItem(@aSub(j), nCtrlSendIndex)
                    If bSubChanged
                      debugMsg(sProcName, "calling PNL_reloadDispPanelForSub(" + getSubLabel(j) + ")")
                      PNL_reloadDispPanelForSub(j)
                      bCueChanged = #True
                    EndIf
                  EndIf
                EndIf
              Next nCtrlSendIndex
            EndIf
          EndIf
          j = \nNextSubIndex
        EndWith
      Wend
      If bCueChanged
        debugMsg(sProcName, "calling loadGridRow(" + getCueLabel(i) + ")")
        loadGridRow(i)
      EndIf
    EndIf
  Next i
  
EndProcedure

Procedure.s buildTempoEtcValueString(pSubPtr)
  PROCNAMECS(pSubPtr)
  Protected sTempoEtcValueString.s, nAudPtr, sTempValue.s
  
  With aSub(pSubPtr)
    If \bSubTypeL
      Select \nLCAction
        Case #SCS_LC_ACTION_FREQ
          sTempoEtcValueString = StrF(\fLCActionValue) + "%"
          
        Case #SCS_LC_ACTION_TEMPO
          sTempoEtcValueString = StrF(\fLCActionValue) + "%"
          
        Case #SCS_LC_ACTION_PITCH
          sTempValue = StrF(\fLCActionValue, 1)
          ; if a whole number then remove the trailing ".0"
          If FindString(sTempValue, gsDecimalMarker)
            sTempValue = RTrim(sTempValue, "0")
            sTempValue = RTrim(sTempValue, gsDecimalMarker)
          EndIf
          If \fLCActionValue > 0
            sTempoEtcValueString = "+" + sTempValue
          Else
            sTempoEtcValueString = sTempValue
          EndIf
          
      EndSelect
    EndIf
  EndWith
  ProcedureReturn sTempoEtcValueString
EndProcedure

Procedure.s buildTempoEtcInfo(pSubPtr)
  PROCNAMECS(pSubPtr)
  Protected sTempoEtcInfo.s, nAudPtr, sTempValue.s
  Static sFreq.s, sTempo.s, sPitch.s, bStaticLoaded
  
  If bStaticLoaded = #False
    sFreq = LCase(Lang("WQL", "Freq")) + ": "
    sTempo = LCase(Lang("WQL", "Tempo")) + ": "
    sPitch = LCase(Lang("WQL", "Pitch")) + ": "
    bStaticLoaded = #True
  EndIf
  
  If aSub(pSubPtr)\bSubTypeF
    nAudPtr = aSub(pSubPtr)\nFirstAudIndex
    If nAudPtr >= 0
      With aAud(nAudPtr)
        Select \nAudTempoEtcAction
          Case #SCS_AF_ACTION_FREQ
            If \fAudTempoEtcValue <> 1.0
              sTempoEtcInfo = sFreq + StrF(\fAudTempoEtcValue, 2)
            EndIf
          Case #SCS_AF_ACTION_TEMPO
            If \fAudTempoEtcValue <> 1.0
              sTempoEtcInfo = sTempo + StrF(\fAudTempoEtcValue, 2)
            EndIf
          Case #SCS_AF_ACTION_PITCH
            If \fAudTempoEtcValue <> 0.0
              sTempValue = strFTrimmed(\fAudTempoEtcValue, 1)
              If \fAudTempoEtcValue > 0.0
                sTempoEtcInfo = sPitch + "+" + sTempValue
              Else
                sTempoEtcInfo = sPitch + sTempValue
              EndIf
            EndIf
        EndSelect
      EndWith
    EndIf
    
  ElseIf aSub(pSubPtr)\bSubTypeL
    With aSub(pSubPtr)
      If \bSubTypeL
        Select \nLCAction
          Case #SCS_LC_ACTION_FREQ
            sTempoEtcInfo = sFreq + strFTrimmed(\fLCActionValue, 2)
            
          Case #SCS_LC_ACTION_TEMPO
            sTempoEtcInfo = sTempo + strFTrimmed(\fLCActionValue, 2)
            
          Case #SCS_LC_ACTION_PITCH
            sTempValue = strFTrimmed(\fLCActionValue, 1)
            If \fLCActionValue > 0
              sTempoEtcInfo = sPitch + "+" + sTempValue
            Else
              sTempoEtcInfo = sPitch + sTempValue
            EndIf
            
        EndSelect
      EndIf
    EndWith
    
  EndIf
  ProcedureReturn sTempoEtcInfo
EndProcedure

Procedure calcCueStartValues(pCuePtr)
  PROCNAMECQ(pCuePtr)
  Protected bLockedMutex
  Protected sCue.s, nWorkCuePtr, nWorkSubPtr, nCallCuePtr, nCallSubPtr, nActivationMethod, bProcessThisCue
  Protected bLightingPresent, bRefreshGrdCues
  Protected bDMXLoaded
  
  ; NOTE: This procedure should only calculate cue start values for DMX items, and to do that it needs to play those items. It should NOT play any other sub-cues.
  
  If grProd\bDoNotCalcCueStartValues
    ; Production property Run Tme Setting "Do NOT calculate starting DMX values when manually resetting the next cue" is ticked, so do not calculate DMX start values
    ProcedureReturn
  EndIf
  
  debugMsg(sProcName, #SCS_START)
  
  gbInCalcCueStartValues = #True
  
  LockCueListMutex(765)
  
  For nWorkCuePtr = 1 To gnLastCue
    If aCue(nWorkCuePtr)\bSubTypeK
      bLightingPresent = #True
      Break
    EndIf
  Next nWorkCuePtr
  
  If bLightingPresent
    If grProd\nRunMode = #SCS_RUN_MODE_LINEAR
      debugMsg(sProcName, "calling DMX_blackOutAll()")
      DMX_blackOutAll() ; emulate start of run
      bDMXLoaded = DMX_loadCueStartDMXSave(pCuePtr)
      ; bDMXLoaded will be #True if DMX_loadCueStartDMXSave(pCuePtr) found a saved DMX array for pCuePtr in the temporary database.
      ; If that's the case then we need to use that data and not try to calculate DMX values from earlier cues.
    EndIf
  EndIf
  
  For nWorkCuePtr = 1 To (pCuePtr - 1)
    If aCue(nWorkCuePtr)\bCueEnabled
      bProcessThisCue = #True
      nActivationMethod = aCue(nWorkCuePtr)\nActivationMethod
      If nActivationMethod & #SCS_ACMETH_EXT_BIT Or nActivationMethod & #SCS_ACMETH_HK_BIT
        bProcessThisCue = #False
      Else
        Select nActivationMethod
          Case #SCS_ACMETH_CALL_CUE, #SCS_ACMETH_MTC, #SCS_ACMETH_OCM, #SCS_ACMETH_TIME
            bProcessThisCue = #False
        EndSelect
      EndIf
      If bProcessThisCue
        DMX_loadCueStartDMXSave(nWorkCuePtr) ; Added 18Jul2022 11.9.4 to cope with user have moved a controller fader prior to nWorkCuePtr
        nWorkSubPtr = aCue(nWorkCuePtr)\nFirstSubIndex
        While nWorkSubPtr >= 0
          If aSub(nWorkSubPtr)\bSubEnabled
            If aSub(nWorkSubPtr)\bSubTypeK And bDMXLoaded = #False ; See note above regarding bDMXLoaded
              If aSub(nWorkSubPtr)\bChase = #False ; Chase test added 6Nov2023 11.10.0cp because playing a chase lighting cue doesn't end
                debugMsg(sProcName, "calling playSubTypeK(" + getSubLabel(nWorkSubPtr) + ", #False, #False, #True)")
                playSubTypeK(nWorkSubPtr, #False, #False, #True)
                bRefreshGrdCues = #True
              Else
                debugMsg(sProcName, "ignoring playSubTypeK(" + getSubLabel(nWorkSubPtr) + ") because \bChase=" + strB(aSub(nWorkSubPtr)\bChase))
              EndIf
            EndIf
            If aSub(nWorkSubPtr)\bSubTypeQ
              nCallCuePtr = getCuePtr(aSub(nWorkSubPtr)\sCallCue)
              ; debugMsg(sProcName, "aSub(" + getSubLabel(nWorkSubPtr) + ")\sCallCue=" + aSub(nWorkSubPtr)\sCallCue + ", nCallCuePtr=" + getCueLabel(nCallCuePtr))
              If nCallCuePtr >= 0
                ; should be #True
                If aCue(nCallCuePtr)\bCueEnabled
                  ; debugMsg(sProcName, "aCue(" + getCueLabel(nCallCuePtr) + ")\nFirstSubIndex=" + getSubLabel(aCue(nCallCuePtr)\nFirstSubIndex))
                  nCallSubPtr = aCue(nCallCuePtr)\nFirstSubIndex
                  While nCallSubPtr >= 0
                    If aSub(nCallSubPtr)\bSubEnabled
                      If aSub(nCallSubPtr)\bSubTypeK And bDMXLoaded = #False ; See note above regarding bDMXLoaded
                        debugMsg(sProcName, "calling playSubTypeK(" + getSubLabel(nCallSubPtr) + ", #False, #False, #True)")
                        playSubTypeK(nCallSubPtr, #False, #False, #True)
                        bRefreshGrdCues = #True
                      EndIf
                    EndIf
                    nCallSubPtr = aSub(nCallSubPtr)\nNextSubIndex
                  Wend
                EndIf
              EndIf
            EndIf ; EndIf aSub(nWorkSubPtr)\bSubTypeQ
          EndIf ; EndIf aSub(nWorkSubPtr)\bSubEnabled
          nWorkSubPtr = aSub(nWorkSubPtr)\nNextSubIndex
        Wend
      EndIf ; EndIf bProcessThisCue
    EndIf ; EndIf aCue(nWorkCuePtr)\bCueEnabled
  Next nWorkCuePtr
  
  UnlockCueListMutex()
  
  gbInCalcCueStartValues = #False
  
  If bRefreshGrdCues
    samAddRequest(#SCS_SAM_REFRESH_GRDCUES, 0, 0, 0, "", ElapsedMilliseconds()+250)
  EndIf
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure ignoreRequestIfWithinDoubleClickTime(nRequestType)
  PROCNAMEC()
  Protected bIgnoreRequest
  Static qTimeOfLastRequest.q, nLastRequestType
  
  gqTimeNow = ElapsedMilliseconds()
  If nRequestType = nLastRequestType
    If (gqTimeNow - qTimeOfLastRequest) < grGeneralOptions\nDoubleClickTime
      bIgnoreRequest = #True
      ; debugMsg0(sProcName, "Ignore RequestType " + nRequestType + "; gqTimeNow=" + gqTimeNow + ", qTimeOfLastRequest=" + qTimeOfLastRequest + ", diff=" + Str(gqTimeNow - qTimeOfLastRequest) + ", DoubleClickTime=" + grGeneralOptions\nDoubleClickTime)
    Else
      ; debugMsg0(sProcName, "Accept RequestType " + nRequestType + "; gqTimeNow=" + gqTimeNow + ", qTimeOfLastRequest=" + qTimeOfLastRequest + ", diff=" + Str(gqTimeNow - qTimeOfLastRequest) + ", DoubleClickTime=" + grGeneralOptions\nDoubleClickTime)
      qTimeOfLastRequest = gqTimeNow
    EndIf
  Else
    ; typically occurs when using something like a Qu-16 programmed softkey for 'GO'
    ; debugMsg(sProcName, "Accept RequestType " + nRequestType + "; gqTimeNow=" + gqTimeNow + ", qTimeOfLastRequest=" + qTimeOfLastRequest + ", diff=" + Str(gqTimeNow - qTimeOfLastRequest) + ", DoubleClickTime=" + grGeneralOptions\nDoubleClickTime)
    qTimeOfLastRequest = gqTimeNow
    nLastRequestType = nRequestType
  EndIf
  ProcedureReturn bIgnoreRequest
EndProcedure

Procedure populateCallableCueParamArray(*rCue.tyCue)
  PROCNAMEC()
  Protected sWorkParams.s, nPartCount, nPartNo, sPart.s, sParamId.s, sParamDefault.s, nArrayIndex
  Protected bTrace = #False
  
  With *rCue
    debugMsgC0(sProcName, "\sCue=" + \sCue + ", \sCallableCueParams=" + #DQUOTE$ + \sCallableCueParams + #DQUOTE$)
    nArrayIndex = -1
    If \sCallableCueParams
      sWorkParams = Trim(\sCallableCueParams)
      nPartCount = CountString(sWorkParams, ",") + 1
      If ArraySize(\aCallableCueParam()) < (nPartCount - 1)
        ReDim \aCallableCueParam(nPartCount - 1)
      EndIf
      For nPartNo = 1 To nPartCount
        sPart = Trim(StringField(sWorkParams, nPartNo, ","))
        If sPart
          sParamId = Trim(StringField(sPart, 1, "="))
          sParamDefault = Trim(StringField(sPart, 2, "="))
          If sParamId
            nArrayIndex + 1
            \aCallableCueParam(nArrayIndex)\sCallableParamId = sParamId
            \aCallableCueParam(nArrayIndex)\sCallableParamDefault = sParamDefault
            debugMsgC0(sProcName, "*rCue\sCue=" + *rCue\sCue + ", \aCallableCueParam(" + nArrayIndex + ")\sCallableParamId=" + \aCallableCueParam(nArrayIndex)\sCallableParamId + ", \aCallableCueParam(" + nArrayIndex + ")\sCallableParamDefault=" + \aCallableCueParam(nArrayIndex)\sCallableParamDefault)
          EndIf
        EndIf
      Next nPartNo
    EndIf
    \nMaxCallableCueParam = nArrayIndex
    debugMsgC0(sProcName, "\nMaxCallableCueParam=" + \nMaxCallableCueParam)
  EndWith
EndProcedure

Procedure getCallableCueParamIndex(*rCue.tyCue, sParamId.s)
  PROCNAMEC()
  Protected nParamIndex, nArrayIndex
  
  nParamIndex = -1
  With *rCue
    For nArrayIndex = 0 To \nMaxCallableCueParam
      If UCase(\aCallableCueParam(nArrayIndex)\sCallableParamId) = UCase(sParamId)
        nParamIndex = nArrayIndex
        Break
      EndIf
    Next nArrayIndex
  EndWith
  ProcedureReturn nParamIndex
EndProcedure

Procedure.s getCallableCueParamDefault(*rCue.tyCue, sParamId.s)
  PROCNAMEC()
  Protected nArrayIndex, sParamDefault.s
  
  With *rCue
    For nArrayIndex = 0 To \nMaxCallableCueParam
      If UCase(\aCallableCueParam(nArrayIndex)\sCallableParamId) = UCase(sParamId)
        sParamDefault = \aCallableCueParam(nArrayIndex)\sCallableParamDefault
        Break
      EndIf
    Next nArrayIndex
  EndWith
  ProcedureReturn sParamDefault
EndProcedure

Procedure populateCallCueParamArray(*rSub.tySub, bPrimaryFile=#True)
  PROCNAMEC()
  Protected sWorkParams.s, nPartCount, nPartNo, sPart.s, sParamId.s, sParamValue.s, nArrayIndex, sCallCueParams.s
  Protected bReload, nCuePtr, rCue.tyCue, n
  Protected bTrace = #False
  
  With *rSub
    debugMsgC(sProcName, "\sSubLabel=" + \sSubLabel + ", bPrimaryFile=" + strB(bPrimaryFile) + ", \nCallCuePtr=" + getCueLabel(\nCallCuePtr) + ", \sCallCue=" + \sCallCue)
    nCuePtr = \nCallCuePtr
    If nCuePtr < 0
      \sCallCueParams = ""
      \nMaxCallCueParam = -1
      ProcedureReturn
    EndIf
    If bPrimaryFile
      rCue = aCue(nCuePtr)
    Else
      rCue = a2ndCue(nCuePtr)
    EndIf
    debugMsgC(sProcName, "\nMaxCallCueParam=" + \nMaxCallCueParam + ", rCue\sCue=" + rCue\sCue + ", rCue\nMaxCallableCueParam=" + rCue\nMaxCallableCueParam)
    \nMaxCallCueParam = rCue\nMaxCallableCueParam
    If ArraySize(\aCallCueParam()) < \nMaxCallCueParam
      ReDim \aCallCueParam(\nMaxCallCueParam)
    EndIf
    For n = 0 To \nMaxCallCueParam
      \aCallCueParam(n)\sCallParamId = rCue\aCallableCueParam(n)\sCallableParamId
      \aCallCueParam(n)\sCallParamValue = ""
      \aCallCueParam(n)\sCallParamDefault = rCue\aCallableCueParam(n)\sCallableParamDefault
    Next n
    
    If \sCallCueParams
      sWorkParams = Trim(\sCallCueParams)
      nPartCount = CountString(sWorkParams, ",") + 1
      For nPartNo = 1 To nPartCount
        sPart = Trim(StringField(sWorkParams, nPartNo, ","))
        If sPart
          sParamId = Trim(StringField(sPart, 1, "="))
          sParamValue = Trim(StringField(sPart, 2, "="))
          If sParamId
            For n = 0 To \nMaxCallCueParam
              If \aCallCueParam(n)\sCallParamId = sParamId
                \aCallCueParam(n)\sCallParamValue = sParamValue
                Break
              EndIf
            Next n
          EndIf
        EndIf
      Next nPartNo
    EndIf
    
    If bTrace
      debugMsg(sProcName, "rCue\sCallableCueParams=" + #DQUOTE$ + rCue\sCallableCueParams + #DQUOTE$ + ", *rSub\sCallCueParams=" + #DQUOTE$ + \sCallCueParams + #DQUOTE$)
      For n = 0 To \nMaxCallCueParam
        debugMsg(sProcName, "\aCallCueParam(" + n + ")\sCallParamId=" + \aCallCueParam(n)\sCallParamId + ", \sCallParamValue=" + \aCallCueParam(n)\sCallParamValue + ", \sCallParamDefault=" + \aCallCueParam(n)\sCallParamDefault)
      Next n
    EndIf
    
  EndWith
EndProcedure

Procedure getChangeCodeForLCAction(nLCAction)
  Protected nChangeCode
  
  Select nLCAction
    Case #SCS_LC_ACTION_FREQ
      nChangeCode = #SCS_CHANGE_FREQ
      
    Case #SCS_LC_ACTION_TEMPO
      nChangeCode = #SCS_CHANGE_TEMPO
      
    Case #SCS_LC_ACTION_PITCH
      nChangeCode = #SCS_CHANGE_PITCH
  EndSelect
  
  ProcedureReturn nChangeCode
EndProcedure

Procedure getLCActionForChangeCode(nChangeCode)
  Protected nLCAction
  
  Select nChangeCode
    Case #SCS_CHANGE_FREQ
      nLCAction = #SCS_LC_ACTION_FREQ
      
    Case #SCS_CHANGE_TEMPO
      nLCAction = #SCS_LC_ACTION_TEMPO
      
    Case #SCS_CHANGE_PITCH
      nLCAction = #SCS_LC_ACTION_PITCH
  EndSelect
  
  ProcedureReturn nLCAction
EndProcedure

Procedure getChangeCodeForAFAction(nAFAction)
  Protected nChangeCode
  
  Select nAFAction
    Case #SCS_AF_ACTION_NONE
      nChangeCode = #SCS_CHANGE_NONE
    Case #SCS_AF_ACTION_FREQ
      nChangeCode = #SCS_CHANGE_FREQ
    Case #SCS_AF_ACTION_TEMPO
      nChangeCode = #SCS_CHANGE_TEMPO
    Case #SCS_AF_ACTION_PITCH
      nChangeCode = #SCS_CHANGE_PITCH
  EndSelect
  ProcedureReturn nChangeCode
EndProcedure

Procedure getAFActionForChangeCode(nChangeCode)
  Protected nAFAction
  
  Select nChangeCode
    Case #SCS_CHANGE_NONE
      nAFAction = #SCS_AF_ACTION_NONE
    Case #SCS_CHANGE_FREQ
      nAFAction = #SCS_AF_ACTION_FREQ
    Case #SCS_CHANGE_TEMPO
      nAFAction = #SCS_AF_ACTION_TEMPO
    Case #SCS_CHANGE_PITCH
      nAFAction = #SCS_AF_ACTION_PITCH
  EndSelect
  ProcedureReturn nAFAction
EndProcedure

Procedure.f getDefaultValueForChangeCode(nChangeCode)
  Protected fDefaultValue.f
  Select nChangeCode
    Case #SCS_CHANGE_FREQ
      fDefaultValue = 1.0
    Case #SCS_CHANGE_TEMPO
      fDefaultValue = 1.0
    Case #SCS_CHANGE_TEMPO
      fDefaultValue = 0.0
  EndSelect
  ProcedureReturn fDefaultValue
EndProcedure

Procedure calcMTCStartTimeForSub(pSubPtr)
  PROCNAMECS(pSubPtr)
  Protected nCueStartMillisecondTime, nRelSubStartMillisecondTime, nCalcSubStartMillisecondTime
  Protected nHours, nMinutes, nSeconds, nMilliSeconds, nFrames, nTmpTime, nMTCMillisecondsPerFrame, dMTCMillisecondsPerFrame.d, dFrames.d
  Protected nMTCStartTimeForCue, nCalcMTCStartTimeForSub
  
  With aSub(pSubPtr)
    nMTCStartTimeForCue = aCue(\nCueIndex)\nMTCStartTimeForCue
    nCueStartMillisecondTime = convertMTCTimeToMilliseconds(nMTCStartTimeForCue, 3000)
    nRelSubStartMillisecondTime = convertMTCTimeToMilliseconds(\nRelMTCStartTimeForSub, 3000)
    nCalcSubStartMillisecondTime = nCueStartMillisecondTime + nRelSubStartMillisecondTime
    debugMsg(sProcName, "nCueStartMillisecondTime=" + nCueStartMillisecondTime + ", nRelSubStartMillisecondTime=" + nRelSubStartMillisecondTime + ", nCalcSubStartMillisecondTime=" + nCalcSubStartMillisecondTime)
    nHours = nCalcSubStartMillisecondTime / 3600000
    nTmpTime = nCalcSubStartMillisecondTime - (nHours * 3600000)
    nMinutes = nTmpTime / 60000
    nTmpTime - (nMinutes * 60000)
    nSeconds = nTmpTime / 1000
    nMilliSeconds = nTmpTime - (nSeconds * 1000)
    debugMsg(sProcName, "nHours=" + nHours + ", nMinutes=" + nMinutes + ", nSeconds=" + nSeconds + ", nTmpTime=" + nTmpTime + ", nMilliSeconds=" + nMilliSeconds)
    ; initially just apply a 30fps frame rate
    nMTCMillisecondsPerFrame = -1
    dMTCMillisecondsPerFrame = 1000.0 / 30.0
    ; end of 'initially...' code
    ; debugMsg(sProcName, "\nMTCMillisecondsPerFrame=" + \nMTCMillisecondsPerFrame + ", \dMTCMillisecondsPerFrame=" + StrD(\dMTCMillisecondsPerFrame,4) + ", \nMTCFrameRate=" + \nMTCFrameRate + ", \nMTCFrameRateX100=" + \nMTCFrameRateX100)
    If nMTCMillisecondsPerFrame > 0
      nFrames = nMilliSeconds / nMTCMillisecondsPerFrame
    Else
      dFrames = Round(nMilliSeconds / dMTCMillisecondsPerFrame, #PB_Round_Down)
      nFrames = dFrames
      debugMsg(sProcName, "dFrames=" + StrD(dFrames,4) + ", nTmpTime=" + nTmpTime + ", nSeconds=" + nSeconds + ", nMilliSeconds=" + nMilliSeconds + ", nFrames=" + nFrames)
    EndIf
    nCalcMTCStartTimeForSub = (nHours << 24) | (nMinutes << 16) | (nSeconds << 8) | nFrames
    ; debugMsg(sProcName, "nMTCStartTimeForCue=" + nMTCStartTimeForCue + ", \nRelMTCStartTimeForSub=" + \nRelMTCStartTimeForSub + ", nCalcMTCStartTimeForSub=" + nCalcMTCStartTimeForSub)
    debugMsg(sProcName, "nMTCStartTimeForCue=" + decodeMTCTime(nMTCStartTimeForCue) + ", \nRelMTCStartTimeForSub=" + decodeMTCTime(\nRelMTCStartTimeForSub) + ", nCalcMTCStartTimeForSub=" + decodeMTCTime(nCalcMTCStartTimeForSub))
  EndWith
  ProcedureReturn nCalcMTCStartTimeForSub
  
EndProcedure

Procedure setMTCStartTimesForCueSubs(pCuePtr)
  PROCNAMECQ(pCuePtr)
  Protected j
  
  ; NB do NOT check the 'enabled' state of the cue or sub-cues
  
  If aCue(pCuePtr)\nActivationMethod = #SCS_ACMETH_MTC
    j = aCue(pCuePtr)\nFirstSubIndex
    While j >= 0
      If aSub(j)\nSubStart = #SCS_SUBSTART_REL_MTC
        aSub(j)\nCalcMTCStartTimeForSub = calcMTCStartTimeForSub(j)
        If j = nEditSubPtr
          SUB_setRelMTCStartTimeForSubToolTip(aSub(j)\sSubType)
        EndIf
      EndIf
      j = aSub(j)\nNextSubIndex
    Wend
  EndIf
  
EndProcedure

Procedure setTempoEtcConstants(nChangeCode)
  PROCNAMEC()
  With grTempoEtc
    \nTempoEtcCurrChangeCode = nChangeCode
    Select nChangeCode
      Case #SCS_CHANGE_FREQ, #SCS_CHANGE_NONE
        \nTempoEtcDecimals = 2
        \fTempoEtcFactor = 100.0
        \fTempoEtcMinValue = 0.05
        \fTempoEtcMaxValue = 5.0
        \fTempoEtcDefaultValue = 1.0
        \nTempoEtcDefaultSliderValue = 100
      Case #SCS_CHANGE_TEMPO
        \nTempoEtcDecimals = 2
        \fTempoEtcFactor = 100.0
        \fTempoEtcMinValue = 0.05
        \fTempoEtcMaxValue = 5.0
        \fTempoEtcDefaultValue = 1.0
        \nTempoEtcDefaultSliderValue = 100
      Case #SCS_CHANGE_PITCH
        \nTempoEtcDecimals = 1
        \fTempoEtcFactor = 10.0
        \fTempoEtcMinValue = -60.0
        \fTempoEtcMaxValue = 60.0
        \fTempoEtcDefaultValue = 0.0
        \nTempoEtcDefaultSliderValue = 0
    EndSelect
    debugMsg(sProcName, "nChangeCode=" + decodeChangeCode(nChangeCode) + ", \fTempoEtcMinValue=" + StrF(\fTempoEtcMinValue, \nTempoEtcDecimals) + ", \fTempoEtcMaxValue=" + StrF(\fTempoEtcMaxValue, \nTempoEtcDecimals))
  EndWith
EndProcedure

Procedure checkTempoEtcUsable()
  PROCNAMEC()
  Protected bUsable, sMsg.s
  Static bWarningDisplayed
  
  If gbUseBASSMixer Or gbUseSMS
    bUsable = #True
  Else
    If bWarningDisplayed = #False
      sMsg = Lang("Misc", "TempoEtcReopen")
      scsMessageRequester(grProd\sTitle, sMsg, #PB_MessageRequester_Warning)
      bWarningDisplayed = #True
    EndIf
  EndIf
  ProcedureReturn bUsable
  
EndProcedure

Procedure getValueForNumericParameter(*rSub.tySub, nSubValue, sSubCallCueParamId.s, nParameterDecimals=0, pCallCueSubPtr=-1)
  ; NOTE: Currently only used for DMX fade times
  PROCNAMEC()
  Protected nReqdValue, nCuePtr, n, nCalledBySubPtr, sValue.s, fFloat.f
  Protected bTrace = #False
  Protected sReqdValue.s
  
  debugMsgC(sProcName, #SCS_START + ", *rSub\sSubLabel=" + *rSub\sSubLabel + ", nSubValue=" + nSubValue + ", sSubCallCueParamId=" + sSubCallCueParamId + ", nParameterDecimals=" + nParameterDecimals + ", pCallCueSubPtr=" + getSubLabel(pCallCueSubPtr))
  If sSubCallCueParamId
    nReqdValue = nSubValue
    nCuePtr = *rSub\nCueIndex
    debugMsgC(sProcName, "nCuePtr=" + getCueLabel(nCuePtr))
    If nCuePtr >= 0
      If pCallCueSubPtr >= 0
        nCalledBySubPtr = pCallCueSubPtr
      Else
        nCalledBySubPtr = aCue(nCuePtr)\nCalledBySubPtr
      EndIf
      debugMsgC(sProcName, "nCalledBySubPtr=" + getSubLabel(nCalledBySubPtr))
      If nCalledBySubPtr >= 0
        With aSub(nCalledBySubPtr)
          For n = 0 To \nMaxCallCueParam
            If LCase(\aCallCueParam(n)\sCallParamId) = LCase(sSubCallCueParamId) ; ignore case
              debugMsgC(sProcName, "\aCallCueParam(" + n + ")\sCallParamId=" + \aCallCueParam(n)\sCallParamId + ", \sCallParamValue=" + \aCallCueParam(n)\sCallParamValue + ", \sCallParamDefault=" + \aCallCueParam(n)\sCallParamDefault)
              If \aCallCueParam(n)\sCallParamValue
                sValue = \aCallCueParam(n)\sCallParamValue
              Else
                sValue = \aCallCueParam(n)\sCallParamDefault
              EndIf
              macReadNumericOrStringParam(sValue, sReqdValue, nReqdValue, 0, #True)
              Break
            EndIf
          Next n
        EndWith
      EndIf ; EndIf nCalledBySubPtr >= 0
    EndIf ; EndIf nCuePtr >= 0
    
  Else ; sSubCallCueParamId is blank
    nReqdValue = nSubValue
    
  EndIf ; EndIf sSubCallCueParamId
  debugMsgC(sProcName, #SCS_END + ", returning nReqdValue=" + nReqdValue)
  ProcedureReturn nReqdValue
EndProcedure

Procedure isNumericValueACallCueParamId(sValue.s, pSubPtr)
  PROCNAMECS(pSubPtr)
  Protected nResult, sChar.s, nCuePtr, n
  Protected sValidFirstChar.s = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
  
  sChar = Left(sValue, 1)
  If FindString(sValidFirstChar, sChar, 1, #PB_String_NoCase)
    nResult = -1
    nCuePtr = aSub(pSubPtr)\nCueIndex
    With aCue(nCuePtr)
      ; debugMsg0(sProcName, "aCue(" + getCueLabel(nCuePtr) + ")\nActivationMethod=" + \nActivationMethod)
      If \nActivationMethod = #SCS_ACMETH_CALL_CUE
        ; debugMsg0(sProcName, "\sCallableCueParams=" + \sCallableCueParams + ", \nMaxCallableCueParam=" + \nMaxCallableCueParam)
        For n = 0 To \nMaxCallableCueParam
          If UCase(\aCallableCueParam(n)\sCallableParamId) = UCase(sValue)
            nResult = 1
            Break
          EndIf
        Next n
      EndIf
    EndWith
  EndIf
  
  ; nResult values:
  ;   0 - sValue is not a call cue parameter, ie it doesn't start with A-Z or a-z
  ;   1 - sValue is a call cue parameter that was found in the parent cue's parameter list
  ;  -1 - sValue looks like a call cue parameter but it does not exist in the parent cue's parameter list
  ProcedureReturn nResult

EndProcedure

Procedure.s makeDisplayTimeValue(sTimeValue.s, nTimeValue)
  ; For time values in hundredths of a second
  Protected sDisplayTime.s
  
  If sTimeValue
    sDisplayTime = sTimeValue
  Else
    sDisplayTime = timeToString(nTimeValue)
  EndIf
  ProcedureReturn sDisplayTime
EndProcedure

Procedure.s makeDisplayTimeValueD(sTimeValue.s, nTimeValue)
  ; For time values in tenths of a second
  Protected sDisplayTime.s
  
  If sTimeValue
    sDisplayTime = sTimeValue
  Else
    sDisplayTime = timeToStringD(nTimeValue)
  EndIf
  ProcedureReturn sDisplayTime
EndProcedure

Procedure.s makeDisplayTimeValueT(sTimeValue.s, nTimeValue)
  ; For time values in thousandths of a second (milliseconds)
  Protected sDisplayTime.s
  
  If sTimeValue
    sDisplayTime = sTimeValue
  Else
    sDisplayTime = timeToStringT(nTimeValue)
  EndIf
  ProcedureReturn sDisplayTime
EndProcedure

Procedure.s makeDisplayTimeValueBWZT(sTimeValue.s, nTimeValue)
  ; For time values in thousandths of a second (milliseconds) - but blank when zero
  Protected sDisplayTime.s
  
  If sTimeValue
    sDisplayTime = sTimeValue
  Else
    sDisplayTime = timeToStringBWZT(nTimeValue)
  EndIf
  ProcedureReturn sDisplayTime
EndProcedure

Procedure applyCallCueParameters(nSubPtr)
  ; Called exclusively from playSubTypeQ(), ie when playing a 'Call Cue' sub-cue.
  ; Not to be confused with the procedure WEC_applyCallableCueParams() in fmEditCue.pbi which is called
  ; when the user edits the callable cue parameters of a cue with an activation method of 'Callable Cue'.
  PROCNAMECS(nSubPtr)
  Protected i, j, k
  Protected nParamIndex, nMaxParamIndex
  Protected sCallParamId.s, sCallParamValue.s, sCallParamDefault.s
  Protected fFloat.f, nTimeValue, nNumericValue, bAudChanged
  Protected nLvlChgIndex, nCtrlSendIndex
  Protected nColonPtr, sMinutes.s, sSeconds.s 
  
  debugMsg(sProcName, #SCS_START)
  
  populateCallCueParamArray(@aSub(nSubPtr))
  
  nMaxParamIndex = aSub(nSubPtr)\nMaxCallCueParam
  If nMaxParamIndex >= 0
    i = aSub(nSubPtr)\nCallCuePtr
    If i >= 0
      j = aCue(i)\nFirstSubIndex
      While j >= 0
        With aSub(j)
          If \bSubEnabled
            If FindString("FKLMS", \sSubType) > 0 ; subtypes that currently support callable cue parameter substitution
              For nParamIndex = 0 To nMaxParamIndex
                sCallParamId = aSub(nSubPtr)\aCallCueParam(nParamIndex)\sCallParamId
                sCallParamValue = aSub(nSubPtr)\aCallCueParam(nParamIndex)\sCallParamValue
                sCallParamDefault = aSub(nSubPtr)\aCallCueParam(nParamIndex)\sCallParamDefault
                If sCallParamValue = ""
                  sCallParamValue = sCallParamDefault
                EndIf
                If IsNumeric(sCallParamValue)
                  fFloat = ValF(sCallParamValue) * 1000
                  nTimeValue = Int(fFloat) ; for time values (eg fade-in times)
                  nNumericValue = Val(sCallParamValue) ; for numeric values (eg MIDI values)
                ElseIf CountString(sCallParamValue, ":") = 1
                  ; Added 30Jan2024 11.10.2ad
                  nColonPtr = FindString(sCallParamValue, ":", 1)
                  sMinutes = Left(sCallParamValue, nColonPtr - 1)
                  sSeconds = Right(sCallParamValue, Len(sCallParamValue) - nColonPtr)
                  nNumericValue = (ValD(sMinutes) * 60) + ValD(sSeconds)
                  nTimeValue = nNumericValue * 1000
                  ; End added 30Jan2024 11.10.2ad
                Else
                  Continue ; If sCallParamValue is not numeric and not a time value with minutes then no need to proceed further within the current iteration of the loop
                EndIf
                If \bSubTypeF
                  ;{
                  k = \nFirstAudIndex
                  If k >= 0
                    bAudChanged = #False
                    If aAud(k)\sFadeInTime = sCallParamId
                      If nTimeValue >= 0 And nTimeValue < aAud(k)\nCueDuration
                        If nTimeValue = 0 : nTimeValue = 1 : EndIf ; 1 millisecond as level points must have >0 times
                        aAud(k)\nFadeInTime = nTimeValue
                        ; debugMsg(sProcName, "aAud(" + getAudLabel(k) + ")\nFadeInTime=" + aAud(k)\nFadeInTime)
                        bAudChanged = #True
                      EndIf
                    EndIf
                    If aAud(k)\sFadeOutTime = sCallParamId
                      If nTimeValue >= 0 And nTimeValue < aAud(k)\nCueDuration
                        If nTimeValue = 0 : nTimeValue = 1 : EndIf ; 1 millisecond as level points must have >0 times
                        aAud(k)\nFadeOutTime = nTimeValue
                        bAudChanged = #True
                      EndIf
                    EndIf
                    If bAudChanged
                      setDerivedLevelPointInfo2(k)
                      loadLvlPtRun(k, aAud(k)\nCuePos, #False)
                    EndIf
                  EndIf
                  ;}
                ElseIf \bSubTypeK
                  ;{
                  Select \nLTEntryType
                      ; no need to check for 'user-defined action' in the following
                    Case #SCS_LT_ENTRY_TYPE_BLACKOUT
                      If \sLTBLFadeUserTime = sCallParamId : \nLTBLFadeUserTime = nTimeValue : EndIf
                    Case #SCS_LT_ENTRY_TYPE_DMX_CAPTURE_SEQ
                      ; no parameters
                    Case #SCS_LT_ENTRY_TYPE_DMX_CAPTURE_SNAP
                      If \sLTDCFadeUpUserTime = sCallParamId : \nLTDCFadeUpUserTime = nTimeValue : EndIf
                      If \sLTDCFadeDownUserTime = sCallParamId : \nLTDCFadeDownUserTime = nTimeValue : EndIf
                      If \sLTDCFadeOutOthersUserTime = sCallParamId : \nLTDCFadeOutOthersUserTime = nTimeValue : EndIf
                    Case #SCS_LT_ENTRY_TYPE_DMX_ITEMS
                      If \sLTDIFadeUpUserTime = sCallParamId : \nLTDIFadeUpUserTime = nTimeValue : EndIf
                      If \sLTDIFadeDownUserTime = sCallParamId : \nLTDIFadeDownUserTime = nTimeValue : EndIf
                      If \sLTDIFadeOutOthersUserTime = sCallParamId : \nLTDIFadeOutOthersUserTime = nTimeValue : EndIf
                    Case #SCS_LT_ENTRY_TYPE_FIXTURE_ITEMS
                      If \sLTFIFadeUpUserTime = sCallParamId : \nLTFIFadeUpUserTime = nTimeValue : EndIf
                      If \sLTFIFadeUpUserTime = sCallParamId : \nLTFIFadeUpUserTime = nTimeValue : EndIf
                      If \sLTFIFadeUpUserTime = sCallParamId : \nLTFIFadeUpUserTime = nTimeValue : EndIf
                  EndSelect
                  ;}
                ElseIf \bSubTypeL
                  ;{
                  For nLvlChgIndex = 0 To #SCS_MAX_AUDIO_DEV_PER_AUD_OR_SUB
                    If \sLCTime[nLvlChgIndex] = sCallParamId : \nLCTime[nLvlChgIndex] = nTimeValue : EndIf
                  Next nLvlChgIndex
                  ;}
                ElseIf \bSubTypeM
                  ;{
                  For nCtrlSendIndex = 0 To #SCS_MAX_CTRL_SEND
                    ; no need to check \nMSMsgType in the following
                    If \aCtrlSend[nCtrlSendIndex]\sMSParam1 = sCallParamId : \aCtrlSend[nCtrlSendIndex]\nMSParam1 = nNumericValue : EndIf
                    If \aCtrlSend[nCtrlSendIndex]\sMSParam2 = sCallParamId : \aCtrlSend[nCtrlSendIndex]\nMSParam2 = nNumericValue : EndIf
                    If \aCtrlSend[nCtrlSendIndex]\sMSParam3 = sCallParamId : \aCtrlSend[nCtrlSendIndex]\nMSParam3 = nNumericValue : EndIf
                    If \aCtrlSend[nCtrlSendIndex]\sMSParam4 = sCallParamId : \aCtrlSend[nCtrlSendIndex]\nMSParam4 = nNumericValue : EndIf
                  Next nCtrlSendIndex
                  ;}
                ElseIf \bSubTypeS
                  ;{
                  If \sSFRTimeOverride = sCallParamId : \nSFRTimeOverride = nTimeValue : EndIf
                  ;}
                EndIf
              Next nParamIndex
            EndIf
          EndIf
          j = \nNextSubIndex
        EndWith
      Wend
    EndIf
  EndIf
  
  ; debugMsg(sProcName, "calling debugCuePtrs(" + getCueLabel(i) + ")")
  ; debugCuePtrs(i)
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure setOrClearGadgetValidValuesFlag()
  Protected nGadgetPropsIndex
  
  nGadgetPropsIndex = getGadgetPropsIndex(gnEventGadgetNo)
  If aCue(nEditCuePtr)\bCallableCue Or gaGadgetProps(nGadgetPropsIndex)\sValidChars = ""
    ; If sub-cue of a callable cue then the numeric list of valid chars IS NOT to be applied as the field may contain a parameter label
    gaGadgetProps(nGadgetPropsIndex)\bValidCharsPresent = #False
  Else
    ; If sub-cue of a callable cue then the numeric list of valid chars IS to be applied as the field may not contain a parameter label
    gaGadgetProps(nGadgetPropsIndex)\bValidCharsPresent = #True
  EndIf
  
EndProcedure

Procedure.s makeShortDescr(sLabel.s, sDescr.s, nMaxLength=20)
  Protected sShortDescr.s
  
  sShortDescr = sDescr ; will be cue or sub-cue description, or file title
  If Len(sShortDescr) > nMaxLength
    sShortDescr = Trim(Left(sShortDescr, nMaxLength-3)) + "..."
  EndIf
  sShortDescr = sLabel + " (" + sShortDescr + ")"
  ProcedureReturn sShortDescr

EndProcedure

Procedure getPLRepeatActive(pSubPtr)
  Protected bPLRepeatActive
  
  If aSub(pSubPtr)\bPLRepeat
    If aSub(pSubPtr)\bPLRepeatCancelled = #False
      bPLRepeatActive = #True
    EndIf
  EndIf
  ProcedureReturn bPLRepeatActive
EndProcedure

; EOF