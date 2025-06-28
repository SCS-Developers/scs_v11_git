; File: fmFileRename.pbi

EnableExplicit

Procedure WFR_Form_Unload()
  PROCNAMEC()
  
  debugMsg(sProcName, #SCS_START)
  
  getFormPosition(#WFR, @grFileRenameWindow)
  unsetWindowModal(#WFR)
  scsCloseWindow(#WFR)
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WFR_btnRename_Click()
  PROCNAMECA(nEditAudPtr)
  Protected sOldName.s, sOldExt.s
  Protected sNewName.s, sNewExt.s
  Protected sFolder.s
  Protected sFullFileName.s
  Protected nReply
  Protected sMsg.s, sError.s
  Protected k
  Protected nErrorCode.l
  Protected sMsgBuf.s, n
  
  debugMsg(sProcName, #SCS_START)
  
  sOldName = Trim(GGT(WFR\txtCurrFilename))
  sNewName = Trim(GGT(WFR\txtReqdFilename))
  If sOldName = sNewName
    WFR_Form_Unload()
    ProcedureReturn
  EndIf
  
  sOldExt = GetExtensionPart(sOldName)
  sNewExt = GetExtensionPart(sNewName)
  If LCase(sNewExt) <> LCase(sOldExt)
    sMsg = Lang("WFR", "ChangeExt")
    debugMsg(sProcName, sMsg)
    nReply = scsMessageRequester(GWT(#WFR), sMsg, #PB_MessageRequester_YesNo|#MB_ICONEXCLAMATION)
    If nReply = #PB_MessageRequester_Yes
      grWFR\bSelectWholeField = #True
      SAG(WFR\txtReqdFilename)
      ProcedureReturn
    EndIf
  EndIf
  
  sFolder = GetPathPart(grWFR\sCurrFileName)
  sFullFileName = sFolder + sNewName
  If FileExists(sFullFileName)
    sMsg = LangPars("WFR", "AlreadyExists", sOldName, sNewName)
    debugMsg(sProcName, sMsg)
    scsMessageRequester(GWT(#WFR), sMsg, #PB_MessageRequester_Error)
    SAG(WFR\txtReqdFilename)
    ProcedureReturn
  EndIf
  
  For k = 1 To gnLastAud
    With aAud(k)
      If LCase(\sFileName) = LCase(grWFR\sCurrFileName)
        If \nFileState = #SCS_FILESTATE_OPEN
          debugMsg(sProcName, "calling closeAud(" + getAudLabel(k) + ", #True)")
          closeAud(k, #True)
        EndIf
      EndIf
    EndWith
    
  Next k
  
  ; force freeing streams before trying to rename the file
  freeStreams(#True)
  
  debugMsg(sProcName, "renaming " + grWFR\sCurrFileName)
  debugMsg(sProcName, "new name: " + sFullFileName)
  If RenameFile(grWFR\sCurrFileName, sFullFileName)
    gsRenamedFileName = sFullFileName
    debugMsg(sProcName, "rename successful")
  Else
    nErrorCode = GetLastError_()
    sMsgBuf = Space(256)
    n = FormatMessage_(#FORMAT_MESSAGE_FROM_SYSTEM, 0, nErrorCode, 0, @sMsgBuf, 256, 0)
    sMsg = LangPars("WFR", "Failed", Str(nErrorCode)) + Chr(10) + Left(sMsgBuf,n)
    debugMsg(sProcName, sMsg)
    scsMessageRequester(GWT(#WFR), sMsg, #PB_MessageRequester_Error)
    SAG(WFR\txtReqdFilename)
    ProcedureReturn
  EndIf
  
  WFR_Form_Unload()
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WFR_txtReqdFilename_GotFocus()
  PROCNAMEC()
  Protected nDotPos
  
  debugMsg(sProcName, #SCS_START + ", bSelectWholeField=" + strB(grWFR\bSelectWholeField))
  
  nDotPos = FindString(GGT(WFR\txtReqdFilename), ".", 1)
  
  If (grWFR\bSelectWholeField) Or (nDotPos <= 1)
    debugMsg(sProcName, "calling selectWholeField()")
    selectWholeField(WFR\txtReqdFilename)
  Else
    debugMsg(sProcName, "Len(txtReqdFilename=" + Str(Len(GGT(WFR\txtReqdFilename))) + ", nDotPos=" + Str(nDotPos))
    SendMessage_(GadgetID(WFR\txtReqdFilename),#EM_SETSEL,0,(nDotPos-1)) 
  EndIf
  grWFR\bSelectWholeField = #False
EndProcedure

Procedure WFR_Form_Show(bModal, nReturnFunction)
  PROCNAMEC()
  
  If IsWindow(#WFR) = #False
    createfmFileRename()
  EndIf
  setFormPosition(#WFR, @grFileRenameWindow)
  setWindowModal(#WFR, bModal, nReturnFunction)
  
  gsRenamedFileName = grWFR\sCurrFileName
  SGT(WFR\txtCurrFilename, GetFilePart(grWFR\sCurrFileName))
  SGT(WFR\txtReqdFilename, GetFilePart(gsRenamedFileName))
  SAG(WFR\txtReqdFilename)
  
  setWindowVisible(#WFR, #True)
  
EndProcedure

Procedure WFR_EventHandler()
  PROCNAMEC()
  
  With WFR
    Select gnWindowEvent
        
      Case #PB_Event_CloseWindow
        WFR_Form_Unload()
        
      Case #PB_Event_Menu
        gnEventMenu=EventMenu()
        debugMsg(sProcName, "gnEventMenu=" + decodeMenuItem(gnEventMenu))
        Select gnEventMenu
            
          Case #SCS_mnuKeyboardReturn   ; Return
            If getEnabled(\btnRename)
              WFR_btnRename_Click()
            EndIf
            
          Case #SCS_mnuKeyboardEscape   ; Escape
            WFR_Form_Unload()
            
        EndSelect
        
      Case #PB_Event_Gadget
        ;debugMsg(sProcName, "gnEventGadgetNo=G" + gnEventGadgetNo)
        Select gnEventGadgetNoForEvHdlr
            
          Case \btnCancel   ; btnCancel
            WFR_Form_Unload()
            
          Case \btnRename   ; btnRename
            WFR_btnRename_Click()
            
          Case \txtReqdFilename   ; txtReqdFilename
            If gnEventType = #PB_EventType_Focus
              WFR_txtReqdFilename_GotFocus()
            EndIf
            
          Default
            debugMsg(sProcName, "gnEventGadgetNo=G" + gnEventGadgetNo + ", gnEventType=" + decodeEventType())
        EndSelect
        
    EndSelect
  EndWith
  
EndProcedure

Procedure WFR_renameAudFile(sFileName.s, sSubType.s)
  PROCNAMEC()
  Protected sMyFileName.s
  Protected sMsg.s
  
  grWFR\sSubType = sSubType
  
  sMyFileName = Trim(sFileName)
  If Len(sMyFileName) = 0
    ProcedureReturn
  EndIf
  
  If FileExists(sMyFileName) = #False
    sMsg = LangPars("Errors", "FileNotFound", sMyFileName)
    debugMsg(sProcName, sMsg)
    scsMessageRequester(GWT(#WFR), sMsg, #PB_MessageRequester_Error)
    ProcedureReturn
  EndIf
  
  grWFR\sCurrFileName = sMyFileName
  WFR_Form_Show(#True, #SCS_MODRETURN_FILE_RENAME)
  
EndProcedure

Procedure WFR_renameAudFileModReturn(nRenameAction)
  PROCNAMEC()
  Protected sMsg.s
  Protected i, k, f
  Protected bAudChanged, bFileDataChanged
  Protected bChangesApplied
  Protected Dim aAffectedCue(0)
  
  debugMsg(sProcName, #SCS_START)
  
  If nRenameAction = #PB_MessageRequester_Cancel   ; indicates the user clicked the 'Cancel' button or the 'close window' button
    ProcedureReturn
  EndIf
  
  debugMsg(sProcName, "returned from fmFileRename grWFR\sCurrFileName=" + GetFilePart(grWFR\sCurrFileName) + ", gsRenamedFileName=" + GetFilePart(gsRenamedFileName))
  If gsRenamedFileName = grWFR\sCurrFileName
    ; filename not changed
    ProcedureReturn
  EndIf
  
  ReDim aAffectedCue(gnLastCue)
  For i = 0 To gnLastCue
    aAffectedCue(i) = #False
  Next i
  
  For k = 1 To gnLastAud
    With aAud(k)
      If LCase(\sFileName) = LCase(grWFR\sCurrFileName)
        ; debugMsg(sProcName, "changing aAud(" + getAudLabel(k) + ")\sFileName from " + \sFileName + " to " + gsRenamedFileName)
        \sFileName = gsRenamedFileName
        \sFileExt = GetExtensionPart(\sFileName)
        \sStoredFileName = encodeFileName(\sFileName, #False, grProd\bTemplate)
        bAudChanged = #True
        i = \nCueIndex
        If (i > 0) And (i <= gnLastCue)
          aAffectedCue(i) = #True
        EndIf
      EndIf
    EndWith
  Next k
  
  For f = 1 To gnLastFileData
    With gaFileData(f)
      If LCase(\sFileName) = LCase(grWFR\sCurrFileName)
        \sFileName = gsRenamedFileName
        \sStoredFileName = encodeFileName(\sFileName, #False, grProd\bTemplate)
        bFileDataChanged = #True
      EndIf
    EndWith
  Next f
  
  For i = 1 To gnLastCue
    If aAffectedCue(i)
      If (aCue(i)\nCueState >= #SCS_CUE_READY) And (aCue(i)\nCueState < #SCS_CUE_COMPLETED)
        debugMsg(sProcName, "calling closeCue(" + getCueLabel(i) + ", #True)")
        closeCue(i, #True)
      EndIf
    EndIf
  Next i
  
  ; save cue file
  WED_applyChangesWrapper()
  
  ; clear undo history
  initUndoItems()
  clearSaveSettings()
  
  If grWFR\sSubType = "A"
    displaySub(nEditSubPtr, rWQA\nItemIndex, rWQA\nScrollPos)
  Else
    displaySub(nEditSubPtr)
  EndIf
  WED_setEditorButtons()
  
  gnCallOpenNextCues = 1
  
  ProcedureReturn #True
EndProcedure

; EOF