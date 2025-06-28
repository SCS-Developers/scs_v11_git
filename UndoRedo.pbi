; File: UndoRedo.pbi
; abbreviation: MUR

EnableExplicit

Procedure changedSinceLastSave()
  ; PROCNAMEC()
  Protected nLatestUndoGroupId
  
  With grMUR
    If \nUndoGroupPtr = -1
      nLatestUndoGroupId = -1
    Else
      nLatestUndoGroupId = gaUndoGroup(\nUndoGroupPtr)\nUndoGroupId
    EndIf
    If nLatestUndoGroupId = \nLatestUndoGroupIdAtSave
      ; debugMsg(sProcName, "#False \nUndoGroupPtr=" + \nUndoGroupPtr + ", nLatestUndoGroupId=" + nLatestUndoGroupId + ", \nLatestUndoGroupIdAtSave=" + \nLatestUndoGroupIdAtSave)
      ProcedureReturn #False
    Else
      ; debugMsg(sProcName, "#True \nUndoGroupPtr=" + \nUndoGroupPtr + ", nLatestUndoGroupId=" + nLatestUndoGroupId + ", \nLatestUndoGroupIdAtSave=" + \nLatestUndoGroupIdAtSave)
      ProcedureReturn #True
    EndIf
  EndWith
EndProcedure

Procedure clearUndoItems()
;   PROCNAMEC()

  With grMUR
    \nUndoGroupPtr = -1
    ; debugMsg(sProcName, "\nUndoGroupPtr=" + \nUndoGroupPtr)
    \nMaxRedoGroupPtr = -1
    \nUndoItemPtr = 0   ; valid index starts at 1 so that an unintialised index of 0 indicates preChangeItemInfo was not called
    \nB4ProdPtr = -1
    \nB4DevChgsPtr = -1
    \nB4CuePtr = -1
    \nB4SubPtr = -1
    \nB4AudPtr = -1
    \nAftProdPtr = -1
    \nAftDevChgsPtr = -1
    \nAftCuePtr = -1
    \nAftSubPtr = -1
    \nAftAudPtr = -1
    \nUniqueUndoGroupId = 1000
    \nUniqueUndoId = 5000
    \nCurrUndoGroupId = -1
    \nCurrUndoItemId = -1
    \nPrimaryUndoGroupId = -1
    \nLatestUndoGroupIdAtSave = -1
  EndWith

EndProcedure

