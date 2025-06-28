; File: scs_lang_database.pbi
; language database handler

#SCS_TRANSLATOR_VERSION = "5.6"

; INFO First-time translation.
; Find the language code and name from https://en.wikipedia.org/wiki/List_of_ISO_639-1_codes
; (NB Japanese code should have been JA not JP, but JP was selected without looking at the above list!)
;
; Using Japanese as an example:-
;
; User needs a language translation program compiled from "scs_lang_database_jp.pb", so:
; --------------------------------------------------------------------------------------
; In PB open "scs_lang_database_aa.pb" and SaveAs "scs_lang_database_jp.pb"
; Change all aa to jp and all AA to JP
; Set gnLangDatabaseAction = #SCS_LANG_DB_CREATE
;
; In PB open "scsLangAA.pbi" and SaveAs "scsLangJP.pbi"
; Change all aa to jp and all AA to JP
; Set \sLangName and \sCreator as required
;
; Run "scs_lang_database_jp.pb" from PB using the Debugger option (so you can view progress in the diagnostics window)
; The language database file ("scs_lang_db_jp.sqlite") should be saved to "Documents"
; Compress "scs_lang_db_jp.sqlite" to "scs_lang_db_jp.zip"
;
; NOTE: In "scs_lang_database_jp.pb" change gnLangDatabaseAction to #SCS_LANG_DB_READ
; NOTE:                              set #cDisplayExportButton = #False
; NOTE:                              set #cDatabaseInDocumentsFolder = #True
;
; Save all changes.
;
; INFO: Create executable from this file (scs_lang_database_jp.pb), saving the executable as "scslangjp.exe" in the Runtime folder (nb "jp" is the relevant language code)
;
; INFO: Updating SCS from a language database supplied by a user.
; Using Japanese as an example:-
;
; Masashi Doi supplies file "scs_lang_db_jp.sqlite" (probably zipped). This is the SQLite database file.
; Copy "scs_lang_db_jp.sqlite" to the "Documents" folder, after renaming any existing version to add a version number.
;
; If there is an existing file named "scs_lang_export_jp.txt" then rename this file to add a version number.
;
; In PB open "scs_lang_database_jp.pb".
; IMPORTANT: Make sure #cCreateDatabaseFile = #False and #cDisplayExportButton = #True
;
; Compile and run "scs_lang_database_jp.pb".
; Click 'Export Database'. This will create "scs_lang_export_jp.txt". Warning! This function does not currently check if "scs_lang_export_jp.txt" already exists,
; so if it does then the old file is just overwritten. Hence the recommendation to rename the old file before running this program.
;
; Make a back-up copy of "scsLangJP.pbi", then open "scsLangJP.pbi" in PB.
; Copy-and-paste the entire contents of "scs_lang_export_jp.txt" to the DataSection in "scsLangJP.pbi" (including the lines "DataSection" and "EndDataSection").
;
; if first time update then:
; Modify scs_top_level.pbi with: XIncludeFile "scsLangJP.pbi"
; Modify modLang.pbi with: Restore Language_JP (and associated coding)

; all updates: 
; Compile and run "scs_PB.pb", and fix any errors reported in the "scsLangJP.pbi" DataSection.
;
; Job done! But now rename files "scs_lang_export_jp.txt" and "scs_lang_db_jp.sqlite" to add a version number.
;
; Creating a new language database file for a user.
; Using Japanese as an example:-
;
; In "Documents", if there is an existing file named "scs_lang_db_jp.sqlite" then rename this file to add a version number.
;
; In PB open "scs_lang_database_jp.pb".
; Set #cCreateDatabaseFile = #True
;
; Compile and run "scs_lang_database_jp.pb". (Recommend using Compile/Debug as Debug messages are displayed showing progress.)
; The translation window will be opened after the database has been created,
; and if you select "Untranslated items" the list will be reduced to show only the items still needing translation.
; Now close the program.
;
; IMPORTANT: Before doing anything else, in "scs_lang_database_jp.pb" set #cCreateDatabaseFile = #False and save the file.
;
; Now compress "scs_lang_db_jp.sqlite" and email it back to the user.
;
;/

EnableExplicit

#c_video_target_aspect_ratio_included = #False

XIncludeFile "scsLangENUS.pbi"      ; English (US)
XIncludeFile "KnownFolders.pbi"
XIncludeFile "GetKnownFolderPath.pbi"

UseSQLiteDatabase()

Global gsMyDocsPath.s
Global gsDropboxPath.s
Global gsDefaultFolder.s
Global gsMyFolder.s
Global gsOldDatabaseFile.s, gsNewDatabaseFile.s, gsCurrDatabaseFile.s
Global gsExportFile.s
Global gsLangFile.s
Global gnRowsInserted
Global gnRowsUpdated
Global gnGadgetNo
Global gsLanguageENUSName.s, gsLanguageName.s
Global gnWindowEvent
Global gnEventGadgetNo
Global gnEventType
Global gnEventMenu
Global gbEndOfRun
Global gnCurrentItem
Global gbEndOfRun
Global gnCurrentID
Global gqTimeDebugMsgDisplayed.q
Global gqMyElapsedMilliseconds.q

; windows
Enumeration
  #WTR
EndEnumeration

; menus
Enumeration 1
  #WTR_mnuPrev
  #WTR_mnuNext
EndEnumeration

#TR_Database = 123

Structure strWTR ; fmTranslate
  btnClearSearch.i
  btnClose.i
  btnNext.i
  btnPrev.i
  btnRevert.i
  btnSearch.i
  btnExport.i
  btnClipboard.i
  btnCreateLangFile.i
  cboOrderBy.i
  cntDetail.i
  cntOrder.i
  cntSearch.i
  cntSelection.i
  grdTranslate.i
  lblComment.i
  lblDebugMsg1.i
  lblDebugMsg2.i
  lblEnglish.i
  lblId.i
  lblItemChanged.i
  lblOrderBy.i
  lblOrigTrans.i
  lblOther.i
  lblSearch.i
  optAll.i
  optBlanks.i
  optChanged.i
  optCommented.i
  txtComment.i
  txtEnglish.i
  txtId.i
  txtOrigTrans.i
  txtOther.i
  txtSearch.i
EndStructure
Global WTR.strWTR ; fmTranslate

Structure tyRow
  nID.i
  sGroup.s
  sName.s
  sEnglish.s
  sTranslation.s
  sComment.s
  sItemChanged.s
  sOrigTrans.s
  bUpdateReqd.i
EndStructure
Global grCurrentRow.tyRow

Structure tyLanguageGroup
  sName.s
  iGroupStart.i
  iGroupEnd.i
  aIndexTable.i[256]    ; 256 = number of characters in the ASCII character set. For unicode characters with Asc() > 255, use the last element
EndStructure

Global Dim gaLanguageGroups.tyLanguageGroup(1)  ; all one based here
Global Dim gsLanguageStrings.s(1)
Global Dim gsLanguageNames.s(1)
Global Dim gnLanguageIds.i(1)

Global gnLanguageGroups, gnLanguageStrings

Structure tyComment
  nID.i
  sComment.s
EndStructure
Global Dim gaComments.tyComment(100)
Global gnCommentCount

Macro scsMilliseconds()
  (gqMyElapsedMilliseconds + ElapsedMilliseconds())
EndMacro

