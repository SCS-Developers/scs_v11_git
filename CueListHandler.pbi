; File: CueListHandler.pbi

EnableExplicit

Procedure getTreeItemNoForNodeKey(nNodeKey)
  PROCNAMEC()
  Protected n, nItemNo
  
  nItemNo = -1
  For n = 0 To (CountGadgetItems(WED\tvwProdTree)-1)
    If GetGadgetItemData(WED\tvwProdTree, n) = nNodeKey
      nItemNo = n
      Break
    EndIf
  Next n
  
  ProcedureReturn nItemNo
EndProcedure

Procedure addCueNode(pCuePtr, nBeforeNodeKey=0)
  PROCNAMECQ(pCuePtr)
  ; see also WED_setCueNodeText()
  Protected j, nImage, nSubCount
  Protected nNodeKey, sNodeText.s
  Protected nCueNodePos, nSubNodePos
;   Protected bAllSubsDisabled

  ; debugMsg(sProcName, #SCS_START + ", nBeforeNodeKey=" + Str(nBeforeNodeKey))

  grCLH\mbMulti = #False
  j = aCue(pCuePtr)\nFirstSubIndex
  nImage = 0
  If j >= 0
    If aSub(j)\nNextSubIndex >= 0
      grCLH\mbMulti = #True
      If aCue(pCuePtr)\bNodeExpanded
        nImage = hClMultiOpen
      Else
        nImage = hClMultiClosed
      EndIf
    ElseIf aSub(j)\bSubTypeA
      If IMG_checkForUseCameraIcon(j)
        nImage = hClCamera
      Else
        nImage = hClVideo
      EndIf
    ElseIf aSub(j)\bSubTypeE
      nImage = hClMemo
    ElseIf aSub(j)\bSubTypeF
      nImage = hClAudio
    ElseIf aSub(j)\bSubTypeG
      nImage = hClGoToCue
    ElseIf aSub(j)\bSubTypeI
      If IMG_checkForUseLiveInputOffIcon(j)
        nImage = hClLiveInputOff
      Else
        nImage = hClLiveInput
      EndIf
    ElseIf aSub(j)\bSubTypeJ
      nImage = hClEnaDis
    ElseIf aSub(j)\bSubTypeK
      nImage = hClLighting
    ElseIf aSub(j)\bSubTypeL
      nImage = hClLvlChg
    ElseIf aSub(j)\bSubTypeM
      nImage = hClCtrlSend
    ElseIf aSub(j)\bSubTypeN
      nImage = hClNote
    ElseIf aSub(j)\bSubTypeP
      nImage = hClPlaylist
    ElseIf aSub(j)\bSubTypeQ
      nImage = hClCallCue
    ElseIf aSub(j)\bSubTypeR
      nImage = hClRun
    ElseIf aSub(j)\bSubTypeS
      nImage = hClSFR
    ElseIf aSub(j)\bSubTypeT
      nImage = hClSetPos
    ElseIf aSub(j)\bSubTypeU
      nImage = hClMTC
    EndIf
  EndIf

  If nImage = 0
    nImage = hClAudio
  EndIf

  With aCue(pCuePtr)
    If \bCueEnabled = #False
      nImage = hClDisabled
    ElseIf \nFirstSubIndex >= 0
      If \bCueSubsAllDisabled
        nImage = hClDisabled
      EndIf
    EndIf
    \nNodeImageHandle = nImage
    sNodeText = WED_buildCueNodeText(pCuePtr)
    nNodeKey = \nNodeKey
  EndWith
  
  If nBeforeNodeKey = 0
    nCueNodePos = -1
  Else
    nCueNodePos = getTreeItemNoForNodeKey(nBeforeNodeKey)
  EndIf
  
  ; debugMsg(sProcName, "calling AddGadgetItem(WED\tvwProdTree, " + Str(nCueNodePos) + ", " + sNodeText + ", ImageID(" + Str(nImage) + "), 1)")
  AddGadgetItem(WED\tvwProdTree, nCueNodePos, sNodeText, ImageID(nImage), 1)
  If nCueNodePos = -1
    nCueNodePos = CountGadgetItems(WED\tvwProdTree)-1
  EndIf
  SetGadgetItemData(WED\tvwProdTree, nCueNodePos, nNodeKey)

  ; the following not available in PB, because PB doesn't provide for setting the font on gadget items, only on the gadget
  ; If aCue(pCuePtr)\bCueEnabled
    ; \Font\Strikethrough = #True
  ; EndIf
  
  ; debugMsg(sProcName, "pCuePtr=" + pCuePtr)

  ; add subs if multi
  If grCLH\mbMulti
    nSubCount = 0
    nSubNodePos=nCueNodePos ; will be incremented in the 'while' loop
    j = aCue(pCuePtr)\nFirstSubIndex
    While j >= 0
      nSubCount + 1
      nSubNodePos + 1
      If aSub(j)\bSubTypeA
        nImage = hClVideo
      ElseIf aSub(j)\bSubTypeE
        nImage = hClMemo
      ElseIf aSub(j)\bSubTypeF
        nImage = hClAudio
      ElseIf aSub(j)\bSubTypeG
        nImage = hClGoToCue
      ElseIf aSub(j)\bSubTypeI
        nImage = hClLiveInput
      ElseIf aSub(j)\bSubTypeJ
        nImage = hClEnaDis
      ElseIf aSub(j)\bSubTypeK
        nImage = hClLighting
      ElseIf aSub(j)\bSubTypeL
        nImage = hClLvlChg
      ElseIf aSub(j)\bSubTypeM
        nImage = hClCtrlSend
      ElseIf aSub(j)\bSubTypeN
        nImage = hClNote
      ElseIf aSub(j)\bSubTypeP
        nImage = hClPlaylist
      ElseIf aSub(j)\bSubTypeQ
        nImage = hClCallCue
      ElseIf aSub(j)\bSubTypeR
        nImage = hClRun
      ElseIf aSub(j)\bSubTypeS
        nImage = hClSFR
      ElseIf aSub(j)\bSubTypeT
        nImage = hClSetPos
      ElseIf aSub(j)\bSubTypeU
        nImage = hClMTC
      EndIf
      If aSub(j)\bSubEnabled = #False
        nImage = hClDisabled
      EndIf
      sNodeText = "<" + aSub(j)\nSubNo + "> " + aSub(j)\sSubDescr
      nNodeKey = aSub(j)\nNodeKey
      AddGadgetItem(WED\tvwProdTree, nSubNodePos, sNodeText, ImageID(nImage), 2)
      SetGadgetItemData(WED\tvwProdTree, nSubNodePos, nNodeKey)
      
      j = aSub(j)\nNextSubIndex
    Wend
  EndIf
  
  ; debugMsg(sProcName, "aCue(pCuePtr)\bNodeExpanded=" + strB(aCue(pCuePtr)\bNodeExpanded))
  If aCue(pCuePtr)\bNodeExpanded
    SetGadgetItemState(WED\tvwProdTree, nCueNodePos, #PB_Tree_Expanded)
  Else
    SetGadgetItemState(WED\tvwProdTree, nCueNodePos, #PB_Tree_Collapsed)
  EndIf
  grWED\nTreeGadgetItemExpanded = 0  ; cancel indicator set by WED_windowCallback()
  
EndProcedure

Procedure populateProdTree()
  PROCNAMEC()
  Protected i
  Protected bEnableExpandAll, bEnableCollapseAll
  Protected nProdNodePos
  Protected sProdNodeText.s
  
  debugMsg(sProcName, #SCS_START)
  
  setVisible(WED\tvwProdTree, #False)
  debugMsg(sProcName, "calling ClearGadgetItems(WED\tvwProdTree)")
  ClearGadgetItems(WED\tvwProdTree)
  
  gnSelectedNodeKey = -1
  grCED\nSelectedItemForDragAndDrop = -1
  
  debugMsg(sProcName, "add prod node")
  ; add production node
  If grProd\bTemplate
    sProdNodeText = grProd\sTmName + " (" + grText\sTextTemplate + ")"
  Else
    sProdNodeText = grProd\sTitle
  EndIf
  debugMsg(sProcName, "grProd\nNodeKey=" + grProd\nNodeKey)
  debugMsg(sProcName, "calling AddGadgetItem(WED\tvwProdTree, -1, " + sProdNodeText + ", ImageID(" + hClProd + "), 0)")
  AddGadgetItem(WED\tvwProdTree, -1, sProdNodeText, ImageID(hClProd), 0)
  nProdNodePos = CountGadgetItems(WED\tvwProdTree)-1
  SetGadgetItemData(WED\tvwProdTree, nProdNodePos, grProd\nNodeKey)
  
  debugMsg(sProcName, "add cue nodes")
  For i = 1 To gnLastCue
    addCueNode(i)
  Next i
  
  debugMsg(sProcName, "expand prod node")
  SetGadgetItemState(WED\tvwProdTree, nProdNodePos, #PB_Tree_Expanded)
  grWED\nTreeGadgetItemExpanded = 0  ; cancel indicator set by WED_windowCallback()
  
  debugMsg(sProcName, "calling setTBSButtons")
  WED_setTBSButtons()
  
  setVisible(WED\tvwProdTree, #True)
  
  debugMsg(sProcName, #SCS_END)
EndProcedure

Procedure getNodeTypeForNodeKey(nNodeKey)
  PROCNAMEC()
  Protected n, nNodeType
  Protected i, j
  
  If grProd\nNodeKey = nNodeKey
    nNodeType = #SCS_NODE_TYPE_PROD
  EndIf
  
  If nNodeType = 0
    For i = 1 To gnLastCue
      If aCue(i)\nNodeKey = nNodeKey
        nNodeType = #SCS_NODE_TYPE_CUE
        j = aCue(i)\nFirstSubIndex
        If j >= 0
          If aSub(j)\nNextSubIndex >= 0
            nNodeType = #SCS_NODE_TYPE_MULTI
          EndIf
        EndIf
      Else
        j = aCue(aCue(i)\nFirstSubIndex)
        While j >= 0
          If aSub(j)\nNodeKey = nNodeKey
            nNodeType = #SCS_NODE_TYPE_SUB
            Break
          EndIf
          j = aSub(j)\nNextSubIndex
        Wend
      EndIf
      If nNodeKey<>0
        Break
      EndIf
    Next i
  EndIf
  
  ProcedureReturn nNodeType
  
EndProcedure

; EOF
