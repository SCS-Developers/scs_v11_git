; File: gapless.pbi

EnableExplicit

Procedure listGaplessArray()
  PROCNAMEC()
  Protected nGaplessSeqPtr
  
  ; debugMsg(sProcName, #SCS_START + ", gnGaplessSeqCount=" + gnGaplessSeqCount)
  For nGaplessSeqPtr = 0 To (gnGaplessSeqCount-1)
    With gaGaplessSeqs(nGaplessSeqPtr)
      debugMsg(sProcName, "gaGaplessSeqs(" + nGaplessSeqPtr + ")\nGaplessStream=" + decodeHandle(\nGaplessStream) + ", \nSyncHandle=" + decodeHandle(\nSyncHandle) +
                          ", \nFirstGaplessAudPtr=" + getAudLabel(\nFirstGaplessAudPtr) +
                          ", \nLastGaplessAudPtr=" + getAudLabel(\nLastGaplessAudPtr) +
                          ", \nCurrGaplessAudPtr=" + getAudLabel(\nCurrGaplessAudPtr))
    EndWith
  Next nGaplessSeqPtr
  
EndProcedure

Procedure setGaplessInfo()
  PROCNAMEC()
  Protected i, j, k
  Protected nGaplessSeqPtr
  Protected Dim bCheckCue(0)
  Protected Dim bCueEligible(0)
  Protected Dim nAutoActCuePtr(0)
  Protected Dim nCueGaplessSeqNo(0)
  Protected Dim nCueOutputScreen(0)
  Protected Dim nCueAudDevMask(0)
  Protected Dim nCuePassForCheck(0)
  Protected Dim bOrigUseGaplessStream(0)
  Protected Dim nOrigGaplessSeqPtr(0)
  Protected Dim nOrigAutoFollowAudPtr(0)
  Protected bThisCueEligible
  Protected nSubTypeACount
  Protected nSubTypeFCount
  Protected bCheckThisCue
  Protected nGaplessSeqNo
  Protected bFirstInGaplessSeq
  Protected nGaplessSeqOutputScreen
  Protected nPrevCueInGaplessSeq
  Protected nThisGaplessSeqNo
  Protected nPrevGaplessAudPtr
  Protected nCueCount
  Protected nFileChannels
  Protected nPassNo, nMaxPassNo
  Protected nThisCueOutputScreen
  Protected nThisCueAudDevMask
  Protected nThisAutoActCuePtr
  Protected bGaplessInfoChanged
  Protected bVideoXFadeFound
  Protected nVideoCount, nImageCount
  Protected nAudPtr
  
  debugMsg(sProcName, #SCS_START)
  
  If grLicInfo\nLicLevel < #SCS_LIC_STD
    ; gapless only available in SCS Standard and higher
    ProcedureReturn
  EndIf
  
  If (gnLastCue < 0) Or (gnLastSub < 0) Or (gnLastAud < 0)
    debugMsg(sProcName, "exiting - gnLastCue=" + getCueLabel(gnLastCue) + ", gnLastSub=" + getSubLabel(gnLastSub) + ", gnLastAud=" + getAudLabel(gnLastAud))
    ProcedureReturn
  EndIf
  
  debugMsg(sProcName, "calling checkForMajorChangesInEditor()")
  checkForMajorChangesInEditor()
  
  ReDim bOrigUseGaplessStream(gnLastAud)
  ReDim nOrigGaplessSeqPtr(gnLastAud)
  ReDim nOrigAutoFollowAudPtr(gnLastAud)
  For k = 1 To gnLastAud
    bOrigUseGaplessStream(k) = aAud(k)\bAudUseGaplessStream
    nOrigGaplessSeqPtr(k) = aAud(k)\nAudGaplessSeqPtr
    nOrigAutoFollowAudPtr(k) = aAud(k)\nAutoFollowAudPtr
  Next k
  
  ; phase 1: clear gapless info where applicable
  debugMsg(sProcName, "phase 1")
  ReDim bCheckCue(gnLastCue)
  For i = 1 To gnLastCue
    bCheckThisCue = #True
    If aCue(i)\nCueState > #SCS_CUE_READY
      bCheckThisCue = #False
      ; debugMsg(sProcName, "aCue(" + getCueLabel(i) + ")\nCueState=" + decodeCueState(aCue(i)\nCueState))
    Else
      ; debugMsg(sProcName, "aCue(" + getCueLabel(i) + ")\bCueContainsGapless=" + strB(aCue(i)\bCueContainsGapless))
      If aCue(i)\bCueContainsGapless
        j = aCue(i)\nFirstSubIndex
        While j >= 0
          If (aSub(j)\bSubEnabled) And (aSub(j)\bSubTypeHasAuds)
            If (aSub(j)\bSubTypeP) And (aSub(j)\bPLSavePos)
              bCheckThisCue = #False
              Break
            Else
              ; debugMsg(sProcName, "aSub(" + getSubLabel(j) + ")\nGaplessSeqPtr=" + aSub(j)\nSubGaplessSeqPtr)
              nGaplessSeqPtr = aSub(j)\nSubGaplessSeqPtr
              If nGaplessSeqPtr >= 0
                ; debugMsg(sProcName, "gaGaplessSeqs(" + nGaplessSeqPtr + ")\nCurrGaplessAudPtr=" + getAudLabel(gaGaplessSeqs(nGaplessSeqPtr)\nCurrGaplessAudPtr))
                nAudPtr = gaGaplessSeqs(nGaplessSeqPtr)\nCurrGaplessAudPtr
                If nAudPtr >= 0
                  If (aAud(nAudPtr)\nAudState >= #SCS_CUE_FADING_IN) And (aAud(nAudPtr)\nAudState <= #SCS_CUE_FADING_OUT)
                    ; another Aud in this gapless sequence is currently playing, so exclude this cue from further checks
                    bCheckThisCue = #False
                    Break
                  EndIf
                EndIf
              EndIf
            EndIf
          EndIf
          j = aSub(j)\nNextSubIndex
        Wend
      EndIf
    EndIf
    
    bCheckCue(i) = bCheckThisCue
    ; debugMsg(sProcName, "i=" + getCueLabel(i) + ", bCheckThisCue=" + strB(bCheckThisCue))
    
    If bCheckThisCue
      j = aCue(i)\nFirstSubIndex
      While j >= 0
        If (aSub(j)\bSubEnabled) And (aSub(j)\bSubTypeHasAuds)
          If aSub(j)\nSubGaplessSeqPtr >= 0
            If grMMedia\nCurrGaplessSeqPtr = aSub(j)\nSubGaplessSeqPtr
              grMMedia\nCurrGaplessSeqPtr = -1
              ; debugMsg(sProcName, "grMMedia\nCurrGaplessSeqPtr=" + grMMedia\nCurrGaplessSeqPtr)
            EndIf
          EndIf
          k = aSub(j)\nFirstAudIndex
          If k >= 0
            aAud(k)\bAudUseGaplessStream = grAudDef\bAudUseGaplessStream
            aAud(k)\nAudGaplessSeqPtr = grAudDef\nAudGaplessSeqPtr
            aAud(k)\nAutoFollowAudPtr = grAudDef\nAutoFollowAudPtr
          EndIf
          aSub(j)\nSubGaplessSeqPtr = grSubDef\nSubGaplessSeqPtr
        EndIf
        aSub(j)\bSubContainsGapless = #False
        j = aSub(j)\nNextSubIndex
      Wend
      aCue(i)\bCueContainsGapless = #False
    EndIf
  Next i
  
  ; phase 2: check cues containing just one audio file sub-cue or just one video/image sub-cue
  ; debugMsg(sProcName, "phase 2")
  ReDim bCueEligible(gnLastCue)
  ReDim nAutoActCuePtr(gnLastCue)
  ReDim nCueGaplessSeqNo(gnLastCue)
  ReDim nCueOutputScreen(gnLastCue)
  ReDim nCueAudDevMask(gnLastCue)
  ReDim nCuePassForCheck(gnLastCue)
  
  nMaxPassNo = 1
  For i = 1 To gnLastCue
    If bCheckCue(i)
      nAutoActCuePtr(i) = -1
      nThisCueOutputScreen = 0
      nThisCueAudDevMask = 0
      If aCue(i)\bCueCurrentlyEnabled
        If aCue(i)\bSubTypeA
          j = aCue(i)\nFirstSubIndex
          While j >= 0
            If (aSub(j)\bSubTypeA) And (aSub(j)\bSubEnabled)
              If nThisCueOutputScreen = 0
                nThisCueOutputScreen = aSub(j)\nOutputScreen
              ElseIf aSub(j)\nOutputScreen <> nThisCueOutputScreen
                nThisCueOutputScreen = -1
              EndIf
            EndIf
            j = aSub(j)\nNextSubIndex
          Wend
        EndIf
        If aCue(i)\bSubTypeF
          nThisCueAudDevMask = buildAudDevMaskForCue(i)
        EndIf
      EndIf
      nCueOutputScreen(i) = nThisCueOutputScreen
      nCueAudDevMask(i) = nThisCueAudDevMask
      ; 0 if no video/image sub in cue
      ; -1 if video/image subs use different output screens
      ; nOutputScreen if all (or only) video subs use the same nOutputScreen
      If nThisCueOutputScreen < 2
        nCuePassForCheck(i) = 1
      Else
        nCuePassForCheck(i) = nThisCueOutputScreen
        If nCuePassForCheck(i) > nMaxPassNo
          nMaxPassNo = nCuePassForCheck(i)
        EndIf
      EndIf
      ; debugMsg(sProcName, "nCueOutputScreen(" + getCueLabel(i) + ")=" + nCueOutputScreen(i) + ", nCuePassForCheck(" + getCueLabel(i) + ")=" + nCuePassForCheck(i))
    EndIf
  Next i
  
;   ; NOTE ADDED
;   For i = 1 To gnLastCue
;     nCueGaplessSeqNo(i) = -1
;   Next i
;   ; NOTE END ADDED
  
  For nPassNo = 1 To nMaxPassNo
    debugMsg(sProcName, ">>> nPassNo=" + nPassNo)
    For i = 1 To gnLastCue
      If bCheckCue(i)
        If nCuePassForCheck(i) = nPassNo
          ; nAutoActCuePtr(i) = -1
          bThisCueEligible = #False
          ; debugMsg(sProcName, "a i=" + getCueLabel(i) + ", bThisCueEligible=" + strB(bThisCueEligible))
          bFirstInGaplessSeq = #False
          nPrevCueInGaplessSeq = -1
          nSubTypeACount = 0
          nSubTypeFCount = 0
          If aCue(i)\bCueCurrentlyEnabled ; And aCue(i)\nCueState < #SCS_CUE_COMPLETED
            ; debugMsg(sProcName,  "aCue(" + getCueLabel(i) + ")\nActivationMethodReqd=" + decodeActivationMethod(aCue(i)\nActivationMethodReqd))
            Select aCue(i)\nActivationMethodReqd
              Case #SCS_ACMETH_MAN, #SCS_ACMETH_MAN_PLUS_CONF, #SCS_ACMETH_TIME
                bThisCueEligible = #True
                ; debugMsg(sProcName, "b i=" + getCueLabel(i) + ", bThisCueEligible=" + strB(bThisCueEligible))
                bFirstInGaplessSeq = #True
              Case #SCS_ACMETH_AUTO, #SCS_ACMETH_AUTO_PLUS_CONF
                ; debugMsg(sProcName,  "aCue(" + getCueLabel(i) + ")\nAutoActPosn=" + decodeAutoActPosn(aCue(i)\nAutoActPosn))
                Select aCue(i)\nAutoActPosn
                  Case #SCS_ACPOSN_LOAD
                    bThisCueEligible = #True
                    ; debugMsg(sProcName, "c i=" + getCueLabel(i) + ", bThisCueEligible=" + strB(bThisCueEligible))
                    bFirstInGaplessSeq = #True
                  Case #SCS_ACPOSN_AE, #SCS_ACPOSN_BE
                    ; debugMsg(sProcName,  "aCue(" + getCueLabel(i) + ")\nAutoActCuePtr=" + getCueLabel(aCue(i)\nAutoActCuePtr) + ", \nAutoActTime=" + aCue(i)\nAutoActTime)
                    nAutoActCuePtr(i) = aCue(i)\nAutoActCuePtr
                    nThisAutoActCuePtr = nAutoActCuePtr(i)
                    If nThisAutoActCuePtr >= 0
                      ; debugMsg(sProcName, "nCueOutputScreen(" + getCueLabel(i) + ")=" + nCueOutputScreen(i) + ", nCueOutputScreen(" + getCueLabel(nThisAutoActCuePtr) + ")=" + nCueOutputScreen(nThisAutoActCuePtr) +
                      ;                     ", nCueAudDevMask(" + getCueLabel(i) + ")=" + nCueAudDevMask(i) + ", nCueAudDevMask(" + getCueLabel(nThisAutoActCuePtr) + ")=" + nCueAudDevMask(nThisAutoActCuePtr))
                      If (aCue(i)\nAutoActTime = 0) And (nCueOutputScreen(i) = nCueOutputScreen(nThisAutoActCuePtr)) And (nCueAudDevMask(i) = nCueAudDevMask(nThisAutoActCuePtr))
                        bThisCueEligible = #True
                        ; debugMsg(sProcName, "d i=" + getCueLabel(i) + ", bThisCueEligible=" + strB(bThisCueEligible))
                        nPrevCueInGaplessSeq = aCue(i)\nAutoActCuePtr
                      EndIf
                    EndIf
                  Case #SCS_ACPOSN_AS, #SCS_ACPOSN_DEFAULT
                    ; debugMsg(sProcName,  "aCue(" + getCueLabel(i) + ")\nAutoActCuePtr=" + getCueLabel(aCue(i)\nAutoActCuePtr))
                    nAutoActCuePtr(i) = aCue(i)\nAutoActCuePtr
                EndSelect
            EndSelect
            ; debugMsg(sProcName, "i=" + getCueLabel(i) + ", bThisCueEligible=" + strB(bThisCueEligible) + ", aCue(" + getCueLabel(i) + ")\nCueState=" + decodeCueState(aCue(i)\nCueState))
            j = aCue(i)\nFirstSubIndex
            While (j >= 0) And (bThisCueEligible)
              If aSub(j)\bSubEnabled
                nVideoCount = 0
                nImageCount = 0
                bVideoXFadeFound = #False
                If (aSub(j)\bSubTypeAorF) And (aSub(j)\nAudCount = 1)
                  If aSub(j)\bSubTypeA
                    nSubTypeACount + 1
                    If nSubTypeACount > 1
                      If (aSub(j)\nRelStartMode <> #SCS_RELSTART_AE_PREV_SUB) Or (aSub(j)\nRelStartTime > 0)
                        bThisCueEligible = #False
                        ; debugMsg(sProcName, "f i=" + getCueLabel(i) + ", bThisCueEligible=" + strB(bThisCueEligible))
                      EndIf
                    EndIf
                  EndIf
                  If aSub(j)\bSubTypeF
                    nSubTypeFCount + 1
                    If gbUseBASSMixer = #False
                      bThisCueEligible = #False
                      ; debugMsg(sProcName, "h i=" + getCueLabel(i) + ", bThisCueEligible=" + strB(bThisCueEligible))
                    EndIf
                    If nSubTypeFCount > 1
                      If (aSub(j)\nRelStartMode <> #SCS_RELSTART_AE_PREV_SUB) Or (aSub(j)\nRelStartTime > 0)
                        bThisCueEligible = #False
                        ; debugMsg(sProcName, "j i=" + getCueLabel(i) + ", bThisCueEligible=" + strB(bThisCueEligible))
                      EndIf
                    EndIf
                  EndIf
                  If (nSubTypeACount > 0) And (nSubTypeFCount > 0)
                    bThisCueEligible = #False
                    ; debugMsg(sProcName, "k i=" + getCueLabel(i) + ", bThisCueEligible=" + strB(bThisCueEligible))
                  EndIf
                  If bThisCueEligible
                    k = aSub(j)\nFirstAudIndex
                    If k >= 0
                      While k >= 0
                        With aAud(k)
                          If \bAudTypeForP
                            If (\nAbsStartAt > 0) Or (\nAbsEndAt < (\nFileDuration - 1)) Or (\nFadeInTime > 0) Or (\nFadeOutTime > 0)
                              bThisCueEligible = #False
                              ; debugMsg(sProcName, "l i=" + getCueLabel(i) + ", bThisCueEligible=" + strB(bThisCueEligible))
                              Break
                            EndIf
                            If \bAudTypeF
                              If \nMaxLoopInfo >= 0
                                bThisCueEligible = #False
                                ; debugMsg(sProcName, "i=" + getCueLabel(i) + ", \nMaxLoopInfo=" + \nMaxLoopInfo + ", bThisCueEligible=" + strB(bThisCueEligible))
                                Break
                              EndIf
                            EndIf
                          ElseIf \bAudTypeA
                            Select \nFileFormat
                              Case #SCS_FILEFORMAT_PICTURE
                                nImageCount + 1
                              Case #SCS_FILEFORMAT_VIDEO
                                nVideoCount + 1
                                If (\nPLTransType = #SCS_TRANS_XFADE) And (\nPLTransTime > 0)
                                  bVideoXFadeFound = #True
                                EndIf
                              Default
                                bThisCueEligible = #False
                                ; debugMsg(sProcName, "m i=" + getCueLabel(i) + ", bThisCueEligible=" + strB(bThisCueEligible))
                                Break
                            EndSelect
                          EndIf
                          k = \nNextAudIndex
                        EndWith
                      Wend
                      ; debugMsg(sProcName, "aSub(" + getSubLabel(j) + ")\bSubTypeA=" + strB(aSub(j)\bSubTypeA) + ", nVideoCount=" + nVideoCount + ", bVideoXFadeFound=" + strB(bVideoXFadeFound))
                      If aSub(j)\bSubTypeA
                        If (nVideoCount = 0) Or (bVideoXFadeFound = #False)
                          bThisCueEligible = #False
                          ; debugMsg(sProcName, "n i=" + getCueLabel(i) + ", bThisCueEligible=" + strB(bThisCueEligible))
                        EndIf
                      EndIf
                    Else
                      bThisCueEligible = #False
                      ; debugMsg(sProcName, "o i=" + getCueLabel(i) + ", bThisCueEligible=" + strB(bThisCueEligible))
                    EndIf
                  EndIf
                EndIf
              EndIf ; EndIf aSub(j)\bSubEnabled
              j = aSub(j)\nNextSubIndex
            Wend
            If (nSubTypeFCount = 0) And (nSubTypeACount = 0)
              bThisCueEligible = #False
              ; debugMsg(sProcName, "p i=" + getCueLabel(i) + ", bThisCueEligible=" + strB(bThisCueEligible))
            EndIf
          EndIf
          
          If bThisCueEligible
            With aCue(i)
              If \bHotkey
                ; debugMsg(sProcName, "aCue(" + getCueLabel(i) + ")\bHotkey=" + strB(aCue(i)\bHotkey) + " so setting bThisCueEligible = #False")
                bThisCueEligible = #False
                ; debugMsg(sProcName, "q i=" + getCueLabel(i) + ", bThisCueEligible=" + strB(bThisCueEligible))
              EndIf
              ; Added 27Nov2020 11.8.3.3aq following bug reported by Ian Henderson where auto-cue didn't start
              If \bSubTypeU Or \bSubTypeM
                bThisCueEligible = #False
              EndIf
              ; End added 27Nov2020 11.8.3.3aq
            EndWith
          EndIf
          
          bCueEligible(i) = bThisCueEligible
          ; debugMsg(sProcName, "bCueEligible(" + getCueLabel(i) + ")=" + strB(bCueEligible(i)) + ", bFirstInGaplessSeq=" + strB(bFirstInGaplessSeq))
          If bThisCueEligible
            If bFirstInGaplessSeq
              nGaplessSeqNo + 1
              nCueGaplessSeqNo(i) = nGaplessSeqNo
              ; debugMsg(sProcName, "bFirstInGaplessSeq=#True, nCueGaplessSeqNo(" + getCueLabel(i) + ")=" + nCueGaplessSeqNo(i))
            Else
              If nPrevCueInGaplessSeq >= 0
                nCueGaplessSeqNo(i) = nCueGaplessSeqNo(nPrevCueInGaplessSeq)
                ; debugMsg(sProcName, "bFirstInGaplessSeq=#False, nPrevCueInGaplessSeq=" + getCueLabel(nPrevCueInGaplessSeq) + ", nCueGaplessSeqNo(" + getCueLabel(i) + ")=" + nCueGaplessSeqNo(i))
              EndIf
            EndIf
          EndIf
        EndIf ; EndIf nCuePassForCheck(i) = nPassNo
      EndIf ; EndIf bCheckCue(i)
    Next i
  Next nPassNo
  
  ; debugMsg(sProcName, "nGaplessSeqNo=" + nGaplessSeqNo)
  ; clear indicators for any seq that only has one cue
  For nThisGaplessSeqNo = 1 To nGaplessSeqNo
    ; debugMsg(sProcName, "nThisGaplessSeqNo=" + nThisGaplessSeqNo)
    nCueCount = 0
    For i = 1 To gnLastCue
      ; debugMsg(sProcName, "nCueGaplessSeqNo(" + getCueLabel(i) + ")=" + nCueGaplessSeqNo(i))
      If nCueGaplessSeqNo(i) = nThisGaplessSeqNo
        nCueCount + 1
      EndIf
    Next i
    ; debugMsg(sProcName, "nCueCount=" + nCueCount)
    If nCueCount = 1
      For i = 1 To gnLastCue
        If nCueGaplessSeqNo(i) = nThisGaplessSeqNo
          bCueEligible(i) = #False
          debugMsg(sProcName, "bCueEligible(" + getCueLabel(i) + ")=" + strB(bCueEligible(i)))
          nCueGaplessSeqNo(i) = -1
          nAutoActCuePtr(i) = -1
        EndIf
      Next i
    EndIf
  Next nThisGaplessSeqNo
  
  For nThisGaplessSeqNo = 1 To nGaplessSeqNo
    ; debugMsg(sProcName, "nThisGaplessSeqNo=" + Str(nThisGaplessSeqNo))
    bFirstInGaplessSeq = #True
    nGaplessSeqPtr = grAudDef\nAudGaplessSeqPtr
    nPrevGaplessAudPtr = -1
    For i = 1 To gnLastCue
      If nCueGaplessSeqNo(i) = nThisGaplessSeqNo
        j = aCue(i)\nFirstSubIndex
        While j >= 0
          If aSub(j)\bSubEnabled
            aSub(j)\bSubUseGaplessStream = #False
            aSub(j)\nSubGaplessSeqPtr = -1
            If (aSub(j)\bSubTypeAorF) And (aSub(j)\nAudCount = 1)
              k = aSub(j)\nFirstAudIndex
              If k >= 0
                If aSub(j)\bSubTypeA
                  nFileChannels = 2
                Else
                  ; debugMsg(sProcName, "aAud(" + getAudLabel(k) + ")\nFileChannels=" + Str(aAud(k)\nFileChannels))
                  nFileChannels = aAud(k)\nFileChannels
                  If nFileChannels = 0
                    nFileChannels = 2
                  EndIf
                EndIf
                If bFirstInGaplessSeq
                  nGaplessSeqPtr = assignGaplessSeqEntry()
                  If aAud(k)\bAudTypeF
                    gaGaplessSeqs(nGaplessSeqPtr)\nStreamType = #SCS_STREAM_AUDIO
                  ElseIf aAud(k)\bAudTypeA
                    gaGaplessSeqs(nGaplessSeqPtr)\nStreamType = #SCS_STREAM_VIDEO
                  EndIf
                  gaGaplessSeqs(nGaplessSeqPtr)\nMaxFileChannels = nFileChannels
                  gaGaplessSeqs(nGaplessSeqPtr)\nFirstGaplessAudPtr = k
                  gaGaplessSeqs(nGaplessSeqPtr)\nLastGaplessAudPtr = k
                  debugMsg(sProcName, "gaGaplessSeqs(" + nGaplessSeqPtr + ")\nFirstGaplessAudPtr=" + getAudLabel(gaGaplessSeqs(nGaplessSeqPtr)\nFirstGaplessAudPtr) + ", \nLastGaplessAudPtr=" + getAudLabel(gaGaplessSeqs(nGaplessSeqPtr)\nLastGaplessAudPtr))
                  bFirstInGaplessSeq = #False
                Else
                  If nFileChannels > gaGaplessSeqs(nGaplessSeqPtr)\nMaxFileChannels
                    gaGaplessSeqs(nGaplessSeqPtr)\nMaxFileChannels = nFileChannels
                  EndIf
                  gaGaplessSeqs(nGaplessSeqPtr)\nLastGaplessAudPtr = k
                EndIf
                aAud(k)\bAudUseGaplessStream = #True
                aAud(k)\nAudGaplessSeqPtr = nGaplessSeqPtr
                aSub(j)\bSubUseGaplessStream = #True
                aSub(j)\nSubGaplessSeqPtr = nGaplessSeqPtr
                If nPrevGaplessAudPtr >= 0
                  aAud(nPrevGaplessAudPtr)\nAutoFollowAudPtr = k
                EndIf
                nPrevGaplessAudPtr = k
              EndIf
            EndIf
          EndIf ; EndIf aSub(j)\bSubEnabled
          j = aSub(j)\nNextSubIndex
        Wend
      EndIf
    Next i
  Next nThisGaplessSeqNo
  
  ; unmark as gapless any gapless streams containing just one aud
  For nGaplessSeqPtr = 0 To (gnGaplessSeqCount-1)
    With gaGaplessSeqs(nGaplessSeqPtr)
      debugMsg(sProcName, "gaGaplessSeqs(" + nGaplessSeqPtr + ")\nFirstGaplessAudPtr=" + getAudLabel(\nFirstGaplessAudPtr) + ", \nLastGaplessAudPtr=" + getAudLabel(\nLastGaplessAudPtr))
      If \nLastGaplessAudPtr = \nFirstGaplessAudPtr
        If \nFirstGaplessAudPtr >= 0
          aAud(\nFirstGaplessAudPtr)\nAudGaplessSeqPtr = grAudDef\nAudGaplessSeqPtr
          debugMsg(sProcName, "aAud(" + getAudLabel(\nFirstGaplessAudPtr) + ")\nAudGaplessSeqPtr=" + aAud(\nFirstGaplessAudPtr)\nAudGaplessSeqPtr)
        EndIf
      EndIf
    EndWith
  Next nGaplessSeqPtr
  
  For i = 1 To gnLastCue
    If bCheckCue(i)
      j = aCue(i)\nFirstSubIndex
      While j >= 0
        If aSub(j)\bSubEnabled
          If aSub(j)\bSubTypeP
            bGaplessInfoChanged = setPlaylistGaplessInfo(j)
            If bGaplessInfoChanged
              If (aSub(j)\nSubState >= #SCS_CUE_READY) And (aSub(j)\nSubState < #SCS_CUE_COMPLETED)
                debugMsg(sProcName, "calling closeSub(" + getSubLabel(j) + ", #False, #False)")
                closeSub(j, #False, #False)
                debugMsg(sProcName, "calling setCueState(" + getCueLabel(i) + ")")
                setCueState(i)
              EndIf
            EndIf
          ElseIf (aSub(j)\bSubTypeA) And (aSub(j)\nAudCount > 1)
            bGaplessInfoChanged = setSlideShowGaplessInfo(j)
            If bGaplessInfoChanged
              If (aSub(j)\nSubState >= #SCS_CUE_READY) And (aSub(j)\nSubState < #SCS_CUE_COMPLETED)
                debugMsg(sProcName, "calling closeSub(" + getSubLabel(j) + ", #False, #False)")
                closeSub(j, #False, #False)
                debugMsg(sProcName, "calling setCueState(" + getCueLabel(i) + ")")
                setCueState(i)
              EndIf
            EndIf
          EndIf
        EndIf ; EndIf aSub(j)\bSubEnabled
        j = aSub(j)\nNextSubIndex
      Wend
    EndIf
  Next i
  
  For i = 1 To gnLastCue
    If bCheckCue(i)
      setContainsGaplessInds(i)
    EndIf
  Next i
  
  For i = 1 To gnLastCue
    If bCheckCue(i)
      j = aCue(i)\nFirstSubIndex
      While j >= 0
        If aSub(j)\bSubEnabled
          If aSub(j)\bSubTypeHasAuds
            k = aSub(j)\nFirstAudIndex
            While k >= 0
              With aAud(k)
                If \bExists
                  If (\bAudUseGaplessStream <> bOrigUseGaplessStream(k)) Or (\nAudGaplessSeqPtr <> nOrigGaplessSeqPtr(k)) Or (\nAutoFollowAudPtr <> nOrigAutoFollowAudPtr(k))
                    \bReOpenFile = #True
                    debugMsg(sProcName, "aAud(" + getAudLabel(k) + ")\bReOpenFile=" + strB(\bReOpenFile))
                    debugMsg(sProcName, "aAud(" + getAudLabel(k) + ")\bAudUseGaplessStream=" + strB(\bAudUseGaplessStream) + ", bOrigUseGaplessStream(" + getAudLabel(k) + ")=" + strB(bOrigUseGaplessStream(k)))
                    debugMsg(sProcName, "aAud(" + getAudLabel(k) + ")\nAudGaplessSeqPtr=" + \nAudGaplessSeqPtr + ", nOrigGaplessSeqPtr(" + getAudLabel(k) + ")=" + nOrigGaplessSeqPtr(k))
                    debugMsg(sProcName, "aAud(" + getAudLabel(k) + ")\nAutoFollowAudPtr=" + getAudLabel(\nAutoFollowAudPtr) + ", nOrigAutoFollowAudPtr(" + getAudLabel(k) + ")=" + getAudLabel(nOrigAutoFollowAudPtr(k)))
                    If aAud(k)\bAudTypeA
                      If (\bAudUseGaplessStream <> bOrigUseGaplessStream(k))
                        If bOrigUseGaplessStream(k) = #False
                          debugMsg(sProcName, "calling closeAud(" + getAudLabel(k) + ")")
                          closeAud(k)
                        EndIf
                      EndIf
                    EndIf
                  Else
                    \bReOpenFile = #False
                    ; debugMsg(sProcName, "aAud(" + getAudLabel(k) + ")\bReOpenFile=" + strB(\bReOpenFile))
                  EndIf
                EndIf
              EndWith
              k = aAud(k)\nNextAudIndex
            Wend
          EndIf
        EndIf ; EndIf aSub(j)\bSubEnabled
        j = aSub(j)\nNextSubIndex
      Wend
    EndIf
  Next i
  
  ; For i = 1 To gnLastCue
    ; debugMsg(sProcName, "bCueEligible(" + getCueLabel(i) + ")=" + strB(bCueEligible(i)))
    ; debugMsg(sProcName, "nAutoActCuePtr(" + getCueLabel(i) + ")=" + getCueLabel(nAutoActCuePtr(i)))
    ; debugMsg(sProcName, "nCueGaplessSeqNo(" + getCueLabel(i) + ")=" + nCueGaplessSeqNo(i))
  ; Next i
  
  freeDeadGaplessStreams()
  
  ; free memory of arrays
  ReDim bCheckCue(0)
  ReDim bOrigUseGaplessStream(0)
  ReDim nOrigGaplessSeqPtr(0)
  ReDim nOrigAutoFollowAudPtr(0)
  ReDim bCueEligible(0)
  ReDim nAutoActCuePtr(0)
  ReDim nCueGaplessSeqNo(0)
  ReDim nCueOutputScreen(0)
  ReDim nCueAudDevMask(0)
  
  debugMsg(sProcName, "calling listGaplessArray()")
  listGaplessArray()
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure resetGaplessFirstAudPtrsIfReqd()
  PROCNAMEC()
  Protected i, j, k
  Protected nGaplessSeqPtr
  Protected nFirstGaplessAudPtr
  Protected bChangeMade
  
  ; debugMsg(sProcName, #SCS_START)
  
  ; debugMsg(sProcName, "calling listCueStates()")
  ; listCueStates()
  
  For nGaplessSeqPtr = 0 To (gnGaplessSeqCount-1)
    debugMsg(sProcName, "nGaplessSeqPtr=" + nGaplessSeqPtr)
    nFirstGaplessAudPtr = -1
    For i = 1 To gnLastCue
      If (aCue(i)\bSubTypeF) And (aCue(i)\bCueCurrentlyEnabled)
        j = aCue(i)\nFirstSubIndex
        While j >= 0
          If aSub(j)\bSubEnabled
            If aSub(j)\bSubTypeF
              k = aSub(j)\nFirstPlayIndex
              If k >= 0
                With aAud(k)
                  If \bAudPlaceHolder = #False
                    debugMsg(sProcName, "aAud(" + getAudLabel(k) + ")\nAudGaplessSeqPtr=" + \nAudGaplessSeqPtr + ", \nAudState=" + decodeCueState(\nAudState))
                    If \nAudGaplessSeqPtr = nGaplessSeqPtr
                      If \nAudState < #SCS_CUE_COMPLETED
                        nFirstGaplessAudPtr = k
                        Break
                      EndIf
                    EndIf
                  EndIf
                EndWith
              EndIf
            EndIf
          EndIf ; EndIf aSub(j)\bSubEnabled
          j = aSub(j)\nNextSubIndex
        Wend
        If nFirstGaplessAudPtr >= 0
          Break
        EndIf
      EndIf
    Next i
    
    ; reinstated 1Mar2019 11.8.0.2aw (was previously commented out, which made the whole procedure pointless)
    ; unfortunately I don't know WHY it was previously commented out
    ; reinstated following a bug reported by email by Christian Peters on 28Feb2019: "SCS doesn't fade up in auto-started LCQ"
    If nFirstGaplessAudPtr >= 0 ; nb don't change \nFirstGaplessAudPtr if all aud's completed
      If gaGaplessSeqs(nGaplessSeqPtr)\nFirstGaplessAudPtr <> nFirstGaplessAudPtr
        debugMsg(sProcName, "gaGaplessSeqs(" + nGaplessSeqPtr + ")\nFirstGaplessAudPtr being changed from " + getAudLabel(gaGaplessSeqs(nGaplessSeqPtr)\nFirstGaplessAudPtr) +
                            " to " + getAudLabel(nFirstGaplessAudPtr))
        gaGaplessSeqs(nGaplessSeqPtr)\nFirstGaplessAudPtr = nFirstGaplessAudPtr
        debugMsg(sProcName, "gaGaplessSeqs(" + nGaplessSeqPtr + ")\nFirstGaplessAudPtr=" + getAudLabel(gaGaplessSeqs(nGaplessSeqPtr)\nFirstGaplessAudPtr) + ", \nLastGaplessAudPtr=" + getAudLabel(gaGaplessSeqs(nGaplessSeqPtr)\nLastGaplessAudPtr))
        bChangeMade = #True
      EndIf
    EndIf
    ; end reinstated 1Mar2019 11.8.0.2aw
    
  Next nGaplessSeqPtr
  
  If bChangeMade
    debugMsg(sProcName, "calling listGaplessArray()")
    listGaplessArray()
  EndIf
  
  ; debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure setPlaylistGaplessInfo(pSubPtr)
  PROCNAMECS(pSubPtr)
  Protected k
  Protected bUseGaplessStream
  Protected nGaplessSeqPtr
  Protected nMaxFileChannels
  Protected bGaplessInfoChanged
  
  debugMsg(sProcName, #SCS_START)
  
  If gbUseBASSMixer = #False
    ProcedureReturn #False
  EndIf
  
  If pSubPtr >= 0
    With aSub(pSubPtr)
      If \bSubTypeP
        
        If grLicInfo\nLicLevel >= #SCS_LIC_STD
          ; 28Jul2015 (11.4.0.3) added "And (\bHotkey = #False)" to the following because gapless streams not currently working
          ; correctly for playlists which are hotkey cues. See emails from Jens Peter Schalow from 23Jul2015.
          ; If (\nAudCount > 1) And (\bPLRandom = #False) And (\bPLRepeat = #False) And (\bHotkey = #False) And (\bPLSavePos = #False)
          If (\nAudCount > 1) And (\bPLRandom = #False) And (getPLRepeatActive(pSubPtr) = #False) And (\bHotkey = #False) And (\bPLSavePos = #False)
            bUseGaplessStream = #True
            k = \nFirstPlayIndex
            While k >= 0
              If (aAud(k)\nPLTransTime > 0) Or (aAud(k)\nAbsStartAt > 0) Or (aAud(k)\nAbsEndAt < (aAud(k)\nFileDuration - 1))
                bUseGaplessStream = #False
                ; debugMsg(sProcName, "k=" + getAudLabel(k) + ", bUseGaplessStream=" + strB(bUseGaplessStream))
                ; debugMsg(sProcName, "aAud(" + getAudLabel(k) + ")\nPLTransTime=" + aAud(k)\nPLTransTime + ", \nAbsStartAt=" + aAud(k)\nAbsStartAt + ", \nAbsEndAt=" + aAud(k)\nAbsEndAt +
                ;                     ", \nFileDuration=" + aAud(k)\nFileDuration)
                Break
              EndIf
              If aAud(k)\nFileChannels > nMaxFileChannels
                nMaxFileChannels = aAud(k)\nFileChannels
              EndIf
              k = aAud(k)\nNextPlayIndex
            Wend
          Else
            bUseGaplessStream = #False
            ; debugMsg(sProcName, "bUseGaplessStream=" + strB(bUseGaplessStream))
          EndIf
          If gbUseBASSMixer = #False
            bUseGaplessStream = #False
            ; debugMsg(sProcName, "bUseGaplessStream=" + strB(bUseGaplessStream))
          EndIf
        EndIf
        ; debugMsg(sProcName, "bUseGaplessStream=" + strB(bUseGaplessStream))
        
        ; check if gapless info changed for this playlist
        If \bSubUseGaplessStream <> bUseGaplessStream
          bGaplessInfoChanged = #True
        Else
          k = \nFirstPlayIndex
          While k >= 0
            If aAud(k)\bAudUseGaplessStream <> bUseGaplessStream
              bGaplessInfoChanged = #True
            ElseIf aAud(k)\nAudGaplessSeqPtr <> \nSubGaplessSeqPtr
              bGaplessInfoChanged = #True
            Else
              If bUseGaplessStream
                If aAud(k)\nAutoFollowAudPtr <> aAud(k)\nNextPlayIndex
                  bGaplessInfoChanged = #True
                EndIf
              Else
                If aAud(k)\nAutoFollowAudPtr <> -1
                  bGaplessInfoChanged = #True
                EndIf
              EndIf
            EndIf
            If bGaplessInfoChanged
              Break
            EndIf
            k = aAud(k)\nNextPlayIndex
          Wend
        EndIf
        
        If bGaplessInfoChanged
          If bUseGaplessStream
            nGaplessSeqPtr = assignGaplessSeqEntry()
            gaGaplessSeqs(nGaplessSeqPtr)\nStreamType = #SCS_STREAM_AUDIO
            gaGaplessSeqs(nGaplessSeqPtr)\nMaxFileChannels = nMaxFileChannels
            gaGaplessSeqs(nGaplessSeqPtr)\nFirstGaplessAudPtr = \nFirstPlayIndex
            gaGaplessSeqs(nGaplessSeqPtr)\nLastGaplessAudPtr = \nLastPlayIndex
            debugMsg(sProcName, "gaGaplessSeqs(" + nGaplessSeqPtr + ")\nFirstGaplessAudPtr=" + getAudLabel(gaGaplessSeqs(nGaplessSeqPtr)\nFirstGaplessAudPtr) + ", \nLastGaplessAudPtr=" + getAudLabel(gaGaplessSeqs(nGaplessSeqPtr)\nLastGaplessAudPtr))
          Else
            nGaplessSeqPtr = grAudDef\nAudGaplessSeqPtr
          EndIf
          
          k = \nFirstPlayIndex
          While k >= 0
            aAud(k)\bAudUseGaplessStream = bUseGaplessStream
            aAud(k)\nAudGaplessSeqPtr = nGaplessSeqPtr
            If bUseGaplessStream
              aAud(k)\nAutoFollowAudPtr = aAud(k)\nNextPlayIndex
            Else
              aAud(k)\nAutoFollowAudPtr = -1
            EndIf
            debugMsg(sProcName, "aAud(" + getAudLabel(k) + ")\bAudUseGaplessStream=" + strB(aAud(k)\bAudUseGaplessStream) + ", \nAudGaplessSeqPtr=" + aAud(k)\nAudGaplessSeqPtr + ", \nAutoFollowAudPtr=" + getAudLabel(aAud(k)\nAutoFollowAudPtr))
            k = aAud(k)\nNextPlayIndex
          Wend
          
          ; propogate settings to the Sub
          \bSubUseGaplessStream = bUseGaplessStream
          \nSubGaplessSeqPtr = nGaplessSeqPtr
        EndIf
        
      EndIf
    EndWith
  EndIf
  debugMsg(sProcName, #SCS_END + ", returning bGaplessInfoChanged=" + strB(bGaplessInfoChanged))
  ProcedureReturn bGaplessInfoChanged
EndProcedure

Procedure setSlideShowGaplessInfo(pSubPtr)
  PROCNAMECS(pSubPtr)
  Protected k
  Protected bUseGaplessStream
  Protected nGaplessSeqPtr
  Protected nVidAudPhysPtr
  Protected sFileExt.s
  Protected bGaplessInfoChanged
  Protected bVideoXFadeFound
  Protected nVideoCount, nImageCount
  
  debugMsg(sProcName, #SCS_START)
  
  Select grVideoDriver\nVideoPlaybackLibrary
    Case #SCS_VPL_TVG
      ; continue
    Default
      ProcedureReturn #False
  EndSelect
  
  If pSubPtr >= 0
    With aSub(pSubPtr)
      If (\bSubTypeA) And (\nAudCount > 1)
        k = \nFirstPlayIndex
        While k >= 0
          Select aAud(k)\nFileFormat
            Case #SCS_FILEFORMAT_PICTURE
              nImageCount + 1
            Case #SCS_FILEFORMAT_VIDEO
              nVideoCount + 1
              If (aAud(k)\nPLTransType = #SCS_TRANS_XFADE) And (aAud(k)\nPLTransTime > 0) And (aAud(k)\nNextAudIndex >= 0)
                bVideoXFadeFound = #True
              EndIf
            Default
              bUseGaplessStream = #False
              Break
          EndSelect
          k = aAud(k)\nNextPlayIndex
        Wend
        If (nVideoCount = 0) Or (bVideoXFadeFound = #False) Or (nImageCount > 0)
          bUseGaplessStream = #False
        EndIf
        
        debugMsg(sProcName, "bUseGaplessStream=" + strB(bUseGaplessStream) + ", \nSubGaplessSeqPtr=" + \nSubGaplessSeqPtr)
        ; check if gapless info changed for this playlist
        If \bSubUseGaplessStream <> bUseGaplessStream
          bGaplessInfoChanged = #True
          debugMsg(sProcName, "bGaplessInfoChanged=" + strB(bGaplessInfoChanged))
        ElseIf (bUseGaplessStream) And (\nSubGaplessSeqPtr = -1)
          bGaplessInfoChanged = #True
          debugMsg(sProcName, "bGaplessInfoChanged=" + strB(bGaplessInfoChanged))
        Else
          k = \nFirstPlayIndex
          While k >= 0
            debugMsg(sProcName, "aAud(" + getAudLabel(k) + ")\bAudUseGaplessStream=" + strB(aAud(k)\bAudUseGaplessStream) + ", aAud(" + getAudLabel(k) + ")\nAudGaplessSeqPtr=" + aAud(k)\nAudGaplessSeqPtr)
            If aAud(k)\bAudUseGaplessStream <> bUseGaplessStream
              bGaplessInfoChanged = #True
              debugMsg(sProcName, "bGaplessInfoChanged=" + strB(bGaplessInfoChanged) + ", aAud(" + getAudLabel(k) + ")\bAudUseGaplessStream=" + strB(aAud(k)\bAudUseGaplessStream) + ", bUseGaplessStream=" + strB(bUseGaplessStream))
            ElseIf aAud(k)\nAudGaplessSeqPtr <> \nSubGaplessSeqPtr
              bGaplessInfoChanged = #True
              debugMsg(sProcName, "bGaplessInfoChanged=" + strB(bGaplessInfoChanged))
            Else
              If bUseGaplessStream
                If aAud(k)\nAutoFollowAudPtr <> aAud(k)\nNextPlayIndex
                  bGaplessInfoChanged = #True
                  debugMsg(sProcName, "bGaplessInfoChanged=" + strB(bGaplessInfoChanged))
                EndIf
              Else
                If aAud(k)\nAutoFollowAudPtr <> -1
                  bGaplessInfoChanged = #True
                  debugMsg(sProcName, "bGaplessInfoChanged=" + strB(bGaplessInfoChanged))
                EndIf
              EndIf
            EndIf
            If bGaplessInfoChanged
              Break
            EndIf
            k = aAud(k)\nNextPlayIndex
          Wend
        EndIf
        
        ; debugMsg(sProcName, "bGaplessInfoChanged=" + strB(bGaplessInfoChanged))
        If bGaplessInfoChanged
          If bUseGaplessStream
            If (\bSubUseGaplessStream) And (\nSubGaplessSeqPtr >= 0)
              ; sub already has a gapless sequence assigned
              nGaplessSeqPtr = \nSubGaplessSeqPtr
              ; gaGaplessSeqs(nGaplessSeqPtr)\nFirstGaplessAudPtr = \nFirstPlayIndex
              gaGaplessSeqs(nGaplessSeqPtr)\nLastGaplessAudPtr = \nLastPlayIndex
            Else
              nGaplessSeqPtr = assignGaplessSeqEntry()
              debugMsg(sProcName, "nGaplessSeqPtr=" + Str(nGaplessSeqPtr))
              gaGaplessSeqs(nGaplessSeqPtr)\nStreamType = #SCS_STREAM_VIDEO
              gaGaplessSeqs(nGaplessSeqPtr)\nFirstGaplessAudPtr = \nFirstPlayIndex
              gaGaplessSeqs(nGaplessSeqPtr)\nLastGaplessAudPtr = \nLastPlayIndex
              debugMsg(sProcName, "gaGaplessSeqs(" + nGaplessSeqPtr + ")\nFirstGaplessAudPtr=" + getAudLabel(gaGaplessSeqs(nGaplessSeqPtr)\nFirstGaplessAudPtr) + ", \nLastGaplessAudPtr=" + getAudLabel(gaGaplessSeqs(nGaplessSeqPtr)\nLastGaplessAudPtr))
            EndIf
          Else
            nGaplessSeqPtr = grAudDef\nAudGaplessSeqPtr
          EndIf
          
          k = \nFirstPlayIndex
          While k >= 0
            aAud(k)\bAudUseGaplessStream = bUseGaplessStream
            aAud(k)\nAudGaplessSeqPtr = nGaplessSeqPtr
            If bUseGaplessStream
              aAud(k)\nAutoFollowAudPtr = aAud(k)\nNextPlayIndex
            Else
              aAud(k)\nAutoFollowAudPtr = -1
            EndIf
            debugMsg(sProcName, "aAud(" + getAudLabel(k) + ")\bAudUseGaplessStream=" + strB(aAud(k)\bAudUseGaplessStream) + ", \nAudGaplessSeqPtr=" + aAud(k)\nAudGaplessSeqPtr + ", \nAutoFollowAudPtr=" + getAudLabel(aAud(k)\nAutoFollowAudPtr))
            k = aAud(k)\nNextPlayIndex
          Wend
          
          ; propogate settings to the Sub
          \bSubUseGaplessStream = bUseGaplessStream
          \nSubGaplessSeqPtr = nGaplessSeqPtr
        EndIf
        
      EndIf
    EndWith
  EndIf
  debugMsg(sProcName, #SCS_END + ", returning bGaplessInfoChanged=" + strB(bGaplessInfoChanged))
  ProcedureReturn bGaplessInfoChanged
EndProcedure

Procedure setContainsGaplessInds(pCuePtr)
  PROCNAMECQ(pCuePtr)
  Protected j, k
  Protected bCueContainsGapless, bSubContainsGapless
  
  If pCuePtr >= 0
    j = aCue(pCuePtr)\nFirstSubIndex
    While j >= 0
      If aSub(j)\bSubEnabled
        bSubContainsGapless = #False
        If aSub(j)\bSubTypeHasAuds
          If (aSub(j)\bSubTypeP) And (aSub(j)\bPLSavePos)
            ; do not set gapless if 'save position' is specified
          Else
            k = aSub(j)\nFirstAudIndex
            While k >= 0
              If aAud(k)\bAudUseGaplessStream
                bSubContainsGapless = #True
                Break
              EndIf
              k = aAud(k)\nNextAudIndex
            Wend
          EndIf
        EndIf
        aSub(j)\bSubContainsGapless = bSubContainsGapless
        ; debugMsg(sProcName, "aSub(" + getSubLabel(j) + ")\bSubContainsGapless=" + strB(aSub(j)\bSubContainsGapless))
        If bSubContainsGapless
          bCueContainsGapless = #True
          ; nb do not Break here as we need to go thru all the subs for the cue and set \bSubContainsGapless appropriately
        EndIf
      EndIf
      j = aSub(j)\nNextSubIndex
    Wend
    aCue(pCuePtr)\bCueContainsGapless = bCueContainsGapless
    ; debugMsg(sProcName, "aCue(" + getCueLabel(pCuePtr) + ")\bCueContainsGapless=" + strB(aCue(pCuePtr)\bCueContainsGapless))
    
    ; Added 16Jun2020 11.8.3.2ad TEMP ???
    If bCueContainsGapless
      aCue(pCuePtr)\bLogInONCCloseFilesNotReqd = #True
      ; Important: Once set #True, this field must NEVER be set #False during this run. See comment about this field in Structures.pbi.
    EndIf
    ; End added 16Jun2020 11.8.3.2ad
    
  EndIf
  
EndProcedure

Procedure clearSubGaplessInfo(pSubPtr)
  PROCNAMECS(pSubPtr)
  Protected k
  Protected nCuePtr
  
  ; debugMsg(sProcName, #SCS_START)
  
  If pSubPtr >= 0
    If aSub(pSubPtr)\bSubTypeHasAuds
      k = aSub(pSubPtr)\nFirstAudIndex
      While k >= 0
        With aAud(k)
          \bAudUseGaplessStream = grAudDef\bAudUseGaplessStream
          \nAudGaplessSeqPtr = grAudDef\nAudGaplessSeqPtr
          \nAudGaplessStream = grAudDef\nAudGaplessStream
        EndWith
        k = aAud(k)\nNextAudIndex
      Wend
      With aSub(pSubPtr)
        \bSubUseGaplessStream = grSubDef\bSubUseGaplessStream
        \nSubGaplessSeqPtr = grSubDef\nSubGaplessSeqPtr
        \bSubContainsGapless = grSubDef\bSubContainsGapless
      EndWith
    EndIf
    
    nCuePtr = aSub(pSubPtr)\nCueIndex
    setContainsGaplessInds(nCuePtr)
    
  EndIf
  
  ; debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure clearAllGaplessInds()
  PROCNAMEC()
  Protected i, j, k
  
  debugMsg(sProcName, #SCS_START)
  
  For i = 1 To gnLastCue
    j = aCue(i)\nFirstSubIndex
    While j >= 0
      clearSubGaplessInfo(j)
      j = aSub(j)\nNextSubIndex
    Wend
    With aCue(i)
      \bCueContainsGapless = grCueDef\bCueContainsGapless
    EndWith
  Next i
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure setGaplessMajorChangeForAud(pAudPtr)
  PROCNAMECA(pAudPtr)
  Protected nGaplessSeqPtr
  
  If pAudPtr >= 0
    If aAud(pAudPtr)\bAudUseGaplessStream
      nGaplessSeqPtr = aAud(pAudPtr)\nAudGaplessSeqPtr
      If nGaplessSeqPtr >= 0
        gaGaplessSeqs(nGaplessSeqPtr)\bMajorChangeInEditor = #True
        debugMsg(sProcName, "gaGaplessSeqs(" + nGaplessSeqPtr + ")\bMajorChangeInEditor=" + strB(gaGaplessSeqs(nGaplessSeqPtr)\bMajorChangeInEditor))
      EndIf
    EndIf
  EndIf
EndProcedure

Procedure setGaplessMajorChangeForCue(pCuePtr)
  PROCNAMECQ(pCuePtr)
  Protected j, k, nGaplessSeqPtr
  
  If pCuePtr >= 0
    j = aCue(pCuePtr)\nFirstSubIndex
    While j >= 0
      If aSub(j)\bSubTypeAorP
        If aSub(j)\bSubUseGaplessStream
          nGaplessSeqPtr = aSub(j)\nSubGaplessSeqPtr
          If nGaplessSeqPtr >= 0
            gaGaplessSeqs(nGaplessSeqPtr)\bMajorChangeInEditor = #True
            debugMsg(sProcName, "gaGaplessSeqs(" + nGaplessSeqPtr + ")\bMajorChangeInEditor=" + strB(gaGaplessSeqs(nGaplessSeqPtr)\bMajorChangeInEditor))
          EndIf
        EndIf
      ElseIf aSub(j)\bSubTypeF
        k = aSub(j)\nFirstAudIndex
        If aAud(k)\bAudUseGaplessStream
          nGaplessSeqPtr = aAud(k)\nAudGaplessSeqPtr
          If nGaplessSeqPtr >= 0
            gaGaplessSeqs(nGaplessSeqPtr)\bMajorChangeInEditor = #True
            debugMsg(sProcName, "gaGaplessSeqs(" + nGaplessSeqPtr + ")\bMajorChangeInEditor=" + strB(gaGaplessSeqs(nGaplessSeqPtr)\bMajorChangeInEditor))
          EndIf
        EndIf
      EndIf
      j = aSub(j)\nNextSubIndex
    Wend
  EndIf
EndProcedure

Procedure checkForMajorChangesInEditor()
  PROCNAMEC()
  Protected nGaplessSeqPtr, j, k
  Protected nBassResult.l
  
  debugMsg(sProcName, #SCS_START)
  
  ; Modified 7Apr2020 11.8.2.3am to correct an incorrect bug-fix applied elsewhere in SCS, regarding Dave Korman's reported bug (25Feb2020)
  ; that on closing the editor, a running cue was stopped. The reason truned out to be that the running cue was a gapless playlist, and this
  ; procedure (checkForMajorChangesInEditor()) had the test for \bMajorChangeInEditor only wrapped around the code that calls BASS_StreamFree(),
  ; so the loops that closed subs and auds was always performed for all gapless strems.
  
  For nGaplessSeqPtr = 0 To gnGaplessSeqCount-1
    If gaGaplessSeqs(nGaplessSeqPtr)\bMajorChangeInEditor
      With gaGaplessSeqs(nGaplessSeqPtr)
        debugMsg(sProcName, "gaGaplessSeqs(" + nGaplessSeqPtr + ")\bMajorChangeInEditor=" + strB(\bMajorChangeInEditor) +
                            ", \nFirstGaplessAudPtr=" + getAudLabel(\nFirstGaplessAudPtr) + ", \nLastGaplessAudPtr=" + getAudLabel(\nLastGaplessAudPtr) +
                            ", \nGaplessStream=" + decodeHandle(\nGaplessStream))
      EndWith
      For k = 1 To gnLastAud
        With aAud(k)
          If \nAudGaplessSeqPtr = nGaplessSeqPtr
            \nAudGaplessSeqPtr = grAudDef\nAudGaplessSeqPtr
            \bAudUseGaplessStream = #False
            debugMsg(sProcName, "calling closeAud(" + getAudLabel(k) + ")")
            closeAud(k)
          EndIf
        EndWith
      Next k
      For j = 1 To gnLastSub
        With aSub(j)
          If \nSubGaplessSeqPtr = nGaplessSeqPtr
            \nSubGaplessSeqPtr = grSubDef\nSubGaplessSeqPtr
            \bSubUseGaplessStream = #False
            debugMsg(sProcName, "calling closeSub(" + getSubLabel(j) + ")")
            closeSub(j)
          EndIf
        EndWith
      Next j
      With gaGaplessSeqs(nGaplessSeqPtr)
        If \nGaplessStream > 0
          nBassResult = BASS_StreamFree(\nGaplessStream)
          debugMsg2(sProcName, "BASS_StreamFree(" + decodeHandle(\nGaplessStream) + ")", nBassResult)
          \nGaplessStream = 0
        EndIf
      EndWith
      gaGaplessSeqs(nGaplessSeqPtr)\bMajorChangeInEditor = #False
    EndIf ; EndIf gaGaplessSeqs(nGaplessSeqPtr)\bMajorChangeInEditor
  Next nGaplessSeqPtr
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure PlayEndSyncProcGapless(pHandle.l, pChannel.l, pData, pUser)
  PROCNAME("PlayEndSyncProcGapless pHandle=" + decodeHandle(pHandle) + ", pChannel=" + decodeHandle(pChannel) + ", pUser=" + pUser)
  
  ;========================================
  ; no system calls in callback procedures!
  ;========================================
  
  Protected nAudPtr
  Protected nAutoFollowAudPtr
  Protected nBassResult.l
  Protected nChannel.l
  Protected nGaplessSeqPtr
  Protected nGaplessStream.l
  
  debugMsg3_S(sProcName, #SCS_START)
  
  If gbStoppingEverything Or gbClosingDown
    ProcedureReturn
  EndIf
  
  nGaplessSeqPtr = pUser
  If nGaplessSeqPtr >= 0
    
    With gaGaplessSeqs(nGaplessSeqPtr)
      nAudPtr = \nCurrGaplessAudPtr
      debugMsg3_S(sProcName, "gaGaplessSeqs(" + nGaplessSeqPtr + ")\nCurrGaplessAudPtr=" + getAudLabel(gaGaplessSeqs(nGaplessSeqPtr)\nCurrGaplessAudPtr))
      If nAudPtr >= 0
        nAutoFollowAudPtr = aAud(nAudPtr)\nAutoFollowAudPtr
        If nAutoFollowAudPtr >= 0
          nGaplessStream = \nGaplessStream
          If nGaplessStream <> 0
            debugMsg3_S(sProcName, "aAud(" + getAudLabel(nAutoFollowAudPtr) + ")\nSourceChannel=" + decodeHandle(aAud(nAutoFollowAudPtr)\nSourceChannel))
            nChannel = aAud(nAutoFollowAudPtr)\nSourceChannel
            If nChannel <> 0
              nBassResult = BASS_Mixer_StreamAddChannel(nGaplessStream, nChannel, #BASS_MIXER_CHAN_NORAMPIN)
              debugMsg2_S(sProcName, "BASS_Mixer_StreamAddChannel(" + decodeHandle(nGaplessStream) + ", " + decodeHandle(nChannel) + ", #BASS_MIXER_CHAN_NORAMPIN)", nBassResult)
              If nBassResult = #BASSFALSE
                debugMsg3(sProcName, "Error: " + getBassErrorDesc(BASS_ErrorGetCode()))
              Else
                nBassResult = BASS_ChannelSetAttribute(nChannel, #BASS_ATTRIB_VOL, 1.0) ; in case channel 'volume' had been faded out by StopOrFadeOutAudChannels()
                debugMsg2_S(sProcName, "BASS_ChannelSetAttribute(" + decodeHandle(nChannel) + ", #BASS_ATTRIB_VOL, 1.0)", nBassResult)
                nBassResult = BASS_ChannelIsActive(nChannel)
                debugMsg2_S(sProcName, "BASS_ChannelIsActive(" + decodeHandle(nChannel) + ")", nBassResult)
                If nBassResult = #BASS_ACTIVE_STOPPED
                  nBassResult = BASS_ChannelSetPosition(nChannel, 0, #BASS_POS_BYTE); // reset the source channel
                  debugMsg2_S(sProcName, "BASS_ChannelSetPosition(" + decodeHandle(nChannel) + ", 0, #BASS_POS_BYTE)", nBassResult)
                  If nBassResult = #BASSFALSE
                    debugMsg3(sProcName, "Error: " + getBassErrorDesc(BASS_ErrorGetCode()))
                  EndIf
                EndIf
              EndIf
              nBassResult = BASS_ChannelSetPosition(nGaplessStream, 0, #BASS_POS_BYTE); // reset the mixer
              debugMsg2_S(sProcName, "BASS_ChannelSetPosition(" + decodeHandle(nGaplessStream) + ", 0, #BASS_POS_BYTE)", nBassResult)
              If nBassResult = #BASSFALSE
                debugMsg3(sProcName, "Error: " + getBassErrorDesc(BASS_ErrorGetCode()))
              EndIf
              \nCurrGaplessAudPtr = nAutoFollowAudPtr
              aAud(nAutoFollowAudPtr)\bAutoFollowStarted = #True
              aAud(nAutoFollowAudPtr)\bWaitForGaplessEndSync = #True
              aAud(nAudPtr)\bWaitForGaplessEndSync = #False ; allow StatusCheck() to proceed with 'stop aud' processing
              debugMsg3_S(sProcName, "aAud(" + getAudLabel(nAudPtr) + ")\bWaitForGaplessEndSync=" + strB(aAud(nAudPtr)\bWaitForGaplessEndSync) +
                                     ", aAud(" + getAudLabel(nAutoFollowAudPtr) + ")\bWaitForGaplessEndSync=" + strB(aAud(nAutoFollowAudPtr)\bWaitForGaplessEndSync))
            EndIf
          EndIf
        EndIf
      EndIf
    EndWith
  EndIf
  
  debugMsg3_S(sProcName, #SCS_END)
EndProcedure

; EOF