Procedure loadENUS()
  Protected sId.s, sName.s, sString.s
  Protected iGroup, iStringIndex, iChar
  Protected n
  Protected iGroupStart
  Protected iGroupEnd
  Protected bGroupFound
  
  gnLanguageGroups = 0
  gnLanguageStrings = 0
  
  Restore Language_ENUS
  Repeat
    
    Read.s sId
    Read.s sName
    Read.s sString
    
    sName = UCase(sName)
    
    If sName = "_GROUP_"
      gnLanguageGroups + 1
    ElseIf sName = "_END_"
      Break
    Else
      gnLanguageStrings + 1
    EndIf
    
  ForEver
  
  ReDim gaLanguageGroups.tyLanguageGroup(gnLanguageGroups)  ; all one based here
  ReDim gsLanguageStrings.s(gnLanguageStrings)
  ReDim gsLanguageNames.s(gnLanguageStrings)
  ReDim gnLanguageIds.i(gnLanguageStrings)
  
  ; Now load the standard language (US English):
  ;
  iGroup = 0
  iStringIndex = 0
  
  Restore Language_ENUS
  Repeat
    
    Read.s sId
    Read.s sName
    Read.s sString
    
    sName = UCase(sName)
    
    If sName = "_GROUP_"
      gaLanguageGroups(iGroup)\iGroupEnd   = iStringIndex
      iGroup + 1
      gaLanguageGroups(iGroup)\sName       = UCase(sString)
      gaLanguageGroups(iGroup)\iGroupStart = iStringIndex + 1
      For n = 0 To 255
        gaLanguageGroups(iGroup)\aIndexTable[n] = 0
      Next n
      
    ElseIf sName = "_END_"
      Break
      
    Else
      iStringIndex + 1
      gsLanguageNames(iStringIndex) = sName + Chr(1) + sString  ; keep name and string together for easier sorting
      gnLanguageIds(iStringIndex)   = Val(sId)
      
    EndIf
    
  ForEver
  
  gaLanguageGroups(iGroup)\iGroupEnd   = iStringIndex ; set end for the last group!
  
EndProcedure

Procedure checkAllIds()
  Protected nID
  Protected n1, n2
  Protected sMsg.s
  Protected bErrorFound
  Protected nMaxId
  
  loadENUS()
  
  ; check for omitted id's
  For n1 = 1 To gnLanguageStrings
    nID = gnLanguageIds(n1)
    If nID <= 0
      sMsg + "Id=" + Str(nID) + ", Name=" + gsLanguageNames(n1) + Chr(10)
      bErrorFound = #True
    ElseIf nID > nMaxId
      nMaxId = nID
    EndIf
  Next n1
  
  Debug "nMaxId=" + Str(nMaxId)
  
  ; check for duplicate id's
  For n1 = 1 To gnLanguageStrings
    nID = gnLanguageIds(n1)
    If nID > 0
      For n2 = (n1 + 1) To gnLanguageStrings
        If gnLanguageIds(n2) = nID
          sMsg + "Id=" + Str(nID) + " duplicated" + Chr(10)
          Debug "Id=" + Str(nID) + " duplicated"
          bErrorFound = #True
        EndIf
      Next n2
    EndIf
  Next n1
  
  If bErrorFound
    MessageRequester("checkAllIds", sMsg)
    ProcedureReturn #False
  EndIf
  
  ProcedureReturn #True
EndProcedure