Procedure initUndoItems()
  PROCNAMEC()
  Static bInitUndoItemsDone
  debugMsg(sProcName, #SCS_START)

  If bInitUndoItemsDone = #False
    ReDim gaUndoGroup(10)
    ReDim gaUndoItem(10)
    ReDim gaB4ImageProd(10)
    ReDim gaB4ImageDevChgs(10)
    ReDim gaB4ImageCue(10)
    ReDim gaB4ImageSub(10)
    ReDim gaB4ImageAud(10)
    ReDim gaAftImageProd(10)
    ReDim gaAftImageDevChgs(10)
    ReDim gaAftImageCue(10)
    ReDim gaAftImageSub(10)
    ReDim gaAftImageAud(10)
    bInitUndoItemsDone = #True
  EndIf
  clearUndoItems()
EndProcedure

Procedure newUndoGroup(nItemType, nItemId, nAction, nOldPtr, nNewPtr, nSubRef, sDescr.s, nExtraParam)
  PROCNAMEC()

  ; debugMsg(sProcName, #SCS_START)
  
  grMUR\nUndoGroupPtr + 1
  ; debugMsg(sProcName, "\nUndoGroupPtr=" + grMUR\nUndoGroupPtr)
  If grMUR\nUndoGroupPtr >= ArraySize(gaUndoGroup())
    ReDim gaUndoGroup(grMUR\nUndoGroupPtr + 100)
  EndIf
  grMUR\nUniqueUndoGroupId + 1

  With gaUndoGroup(grMUR\nUndoGroupPtr)
    \nUndoGroupId = grMUR\nUniqueUndoGroupId
    \nPrimaryAction = nAction
    \nPrimaryItemId = nItemId
    \nPrimaryType = nItemType
    \nPrimaryOldPtr = nOldPtr
    \nPrimaryNewPtr = nNewPtr
    \nPrimarySubRef = nSubRef
    \sPrimaryDescr = Trim(sDescr)
    \nPrimaryExtraParam = nExtraParam
    ; save state of pointers so that on cancelling the group we can recover the space used in the arrays.
    \nStartUndoItemPtr = grMUR\nUndoItemPtr
    \nStartB4ProdPtr = grMUR\nB4ProdPtr
    \nStartB4CuePtr = grMUR\nB4CuePtr
    \nStartB4SubPtr = grMUR\nB4SubPtr
    \nStartB4AudPtr = grMUR\nB4AudPtr
    \nStartAftProdPtr = grMUR\nAftProdPtr
    \nStartAftCuePtr = grMUR\nAftCuePtr
    \nStartAftSubPtr = grMUR\nAftSubPtr
    \nStartAftAudPtr = grMUR\nAftAudPtr
    If gbEditorFormLoaded
      If GetGadgetState(WED\tvwProdTree) >= 0
        \nSelectedNodeKey = GetGadgetItemData(WED\tvwProdTree, GetGadgetState(WED\tvwProdTree))
      EndIf
    EndIf
    ; debugMsg(sProcName, "gaUndoGroup(" + grMUR\nUndoGroupPtr + ")\nSelectedNodeKey=" + \nSelectedNodeKey + ", \nUndoGroupId=" + \nUndoGroupId)
  EndWith
  
  ; debugMsg(sProcName, "setting nCurrUndoGroupId=" + grMUR\nUniqueUndoGroupId + " (was " + grMUR\nCurrUndoGroupId + ")")
  grMUR\nCurrUndoGroupId = grMUR\nUniqueUndoGroupId
  
  ; debugMsg(sProcName, #SCS_END)

EndProcedure

Procedure preChangeItemInfo(nItemType, nOldPtr, nItemId, nAction, nFlags, nSubRef, sDescr.s, nExtraParam, bForceNewGroup=#False)
  PROCNAMEC()
  ; to be called by preChangeProd/Cue/Sub/Aud... functions
  ; nItemId must ALWAYS be set, even for new items, as the function relies on this value for detecting multiple changes to the same item
  ;  For example, if you add an audio file and in the same functional operation set the level to -3dB then this may come thru as two changes,
  ;  one to add the audio file and another to change the level. A before image for the change level must not be created as the audio file was added
  ;  in this functional operation.
  ; nOldPtr to be set to -1 if there is no b4image, ie if this 'change' is for a new prod, cue, sub or aud
  ; function returns item pointer
  ; gbItemKnown will be set True if this item (eg this subcue) has already been logged for this undo group, which implies the calling function does not need to save the b4Image

  ; if no b4image is to be saved for the primary item (eg this is a new cue) then no b4images are to be saved for any secondary items

  Protected bPrimary
  Protected bMyItemKnown
  Protected n
  Protected bMySameAsLastGroup
  Protected nMyUndoItemPtr
  Protected sMyDescr.s

  sMyDescr = Trim(ReplaceString(sDescr, Chr(10), " "))
;   debugMsg(sProcName, #SCS_START + ", nType=" + decodeUndoType(nItemType) + ", nItemId=" + nItemId + ", nAction=" + decodeUndoAction(nAction) +
;                       ", nFlags=" + nFlags + ", nOldPtr=" + nOldPtr + ", nSubRef=" + nSubRef +
;                       ", sMyDescr=" + Chr(34) + sMyDescr + Chr(34) +
;                       ", nExtraParam=" + nExtraParam +
;                       ", nPrimaryUndoGroupId=" + grMUR\nPrimaryUndoGroupId + ", nUndoGroupPtr=" + grMUR\nUndoGroupPtr)
  
  ; temp(?) test - see note about nItemId at beginning of function
  If nItemId <= 0
    scsMessageRequester(Lang("CED","UndoRedo"), sProcName + " nItemId=" + nItemId, #PB_MessageRequester_Error)
    ProcedureReturn -1
  EndIf

  gqLastChangeTime = gqTimeNow
  
  ; debugMsg(sProcName, "grMUR\nPrimaryUndoGroupId=" + grMUR\nPrimaryUndoGroupId + ", bForceNewGroup=" + strB(bForceNewGroup))
  
  If grMUR\nPrimaryUndoGroupId = -1
    ; primary item - check if a new undo group or if another change for the last group, based on the change to the primary item
    For n = grMUR\nUndoGroupPtr To 0 Step -1
      If gaUndoGroup(n)\nUndoGroupId <> grMUR\nCurrUndoGroupId
        Break
      Else
       If gaUndoGroup(n)\nPrimaryItemId = nItemId
        If gaUndoGroup(n)\nPrimaryType = nItemType And gaUndoGroup(n)\nPrimaryAction = nAction
          Select nAction
            Case #SCS_UNDO_ACTION_MOVE_SUB
              ; debugMsg(sProcName, "nAction=UNDO_ACTION_MOVE_SUB")
              If (nSubRef > 0 And gaUndoGroup(n)\nPrimarySubRef = nSubRef)
                ; debugMsg(sProcName, "same undo group (" + grMUR\nCurrUndoGroupId + ")")
                bMySameAsLastGroup = #True
                Break
              EndIf
            Case #SCS_UNDO_ACTION_ADD, #SCS_UNDO_ACTION_ADD_CUE, #SCS_UNDO_ACTION_ADD_SUB, #SCS_UNDO_ACTION_ADD_AUD
              ; debugMsg(sProcName, "nAction=UNDO_ACTION_ADD...")
              ; consecutive add operations not to be treated as same group as they must be undone separately
              ; nb only get here if nPrimaryUndoGroupId = -1, so does not affect dragging multiple audio files into the cue list
              ; as these will all be handled in a single operation and so will be in the same group
              Break
            Case #SCS_UNDO_ACTION_DRAG_CUE
              Break
            Default
              If (gaUndoGroup(n)\sPrimaryDescr = Trim(sMyDescr) And Len(Trim(sMyDescr)) > 0)
                bMySameAsLastGroup = #True
                bPrimary = #True
                Break
              EndIf
            EndSelect
          EndIf
        EndIf
      EndIf
    Next n
    
    If (bMySameAsLastGroup = #False) Or (grMUR\nCurrUndoGroupId = grMUR\nLatestUndoGroupIdAtSave) Or (bForceNewGroup)
      newUndoGroup(nItemType, nItemId, nAction, nOldPtr, -1, nSubRef, sMyDescr, nExtraParam) ; create a new group
      bPrimary = #True
    EndIf
    
    grMUR\nPrimaryUndoGroupId = grMUR\nCurrUndoGroupId
    
  EndIf

  If grMUR\nUndoItemPtr >= 0
    ; now check if record has already been changed for this nUndoGroupId
    For n = grMUR\nUndoItemPtr To 1 Step -1
      If (gaUndoItem(n)\nUndoGroupId = grMUR\nCurrUndoGroupId)
        If (gaUndoItem(n)\nItemType = nItemType) And (gaUndoItem(n)\nItemId = nItemId)
          bMyItemKnown = #True
          nMyUndoItemPtr = n
          Break
        EndIf
      EndIf
    Next n
  EndIf

  If bMyItemKnown = #False
    grMUR\nUndoItemPtr = grMUR\nUndoItemPtr + 1
    If grMUR\nUndoItemPtr >= ArraySize(gaUndoItem())
      ReDim gaUndoItem(grMUR\nUndoItemPtr + 100)
    EndIf
    nMyUndoItemPtr = grMUR\nUndoItemPtr
    grMUR\nUniqueUndoId = grMUR\nUniqueUndoId + 1              ; makes \nUndoItemId always unique, regardless of undo's and redo's
    With gaUndoItem(nMyUndoItemPtr)
      \nUndoItemId = grMUR\nUniqueUndoId
      \nUndoGroupId = grMUR\nCurrUndoGroupId
      \bCancelled = #False
      \nItemType = nItemType
      \nItemId = nItemId
      \nAction = nAction
      \nFlags = nFlags
      If bPrimary
        \bSecondaryChange = #False
      Else
        \bSecondaryChange = #True
      EndIf
      \nOldPtr = nOldPtr
      \nNewPtr = -1
      \nSubRef = nSubRef
      \nB4Ptr = -1
      \nAftPtr = -1
      \sDescr = Trim(sMyDescr)
      \nExtraParam = nExtraParam
      Select gvWork\nVarType
        Case #SCS_VAR_L
          \vOld\lVar = gvWork\lVar
        Case #SCS_VAR_F
          \vOld\fVar = gvWork\fVar
        Case #SCS_VAR_D ; Added 19Jul2022
          \vOld\dVar = gvWork\dVar
        Case #SCS_VAR_S
          \vOld\sVar = gvWork\sVar
      EndSelect
    EndWith
    grMUR\nCurrUndoItemId = grMUR\nUniqueUndoId
    
  Else
    gaUndoItem(nMyUndoItemPtr)\nFlags = gaUndoItem(nMyUndoItemPtr)\nFlags | nFlags
  EndIf

  grMUR\nMaxRedoGroupPtr = grMUR\nUndoGroupPtr    ; effectively clears the redo list as soon as an undo item is created, ie as soon as the user has made a new change
  grMUR\nMaxRedoItemPtr = grMUR\nUndoItemPtr      ; used to limit loop scanning redo items

  ; set return fields
  ;   was byRef in VB6
  gbItemKnown = bMyItemKnown
  ; return value
  If bPrimary
    nMyUndoItemPtr = nMyUndoItemPtr | $40000000
  EndIf
  
  ProcedureReturn nMyUndoItemPtr  ; see note about return value at start of function

EndProcedure

Procedure postChangeItemInfo(pUndoItemPtr, nNewPtr, sDescr.s = "")
  ; to be called by postChangeProd/Cue/Sub/Aud... functions
  ; nNewPtr to be set to -1 if there is no after image, ie if this 'change' is for a deleted prod, cue, sub or aud
  PROCNAMEC()
  Protected nMyUndoItemPtr
  Protected nPrimaryInd
  Protected sMyDescr.s
  Protected bItemChanged
  
  ; debugMsg(sProcName, #SCS_START + ", pUndoItemPtr=" + pUndoItemPtr + " (" + Str(pUndoItemPtr & $FFFFFF) + "), nNewPtr=" + nNewPtr + ", sDescr=" + sDescr)
  
  If pUndoItemPtr = 0
    ; matching preChangeItemInfo was not called
    ProcedureReturn
  EndIf

  sMyDescr = Trim(ReplaceString(sDescr, Chr(10), " "))
  nMyUndoItemPtr = pUndoItemPtr & $FFFFFF
  nPrimaryInd = pUndoItemPtr & $40000000
  ; debugMsg(sProcName, "nMyUndoItemPtr=" + nMyUndoItemPtr + ", nPrimaryInd=" + nPrimaryInd + ", grMUR\nUndoGroupPtr=" + grMUR\nUndoGroupPtr)

  With gaUndoItem(nMyUndoItemPtr)
    \nNewPtr = nNewPtr
    \vNew\nVarType = gvWork\nVarType
    \bCancelled = #False
    Select gvWork\nVarType
      Case #SCS_VAR_L
        If \vOld\lVar = gvWork\lVar
          \bCancelled = #True
        Else
          bItemChanged = #True
          \vNew\lVar = gvWork\lVar
        EndIf
      Case #SCS_VAR_F
        If \vOld\fVar = gvWork\fVar
          \bCancelled = #True
        Else
          bItemChanged = #True
          \vNew\fVar = gvWork\fVar
        EndIf
      Case #SCS_VAR_D ; Added 19Jul2022
        If \vOld\dVar = gvWork\dVar
          \bCancelled = #True
        Else
          bItemChanged = #True
          \vNew\dVar = gvWork\dVar
        EndIf
      Case #SCS_VAR_S
        If \vOld\sVar = gvWork\sVar
          \bCancelled = #True
        Else
          bItemChanged = #True
          \vNew\sVar = gvWork\sVar
        EndIf
    EndSelect
    
    If sMyDescr
      \sDescr = sMyDescr
    EndIf
    ; debugMsg(sProcName, "gaUndoItem(" + nMyUndoItemPtr + ")\sDescr=" + \sDescr)
    
    ; debugMsg(sProcName, "nPrimaryInd=" + nPrimaryInd)
    If nPrimaryInd <> 0
      ; postchange on the primary change, so update the group's description
      gaUndoGroup(grMUR\nUndoGroupPtr)\sPrimaryDescr = \sDescr
      ; postchange on the primary change, so this is the end of the group
      ; debugMsg(sProcName, "calling cancelGroupIfReqd()")
      cancelGroupIfReqd()
      ; debugMsg(sProcName, "setting nPrimaryUndoGroupId=-1 (was " + grMUR\nPrimaryUndoGroupId + "), nMyUndoItemPtr=" + nMyUndoItemPtr)
      grMUR\nPrimaryUndoGroupId = -1
    EndIf
  EndWith
  
  ; debugMsg(sProcName, #SCS_END + ", returning " + strB(bItemChanged))
  ProcedureReturn bItemChanged
  
EndProcedure

Procedure preChangeAudL(nOld, sUndoDescr.s="", nOldAudPtr=-5, nAction=#SCS_UNDO_ACTION_CHANGE, nIndex=-1, nFlags=0, nAudId=0, nExtraParam=0, bForceNewGroup=#False)
  gvWork\nVarType = #SCS_VAR_L
  gvWork\lVar = nOld
  ProcedureReturn preChangeAudV(sUndoDescr, nOldAudPtr, nAction, nIndex, nFlags, nAudId, nExtraParam, bForceNewGroup)
EndProcedure

Procedure preChangeAudF(fOld.f, sUndoDescr.s="", nOldAudPtr=-5, nAction=#SCS_UNDO_ACTION_CHANGE, nIndex=-1, nFlags=0, nAudId=0, nExtraParam=0, bForceNewGroup=#False)
  gvWork\nVarType = #SCS_VAR_F
  gvWork\fVar = fOld
  ProcedureReturn preChangeAudV(sUndoDescr, nOldAudPtr, nAction, nIndex, nFlags, nAudId, nExtraParam, bForceNewGroup)
EndProcedure

Procedure preChangeAudS(sOld.s, sUndoDescr.s="", nOldAudPtr=-5, nAction=#SCS_UNDO_ACTION_CHANGE, nIndex=-1, nFlags=0, nAudId=0, nExtraParam=0, bForceNewGroup=#False)
  gvWork\nVarType = #SCS_VAR_S
  gvWork\sVar = sOld
  ProcedureReturn preChangeAudV(sUndoDescr, nOldAudPtr, nAction, nIndex, nFlags, nAudId, nExtraParam, bForceNewGroup)
EndProcedure

Procedure preChangeAudV(sUndoDescr.s="", nOldAudPtr=-5, nAction=#SCS_UNDO_ACTION_CHANGE, nIndex=-1, nFlags=0, nAudId=0, nExtraParam=0, bForceNewGroup=#False)
  ; nOldAudPtr to be set to -1 if there is no before image, ie if this 'change' is for an added aud
  ; function returns item pointer
  PROCNAMEC()
  Protected nOldPtr, nItemId
  Protected sMyUndoDescr.s, sAudLabel.s
  Protected nMyUndoItemPtr

  If gbInDisplayCue Or gbInDisplaySub Or gbInDisplayDev Or gbInEditUpdateDisplay Or gbInUndoOrRedo
    ProcedureReturn 0
  EndIf

  If nOldAudPtr = -5
    nOldPtr = nEditAudPtr
  Else
    nOldPtr = nOldAudPtr
  EndIf

  If nOldPtr >= 0
    sAudLabel = aAud(nOldPtr)\sAudLabel
    nItemId = aAud(nOldPtr)\nAudId
  Else
    sAudLabel = ""
    nItemId = nAudId
  EndIf
  
  If (Len(sUndoDescr) = 0) Or (Len(Trim(sAudLabel)) = 0)
    sMyUndoDescr = sUndoDescr
  Else
    If nIndex = -1
      sMyUndoDescr = "File " + sAudLabel + ": " + sUndoDescr
    Else
      sMyUndoDescr = "File " + sAudLabel + ": " + sUndoDescr + " (" + Str(nIndex+1) + ")"
    EndIf
  EndIf

  nMyUndoItemPtr = preChangeItemInfo(#SCS_UNDO_TYPE_AUD, nOldPtr, nItemId, nAction, nFlags, -1, sMyUndoDescr, nExtraParam, bForceNewGroup)

  If gbItemKnown = #False
    ; only save before image for the first save for this item
    With gaUndoItem(nMyUndoItemPtr & $FFFFFF)
      If nOldPtr >= 0
        If \nB4Ptr = -1
          grMUR\nB4AudPtr = grMUR\nB4AudPtr + 1
          If grMUR\nB4AudPtr > ArraySize(gaB4ImageAud())
            ReDim gaB4ImageAud(grMUR\nB4AudPtr + 100)
          EndIf
          \nB4Ptr = grMUR\nB4AudPtr
        EndIf
        ;-------------------------------------- STORE BEFORE IMAGE
        gaB4ImageAud(\nB4Ptr)\rAud = aAud(nOldPtr)
        gaB4ImageAud(\nB4Ptr)\nUndoItemId = \nUndoItemId
        gaB4ImageAud(\nB4Ptr)\nUndoGroupId = \nUndoGroupId
      EndIf
    EndWith
  EndIf

  ProcedureReturn nMyUndoItemPtr
EndProcedure

Procedure postChangeAudL(pUndoItemPtr, nNew, nNewAudPtr=-5, nIndex=-1, sUndoDescr.s="")
  gvWork\nVarType = #SCS_VAR_L
  gvWork\lVar = nNew
  ProcedureReturn postChangeAudV(pUndoItemPtr, nNewAudPtr, nIndex, sUndoDescr)
EndProcedure

Procedure postChangeAudF(pUndoItemPtr, fNew.f, nNewAudPtr=-5, nIndex=-1, sUndoDescr.s="")
  gvWork\nVarType = #SCS_VAR_F
  gvWork\fVar = fNew
  ProcedureReturn postChangeAudV(pUndoItemPtr, nNewAudPtr, nIndex, sUndoDescr)
EndProcedure

Procedure postChangeAudS(pUndoItemPtr, sNew.s, nNewAudPtr=-5, nIndex=-1, sUndoDescr.s="")
  gvWork\nVarType = #SCS_VAR_S
  gvWork\sVar = sNew
  ProcedureReturn postChangeAudV(pUndoItemPtr, nNewAudPtr, nIndex, sUndoDescr)
EndProcedure

Procedure postChangeAudLN(pUndoItemPtr, nNew, nNewAudPtr=-5, nIndex=-1, sUndoDescr.s="")
  ; similar to postChangeAudL() but sets bSetCloseCueWhenLeavingEditor=#False when calling postChangeAudV()
  gvWork\nVarType = #SCS_VAR_L
  gvWork\lVar = nNew
  ProcedureReturn postChangeAudV(pUndoItemPtr, nNewAudPtr, nIndex, sUndoDescr, #False)
EndProcedure

Procedure postChangeAudFN(pUndoItemPtr, fNew.f, nNewAudPtr=-5, nIndex=-1, sUndoDescr.s="")
  ; similar to postChangeAudF() but sets bSetCloseCueWhenLeavingEditor=#False when calling postChangeAudV()
  gvWork\nVarType = #SCS_VAR_F
  gvWork\fVar = fNew
  ProcedureReturn postChangeAudV(pUndoItemPtr, nNewAudPtr, nIndex, sUndoDescr, #False)
EndProcedure

Procedure postChangeAudSN(pUndoItemPtr, sNew.s, nNewAudPtr=-5, nIndex=-1, sUndoDescr.s="")
  ; similar to postChangeAudS() but sets bSetCloseCueWhenLeavingEditor=#False when calling postChangeAudV()
  gvWork\nVarType = #SCS_VAR_S
  gvWork\sVar = sNew
  ProcedureReturn postChangeAudV(pUndoItemPtr, nNewAudPtr, nIndex, sUndoDescr, #False)
EndProcedure

Procedure postChangeAudV(pUndoItemPtr, nNewAudPtr=-5, nIndex=-1, sUndoDescr.s="", bSetCloseCueWhenLeavingEditor=#True)
  ; nNewAudPtr to be set to -1 if there is no after image, ie if this 'change' is for a deleted file
  PROCNAMEC()
  Protected nMyUndoItemPtr
  Protected sMyUndoDescr.s, sAudLabel.s
  Protected nNewPtr
  Protected nCuePtr
  Protected sMsg.s
  Protected bItemChanged

  ; debugMsg(sProcName, #SCS_START + ", sUndoDescr=" + sUndoDescr + ", bSetCloseCueWhenLeavingEditor=" + strB(bSetCloseCueWhenLeavingEditor))
  
  nMyUndoItemPtr = pUndoItemPtr & $FFFFFF
  If nMyUndoItemPtr = 0
    ; matching preChangeAud was not called
    ProcedureReturn 0
  EndIf
  
  If nNewAudPtr = -5
    nNewPtr = nEditAudPtr
  Else
    nNewPtr = nNewAudPtr
  EndIf

  With gaUndoItem(nMyUndoItemPtr)
    If \nItemType <> #SCS_UNDO_TYPE_AUD
      sMsg = "Incorrect undo type - expected " + #SCS_UNDO_TYPE_AUD + " but gaUndoItem(" + nMyUndoItemPtr + ")\nItemType=" + gaUndoItem(nMyUndoItemPtr)\nItemType
      debugMsg(sProcName, sMsg)
      scsMessageRequester("Undo/Redo", sMsg)
      ProcedureReturn 0
    EndIf
    \nNewPtr = nNewPtr
    If nNewPtr >= 0
      nCuePtr = aAud(nNewPtr)\nCueIndex
      If bSetCloseCueWhenLeavingEditor
        If nCuePtr >= 0
          aCue(nCuePtr)\bCloseCueWhenLeavingEditor = #True
        EndIf
      EndIf
      If \nAftPtr = -1
        grMUR\nAftAudPtr = grMUR\nAftAudPtr + 1
        If grMUR\nAftAudPtr > ArraySize(gaAftImageAud())
          ReDim gaAftImageAud(grMUR\nAftAudPtr + 100)
        EndIf
        \nAftPtr = grMUR\nAftAudPtr
      EndIf
      ;-------------------------------------- STORE AFTER IMAGE
      gaAftImageAud(\nAftPtr)\rAud = aAud(nNewPtr)
      gaAftImageAud(\nAftPtr)\nUndoItemId = \nUndoItemId
      gaAftImageAud(\nAftPtr)\nUndoGroupId = \nUndoGroupId
    EndIf
  EndWith

  If nNewPtr >= 0
    sAudLabel = aAud(nNewPtr)\sAudLabel
  Else
    sAudLabel = ""
  EndIf

  If (Len(sUndoDescr) = 0) Or (Len(Trim(sAudLabel)) = 0)
    sMyUndoDescr = sUndoDescr
  Else
    If nIndex = -1
      sMyUndoDescr = "File " + sAudLabel + ": " + sUndoDescr
    Else
      sMyUndoDescr = "File " + sAudLabel + ": " + sUndoDescr + " (" + Str(nIndex+1) + ")"
    EndIf
  EndIf

  ; debugMsg(sProcName, "nNewPtr=" + nNewPtr + ", sAudLabel=" + sAudLabel + ", sMyUndoDescr=" + sMyUndoDescr)

  bItemChanged = postChangeItemInfo(pUndoItemPtr, nNewPtr, sMyUndoDescr)
  If bItemChanged
    grRAI\nStatus | #SCS_RAI_STATUS_CUE
    If nNewPtr >= 0
      aAud(nNewPtr)\qTimeAudLastEdited = ElapsedMilliseconds()
      ; Debug sProcName + ": aAud(" + getAudLabel(nNewPtr) + ")\qTimeAudLastEdited=" + aAud(nNewPtr)\qTimeAudLastEdited
    EndIf
  EndIf

  If gbEditorFormLoaded
    WED_setEditorButtons()
  Else
    setFileSave()
  EndIf

EndProcedure

Procedure preChangeCueL(nOld, sUndoDescr.s, nOldCuePtr=-5, nAction=#SCS_UNDO_ACTION_CHANGE, nIndex=-1, nFlags=0, nCueId=0, nExtraParam=0, bForceNewGroup=#False)
  gvWork\nVarType = #SCS_VAR_L
  gvWork\lVar = nOld
  ProcedureReturn preChangeCueV(sUndoDescr, nOldCuePtr, nAction, nIndex, nFlags, nCueId, nExtraParam, bForceNewGroup)
EndProcedure

Procedure preChangeCueF(fOld.f, sUndoDescr.s, nOldCuePtr=-5, nAction=#SCS_UNDO_ACTION_CHANGE, nIndex=-1, nFlags=0, nCueId=0, nExtraParam=0, bForceNewGroup=#False)
  gvWork\nVarType = #SCS_VAR_F
  gvWork\fVar = fOld
  ProcedureReturn preChangeCueV(sUndoDescr, nOldCuePtr, nAction, nIndex, nFlags, nCueId, nExtraParam, bForceNewGroup)
EndProcedure

Procedure preChangeCueS(sOld.s, sUndoDescr.s, nOldCuePtr=-5, nAction=#SCS_UNDO_ACTION_CHANGE, nIndex=-1, nFlags=0, nCueId=0, nExtraParam=0, bForceNewGroup=#False)
  gvWork\nVarType = #SCS_VAR_S
  gvWork\sVar = sOld
  ProcedureReturn preChangeCueV(sUndoDescr, nOldCuePtr, nAction, nIndex, nFlags, nCueId, nExtraParam, bForceNewGroup)
EndProcedure

Procedure preChangeCueV(sUndoDescr.s, nOldCuePtr=-5, nAction=#SCS_UNDO_ACTION_CHANGE, nIndex=-1, nFlags=0, nCueId=0, nExtraParam=0, bForceNewGroup=#False)
  ; nOldCuePtr to be set to -1 if there is no before image, ie if this 'change' is for an added cue
  ; function returns item pointer
  PROCNAMEC()
  Protected nOldPtr, nItemId
  Protected sMyUndoDescr.s
  Protected nMyUndoItemPtr
  Protected sCue.s

  If gbInDisplayCue Or gbInDisplaySub Or gbInDisplayDev Or gbInEditUpdateDisplay Or gbInUndoOrRedo
    ProcedureReturn 0
  EndIf

  ; debugMsg(sProcName, #SCS_START + ", vOld=" + CStr(grMUR\vOld) + ", sUndoDescr=" + sUndoDescr + ", nOldCuePtr=" + nOldCuePtr)

  If nOldCuePtr = -5
    nOldPtr = nEditCuePtr
  Else
    nOldPtr = nOldCuePtr
  EndIf

  If nOldPtr >= 0
    sCue = aCue(nOldPtr)\sCue
    nItemId = aCue(nOldPtr)\nCueId
  Else
    sCue = ""
    nItemId = nCueId
  EndIf

  If (Len(sUndoDescr) = 0) Or (Len(Trim(sCue)) = 0)
    sMyUndoDescr = sUndoDescr
  Else
    If nIndex = -1
      sMyUndoDescr = "Cue " + sCue + ": " + sUndoDescr
    Else
      sMyUndoDescr = "Cue " + sCue + ": " + sUndoDescr + " (" + Str(nIndex+1) + ")"
    EndIf
  EndIf

  nMyUndoItemPtr = preChangeItemInfo(#SCS_UNDO_TYPE_CUE, nOldPtr, nItemId, nAction, nFlags, -1, sMyUndoDescr, nExtraParam, bForceNewGroup)

  If gbItemKnown = #False
    ; only save before image for the first save for this item
    With gaUndoItem(nMyUndoItemPtr & $FFFFFF)
      If nOldPtr >= 0
        If \nB4Ptr = -1
          grMUR\nB4CuePtr = grMUR\nB4CuePtr + 1
          If grMUR\nB4CuePtr > ArraySize(gaB4ImageCue())
            ReDim gaB4ImageCue(grMUR\nB4CuePtr + 100)
          EndIf
          \nB4Ptr = grMUR\nB4CuePtr
        EndIf
        ;-------------------------------------- STORE BEFORE IMAGE
        gaB4ImageCue(\nB4Ptr)\rCue = aCue(nOldPtr)
        gaB4ImageCue(\nB4Ptr)\nUndoItemId = \nUndoItemId
        gaB4ImageCue(\nB4Ptr)\nUndoGroupId = \nUndoGroupId
      EndIf
    EndWith
  EndIf

  ; debugMsg(sProcName, #SCS_END + " returning " + nMyUndoItemPtr)
  ProcedureReturn nMyUndoItemPtr
EndProcedure

Procedure postChangeCueL(pUndoItemPtr, nNew, nNewCuePtr=-5, nIndex=-1, sUndoDescr.s="")
  gvWork\nVarType = #SCS_VAR_L
  gvWork\lVar = nNew
  ProcedureReturn postChangeCueV(pUndoItemPtr, nNewCuePtr, nIndex, sUndoDescr)
EndProcedure

Procedure postChangeCueF(pUndoItemPtr, fNew.f, nNewCuePtr=-5, nIndex=-1, sUndoDescr.s="")
  gvWork\nVarType = #SCS_VAR_F
  gvWork\fVar = fNew
  ProcedureReturn postChangeCueV(pUndoItemPtr, nNewCuePtr, nIndex, sUndoDescr)
EndProcedure

Procedure postChangeCueS(pUndoItemPtr, sNew.s, nNewCuePtr=-5, nIndex=-1, sUndoDescr.s="")
  gvWork\nVarType = #SCS_VAR_S
  gvWork\sVar = sNew
  ProcedureReturn postChangeCueV(pUndoItemPtr, nNewCuePtr, nIndex, sUndoDescr)
EndProcedure

Procedure postChangeCueV(pUndoItemPtr, nNewCuePtr=-5, nIndex=-1, sUndoDescr.s="")
  ; nNewCuePtr to be set to -1 if there is no after image, ie if this 'change' is for a deleted cue
  PROCNAMEC()
  Protected sMyUndoDescr.s, sCue.s
  Protected nNewPtr
  Protected nMyUndoItemPtr
  Protected sMsg.s
  Protected bItemChanged

  If pUndoItemPtr = 0
    ; matching preChangeCue was not called
    ProcedureReturn 0
  EndIf

  nMyUndoItemPtr = pUndoItemPtr & $FFFFFF

  If nNewCuePtr = -5
    nNewPtr = nEditCuePtr
  Else
    nNewPtr = nNewCuePtr
  EndIf

  With gaUndoItem(nMyUndoItemPtr)
    If \nItemType <> #SCS_UNDO_TYPE_CUE
      sMsg = "Incorrect undo type - expected " + #SCS_UNDO_TYPE_CUE + " but gaUndoItem(" + nMyUndoItemPtr + ")\nItemType=" + gaUndoItem(nMyUndoItemPtr)\nItemType
      debugMsg(sProcName, sMsg)
      scsMessageRequester(#SCS_TITLE, sMsg)
      ProcedureReturn 0
    EndIf
    \nNewPtr = nNewPtr
    If nNewPtr >= 0
      If \nAftPtr = -1
        grMUR\nAftCuePtr = grMUR\nAftCuePtr + 1
        If grMUR\nAftCuePtr > ArraySize(gaAftImageCue())
          ReDim gaAftImageCue(grMUR\nAftCuePtr + 100)
        EndIf
        \nAftPtr = grMUR\nAftCuePtr
      EndIf
      ;-------------------------------------- STORE AFTER IMAGE
      gaAftImageCue(\nAftPtr)\rCue = aCue(nNewPtr)
      gaAftImageCue(\nAftPtr)\nUndoItemId = \nUndoItemId
      gaAftImageCue(\nAftPtr)\nUndoGroupId = \nUndoGroupId
    EndIf
  EndWith

  If nNewPtr >= 0
    sCue = aCue(nNewPtr)\sCue
  Else
    sCue = ""
  EndIf

  If (Len(sUndoDescr) = 0) Or (Len(Trim(sCue)) = 0)
    sMyUndoDescr = sUndoDescr
  Else
    If nIndex = -1
      sMyUndoDescr = "Cue " + sCue + ": " + sUndoDescr
    Else
      sMyUndoDescr = "Cue " + sCue + ": " + sUndoDescr + " (" + Str(nIndex+1) + ")"
    EndIf
  EndIf

  bItemChanged = postChangeItemInfo(pUndoItemPtr, nNewPtr, sMyUndoDescr)
  If bItemChanged
    grRAI\nStatus | #SCS_RAI_STATUS_CUE
    If nNewPtr >= 0
      aCue(nNewPtr)\qTimeCueLastEdited = ElapsedMilliseconds()
    EndIf
  EndIf

  If gbEditorFormLoaded
    ; debugMsg(sProcName, "calling WED_setEditorButtons()")
    WED_setEditorButtons()
  Else
    ; debugMsg(sProcName, "calling setFileSave()")
    setFileSave()
  EndIf

  ; debugMsg(sProcName, #SCS_END)

EndProcedure

Procedure preChangeSubL(nOld, sUndoDescr.s, nOldSubPtr=-5, nAction=#SCS_UNDO_ACTION_CHANGE, nIndex=-1, nFlags=0, nSubId=0, nExtraParam=0, bForceNewGroup=#False)
  PROCNAMEC()
  gvWork\nVarType = #SCS_VAR_L
  gvWork\lVar = nOld
  ProcedureReturn preChangeSubV(sUndoDescr, nOldSubPtr, nAction, nIndex, nFlags, nSubId, nExtraParam, bForceNewGroup)
EndProcedure

Procedure preChangeSubF(fOld.f, sUndoDescr.s, nOldSubPtr=-5, nAction=#SCS_UNDO_ACTION_CHANGE, nIndex=-1, nFlags=0, nSubId=0, nExtraParam=0, bForceNewGroup=#False)
  gvWork\nVarType = #SCS_VAR_F
  gvWork\fVar = fOld
  ProcedureReturn preChangeSubV(sUndoDescr, nOldSubPtr, nAction, nIndex, nFlags, nSubId, nExtraParam, bForceNewGroup)
EndProcedure

Procedure preChangeSubD(dOld.d, sUndoDescr.s, nOldSubPtr=-5, nAction=#SCS_UNDO_ACTION_CHANGE, nIndex=-1, nFlags=0, nSubId=0, nExtraParam=0, bForceNewGroup=#False)
  gvWork\nVarType = #SCS_VAR_D
  gvWork\dVar = dOld
  ProcedureReturn preChangeSubV(sUndoDescr, nOldSubPtr, nAction, nIndex, nFlags, nSubId, nExtraParam, bForceNewGroup)
EndProcedure

Procedure preChangeSubS(sOld.s, sUndoDescr.s, nOldSubPtr=-5, nAction=#SCS_UNDO_ACTION_CHANGE, nIndex=-1, nFlags=0, nSubId=0, nExtraParam=0, bForceNewGroup=#False)
  gvWork\nVarType = #SCS_VAR_S
  gvWork\sVar = sOld
  ProcedureReturn preChangeSubV(sUndoDescr, nOldSubPtr, nAction, nIndex, nFlags, nSubId, nExtraParam, bForceNewGroup)
EndProcedure

Procedure preChangeSubV(sUndoDescr.s, nOldSubPtr=-5, nAction=#SCS_UNDO_ACTION_CHANGE, nIndex=-1, nFlags=0, nSubId=0, nExtraParam=0, bForceNewGroup=#False)
  ; nOldSubPtr to be set to -1 if there is no before image, ie if this 'change' is for an added sub
  ; function returns item pointer
  PROCNAMEC()
  Protected nOldPtr, nItemId
  Protected sMyUndoDescr.s, sSubLabel.s, nSubRef
  Protected nMyUndoItemPtr
  
  If gbInDisplayCue Or gbInDisplaySub Or gbInDisplayDev Or gbInEditUpdateDisplay Or gbInUndoOrRedo
    ; debugMsg(sProcName, "gbInDisplayCue=" + gbInDisplayCue + ", gbInDisplaySub=" + gbInDisplaySub + ", gbInDisplayDev=" + gbInDisplayDev + ", gbInEditUpdateDisplay=" + gbInEditUpdateDisplay + ", gbInUndoOrRedo=" + gbInUndoOrRedo +
    ;                      ", nEditSubPtr=" + getSubLabel(nEditSubPtr) + ", nOldSubPtr=" + getSubLabel(nOldSubPtr))
    ProcedureReturn 0
  EndIf
  
  If nOldSubPtr = -5
    nOldPtr = nEditSubPtr
  Else
    nOldPtr = nOldSubPtr
  EndIf

  If nOldPtr >= 0
    sSubLabel = aSub(nOldPtr)\sSubLabel
    nItemId = aSub(nOldPtr)\nSubId
    nSubRef = aSub(nOldPtr)\nSubRef
  Else
    sSubLabel = ""
    nSubRef = -1
    nItemId = nSubId
  EndIf
  ; debugMsg(sProcName, "nOldSubPtr=" + nOldSubPtr + ", nOldPtr=" + nOldPtr + ", sSubLabel=" + sSubLabel + ", nItemId=" + nItemId + ", nSubRef=" + nSubRef)

  If (Len(sUndoDescr) = 0) Or (Len(Trim(sSubLabel)) = 0)
    sMyUndoDescr = sUndoDescr
  Else
    If nIndex = -1
      sMyUndoDescr = "SubCue " + sSubLabel + ": " + sUndoDescr
    Else
      sMyUndoDescr = "SubCue " + sSubLabel + ": " + sUndoDescr + " (" + Str(nIndex+1)  + ")"
    EndIf
  EndIf

  nMyUndoItemPtr = preChangeItemInfo(#SCS_UNDO_TYPE_SUB, nOldPtr, nItemId, nAction, nFlags, nSubRef, sMyUndoDescr, nExtraParam, bForceNewGroup)
  ; debugMsg(sProcName, "nMyUndoItemPtr=" + nMyUndoItemPtr)

  If gbItemKnown = #False
    ; only save before image for the first save for this item
    With gaUndoItem(nMyUndoItemPtr & $FFFFFF)
      If nOldPtr >= 0
        If \nB4Ptr = -1
          grMUR\nB4SubPtr = grMUR\nB4SubPtr + 1
          If grMUR\nB4SubPtr > ArraySize(gaB4ImageSub())
            ReDim gaB4ImageSub(grMUR\nB4SubPtr + 100)
          EndIf
          \nB4Ptr = grMUR\nB4SubPtr
        EndIf
        ;-------------------------------------- STORE BEFORE IMAGE
        gaB4ImageSub(\nB4Ptr)\rSub = aSub(nOldPtr)
        gaB4ImageSub(\nB4Ptr)\nUndoItemId = \nUndoItemId
        gaB4ImageSub(\nB4Ptr)\nUndoGroupId = \nUndoGroupId
      EndIf
    EndWith
  EndIf

  ProcedureReturn nMyUndoItemPtr
EndProcedure

Procedure postChangeSubL(pUndoItemPtr, nNew, nNewSubPtr=-5, nIndex=-1, sUndoDescr.s="")
  gvWork\nVarType = #SCS_VAR_L
  gvWork\lVar = nNew
  ProcedureReturn postChangeSubV(pUndoItemPtr, nNewSubPtr, nIndex, sUndoDescr)
EndProcedure

Procedure postChangeSubF(pUndoItemPtr, fNew.f, nNewSubPtr=-5, nIndex=-1, sUndoDescr.s="")
  gvWork\nVarType = #SCS_VAR_F
  gvWork\fVar = fNew
  ProcedureReturn postChangeSubV(pUndoItemPtr, nNewSubPtr, nIndex, sUndoDescr)
EndProcedure

Procedure postChangeSubD(pUndoItemPtr, dNew.d, nNewSubPtr=-5, nIndex=-1, sUndoDescr.s="")
  gvWork\nVarType = #SCS_VAR_D
  gvWork\dVar = dNew
  ProcedureReturn postChangeSubV(pUndoItemPtr, nNewSubPtr, nIndex, sUndoDescr)
EndProcedure

Procedure postChangeSubS(pUndoItemPtr, sNew.s, nNewSubPtr=-5, nIndex=-1, sUndoDescr.s="")
  gvWork\nVarType = #SCS_VAR_S
  gvWork\sVar = sNew
  ProcedureReturn postChangeSubV(pUndoItemPtr, nNewSubPtr, nIndex, sUndoDescr)
EndProcedure

Procedure postChangeSubLN(pUndoItemPtr, nNew, nNewSubPtr=-5, nIndex=-1, sUndoDescr.s="")
  ; similar to postChangeSubL() but sets bSetCloseCueWhenLeavingEditor=#False when calling postChangeSubV()
  gvWork\nVarType = #SCS_VAR_L
  gvWork\lVar = nNew
  ProcedureReturn postChangeSubV(pUndoItemPtr, nNewSubPtr, nIndex, sUndoDescr, #False)
EndProcedure

Procedure postChangeSubFN(pUndoItemPtr, fNew.f, nNewSubPtr=-5, nIndex=-1, sUndoDescr.s="")
  ; similar to postChangeSubF() but sets bSetCloseCueWhenLeavingEditor=#False when calling postChangeSubV()
  gvWork\nVarType = #SCS_VAR_F
  gvWork\fVar = fNew
  ProcedureReturn postChangeSubV(pUndoItemPtr, nNewSubPtr, nIndex, sUndoDescr, #False)
EndProcedure

Procedure postChangeSubSN(pUndoItemPtr, sNew.s, nNewSubPtr=-5, nIndex=-1, sUndoDescr.s="")
  ; similar to postChangeSubS() but sets bSetCloseCueWhenLeavingEditor=#False when calling postChangeSubV()
  gvWork\nVarType = #SCS_VAR_S
  gvWork\sVar = sNew
  ProcedureReturn postChangeSubV(pUndoItemPtr, nNewSubPtr, nIndex, sUndoDescr, #False)
EndProcedure

Procedure postChangeSubV(pUndoItemPtr, nNewSubPtr=-5, nIndex=-1, sUndoDescr.s="", bSetCloseCueWhenLeavingEditor=#True)
  ; nNewSubPtr to be set to -1 if there is no after image, ie if this 'change' is for a deleted sub
  PROCNAMEC()
  Protected sMyUndoDescr.s, sSubLabel.s
  Protected nNewPtr
  Protected nCuePtr
  Protected nMyUndoItemPtr
  Protected sMsg.s
  Protected bItemChanged
  
  ; debugMsg(sProcName, #SCS_START + ", pUndoItemPtr=" + pUndoItemPtr + ", sUndoDescr=" + sUndoDescr + ", bSetCloseCueWhenLeavingEditor=" + strB(bSetCloseCueWhenLeavingEditor))
  If pUndoItemPtr = 0
    ; matching preChangeSub was not called
    ProcedureReturn 0
  EndIf

  ; debugMsgOutdent()

  nMyUndoItemPtr = pUndoItemPtr & $FFFFFF

  If nNewSubPtr = -5
    nNewPtr = nEditSubPtr
  Else
    nNewPtr = nNewSubPtr
  EndIf
  
  With gaUndoItem(nMyUndoItemPtr)
    If \nItemType <> #SCS_UNDO_TYPE_SUB
      sMsg = "Incorrect undo type - expected " + #SCS_UNDO_TYPE_SUB + " but gaUndoItem(" + nMyUndoItemPtr + ")\nItemType=" + gaUndoItem(nMyUndoItemPtr)\nItemType
      debugMsg(sProcName, sMsg)
      scsMessageRequester(#SCS_TITLE, sMsg)
      ProcedureReturn 0
    EndIf
    \nNewPtr = nNewPtr
    If nNewPtr >= 0
      If aSub(nNewPtr)\bSubTypeHasAuds
        nCuePtr = aSub(nNewPtr)\nCueIndex
        If bSetCloseCueWhenLeavingEditor
          If nCuePtr >= 0
            aCue(nCuePtr)\bCloseCueWhenLeavingEditor = #True
            ; debugMsg(sProcName, "aCue(" + getCueLabel(nCuePtr) + ")\bCloseCueWhenLeavingEditor=" + strB(aCue(nCuePtr)\bCloseCueWhenLeavingEditor))
          EndIf
        EndIf
      EndIf
      If \nAftPtr = -1
        grMUR\nAftSubPtr = grMUR\nAftSubPtr + 1
        If grMUR\nAftSubPtr > ArraySize(gaAftImageSub())
          ReDim gaAftImageSub(grMUR\nAftSubPtr + 100)
        EndIf
        \nAftPtr = grMUR\nAftSubPtr
      EndIf
      ;-------------------------------------- STORE AFTER IMAGE
      gaAftImageSub(\nAftPtr)\rSub = aSub(nNewPtr)
      gaAftImageSub(\nAftPtr)\nUndoItemId = \nUndoItemId
      gaAftImageSub(\nAftPtr)\nUndoGroupId = \nUndoGroupId
    EndIf
  EndWith

  If nNewPtr >= 0
    sSubLabel = aSub(nNewPtr)\sSubLabel
  Else
    sSubLabel = ""
  EndIf

  If (Len(sUndoDescr) = 0) Or (Len(Trim(sSubLabel)) = 0)
    sMyUndoDescr = sUndoDescr
  Else
    If nIndex = -1
      sMyUndoDescr = "SubCue " + sSubLabel + ": " + sUndoDescr
    Else
      sMyUndoDescr = "SubCue " + sSubLabel + ": " + sUndoDescr + " (" + Str(nIndex+1) + ")"
    EndIf
  EndIf

  bItemChanged = postChangeItemInfo(pUndoItemPtr, nNewPtr, sMyUndoDescr)
  If bItemChanged
    grRAI\nStatus | #SCS_RAI_STATUS_CUE
    If nNewPtr >= 0
      aSub(nNewPtr)\qTimeSubLastEdited = ElapsedMilliseconds()
    EndIf
  EndIf

  If gbEditorFormLoaded
    WED_setEditorButtons()
  Else
    setFileSave()
  EndIf

EndProcedure

Procedure preChangeProdL(nOld, sUndoDescr.s, nOldProdPtr=-5, nAction=#SCS_UNDO_ACTION_CHANGE, nIndex=-1, nFlags=0, nProdId=0, nExtraParam=0, bForceNewGroup=#False)
  gvWork\nVarType = #SCS_VAR_L
  gvWork\lVar = nOld
  ProcedureReturn preChangeProdV(sUndoDescr, nOldProdPtr, nAction, nIndex, nFlags, nProdId, nExtraParam, bForceNewGroup)
EndProcedure

Procedure preChangeProdF(fOld.f, sUndoDescr.s, nOldProdPtr=-5, nAction=#SCS_UNDO_ACTION_CHANGE, nIndex=-1, nFlags=0, nProdId=0, nExtraParam=0, bForceNewGroup=#False)
  gvWork\nVarType = #SCS_VAR_F
  gvWork\fVar = fOld
  ProcedureReturn preChangeProdV(sUndoDescr, nOldProdPtr, nAction, nIndex, nFlags, nProdId, nExtraParam, bForceNewGroup)
EndProcedure

Procedure preChangeProdS(sOld.s, sUndoDescr.s, nOldProdPtr=-5, nAction=#SCS_UNDO_ACTION_CHANGE, nIndex=-1, nFlags=0, nProdId=0, nExtraParam=0, bForceNewGroup=#False)
  gvWork\nVarType = #SCS_VAR_S
  gvWork\sVar = sOld
  ProcedureReturn preChangeProdV(sUndoDescr, nOldProdPtr, nAction, nIndex, nFlags, nProdId, nExtraParam, bForceNewGroup)
EndProcedure

Procedure preChangeProdV(sUndoDescr.s, nOldProdPtr=-5, nAction=#SCS_UNDO_ACTION_CHANGE, nIndex=-1, nFlags=0, nProdId=0, nExtraParam=0, bForceNewGroup=#False)
  ; nOldProdPtr to be set to -1 if there is no before image, ie if this 'change' is for an added prod
  ; function returns item pointer
  PROCNAMEC()
  Protected nOldPtr, nItemId
  Protected sMyUndoDescr.s
  Protected nMyUndoItemPtr

  If gbInDisplayProd Or gbInDisplayCue Or gbInDisplaySub Or gbInDisplayDev Or gbInEditUpdateDisplay Or gbInUndoOrRedo
    ProcedureReturn 0
  EndIf

  If nOldProdPtr = -5
    nOldPtr = 1
  Else
    nOldPtr = nOldProdPtr
  EndIf

  nItemId = grProd\nProdId

  If (Len(sUndoDescr) = 0)
    sMyUndoDescr = sUndoDescr
  Else
    If nIndex = -1
      sMyUndoDescr = "Prod: " + sUndoDescr
    Else
      sMyUndoDescr = "Prod: " + sUndoDescr + " (" + Str(nIndex+1) + ")"
    EndIf
  EndIf

  nMyUndoItemPtr = preChangeItemInfo(#SCS_UNDO_TYPE_PROD, nOldPtr, nItemId, nAction, nFlags, -1, sMyUndoDescr, nExtraParam, bForceNewGroup)

  If gbItemKnown = #False
    ; only save before image for the first save for this item
    With gaUndoItem(nMyUndoItemPtr & $FFFFFF)
      If nOldPtr >= 0
        If \nB4Ptr = -1
          grMUR\nB4ProdPtr = grMUR\nB4ProdPtr + 1
          If grMUR\nB4ProdPtr > ArraySize(gaB4ImageProd())
            ReDim gaB4ImageProd(grMUR\nB4ProdPtr + 100)
          EndIf
          \nB4Ptr = grMUR\nB4ProdPtr
        EndIf
        ;-------------------------------------- STORE BEFORE IMAGE
        gaB4ImageProd(\nB4Ptr)\rProd = grProd
        gaB4ImageProd(\nB4Ptr)\nUndoItemId = \nUndoItemId
        gaB4ImageProd(\nB4Ptr)\nUndoGroupId = \nUndoGroupId
      EndIf
    EndWith
  EndIf

  ProcedureReturn nMyUndoItemPtr
EndProcedure

Procedure postChangeProdL(pUndoItemPtr, nNew, nNewProdPtr=-5, nIndex=-1, sUndoDescr.s="")
  gvWork\nVarType = #SCS_VAR_L
  gvWork\lVar = nNew
  ProcedureReturn postChangeProdV(pUndoItemPtr, nNewProdPtr, nIndex, sUndoDescr)
EndProcedure

Procedure postChangeProdF(pUndoItemPtr, fNew.f, nNewProdPtr=-5, nIndex=-1, sUndoDescr.s="")
  PROCNAMEC()
  gvWork\nVarType = #SCS_VAR_F
  gvWork\fVar = fNew
  ; debugMsg(sProcName, "#SCS_VAR_F=" + #SCS_VAR_F + ", gvWork\nVarType=" + gvWork\nVarType)
  ProcedureReturn postChangeProdV(pUndoItemPtr, nNewProdPtr, nIndex, sUndoDescr)
EndProcedure

Procedure postChangeProdS(pUndoItemPtr, sNew.s, nNewProdPtr=-5, nIndex=-1, sUndoDescr.s="")
  gvWork\nVarType = #SCS_VAR_S
  gvWork\sVar = sNew
  ProcedureReturn postChangeProdV(pUndoItemPtr, nNewProdPtr, nIndex, sUndoDescr)
EndProcedure

Procedure postChangeProdV(pUndoItemPtr, nNewProdPtr=-5, nIndex=-1, sUndoDescr.s="")
  ; nNewProdPtr to be set to -1 if there is no after image, ie if this 'change' is for a deleted prod
  PROCNAMEC()
  Protected sMyUndoDescr.s, sProdLabel.s
  Protected nNewPtr
  Protected nMyUndoItemPtr
  Protected sMsg.s
  Protected bItemChanged

  If pUndoItemPtr = 0
    ; matching preChangeProd was not called
    ProcedureReturn 0
  EndIf

  ; debugMsgOutdent()

  nMyUndoItemPtr = pUndoItemPtr & $FFFFFF

  If nNewProdPtr = -5
    nNewPtr = 1
  Else
    nNewPtr = nNewProdPtr
  EndIf

  With gaUndoItem(nMyUndoItemPtr)
    If \nItemType <> #SCS_UNDO_TYPE_PROD
      sMsg = "Incorrect undo type - expected " + #SCS_UNDO_TYPE_PROD + " but gaUndoItem(" + nMyUndoItemPtr + ")\nItemType=" + gaUndoItem(nMyUndoItemPtr)\nItemType
      debugMsg(sProcName, sMsg)
      scsMessageRequester(#SCS_TITLE, sMsg)
      ProcedureReturn 0
    EndIf
    \nNewPtr = nNewPtr
    If nNewPtr >= 0
      If \nAftPtr = -1
        grMUR\nAftProdPtr + 1
        If grMUR\nAftProdPtr > ArraySize(gaAftImageProd())
          ReDim gaAftImageProd(grMUR\nAftProdPtr + 5)
        EndIf
        \nAftPtr = grMUR\nAftProdPtr
      EndIf
      ;-------------------------------------- STORE AFTER IMAGE
      gaAftImageProd(\nAftPtr)\rProd = grProd
      gaAftImageProd(\nAftPtr)\nUndoItemId = \nUndoItemId
      gaAftImageProd(\nAftPtr)\nUndoGroupId = \nUndoGroupId
    EndIf
  EndWith

  If (Len(sUndoDescr) = 0)
    sMyUndoDescr = sUndoDescr
  Else
    If nIndex = -1
      sMyUndoDescr = "Prod: " + sUndoDescr
    Else
      sMyUndoDescr = "Prod: " + sUndoDescr + " (" + Str(nIndex+1) + ")"
    EndIf
  EndIf

  bItemChanged = postChangeItemInfo(pUndoItemPtr, nNewPtr, sMyUndoDescr)
  If bItemChanged
    grRAI\nStatus | #SCS_RAI_STATUS_PROD
  EndIf

  If gbEditorFormLoaded
    WED_setEditorButtons()
  Else
    setFileSave()
  EndIf

EndProcedure

Procedure undoAvailable()
  ; PROCNAMEC()
  Protected sTmpToolTip.s, bAvailable

  ; debugMsg(sProcName, "nUndoGroupPtr=" + grMUR\nUndoGroupPtr)
  If grMUR\nUndoGroupPtr >= 0
    Select gaUndoGroup(grMUR\nUndoGroupPtr)\nPrimaryAction
      Case #SCS_UNDO_ACTION_CHANGE
        sTmpToolTip = "Change " + Trim(gaUndoGroup(grMUR\nUndoGroupPtr)\sPrimaryDescr)
      Default
        sTmpToolTip = Trim(gaUndoGroup(grMUR\nUndoGroupPtr)\sPrimaryDescr)
    EndSelect
    bAvailable = #True
  EndIf
  gsToolTipText = sTmpToolTip
  ProcedureReturn bAvailable
EndProcedure

Procedure redoAvailable()
  ; PROCNAMEC()
  Protected sTmpToolTip.s, bAvailable

  ; debugMsg(sProcName, "nUndoGroupPtr=" + grMUR\nUndoGroupPtr + ", nMaxRedoGroupPtr=" + grMUR\nMaxRedoGroupPtr)
  If grMUR\nMaxRedoGroupPtr > grMUR\nUndoGroupPtr
    Select gaUndoGroup(grMUR\nUndoGroupPtr + 1)\nPrimaryAction
      Case #SCS_UNDO_ACTION_CHANGE
        sTmpToolTip = "Change " + Trim(gaUndoGroup(grMUR\nUndoGroupPtr + 1)\sPrimaryDescr)
      Default
        sTmpToolTip = Trim(gaUndoGroup(grMUR\nUndoGroupPtr + 1)\sPrimaryDescr)
    EndSelect
    bAvailable = #True
  EndIf
  gsToolTipText = sTmpToolTip
  ProcedureReturn bAvailable
EndProcedure

Procedure undoLastGroup(*pLastGroupInfo.tyLastGroupInfo)
  PROCNAMEC()
  ; Description:
  ; 1. undo changes, etc in group pointed at my nUndoGroupPtr
  ; 2. step nUndoGroupPtr back 1
  ; 3. return nGroupPtr of group just undone, or -1 if undo failed
  Protected nUndoResult, n, n2, n3
  Protected i, j, k
  Protected nSubjectId, nSubjectPtr
  Protected nMyUndoGroupId
  Protected rTmpCue.tyCue, rTmpSub.tySub
  Protected nMySubPtr, nMyAudPtr
  Protected nUndoAudPtr
  Protected nMyUndoTypes, nMyUndoFlags
  Protected sMsg.s, nAudCount
  Protected nPrevSubIndex, sCue.s, nSubNo
  Protected nPrevAudIndex
  Protected nPreChangeCueToMove, nPreChangeTargetCuePtr
  Protected nThisCueToMove, nThisTargetCuePtr

  ; debugMsg(sProcName, #SCS_START + ", gbInCueStatusChecks=" + strB(gbInCueStatusChecks))
  
  ; wait for cueStatusChecks to pause
  THR_waitForCueStatusChecksToEnd()
  
  THR_suspendAThreadAndWait(#SCS_THREAD_CONTROL, 20, 1000)
  
;   debugMsg(sProcName, "calling debugCuePtrs()")
;   debugCuePtrs()
  
  nUndoResult = -1
  With *pLastGroupInfo
    \nCuePtr1 = -1
    \nCuePtr2 = -1
    \nSubPtr = -1
    \nAudPtr = -1
  EndWith
  
  debugMsg(sProcName, "grMUR\nUndoGroupPtr=" + grMUR\nUndoGroupPtr)
  If grMUR\nUndoGroupPtr >= 0
    nMyUndoGroupId = gaUndoGroup(grMUR\nUndoGroupPtr)\nUndoGroupId
    debugMsg(sProcName, "nUndoGroupPtr=" + grMUR\nUndoGroupPtr + ", nMyUndoGroupId=" + nMyUndoGroupId)
    For n3 = grMUR\nUndoItemPtr To 1 Step -1
      debugMsg(sProcName, "gaUndoItem(" + n3 + ")\nUndoGroupId=" + gaUndoItem(n3)\nUndoGroupId)
      If gaUndoItem(n3)\nUndoGroupId = nMyUndoGroupId
        With gaUndoItem(n3)
          debugMsg(sProcName, "n3=" + n3 + ", \nType=" + decodeUndoType(\nItemType) + ", \nAction=" + decodeUndoAction(\nAction) + ", \nFlags=" + \nFlags + ", nMyUndoGroupId=" + nMyUndoGroupId)
          nMyUndoTypes | \nItemType
          nMyUndoFlags | \nFlags
          debugMsg(sProcName, "n3=" + n3 + ", nMyUndoTypes=" + nMyUndoTypes + ", nMyUndoFlags=" + nMyUndoFlags)
          
          Select \nItemType
            Case #SCS_UNDO_TYPE_EDITDEVS
              ;{
              Select \nAction
                Case #SCS_UNDO_ACTION_CHANGE        ;---- UNDO CHANGE EDITDEVS
                  debugMsg(sProcName, "UNDO CHANGE EDITDEVS")
                  For n = grMUR\nB4ProdPtr To 0 Step -1
                    If gaB4ImageProd(n)\nUndoItemId = \nUndoItemId
                      grProdForDevChgs = gaB4ImageDevChgs(n)\rProdForDevChgs
                      nUndoResult = grMUR\nUndoGroupPtr
                      ;Break
                    EndIf
                  Next n
                  WEP_setRetryActivateBtn()
                  clearVUDisplay()
                  gbCallPopulateGrid = #True
                  gbCallLoadDispPanels = #True
              EndSelect
              ;}
            Case #SCS_UNDO_TYPE_PROD
              ;{
              Select \nAction
                Case #SCS_UNDO_ACTION_CHANGE         ;---- UNDO CHANGE PROD
                  debugMsg(sProcName, "UNDO CHANGE PROD")
                  For n = grMUR\nB4ProdPtr To 0 Step -1
                    If gaB4ImageProd(n)\nUndoItemId = \nUndoItemId
                      grProd = gaB4ImageProd(n)\rProd
                      nUndoResult = grMUR\nUndoGroupPtr
                      ;Break
                    EndIf
                  Next n
                  If \nFlags & #SCS_UNDO_FLAG_SET_PROD_NODE_TEXT
                    WED_setProdNodeText()
                    WEP_setPageTitle()
                    WED_setWindowTitle()
                    WMN_setWindowTitle()
                    WED_displayTemplateInfoIfReqd(#True)
                    WMN_displayTemplateInfoIfReqd(#True)
                  EndIf
                  WEP_setRetryActivateBtn()
                  clearVUDisplay()
                  ; call setFirstAndLastDev for each aud as this may have been affected by device changes in prod
                  For k = 1 To gnLastAud
                    If aAud(k)\bExists
                      setFirstAndLastDev(k)
                    EndIf
                  Next k
                  gbCallPopulateGrid = #True
                  gbCallLoadDispPanels = #True
                  
                Case #SCS_UNDO_ACTION_DRAG           ;---- UNDO DRAG AND DROP
                  ; no special action
                  nUndoResult = grMUR\nUndoGroupPtr
                  
                Case #SCS_UNDO_ACTION_RENUMBER_CUES  ;---- UNDO RENUMBER CUES
                  ; no special action
                  nUndoResult = grMUR\nUndoGroupPtr
                  
                Case #SCS_UNDO_ACTION_BULK_EDIT      ;---- UNDO BULK EDIT
                  ; no special action
                  nUndoResult = grMUR\nUndoGroupPtr
                  
                Case #SCS_UNDO_ACTION_IMPORT_FILES   ;---- UNDO IMPORT FILES
                  ; no special action
                  nUndoResult = grMUR\nUndoGroupPtr
                  
                Case #SCS_UNDO_ACTION_MULTI_CUE_COPY_ETC ;---- UNDO MULTI CUE COPY ETC
                  ; no special action
                  nUndoResult = grMUR\nUndoGroupPtr
                  
                Default
                  sMsg = "unhandled type/action. type=" + decodeUndoType(\nItemType) + ", action=" + decodeUndoAction(\nAction)
                  debugMsg(sProcName, sMsg)
                  scsMessageRequester(sProcName, sMsg, #PB_MessageRequester_Error)
                  ProcedureReturn
                  
              EndSelect
              ;}
            Case #SCS_UNDO_TYPE_CUE
              ;{
              nMyUndoFlags | #SCS_UNDO_FLAG_REDO_MAIN  ; always redo main for cue changes
              debugMsg(sProcName, "nMyUndoFlags=" + nMyUndoFlags)
              Select \nAction
                Case #SCS_UNDO_ACTION_CHANGE         ;---- UNDO CHANGE CUE
                  For n = grMUR\nB4CuePtr To 0 Step -1
                    If gaB4ImageCue(n)\nUndoItemId = \nUndoItemId
                      If \nNewPtr >= 0
                        grMUR\rPreserveCue = aCue(\nNewPtr)
                        aCue(\nNewPtr) = gaB4ImageCue(n)\rCue
                        preserveCueCurrInfo(\nNewPtr)
                        If (\nFlags & #SCS_UNDO_FLAG_REDO_CUE) <> 0
                          If *pLastGroupInfo\nCuePtr1 = -1
                            *pLastGroupInfo\nCuePtr1 = \nNewPtr
                          Else
                            *pLastGroupInfo\nCuePtr2 = \nNewPtr
                          EndIf
                        EndIf
                        loadGridRow(\nNewPtr)
                      EndIf
                      nUndoResult = grMUR\nUndoGroupPtr
                    EndIf
                  Next n
                  
                Case #SCS_UNDO_ACTION_ADD_CUE        ;---- UNDO ADD CUE
                  If \nNewPtr >= 0
                    For i = (\nNewPtr + 1) To gnLastCue
                      aCue(i-1) = aCue(i)
                    Next i
                    gnLastCue - 1
                    gnCueEnd - 1
                  EndIf
                  setEditCueSubAudPtrs(\nNewPtr)
                  nUndoResult = grMUR\nUndoGroupPtr
                  
                Case #SCS_UNDO_ACTION_DELETE         ;---- UNDO DELETE CUE
                  If \nOldPtr >= 0
                    For i = (gnLastCue + 1) To (\nOldPtr + 1) Step -1
                      aCue(i) = aCue(i-1)
                    Next i
                    For n = grMUR\nB4CuePtr To 0 Step -1
                      If gaB4ImageCue(n)\nUndoItemId = \nUndoItemId
                        ; do not use preserveCueCurrInfo as there is no curr info for a deleted cue
                        aCue(\nOldPtr) = gaB4ImageCue(n)\rCue
                      EndIf
                    Next n
                    ; mark sub and aud array entries as existent
                    j = aCue(\nOldPtr)\nFirstSubIndex
                    While j >= 0
                      If aSub(j)\bSubTypeF Or aSub(j)\bSubTypeP Or aSub(j)\bSubTypeA
                        k = aSub(j)\nFirstAudIndex
                        While k >= 0
                          aAud(k)\bExists = #True
                          k = aAud(k)\nNextAudIndex
                        Wend
                      EndIf
                      aSub(j)\bExists = #True
                      j = aSub(j)\nNextSubIndex
                    Wend
                    gnLastCue + 1
                    gnCueEnd + 1
                    setEditCueSubAudPtrs(\nOldPtr)
                  EndIf
                  nUndoResult = grMUR\nUndoGroupPtr
                  
                Case #SCS_UNDO_ACTION_MOVE_CUE           ;---- UNDO MOVE CUE
                  ; see also #SCS_UNDO_ACTION_DRAG_CUE
                  debugMsg(sProcName, "undo move \nNewPtr=" + \nNewPtr + ", \nOldPtr=" + \nOldPtr)
                  If (\nNewPtr >= 0) And (\nOldPtr >= 0) And (\nNewPtr <> \nOldPtr)
                    If \nNewPtr > \nOldPtr
                      rTmpCue = aCue(\nNewPtr)
                      For i = (\nNewPtr - 1) To \nOldPtr Step -1
                        aCue(i+1) = aCue(i)
                      Next i
                      aCue(\nOldPtr) = rTmpCue
                    Else
                      rTmpCue = aCue(\nNewPtr)
                      For i = \nNewPtr To (\nOldPtr - 1)
                        aCue(i) = aCue(i+1)
                      Next i
                      aCue(\nOldPtr) = rTmpCue
                    EndIf
                    setEditCueSubAudPtrs(\nOldPtr)
                    *pLastGroupInfo\nCuePtr1 = \nNewPtr
                    *pLastGroupInfo\nCuePtr2 = \nOldPtr
                  EndIf
                  nUndoResult = grMUR\nUndoGroupPtr
                  
                Case #SCS_UNDO_ACTION_MAKE_SCS_CUE_FROM_SUBS  ;---- UNDO MAKE CUE FROM SUBS
                  debugMsg(sProcName, "undo moveleft \nNewPtr=" + \nNewPtr + ", \nOldPtr=" + \nOldPtr)
                  If (\nNewPtr >= 0) And (\nOldPtr >= 0) And (\nNewPtr <> \nOldPtr)
                    *pLastGroupInfo\nCuePtr1 = \nNewPtr
                    *pLastGroupInfo\nCuePtr2 = \nOldPtr
                    sCue = aCue(\nOldPtr)\sCue
                    nSubNo = 0
                    nPrevSubIndex = aCue(\nOldPtr)\nFirstSubIndex
                    j = aCue(\nOldPtr)\nFirstSubIndex
                    While j >= 0
                      nSubNo = aSub(j)\nSubNo
                      nPrevSubIndex = j
                      j = aSub(j)\nNextSubIndex
                    Wend
                    ; nSubNo now contains last existing nSubNo of old cue, and nPrevSubIndex contains pointer to the last existing sub of the old cue
                    ; now move subs from new cue back to the end of the old cue
                    j = aCue(\nNewPtr)\nFirstSubIndex
                    If nPrevSubIndex = -1
                      aCue(\nOldPtr)\nFirstSubIndex = j
                    Else
                      aSub(nPrevSubIndex)\nNextSubIndex = j
                    EndIf
                    aSub(j)\nPrevSubIndex = nPrevSubIndex
                    While j >= 0
                      aSub(j)\nCueIndex = *pLastGroupInfo\nCuePtr2
                      aSub(j)\sCue = sCue
                      nSubNo + 1
                      aSub(j)\nSubNo = nSubNo
                      j = aSub(j)\nNextSubIndex
                    Wend
                    ; now delete the new cue that was created
                    For i = (\nNewPtr+1) To gnLastCue
                      aCue(i-1) = aCue(i)
                    Next i
                    gnLastCue - 1
                    gnCueEnd - 1
                    setEditCueSubAudPtrs(\nOldPtr)
                    ; resyncCuePtrs()
                    ; loadHotkeyArray()
                  EndIf
                  nUndoResult = grMUR\nUndoGroupPtr
                  
                Case #SCS_UNDO_ACTION_DRAG_CUE          ;---- UNDO DRAG CUE
                  ; see also #SCS_UNDO_ACTION_MOVE_CUE
                  nPreChangeCueToMove = \nOldPtr        ; was populated in pre-change from nCueToMove
                  nPreChangeTargetCuePtr = \nExtraParam ; was populated in pre-change from nTargetCuePtr
                  If nPreChangeCueToMove < nPreChangeTargetCuePtr
                    nThisCueToMove = nPreChangeTargetCuePtr
                    nThisTargetCuePtr = nPreChangeCueToMove - 1
                  Else
                    nThisCueToMove = nPreChangeTargetCuePtr + 1
                    nThisTargetCuePtr = nPreChangeCueToMove
                  EndIf
                  debugMsg(sProcName, "calling moveCue(" + nThisCueToMove + ", " + nThisTargetCuePtr + ")")
                  moveCue(nThisCueToMove, nThisTargetCuePtr)
                  *pLastGroupInfo\nCuePtr1 = \nNewPtr
                  *pLastGroupInfo\nCuePtr2 = \nOldPtr
                  nUndoResult = grMUR\nUndoGroupPtr
                  
                Default
                  sMsg = "unhandled type/action. type=" + decodeUndoType(\nItemType) + ", action=" + decodeUndoAction(\nAction)
                  debugMsg(sProcName, sMsg)
                  scsMessageRequester(sProcName, sMsg, #PB_MessageRequester_Error)
                  ProcedureReturn
                  
              EndSelect
              ;}
            Case #SCS_UNDO_TYPE_SUB
              ;{
              Select \nAction
                Case #SCS_UNDO_ACTION_CHANGE         ;---- UNDO CHANGE SUB
                  For n = grMUR\nB4SubPtr To 0 Step -1
                    If gaB4ImageSub(n)\nUndoItemId = \nUndoItemId
                      If \nNewPtr >= 0
                        grMUR\rPreserveSub = aSub(\nNewPtr)
                        aSub(\nNewPtr) = gaB4ImageSub(n)\rSub
                        preserveSubCurrInfo(\nNewPtr)
                        *pLastGroupInfo\nSubPtr = \nNewPtr
                        Break
                      EndIf
                    EndIf
                  Next n
                  nUndoResult = grMUR\nUndoGroupPtr
                  
                Case #SCS_UNDO_ACTION_ADD_SUB        ;---- UNDO ADD SUB
                  If \nNewPtr >= 0
                    delSubForSubPtr(\nNewPtr)
                  EndIf
                  nUndoResult = grMUR\nUndoGroupPtr
                  
                Case #SCS_UNDO_ACTION_MOVE_SUB       ;---- UNDO MOVE SUB
                  ; debugMsg(sProcName, "undo move \nOldPtr=" + \nOldPtr)
                  For n = grMUR\nB4SubPtr To 0 Step -1
                    If gaB4ImageSub(n)\nUndoItemId = \nUndoItemId
                      rTmpSub = gaB4ImageSub(n)\rSub
                      *pLastGroupInfo\nCuePtr1 = rTmpSub\nCueIndex
                      nMySubPtr = \nOldPtr
                      debugMsg(sProcName, "calling moveOneSub(" + nMySubPtr + ", " + rTmpSub\nCueIndex + ", " + rTmpSub\nSubNo + ")")
                      moveOneSub(nMySubPtr, rTmpSub\nCueIndex, rTmpSub\nSubNo)
                      *pLastGroupInfo\nCuePtr2 = aSub(nMySubPtr)\nCueIndex
                      debugMsg(sProcName, "nCuePtr1=" + *pLastGroupInfo\nCuePtr1 + ", nCuePtr2=" + *pLastGroupInfo\nCuePtr2)
                      Break
                    EndIf
                  Next n
                  nUndoResult = grMUR\nUndoGroupPtr
                  
                Case #SCS_UNDO_ACTION_DELETE         ;---- UNDO DELETE SUB
                  debugMsg(sProcName, "undo delete \nOldPtr=" + \nOldPtr)
                  For n = grMUR\nB4SubPtr To 0 Step -1
                    If gaB4ImageSub(n)\nUndoItemId = \nUndoItemId
                      rTmpSub = gaB4ImageSub(n)\rSub
                      *pLastGroupInfo\nCuePtr1 = rTmpSub\nCueIndex
                      nMySubPtr = \nOldPtr
                      aSub(nMySubPtr) = rTmpSub
                      If rTmpSub\nPrevSubIndex = -1
                        aCue(*pLastGroupInfo\nCuePtr1)\nFirstSubIndex = nMySubPtr
                      Else
                        aSub(rTmpSub\nPrevSubIndex)\nNextSubIndex = nMySubPtr
                      EndIf
                      If rTmpSub\nNextSubIndex <> -1
                        aSub(rTmpSub\nNextSubIndex)\nPrevSubIndex = nMySubPtr
                      EndIf
                      Break
                    EndIf
                  Next n
                  nUndoResult = grMUR\nUndoGroupPtr
                  
                Default
                  sMsg = "unhandled type/action. type=" + decodeUndoType(\nItemType) + ", action=" + decodeUndoAction(\nAction)
                  debugMsg(sProcName, sMsg)
                  scsMessageRequester(sProcName, sMsg, #PB_MessageRequester_Error)
                  ProcedureReturn
                  
              EndSelect
              ;}
            Case #SCS_UNDO_TYPE_AUD
              ;{
              Select \nAction
                Case #SCS_UNDO_ACTION_CHANGE         ;---- UNDO CHANGE AUD
                  For n = grMUR\nB4AudPtr To 0 Step -1
                    If gaB4ImageAud(n)\nUndoItemId = \nUndoItemId
                      If \nNewPtr >= 0
                        nUndoAudPtr = \nNewPtr
                        grMUR\rPreserveAud = aAud(nUndoAudPtr)
                        aAud(nUndoAudPtr) = gaB4ImageAud(n)\rAud
                        aAud(nUndoAudPtr)\bAudNormSet = #False ; Clear this separately becuase it may have been set outside of a PreChange/PostChange sequence in a call to calcAudLoudness()
                        preserveAudCurrInfo(nUndoAudPtr)
                        *pLastGroupInfo\nAudPtr = nUndoAudPtr
                        *pLastGroupInfo\nSubPtr = aAud(\nNewPtr)\nSubIndex
                        setFileStateEtc(nUndoAudPtr)
                        If (\nFlags & #SCS_UNDO_FLAG_OPEN_FILE) <> 0
                          ; close and re-open the file to fix an 'invalid handle' error that can occur if the 'undo' removes a device
                          ; ('invalid handle' bug reported by Christian Peters, 11/06/2014)
                          If aAud(nUndoAudPtr)\nFileState = #SCS_FILESTATE_OPEN
                            debugMsg(sProcName, "calling closeAud(" + getAudLabel(nUndoAudPtr) + ")")
                            closeAud(nUndoAudPtr)
                          EndIf
                          If aAud(nUndoAudPtr)\nFileState <> #SCS_FILESTATE_OPEN
                            debugMsg(sProcName, "calling openMediaFile(" + getAudLabel(nUndoAudPtr) + ")")
                            openMediaFile(nUndoAudPtr)
                          EndIf
                        EndIf
                        ; end added 12/06/2014
                        If nUndoAudPtr = nEditAudPtr
                          If aAud(nEditAudPtr)\bAudTypeF
                            recalcLvlPtLevels(nEditAudPtr)
                            aAud(nEditAudPtr)\bLvlPtRunForceSettings = #True
                            doLvlPtRun(nEditAudPtr, aAud(nEditAudPtr)\nCuePos)
                            rWQF\bCallSetOrigDBLevels = #True
                          ElseIf aAud(nEditAudPtr)\bAudTypeP
                            rWQP\bCallSetOrigDBLevels = #True
                          EndIf
                        EndIf
                      EndIf
                      nUndoResult = grMUR\nUndoGroupPtr
                    EndIf
                  Next n
                  
                Case #SCS_UNDO_ACTION_ADD_AUD        ;---- UNDO ADD AUD
                  If \nNewPtr >= 0
                    delAudForAudPtr(\nNewPtr)
                  EndIf
                  nUndoResult = grMUR\nUndoGroupPtr
                  
                Case #SCS_UNDO_ACTION_DELETE         ;---- UNDO DELETE AUD
                  If \nOldPtr >= 0
                    nMyAudPtr = \nOldPtr
                    For n = grMUR\nB4AudPtr To 0 Step -1
                      If gaB4ImageAud(n)\nUndoItemId = \nUndoItemId
                        If \nOldPtr >= 0
                          grMUR\rPreserveAud = aAud(\nOldPtr)
                          aAud(\nOldPtr) = gaB4ImageAud(n)\rAud
                          preserveAudCurrInfo(\nOldPtr)
                        EndIf
                      EndIf
                    Next n
                    setFileStateEtc(nMyAudPtr)
                    nPrevAudIndex = aAud(nMyAudPtr)\nPrevAudIndex
                    If nPrevAudIndex = -1
                      aSub(aAud(nMyAudPtr)\nSubIndex)\nFirstAudIndex = nMyAudPtr
                    Else
                      aAud(nPrevAudIndex)\nNextAudIndex = nMyAudPtr
                    EndIf
                    If aAud(nMyAudPtr)\nNextAudIndex >= 0
                      aAud(aAud(nMyAudPtr)\nNextAudIndex)\nPrevAudIndex = nMyAudPtr
                    EndIf
                    *pLastGroupInfo\nCuePtr1 = aAud(nMyAudPtr)\nCueIndex
                    If aAud(nMyAudPtr)\nFileState <> #SCS_FILESTATE_OPEN
                      openMediaFile(nMyAudPtr)
                    EndIf
                    nAudCount = 0
                    k = aSub(aAud(nMyAudPtr)\nSubIndex)\nFirstAudIndex
                    While k >= 0
                      nAudCount + 1
                      aAud(k)\nAudNo = nAudCount
                      k = aAud(k)\nNextAudIndex
                    Wend
                    aSub(aAud(nMyAudPtr)\nSubIndex)\nAudCount = nAudCount
                    generatePlayOrder(aAud(nMyAudPtr)\nSubIndex)
                    setLabels(*pLastGroupInfo\nCuePtr1)
                  EndIf
                  nUndoResult = grMUR\nUndoGroupPtr
                  
                Default
                  sMsg = "unhandled type/action. type=" + decodeUndoType(\nItemType) + ", action=" + decodeUndoAction(\nAction)
                  debugMsg(sProcName, sMsg)
                  scsMessageRequester(sProcName, sMsg, #PB_MessageRequester_Error)
                  ProcedureReturn
                  
              EndSelect
              ;}
          EndSelect
        EndWith
      EndIf
    Next n3
    
    resetLastSubAndLastAud()
    resyncCuePtrs()
    loadCueBrackets()
    loadHotkeyArray()
    loadCueMarkerArrays()
    DMX_setChaseCueCount()  ; counts lighting cues that contain chase
    debugMsg(sProcName, "calling DMX_loadDMXChannelMonitoredArray(@grProd)")
    DMX_loadDMXChannelMonitoredArray(@grProd)
    
    ; Added 8Sep2023 11.10.0ca
    gbCallLoadDispPanels = #True
    gbCallLoadGridRowsWhereRequested = #True
    gbForceNodeDisplay = #True
    If IsGadget(WED\tvwProdTree)
      ; should be #True
      debugMsg(sProcName, "calling ED_loadDevChgsFromProd()")
      ED_loadDevChgsFromProd()
      debugMsg(sProcName, "calling WED_tvwProdTree_NodeClick(#True)")
      WED_tvwProdTree_NodeClick(#True) ; causes relevant changes to be shown in the editor window
    EndIf
    ; End added 8Sep2023 11.10.0ca
    
  EndIf
  
  With *pLastGroupInfo
    If \nCuePtr1 >= 0
      resyncCuePtrs(\nCuePtr1)
    EndIf
    If \nCuePtr2 >= 0 And \nCuePtr2 <> \nCuePtr1
      resyncCuePtrs(\nCuePtr2)
    EndIf
  EndWith

  If nUndoResult >= 0
    grMUR\nUndoGroupPtr - 1
    debugMsg(sProcName, "\nUndoGroupPtr=" + grMUR\nUndoGroupPtr)
  EndIf

  setNonLinearCueFlags()
  CSRD_SetRemDevUsedInProd()
  
  For i = 1 To gnLastCue
    setLinksForCue(i)
    setLinksForAudsWithinSubsForCue(i)
  Next i
  setMTCLinksForAllCues()
  buildAudSetArray()

  ; set return values
  ;   byRef values
  *pLastGroupInfo\nUndoTypes = nMyUndoTypes
  debugMsg(sProcName, "nMyUndoFlags=" + nMyUndoFlags)
  *pLastGroupInfo\nUndoFlags = nMyUndoFlags
  
  debugMsg(sProcName, "calling displayOrHideVideoWindows()")
  displayOrHideVideoWindows()
  
;   debugMsg(sProcName, "calling debugCuePtrs()")
;   debugCuePtrs()
  
  THR_resumeAThread(#SCS_THREAD_CONTROL)
  
  grRAI\nStatus | #SCS_RAI_STATUS_PROD | #SCS_RAI_STATUS_CUE

  ; debugMsg(sProcName, #SCS_END + ", returning nUndoResult=" + nUndoResult)
  ProcedureReturn nUndoResult
EndProcedure

Procedure redoLastGroup(*pLastGroupInfo.tyLastGroupInfo)
  PROCNAMEC()
  ; Description:
  ; 1. redo changes, etc in group pointed at my (nUndoGroupPtr + 1)
  ; 2. step nUndoGroupPtr forward 1
  ; 3. return nGroupPtr of group just redone, or -1 if undo failed
  Protected nRedoResult, n, n2, n3
  Protected h
  Protected i, j, k
  Protected nSubjectId, nSubjectPtr
  Protected nMyUndoGroupId
  Protected rTmpCue.tyCue, rTmpSub.tySub
  Protected nMySubPtr, nMyAudPtr
  Protected nMyUndoTypes, nMyUndoFlags
  Protected sMsg.s, nAudCount
  Protected nPrevSubIndex, nPrevAudIndex
  Protected nPreChangeCueToMove, nPreChangeTargetCuePtr

  debugMsg(sProcName, #SCS_START)
  
  ; wait for cueStatusChecks to pause
  THR_waitForCueStatusChecksToEnd()
  ; While gbInCueStatusChecks
    ; Delay(10)
  ; Wend

  nRedoResult = -1
  With *pLastGroupInfo
    \nCuePtr1 = -1
    \nCuePtr2 = -1
    \nSubPtr = -1
    \nAudPtr = -1
  EndWith
  
  If grMUR\nUndoGroupPtr < grMUR\nMaxRedoGroupPtr
    nMyUndoGroupId = gaUndoGroup(grMUR\nUndoGroupPtr + 1)\nUndoGroupId
    For n3 = 1 To grMUR\nMaxRedoItemPtr
      If gaUndoItem(n3)\nUndoGroupId = nMyUndoGroupId
        With gaUndoItem(n3)
          nMyUndoTypes = nMyUndoTypes | \nItemType
          nMyUndoFlags = nMyUndoFlags | \nFlags
          
          debugMsg(sProcName, "gaUndoItem(" + n3 + ")\nItemType=" + decodeUndoType(\nItemType) + ", \nAction=" + decodeUndoAction(\nAction) + ", \nUndoItemId=" + \nUndoItemId)
          Select \nItemType
              
            Case #SCS_UNDO_TYPE_PROD
              Select \nAction
                Case #SCS_UNDO_ACTION_CHANGE         ;---- REDO CHANGE PROD
                  For n = grMUR\nAftProdPtr To 0 Step -1
                    If gaAftImageProd(n)\nUndoItemId = \nUndoItemId
                      grProd = gaAftImageProd(n)\rProd
                      If \nFlags & #SCS_UNDO_FLAG_CHANGE_LOGICAL_DEV_NAME
                        changeDevLogicalName(\vOld\sVar, \vNew\sVar)
                      EndIf
                      nRedoResult = grMUR\nUndoGroupPtr + 1
                      ;Break
                    EndIf
                  Next n
                  ; WEP_setDevChgsBtns()
                  WEP_setRetryActivateBtn()
                  clearVUDisplay()
                  ; call setFirstAndLastDev for each aud as this may have been affected by device changes in prod
                  For k = 1 To gnLastAud
                    If aAud(k)\bExists
                      setFirstAndLastDev(k)
                    EndIf
                  Next k
                  gbCallPopulateGrid = #True
                  gbCallLoadDispPanels = #True
                  
                Case #SCS_UNDO_ACTION_DRAG           ;---- REDO DRAG AND DROP
                  ; no special action
                  nRedoResult = grMUR\nUndoGroupPtr + 1
                  
                Case #SCS_UNDO_ACTION_RENUMBER_CUES  ;---- REDO RENUMBER CUES
                  ; no special action
                  nRedoResult = grMUR\nUndoGroupPtr + 1
                  
                Case #SCS_UNDO_ACTION_BULK_EDIT      ;---- REDO BULK EDIT
                  ; no special action
                  nRedoResult = grMUR\nUndoGroupPtr + 1
                  
                Case #SCS_UNDO_ACTION_IMPORT_FILES   ;---- REDO IMPORT FILES
                  ; no special action
                  nRedoResult = grMUR\nUndoGroupPtr + 1
                  
                Case #SCS_UNDO_ACTION_MULTI_CUE_COPY_ETC ;---- REDO MULTI CUE COPY ETC
                  ; no special action
                  nRedoResult = grMUR\nUndoGroupPtr + 1
                  
                Default
                  sMsg = "unhandled type/action. type=" + decodeUndoType(\nItemType) + ", action=" + decodeUndoAction(\nAction)
                  debugMsg(sProcName, sMsg)
                  scsMessageRequester(sProcName, sMsg, #PB_MessageRequester_Error)
                  ProcedureReturn
                  
              EndSelect
              
              mergeDuplicateAsioDevs()
              
            Case #SCS_UNDO_TYPE_CUE
              nMyUndoFlags = nMyUndoFlags | #SCS_UNDO_FLAG_REDO_MAIN  ; always redo main for cue changes
              Select \nAction
                Case #SCS_UNDO_ACTION_CHANGE         ;---- REDO CHANGE CUE
                  For n = grMUR\nAftCuePtr To 0 Step -1
                    If gaAftImageCue(n)\nUndoItemId = \nUndoItemId
                      If \nNewPtr >= 0
                        grMUR\rPreserveCue = aCue(\nNewPtr)
                        aCue(\nNewPtr) = gaAftImageCue(n)\rCue
                        preserveCueCurrInfo(\nNewPtr)
                        If (\nFlags & #SCS_UNDO_FLAG_REDO_CUE) <> 0
                          If *pLastGroupInfo\nCuePtr1 = -1
                            *pLastGroupInfo\nCuePtr1 = \nNewPtr
                          Else
                            *pLastGroupInfo\nCuePtr2 = \nNewPtr
                          EndIf
                        EndIf
                        loadGridRow(\nNewPtr)
                      EndIf
                      nRedoResult = grMUR\nUndoGroupPtr + 1
                      ;Break
                    EndIf
                  Next n
                  
                Case #SCS_UNDO_ACTION_ADD_CUE        ;---- REDO ADD CUE
                  If \nNewPtr >= 0
                    For i = gnLastCue To \nNewPtr Step -1
                      aCue(i+1) = aCue(i)
                    Next i
                    For n = grMUR\nAftCuePtr To 0 Step -1
                      If gaAftImageCue(n)\nUndoItemId = \nUndoItemId
                        If \nNewPtr >= 0
                          ; do not use preserveCueCurrInfo as no curr info for an added cue
                          aCue(\nNewPtr) = gaAftImageCue(n)\rCue
                          debugMsg(sProcName, "aCue(" + \nNewPtr + ")\sCueDescr=" + aCue(\nNewPtr)\sCueDescr + ", \sValidatedDescr=" + aCue(\nNewPtr)\sValidatedDescr)
                        EndIf
                        ;Break
                      EndIf
                    Next n
                    gnLastCue + 1
                    gnCueEnd + 1
                    setEditCueSubAudPtrs(\nNewPtr)
                    ; resyncCuePtrs()
                    ; loadHotkeyArray()
                  EndIf
                  nRedoResult = grMUR\nUndoGroupPtr + 1
                  
                Case #SCS_UNDO_ACTION_DELETE         ;---- REDO DELETE CUE
                  If \nOldPtr >= 0
                    ; mark sub and aud array entries as non-existent
                    j = aCue(\nOldPtr)\nFirstSubIndex
                    While j >= 0
                      If aSub(j)\bSubTypeF Or aSub(j)\bSubTypeP Or aSub(j)\bSubTypeA
                        k = aSub(j)\nFirstAudIndex
                        While k >= 0
                          aAud(k)\bExists = #False
                          k = aAud(k)\nNextAudIndex
                        Wend
                      EndIf
                      aSub(j)\bExists = #False
                      j = aSub(j)\nNextSubIndex
                    Wend
                    For i = \nOldPtr To gnLastCue
                      If i < gnLastCue
                        aCue(i) = aCue(i+1)
                      EndIf
                    Next i
                    gnLastCue - 1
                    gnCueEnd - 1
                    setEditCueSubAudPtrs(\nOldPtr)
                    ; resyncCuePtrs()
                    ; loadHotkeyArray()
                  EndIf
                  nRedoResult = grMUR\nUndoGroupPtr + 1
                  
                Case #SCS_UNDO_ACTION_MOVE_CUE           ;---- REDO MOVE CUE
                  ; see also #SCS_UNDO_ACTION_DRAG_CUE
                  debugMsg(sProcName, "redo move \nNewPtr=" + \nNewPtr + ", \nOldPtr=" + \nOldPtr)
                  If (\nNewPtr >= 0) And (\nOldPtr >= 0) And (\nNewPtr <> \nOldPtr)
                    If \nOldPtr > \nNewPtr
                      rTmpCue = aCue(\nOldPtr)
                      For i = (\nOldPtr-1) To \nNewPtr Step -1
                        aCue(i+1) = aCue(i)
                      Next i
                      aCue(\nNewPtr) = rTmpCue
                    Else
                      rTmpCue = aCue(\nOldPtr)
                      For i = \nOldPtr To (\nNewPtr-1)
                        aCue(i) = aCue(i+1)
                      Next i
                      aCue(\nNewPtr) = rTmpCue
                    EndIf
                    setEditCueSubAudPtrs(\nNewPtr)
                    *pLastGroupInfo\nCuePtr1 = \nOldPtr
                    *pLastGroupInfo\nCuePtr2 = \nNewPtr
                  EndIf
                  nRedoResult = grMUR\nUndoGroupPtr + 1
                  
                Case #SCS_UNDO_ACTION_MAKE_SCS_CUE_FROM_SUBS ;---- REDO MAKE CUE FROM SUBS
                  debugMsg(sProcName, "redo moveleft \nNewPtr=" + \nNewPtr + ", \nOldPtr=" + \nOldPtr)
                  For i = gnLastCue To \nNewPtr Step -1
                    aCue(i+1) = aCue(i)
                  Next i
                  For n = grMUR\nAftCuePtr To 0 Step -1
                    If gaAftImageCue(n)\nUndoItemId = \nUndoItemId
                      If \nNewPtr >= 0
                        ; do not use preserveCueCurrInfo as no curr info for an added cue
                        aCue(\nNewPtr) = gaAftImageCue(n)\rCue
                      EndIf
                      ;Break
                    EndIf
                  Next n
                  gnLastCue + 1
                  gnCueEnd + 1
                  j = aCue(\nNewPtr)\nFirstSubIndex
                  ; set termination point of previous cue
                  nPrevSubIndex = aSub(j)\nPrevSubIndex
                  If nPrevSubIndex = -1
                    aCue(aSub(\nNewPtr)\nCueIndex)\nFirstSubIndex = -1
                  Else
                    aSub(nPrevSubIndex)\nNextSubIndex = -1
                  EndIf
                  aSub(j)\nPrevSubIndex = -1
                  setChildInfoForCue(\nNewPtr)
                  setLabels(\nNewPtr)
                  setEditCueSubAudPtrs(\nNewPtr)
                  resyncCuePtrs()
                  autoSetNodeExpanded(\nNewPtr)
                  loadHotkeyArray()
                  loadCueMarkerArrays()
                  nRedoResult = grMUR\nUndoGroupPtr + 1
                  
                Case #SCS_UNDO_ACTION_DRAG_CUE          ;---- REDO DRAG CUE
                  ; see also #SCS_UNDO_ACTION_MOVE_CUE
                  nPreChangeCueToMove = \nOldPtr        ; was populated in pre-change from nCueToMove
                  nPreChangeTargetCuePtr = \nExtraParam ; was populated in pre-change from nTargetCuePtr
                  debugMsg(sProcName, "calling moveCue(" + nPreChangeCueToMove + ", " + nPreChangeTargetCuePtr + ")")
                  moveCue(nPreChangeCueToMove, nPreChangeTargetCuePtr)
                  *pLastGroupInfo\nCuePtr1 = \nOldPtr
                  *pLastGroupInfo\nCuePtr2 = \nNewPtr
                  nRedoResult = grMUR\nUndoGroupPtr + 1
                  
                Default
                  sMsg = "unhandled type/action. type=" + decodeUndoType(\nItemType) + ", action=" + decodeUndoAction(\nAction)
                  debugMsg(sProcName, sMsg)
                  scsMessageRequester(sProcName, sMsg, #PB_MessageRequester_Error)
                  ProcedureReturn
                  
              EndSelect
              
            Case #SCS_UNDO_TYPE_SUB
              Select \nAction
                Case #SCS_UNDO_ACTION_CHANGE         ;---- REDO CHANGE SUB
                  For n = grMUR\nAftSubPtr To 0 Step -1
                    If gaAftImageSub(n)\nUndoItemId = \nUndoItemId
                      If \nNewPtr >= 0
                        grMUR\rPreserveSub = aSub(\nNewPtr)
                        aSub(\nNewPtr) = gaAftImageSub(n)\rSub
                        preserveSubCurrInfo(\nNewPtr)
                        debugMsg(sProcName, "aSub(" + \nNewPtr + ") reinstated")
                      EndIf
                      nRedoResult = grMUR\nUndoGroupPtr + 1
                      ;Break
                    EndIf
                  Next n
                  
                Case #SCS_UNDO_ACTION_ADD_SUB        ;---- REDO ADD SUB
                  If \nNewPtr >= 0
                    nMySubPtr = \nNewPtr
                    For n = grMUR\nAftSubPtr To 0 Step -1
                      If gaAftImageSub(n)\nUndoItemId = \nUndoItemId
                        If \nNewPtr >= 0
                          ; do not use preserveSubCurrInfo as no curr info for an added sub
                          aSub(\nNewPtr) = gaAftImageSub(n)\rSub
                        EndIf
                        ;Break
                      EndIf
                    Next n
                    debugMsg(sProcName, "\nPrevSubIndex=" + aSub(\nNewPtr)\nPrevSubIndex + ", \nNextSubIndex=" + aSub(\nNewPtr)\nNextSubIndex + ", \bExists=" + strB(aSub(\nNewPtr)\bExists))
                    If aSub(\nNewPtr)\nPrevSubIndex = -1
                      aCue(aSub(\nNewPtr)\nCueIndex)\nFirstSubIndex = nMySubPtr
                    Else
                      aSub(aSub(\nNewPtr)\nPrevSubIndex)\nNextSubIndex = nMySubPtr
                    EndIf
                    If aSub(\nNewPtr)\nNextSubIndex >= 0
                      aSub(aSub(\nNewPtr)\nNextSubIndex)\nPrevSubIndex = nMySubPtr
                    EndIf
                    If aSub(\nNewPtr)\bSubTypeA Or aSub(\nNewPtr)\bSubTypeF Or aSub(\nNewPtr)\bSubTypeP
                      k = aSub(\nNewPtr)\nFirstAudIndex
                      While k >= 0
                        aAud(k)\bExists = #True
                        k = aAud(k)\nNextAudIndex
                      Wend
                    EndIf
                    *pLastGroupInfo\nCuePtr1 = aSub(\nNewPtr)\nCueIndex
                    debugMsg(sProcName, "nMySubPtr=" + nMySubPtr + ", nCuePtr1=" + *pLastGroupInfo\nCuePtr1)
                    debugMsg(sProcName, "aCue(" + aSub(\nNewPtr)\nCueIndex + ")\nFirstSubIndex=" + aCue(aSub(\nNewPtr)\nCueIndex)\nFirstSubIndex)
                    debugMsg(sProcName, "\nPrevSubIndex=" + aSub(\nNewPtr)\nPrevSubIndex + ", \nNextSubIndex=" + aSub(\nNewPtr)\nNextSubIndex)
                    renumberSubNos(*pLastGroupInfo\nCuePtr1)
                    debugMsg(sProcName, "calling setLabels(" + *pLastGroupInfo\nCuePtr1 + ")")
                    setLabels(*pLastGroupInfo\nCuePtr1)
                    setEditCueSubAudPtrs(*pLastGroupInfo\nCuePtr1) ; Added 29Dec2023 following test of adding an audio file cue, then undoing the change, then redoing the change. The redo crashed because aSub()\nFirstAudIndex had not been set
                  EndIf
                  debugMsg(sProcName, "setting nRedoResult=" + Str(grMUR\nUndoGroupPtr + 1))
                  nRedoResult = grMUR\nUndoGroupPtr + 1
                  
                Case #SCS_UNDO_ACTION_MOVE_SUB       ;---- REDO MOVE SUB
                  debugMsg(sProcName, "redo move \nOldPtr=" + \nOldPtr)
                  rTmpSub = gaAftImageSub(\nAftPtr)\rSub
                  *pLastGroupInfo\nCuePtr1 = rTmpSub\nCueIndex
                  debugMsg(sProcName, "rTmpSub\sCue=" + rTmpSub\sCue + ", \nCueIndex=" + rTmpSub\nCueIndex + ", \nSubNo=" + rTmpSub\nSubNo)
                  nMySubPtr = \nOldPtr
                  debugMsg(sProcName, "nMySubPtr=" + nMySubPtr)
                  moveOneSub(nMySubPtr, rTmpSub\nCueIndex, rTmpSub\nSubNo)
                  *pLastGroupInfo\nCuePtr2 = aSub(nMySubPtr)\nCueIndex
                  nRedoResult = grMUR\nUndoGroupPtr + 1
                  
                Case #SCS_UNDO_ACTION_DELETE         ;---- REDO DELETE SUB
                  debugMsg(sProcName, "redo delete \nOldPtr=" + \nOldPtr)
                  If \nOldPtr >= 0
                    delSubForSubPtr(\nOldPtr)
                  EndIf
                  nRedoResult = grMUR\nUndoGroupPtr + 1
                  
                Default
                  sMsg = "unhandled type/action. type=" + decodeUndoType(\nItemType) + ", action=" + decodeUndoAction(\nAction)
                  debugMsg(sProcName, sMsg)
                  scsMessageRequester(sProcName, sMsg, #PB_MessageRequester_Error)
                  ProcedureReturn
                  
              EndSelect
              
            Case #SCS_UNDO_TYPE_AUD
              Select \nAction
                Case #SCS_UNDO_ACTION_CHANGE         ;---- REDO CHANGE AUD
                  debugMsg(sProcName, "\nOldPtr=" + \nOldPtr + ", \nNewPtr=" + \nNewPtr)
                  For n = grMUR\nAftAudPtr To 0 Step -1
                    debugMsg(sProcName, "gaAftImageAud(" + n + ")\nUndoItemId=" + gaAftImageAud(n)\nUndoItemId)
                    If gaAftImageAud(n)\nUndoItemId = \nUndoItemId
                      If \nNewPtr >= 0
                        grMUR\rPreserveAud = aAud(\nNewPtr)
                        aAud(\nNewPtr) = gaAftImageAud(n)\rAud
                        preserveAudCurrInfo(\nNewPtr)
                        debugMsg(sProcName, "aAud(" + \nNewPtr + ")\sFileName=" + aAud(\nNewPtr)\sFileName)
                        *pLastGroupInfo\nAudPtr = \nNewPtr
                        *pLastGroupInfo\nSubPtr = aAud(\nNewPtr)\nSubIndex
                        setFileStateEtc(*pLastGroupInfo\nAudPtr)
                        If (\nFlags & #SCS_UNDO_FLAG_OPEN_FILE) <> 0
                          If aAud(*pLastGroupInfo\nAudPtr)\nFileState <> #SCS_FILESTATE_OPEN
                            debugMsg(sProcName, "calling openMediaFile(" + getAudLabel(*pLastGroupInfo\nAudPtr) + ")")
                            openMediaFile(*pLastGroupInfo\nAudPtr)
                          EndIf
                        EndIf
                      EndIf
                      nRedoResult = grMUR\nUndoGroupPtr + 1
                      ;Break
                    EndIf
                  Next n
                  
                Case #SCS_UNDO_ACTION_ADD_AUD        ;---- REDO ADD AUD
                  If \nNewPtr >= 0
                    nMyAudPtr = \nNewPtr
                    For n = grMUR\nAftAudPtr To 0 Step -1
                      If gaAftImageAud(n)\nUndoItemId = \nUndoItemId
                        If \nNewPtr >= 0
                          grMUR\rPreserveAud = aAud(\nNewPtr)
                          aAud(\nNewPtr) = gaAftImageAud(n)\rAud
                          preserveAudCurrInfo(\nNewPtr)
                        EndIf
                        ;Break
                      EndIf
                    Next n
                    setFileStateEtc(nMyAudPtr)
                    debugMsg(sProcName, "\nPrevAudIndex=" + aAud(nMyAudPtr)\nPrevAudIndex + ", \nNextAudIndex=" + aAud(nMyAudPtr)\nNextAudIndex +
                                        ", \bExists=" + strB(aAud(nMyAudPtr)\bExists) + ", \nFileState=" + decodeFileState(aAud(nMyAudPtr)\nFileState) + ", \nBassChannel[0]=" + aAud(nMyAudPtr)\nBassChannel[0])
                    nPrevAudIndex = aAud(nMyAudPtr)\nPrevAudIndex
                    If nPrevAudIndex = -1
                      aSub(aAud(nMyAudPtr)\nSubIndex)\nFirstAudIndex = nMyAudPtr
                      debugMsg(sProcName, "aSub(" + aAud(nMyAudPtr)\nSubIndex + ")\nFirstAudIndex=" + aSub(aAud(nMyAudPtr)\nSubIndex)\nFirstAudIndex)
                    Else
                      aAud(nPrevAudIndex)\nNextAudIndex = nMyAudPtr
                      debugMsg(sProcName, "aAud(" + getAudLabel(nPrevAudIndex) + ")\nNextAudIndex=" + getAudLabel(aAud(nPrevAudIndex)\nNextAudIndex))
                    EndIf
                    If aAud(nMyAudPtr)\nNextAudIndex >= 0
                      aAud(aAud(nMyAudPtr)\nNextAudIndex)\nPrevAudIndex = nMyAudPtr
                    EndIf
                    *pLastGroupInfo\nCuePtr1 = aAud(nMyAudPtr)\nCueIndex
                    debugMsg(sProcName, "nMyAudPtr=" + nMyAudPtr + ", nCuePtr1=" + *pLastGroupInfo\nCuePtr1)
                    If aAud(nMyAudPtr)\nFileState <> #SCS_FILESTATE_OPEN
                      openMediaFile(nMyAudPtr)
                    EndIf
                    nAudCount = 0
                    k = aSub(aAud(nMyAudPtr)\nSubIndex)\nFirstAudIndex
                    While k >= 0
                      nAudCount + 1
                      aAud(k)\nAudNo = nAudCount
                      k = aAud(k)\nNextAudIndex
                    Wend
                    aSub(aAud(nMyAudPtr)\nSubIndex)\nAudCount = nAudCount
                    debugMsg(sProcName, "aSub(" + getSubLabel(aAud(nMyAudPtr)\nSubIndex) + ")\nAudCount=" + aSub(aAud(nMyAudPtr)\nSubIndex)\nAudCount)
                    generatePlayOrder(aAud(nMyAudPtr)\nSubIndex)
                    debugMsg(sProcName, "calling setLabels(" + *pLastGroupInfo\nCuePtr1 + ")")
                    setLabels(*pLastGroupInfo\nCuePtr1)
                    setEditCueSubAudPtrs(*pLastGroupInfo\nCuePtr1) ; Added 29Dec2023 following test of adding an audio file cue, then undoing the change, then redoing the change. The redo crashed because aSub()\nFirstAudIndex had not been set
                  EndIf
                  debugMsg(sProcName, "setting nRedoResult=" + Str(grMUR\nUndoGroupPtr + 1))
                  nRedoResult = grMUR\nUndoGroupPtr + 1
                  
                Case #SCS_UNDO_ACTION_DELETE         ;---- REDO DELETE AUD
                  If \nOldPtr >= 0
                    delAudForAudPtr(\nOldPtr)
                  EndIf
                  nRedoResult = grMUR\nUndoGroupPtr + 1
                  
                Default
                  sMsg = "unhandled type/action. type=" + decodeUndoType(\nItemType) + ", action=" + decodeUndoAction(\nAction)
                  debugMsg(sProcName, sMsg)
                  scsMessageRequester(sProcName, sMsg, #PB_MessageRequester_Error)
                  ProcedureReturn
                  
              EndSelect
              
          EndSelect
        EndWith
      EndIf
    Next n3
    
    For j = 1 To gnLastSub
      With aSub(j)
        If \bSubTypeL
          \nLCSubRef = -1
          debugMsg(sProcName, "aSub(" + getSubLabel(j) + ")\nLCSubRef=" + \nLCSubRef)
        ElseIf \bSubTypeS
          For h = 0 To #SCS_MAX_SFR
            \nSFRSubRef[h] = -1
          Next h
        EndIf
      EndWith
    Next j
    
    resetLastSubAndLastAud()
    setCuePtrs(#False)
    resyncCuePtrs()
    loadCueBrackets()
    loadHotkeyArray()
    loadCueMarkerArrays()
    debugMsg(sProcName, "calling DMX_loadDMXChannelMonitoredArray(@grProd)")
    DMX_loadDMXChannelMonitoredArray(@grProd)
    
    ; Added 8Sep2023 11.10.0ca
    gbCallLoadDispPanels = #True
    gbCallLoadGridRowsWhereRequested = #True
    gbForceNodeDisplay = #True
    If IsGadget(WED\tvwProdTree)
      ; should be #True
      debugMsg(sProcName, "calling ED_loadDevChgsFromProd()")
      ED_loadDevChgsFromProd()
      debugMsg(sProcName, "calling WED_tvwProdTree_NodeClick(#True)")
      WED_tvwProdTree_NodeClick(#True) ; causes relevant changes to be shown in the editor window
    EndIf
    ; End added 8Sep2023 11.10.0ca
    
  EndIf
  
  With *pLastGroupInfo
    If \nCuePtr1 >= 0
      resyncCuePtrs(\nCuePtr1)
    EndIf
    If (\nCuePtr2 >= 0) And (\nCuePtr2 <> \nCuePtr1)
      resyncCuePtrs(\nCuePtr2)
    EndIf
  EndWith
  
  If nRedoResult >= 0
    grMUR\nUndoGroupPtr + 1
    debugMsg(sProcName, "\nUndoGroupPtr=" + grMUR\nUndoGroupPtr)
  EndIf

  setNonLinearCueFlags()
  CSRD_SetRemDevUsedInProd()
  
  For i = 1 To gnLastCue
    setLinksForCue(i)
    setLinksForAudsWithinSubsForCue(i)
  Next i
  setMTCLinksForAllCues()
  buildAudSetArray()

  ; set return values
  ;   byRef values
  *pLastGroupInfo\nUndoTypes = nMyUndoTypes
  *pLastGroupInfo\nUndoFlags = nMyUndoFlags

  debugMsg(sProcName, "calling displayOrHideVideoWindows()")
  displayOrHideVideoWindows()
  
  ; debugCuePtrs()
  
  grRAI\nStatus | #SCS_RAI_STATUS_PROD | #SCS_RAI_STATUS_CUE
  
  debugMsg(sProcName, #SCS_END)
  ;   return variable
  ProcedureReturn nRedoResult
EndProcedure

Procedure buildUndoRedoList(bUndoList)
  PROCNAMEC()
  Protected n, nCount, nGroupCount, nGroups
  Protected nTop, nWidth, nHeight
  
  With WED
    scsCreatePopupMenu(#WED_mnuUndoRedoMenu)
    If bUndoList
      grMUR\sUndoRedo = "UNDO"
      scsMenuItem(#WED_mnuUndoRedoInfo, "mnuUndoInfo")
      DisableMenuItem(#WED_mnuUndoRedoMenu, #WED_mnuUndoRedoInfo, #True)
      MenuBar()
      nCount = 0
      nGroupCount = 0
      debugMsg(sProcName, "UNDO, grMUR\nUndoGroupPtr=" + grMUR\nUndoGroupPtr)
      For n = grMUR\nUndoGroupPtr To 0 Step -1
        nCount + 1
        nGroupCount + 1
        If nGroupCount = 10
          If nGroups > 0
            CloseSubMenu()
          EndIf
          OpenSubMenu(Str(nCount) + " - " + Str(nCount+9))
          nGroups + 1
          nGroupCount = 0
        EndIf
        MenuItem(#WED_mnuUndoRedo_01 + nCount - 1, Str(nCount) + ": " + gaUndoGroup(n)\sPrimaryDescr)
      Next n
      If nGroups > 0
        CloseSubMenu()
      EndIf
    Else
      grMUR\sUndoRedo = "REDO"
      scsMenuItem(#WED_mnuUndoRedoInfo, "mnuRedoInfo")
      DisableMenuItem(#WED_mnuUndoRedoMenu, #WED_mnuUndoRedoInfo, #True)
      MenuBar()
      nCount = 0
      nGroupCount = 0
      debugMsg(sProcName, "REDO, grMUR\nUndoGroupPtr=" + grMUR\nUndoGroupPtr + ", grMUR\nMaxRedoGroupPtr=" + grMUR\nMaxRedoGroupPtr)
      For n = (grMUR\nUndoGroupPtr + 1) To grMUR\nMaxRedoGroupPtr
        nCount + 1
        nGroupCount + 1
        If nGroupCount = 10
          If nGroups > 0
            CloseSubMenu()
          EndIf
          OpenSubMenu(Str(nCount) + " - " + Str(nCount+9))
          nGroups + 1
          nGroupCount = 0
        EndIf
        MenuItem(#WED_mnuUndoRedo_01 + nCount - 1, Str(nCount) + ": " + gaUndoGroup(n)\sPrimaryDescr)
      Next n
      If nGroups > 0
        CloseSubMenu()
      EndIf
    EndIf
    DisplayPopupMenu(#WED_mnuUndoRedoMenu, WindowID(#WED))
  EndWith
  
EndProcedure

Procedure cancelGroupIfReqd()
  PROCNAMEC()
  Protected n, bCancelGroup, sMsg.s

  ; debugMsg(sProcName, #SCS_START + ", grMUR\nCurrUndoGroupId=" + grMUR\nCurrUndoGroupId)
  
  bCancelGroup = #True
  If grMUR\nCurrUndoGroupId >= 0
    For n = grMUR\nUndoItemPtr To 0 Step -1
      ; debugMsg(sProcName, "gaUndoItem(" + n + ")\nUndoGroupId=" + gaUndoItem(n)\nUndoGroupId + ", gaUndoItem(" + n + ")\bCancelled=" + strB(gaUndoItem(n)\bCancelled))
      If gaUndoItem(n)\nUndoGroupId <> grMUR\nCurrUndoGroupId
        Break
      ElseIf gaUndoItem(n)\bCancelled = #False
        bCancelGroup = #False
        Break
      EndIf
    Next n
    ; debugMsg(sProcName, "bCancelGroup=" + strB(bCancelGroup))
    
    If bCancelGroup
      With gaUndoGroup(grMUR\nUndoGroupPtr)
        ; debugMsg(sProcName, "cancelling group " + grMUR\nCurrUndoGroupId + ", nUndoGroupPtr=" + grMUR\nUndoGroupPtr + ", \nUndoGroupId=" + \nUndoGroupId)
        If \nUndoGroupId <> grMUR\nCurrUndoGroupId
          sMsg = "nUndoGroupPtr=" + grMUR\nUndoGroupPtr + ", nCurrUndoGroupId=" + grMUR\nCurrUndoGroupId + ", gaUndoGroup(" + grMUR\nUndoGroupPtr + ")\nUndoGroupId)=" + gaUndoGroup(grMUR\nUndoGroupPtr)\nUndoGroupId
          debugMsg(sProcName, "==============")
          debugMsg(sProcName, sMsg)
          debugMsg(sProcName, "==============")
          scsMessageRequester(sProcName, sMsg, #PB_MessageRequester_Error)
          ProcedureReturn
        EndIf
        ; recover the space used in the arrays
        grMUR\nUndoItemPtr = \nStartUndoItemPtr
        grMUR\nB4ProdPtr = \nStartB4ProdPtr
        grMUR\nB4CuePtr = \nStartB4CuePtr
        grMUR\nB4SubPtr = \nStartB4SubPtr
        grMUR\nB4AudPtr = \nStartB4AudPtr
        grMUR\nAftProdPtr = \nStartAftProdPtr
        grMUR\nAftCuePtr = \nStartAftCuePtr
        grMUR\nAftSubPtr = \nStartAftSubPtr
        grMUR\nAftAudPtr = \nStartAftAudPtr
      EndWith
      grMUR\nUndoGroupPtr - 1
      ; debugMsg(sProcName, "\nUndoGroupPtr=" + grMUR\nUndoGroupPtr)
      ; debugMsg(sProcName, "setting nMaxRedoGroupPtr=" + grMUR\nUndoGroupPtr + " (was " + grMUR\nMaxRedoGroupPtr + ")")
      grMUR\nMaxRedoGroupPtr = grMUR\nUndoGroupPtr
      grMUR\nMaxRedoItemPtr = grMUR\nUndoItemPtr
    EndIf
    
  EndIf
  
  ; debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure setLatestUndoGroupIdAtSave()
  PROCNAMEC()
  If grMUR\nUndoGroupPtr = -1
    grMUR\nLatestUndoGroupIdAtSave = -1
  Else
    grMUR\nLatestUndoGroupIdAtSave = gaUndoGroup(grMUR\nUndoGroupPtr)\nUndoGroupId
  EndIf
  debugMsg(sProcName, "nUndoGroupPtr=" + grMUR\nUndoGroupPtr + ", nLatestUndoGroupIdAtSave=" + grMUR\nLatestUndoGroupIdAtSave)
EndProcedure

Procedure.s decodeUndoType(nType)
  Protected sType.s
  Select nType
    Case #SCS_UNDO_TYPE_EDITDEVS
      sType = "UNDO_TYPE_EDITDEVS"
    Case #SCS_UNDO_TYPE_PROD
      sType = "UNDO_TYPE_PROD"
    Case #SCS_UNDO_TYPE_CUE
      sType = "UNDO_TYPE_CUE"
    Case #SCS_UNDO_TYPE_SUB
      sType = "UNDO_TYPE_SUB"
    Case #SCS_UNDO_TYPE_AUD
      sType = "UNDO_TYPE_AUD"
    Default
      sType = Str(nType)
  EndSelect
  ProcedureReturn sType
EndProcedure

Procedure.s decodeUndoAction(nAction)
  Protected sAction.s
  Select nAction
    Case #SCS_UNDO_ACTION_CHANGE
      sAction = "#SCS_UNDO_ACTION_CHANGE"
    Case #SCS_UNDO_ACTION_ADD
      sAction = "#SCS_UNDO_ACTION_ADD"
    Case #SCS_UNDO_ACTION_DELETE
      sAction = "#SCS_UNDO_ACTION_DELETE"
    Case #SCS_UNDO_ACTION_MOVE_CUE
      sAction = "#SCS_UNDO_ACTION_MOVE_CUE"
    Case #SCS_UNDO_ACTION_MOVE_SUB
      sAction = "#SCS_UNDO_ACTION_MOVE_SUB"
    Case #SCS_UNDO_ACTION_RENUMBER_CUES
      sAction = "#SCS_UNDO_ACTION_RENUMBER_CUES"
    Case #SCS_UNDO_ACTION_MULTI_CUE_COPY_ETC
      sAction = "#SCS_UNDO_ACTION_MULTI_CUE_COPY_ETC"
    Case #SCS_UNDO_ACTION_MAKE_SCS_CUE_FROM_SUBS
      sAction = "#SCS_UNDO_ACTION_MAKE_SCS_CUE_FROM_SUBS"
    Case #SCS_UNDO_ACTION_ADD_CUE
      sAction = "#SCS_UNDO_ACTION_ADD_CUE"
    Case #SCS_UNDO_ACTION_ADD_SUB
      sAction = "#SCS_UNDO_ACTION_ADD_SUB"
    Case #SCS_UNDO_ACTION_ADD_AUD
      sAction = "#SCS_UNDO_ACTION_ADD_AUD"
    Case #SCS_UNDO_ACTION_DRAG
      sAction = "#SCS_UNDO_ACTION_DRAG"
    Case #SCS_UNDO_ACTION_DRAG_CUE
      sAction = "#SCS_UNDO_ACTION_DRAG_CUE"
    Case #SCS_UNDO_ACTION_BULK_EDIT
      sAction = "#SCS_UNDO_ACTION_BULK_EDIT"
    Case #SCS_UNDO_ACTION_IMPORT_FILES
      sAction = "#SCS_UNDO_ACTION_IMPORT_FILES"
    Default
      sAction = Str(nAction)
  EndSelect
  ProcedureReturn sAction
EndProcedure

Procedure debugUndoArrays()
  PROCNAMEC()
  Protected n1, n2, nMyUndoGroupId

  debugMsg(sProcName, #SCS_BLANK)
  debugMsg(sProcName, "nUndoGroupPtr=" + grMUR\nUndoGroupPtr + ", nMaxRedoGroupPtr=" + grMUR\nMaxRedoGroupPtr)
  debugMsg(sProcName, "nUndoItemPtr=" + grMUR\nUndoItemPtr + ", nMaxRedoItemPtr=" + grMUR\nMaxRedoItemPtr)

  For n1 = 0 To grMUR\nMaxRedoGroupPtr
    With gaUndoGroup(n1)
      debugMsg(sProcName, "gaUndoGroup(" + n1 + ")\nUndoGroupId=" + \nUndoGroupId + ", \sPrimaryDescr=" + \sPrimaryDescr)
      nMyUndoGroupId = \nUndoGroupId
      For n2 = 0 To grMUR\nMaxRedoItemPtr
        If gaUndoItem(n2)\nUndoGroupId = nMyUndoGroupId
          debugMsg(sProcName, "gaUndoItem(" + n2 + ")\nItemId=" + gaUndoItem(n2)\nItemId + ", \nItemType=" + decodeUndoType(gaUndoItem(n2)\nItemType) + ", \nAction=" + decodeUndoAction(gaUndoItem(n2)\nAction) +
                              ", \nOldPtr=" + gaUndoItem(n2)\nOldPtr + ", \nNewPtr=" + gaUndoItem(n2)\nNewPtr + ", \nFlags=" + gaUndoItem(n2)\nFlags)
        EndIf
      Next n2
    EndWith
  Next n1

  debugMsg(sProcName, #SCS_BLANK)
  
EndProcedure

Procedure preserveAudCurrInfo(pAudPtr)
  PROCNAMECA(pAudPtr)
  Protected d, n, l2

  If pAudPtr >= 0
    With aAud(pAudPtr)
      \nAudState = grMUR\rPreserveAud\nAudState
      \nFileState = grMUR\rPreserveAud\nFileState
      For d = 0 To #SCS_MAX_AUDIO_DEV_PER_AUD_OR_SUB
        \nBassChannel[d] = grMUR\rPreserveAud\nBassChannel[d]
        \nBassDevice[d] = grMUR\rPreserveAud\nBassDevice[d]
        \nBassAltChannel[d] = grMUR\rPreserveAud\nBassAltChannel[d]
        \fCuePanNow[d] = grMUR\rPreserveAud\fCuePanNow[d]
        \fCueVolNow[d] = grMUR\rPreserveAud\fCueVolNow[d]
        \fBVLevelWhenFadeOutStarted[d] = grMUR\rPreserveAud\fBVLevelWhenFadeOutStarted[d]
      Next d
      \nSourceChannel = grMUR\rPreserveAud\nSourceChannel
      \nSourceAltChannel = grMUR\rPreserveAud\nSourceAltChannel
      \bUsingSplitStream = grMUR\rPreserveAud\bUsingSplitStream
      \bFinalSlide = grMUR\rPreserveAud\bFinalSlide
      \bFinalFadeOut = grMUR\rPreserveAud\bFinalFadeOut
      \qChannelBytePosition = grMUR\rPreserveAud\qChannelBytePosition
      \nCuePos = grMUR\rPreserveAud\nCuePos
      \nCuePosAtLoopStart = grMUR\rPreserveAud\nCuePosAtLoopStart
      \nPLCountDownTimeLeft = grMUR\rPreserveAud\nPLCountDownTimeLeft
      \qPLTimeTransStarted = grMUR\rPreserveAud\qPLTimeTransStarted
      \nPreFadeInTimeOnPause = grMUR\rPreserveAud\nPreFadeInTimeOnPause
      \nPreFadeOutTimeOnPause = grMUR\rPreserveAud\nPreFadeOutTimeOnPause
      \nPrepauseAudState = grMUR\rPreserveAud\nPrepauseAudState
      \nPriorTimeOnPause = grMUR\rPreserveAud\nPriorTimeOnPause
      \nRelFilePos = grMUR\rPreserveAud\nRelFilePos
      \nRelPassEnd = grMUR\rPreserveAud\nRelPassEnd
      \nRelPassStart = grMUR\rPreserveAud\nRelPassStart
      \qTimeFadeInStarted = grMUR\rPreserveAud\qTimeFadeInStarted
      \bTimeFadeInStartedSet = grMUR\rPreserveAud\bTimeFadeInStartedSet
      \qTimeFadeOutStarted = grMUR\rPreserveAud\qTimeFadeOutStarted
      \bTimeFadeOutStartedSet = grMUR\rPreserveAud\bTimeFadeOutStartedSet
      \nCuePosAtFadeStart = grMUR\rPreserveAud\nCuePosAtFadeStart
      \qTimePauseStarted = grMUR\rPreserveAud\qTimePauseStarted
      \qTimeAudRestarted = grMUR\rPreserveAud\qTimeAudRestarted
      \qTimeAudStarted = grMUR\rPreserveAud\qTimeAudStarted
      \qTimeAudEnded = grMUR\rPreserveAud\qTimeAudEnded
      \bTimeAudEndedSet = grMUR\rPreserveAud\bTimeAudEndedSet
      \nTotalTimeOnPause = grMUR\rPreserveAud\nTotalTimeOnPause
      \nLoopPassNo = grMUR\rPreserveAud\nLoopPassNo
      If grMUR\rPreserveAud\nMaxLoopInfo >= 0
        If \rCurrLoopInfo\nNumLoops <> grMUR\rPreserveAud\rCurrLoopInfo\nNumLoops
          For n = 1 To gnLastLoopSync
            If (gaLoopSync(n)\bActive) And (gaLoopSync(n)\nAudPtr = pAudPtr)
              gaLoopSync(n)\nLoopSyncPassesReqd = \rCurrLoopInfo\nNumLoops
              Break
            EndIf
          Next n
        EndIf
      EndIf
      \nVideoPlayState = grMUR\rPreserveAud\nVideoPlayState
      \nVideoPosition = grMUR\rPreserveAud\nVideoPosition
      debugMsg(sProcName, \sAudLabel + ", \nFileState=" + decodeFileState(\nFileState) + ", \nAudState=" + decodeCueState(\nAudState))
    EndWith
  EndIf

EndProcedure

Procedure preserveSubCurrInfo(pSubPtr)
  PROCNAMECS(pSubPtr)
  Protected d

  If pSubPtr >= 0
    With aSub(pSubPtr)
      \nSubState = grMUR\rPreserveSub\nSubState
      \qTimeSubStarted = grMUR\rPreserveSub\qTimeSubStarted
      \qAdjTimeSubStarted = grMUR\rPreserveSub\qAdjTimeSubStarted
      \bTimeSubStartedSet = grMUR\rPreserveSub\bTimeSubStartedSet
      \qTimeSubRestarted = grMUR\rPreserveSub\qTimeSubRestarted
      \bPLTerminating = grMUR\rPreserveSub\bPLTerminating
      debugMsg(sProcName, "aSub(" + getSubLabel(pSubPtr) + ")\bPLTerminating=" + strB(\bPLTerminating))
      \nLCPositionMax = grMUR\rPreserveSub\nLCPositionMax
      \nPLCuePosition = grMUR\rPreserveSub\nPLCuePosition
      \qPLTimeFadeInStarted = grMUR\rPreserveSub\qPLTimeFadeInStarted
      \qPLTimeFadeOutStarted = grMUR\rPreserveSub\qPLTimeFadeOutStarted
      \nPLUnplayedFilesTime = grMUR\rPreserveSub\nPLUnplayedFilesTime
      For d = 0 To #SCS_MAX_AUDIO_DEV_PER_AUD_OR_SUB
        \fLCBVLevelWhenStarted[d] = grMUR\rPreserveSub\fLCBVLevelWhenStarted[d]
        \fLCPanWhenStarted[d] = grMUR\rPreserveSub\fLCPanWhenStarted[d]
        \nLCPosition[d] = grMUR\rPreserveSub\nLCPosition[d]
      Next d
      \nSubPosition = grMUR\rPreserveSub\nSubPosition
      \nSubPriorTimeOnPause = grMUR\rPreserveSub\nSubPriorTimeOnPause
      \qSubTimePauseStarted = grMUR\rPreserveSub\qSubTimePauseStarted
      \nSubTotalTimeOnPause = grMUR\rPreserveSub\nSubTotalTimeOnPause
    EndWith
  EndIf

EndProcedure

Procedure preserveCueCurrInfo(pCuePtr)
  PROCNAMECQ(pCuePtr)

  If pCuePtr >= 0
    With aCue(pCuePtr)
      \nCueState = grMUR\rPreserveCue\nCueState
      \qTimeCueStarted = grMUR\rPreserveCue\qTimeCueStarted
      \bTimeCueStartedSet = grMUR\rPreserveCue\bTimeCueStartedSet
      \qTimeCueStopped = grMUR\rPreserveCue\qTimeCueStopped
      \bTimeCueStoppedSet = grMUR\rPreserveCue\bTimeCueStoppedSet
      \qTimeCueLastStarted = grMUR\rPreserveCue\qTimeCueLastStarted
    EndWith
  EndIf

EndProcedure

Procedure purgeOldUndoGroups()
  PROCNAMEC()
  Protected n1, n2
  Protected nFirstUndoGroupPtr, nFirstUndoItemPtr
  Protected nMyGroupPtr

  If grMUR\nUndoGroupPtr < 150
    ProcedureReturn
  EndIf

  nFirstUndoGroupPtr = grMUR\nUndoGroupPtr - 99
  nFirstUndoItemPtr = 999999

  ; purge old groups
  n1 = -1
  For n2 = nFirstUndoGroupPtr To grMUR\nUndoGroupPtr
    n1 = n1 + 1
    gaUndoGroup(n1) = gaUndoGroup(n2)
    If gaUndoGroup(n1)\nStartUndoItemPtr >= 0
      If gaUndoGroup(n1)\nStartUndoItemPtr < nFirstUndoItemPtr
        nFirstUndoItemPtr = gaUndoGroup(n1)\nStartUndoItemPtr
      EndIf
    EndIf
  Next n2
  grMUR\nUndoGroupPtr = n1
  debugMsg(sProcName, "\nUndoGroupPtr=" + grMUR\nUndoGroupPtr)
  
  ; purge old items
  If nFirstUndoItemPtr < 999999
    n1 = -1
    For n2 = nFirstUndoItemPtr To grMUR\nUndoItemPtr
      n1 = n1 + 1
      gaUndoItem(n1) = gaUndoItem(n2)
    Next n2
    grMUR\nUndoItemPtr = n1
    ; adjust start item pointers in groups
    For n1 = 0 To grMUR\nUndoGroupPtr
      If gaUndoGroup(n1)\nStartUndoItemPtr >= 0
        gaUndoGroup(n1)\nStartUndoItemPtr = gaUndoGroup(n1)\nStartUndoItemPtr - nFirstUndoItemPtr
      EndIf
    Next n1
  EndIf

  ; sanity check to make sure we did everything correctly

EndProcedure

; EOF