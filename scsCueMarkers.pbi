; File scsCueMarkers.pbi

EnableExplicit

; SCS Cue Markers
; Purpose is to add User Defined Cue Markers to Audio File Cues for various Cue File Activation
; The procedures in this include file all relate to SCS Cue Markers

; Modified Sep 2023 SCS 11.10.0 to support Cue Markers in Video File Cues as well as Audio File Cues

Procedure getCueMarkerPlaybackPosition(nCueMarkerId)
  PROCNAMEC()
  Protected i, j, k, nCueMarkerIndex, nCueMarkerPlaybackPosition = -1
  
  For i = 1 To gnLastCue
    If aCue(i)\bSubTypeAorF And aCue(i)\bCueEnabled
      j = aCue(i)\nFirstSubIndex
      While j >= 0
        If aSub(j)\bSubTypeAorF And aSub(j)\bSubEnabled
          k = aSub(j)\nFirstAudIndex
          While k >= 0
            If aAud(k)\nMaxCueMarker >= 0
              For nCueMarkerIndex = 0 To aAud(k)\nMaxCueMarker
                With aAud(k)\aCueMarker(nCueMarkerIndex)
                  If \nCueMarkerId = nCueMarkerId
                    nCueMarkerPlaybackPosition = \nCueMarkerPosition - aAud(k)\nAbsStartAt
                    Break 4 ; Break nCueMarkerIndex, k, j, i
                  EndIf
                EndWith
              Next nCueMarkerIndex
            EndIf
            k = aAud(k)\nNextAudIndex
          Wend
        EndIf
        j = aSub(j)\nNextSubIndex
      Wend
    EndIf
  Next i
  ProcedureReturn nCueMarkerPlaybackPosition
  
EndProcedure