Procedure createfmTranslate()
  Protected nWindowWidth, nWindowHeight
  Protected nLeft, nTop, nWidth, nHeight
  Protected nLeft2
  Protected nLabelWidth = 120
  Protected nTextLeft, nTextWidth
  Protected nDetailHeight = 180
  Protected nTextColumnWidth
  
  If OpenWindow(#WTR, 0, 0, 1200, 650, "SCS Translator v" + #SCS_TRANSLATOR_VERSION, #PB_Window_SystemMenu|#PB_Window_MaximizeGadget|#PB_Window_MinimizeGadget|#PB_Window_ScreenCentered)
    SetWindowState(#WTR,#PB_Window_Maximize)
    nWindowWidth = WindowWidth(#WTR)
    nWindowHeight = WindowHeight(#WTR)
    
    With WTR
      
      nLeft = 16
      nTop = 4
      
      gnGadgetNo + 1
      \cntSelection = gnGadgetNo
      ContainerGadget(gnGadgetNo,nLeft,nTop,478,30)
        nLeft = 30
        gnGadgetNo + 1
        \optAll = gnGadgetNo
        nWidth = 110
        OptionGadget(gnGadgetNo,nLeft,0,nWidth,23,"All Items")
        nLeft + nWidth
        
        gnGadgetNo + 1
        \optBlanks = gnGadgetNo
        nWidth = 160
        OptionGadget(gnGadgetNo,nLeft,0,nWidth,23,"Untranslated Items")
        nLeft + nWidth
        
        gnGadgetNo + 1
        \optChanged = gnGadgetNo
        OptionGadget(gnGadgetNo,nLeft,0,nWidth,23,"Changed Items")
        nLeft + nWidth
        
        gnGadgetNo + 1
        \optCommented = gnGadgetNo
        OptionGadget(gnGadgetNo,nLeft,0,nWidth,23,"Commented Items")
        nLeft + nWidth
        
        SetGadgetState(\optAll,#True)
        ResizeGadget(\cntSelection, #PB_Ignore, #PB_Ignore, nLeft, #PB_Ignore)
        
      CloseGadgetList()
      
      gnGadgetNo + 1
      \cntOrder = gnGadgetNo
      nLeft = GadgetX(\cntSelection) + GadgetWidth(\cntSelection)
      ContainerGadget(\cntOrder,nLeft,nTop,160,30)
        gnGadgetNo + 1
        \lblOrderBy = gnGadgetNo
        TextGadget(gnGadgetNo,0,5,50,15,"Order by",#PB_Text_Right)
        gnGadgetNo + 1
        \cboOrderBy = gnGadgetNo
        ComboBoxGadget(gnGadgetNo,54,1,100,23)
        AddGadgetItem(\cboOrderBy,-1,"Id")
        AddGadgetItem(\cboOrderBy,-1,"Group+Item")
        AddGadgetItem(\cboOrderBy,-1,"Item")
        AddGadgetItem(\cboOrderBy,-1,gsLanguageENUSName)
        AddGadgetItem(\cboOrderBy,-1,gsLanguageName)
        SetGadgetState(\cboOrderBy,0)
      CloseGadgetList()
      
      gnGadgetNo + 1
      \cntSearch = gnGadgetNo
      nLeft2 = GadgetX(\cntOrder) + GadgetWidth(\cntOrder) + 8
      ContainerGadget(gnGadgetNo,nLeft2,nTop,330,30)
        gnGadgetNo + 1
        \lblSearch = gnGadgetNo
        TextGadget(gnGadgetNo,0,6,70,17,"Search",#PB_Text_Right)
        gnGadgetNo + 1
        \txtSearch = gnGadgetNo
        StringGadget(gnGadgetNo,75,3,120,21,"")
        gnGadgetNo + 1
        \btnSearch = gnGadgetNo
        ButtonGadget(gnGadgetNo,195,1,40,23,"Go")
        gnGadgetNo + 1
        \btnClearSearch = gnGadgetNo
        ButtonGadget(gnGadgetNo,240,1,80,23,"Clear Search")
      CloseGadgetList()
      
      nLeft = GadgetX(\cntSelection)
      nTop + GadgetHeight(\cntSelection)
      nWidth = nWindowWidth - nLeft - nLeft
      nHeight = nWindowHeight - nDetailHeight - nTop - 8
      
      gnGadgetNo + 1
      \grdTranslate = gnGadgetNo
      ListIconGadget(\grdTranslate,nLeft,nTop,nWidth,nHeight,"Id",45,#PB_ListIcon_AlwaysShowSelection | #PB_ListIcon_FullRowSelect | #PB_ListIcon_GridLines)
      nTextColumnWidth = (GadgetWidth(\grdTranslate) - 45 - 80 - 80 - 20 - 24) / 3
      AddGadgetColumn(\grdTranslate,1,"Group",80)
      AddGadgetColumn(\grdTranslate,2,"Item",80)
      AddGadgetColumn(\grdTranslate,3,gsLanguageENUSName,nTextColumnWidth)
      AddGadgetColumn(\grdTranslate,4,"*",20)
      AddGadgetColumn(\grdTranslate,5,gsLanguageName,nTextColumnWidth)
      AddGadgetColumn(\grdTranslate,6,"Comment",nTextColumnWidth)
      AddGadgetColumn(\grdTranslate,7,"Original",nTextColumnWidth)
      
      nTop = nWindowHeight - nDetailHeight
      gnGadgetNo + 1
      \cntDetail = gnGadgetNo
      ContainerGadget(gnGadgetNo,nLeft,nTop,nWidth,nDetailHeight)
        nLeft = 0
        nTop = 0
        nTextLeft = nLeft + nLabelWidth + 7
        nTextWidth = GadgetWidth(\cntDetail) - nTextLeft - 8
        
        gnGadgetNo + 1
        \lblId = gnGadgetNo
        TextGadget(gnGadgetNo,nLeft,nTop+2,nLabelWidth,15,"Id",#PB_Text_Right)
        gnGadgetNo + 1
        \txtId = gnGadgetNo
        StringGadget(gnGadgetNo,nTextLeft,nTop,50,20,"",#PB_String_ReadOnly)
        
        nTop + 20
        gnGadgetNo + 1
        \lblEnglish = gnGadgetNo
        TextGadget(gnGadgetNo,nLeft,nTop+2,nLabelWidth,15,gsLanguageENUSName,#PB_Text_Right)
        gnGadgetNo + 1
        \txtEnglish = gnGadgetNo
        StringGadget(gnGadgetNo,nTextLeft,nTop,nTextWidth,30,"",#ES_MULTILINE|#PB_String_ReadOnly)
        
        nTop + 30
        gnGadgetNo + 1
        \lblOrigTrans = gnGadgetNo
        TextGadget(gnGadgetNo,nLeft,nTop+2,nLabelWidth,15,"Original Translation",#PB_Text_Right)
        gnGadgetNo + 1
        \txtOrigTrans = gnGadgetNo
        StringGadget(gnGadgetNo,nTextLeft,nTop,nTextWidth,30,"",#ES_MULTILINE|#PB_String_ReadOnly)
        
        nTop + 30
        gnGadgetNo + 1
        \lblOther = gnGadgetNo
        TextGadget(gnGadgetNo,nLeft,nTop+2,nLabelWidth,15,gsLanguageName,#PB_Text_Right)
        gnGadgetNo + 1
        \txtOther = gnGadgetNo
        StringGadget(gnGadgetNo,nTextLeft,nTop,nTextWidth,30,"",#ES_MULTILINE)
        
        nTop + 30
        gnGadgetNo + 1
        \lblComment = gnGadgetNo
        TextGadget(gnGadgetNo,nLeft,nTop+2,nLabelWidth,15,"Comment",#PB_Text_Right)
        gnGadgetNo + 1
        \txtComment = gnGadgetNo
        StringGadget(gnGadgetNo,nTextLeft,nTop,nTextWidth,30,"",#ES_MULTILINE)
        
        nTop + 34
        nLeft = nTextLeft
        gnGadgetNo + 1
        \lblItemChanged = gnGadgetNo
        TextGadget(gnGadgetNo,nLeft,nTop+2,80,15,"",#PB_Text_Center)
        nLeft + GadgetWidth(gnGadgetNo) + 4
        gnGadgetNo + 1
        \btnRevert = gnGadgetNo
        ButtonGadget(gnGadgetNo,nLeft,nTop,150,23,"Revert to Original")
        nLeft + GadgetWidth(gnGadgetNo) + 12
        gnGadgetNo + 1
        \btnPrev = gnGadgetNo
        ButtonGadget(gnGadgetNo,nLeft,nTop,100,23,"Previous")
        nLeft + GadgetWidth(gnGadgetNo) + 4
        gnGadgetNo + 1
        \btnNext = gnGadgetNo
        ButtonGadget(gnGadgetNo,nLeft,nTop,100,23,"Next",#PB_Button_Default)
        
        CompilerIf #cDisplayExportButton
          nLeft + GadgetWidth(gnGadgetNo) + 24
          gnGadgetNo + 1
          \btnExport = gnGadgetNo
          ButtonGadget(gnGadgetNo,nLeft,nTop,150,23,"Export Database")
          nLeft + GadgetWidth(gnGadgetNo) + 24
          gnGadgetNo + 1
          \btnClipboard = gnGadgetNo
          ButtonGadget(gnGadgetNo,nLeft,nTop,150,23,"Copy to Clipboard")
        CompilerEndIf
        
        CompilerIf #cDisplayLanguageFileButton
          nLeft + GadgetWidth(gnGadgetNo) + 24
          gnGadgetNo + 1
          \btnCreateLangFile = gnGadgetNo
          ButtonGadget(gnGadgetNo,nLeft,nTop,150,23,"Create Language File")
        CompilerEndIf
        
        nLeft + GadgetWidth(gnGadgetNo) + 24
        gnGadgetNo + 1
        \btnClose = gnGadgetNo
        ButtonGadget(gnGadgetNo,nLeft,nTop,100,23,"Close")
        
        nLeft + GadgetWidth(gnGadgetNo) + 24
        gnGadgetNo + 1
        \lblDebugMsg1 = gnGadgetNo
        TextGadget(gnGadgetNo,nLeft,nTop,nTextWidth,15,"")
        gnGadgetNo + 1
        \lblDebugMsg2 = gnGadgetNo
        TextGadget(gnGadgetNo,nLeft,nTop+15,nTextWidth,15,"")
        
      CloseGadgetList()
      
      AddKeyboardShortcut(#WTR, #PB_Shortcut_Return, #WTR_mnuNext)
      AddKeyboardShortcut(#WTR, #PB_Shortcut_Up, #WTR_mnuPrev)
      AddKeyboardShortcut(#WTR, #PB_Shortcut_Down, #WTR_mnuNext)
      
    EndWith
    ProcedureReturn #True
  Else
    ProcedureReturn #False
  EndIf
EndProcedure

Procedure displayDebugMsg(sDebugMsg1.s, sDebugMsg2.s)
  If IsGadget(WTR\lblDebugMsg1)
    gqTimeDebugMsgDisplayed = scsMilliseconds()
    SetGadgetText(WTR\lblDebugMsg1, sDebugMsg1)
    SetGadgetText(WTR\lblDebugMsg2, sDebugMsg2)
  EndIf
EndProcedure

Procedure.s getSpecialFolder(nSpecialFolder.l)
  ; Windows-only procedure for obtaining path of special folders.
  ; nSpecialFolder values:
  ;   #CSIDL_APPDATA          Application data
  ;   #CSIDL_COMMON_APPDATA   Application data for all users (NB only admin users can write to this folder; all users can read from the folder)
  ;   #CSIDL_PERSONAL         The virtual folder that represents the My Documents desktop item. This is equivalent to #CSIDL_MYDOCUMENTS.
  Protected nListPtr.l, sSpecialFolderPath.s
  ; debugMsg(sProcName, #SCS_START)
  
  sSpecialFolderPath = Space(#MAX_PATH * 2)
  If SHGetSpecialFolderLocation_(0, nSpecialFolder, @nListPtr) = 0
    SHGetPathFromIDList_(nListPtr, @sSpecialFolderPath)
    sSpecialFolderPath = Trim(sSpecialFolderPath)
    If Len(sSpecialFolderPath) > 0
      If Right(sSpecialFolderPath, 1) <> "\"
        sSpecialFolderPath + "\"
      EndIf
    EndIf
    CoTaskMemFree_(nListPtr)
  EndIf
  ProcedureReturn sSpecialFolderPath
EndProcedure

Procedure.s encodeSpecialChars(sText.s)
  Protected sNewText.s
  
  sNewText = ReplaceString(sText, "&", "&amp;")
  sNewText = ReplaceString(sNewText, Chr(34), "&quot;")
  sNewText = ReplaceString(sNewText, "'", "&squo;")
  ProcedureReturn sNewText
EndProcedure

Procedure.s decodeSpecialChars(sText.s)
  Protected sNewText.s
  
  sNewText = ReplaceString(sText, "&squo;", "'")
  sNewText = ReplaceString(sNewText, "&quot;", Chr(34))
  sNewText = ReplaceString(sNewText, "&amp;", "&")
  ProcedureReturn sNewText
EndProcedure

Procedure doDatabaseUpdate(nDatabase, sQuery.s)
  Protected nResult
  
  nResult = DatabaseUpdate(nDatabase, sQuery)
  If nResult = 0
    Debug DatabaseError()
  EndIf
  
  ProcedureReturn nResult
EndProcedure

Procedure selectWholeField(hTxtField)
  SendMessage_(GadgetID(hTxtField),#EM_SETSEL,0,-1) 
EndProcedure

Procedure countConditions(bIncludeAll=#True)
  Protected nAll, nUntranslated, nChanged, nCommented
  Protected sRequest.s
  
  If bIncludeAll
    sRequest = "SELECT COUNT(*) FROM langtext"
    If DatabaseQuery(#TR_Database, sRequest)
      If NextDatabaseRow(#TR_Database) <> 0
        nAll = GetDatabaseLong(#TR_Database, 0)
      EndIf
      FinishDatabaseQuery(#TR_Database)
    EndIf
  EndIf
  
  sRequest = "SELECT COUNT(*) FROM langtext WHERE sTrans IS NULL OR LENGTH(sTrans) = 0"
  If DatabaseQuery(#TR_Database, sRequest)
    If NextDatabaseRow(#TR_Database) <> 0
      nUntranslated = GetDatabaseLong(#TR_Database, 0)
    EndIf
    FinishDatabaseQuery(#TR_Database)
  EndIf

  sRequest = "SELECT COUNT(*) FROM langtext WHERE sItemChanged IS NOT NULL AND LENGTH(sItemChanged) > 0"
  If DatabaseQuery(#TR_Database, sRequest)
    If NextDatabaseRow(#TR_Database) <> 0
      nChanged = GetDatabaseLong(#TR_Database, 0)
    EndIf
    FinishDatabaseQuery(#TR_Database)
  EndIf

  sRequest = "SELECT COUNT(*) FROM langtext WHERE sComment IS NOT NULL AND LENGTH(sComment) > 0"
  If DatabaseQuery(#TR_Database, sRequest)
    If NextDatabaseRow(#TR_Database) <> 0
      nCommented = GetDatabaseLong(#TR_Database, 0)
    EndIf
    FinishDatabaseQuery(#TR_Database)
  EndIf
  
  With WTR
    If bIncludeAll
      SetGadgetText(\optAll, "All Items (" + nAll + ")")
    EndIf
    SetGadgetText(\optBlanks, "Untranslated Items (" + nUntranslated + ")")
    SetGadgetText(\optChanged, "Changed Items (" + nChanged + ")")
    SetGadgetText(\optCommented, "Commented Items (" + nCommented + ")")
  EndWith
  
EndProcedure

Procedure setItemChangedInd()
  Protected bItemChanged
  Protected bEnableRevert
  Protected sChangedDesc.s
  
  With WTR
    If Len(Trim(GetGadgetText(\txtId))) > 0
      If Trim(GetGadgetText(\txtOther)) <> Trim(grCurrentRow\sOrigTrans)
        bItemChanged = #True
      ElseIf Trim(GetGadgetText(\txtComment)) <> Trim(GetGadgetItemText(\grdTranslate, gnCurrentItem, 6))
        bItemChanged = #True
      EndIf
    EndIf
    
    If bItemChanged
      grCurrentRow\sItemChanged = "*"
      grCurrentRow\bUpdateReqd = #True
      sChangedDesc = "Changed"
      bEnableRevert = #True
    Else
      grCurrentRow\sItemChanged = ""
    EndIf
    SetGadgetText(\lblItemChanged, sChangedDesc)
    
    If bEnableRevert
      DisableGadget(\btnRevert, #False)
    Else
      DisableGadget(\btnRevert, #True)
    EndIf
    
  EndWith
EndProcedure

Procedure applyItemChangeIfReqd()
  Protected sRequest.s
  Protected sTranslation.s, sComment.s, sItemChanged.s
  Protected sDebugMsg1.s, sDebugMsg2.s
  
  With grCurrentRow
    If \nID > 0
      If (\sItemChanged = "*") Or (\bUpdateReqd)
        sTranslation = encodeSpecialChars(\sTranslation)
        sComment = encodeSpecialChars(\sComment)
        sItemChanged = encodeSpecialChars(\sItemChanged)
        sRequest = "UPDATE langtext SET sTrans = '" + sTranslation + "', sComment = '" + sComment + "', sItemChanged = '" + sItemChanged + "'"
        sRequest + " WHERE nId = " + Str(\nID)
        
        sDebugMsg1 = "sRequest=" + sRequest
        If DatabaseUpdate(#TR_Database, sRequest) = #False
          sDebugMsg1 = "SQL Failed: " + sRequest
          sDebugMsg2 = "Error: " + DatabaseError()
          displayDebugMsg(sDebugMsg1, sDebugMsg2)
        Else
          sDebugMsg1 = "sRequest=" + sRequest
          sDebugMsg2 = "OK"
          displayDebugMsg(sDebugMsg1, sDebugMsg2)
        EndIf
        
        ; update grid
        SetGadgetItemText(WTR\grdTranslate, gnCurrentItem, \sItemChanged, 4)
        SetGadgetItemText(WTR\grdTranslate, gnCurrentItem, \sTranslation, 5)
        SetGadgetItemText(WTR\grdTranslate, gnCurrentItem, \sComment, 6)
        
        countConditions(#False)
        
      EndIf
    EndIf
  EndWith
EndProcedure

Procedure setCurrentItem(bPositionAtCurrentId=#False)
  Protected nRowNo=-1, n, sId.s, sReqdId.s
  
  With WTR
    If bPositionAtCurrentId
      If gnCurrentID > 0
        sReqdId = Str(gnCurrentID)
        For n = 0 To (CountGadgetItems(\grdTranslate) - 1)
          sId = GetGadgetItemText(\grdTranslate, n, 0)
          If sId = sReqdId
            nRowNo = n
            Break
          EndIf
        Next n
        If nRowNo >= 0
          SetGadgetState(\grdTranslate, nRowNo)
        EndIf
      EndIf
    EndIf
    
    gnCurrentItem = GetGadgetState(\grdTranslate)
    
    If gnCurrentItem >= 0
      grCurrentRow\nID = Val(GetGadgetItemText(\grdTranslate, gnCurrentItem, 0))
      grCurrentRow\sEnglish = GetGadgetItemText(\grdTranslate, gnCurrentItem, 3)
      grCurrentRow\sTranslation = GetGadgetItemText(\grdTranslate, gnCurrentItem, 5)
      grCurrentRow\sComment = GetGadgetItemText(\grdTranslate, gnCurrentItem, 6)
      grCurrentRow\sOrigTrans = GetGadgetItemText(\grdTranslate, gnCurrentItem, 7)
      grCurrentRow\bUpdateReqd = #False
      SetGadgetText(\txtId, Str(grCurrentRow\nID))
      SetGadgetText(\txtEnglish, grCurrentRow\sEnglish)
      SetGadgetText(\txtOther, grCurrentRow\sTranslation)
      SetGadgetText(\txtComment, grCurrentRow\sComment)
      SetGadgetText(\txtOrigTrans, grCurrentRow\sOrigTrans)
      setItemChangedInd()
      gnCurrentID = grCurrentRow\nID
    EndIf
  EndWith
  
EndProcedure

Procedure loadCommentsFromOldDatabase()
  Protected sRequest.s
  Protected sComment.s
  
  If OpenDatabase(#TR_Database, gsOldDatabaseFile, "", "")
    
    sRequest = "SELECT * FROM langtext where sComment IS NOT NULL AND Length(sComment) > 0 ORDER BY nId"
    gnCommentCount = 0
    
    Debug "sRequest=" + sRequest
    If DatabaseQuery(#TR_Database, sRequest)
      While NextDatabaseRow(#TR_Database)
        sComment = decodeSpecialChars(GetDatabaseString(#TR_Database, 6))  ; sComment
        If Len(Trim(sComment)) > 0
          If gnCommentCount > ArraySize(gaComments())
            ReDim gaComments(gnCommentCount+50)
          EndIf
          With gaComments(gnCommentCount)
            \nID = GetDatabaseLong(#TR_Database, 0)   ; nId
            \sComment = sComment
          EndWith
          gnCommentCount + 1
        EndIf
      Wend
      FinishDatabaseQuery(#TR_Database)
      
    Else
      Debug "SQL Failed: " + sRequest
      
    EndIf
    CloseDatabase(#TR_Database)
  EndIf
EndProcedure

Procedure loadCommentsIntoNewDatabase()
  Protected sRequest.s
  Protected n
  Protected nID, sEncodedComment.s
  Protected nCommentsInserted
  Protected nResult
  
  If gnCommentCount > 0
    If OpenDatabase(#TR_Database, gsNewDatabaseFile, "", "")
      For n = 0 To (gnCommentCount - 1)
        With gaComments(n)
          Debug "reinstateComment: \nID=" + Str(\nID) + ", \sComment=" + \sComment
          nID = \nID
          sEncodedComment = encodeSpecialChars(\sComment)
          sRequest = "UPDATE langtext SET sComment = '" + sEncodedComment + "' WHERE nId = " + Str(nID)
          nResult = doDatabaseUpdate(#TR_Database, sRequest)
          If nResult = 0
            Debug "Failed: " + sRequest
            Debug "Error: " + DatabaseError()
          Else
            nCommentsInserted + 1
          EndIf
        EndWith
      Next n
    EndIf
    CloseDatabase(#TR_Database)
  EndIf
  Debug "gnCommentCount=" + Str(gnCommentCount) + ", nCommentsInserted=" + Str(nCommentsInserted)
EndProcedure

Procedure loadGrdTranslate(bSearch=#False)
  Protected sRequest.s, sLine.s, sWhere.s, sOrderBy.s
  Protected sSearchText.s
  Protected rCurrentRow.tyRow
  
  rCurrentRow = grCurrentRow
  
  sRequest = "SELECT * FROM langtext"
  
  If IsGadget(WTR\txtSearch)
    sSearchText = Trim(GetGadgetText(WTR\txtSearch))
  EndIf
  Debug "sSearchText=" + sSearchText
  
  If (bSearch) And (sSearchText) And (FindString(sSearchText,"'") = 0) And (FindString(sSearchText,#DQUOTE$) = 0)
    sWhere + "LOWER(sGroup) LIKE '%" + LCase(sSearchText) + "%'"
    sWhere + " OR LOWER(sName) LIKE '%" + LCase(sSearchText) + "%'"
    sWhere + " OR LOWER(sString) LIKE '%" + LCase(sSearchText) + "%'"
    sWhere + " OR LOWER(sComment) LIKE '%" + LCase(sSearchText) + "%'"
    sWhere + " OR LOWER(sTrans) LIKE '%" + LCase(sSearchText) + "%'"
    sWhere + " OR sTrans LIKE '%" + sSearchText + "%'"   ; nb Sqlite function LOWER works for ASCII characters only, so also include a case-sensitive search for non-ASCII search strings
    If Str(Val(sSearchText)) = sSearchText
      ; sSearchText is numeric
      sWhere + " OR nId = " + sSearchText
    EndIf
    
  Else
    ; add WHERE clause
    If GetGadgetState(WTR\optBlanks)
      sWhere + "sTrans IS NULL OR LENGTH(sTrans) = 0"
    ElseIf GetGadgetState(WTR\optChanged)
      sWhere + "sItemChanged IS NOT NULL AND LENGTH(sItemChanged) > 0"
    ElseIf GetGadgetState(WTR\optCommented)
      sWhere + "sComment IS NOT NULL AND LENGTH(sComment) > 0"
    EndIf
  EndIf
  If sWhere
    sRequest + " WHERE " + sWhere
  EndIf
  
  ; add ORDER BY clause
  Select GetGadgetState(WTR\cboOrderBy)
    Case 0
      sOrderBy + "nId"
    Case 1
      sOrderBy + "sGroup, sName"
    Case 2
      sOrderBy + "sName"
    Case 3
      sOrderBy + "sString"
    Case 4
      sOrderBy + "sTrans"
    Default
      sOrderBy + "nId"
  EndSelect
  If sOrderBy
    sRequest + " ORDER BY " + sOrderBy
  EndIf
  
  Debug "sRequest=" + sRequest
  If DatabaseQuery(#TR_Database, sRequest)
    ClearGadgetItems(WTR\grdTranslate)
    While NextDatabaseRow(#TR_Database)
      sLine = Str(GetDatabaseLong(#TR_Database, 0))                             ; nId
      sLine + Chr(10) + decodeSpecialChars(GetDatabaseString(#TR_Database, 1))  ; sGroup
      sLine + Chr(10) + decodeSpecialChars(GetDatabaseString(#TR_Database, 2))  ; sName
      sLine + Chr(10) + decodeSpecialChars(GetDatabaseString(#TR_Database, 3))  ; sString
      sLine + Chr(10) + decodeSpecialChars(GetDatabaseString(#TR_Database, 4))  ; sItemChanged
      sLine + Chr(10) + decodeSpecialChars(GetDatabaseString(#TR_Database, 5))  ; sTrans
      ; sLine + Chr(10) + GetDatabaseString(#TR_Database, 5)  ; sTrans
      sLine + Chr(10) + decodeSpecialChars(GetDatabaseString(#TR_Database, 6))  ; sComment
      sLine + Chr(10) + decodeSpecialChars(GetDatabaseString(#TR_Database, 7))  ; sOrigTrans
      AddGadgetItem(WTR\grdTranslate, -1, sLine)
    Wend
    FinishDatabaseQuery(#TR_Database)
    
  Else
    Debug "SQL Failed: " + sRequest
    
  EndIf
  
  If CountGadgetItems(WTR\grdTranslate) > 0
    SetGadgetState(WTR\grdTranslate,0)
    setCurrentItem(#True)
  EndIf
  
  If bSearch = #False
    SetGadgetText(WTR\txtSearch,"")
  EndIf
  
EndProcedure

Procedure checkParams()
  Protected sRequest.s
  Protected nId, sGroup.s, sName.s, sString.s, sTrans.s
  Protected nParamCount
  Protected nParam, sParam.s
  Protected nStringCount, nTransCount
  Protected sErrors.s, nErrorCount
  Protected sErrorLine.s
  
  sRequest = "SELECT * FROM langtext"
  sRequest + " ORDER BY sGroup, sName"
  
  sErrors = "Translation Parameter Errors"
  If DatabaseQuery(#TR_Database, sRequest)
    While NextDatabaseRow(#TR_Database)
      nId     = GetDatabaseLong(#TR_Database, 0)                        ; nId
      sGroup  = decodeSpecialChars(GetDatabaseString(#TR_Database, 1))  ; sGroup
      sName   = decodeSpecialChars(GetDatabaseString(#TR_Database, 2))  ; sName
      sString = decodeSpecialChars(GetDatabaseString(#TR_Database, 3))  ; sString
      sTrans  = decodeSpecialChars(GetDatabaseString(#TR_Database, 5))  ; sTrans
      If (Len(sTrans) > 0) And (LCase(sTrans) <> "x") ; "x" means this string is not to be translated - specifically as required by Uwe Henkel for the German translations
        If (FindString(sString,"$") > 0) Or (FindString(sTrans,"$") > 0)
          For nParam = 1 To 9
            sParam = "$" + nParam
            nStringCount = CountString(sString,sParam)
            nTransCount = CountString(sTrans,sParam)
            If nStringCount <> nTransCount
              nErrorCount + 1
              sErrorLine = Str(nErrorCount) + ": Group: " + sGroup + ", sName: " + sName + ", sString: " + sString + ", sTrans: " + sTrans
              Debug sErrorLine  ; add to debug log so we can copy this to UltraEdit, etc
              sErrors + Chr(10) + sErrorLine
            EndIf
          Next nParam
        EndIf
      EndIf
    Wend
    FinishDatabaseQuery(#TR_Database)
    
    If nErrorCount > 0
      MessageRequester("checkParams", sErrors)
    EndIf
    
  Else
    Debug "SQL Failed: " + sRequest
    
  EndIf
  
EndProcedure

Procedure grdTranslateEvent()
  Select gnEventType
    Case #PB_EventType_Change
      applyItemChangeIfReqd()
      setCurrentItem(#False)
  EndSelect
EndProcedure

Procedure txtOtherEvent()
  With WTR
    Select gnEventType
      Case #PB_EventType_Focus
        selectWholeField(\txtOther)
      Case #PB_EventType_Change
        grCurrentRow\sTranslation = GetGadgetText(\txtOther)
        setItemChangedInd()
    EndSelect
  EndWith
EndProcedure

Procedure txtCommentEvent()
  With WTR
    Select gnEventType
      Case #PB_EventType_Focus
        selectWholeField(\txtComment)
      Case #PB_EventType_Change
        grCurrentRow\sComment = GetGadgetText(\txtComment)
        setItemChangedInd()
    EndSelect
  EndWith
EndProcedure

Procedure btnPrevEvent()
  Protected nCurrentRow
  
  With WTR
    applyItemChangeIfReqd()
    nCurrentRow = GetGadgetState(\grdTranslate)
    If nCurrentRow > 0
      nCurrentRow - 1
      SetGadgetState(\grdTranslate, nCurrentRow)
      setCurrentItem(#False)
    EndIf
  EndWith
EndProcedure

Procedure btnNextEvent()
  Protected nCurrentRow
  
  With WTR
    applyItemChangeIfReqd()
    nCurrentRow = GetGadgetState(\grdTranslate)
    If nCurrentRow < (CountGadgetItems(\grdTranslate)-1)
      nCurrentRow + 1
      SetGadgetState(\grdTranslate, nCurrentRow)
      setCurrentItem(#False)
    EndIf
  EndWith
EndProcedure

Procedure btnRevertEvent()
  With grCurrentRow
    \sTranslation = \sOrigTrans
    \sItemChanged = ""
    \bUpdateReqd = #True
    SetGadgetText(WTR\txtOther, \sTranslation)
    setItemChangedInd()
    applyItemChangeIfReqd()
  EndWith
EndProcedure

Procedure btnExportEvent()
  Protected sRequest.s, sLine.s
  Protected sId.s, sGroup.s, sName.s, sTrans.s, sComment.s
  Protected sCurrGroup.s
  Protected nItemsExported
  Protected sPad.s

  With WTR
    applyItemChangeIfReqd()
    
    If CreateFile(1, gsExportFile)
      ; file created OK
    Else
      MessageRequester("Export", "Export CreateFile failed" + Chr(10) + "gsExportFile=" + gsExportFile)
      ProcedureReturn
    EndIf
    
    sRequest = "SELECT * FROM langtext WHERE sTrans IS NOT NULL OR sComment IS NOT NULL ORDER BY sGroup, nId"
    
    Debug "sRequest=" + sRequest
    If DatabaseQuery(#TR_Database, sRequest)
      
      WriteStringN(1, "; INFO: last created " + FormatDate("%yyyy/%mm/%dd", Date()) + " from " + #DQUOTE$ + GetFilePart(gsCurrDatabaseFile) + #DQUOTE$)
      
      WriteStringN(1, "DataSection")
      sPad = "  "
      WriteStringN(1, sPad + "Language_" + UCase(gsLanguageCode) + ":")
      
      While NextDatabaseRow(#TR_Database)
        sId = RSet(decodeSpecialChars(GetDatabaseString(#TR_Database, 0)), 4, "0")  ; sId (as a 4-digit string)
        sGroup = decodeSpecialChars(GetDatabaseString(#TR_Database, 1))  ; sGroup
        sName = decodeSpecialChars(GetDatabaseString(#TR_Database, 2))  ; sName
        sTrans = Trim(ReplaceString(Trim(decodeSpecialChars(GetDatabaseString(#TR_Database, 5))), #DQUOTE$, "'"))  ; sTrans
        sComment = Trim(decodeSpecialChars(GetDatabaseString(#TR_Database, 6)))  ; sComment
        If Len(sGroup) > 0
          If sGroup <> sCurrGroup
            WriteStringN(1, sPad)
            WriteStringN(1, sPad + ";- Language group " + sGroup)
            WriteStringN(1, sPad + "Data.s " + #DQUOTE$ + #DQUOTE$ + ", " + #DQUOTE$ + "_GROUP_" + #DQUOTE$ + ", " + #DQUOTE$ + sGroup + #DQUOTE$)
            sCurrGroup = sGroup
          EndIf
          If sTrans ; ignores blank translations (used a few times in the German translation)
            sLine = "Data.s " + #DQUOTE$ + sId + #DQUOTE$ + ", " + #DQUOTE$ + sName + #DQUOTE$ + ", " + #DQUOTE$ + sTrans + #DQUOTE$
            If Len(sComment) > 0
              sLine + " ; " + sComment
            EndIf
            WriteStringN(1, sPad + sLine)
            nItemsExported + 1
          EndIf
        EndIf
      Wend
      FinishDatabaseQuery(#TR_Database)
      
      WriteStringN(1, sPad)
      ; WriteStringN(1, sPad + ";-")
      WriteStringN(1, sPad + "Data.s " + #DQUOTE$ + #DQUOTE$ + ", " + #DQUOTE$ + "_END_" + #DQUOTE$ + ", " + #DQUOTE$ + #DQUOTE$)
      
      sPad = ""
      WriteStringN(1, "EndDataSection")
      
    Else
      Debug "SQL Failed: " + sRequest
    EndIf
    
    CloseFile(1)
    MessageRequester("Export", Str(nItemsExported) + " items exported to" + Chr(10) + gsExportFile)
    
  EndWith
EndProcedure

Procedure btnClipboardEvent()
  Protected sRequest.s, sLine.s
  Protected sId.s, sGroup.s, sName.s, sTrans.s, sComment.s
  Protected sCurrGroup.s
  Protected nItemsCopied
  Protected sPad.s
  Protected sClipboardText.s

  With WTR
    applyItemChangeIfReqd()
    
    sRequest = "SELECT * FROM langtext WHERE sTrans IS NOT NULL OR sComment IS NOT NULL ORDER BY sGroup, nId"
    
    Debug "sRequest=" + sRequest
    If DatabaseQuery(#TR_Database, sRequest)
      
      sClipboardText = "; INFO: last created " + FormatDate("%yyyy/%mm/%dd", Date()) + " from " + #DQUOTE$ + GetFilePart(gsCurrDatabaseFile) + #DQUOTE$
      
      sClipboardText + Chr(10) + "DataSection"
      sPad = "  "
      sClipboardText + Chr(10) + sPad + "Language_" + UCase(gsLanguageCode) + ":"
      
      While NextDatabaseRow(#TR_Database)
        sId = RSet(decodeSpecialChars(GetDatabaseString(#TR_Database, 0)), 4, "0")  ; sId (as a 4-digit string)
        sGroup = decodeSpecialChars(GetDatabaseString(#TR_Database, 1))  ; sGroup
        sName = decodeSpecialChars(GetDatabaseString(#TR_Database, 2))  ; sName
        sTrans = Trim(ReplaceString(Trim(decodeSpecialChars(GetDatabaseString(#TR_Database, 5))), #DQUOTE$, "'"))  ; sTrans
        sComment = Trim(decodeSpecialChars(GetDatabaseString(#TR_Database, 6)))  ; sComment
        If Len(sGroup) > 0
          If sGroup <> sCurrGroup
            sClipboardText + Chr(10) + sPad
            sClipboardText + Chr(10) + sPad + ";- Language group " + sGroup
            sClipboardText + Chr(10) + sPad + "Data.s " + #DQUOTE$ + #DQUOTE$ + ", " + #DQUOTE$ + "_GROUP_" + #DQUOTE$ + ", " + #DQUOTE$ + sGroup + #DQUOTE$
            sCurrGroup = sGroup
          EndIf
          If sTrans ; ignores blank translations (used a few times in the German translation)
            sLine = "Data.s " + #DQUOTE$ + sId + #DQUOTE$ + ", " + #DQUOTE$ + sName + #DQUOTE$ + ", " + #DQUOTE$ + sTrans + #DQUOTE$
            If Len(sComment) > 0
              sLine + " ; " + sComment
            EndIf
            sClipboardText + Chr(10) + sPad + sLine
            nItemsCopied + 1
          EndIf
        EndIf
      Wend
      FinishDatabaseQuery(#TR_Database)
      
      sClipboardText + Chr(10) + sPad
      ; sClipboardText + Chr(10) + sPad + ";-"
      sClipboardText + Chr(10) + sPad + "Data.s " + #DQUOTE$ + #DQUOTE$ + ", " + #DQUOTE$ + "_END_" + #DQUOTE$ + ", " + #DQUOTE$ + #DQUOTE$
      
      sPad = ""
      sClipboardText + Chr(10) + "EndDataSection"
      sClipboardText + Chr(10)
      
    Else
      Debug "SQL Failed: " + sRequest
    EndIf
    
    ClearClipboard()
    SetClipboardText(sClipboardText)
    MessageRequester("Clipboard", Str(nItemsCopied) + " items copied to the clipboard")
    
  EndWith
EndProcedure

Procedure btnCreateLangFileEvent()
  Protected sRequest.s
  Protected sId.s, sGroup.s, sName.s, sTrans.s
  Protected sCurrGroup.s
  Protected nItemsWritten
  Protected sTab.s = Chr(9)

  With WTR
    applyItemChangeIfReqd()
    
    If CreateFile(2, gsLangFile)
      ; file created OK
    Else
      MessageRequester("Create Language File", "CreateFile failed" + Chr(10) + "gsLangFile=" + gsLangFile)
      ProcedureReturn
    EndIf
    
    sRequest = "SELECT * FROM langtext WHERE sTrans IS NOT NULL OR sComment IS NOT NULL ORDER BY sGroup, nId"
    
    Debug "sRequest=" + sRequest
    If DatabaseQuery(#TR_Database, sRequest)
      
      WriteStringN(2, "_LANGUAGE_" + sTab + UCase(gsLanguageCode)) ; + sTab)
      
      While NextDatabaseRow(#TR_Database)
        ; sId = RSet(decodeSpecialChars(GetDatabaseString(#TR_Database, 0)), 4, "0")  ; sId (as a 4-digit string)
        sGroup = decodeSpecialChars(GetDatabaseString(#TR_Database, 1))  ; sGroup
        sName = decodeSpecialChars(GetDatabaseString(#TR_Database, 2))  ; sName
        sTrans = ReplaceString(Trim(decodeSpecialChars(GetDatabaseString(#TR_Database, 5))), #DQUOTE$, "'")  ; sTrans
        If Len(sGroup) > 0
          If sGroup <> sCurrGroup
            WriteStringN(2, "_GROUP_" + sTab + sGroup + sTab)
            sCurrGroup = sGroup
          EndIf
          WriteStringN(2, sName + sTab + sTrans) ; + sTab + sId)
          nItemsWritten + 1
        EndIf
      Wend
      FinishDatabaseQuery(#TR_Database)
      
      WriteStringN(2, "_END_" + sTab) ; + sTab)
      
    Else
      Debug "SQL Failed: " + sRequest
    EndIf
    
    CloseFile(2)
    MessageRequester("Create Language File", Str(nItemsWritten) + " items written to" + Chr(10) + gsLangFile)
    
  EndWith
EndProcedure

Procedure closeForm()
  Debug "closeForm Start"
  If IsDatabase(#TR_Database)
    Debug "calling applyItemChangeIfReqd()"
    applyItemChangeIfReqd()
    Debug "returned from applyItemChangeIfReqd()"
  EndIf
  gbEndOfRun = #True
  Debug "closeForm End"
EndProcedure

Procedure EventHandler()
  
  With WTR
    Select gnWindowEvent
      Case #PB_Event_CloseWindow
        Debug "Close Window"
        closeForm()
        
      Case #PB_Event_Menu
        gnEventMenu = EventMenu()
        Select gnEventMenu
          Case #WTR_mnuPrev
            btnPrevEvent()
            
          Case #WTR_mnuNext
            btnNextEvent()
            
        EndSelect
        
      Case #PB_Event_Gadget
        gnEventGadgetNo = EventGadget()
        gnEventType = EventType()
        
        Select gnEventGadgetNo
          Case \btnClearSearch
            loadGrdTranslate()
            
          Case \btnClipboard
            CompilerIf #cDisplayExportButton
              btnClipboardEvent()
            CompilerEndIf
            
          Case \btnClose
            closeForm()
            
          Case \btnCreateLangFile
            btnCreateLangFileEvent()
            
          Case \btnExport
            CompilerIf #cDisplayExportButton
              btnExportEvent()
            CompilerEndIf
            
          Case \btnNext
            btnNextEvent()
            
          Case \btnPrev
            btnPrevEvent()
            
          Case \btnRevert
            btnRevertEvent()
            
          Case \btnSearch
            loadGrdTranslate(#True)
            
          Case \grdTranslate
            grdTranslateEvent()
            
          Case \cboOrderBy
            If gnEventType = #PB_EventType_Change
              loadGrdTranslate()
            EndIf
            
          Case \optAll
            loadGrdTranslate()
            
          Case \optBlanks
            loadGrdTranslate()
            
          Case \optChanged
            loadGrdTranslate()
            
          Case \optCommented
            loadGrdTranslate()
            
          Case \txtOther
            txtOtherEvent()
            
          Case \txtComment
            txtCommentEvent()
            
        EndSelect
    EndSelect
  EndWith
  
EndProcedure

Procedure createNewDatabase()
  Protected nID, sId.s, sGroup.s, sName.s, sString.s
  Protected nResult, sRequest.s
  Protected sLine.s
  Protected nMaxLengthGroup, nMaxLengthName, nMaxLengthString, nMaxLengthTrans
  Protected nMaxId

  Debug "createNewDatabase Start"
  
  If CreateFile(0, gsNewDatabaseFile)
    Debug "database file created"
    CloseFile(0)
  Else
    MessageRequester("DB Create", "Cannot create the database file " + gsNewDatabaseFile)
    ProcedureReturn
  EndIf
  
  If OpenDatabase(#TR_Database, gsNewDatabaseFile, "", "")
    
    doDatabaseUpdate(#TR_Database, "CREATE TABLE langtext (nId INT, sGroup CHAR(20), sName CHAR(40), sString CHAR(500), sItemChanged CHAR(1), sTrans CHAR(500), sComment CHAR(200), sOrigTrans CHAR(500))")
    
    ; Default language (ENUS)
    Restore Language_ENUS
    Repeat
      
      Read.s sId
      Read.s sName
      Read.s sString
      
      ; sName = UCase(sName)
      
      sName = encodeSpecialChars(sName)
      sString = encodeSpecialChars(sString)
      
      If sName = "_GROUP_"
        ; sGroup = UCase(sString)
        sGroup = sString
        If Len(sGroup) > nMaxLengthGroup
          nMaxLengthGroup = Len(sGroup)
        EndIf
        
      ElseIf sName = "_END_"
        Break
        
      Else
        If Len(sName) > nMaxLengthName
          nMaxLengthName = Len(sName)
        EndIf
        If Len(sString) > nMaxLengthString
          nMaxLengthString = Len(sString)
        EndIf
        If gsLanguageCode = "ENUS"
          sRequest = "INSERT INTO langtext (nId, sGroup, sName, sString) VALUES (999999, '" + sGroup + "', '" + sName + "', '" + sString + "')"
        Else
          sRequest = "INSERT INTO langtext (nId, sGroup, sName, sString) VALUES (" + sId + ", '" + sGroup + "', '" + sName + "', '" + sString + "')"
        EndIf
        nResult = doDatabaseUpdate(#TR_Database, sRequest)
        If nResult = 0
          Debug "Failed: " + sRequest
          Debug "Error: " + DatabaseError()
        Else
          gnRowsInserted + 1
          If (gnRowsInserted % 100) = 0
            Debug Str(gnRowsInserted) + " rows inserted"
          EndIf
        EndIf
        
      EndIf
      
    ForEver
    
    Debug Str(gnRowsInserted) + " rows inserted"
    
    ; Specific language
    restoreLanguage()
    Repeat
      
      Read.s sId
      Read.s sName
      Read.s sString
      
      ; sName = UCase(sName)
      
      sName = encodeSpecialChars(sName)
      sString = encodeSpecialChars(sString)
      
      If sName = "_GROUP_"
        ; sGroup = UCase(sString)
        sGroup = sString
        
      ElseIf sName = "_END_"
        Break
        
      Else
        If Len(sString) > nMaxLengthTrans
          nMaxLengthTrans = Len(sString)
        EndIf
        sRequest = "UPDATE langtext SET sTrans = '" + sString + "' WHERE sGroup = '" + sGroup + "' AND sName = '" + sName + "'"
        nResult = doDatabaseUpdate(#TR_Database, sRequest)
        If nResult = 0
          Debug "Failed: " + sRequest
          Debug "Error: " + DatabaseError()
        Else
          gnRowsUpdated + 1
          If (gnRowsUpdated % 100) = 0
            Debug Str(gnRowsUpdated) + " rows updated"
          EndIf
        EndIf
        
      EndIf
      
    ForEver
    
    If gsLanguageCode = "ENUS"
      ; find maximum Id currently used for this language
      restoreLanguage()
      Repeat
        Read.s sId
        Read.s sName
        Read.s sString
        sName = encodeSpecialChars(sName)
        If sName = "_GROUP_"
          sGroup = sString
        ElseIf sName = "_END_"
          Break
        Else
          If Len(sId) > 0
            nID = Val(sId)
            If nID > nMaxId
              nMaxId = nID
            EndIf
          EndIf
        EndIf
      ForEver
      Debug "nMaxId=" + Str(nMaxId)
      
      sRequest = "SELECT * FROM langtext WHERE nId = 999999 ORDER BY sGroup, sName"
      
      Debug "sRequest=" + sRequest
      If DatabaseQuery(#TR_Database, sRequest)
        While NextDatabaseRow(#TR_Database)
          sGroup = decodeSpecialChars(GetDatabaseString(#TR_Database, 1))  ; sGroup
          sName = decodeSpecialChars(GetDatabaseString(#TR_Database, 2))  ; sName
          nMaxId + 1
          sId = Str(nMaxId)
          sRequest = "UPDATE langtext SET nId = " + sId + " WHERE sGroup = '" + sGroup + "' AND sName = '" + sName + "'"
          nResult = doDatabaseUpdate(#TR_Database, sRequest)
          If nResult = 0
            Debug "Failed: " + sRequest
            Debug "Error: " + DatabaseError()
          Else
            gnRowsUpdated + 1
            If (gnRowsUpdated % 100) = 0
              Debug Str(gnRowsUpdated) + " rows updated"
            EndIf
          EndIf
        Wend
        FinishDatabaseQuery(#TR_Database)
      Else
        Debug "SQL Failed: " + sRequest
      EndIf
    EndIf
    
    Debug Str(gnRowsUpdated) + " rows updated"
    
    sRequest = "UPDATE langtext SET sOrigTrans = sTrans"
    nResult = doDatabaseUpdate(#TR_Database, sRequest)
    If nResult = 0
      Debug "Failed: " + sRequest
      Debug "Error: " + DatabaseError()
    EndIf
    
    Debug "nMaxLengthGroup=" + Str(nMaxLengthGroup)
    Debug "nMaxLengthName=" + Str(nMaxLengthName)
    Debug "nMaxLengthString=" + Str(nMaxLengthString)
    Debug "nMaxLengthTrans=" + Str(nMaxLengthTrans)
    
    CloseDatabase(#TR_Database)
    
  Else
    MessageRequester(#PB_Compiler_Procedure, "(a) Cannot open the database file " + gsNewDatabaseFile + #CRLF$ + #CRLF$ + DatabaseError())
    ProcedureReturn
  EndIf
  
EndProcedure

Procedure __MainProcedure()
  Protected n
  Protected sDatabaseFile.s
  Protected sDate.s
  Protected qFileSize.q
  
  CompilerIf #PB_Compiler_Unicode = #False
    CompilerError "Unicode compiler option not set"
  CompilerEndIf
  
  If checkAllIds() = #False
    ProcedureReturn
  EndIf
  
  sDate = FormatDate("%yy%mm%dd", Date())
  sDatabaseFile = "scs_lang_db_" + LCase(gsLanguageCode) + sDate + ".sqlite"
  
  gsMyDocsPath = GetUserDirectory(#PB_Directory_Documents)
  CompilerIf #cDatabaseInDocumentsFolder
    gsDefaultFolder = gsMyDocsPath
  CompilerElse
    gsDropboxPath = "C:\Users\SCS-Mike\Dropbox\"
    Select gsLanguageCode
      Case "DE"
        gsDefaultFolder = gsDropboxPath + "SCS-transl.ger\"
      Default
        gsDefaultFolder = gsDropboxPath + "SCS General\Language_Databases\Lang_" + gsLanguageCode + "\"
        qFileSize = FileSize(gsDefaultFolder)
        Debug "qFileSize=" + qFileSize + ", gsDefaultFolder=" + #DQUOTE$ + gsDefaultFolder + #DQUOTE$
        If qFileSize = -1
          gsDefaultFolder = gsMyDocsPath
        EndIf
        ; gsDefaultFolder = gsMyDocsPath + "SCS\Language_Databases\Lang_" + gsLanguageCode + "\"
    EndSelect
  CompilerEndIf
  
  Select gnLangDatabaseAction
    Case #SCS_LANG_DB_READ, #SCS_LANG_DB_UPDATE
      gsOldDatabaseFile = OpenFileRequester("Open Most Recent Database File", gsDefaultFolder + sDatabaseFile, "sqlite|*.sqlite", 0)
      If Len(gsOldDatabaseFile) = 0
        ProcedureReturn
      EndIf
      gsMyFolder = GetPathPart(gsOldDatabaseFile)
    Case #SCS_LANG_DB_CREATE
      gsMyFolder = gsDefaultFolder
  EndSelect
  
  gsNewDatabaseFile = gsMyFolder + sDatabaseFile
  CompilerIf #cDisplayExportButton
    gsExportFile = gsDropboxPath + "SCS General\Language_Databases\" + "scs_lang_export_" + LCase(gsLanguageCode) + ".txt"
  CompilerEndIf
  gsLangFile = gsMyFolder + "scsLang" + UCase(gsLanguageCode) + ".scsl"
  
  ; gsExportFile = "scs_lang_export_" + LCase(gsLanguageCode) + ".pbi"
  
  For n = 0 To (gnLanguageCount - 1)
    If gaLanguage(n)\sLangCode = "ENUS"
      gsLanguageENUSName = gaLanguage(n)\sLangName
    EndIf
    If gaLanguage(n)\sLangCode = gsLanguageCode
      gsLanguageName = gaLanguage(n)\sLangName
    EndIf
  Next n
  
  Select gnLangDatabaseAction
    Case #SCS_LANG_DB_CREATE
      createNewDatabase()
      gsCurrDatabaseFile = gsNewDatabaseFile
      
    Case #SCS_LANG_DB_READ
      gsCurrDatabaseFile = gsOldDatabaseFile
      
    Case #SCS_LANG_DB_UPDATE
      loadCommentsFromOldDatabase()
      createNewDatabase()
      loadCommentsIntoNewDatabase()
      gsCurrDatabaseFile = gsNewDatabaseFile
      
  EndSelect
  
  If OpenDatabase(#TR_Database, gsCurrDatabaseFile, "", "")
    If createfmTranslate()
      loadGrdTranslate()
      countConditions(#True)
    EndIf
    
    checkParams()
    
    Repeat
      gnWindowEvent = WaitWindowEvent(50)
      EventHandler()
      If gqTimeDebugMsgDisplayed
        If (scsMilliseconds() - gqTimeDebugMsgDisplayed) > 5000 ; 5-second timeout for debug messages
          SetGadgetText(WTR\lblDebugMsg1, "")
          SetGadgetText(WTR\lblDebugMsg2, "")
          gqTimeDebugMsgDisplayed = 0
        EndIf
      EndIf
    Until gbEndOfRun
    
    Debug "CloseDatabase(#TR_Database)"
    CloseDatabase(#TR_Database)
  Else
    MessageRequester(#PB_Compiler_Procedure, "(b) Cannot open the database file " + gsCurrDatabaseFile + #CRLF$ + #CRLF$ + "DatabaseError()=" + DatabaseError())
    ProcedureReturn
  EndIf

EndProcedure

Debug "Start of Run"
__MainProcedure()
Debug "End of Run"
End