Procedure setAutoActCueMarkerSubAndAudNos(bEditing=#False)
  PROCNAMEC()
  Protected i, j2, k2
  Protected nAutoActCuePtr, nAutoActSubId, nAutoActAudId
  Protected u, bPreChangeCalled ; if editing and a change is required to the OCM auto act info of a cue then pre and post change calls will be made for that cue
  Protected bOCMChanged
  
  debugMsg(sProcName, #SCS_START + ", bEditing=" + strB(bEditing))
  
  For i = 1 To gnLastCue
    With aCue(i)
      ; debugMsg(sProcName, "gnLastCue=" + gnLastCue + ", i=" + i + ", " + getCueLabel(i))
      If \nActivationMethod = #SCS_ACMETH_OCM And \bCueEnabled
        ; debugMsg(sProcName, "aCue(" + getCueLabel(i) + ")\nActivationMethod=" + decodeActivationMethod(\nActivationMethod) + ", \nAutoActCuePtr=" + getCueLabel(\nAutoActCuePtr) +
        ;                     ", \nAutoActSubId=" + \nAutoActSubId+ ", \nAutoActSubNo=" + \nAutoActSubNo + ", \nAutoActAudId=" + \nAutoActAudId + ", \nAutoActAudNo=" + \nAutoActAudNo)
        bPreChangeCalled = #False
        nAutoActCuePtr = \nAutoActCuePtr
        nAutoActSubId = \nAutoActSubId
        nAutoActAudId = \nAutoActAudId
        If nAutoActCuePtr >= 0
          j2 = aCue(nAutoActCuePtr)\nFirstSubIndex
          While j2 >= 0
            If aSub(j2)\nSubId = nAutoActSubId
              ; Set \nAutoActSubNo
              If \nAutoActSubNo <> aSub(j2)\nSubNo
                debugMsg(sProcName, "changing aCue(" + getCueLabel(i) + ")\nAutoActSubNo from " + \nAutoActSubNo + " To " + aSub(j2)\nSubNo)
                bOCMChanged = #True
                If bEditing And bPreChangeCalled = #False
                  u = preChangeCueL(#True, "AutoActChange", i)
                  bPreChangeCalled = #True
                EndIf
                \nAutoActSubNo = aSub(j2)\nSubNo
                \nAutoActSubId = aSub(j2)\nSubId
              EndIf
              k2 = aSub(j2)\nFirstAudIndex
              While k2 >= 0
                If aAud(k2)\nAudId = nAutoActAudId
                  ; Set \nAutoActAudNo
                  If \nAutoActAudNo <> aAud(k2)\nAudNo
                    debugMsg(sProcName, "changing aCue(" + getCueLabel(i) + ")\nAutoActAudNo from " + \nAutoActAudNo + " To " + aAud(k2)\nAudNo)
                    bOCMChanged = #True
                    If bEditing And bPreChangeCalled = #False
                      u = preChangeCueL(#True, "AutoActChange", i)
                      bPreChangeCalled = #True
                    EndIf
                    \nAutoActAudNo = aAud(k2)\nAudNo
                    \nAutoActAudId = aAud(k2)\nAudId
                  EndIf
                  Break 2 ; Break k2, j2
                EndIf
                k2 = aAud(k2)\nNextAudIndex
              Wend
              Break ; Break j2
            EndIf
            j2 = aSub(j2)\nNextSubIndex
          Wend
        EndIf
        If bPreChangeCalled
          postChangeCueL(u, #False, i)
        EndIf
        ; debugMsg(sProcName, "aCue(" + getCueLabel(i) + ")\nActivationMethod=" + decodeActivationMethod(\nActivationMethod) + ", \nAutoActCuePtr=" + getCueLabel(\nAutoActCuePtr) +
        ;                     ", \nAutoActSubId=" + \nAutoActSubId+ ", \nAutoActSubNo=" + \nAutoActSubNo + ", \nAutoActAudId=" + \nAutoActAudId + ", \nAutoActAudNo=" + \nAutoActAudNo)
      Else
        ; debugMsg(sProcName, "aCue(" + getCueLabel(i) + ")\nActivationMethod=" + decodeActivationMethod(\nActivationMethod) + ", \bCueEnabled=" + strB(\bCueEnabled))
      EndIf
    EndWith
  Next i
  
  debugMsg(sProcName, #SCS_END + ", returning bOCMChanged=" + strB(bOCMChanged))
  ProcedureReturn bOCMChanged
  
EndProcedure

Procedure setAutoActCueMarkerIds()
  PROCNAMEC()
  Protected i, sAutoActCue.s, sAutoActCueMarkerName.s, nAutoActCueMarkerId
  Protected nAutoActSubNo, nAutoActAudNo
  Protected i2, j2, k2, n2
  
  ; debugMsg(sProcName, #SCS_START)
  
  For i = 1 To gnLastCue
    With aCue(i)
      If \nActivationMethod = #SCS_ACMETH_OCM And \bCueEnabled
        sAutoActCue = \sAutoActCue
        nAutoActSubNo = \nAutoActSubNo
        nAutoActAudNo = \nAutoActAudNo
        sAutoActCueMarkerName = \sAutoActCueMarkerName
        nAutoActCueMarkerId = grCueDef\nAutoActCueMarkerId
        For i2 = 1 To gnLastCue
          If aCue(i2)\sCue = sAutoActCue And aCue(i2)\bCueEnabled
            j2 = aCue(i2)\nFirstSubIndex
            While j2 >= 0
              If aSub(j2)\nSubNo = nAutoActSubNo And aSub(j2)\bSubEnabled
                \nAutoActSubId = aSub(j2)\nSubId
                If aSub(j2)\bSubTypeAorF
                  k2 = aSub(j2)\nFirstAudIndex
                  While k2 >= 0
                    If aAud(k2)\nAudNo = nAutoActAudNo
                      For n2 = 0 To aAud(k2)\nMaxCueMarker
                        If aAud(k2)\aCueMarker(n2)\sCueMarkerName = sAutoActCueMarkerName
                          \nAutoActAudId = aAud(k2)\nAudId
                          nAutoActCueMarkerId = aAud(k2)\aCueMarker(n2)\nCueMarkerId
                          Break 4 ; break n2, k2, j2, i2
                        EndIf
                      Next n2
                    EndIf
                    k2 = aAud(k2)\nNextAudIndex
                  Wend
                EndIf
              EndIf
              j2 = aSub(j2)\nNextSubIndex
            Wend
          EndIf
        Next i2
        \nAutoActCueMarkerId = nAutoActCueMarkerId
        ; debugMsg(sProcName, "aCue(" + getCueLabel(i) + ")\sAutoActCue=" + \sAutoActCue + ", \sAutoActCueMarkerName=" + \sAutoActCueMarkerName + ", \nAutoActCueMarkerId=" + \nAutoActCueMarkerId)
      Else
        \nAutoActCueMarkerId = grCueDef\nAutoActCueMarkerId
        \nAutoActSubId = grCueDef\nAutoActSubId
        \nAutoActAudId = grCueDef\nAutoActAudId
      EndIf
    EndWith
  Next i
  
  ; debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure setSubCueMarkerIds()
  PROCNAMEC()
  Protected i, j, sSubCueMarkerName.s, nSubCueMarkerId, nSubCueMarkerAudNo, nSubCueMarkerAudId
  Protected j2, k2, n2, nCueMarkerId2
  
  ; debugMsg(sProcName, #SCS_START)
  
  For i = 1 To gnLastCue
    If aCue(i)\bCueEnabled
      j = aCue(i)\nFirstSubIndex
      While j >= 0
        With aSub(j)
          If \nSubStart = #SCS_SUBSTART_OCM
            ; debugMsg(sProcName, "aSub(" + getSubLabel(j) +")\sSubCueMarkerName=" + \sSubCueMarkerName + ", \nSubCueMarkerAudNo=" + \nSubCueMarkerAudNo)
            sSubCueMarkerName = \sSubCueMarkerName
            nSubCueMarkerAudNo = \nSubCueMarkerAudNo
            nSubCueMarkerId = grSubDef\nSubCueMarkerId
            nSubCueMarkerAudId = grSubDef\nSubCueMarkerAudId
            j2 = aCue(\nCueIndex)\nFirstSubIndex
            While j2 >= 0
              If aSub(j2)\bSubTypeAorF And aSub(j2)\bSubEnabled
                k2 = aSub(j2)\nFirstAudIndex
                While k2 >= 0
                  For n2 = 0 To aAud(k2)\nMaxCueMarker
                    If aAud(k2)\aCueMarker(n2)\sCueMarkerName = sSubCueMarkerName And aAud(k2)\nAudNo = nSubCueMarkerAudNo
                      nSubCueMarkerId = aAud(k2)\aCueMarker(n2)\nCueMarkerId
                      nSubCueMarkerAudId = aAud(k2)\nAudId
                      Break 3 ; break n2, k2, j2
                    EndIf
                  Next n2
                  k2 = aAud(k2)\nNextAudIndex
                Wend
              EndIf
              j2 = aSub(j2)\nNextSubIndex
            Wend
            \nSubCueMarkerId = nSubCueMarkerId
            \nSubCueMarkerAudId = nSubCueMarkerAudId
            ; debugMsg(sProcName, "aSub(" + getSubLabel(j) + ")\sSubCueMarkerName=" + \sSubCueMarkerName + ", \nSubCueMarkerId=" + \nSubCueMarkerId +
            ;                     ", \nSubCueMarkerAudNo=" + \nSubCueMarkerAudNo + ", \nSubCueMarkerAudId=" + \nSubCueMarkerAudId)
          Else
            \nSubCueMarkerId = grSubDef\nSubCueMarkerId
          EndIf
          j = \nNextSubIndex
        EndWith
      Wend
    EndIf ; EndIf aCue(i)\bCueEnabled
  Next i
  
  ; debugMsg(sProcName, #SCS_END)
  
EndProcedure

;- Update all the Process Cue Marker Names from all Cue Markers added to Audio File Cues
Procedure propogateCueMarkerNameChange(sHostCue.s, nHostSubNo, sCueMarkerNameOld.s, sCueMarkerNameNew.s)
  PROCNAMEC()
  Protected i, j, u
  
  For i = 1 To gnLastCue
    With aCue(i)
      If \nActivationMethod = #SCS_ACMETH_OCM And \bCueEnabled
        If (\sAutoActCue = sHostCue) And (\nAutoActSubNo = nHostSubNo) And (\sAutoActCueMarkerName = sCueMarkerNameOld)
          u = preChangeCueS(\sAutoActCueMarkerName, "change cue marker name", i)
          \sAutoActCueMarkerName = sCueMarkerNameNew
          postChangeCueS(u, \sAutoActCueMarkerName, i)
        EndIf
      EndIf
    EndWith
  Next i
  
  i = getCuePtr(sHostCue)
  If i >= 0
    j = aCue(i)\nFirstSubIndex
    While j >= 0
      With aSub(j)
        If \nSubStart = #SCS_SUBSTART_OCM And \bSubEnabled
          If \sSubCueMarkerName = sCueMarkerNameOld
            u = preChangeSubS(\sSubCueMarkerName, "change sub cue marker name", j)
            \sSubCueMarkerName = sCueMarkerNameNew
            postChangeSubS(u, \sSubCueMarkerName, j)
          EndIf
        EndIf
        j = \nNextSubIndex
      EndWith
    Wend
  EndIf
  
EndProcedure

Procedure checkMarkerInUse(nCueMarkerId)
  Protected n, bInUse
  
  For n = 0 To gnMaxOCMMatrixItem
    If gaOCMMatrix(n)\nCueMarkerId = nCueMarkerId
      bInUse = #True
      Break
    EndIf
  Next n
  ProcedureReturn bInUse
  
EndProcedure

;- Get the Minimum Time/Position for the SCS Cue Markers in a given Audio File Cue
Procedure getMinTimeforCueMarkers(pAudPtr)
 PROCNAMECA(pAudPtr)
  Protected nMinTime = -1 ; must return -1 if no SCS cue markers
  Protected a
  
  If aAud(pAudPtr)\nMaxCueMarker >= 0
    ; Deleted 3Mar2022 11.9.1ae following test of file supplied by Scott Seigwald which had two embedded cue points and it was not possible to move the end marker back before the first cue point,
    ; which was because the first cue marker was of type #SCS_CM_CP
    ; nMinTime = aAud(pAudPtr)\aCueMarker(a)\nCueMarkerPosition
    ; End deleted 3Mar2022 11.9.1ae
    If pAudPtr >= 0
      With aAud(pAudPtr)
        For a = 0 To \nMaxCueMarker
          If (\aCueMarker(a)\nCueMarkerType = #SCS_CMT_CM) And (\aCueMarker(a)\nCueMarkerPosition > nMinTime)
            nMinTime = \aCueMarker(a)\nCueMarkerPosition  
          EndIf
        Next a
      EndWith
    EndIf
  EndIf
  ProcedureReturn nMinTime  
EndProcedure

;- Get the Maximum Time/Position for the SCS Cue Markers in a given Audio File Cue
Procedure getMaxTimeforCueMarkers(pAudPtr)
  PROCNAMECA(pAudPtr)
  Protected nMaxTime = -1 ; must return -1 if no cue markers
  Protected n
  
  With aAud(pAudPtr)
    For n = 0 To \nMaxCueMarker
      If (\aCueMarker(n)\nCueMarkerType = #SCS_CMT_CM)
        If (\aCueMarker(n)\nCueMarkerPosition < nMaxTime) Or (nMaxTime = -1)
          nMaxTime = \aCueMarker(n)\nCueMarkerPosition
        EndIf
      EndIf 
    Next n
  EndWith
  ProcedureReturn nMaxTime  
EndProcedure

;- Get the Minimum Time/Position for an SCS Cue Marker in a given Audio File Cue
Procedure getMinTimeForACueMarker(pAudPtr)
  PROCNAMECA(pAudPtr)
  Protected nMinTime
  
  If pAudPtr >= 0
    nMinTime = aAud(pAudPtr)\nAbsStartAt + 1 ; min cue marker position is 1 millisecond after cue start position
  EndIf
  ProcedureReturn nMinTime  
EndProcedure

;- Get the Maximum Time/Position for an SCS Cue Marker in a given Audio File Cue
Procedure getMaxTimeForACueMarker(pAudPtr)
  PROCNAMECA(pAudPtr)
  Protected nMaxTime
  
  If pAudPtr >= 0
    nMaxTime = aAud(pAudPtr)\nAbsMax - 1 ; max cue marker position is 1 millisecond before cue end position
  EndIf
  ProcedureReturn nMaxTime  
EndProcedure

Procedure removeAllUnusedCueMarkersFromThisFile(pAudPtr, bUpdateDisplay=#True)
  PROCNAMECA(pAudPtr)
  Protected nCount, nDelete, nDeleteCount
  Protected nCueMarkerId
  Protected u, n, bMarkerInUse
  
  debugMsg(sProcName, #SCS_START)
  
  With aAud(pAudPtr)
    If \nMaxCueMarker >= 0
      u = preChangeAudL(\nMaxCueMarker, "Remove Cue Marker: " + \nMaxCueMarker + " - " + getAudLabel(pAudPtr))
      While nCount <= \nMaxCueMarker
        nCueMarkerId = \aCueMarker(nCount)\nCueMarkerId
        bMarkerInUse = #False
        For n = 0 To gnMaxOCMMatrixItem
          If gaOCMMatrix(n)\nCueMarkerId = nCueMarkerId
            bMarkerInUse = #True
            Break ; Break n
          EndIf
        Next n
        If bMarkerInUse = #False
          For nDelete = nCount To \nMaxCueMarker-1
            If nDelete < \nMaxCueMarker
              \aCueMarker(nDelete) = \aCueMarker(nDelete+1)
            EndIf
          Next nDelete
          nDeleteCount + 1
          \nMaxCueMarker - 1
        Else
          nCount + 1
        EndIf
      Wend
      ; debugMsg(sProcName, "calling loadCueMarkerArrays()")
      loadCueMarkerArrays()
      If bUpdateDisplay
        If \bAudTypeF
          WQF_displayFileInfo()
          redrawGraphAfterMouseChange(@grMG2)
        ElseIf \bAudTypeA
          WQA_displayFileInfo()
          redrawGraphAfterMouseChange(@grMG5)
        EndIf
      EndIf
      postChangeAudL(u, \nMaxCueMarker)
    EndIf
  EndWith
  
  debugMsg(sProcName, #SCS_END + ", nDeleteCount=" + nDeleteCount)
  
EndProcedure

Procedure removeAllUnusedCueMarkers()
  PROCNAMEC()
  Protected i, j, k
  Protected bCallDisplayInfo
  
  If MessageRequester("Removing Cue Markers", Lang("CueMarkerMsgs", "RemoveAll"), #PB_MessageRequester_YesNo) = #PB_MessageRequester_Yes
    For i = 1 To gnLastCue
      If aCue(i)\bCueEnabled
        j = aCue(i)\nFirstSubIndex
        While j >= 0
          With aSub(j)
            If \bSubTypeAorF And \bSubEnabled
              k = aSub(j)\nFirstAudIndex
              While k >= 0
                removeAllUnusedCueMarkersFromThisFile(k, #False)
                If k = nEditAudPtr
                  bCallDisplayInfo = #True
                EndIf
                k = aAud(k)\nNextAudIndex
              Wend
            EndIf
            j = \nNextSubIndex  
          EndWith
        Wend
      EndIf ; EndIf aCue(i)\bCueEnabled
    Next i
    If bCallDisplayInfo
      If aAud(nEditAudPtr)\bAudTypeF
        WQF_displayFileInfo()
        redrawGraphAfterMouseChange(@grMG2)
      ElseIf aAud(nEditAudPtr)\bAudTypeA
        WQA_displayFileInfo()
        redrawGraphAfterMouseChange(@grMG5)
      EndIf
    EndIf
  EndIf ; EndIf MessageRequester(...)
  
EndProcedure

Procedure getCueMarkerIndexForPosition(pAudPtr, nCueMarkerPosition)
  PROCNAMEC()
  Protected nCueMarkerIndex, n
  
  nCueMarkerIndex = -1
  If pAudPtr >= 0
    For n = 0 To aAud(pAudPtr)\nMaxCueMarker
      With aAud(pAudPtr)\aCueMarker(n)
        ; debugMsg(sProcName, "nCueMarkerPosition="+nCueMarkerPosition+ " Index(n)="+n)
        If \nCueMarkerPosition = nCueMarkerPosition
          nCueMarkerIndex = n
          Break
        EndIf
      EndWith
    Next n
  EndIf
  ProcedureReturn nCueMarkerIndex
EndProcedure

Procedure getCueMarkerIndexForCueMarkerId(pAudPtr, nCueMarkerId)
  PROCNAMEC()
  Protected nCueMarkerIndex, n
  
  nCueMarkerIndex = -1
  If pAudPtr >= 0
    For n = 0 To aAud(pAudPtr)\nMaxCueMarker
      With aAud(pAudPtr)\aCueMarker(n)
        ; debugMsg(sProcName, "nCueMarkerPosition="+nCueMarkerPosition+ " Index(n)="+n)
        If \nCueMarkerId = nCueMarkerId
          nCueMarkerIndex = n
          Break
        EndIf
      EndWith
    Next n
  EndIf
  ProcedureReturn nCueMarkerIndex
EndProcedure

Procedure setMissingCueMarkerIds(pAudPtr)
  PROCNAMECA(pAudPtr)
  Protected n
  
  If aAud(pAudPtr)\bAudTypeAorF
    For n = 0 To aAud(pAudPtr)\nMaxCueMarker
      With aAud(pAudPtr)\aCueMarker(n)
        If \nCueMarkerId <= 0
          gnUniqueCueMarkerId + 1
          \nCueMarkerId = gnUniqueCueMarkerId
        EndIf
      EndWith
    Next n
  EndIf
  
EndProcedure

Procedure clear_CueMarkerIdsEtc(*rAud.tyAud)
  PROCNAMEC()
  Protected n
  
  With *rAud
    If \bAudTypeAorF
      For n = 0 To \nMaxCueMarker
        \aCueMarker(n)\nCueMarkerId = 0
        \aCueMarker(n)\nBassMarkerSync = 0
      Next n
    EndIf
  EndWith
  
EndProcedure

Procedure setNextCueMarker(pAudPtr, pPosition)
  PROCNAMECA(pAudPtr)
  Protected nCueMarkerIndex, nCueMarkerPosition
  Protected nNextCueMarkerIndex = -1, nNextCueMarkerPosition = -1, sNextCueMarkerName.s
  
  ; debugMsg(sProcName, #SCS_START + ", pPosition=" + pPosition)
  
  With aAud(pAudPtr)
    ; debugMsg(sProcName, "\nMaxCueMarker=" + \nMaxCueMarker)
    For nCueMarkerIndex = 0 To \nMaxCueMarker
      ; debugMsg(sProcName, "\aCueMarker(" + nCueMarkerIndex + ")\nCueMarkerPosition=" + \aCueMarker(nCueMarkerIndex)\nCueMarkerPosition)
      nCueMarkerPosition = \aCueMarker(nCueMarkerIndex)\nCueMarkerPosition
      If nCueMarkerPosition >= pPosition
        If nNextCueMarkerIndex = -1
          nNextCueMarkerIndex = nCueMarkerIndex
          nNextCueMarkerPosition = nCueMarkerPosition
        ElseIf nCueMarkerPosition < nNextCueMarkerPosition
          nNextCueMarkerIndex = nCueMarkerIndex
          nNextCueMarkerPosition = nCueMarkerPosition
        EndIf
      EndIf
    Next nCueMarkerIndex
    If nNextCueMarkerIndex = -1
      ; no later cue markers, or no cue markers at all
      \rNextCueMarker\sCueMarkerName = ""
      \rNextCueMarker\nCueMarkerPosition = -1
      \rNextCueMarker\nCueMarkerId = -1
    Else
      ; a later cue marker found
      \rNextCueMarker\sCueMarkerName = \aCueMarker(nNextCueMarkerIndex)\sCueMarkerName
      \rNextCueMarker\nCueMarkerPosition = \aCueMarker(nNextCueMarkerIndex)\nCueMarkerPosition
      \rNextCueMarker\nCueMarkerId = \aCueMarker(nNextCueMarkerIndex)\nCueMarkerId
    EndIf
    If \nMaxCueMarker >= 0
      debugMsg(sProcName, "pPosition=" + pPosition + ", \rNextCueMarker\sCueMarkerName=" + \rNextCueMarker\sCueMarkerName + ", \nCueMarkerPosition=" + \rNextCueMarker\nCueMarkerPosition + ", \nCueMarkerId=" + \rNextCueMarker\nCueMarkerId)
    EndIf
  EndWith
  
EndProcedure

Procedure loadOCMCuesAfterAudPos(pAudPtr, pAbsPosition)
  PROCNAMECA(pAudPtr)
  Protected nCueMarkerIndex, nCueMarkerPosition
  Protected nCueMarkerId
  Protected i, nLoadCount
  
  debugMsg(sProcName, #SCS_START + ", pAbsPosition=" + pAbsPosition)
  
  If gnThreadNo <> #SCS_THREAD_MAIN
    debugMsg0(sProcName, "calling samAddRequest(#SCS_SAM_LOAD_OCM_CUES, " + getAudLabel(pAudPtr) + ", 0, " + pAbsPosition + ")")
    samAddRequest(#SCS_SAM_LOAD_OCM_CUES, pAudPtr, 0, pAbsPosition)
    ProcedureReturn
  EndIf
  
  With aAud(pAudPtr)
    debugMsg(sProcName, "\nCuePos=" + \nCuePos + ", \nAbsMin=" + \nAbsMin)
    ; debugMsg(sProcName, "\nMaxCueMarker=" + \nMaxCueMarker)
    For nCueMarkerIndex = 0 To \nMaxCueMarker
      ; debugMsg(sProcName, "\aCueMarker(" + nCueMarkerIndex + ")\nCueMarkerPosition=" + \aCueMarker(nCueMarkerIndex)\nCueMarkerPosition)
      nCueMarkerPosition = \aCueMarker(nCueMarkerIndex)\nCueMarkerPosition
      If nCueMarkerPosition >= pAbsPosition
        nCueMarkerId = \aCueMarker(nCueMarkerIndex)\nCueMarkerId
        If nCueMarkerId >= 0
          For i = 1 To gnLastCue
            If aCue(i)\nActivationMethod = #SCS_ACMETH_OCM And aCue(i)\bCueEnabled And aCue(i)\nAutoActCueMarkerId = nCueMarkerId
              If aCue(i)\nCueState >= #SCS_CUE_COMPLETED
                debugMsg(sProcName,"Calling loadOneCue(" + getCueLabel(i) + ")")
                loadOneCue(i)
                nLoadCount + 1
              EndIf
            EndIf
          Next i
        EndIf
      EndIf
    Next nCueMarkerIndex
  EndWith
  
  If nLoadCount > 0
    gqMainThreadRequest | #SCS_MTH_LOAD_DISP_PANELS
  EndIf

  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure checkNextCueMarker(pAudPtr)
  PROCNAMECA(pAudPtr)
  Protected nTrackTimeInMS
  Protected nCuePtr, i
  Protected nCueMarkerId
  
  ; This procedure is essential for detecting cue marker playback positions when using SoundMan-Server, but it is also used for BASS
  ; in case MarkerSyncProc() is not called when the cue marker position is reached. Technically, that should not occur, but in a test
  ; run by Rick Shamel (log etc supplied 30Jul2018) Rick had 40 lighting cues to be activated by 40 cue markers in a single audio file,
  ; and in that test 4 of those cue marker callbacks didn't occur. This may have been due to excessive processing being carried out by
  ; SCS, such as unnecessarily refreshing the cue list (unnecessary because the lighting cues were all marked to be 'hidden' so there
  ; was nothing to refresh). That inefficiency has now been fixed, but in case the problem should occur again, ie a callback doesn't
  ; happen, then THIS procedure should handle the required processing. Note that the BASS Sync callback is still the preferred mechanism
  ; as the timing is far more accurate. In practice, the callback MarkerSyncProc() should ALWAYS occur before the control thread gets
  ; around to calling checkNextCueMarker().
  
  ; Following up on a test by Tom Eagle (email 31Jul2018), it appears that setting BASS sync points for a gapless stream do not work well,
  ; especially on the second and subsequent files in the gapless stream. Since this is a rare requirement and the cue markers can be
  ; triggered by checkNextCueMarker(), do not try to set BASS sync points for gapless streams. (See similar comments in setBassMarkerPositions())
  
  With aAud(pAudPtr)
    If aSub(\nSubIndex)\bStartedInEditor
      ProcedureReturn
    EndIf
    
    If (\nAudState >= #SCS_CUE_FADING_IN) And (\nAudState <= #SCS_CUE_FADING_OUT)
      If \rNextCueMarker\nCueMarkerPosition >= 0
        ; indicates we are expecting to hit a cue marker
        If gbUseSMS
          nTrackTimeInMS = getSMSTrackTimeInMS(\sPPrimaryChan)
        Else
          nTrackTimeInMS = \nRelFilePos + \nAbsMin
        EndIf
        If nTrackTimeInMS >= \rNextCueMarker\nCueMarkerPosition
          ; we have reached (or past) the next cue marker
          debugMsg(sProcName, "\nAudState=" + decodeCueState(\nAudState) + ", \nRelFilePos=" + \nRelFilePos + ", \nAbsMin=" + \nAbsMin + ", nTrackTimeInMS=" + nTrackTimeInMS +
                              ", \rNextCueMarker\nCueMarkerPosition=" + \rNextCueMarker\nCueMarkerPosition + ", \rNextCueMarker\sCueMarkerName=" + \rNextCueMarker\sCueMarkerName +
                              ", \rNextCueMarker\nCueMarkerId=" + \rNextCueMarker\nCueMarkerId)
          nCueMarkerId = \rNextCueMarker\nCueMarkerId
          nCuePtr = \nCueIndex
          For i = 1 To gnLastCue
            If i <> nCuePtr
              If aCue(i)\nAutoActCueSelType = #SCS_ACCUESEL_CM And aCue(i)\bCueEnabled
                If aCue(i)\nAutoActCueMarkerId = nCueMarkerId
                  If aCue(i)\bPlayCueEventPosted = #False
                    debugMsg(sProcName, "PostEvent(#SCS_Event_PlayCue, #WMN, 0, 0, " + getCueLabel(i) + ")")
                    PostEvent(#SCS_Event_PlayCue, #WMN, 0, 0, i)
                    aCue(i)\bPlayCueEventPosted = #True
                  EndIf
                EndIf
              EndIf
            EndIf
          Next i
          ; set \rNextCueMarker to the next cue marker (if any) for this aAud()
          setNextCueMarker(pAudPtr, nTrackTimeInMS+1)
        EndIf
      EndIf
    EndIf
  EndWith
  
EndProcedure

Procedure propogateCueMarkerPositionChange(pAudPtr, nCueMarkerId)
  PROCNAMECA(pAudPtr)
  Protected i
  
  debugMsg(sProcName, #SCS_START + ", nCueMarkerId=" + nCueMarkerId)
  
  For i = 1 To gnLastCue
    With aCue(i)
      If \bCueEnabled
        If (\nActivationMethod = #SCS_ACMETH_OCM) And (\nAutoActCueMarkerId = nCueMarkerId)
          debugMsg(sProcName, "Relevant OCM found at aCue(" + getCueLabel(i) + ")")
          loadGridRow(i)
        EndIf
      EndIf
    EndWith
  Next i
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure loadCueMarkerInfoArray()
  PROCNAMEC()
  Protected i, j, k, n
  Protected nCueMarkerPlaybackPosition
  
  ; debugMsg(sProcName, #SCS_START)
  
  gnMaxCueMarkerInfo = -1
  For i = 1 To gnLastCue
    If aCue(i)\bSubTypeAorF And aCue(i)\bCueEnabled
      j = aCue(i)\nFirstSubIndex
      While j >= 0
        If aSub(j)\bSubTypeAorF And aSub(j)\bSubEnabled
          k = aSub(j)\nFirstAudIndex
          While k >= 0
            For n = 0 To aAud(k)\nMaxCueMarker
              gnMaxCueMarkerInfo + 1
              If gnMaxCueMarkerInfo > ArraySize(gaCueMarkerInfo())
                ReDim gaCueMarkerInfo(gnMaxCueMarkerInfo + 20)
              EndIf
              With gaCueMarkerInfo(gnMaxCueMarkerInfo)
                \nCueMarkerType = aAud(k)\aCueMarker(n)\nCueMarkerType
                \nCueMarkerId = aAud(k)\aCueMarker(n)\nCueMarkerId
                \sCueMarkerName = aAud(k)\aCueMarker(n)\sCueMarkerName
                \nCueMarkerPosition = aAud(k)\aCueMarker(n)\nCueMarkerPosition
                ; debugMsg(sProcName, "aAud(" + getAudLabel(k) + ")\aCueMarker(" + n + ")\nCueMarkerPosition=" + ttszt(aAud(k)\aCueMarker(n)\nCueMarkerPosition) + ", \nAbsStartAt=" + ttsz(aAud(k)\nAbsStartAt))
                \sCueMarkerDisplayInfoShort = \sCueMarkerName
                If (\nCueMarkerPosition >= aAud(k)\nAbsStartAt) And (\nCueMarkerPosition < aAud(k)\nAbsEndAt)
                  nCueMarkerPlaybackPosition = \nCueMarkerPosition - aAud(k)\nAbsStartAt
                  \sCueMarkerDisplayInfoShort + " (" + timeToString(nCueMarkerPlaybackPosition) + " as " + getAudLabel(k) + ")"
                  \bOCMAvailable = #True
                Else
                  ; should only get here for cue points, not for SCS cue markers, as SCS cue markers can only be created for positions between 'start at' and 'end at', whereas cue points are externally set for the audio file itself
                  \bOCMAvailable = #False
                EndIf
                \sCueMarkerDisplayInfo = getAudLabel(k) + ": " + \sCueMarkerDisplayInfoShort
                \nHostCuePtr = i
                \sHostCue = getCueLabel(i)
                \nHostSubNo = aSub(j)\nSubNo
                \nHostSubId = aSub(j)\nSubId
                \nHostAudNo = aAud(k)\nAudNo
                \nHostAudId = aAud(k)\nAudId
                \nHostAudPtr = k
                ; debugMsg(sProcName, "gaCueMarkerInfo("+ gnMaxCueMarkerInfo +")\nCueMarkerId=" + \nCueMarkerId + ", \nHostAudPtr=" + getAudLabel(\nHostAudPtr) +
                ;                     ", \nCueMarkerPosition=" + ttszt(\nCueMarkerPosition) + ", \sCueMarkerDisplayInfo=" + #DQUOTE$ + \sCueMarkerDisplayInfo + #DQUOTE$)
              EndWith
            Next n
            k = aAud(k)\nNextAudIndex
          Wend
        EndIf ; EndIf aSub(j)\bSubTypAorF
        j = aSub(j)\nNextSubIndex
      Wend
    EndIf ; EndIf aCue(i)\bSubTypeAorF
  Next i
  
  ; debugMsg(sProcName, #SCS_END + ", gnMaxCueMarkerInfo=" + gnMaxCueMarkerInfo)
  
EndProcedure

Procedure listCueMarkerInfo(pCuePtr=-1) ; pCuePtr added 3May2022 11.9.1
  PROCNAMEC()
  Protected n, sLine.s
  
  For n = 0 To gnMaxCueMarkerInfo
    With gaCueMarkerInfo(n)
      If \nHostCuePtr = pCuePtr Or pCuePtr = -1 ; test added 3May2022 11.9.1
        sLine = "gaCueMarkerInfo(" + n + ")\nHostCuePtr=" + getCueLabel(\nHostCuePtr) + ", \nHostSubNo=" + \nHostSubNo + ", \nHostAudNo=" + \nHostAudNo + ", \sCueMarkerDisplayInfo=" + \sCueMarkerDisplayInfo +
                ", \nCueMarkerPosition=" + \nCueMarkerPosition + ", \nCueMarkerType=" + \nCueMarkerType
        debugMsg(sProcName, sLine)
      EndIf
    EndWith
  Next n
  
EndProcedure

Procedure loadOCMMatrix(bTrace=#False)
  PROCNAMEC()
  Protected i, j, n
  Protected nCueMarkerId, sHostCue.s, nHostSubNo, nHostAudNo, sCueMarkerName.s, nHostCuePtr, nHostAudPtr
  Protected sDebugLine.s, sCues.s, sSubs.s, sAuds.s
  
  ; debugMsg(sProcName, #SCS_START + ", gnMaxCueMarkerInfo=" + gnMaxCueMarkerInfo)
  
  gnMaxOCMMatrixItem = -1
  For n = 0 To gnMaxCueMarkerInfo
    If gaCueMarkerInfo(n)\bOCMAvailable
      nCueMarkerId = gaCueMarkerInfo(n)\nCueMarkerId
      sHostCue = gaCueMarkerInfo(n)\sHostCue
      nHostCuePtr = gaCueMarkerInfo(n)\nHostCuePtr
      nHostSubNo = gaCueMarkerInfo(n)\nHostSubNo
      nHostAudPtr = gaCueMarkerInfo(n)\nHostAudPtr
      nHostAudNo = aAud(nHostAudPtr)\nAudNo
      sCueMarkerName = gaCueMarkerInfo(n)\sCueMarkerName
      sDebugLine = "gaCueMarkerInfo(" + n + ")\nCueMarkerId=" + nCueMarkerId + ", " + gaCueMarkerInfo(n)\sCueMarkerDisplayInfo
      sCues = ""
      sSubs = ""
      sAuds = ""
      For i = 1 To gnLastCue
        With aCue(i)
          If \bCueEnabled
            If \nActivationMethodReqd = #SCS_ACMETH_OCM
              If (\sAutoActCue = sHostCue) And (\nAutoActSubNo = nHostSubNo) And (\nAutoActAudNo = nHostAudNo) And (\sAutoActCueMarkerName = sCueMarkerName)
                gnMaxOCMMatrixItem + 1
                If gnMaxOCMMatrixItem > ArraySize(gaOCMMatrix())
                  ReDim gaOCMMatrix(gnMaxOCMMatrixItem + 20)
                EndIf
                gaOCMMatrix(gnMaxOCMMatrixItem)\nCueMarkerId = nCueMarkerId
                gaOCMMatrix(gnMaxOCMMatrixItem)\nOCMCuePtr = i
                gaOCMMatrix(gnMaxOCMMatrixItem)\nOCMSubPtr = -1
                gaOCMMatrix(gnMaxOCMMatrixItem)\nOCMAudPtr = -1
                sCues + ", " + \sCue
              EndIf
            EndIf
            If i = nHostCuePtr
              j = \nFirstSubIndex
              While j >= 0
                If aSub(j)\bSubEnabled
                  If aSub(j)\nSubStart = #SCS_SUBSTART_OCM
                    If aSub(j)\sSubCueMarkerName = sCueMarkerName
                      gnMaxOCMMatrixItem + 1
                      If gnMaxOCMMatrixItem > ArraySize(gaOCMMatrix())
                        ReDim gaOCMMatrix(gnMaxOCMMatrixItem + 20)
                      EndIf
                      gaOCMMatrix(gnMaxOCMMatrixItem)\nCueMarkerId = nCueMarkerId
                      gaOCMMatrix(gnMaxOCMMatrixItem)\nOCMCuePtr = i
                      gaOCMMatrix(gnMaxOCMMatrixItem)\nOCMSubPtr = j
                      sSubs + ", " + aSub(j)\sSubLabel
                    EndIf
                  EndIf
                EndIf
                j = aSub(j)\nNextSubIndex
              Wend
            EndIf
          EndIf
        EndWith
      Next i
      If bTrace
        If sCues
          sDebugLine + " Cue_OCM: " + Mid(sCues, 3)
        EndIf
        If sSubs
          sDebugLine + " Sub_OCM: " + Mid(sSubs, 3)
        EndIf
        debugMsg(sProcName, sDebugLine)
      EndIf
    EndIf ; EndIf gaCueMarkerInfo(n)\bOCMAvailable
  Next n
  
  ; debugMsg(sProcName, #SCS_END + ", gnMaxOCMMatrixItem=" + gnMaxOCMMatrixItem)
  
EndProcedure

Procedure loadCueMarkerFileArray()
  PROCNAMEC()
  Protected n2, n3, nHostAudPtr, sFileName.s, bAlreadyExists
  
  ; debugMsg(sProcName, #SCS_START)
  
  gnMaxCueMarkerFile = -1
  For n2 = 0 To gnMaxCueMarkerInfo
    nHostAudPtr = gaCueMarkerInfo(n2)\nHostAudPtr
    If nHostAudPtr >= 0
      sFileName = aAud(nHostAudPtr)\sFileName
      bAlreadyExists = #False
      For n3 = 0 To gnMaxCueMarkerFile
        If (gaCueMarkerFile(n3)\nAudPtr = nHostAudPtr) And (gaCueMarkerFile(n3)\sFileName = sFileName)
          bAlreadyExists = #True
          Break
        EndIf
      Next n3
      ; debugMsg(sProcName, "nHostAudPtr=" + getAudLabel(nHostAudPtr) + ", sFileName=" + GetFilePart(sFileName) + ", bAlreadyExists=" + strB(bAlreadyExists) + ", n3=" + n3)
      If bAlreadyExists = #False
        gnMaxCueMarkerFile + 1
        If gnMaxCueMarkerFile > ArraySize(gaCueMarkerFile())
          ReDim gaCueMarkerFile(gnMaxCueMarkerFile + 20)
        EndIf
        gaCueMarkerFile(gnMaxCueMarkerFile)\nAudPtr = nHostAudPtr
        gaCueMarkerFile(gnMaxCueMarkerFile)\sFileName = sFileName
;         debugMsg(sProcName, "gaCueMarkerFile(" + gnMaxCueMarkerFile + ")\nAudPtr=" + getAudLabel(gaCueMarkerFile(gnMaxCueMarkerFile)\nAudPtr) +
;                             ", gaCueMarkerFile(" + gnMaxCueMarkerFile + ")\sFileName=" + GetFilePart(gaCueMarkerFile(gnMaxCueMarkerFile)\sFileName))
      EndIf
    EndIf
  Next n2
  
  ; debugMsg(sProcName, #SCS_END + ", gnMaxCueMarkerFile=" + gnMaxCueMarkerFile)
  
EndProcedure

Procedure updateCueMarkerArrayWithCuePoints(pAudPtr)
  PROCNAMECA(pAudPtr)
  Protected n1, n2, sFileName.s
  
  ; debugMsg(sProcName, #SCS_START)
  
  With aAud(pAudPtr)
    ; debugMsg(sProcName, "aAud(" + getAudLabel(pAudPtr) +")\nMaxCueMarker=" + \nMaxCueMarker)
    ; delete any existing cue point entries from the array
    n1 = 0
    While n1 <= \nMaxCueMarker
      If \aCueMarker(n1)\nCueMarkerType = #SCS_CMT_CP
        For n2 = n1 To (\nMaxCueMarker - 1)
          \aCueMarker(n2) = \aCueMarker(n2+1)
        Next n2
        \nMaxCueMarker - 1
      Else
        n1 + 1
      EndIf
    Wend
    ; debugMsg(sProcName, "aAud(" + getAudLabel(pAudPtr) +")\nMaxCueMarker=" + \nMaxCueMarker)
    ; add any cue points for this file
    sFileName = \sFileName
    ; debugMsg(sProcName, "gnMaxCuePoint=" + gnMaxCuePoint)
    For n1 = 0 To gnMaxCuePoint
      If gaCuePoint(n1)\sFileName = sFileName
        If gaCuePoint(n1)\sName
          \nMaxCueMarker + 1
          n2 = \nMaxCueMarker
          If \nMaxCueMarker > ArraySize(\aCueMarker())
            ReDim \aCueMarker(n2+20)
          EndIf
          \aCueMarker(n2) = grAudDef\aCueMarker(0)
          gnUniqueCueMarkerId + 1
          \aCueMarker(n2)\nCueMarkerId = gnUniqueCueMarkerId
          \aCueMarker(n2)\nCueMarkerType = #SCS_CMT_CP
          \aCueMarker(n2)\sCueMarkerName = gaCuePoint(n1)\sName
          \aCueMarker(n2)\nCueMarkerPosition = Round(gaCuePoint(n1)\dTimePos * 1000, #PB_Round_Nearest)
        EndIf
      EndIf
    Next n1
    ; Added 3May2022 11.9.1
    If \nMaxCueMarker > 1
      SortStructuredArray(\aCueMarker(), #PB_Sort_Ascending, OffsetOf(tyCueMarker\nCueMarkerPosition), #PB_Integer, 0, \nMaxCueMarker)
    EndIf
    ; End added 3May2022 11.9.1
    
    ; debugMsg(sProcName, "aAud(" + getAudLabel(pAudPtr) +")\nMaxCueMarker=" + \nMaxCueMarker)
    For n1 = 0 To \nMaxCueMarker
      debugMsg(sProcName, "\aCueMarker(" + n1 + ")\nCueMarkerType=" + \aCueMarker(n1)\nCueMarkerType + ", \sCueMarkerName=" + \aCueMarker(n1)\sCueMarkerName + ", \nCueMarkerPosition=" + \aCueMarker(n1)\nCueMarkerPosition)
    Next n1
    
  EndWith
  
  ; debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure loadCueMarkerArrays(bTrace=#False)
  PROCNAMEC()
  
  debugMsgC(sProcName, #SCS_START)
  
  loadCueMarkerInfoArray()
  loadOCMMatrix()
  loadCueMarkerFileArray()
  setAutoActCueMarkerIds()
  setSubCueMarkerIds()
  If bTrace
    listCueMarkerInfo()
  EndIf
  
  debugMsgC(sProcName, #SCS_END)
  
EndProcedure

Procedure redisplayCueMarkerInfoWhereReqd(pAudPtr)
  PROCNAMECA(pAudPtr)
  Protected nCuePtr, i
  Protected sActivation.s, nRowNo
  
  If aAud(pAudPtr)\nMaxCueMarker >= 0
    nCuePtr = aAud(pAudPtr)\nCueIndex
    ; debugMsg(sProcName, "nCuePtr=" + getCueLabel(nCuePtr))
    For i = 1 To gnLastCue
      With aCue(i)
        If \bCueEnabled
          ; debugMsg(sProcName, "aCue(" + getCueLabel(i) + ")\nActivationMethod=" + decodeActivationMethod(\nActivationMethod))
          If \nActivationMethod = #SCS_ACMETH_OCM
            ; debugMsg(sProcName, "aCue(" + getCueLabel(i) + ")\nAutoActCuePtr=" + getCueLabel(\nAutoActCuePtr) + ", \nGrdCuesRowNo=" + \nGrdCuesRowNo)
            If \nAutoActCuePtr = nCuePtr
              nRowNo = \nGrdCuesRowNo
              If nRowNo >= 0
                sActivation = getCueActivationMethodForDisplay(i)
                ; debugMsg(sProcName, "i=" + getCueLabel(i) + ", nRowNo=" + nRowNo + ", sActivation=" + sActivation)
                WMN_setGrdCuesCellValue(nRowNo, #SCS_GRDCUES_AC, sActivation)
              EndIf
            EndIf
          EndIf
        EndIf
      EndWith
    Next i
  EndIf
  
EndProcedure

Procedure getAudPtrForCueMarkerPrevOrNext()
  PROCNAMEC()
  Protected i, j, k, nReqdAudPtr
  
  nReqdAudPtr = -1
  For i = 1 To gnLastCue
    If (aCue(i)\bCueEnabled) And (aCue(i)\bSubTypeAorF)
      ; debugMsg(sProcName, "aCue(" + getCueLabel(i) + ")\nCueState=" + decodeCueState(aCue(i)\nCueState))
      If (aCue(i)\nCueState >= #SCS_CUE_READY) And (aCue(i)\nCueState < #SCS_CUE_COMPLETED)
        ; Added 3May2022 11.9.1
        If (aCue(i)\bHotkey Or aCue(i)\bExtAct) And aCue(i)\nCueState = #SCS_CUE_READY
          Continue
        EndIf
        ; End added 3May2022 11.9.1
        j = aCue(i)\nFirstSubIndex
        While j >= 0
          If (aSub(j)\bSubEnabled) And (aSub(j)\bSubTypeAorF)
            ; debugMsg(sProcName, "aSub(" + getSubLabel(j) + ")\nSubState=" + decodeCueState(aSub(j)\nSubState))
            If (aSub(j)\nSubState >= #SCS_CUE_READY) And (aSub(j)\nSubState < #SCS_CUE_COMPLETED)
              k = aSub(j)\nFirstAudIndex
              While k >= 0
                ; If aAud(k)\nMaxCueMarker >= 0 ; Commented out 18Jun2020 11.8.3.2ae as skipCueMarker also available for sub-cues without cue markers
                  nReqdAudPtr = k
                  debugMsg(sProcName, "nReqdAudPtr=" + getAudLabel(nReqdAudPtr))
                  Break 3 ; Break k, j, i
                ; EndIf
                k = aAud(k)\nNextAudIndex
              Wend
            EndIf
          EndIf
          j = aSub(j)\nNextSubIndex
        Wend
      EndIf
    EndIf
  Next i
  ProcedureReturn nReqdAudPtr
  
EndProcedure

Procedure.s getCueMarkerDisplayInfo(nCueMarkerId, bShort=#False)
  ; PROCNAMEC()
  Protected n, sCueMarkerDisplayInfo.s
  
  ; debugMsg(sProcName, #SCS_START + ", nCueMarkerId=" + nCueMarkerId + ", bShort=" + strB(bShort))
  
  For n = 0 To gnMaxCueMarkerInfo
    If gaCueMarkerInfo(n)\nCueMarkerId = nCueMarkerId
      If bShort
        sCueMarkerDisplayInfo = gaCueMarkerInfo(n)\sCueMarkerDisplayInfoShort
      Else
        sCueMarkerDisplayInfo = gaCueMarkerInfo(n)\sCueMarkerDisplayInfo
      EndIf
      Break
    EndIf
  Next n
  ; debugMsg(sProcName, #SCS_END + " returning " + sCueMarkerDisplayInfo)
  ProcedureReturn sCueMarkerDisplayInfo
EndProcedure

Procedure skipCueMarker(nShortcutFunction)
  PROCNAMEC()
  Protected bNext, nSubPtr, nAudPtr, nCueAbsPos, nCueMarkerIndex, nCueMarkerPosition, nNewPos, bNewPosSet, nCueMarkerId
  Protected sCueMarkerDisplayInfo.s, sSkipMessage.s
  
  If nShortcutFunction = #SCS_WMNF_CueMarkerNext Or nShortcutFunction = #SCS_WEDF_CueMarkerNext
    bNext = #True
  EndIf
  If nShortcutFunction = #SCS_WMNF_CueMarkerPrev Or nShortcutFunction = #SCS_WMNF_CueMarkerNext
    nAudPtr = getAudPtrForCueMarkerPrevOrNext()
    If nAudPtr < 0
      nSubPtr = grWMN\nLastPlayingSubPtr
      If nSubPtr >= 0
        If aSub(nSubPtr)\bSubTypeAorF
          nAudPtr = aSub(nSubPtr)\nFirstAudIndex
        EndIf
      EndIf
    EndIf
  Else
    nAudPtr = nEditAudPtr
  EndIf
  While nAudPtr >= 0
    ; debugMsg(sProcName, "nShortcutFunction=" + decodeMenuItem(nShortcutFunction) + ", bNext=" + strB(bNext) + ", nAudPtr=" + getAudLabel(nAudPtr))
    With aAud(nAudPtr)
      ; debugMsg(sProcName, "aAud(" + getAudLabel(nAudPtr) + ")\nAudState=" + decodeCueState(\nAudState))
      ; Modified 7Sep2020 11.8.3.2aw - changed min nAudState from 'fading in' to 'ready' as skip cue marker is also meant to work on a cue that has not yet been started
      ; If \nAudState >= #SCS_CUE_FADING_IN And \nAudState <= #SCS_CUE_FADING_OUT And \nAudState <> #SCS_CUE_HIBERNATING
      If \nAudState >= #SCS_CUE_READY And \nAudState <= #SCS_CUE_FADING_OUT And \nAudState <> #SCS_CUE_HIBERNATING
        nCueAbsPos = \nCuePos + \nAbsMin
        ; debugMsg(sProcName, "aAud(" + getAudLabel(nAudPtr) + ")\nCuePos=" + \nCuePos + ", nCueAbsPos=" + nCueAbsPos)
        If bNext
          For nCueMarkerIndex = 0 To \nMaxCueMarker
            nCueMarkerPosition = \aCueMarker(nCueMarkerIndex)\nCueMarkerPosition
            If (nCueMarkerPosition > nCueAbsPos) And (nCueMarkerPosition <= \nAbsMax)
              nNewPos = nCueMarkerPosition
              nCueMarkerId = \aCueMarker(nCueMarkerIndex)\nCueMarkerId
              bNewPosSet = #True
              Break
            EndIf
          Next nCueMarkerIndex
          If bNewPosSet = #False
            ; no next cue marker, so skip to the 'absolute maximum', which will normally be the 'end at' position, but could be a 'loop end' position
            nNewPos = \nAbsMax
            nCueMarkerId = -1
            bNewPosSet = #True
          EndIf
        Else
          For nCueMarkerIndex = \nMaxCueMarker To 0 Step -1
            nCueMarkerPosition = \aCueMarker(nCueMarkerIndex)\nCueMarkerPosition
            If (nCueMarkerPosition < nCueAbsPos) And (nCueMarkerPosition >= \nAbsMin)
              nNewPos = nCueMarkerPosition
              nCueMarkerId = \aCueMarker(nCueMarkerIndex)\nCueMarkerId
              bNewPosSet = #True
              Break
            EndIf
          Next nCueMarkerIndex
          If bNewPosSet = #False
            ; no previous cue marker, so skip to the 'absolute minimum', which will normally be the 'start at' position, but could be a 'loop start' position
            nNewPos = \nAbsMin
            nCueMarkerId = -1
            bNewPosSet = #True
          EndIf
        EndIf
        If bNewPosSet
          debugMsg(sProcName, "calling reposAuds(" + getAudLabel(nAudPtr) + ", " + nNewPos + ", #True, #True), nCueMarkerId=" + nCueMarkerId)
          reposAuds(nAudPtr, nNewPos, #True, #True) ; Mod 19Mar2021 11.8.4ac - added bResyncOtherCues=#True following email from Michel Winogradoff
          If nShortcutFunction = #SCS_WMNF_CueMarkerPrev Or nShortcutFunction = #SCS_WMNF_CueMarkerNext
            If nCueMarkerId > 0
              sCueMarkerDisplayInfo = getCueMarkerDisplayInfo(nCueMarkerId)
              If sCueMarkerDisplayInfo
                sSkipMessage = LangPars("CueMarkerMsgs", "SkippedToMarker", sCueMarkerDisplayInfo)
                WMN_setStatusField(sSkipMessage)
              EndIf
            Else
              WMN_setStatusField("", #SCS_STATUS_CLEAR)
            EndIf
          EndIf
        EndIf ; EndIf bNewPosSet
      EndIf ; EndIf \nAudState >= #SCS_CUE_FADING_IN And \nAudState <= #SCS_CUE_FADING_OUT And \nAudState <> #SCS_CUE_HIBERNATING
    EndWith
    nAudPtr = aAud(nAudPtr)\nNextAudIndex
  Wend
  
EndProcedure

Procedure checkAddNewMarker()
  Protected bResult
  
  CompilerIf #c_cue_markers_for_video_files
    If grLicInfo\bCueMarkersAvailable
      bResult = #True
    EndIf
  CompilerElse 
    If grLicInfo\bCueMarkersAvailable And aAud(nEditAudPtr)\bAudTypeF
      bResult = #True
    EndIf
  CompilerEndIf
  If bResult = #False
    scsMessageRequester(#SCS_TITLE, Lang("Errors", "Unlicensed"))
  EndIf
  
  ProcedureReturn bResult
EndProcedure

Procedure addQuickCueMarker(*rMG.tyMG)
  ; Purpose is to add a Quick Cue Marker to the Current Audio or Video File at the mouse click position
  PROCNAMECA(nEditAudPtr)
  Protected bCanAddCueMarker, nMarkerName, sCueMarkerName.s, bNameUsed, nCueMarkerPosition
  Protected sAudioFileName.s
  Protected u, n
  
  debugMsg(sProcName, #SCS_START)
  
  If grLicInfo\bCueMarkersAvailable
    With aAud(nEditAudPtr)
      If \bAudPlaceHolder = #False
        bCanAddCueMarker = #True
      EndIf
      If bCanAddCueMarker
        If checkAddNewMarker()
          nMarkerName = 1
          sCueMarkerName = "M1"
          While #True
            bNameUsed = #False
            For n = 0 To \nMaxCueMarker
              If \aCueMarker(n)\sCueMarkerName = sCueMarkerName
                bNameUsed = #True
                Break
              EndIf
            Next n
            If bNameUsed = #False
              Break
            EndIf
            nMarkerName + 1
            sCueMarkerName = "M" + nMarkerName
          Wend
          u = preChangeAudL(\nMaxCueMarker, "Add Cue Marker: " + getAudLabel(nEditAudPtr) + " - " + sCueMarkerName)
          \nMaxCueMarker + 1
          If ArraySize(\aCueMarker()) < \nMaxCueMarker
            ReDim \aCueMarker(\nMaxCueMarker)
          EndIf
          gnUniqueCueMarkerId + 1
          \aCueMarker(\nMaxCueMarker) = grAudDef\aCueMarker(0)
          \aCueMarker(\nMaxCueMarker)\nCueMarkerId = gnUniqueCueMarkerId
          \aCueMarker(\nMaxCueMarker)\sCueMarkerName = sCueMarkerName
          nCueMarkerPosition = (*rMG\nMouseDownStartX - *rMG\nGraphLeft) * *rMG\fMillisecondsPerPixel
          debugMsg(sProcName, "*rMG\nMouseDownStartX=" + *rMG\nMouseDownStartX + ", nCueMarkerPosition=" + nCueMarkerPosition + " (" + timeToStringT(nCueMarkerPosition) + ")")
          \aCueMarker(\nMaxCueMarker)\nCueMarkerPosition = nCueMarkerPosition
          If \bAudTypeA
            WQA_refreshCueMarkersDisplayEtc()
          ElseIf \bAudTypeF
            WQF_refreshCueMarkersDisplayEtc()
          EndIf
          loadGridRow(nEditCuePtr)
          PNL_refreshDispPanel(nEditCuePtr, nEditSubPtr, nEditAudPtr, #True)
          If \bAudTypeF
            debugMsg(sProcName, "calling setBassMarkerPositions(" + getAudLabel(nEditAudPtr) + ")")
            setBassMarkerPositions(nEditAudPtr)
          EndIf
          postChangeAudL(u, \nMaxCueMarker)
        EndIf
      EndIf
    EndWith
  EndIf
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure createCueMarker()
  PROCNAMECA(nEditAudPtr)
  Protected nCueMarkerPosition
  Protected sCueMarkerName.s
  Protected u, sMsg.s
  Protected bUniqueName.b
  Protected sDefaultStr.s
  Protected n
  
  ; Only add new marker after we determine we can from all conditions
  If checkAddNewMarker()
    With aAud(nEditAudPtr)
      While bUniqueName = #False
        sCueMarkerName = Trim(InputRequester(Lang("menu", "mnuWQFEditCueMarker"), Lang("CueMarkerMsgs", "uniqueEditCueMarker"), sDefaultStr))
        If sCueMarkerName
          ; Check that the marker name is unique for this Audio or Video File set of Markers
          bUniqueName = #True
          For n = 0 To \nMaxCueMarker
            If \aCueMarker(n)\sCueMarkerName = sCueMarkerName
              bUniqueName = #False
              Break ; Break n
            EndIf
          Next n
          sDefaultStr = sCueMarkerName
          If Not bUniqueName
            sMsg = LangPars("Errors", "CannotDuplicateOCM", sCueMarkerName)
            scsMessageRequester(Lang("menu", "mnuWQFEditCueMarker"), sMsg, #MB_ICONEXCLAMATION)
          EndIf
        Else
          Break
        EndIf
      Wend
      
      If sCueMarkerName
        u = preChangeAudL(\nMaxCueMarker, "Add Cue Marker: " + \nMaxCueMarker + " - " + aAud(nEditAudPtr)\sCue)
        \nMaxCueMarker + 1
        If ArraySize(\aCueMarker()) < \nMaxCueMarker
          ReDim \aCueMarker(\nMaxCueMarker)
        EndIf
        gnUniqueCueMarkerId + 1
        \aCueMarker(\nMaxCueMarker) = grAudDef\aCueMarker(0)
        \aCueMarker(\nMaxCueMarker)\nCueMarkerId = gnUniqueCueMarkerId
        \aCueMarker(\nMaxCueMarker)\sCueMarkerName = sCueMarkerName
        ; Get the time location of the mouse click from the graph of the audio file
        nCueMarkerPosition = (grMG2\nMouseDownStartX - grMG2\nGraphLeft) * grMG2\fMillisecondsPerPixel
        \aCueMarker(\nMaxCueMarker)\nCueMarkerPosition = nCueMarkerPosition
        postChangeAudL(u, \nMaxCueMarker)
        refreshCueMarkersDisplayEtc()
      EndIf
    EndWith
  EndIf
EndProcedure

Procedure addCueMarker()
  PROCNAMECA(nEditAudPtr)
  Protected bCanAddCueMarker, nMarkerName, sCueMarkerName.s, bNameUsed, nCueMarkerPosition
  Protected sAudioFileName.s
  Protected u, n
  
  debugMsg(sProcName, #SCS_START)
  
  If grLicInfo\bCueMarkersAvailable
    With aAud(nEditAudPtr)
      If \bAudPlaceHolder = #False
        ; Changed 5Mar2024 11.10.2ba following email from CPeters 2Mar2024
        ; Deleted:
        ; Select \nAudState
        ;   Case #SCS_CUE_FADING_IN, #SCS_CUE_PLAYING, #SCS_CUE_FADING_OUT
        ;     ; specific tests mainly to avoid 'paused' and 'ready'
        ;     bCanAddCueMarker = #True
        ; EndSelect
        ; Added:
        If \nAudState >= #SCS_CUE_READY And \nAudState <= #SCS_CUE_COMPLETED
          bCanAddCueMarker = #True
        EndIf
        ; End changed 5Mar2024 11.10.2ba
      EndIf
      If bCanAddCueMarker
        If checkAddNewMarker()
          nMarkerName = 1
          sCueMarkerName = "M1"
          While #True
            bNameUsed = #False
            For n = 0 To \nMaxCueMarker
              If \aCueMarker(n)\sCueMarkerName = sCueMarkerName
                bNameUsed = #True
                Break
              EndIf
            Next n
            If bNameUsed = #False
              Break
            EndIf
            nMarkerName + 1
            sCueMarkerName = "M" + nMarkerName
          Wend
          u = preChangeAudL(\nMaxCueMarker, "Add Cue Marker: " + getAudLabel(nEditAudPtr) + " - " + sCueMarkerName)
          \nMaxCueMarker + 1
          If ArraySize(\aCueMarker()) < \nMaxCueMarker
            ReDim \aCueMarker(\nMaxCueMarker)
          EndIf
          gnUniqueCueMarkerId + 1
          \aCueMarker(\nMaxCueMarker) = grAudDef\aCueMarker(0)
          \aCueMarker(\nMaxCueMarker)\nCueMarkerId = gnUniqueCueMarkerId
          \aCueMarker(\nMaxCueMarker)\sCueMarkerName = sCueMarkerName
          nCueMarkerPosition = \nRelFilePos + \nAbsMin
          \aCueMarker(\nMaxCueMarker)\nCueMarkerPosition = nCueMarkerPosition
          postChangeAudL(u, \nMaxCueMarker)
          refreshCueMarkersDisplayEtc()
        EndIf
      EndIf
    EndWith
  EndIf
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure setCueMarkerPosition(*rMG.tyMG)
  PROCNAMECA(nEditAudPtr)
  Protected nCueMarkerId, nCueMarkerIndex
  Protected nCueMarkerPosition, nNewMarkerPosition, nMinPosition, nMaxPosition
  Protected sMarkerTime.s, sCueMarkerName.s, sRequestMsg.s, sNewMarkerPosition.s, sMsg.s
  Protected u
  
  debugMsg(sProcName, #SCS_START)
  
  If nEditAudPtr >= 0
    With aAud(nEditAudPtr)
      ; Obtain the clicked Cue Marker Index
      nCueMarkerId = *rMG\nMouseDownCueMarkerId
      nCueMarkerIndex = getCueMarkerIndexForCueMarkerId(nEditAudPtr, nCueMarkerId)
      
      If nCueMarkerIndex >= 0
        nCueMarkerPosition = \aCueMarker(nCueMarkerIndex)\nCueMarkerPosition
        sCueMarkerName = \aCueMarker(nCueMarkerIndex)\sCueMarkerName
        sRequestMsg = LangPars("WQF", "NewPos", sCueMarkerName)
        
        sMarkerTime = ttszt(nCueMarkerPosition)
        While #True
          sMarkerTime = Trim(InputRequester(Lang("Menu", "mnuWQFSetCueMarkerPos"), sRequestMsg, sMarkerTime))
          If sMarkerTime ; Set the New Marker Position
            sNewMarkerPosition = Lang("WQF", "CueMarkerPosition")
            If validateTimeFieldT(sMarkerTime, sNewMarkerPosition, #False, #False) = #False
              Continue  
            EndIf
            nNewMarkerPosition = stringToTime(sMarkerTime)
            nMinPosition = getMinTimeForACueMarker(nEditAudPtr)
            nMaxPosition = getMaxTimeForACueMarker(nEditAudPtr)
            
            ; Not happy with marker position being outside the boundaries
            If (nNewMarkerPosition < nMinPosition)  Or (nNewMarkerPosition > nMaxPosition) 
              sMsg = LangPars("Errors", "MustBeBetween", sNewMarkerPosition + " (" + ttszt(nNewMarkerPosition) + ")", ttszt(nMinPosition), ttszt(nMaxPosition))
              debugMsg(sProcName, sMsg)
              scsMessageRequester(grText\sTextValErr, sMsg, #PB_MessageRequester_Error)
              Continue  
            EndIf
            
            ; A new Position obtained and is inside the boundaries so apply new position to the cue marker
            If nNewMarkerPosition <> nCueMarkerPosition
              u = preChangeAudL(nCueMarkerPosition, sNewMarkerPosition + " (" + nCueMarkerIndex + ")", -5, #SCS_UNDO_ACTION_CHANGE, -1, #SCS_UNDO_FLAG_DISPLAYSUB | #SCS_UNDO_FLAG_SET_CUE_PTRS)
              \aCueMarker(nCueMarkerIndex)\nCueMarkerPosition = nNewMarkerPosition
              postChangeAudLN(u, nNewMarkerPosition)
              refreshCueMarkersDisplayEtc()
              loadGridRow(nEditCuePtr)
              PNL_refreshDispPanel(nEditCuePtr, nEditSubPtr, nEditAudPtr, #True)
            EndIf ; End Set New Cue Marker Position
          EndIf ; End Set New Marker Position
          Break
        Wend
      EndIf ; EndIf nCueMarkerIndex >= 0
      If \bAudTypeF
        debugMsg(sProcName, "calling setBassMarkerPositions(" + getAudLabel(nEditAudPtr) + ")")
        setBassMarkerPositions(nEditAudPtr)
      EndIf
      debugMsg(sProcName, "calling propogateCueMarkerPositionChange(" + getAudLabel(nEditAudPtr) + ", " + nCueMarkerId + ")")
      propogateCueMarkerPositionChange(nEditAudPtr, nCueMarkerId)
      gbForceReloadAllDispPanels = #True
      gbCallLoadDispPanels = #True
    EndWith
    
  EndIf
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure refreshCueMarkersDisplayEtc()
  With aAud(nEditAudPtr)
    If \bAudTypeF
      WQF_refreshCueMarkersDisplayEtc()
    ElseIf \bAudTypeA
      WQA_refreshCueMarkersDisplayEtc()
    EndIf
  EndWith
EndProcedure

Procedure editCueMarkerName(nCueMarkerIndex)
  PROCNAMECA(nEditAudPtr)
  Protected sCueMarkerNameOld.s, sCueMarkerNameNew.s
  Protected u, n
  Protected bUniqueName
  
  With aAud(nEditAudPtr)
    sCueMarkerNameOld = Trim(\aCueMarker(nCueMarkerIndex)\sCueMarkerName)
    sCueMarkerNameNew = sCueMarkerNameOld
    While bUniqueName = #False
      sCueMarkerNameNew = Trim(InputRequester(Lang("menu", "mnuWQFEditCueMarker"), Lang("CueMarkerMsgs", "uniqueEditCueMarker"),  sCueMarkerNameOld))
      If sCueMarkerNameNew
        If sCueMarkerNameNew = sCueMarkerNameOld
          Break
          ; Do nothing as the Name is the same but end condition
        Else
          ; Check that the marker name is unique for this Audio File set of Markers
          bUniqueName = #True
          For n = 0 To \nMaxCueMarker
            If \aCueMarker(n)\sCueMarkerName = sCueMarkerNameNew
              bUniqueName = #False
              Break ; Break n
            EndIf
          Next n
        EndIf
      Else
        ; Only get here if cancelling or new name is blank
        sCueMarkerNameNew = sCueMarkerNameOld
        Break
      EndIf 
    Wend
    
    If sCueMarkerNameNew <> sCueMarkerNameOld
      u = preChangeAudS(sCueMarkerNameOld, "Edit Cue Marker Name: " + getAudLabel(nEditAudPtr) + " " + sCueMarkerNameOld)
      \aCueMarker(nCueMarkerIndex)\sCueMarkerName = sCueMarkerNameNew
      propogateCueMarkerNameChange(\sCue, \nSubNo, sCueMarkerNameOld, sCueMarkerNameNew)
      postChangeAudS(u, sCueMarkerNameNew)
      refreshCueMarkersDisplayEtc()
    EndIf
    
  EndWith  
EndProcedure

Procedure editCueMarker(*rMG.tyMG)
  PROCNAMECA(nEditAudPtr)
  Protected nCueMarkerId, nCueMarkerIndex
  
  debugMsg(sProcName, #SCS_START)
  
  ; refresh_ProcessCueMarkerFullNames()
  If *rMG\nMouseDownSliceType = #SCS_SLICE_TYPE_CM
    nCueMarkerId = *rMG\nMouseDownCueMarkerId
    nCueMarkerIndex = getCueMarkerIndexForCueMarkerId(nEditAudPtr, nCueMarkerId)
    If nCueMarkerIndex >= 0
      ; edit an existing Cue Marker's name
      editCueMarkerName(nCueMarkerIndex)
    EndIf
  Else
    ; create a new Cue Marker at the current mouse position
    createCueMarker()
  EndIf
  
  If aAud(nEditAudPtr)\bAudTypeF
    debugMsg(sProcName, "calling setBassMarkerPositions(" + getAudLabel(nEditAudPtr) + ")")
    setBassMarkerPositions(nEditAudPtr)
  EndIf
  
  If nCueMarkerId
    debugMsg(sProcName, "calling propogateCueMarkerPositionChange(" + getAudLabel(nEditAudPtr) + ", " + nCueMarkerId + ")")
    propogateCueMarkerPositionChange(nEditAudPtr, nCueMarkerId)
    gbForceReloadAllDispPanels = #True
    gbCallLoadDispPanels = #True
  EndIf
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure removeCueMarker(*rMG.tyMG)
  PROCNAMECA(nEditAudPtr)
  Protected u, nSize, nDeleteIndex, nCount, n
  Protected nCueMarkerId, nCueMarkerIndex, nMDST, nCMCount
  Protected sDeleteMarkerName.s, sCue.s, sTestName.s, sErrorMsg.s
  
  debugMsg(sProcName, #SCS_START)
  
  nMDST = *rMG\nMouseDownSliceType
  If nMDST = #SCS_SLICE_TYPE_CM
    nCueMarkerId = *rMG\nMouseDownCueMarkerId
    nCueMarkerIndex = getCueMarkerIndexForCueMarkerId(nEditAudPtr, nCueMarkerId)
    sCue = aAud(nEditAudPtr)\sCue
    sDeleteMarkerName = aAud(nEditAudPtr)\aCueMarker(nCueMarkerIndex)\sCueMarkerName
    ; With the Cue Marker Index and the Cue Marker Name we need to check if it being used for OCM
    For n = 0 To gnMaxOCMMatrixItem
      If gaOCMMatrix(n)\nCueMarkerId = nCueMarkerId
        If gaOCMMatrix(n)\nOCMSubPtr >= 0
          sErrorMsg = LangPars("CueMarkerMsgs", "MarkerInUse", sDeleteMarkerName, getSubLabel(gaOCMMatrix(n)\nOCMSubPtr))
        Else
          sErrorMsg = LangPars("CueMarkerMsgs", "MarkerInUse", sDeleteMarkerName, getCueLabel(gaOCMMatrix(n)\nOCMCuePtr))
        EndIf
        MessageRequester(Lang("Menu", "mnuWQFRemoveCueMarker"), sErrorMsg, #PB_MessageRequester_Warning)
        ProcedureReturn  ; Selected Cue Marker is being used
      EndIf
    Next n
    
    ; Remove graph marker for cue marker from the *rMG\aGraphMarker array
    removeGraphMarkerForCueMarker(*rMG, nCueMarkerId)
    
    With aAud(nEditAudPtr)
      If \nMaxCueMarker >= 0
        u = preChangeAudL(\nMaxCueMarker, "Remove Cue Marker: " + Str(\nMaxCueMarker) + " - " + getAudLabel(nEditAudPtr))
        For n = nCueMarkerIndex To \nMaxCueMarker - 1
          \aCueMarker(n) = \aCueMarker(n+1)
        Next n
        \nMaxCueMarker-1
        If \bAudTypeF
          WQF_fcLevelPointInfo()
          ; debugMsg(sProcName, "calling setBassMarkerPositions(" + getAudLabel(nEditAudPtr) + ")")
          setBassMarkerPositions(nEditAudPtr)
        EndIf
        postChangeAudL(u, -1)
      EndIf
      refreshCueMarkersDisplayEtc()
    EndWith
  EndIf
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure syncCueAutoActInfoWithCueMarkerIds()
  PROCNAMEC()
  Protected i, nAutoActCueMarkerId
  Protected i2, j2, k2, m2
  Protected bCueMarkerFound
  
  For i = 1 To gnLastCue
    With aCue(i)
      If \nActivationMethod = #SCS_ACMETH_OCM
        nAutoActCueMarkerId = \nAutoActCueMarkerId
        ; Find the sub-cue that contains this cue marker id
        For i2 = 1 To gnLastCue
          j2 = aCue(i2)\nFirstSubIndex
          While j2 >= 0
            If aSub(j2)\bSubTypeAorF
              k2 = aSub(j2)\nFirstAudIndex
              While k2 >= 0
                For m2 = 0 To aAud(k2)\nMaxCueMarker
                  If aAud(k2)\aCueMarker(m2)\nCueMarkerId = nAutoActCueMarkerId
                    debugMsg(sProcName, "aCue(" + getCueLabel(i) + ")\nAutoActCueMarkerId " + \nAutoActCueMarkerId + " found in aAud(" + getAudLabel(k2) + ")")
                    bCueMarkerFound = #True
                    \nAutoActCuePtr = i2
                    \nAutoActSubNo = aSub(j2)\nSubNo
                    \nAutoActSubId = aSub(j2)\nSubId
                    \nAutoActAudNo = aAud(k2)\nAudNo
                    \nAutoActAudId = aAud(k2)\nAudId
                    Break 4 ; Break m2, k2, j2, i2
                  EndIf
                Next m2
                k2 = aAud(k2)\nNextAudIndex
              Wend
            EndIf
            j2 = aSub(j2)\nNextSubIndex
          Wend
        Next i2
      EndIf
    EndWith
  Next i
  ; Return #True if a cue marker is found - not necessarily causing an actual change
  ProcedureReturn bCueMarkerFound
  
EndProcedure

; EOF