; File: CSRD.pbi (Ctrl Send Remote Device)

EnableExplicit

Procedure CSRD_ScanXMLRemDevs(*CurrentNode, CurrentSublevel)
  PROCNAMEC()
  Protected sNodeName.s, sNodeText.s
  Protected Dim sAttributeName.s(5), Dim sAttributeValue.s(5)
  Protected nMaxAttribute, n
  Protected sErrorMsgs.s
  Static sLangCode.s, sLangGrp.s, nDevType, sDevCode.s, nRemDevId
  Protected *nChildNode
  
  ; debugMsg(sProcName, #SCS_START + ", *CurrentNode=" + *CurrentNode + ", CurrentSublevel=" + CurrentSublevel + ", XMLNodeType(*CurrentNode)=" + XMLNodeType(*CurrentNode) + ", #PB_XML_Normal=" + #PB_XML_Normal)
  
  ; Ignore anything except normal nodes. See the manual for XMLNodeType() for an explanation of the other node types.
  If XMLNodeType(*CurrentNode) = #PB_XML_Normal
    
    sNodeName = GetXMLNodeName(*CurrentNode)
    If XMLChildCount(*CurrentNode) = 0
      sNodeText = GetXMLNodeText(*CurrentNode)
    EndIf
    
    nMaxAttribute = -1
    If ExamineXMLAttributes(*CurrentNode)
      While NextXMLAttribute(*CurrentNode)
        nMaxAttribute + 1
        If nMaxAttribute > ArraySize(sAttributeName())
          ; shouldn't get here
          ReDim sAttributeName(nMaxAttribute+2)
          ReDim sAttributeValue(nMaxAttribute+2)
        EndIf
        sAttributeName(nMaxAttribute) = XMLAttributeName(*CurrentNode)
        sAttributeValue(nMaxAttribute) = XMLAttributeValue(*CurrentNode)
      Wend
    EndIf
    
    ; debugMsg(sProcName, "sNodeName=" + sNodeName + ", sNodeText=" + sNodeText)
    Select sNodeName
      Case "CSRemDevs" ; INFO CSRemDevs
        ; initialise
        nRemDevId = 100 ; arbitrary base id
        sLangCode = ""
        nDevType = #SCS_DEVTYPE_NONE
        sDevCode = ""
        
      Case "LastUpdated" ; INFO LastUpdated
        grCSRD\nCSRDLastUpdated = Val(sNodeText)
        debugMsg(sProcName, "grCSRD\nCSRDLastUpdated=" + grCSRD\nCSRDLastUpdated)
        
      Case "LangInfo" ; INFO LangInfo
        For n = 0 To nMaxAttribute
          Select sAttributeName(n)
            Case "LangCode"
              sLangCode = sAttributeValue(n)
            Default
              sErrorMsgs + #CRLF$ + "XMLNodeName=" + sNodeName + ", Unknown XMLAttributeName: " + sAttributeName(n)
          EndSelect
        Next n
        
      Case "LangGrp" ; INFO LangGrp
        For n = 0 To nMaxAttribute
          Select sAttributeName(n)
            Case "LangGrp"
              sLangGrp = sAttributeValue(n)
            Default
              sErrorMsgs + #CRLF$ + "XMLNodeName=" + sNodeName + ", Unknown XMLAttributeName: " + sAttributeName(n)
          EndSelect
        Next n
        
      Case "LangItem" ; INFO LangItem
        If sLangCode = "ENUS" Or grGeneralOptions\sLangCode
          grCSRD\nMaxLangItem + 1
          If grCSRD\nMaxLangItem > ArraySize(grCSRD\aLangItem())
            ReDim grCSRD\aLangItem(grCSRD\nMaxLangItem+20)
          EndIf
          grCSRD\aLangItem(grCSRD\nMaxLangItem) = gaCSRDLangItem_Def ; set defaults
          With grCSRD\aLangItem(grCSRD\nMaxLangItem)
            \sCSRD_LangGrp = sLangGrp
            For n = 0 To nMaxAttribute
              Select sAttributeName(n)
                Case "LangItem"
                  \sCSRD_LangItem = sAttributeValue(n)
                Case "Short"
                  \sCSRD_LangShort = sAttributeValue(n)
                Case "ValSS"
                  If UCase(sAttributeValue(n)) = "Y"
                    \bCSRD_ValSS = #True
                  EndIf
                Default
                  sErrorMsgs + #CRLF$ + "XMLNodeName=" + sNodeName + ", Unknown XMLAttributeName: " + sAttributeName(n)
              EndSelect
            Next n
            \sCSRD_LangText = sNodeText
          EndWith
        EndIf ; EndIf sLangCode = "ENUS" Or grGeneralOptions\sLangCode
        
      Case "DevType" ; INFO DevType
        For n = 0 To nMaxAttribute
          Select sAttributeName(n)
            Case "DevType"
              Select sAttributeValue(n)
                Case "MIDI"
                  nDevType = #SCS_DEVTYPE_CS_MIDI_OUT
                Case "Network"
                  nDevType = #SCS_DEVTYPE_CS_NETWORK_OUT
                Default
                  sErrorMsgs + #CRLF$ + "XMLNodeName=" + sNodeName + ", Unknown DevType: " + sAttributeValue(n)
              EndSelect
            Default
              sErrorMsgs + #CRLF$ + "XMLNodeName=" + sNodeName + ", Unknown XMLAttributeName: " + sAttributeName(n)
          EndSelect
        Next n
        
      Case "RemDev" ; INFO RemDev
        grCSRD\nMaxRemDev + 1
        If grCSRD\nMaxRemDev > ArraySize(grCSRD\aRemDev())
          ReDim grCSRD\aRemDev(grCSRD\nMaxRemDev+5)
        EndIf
        grCSRD\aRemDev(grCSRD\nMaxRemDev) = gaCSRDRemDev_Def ; set defaults
        With grCSRD\aRemDev(grCSRD\nMaxRemDev)
          nRemDevId + 1
          \nCSRD_RemDevId = nRemDevId
          \nCSRD_DevType = nDevType
          For n = 0 To nMaxAttribute
            Select sAttributeName(n)
              Case "DevCode"
                \sCSRD_DevCode = sAttributeValue(n)
                sDevCode = \sCSRD_DevCode ; save in static variable
              Case "DevLangItem"
                \sCSRD_DevLang = sAttributeValue(n)
              Case "DfltMIDIChan"
                \nCSRD_DfltMIDIChan = Val(sAttributeValue(n))
              Default
                sErrorMsgs + #CRLF$ + "XMLNodeName=" + sNodeName + ", Unknown XMLAttributeName: " + sAttributeName(n)
            EndSelect
          Next n
        EndWith
        
      Case "ValidValues" ; INFO ValidValues
        grCSRD\nMaxValidValue + 1
        If grCSRD\nMaxValidValue > ArraySize(grCSRD\aValidValue())
          ReDim grCSRD\aValidValue(grCSRD\nMaxValidValue+20)
        EndIf
        grCSRD\aValidValue(grCSRD\nMaxValidValue) = gaCSRDValidValue_Def ; set defaults
        With grCSRD\aValidValue(grCSRD\nMaxValidValue)
          \nCSRD_RemDevId = nRemDevId
          \nCSRD_ValBase = 1
          For n = 0 To nMaxAttribute
            Select sAttributeName(n)
              Case "ValType"
                \sCSRD_ValType = sAttributeValue(n)
              Case "ValLangItem"
                \sCSRD_ValLang = sAttributeValue(n)
              Case "ValWidth"
                \nCSRD_ValWidth = Val(sAttributeValue(n))
              Case "ValBase"
                \nCSRD_ValBase = Val(sAttributeValue(n))
              Default
                sErrorMsgs + #CRLF$ + "XMLNodeName=" + sNodeName + ", Unknown XMLAttributeName: " + sAttributeName(n)
            EndSelect
          Next n
          \sCSRD_ValData = StringField(sNodeText, 1, "|") ; modified 2Sep2022 11.9.5.1ab
          \sCSRD_ValDataCodes = StringField(sNodeText, 2, "|") ; added 2Sep2022 11.9.5.1ab
        EndWith
        
      Case "FaderData" ; INFO FaderData
        grCSRD\nMaxFaderData + 1
        If grCSRD\nMaxFaderData > ArraySize(grCSRD\aFaderData())
          ReDim grCSRD\aFaderData(grCSRD\nMaxFaderData+20)
        EndIf
        grCSRD\aFaderData(grCSRD\nMaxFaderData) = gaCSRDFaderData_Def ; set defaults
        With grCSRD\aFaderData(grCSRD\nMaxFaderData)
          \nCSRD_RemDevId = nRemDevId
          For n = 0 To nMaxAttribute
            Select sAttributeName(n)
              Case "FdrType"
                \sCSRD_FdrType = sAttributeValue(n)
              Case "FdrLangItem"
                \sCSRD_FdrLang = sAttributeValue(n)
              Case "FdrData"
                \sCSRD_FdrData = sAttributeValue(n)
              Case "FdrBytes"
                \nCSRD_FdrBytes = Val(sAttributeValue(n))
              Case "FdrValFormat"
                \sCSRD_FdrValFormat = sAttributeValue(n)
              Default
                sErrorMsgs + #CRLF$ + "XMLNodeName=" + sNodeName + ", Unknown XMLAttributeName: " + sAttributeName(n)
            EndSelect
          Next n
          \sCSRD_FdrData = RemoveString(sNodeText, " ") ; remove all spaces, which initially were included in the SQ series FaderData to make it more readable in UltraEdit.
          ; ???? check that first and last fader data values are exact multiples of 10
        EndWith
        
      Case "MsgData" ; INFO MsgData
        grCSRD\nMaxRemDevMsgData + 1
        If grCSRD\nMaxRemDevMsgData > ArraySize(grCSRD\aRemDevMsgData())
          ReDim grCSRD\aRemDevMsgData(grCSRD\nMaxRemDevMsgData+20)
        EndIf
        grCSRD\aRemDevMsgData(grCSRD\nMaxRemDevMsgData) = gaCSRDRemDevMsgData_Def ; set defaults
        With grCSRD\aRemDevMsgData(grCSRD\nMaxRemDevMsgData)
          \nCSRD_RemDevId = nRemDevId
          \nCSRD_SelectionType = #SCS_SELTYPE_GRID ; default allow multiple values to be selected from a grid (may be changed under "SelectionType" below),
                                                   ; although will be changed to #SCS_SELTYPE_NONE in CSRD_DeriveExtraData() if \sMsgData does not contain a $,
                                                   ; because that implies there's only a single value available (eg for MuteLR)
          For n = 0 To nMaxAttribute
            Select sAttributeName(n)
              Case "MsgType"
                \sCSRD_RemDevMsgType = sAttributeValue(n)
              Case "MsgLangItem"
                \sCSRD_MsgLang = sAttributeValue(n)
              Case "ValidValuesType"
                \sCSRD_ValType = sAttributeValue(n)
              Case "ValidValuesType2"
                \sCSRD_ValType2 = sAttributeValue(n)
              Case "FaderType"
                \sCSRD_FdrType = sAttributeValue(n)
              Case "SkipParamValues"
                \sCSRD_SkipParamValues = sAttributeValue(n)
              Case "OSCCmdType"
                \sCSRD_OSCCmdType = sAttributeValue(n)
                \nCSRD_OSCCmdType = encodeOSCCmdType(\sCSRD_OSCCmdType)
              Case "SelectionType"
                ; see default setting above
                Select LCase(sAttributeValue(n))
                  Case "cbo"
                    \nCSRD_SelectionType = #SCS_SELTYPE_CBO
                  Case "cbo+grid" ; Added 5Sep2022 11.9.5.1ab
                    \nCSRD_SelectionType = #SCS_SELTYPE_CBO_AND_GRID
                  Case "fader"
                    \nCSRD_SelectionType = #SCS_SELTYPE_FADER
                  Case "fader+grid"
                    \nCSRD_SelectionType = #SCS_SELTYPE_FADER_AND_GRID
                  Case "cbo+fader+grid"
                    \nCSRD_SelectionType = #SCS_SELTYPE_CBO_FADER_AND_GRID
                  Case "none"
                    \nCSRD_SelectionType = #SCS_SELTYPE_NONE
                  Default
                    \nCSRD_SelectionType = #SCS_SELTYPE_GRID
                EndSelect
              Default
                sErrorMsgs + #CRLF$ + "XMLNodeName=" + sNodeName + ", Unknown XMLAttributeName: " + sAttributeName(n)
            EndSelect
          Next n
          \sCSRD_MsgData = sNodeText
        EndWith
        
      Default
        sErrorMsgs + #CRLF$ + "Unknown XMLNodeName: " + sNodeName
        
    EndSelect
    
    ; Now get the first child node (if any)
    *nChildNode = ChildXMLNode(*CurrentNode)
    ; debugMsg(sProcName, "ChildXMLNode(" + *CurrentNode + ") returned *nChildNode=" + *nChildNode)
    
    While *nChildNode <> 0
      ; Loop through all available child nodes and call this procedure again
      CSRD_ScanXMLRemDevs(*nChildNode, CurrentSublevel + 1)
      *nChildNode = NextXMLNode(*nChildNode)
    Wend        
    
  EndIf
  
  If sErrorMsgs
    ; NB Hopefully this will only occur (if at all) during testing.
    ; The 'RemoveString' removes the leading #CRLF$ as every error line starts with this.
    scsMessageRequester(sProcName, RemoveString(sErrorMsgs, #CRLF$, #PB_String_NoCase, 1, 1), #PB_MessageRequester_Warning)
  EndIf
  
EndProcedure

Procedure CSRD_DeriveExtraData()
  PROCNAMEC()
  Protected n1, n2, n3, bFound, bFound3
  Protected sLangItem.s
  Protected nRemDevId, sValType.s, sValType2.s, sFdrType.s
  
  ; INFO Derive extra device data
  For n1 = 0 To grCSRD\nMaxRemDev
    With grCSRD\aRemDev(n1)
      If Len(\sCSRD_DevLang) = 0
        ; if no DevLang specified then assume it's the same as the DevCode
        \sCSRD_DevLang = \sCSRD_DevCode
      EndIf
      ; obtain device name from language array
      sLangItem = \sCSRD_DevLang
      bFound = #False
      For n2 = 0 To grCSRD\nMaxLangItem
        If grCSRD\aLangItem(n2)\sCSRD_LangGrp = "Dev" And grCSRD\aLangItem(n2)\sCSRD_LangItem = sLangItem
          \sCSRD_DevName = grCSRD\aLangItem(n2)\sCSRD_LangText
          bFound = #True
          Break
        EndIf
      Next n2
      If bFound = #False
        debugMsg(sProcName, "No LangText found for LangGrp 'Dev', LangItem '" + sLangItem + "'")
      EndIf
    EndWith
  Next n1
  
  ; INFO Derive extra valid value data
  ; NB 'Derive extra valid value data' MUST be processed BEFORE 'Derive extra message data'
  debugMsg(sProcName, "grCSRD\nMaxValidValue=" + grCSRD\nMaxValidValue)
  For n1 = 0 To grCSRD\nMaxValidValue
    With grCSRD\aValidValue(n1)
      If Len(\sCSRD_ValLang) = 0
        ; if no ValLang specified then assume it's the same as the ValType
        \sCSRD_ValLang = \sCSRD_ValType
      EndIf
      CSRD_UnpackValData(n1)
    EndWith
  Next n1
  
  ; INFO Derive extra fader data
  ; NB 'Derive extra fader data' MUST be processed BEFORE 'Derive extra message data'
  debugMsg(sProcName, "grCSRD\nMaxFaderData=" + grCSRD\nMaxFaderData)
  For n1 = 0 To grCSRD\nMaxFaderData
    With grCSRD\aFaderData(n1)
      If Len(\sCSRD_FdrLang) = 0
        ; if no FdrLang specified then assume it's the same as the FdrType
        \sCSRD_FdrLang = \sCSRD_FdrType
      EndIf
      CSRD_UnpackFaderValues(n1)
    EndWith
  Next n1
  
  ; INFO Derive extra message data
  For n1 = 0 To grCSRD\nMaxRemDevMsgData
    With grCSRD\aRemDevMsgData(n1)
      ; set nCSRD_RemDevMsgType higher than #SCS_MSGTYPE_DUMMY_LAST as these MsgData entries will be used with regular #SCS_MSGTYPE_... entries in WQM\cboMsgType
      \nCSRD_RemDevMsgType = #SCS_MSGTYPE_DUMMY_LAST + 1 + n1
      If FindString(\sCSRD_MsgData, "$") = 0
        \nCSRD_SelectionType = #SCS_SELTYPE_NONE
      EndIf
      If Len(\sCSRD_MsgLang) = 0
        ; if no MsgLang specified then assume it's the same as the MsgType
        \sCSRD_MsgLang = \sCSRD_RemDevMsgType
      EndIf
      ; obtain message description from language array
      sLangItem = \sCSRD_MsgLang
      ; debugMsg(sProcName, "sLangItem='" + sLangItem + "'")
      bFound = #False
      For n2 = 0 To grCSRD\nMaxLangItem
        ; debugMsg(sProcName, "grCSRD\aLangItem(" + n2 + ")\sCSRD_LangGrp='" + grCSRD\aLangItem(n2)\sCSRD_LangGrp + "', grCSRD\aLangItem(" + n2 + ")\sCSRD_LangItem='" + grCSRD\aLangItem(n2)\sCSRD_LangItem + "'")
        If grCSRD\aLangItem(n2)\sCSRD_LangGrp = "Msg" And grCSRD\aLangItem(n2)\sCSRD_LangItem = sLangItem
          \sCSRD_MsgDesc = grCSRD\aLangItem(n2)\sCSRD_LangText
          If grCSRD\aLangItem(n2)\sCSRD_LangShort
            \sCSRD_MsgShortDesc = grCSRD\aLangItem(n2)\sCSRD_LangShort
          Else
            ; if the 'Short' attribute is not present, then use the language item, which is fine for message types like 'MuteFXRtn'
            \sCSRD_MsgShortDesc = sLangItem
          EndIf
          bFound = #True
          ; debugMsg(sProcName, "bFound=" + strB(bFound) + ", \sCSRD_MsgShortDesc='" + \sCSRD_MsgShortDesc + "'")
          Break
        EndIf
      Next n2
      If bFound = #False
        debugMsg0(sProcName, "\nCSRD_RemDevId=" + \nCSRD_RemDevId + ": No LangText found for LangGrp 'Msg', LangItem '" + sLangItem + "'")
      EndIf
      
      ; obtain valid value info from valid values array
      If \sCSRD_ValType
        nRemDevId = \nCSRD_RemDevId
        sValType = \sCSRD_ValType
        bFound = #False
        For n2 = 0 To grCSRD\nMaxValidValue
          If grCSRD\aValidValue(n2)\nCSRD_RemDevId = nRemDevId And grCSRD\aValidValue(n2)\sCSRD_ValType = sValType
            \sCSRD_ValData = grCSRD\aValidValue(n2)\sCSRD_ValData
            \sCSRD_ValDataCodes = grCSRD\aValidValue(n2)\sCSRD_ValDataCodes ; Added 3Sep2022 11.9.5.1ab
            \sCSRD_ValDataNum = grCSRD\aValidValue(n2)\sCSRD_ValDataNum
            \nCSRD_ValWidth = grCSRD\aValidValue(n2)\nCSRD_ValWidth
            \nCSRD_ValBase = grCSRD\aValidValue(n2)\nCSRD_ValBase
            \nCSRD_MaxValDataValue = grCSRD\aValidValue(n2)\nCSRD_MaxValDataValue
            CopyArray(grCSRD\aValidValue(n2)\sValDataValue(), \sValDataValue())
            bFound = #True
            ; obtain value description from language array
            sLangItem = grCSRD\aValidValue(n2)\sCSRD_ValLang
            bFound3 = #False
            For n3 = 0 To grCSRD\nMaxLangItem
              If grCSRD\aLangItem(n3)\sCSRD_LangGrp = "Val" And grCSRD\aLangItem(n3)\sCSRD_LangItem = sLangItem
                \sCSRD_ValDesc = grCSRD\aLangItem(n3)\sCSRD_LangText
                \bCSRD_ValSS = grCSRD\aLangItem(n3)\bCSRD_ValSS
                bFound3 = #True
                Break
              EndIf
            Next n3
            If bFound3 = #False
              debugMsg0(sProcName, "grCSRD\aRemDevMsgData(" + n1 + ")\nCSRD_RemDevId=" + \nCSRD_RemDevId + ": No LangText found For LangGrp 'Val', LangItem '" + sLangItem + "'")
              grCSRD\bLogCSRDArray = #True
            EndIf
            Break
          EndIf
        Next n2
        If bFound = #False
          debugMsg0(sProcName, "grCSRD\aRemDevMsgData(" + n1 + ")\nCSRD_RemDevId=" + \nCSRD_RemDevId + ": No ValType found For MsgType '" + \sCSRD_RemDevMsgType + "', ValType '" + sValType + "'")
          grCSRD\bLogCSRDArray = #True
        EndIf
      EndIf ; EndIf \sCSRD_ValType
      
      If \sCSRD_ValType2
        nRemDevId = \nCSRD_RemDevId
        sValType2 = \sCSRD_ValType2
        bFound = #False
        For n2 = 0 To grCSRD\nMaxValidValue
          If grCSRD\aValidValue(n2)\nCSRD_RemDevId = nRemDevId And grCSRD\aValidValue(n2)\sCSRD_ValType = sValType2
            \sCSRD_ValData2 = grCSRD\aValidValue(n2)\sCSRD_ValData
            \sCSRD_ValDataCodes2 = grCSRD\aValidValue(n2)\sCSRD_ValDataCodes ; Added 3Sep2022 11.9.5.1ab
            \sCSRD_ValDataNum2 = grCSRD\aValidValue(n2)\sCSRD_ValDataNum
            \nCSRD_ValWidth2 = grCSRD\aValidValue(n2)\nCSRD_ValWidth
            \nCSRD_ValBase2 = grCSRD\aValidValue(n2)\nCSRD_ValBase
            \nCSRD_MaxValDataValue2 = grCSRD\aValidValue(n2)\nCSRD_MaxValDataValue
            CopyArray(grCSRD\aValidValue(n2)\sValDataValue(), \sValDataValue2())
            bFound = #True
            ; obtain value description from language array
            sLangItem = grCSRD\aValidValue(n2)\sCSRD_ValLang
            bFound3 = #False
            For n3 = 0 To grCSRD\nMaxLangItem
              If grCSRD\aLangItem(n3)\sCSRD_LangGrp = "Val" And grCSRD\aLangItem(n3)\sCSRD_LangItem = sLangItem
                \sCSRD_ValDesc2 = grCSRD\aLangItem(n3)\sCSRD_LangText
                \bCSRD_ValSS2 = grCSRD\aLangItem(n3)\bCSRD_ValSS
                bFound3 = #True
                Break
              EndIf
            Next n3
            If bFound3 = #False
              debugMsg0(sProcName, "grCSRD\aRemDevMsgData(" + n1 + ")\nCSRD_RemDevId=" + \nCSRD_RemDevId + ": No LangText found For LangGrp 'Val', LangItem '" + sLangItem + "'")
              grCSRD\bLogCSRDArray = #True
            EndIf
            Break
          EndIf
        Next n2
        If bFound = #False
          debugMsg0(sProcName, "grCSRD\aRemDevMsgData(" + n1 + ")\nCSRD_RemDevId=" + \nCSRD_RemDevId + ": No ValType found For MsgType '" + \sCSRD_RemDevMsgType + "', ValType2 '" + sValType2 + "'")
          grCSRD\bLogCSRDArray = #True
        EndIf
      EndIf ; EndIf \sCSRD_ValType
      
      ; obtain fader data from fader data array
      If \sCSRD_FdrType
        nRemDevId = \nCSRD_RemDevId
        sFdrType = \sCSRD_FdrType
        bFound = #False
        ; debugMsg0(sProcName, "nRemDevId=" + nRemDevId + ", sFdrType=" + sFdrType)
        For n2 = 0 To grCSRD\nMaxFaderData
          If grCSRD\aFaderData(n2)\nCSRD_RemDevId = nRemDevId And grCSRD\aFaderData(n2)\sCSRD_FdrType = sFdrType
            \sCSRD_FdrData= grCSRD\aFaderData(n2)\sCSRD_FdrData
            \nCSRD_MaxFaderValue= grCSRD\aFaderData(n2)\nCSRD_MaxFaderValue
            CopyArray(grCSRD\aFaderData(n2)\aFdrValue(), \aFdrValue())
            ; debugMsg0(sProcName, "grCSRD\aRemDevMsgData(" + n1 + ")\sCSRD_FdrData=" + \sCSRD_FdrData + ", \nCSRD_MaxFaderValue=" + \nCSRD_MaxFaderValue + ", ArraySize(\aFdrValue())=" + ArraySize(\aFdrValue()))
            bFound = #True
            ; obtain value description from language array
            sLangItem = grCSRD\aFaderData(n2)\sCSRD_FdrLang
            bFound3 = #False
            For n3 = 0 To grCSRD\nMaxLangItem
              If grCSRD\aLangItem(n3)\sCSRD_LangGrp = "Fdr" And grCSRD\aLangItem(n3)\sCSRD_LangItem = sLangItem
                \sCSRD_FdrDesc = grCSRD\aLangItem(n3)\sCSRD_LangText
                bFound3 = #True
                Break
              EndIf
            Next n3
            If bFound3 = #False
              debugMsg0(sProcName, "grCSRD\aRemDevMsgData(" + n1 + ")\nCSRD_RemDevId=" + \nCSRD_RemDevId + ": No LangText found For LangGrp 'Fdr', LangItem '" + sLangItem + "'")
              grCSRD\bLogCSRDArray = #True
            EndIf
            Break
          EndIf
        Next n2
        If bFound = #False
          debugMsg0(sProcName, "grCSRD\aRemDevMsgData(" + n1 + ")\nCSRD_RemDevId=" + \nCSRD_RemDevId + ": No FdrType found For MsgType '" + \sCSRD_RemDevMsgType + "', FdrType '" + sFdrType + "'")
          grCSRD\bLogCSRDArray = #True
        EndIf
      EndIf ; EndIf \sCSRD_FdrType
      
    EndWith
  Next n1
  
EndProcedure

Procedure CSRD_List()
  PROCNAMEC()
  Protected n, sLine.s, n1, nValue, fByte1.f, fByte2.f, fRemainder.f
  
  For n = 0 To grCSRD\nMaxRemDev
    With grCSRD\aRemDev(n)
      sLine = "grCSRD\aRemDev(" + n + ")\nCSRD_RemDevId=" + \nCSRD_RemDevId + ", DevType=" + decodeDevType(\nCSRD_DevType) + ", DevCode=" + \sCSRD_DevCode + ", DevName=" + #DQUOTE$ + \sCSRD_DevName + #DQUOTE$
      If \nCSRD_DfltMIDIChan > 0
        sLine + ", DfltMIDIChan=" + \nCSRD_DfltMIDIChan
      EndIf
      debugMsg(sProcName, sLine)
    EndWith
  Next n
  
  For n = 0 To grCSRD\nMaxRemDevMsgData
    With grCSRD\aRemDevMsgData(n)
      sLine = "grCSRD\aRemDevMsgData(" + n + ")\nCSRD_RemDevId=" + \nCSRD_RemDevId + ", MsgType=" + \nCSRD_RemDevMsgType + "(" + \sCSRD_RemDevMsgType + ")" + ", MsgDesc=" + #DQUOTE$ + \sCSRD_MsgDesc + #DQUOTE$ + ", MsgShort=" + #DQUOTE$ + \sCSRD_MsgShortDesc + #DQUOTE$ + 
              ", ValType=" + \sCSRD_ValType + ", ValDesc=" + #DQUOTE$ + \sCSRD_ValDesc + #DQUOTE$ + ", ValData=" + #DQUOTE$ + \sCSRD_ValData + #DQUOTE$ + ", ValDataCodes=" + #DQUOTE$ + \sCSRD_ValDataCodes + #DQUOTE$ + ", ValDataNum=" + #DQUOTE$ + \sCSRD_ValDataNum + #DQUOTE$ ; Changed 3Sep2022
      If \sCSRD_ValType2
        sline + ", ValType2=" + \sCSRD_ValType2 + ", ValDesc2=" + #DQUOTE$ + \sCSRD_ValDesc2 + #DQUOTE$ + ", ValData2=" + #DQUOTE$ + \sCSRD_ValData2 + #DQUOTE$ + ", ValDataCodes2=" + #DQUOTE$ + \sCSRD_ValDataCodes2 + #DQUOTE$ + ", ValDataNum2=" + #DQUOTE$ + \sCSRD_ValDataNum2 + #DQUOTE$ ; Changed 3Sep20
      EndIf
      If \nCSRD_ValWidth > 0
        sLine + ", ValWidth=" + \nCSRD_ValWidth
      EndIf
      If \nCSRD_ValBase <> 1
        sLine + ", ValBase=" + \nCSRD_ValBase
      EndIf
      If \sCSRD_FdrType
        sLine + ", FdrType=" + \sCSRD_FdrType + ", FdrDesc=" + #DQUOTE$ + \sCSRD_FdrDesc + #DQUOTE$ + ", FdrData=" + #DQUOTE$ + \sCSRD_FdrData + #DQUOTE$
      EndIf
      If \bCSRD_ValSS
        sLine + ", ValSS=Y"
      EndIf
      If \sCSRD_OSCCmdType
        sLine + ", OSCCmdType=" + \sCSRD_OSCCmdType
      EndIf
      sLine + ", MsgData=" + #DQUOTE$ + \sCSRD_MsgData + #DQUOTE$
      debugMsg(sProcName, sLine)
      If \sCSRD_FdrType = "Level2"
        sLine = "... "
        For n1 = 0 To \nCSRD_MaxFaderValue
          nValue = (\aFdrValue(n1)\nCSRD_FdrLevel_Byte1 << 7) + \aFdrValue(n1)\nCSRD_FdrLevel_Byte2
          fByte1 = Int(nValue / 8)
          fRemainder = Mod(nValue, 8)
          fByte2 = 128 * (fRemainder / 8)
          ; Debug "nValue=" + Int(nValue) + ", fByte1=" + Int(fByte1) + ", fByte2=" + Int(fByte2)
          sLine + Str(\aFdrValue(n1)\fCSRD_FdrLevel_dB) + "=" + StrF(fByte1,0) + "." + StrF(fByte2,0) + ","
        Next n1
        debugMsg(sProcName, sLine)
      EndIf
    EndWith
  Next n
  
  CompilerIf 1=2
    For n = 0 To grCSRD\nMaxValidValue
      With grCSRD\aValidValue(n)
        sLine = "grCSRD\aValidValue(" + n + ")\nCSRD_RemDevId=" + \nCSRD_RemDevId + ", \sCSRD_ValType=" + \sCSRD_ValType + ", \nCSRD_ValBase=" + \nCSRD_ValBase + ", \sValDataValue()="
        For n1 = \nCSRD_ValBase To \nCSRD_MaxValDataValue
          If n1 > \nCSRD_ValBase
            sLine + ", "
          EndIf
          sLine + \sValDataValue(n1)
        Next n1
        debugMsg(sProcName, sLine)
      EndWith
    Next n
  CompilerEndIf
  
EndProcedure

Procedure CSRD_Init()
  PROCNAMEC()
  Protected sFileName.s, bFileFound
  Protected xmlCSRD
  Protected sMsg.s
  Protected *nRootNode
  Protected n, n1, n2, nRemDevId1, nRemDevId2
  
  debugMsg(sProcName, #SCS_START)
  
  With grCSRD
    \nMaxLangItem = -1
    \nMaxRemDev = -1
    \nMaxValidValue = -1
    \nMaxRemDevMsgData = -1
  EndWith
  
  sFileName = gsAppPath + "scs_csrd.scsrd"
  If FileExists(sFileName)
    bFileFound = #True
  Else
    If FindString(sFileName, "scs_v11_curr_development2\Runtime\x64\") > 0
      sFileName = RemoveString(sFileName, "Runtime\x64\")
      If FileExists(sFileName)
        bFileFound = #True
      EndIf
    ElseIf FindString(sFileName, "scs_v11_curr_development2\Runtime\x86\") > 0
      sFileName = RemoveString(sFileName, "Runtime\x86\")
      If FileExists(sFileName)
        bFileFound = #True
      EndIf
    EndIf
  EndIf
  
  If bFileFound = #False
    debugMsg(sProcName, "File scs_csrd.scsrd not found, sFileName=" + #DQUOTE$ + sFileName + #DQUOTE$)
    ProcedureReturn #False
  EndIf
  
  xmlCSRD = LoadXML(#PB_Any, sFileName)
  debugMsg(sProcName, "LoadXML(#PB_Any, " + #DQUOTE$ + sFileName + #DQUOTE$ + ") returned xmlCSRD=" + xmlCSRD)
  
  If xmlCSRD
    ; Display an error message if there was a markup error
    If XMLStatus(xmlCSRD) <> #PB_XML_Success
      sMsg = "Error in the XML file " + GetFilePart(sFileName) + ":" + #CR$
      sMsg + "Message: " + XMLError(xmlCSRD) + #CR$
      sMsg + "Line: " + XMLErrorLine(xmlCSRD) + "   Character: " + XMLErrorPosition(xmlCSRD)
      debugMsg(sProcName, sMsg)
      scsMessageRequester(grText\sTextError, sMsg)
    Else
      *nRootNode = MainXMLNode(xmlCSRD)      
      If *nRootNode
        CSRD_ScanXMLRemDevs(*nRootNode, 0)
      EndIf
    EndIf
    FreeXML(xmlCSRD)
    CSRD_DeriveExtraData()
;     ; Added 17May2025
;     For n = 0 To grCSRD\nMaxRemDev
;       With grCSRD\aRemDev(n)
;         If \nCSRD_DevType = #SCS_DEVTYPE_CS_MIDI_OUT And \sCSRD_DevCode = "BR_X32"
;           nRemDevId1 = \nCSRD_RemDevId
;         ElseIf \nCSRD_DevType = #SCS_DEVTYPE_CS_NETWORK_OUT And \sCSRD_DevCode = "OSC-X32"
;           nRemDevId2 = \nCSRD_RemDevId
;         EndIf
;       EndWith
;     Next n
;     debugMsg0(sProcName, "nRemDevId1=" + nRemDevId1 + ", nRemDevId2=" + nRemDevId2)
;     If nRemDevId1 And nRemDevId2
;       n2 = grCSRD\nMaxRemDevMsgData
;       For n1 = 0 To grCSRD\nMaxRemDevMsgData
;         With grCSRD\aRemDevMsgData(n1)
;           If \nCSRD_RemDevId = nRemDevId2
;             n2 + 1
;             If n2 > ArraySize(grCSRD\aRemDevMsgData())
;               ReDim grCSRD\aRemDevMsgData(n2 + 40)
;             EndIf
;             grCSRD\aRemDevMsgData(n2) = grCSRD\aRemDevMsgData(n1)
;             grCSRD\aRemDevMsgData(n2)\nCSRD_RemDevId = nRemDevId2
;           EndIf
;         EndWith
;       Next n1
;       grCSRD\nMaxRemDevMsgData = n2
;     ; End added 17May2025
;     EndWith
;   Next n
;   
;   For n = 0 To grCSRD\nMaxRemDevMsgData
;     With grCSRD\aRemDevMsgData(n)
; 
;     
    If grCSRD\bLogCSRDArray Or #cTraceCSRD
      CSRD_List() ; list info for debug purposes
    EndIf
    ProcedureReturn #True
  Else
    ProcedureReturn #False
  EndIf

EndProcedure

Procedure CSRD_GetRemDevIdForDevCode(nDevType, sDevCode.s)
  Protected n, nRemDevId
  
  nRemDevId = -1
  For n = 0 To grCSRD\nMaxRemDev
    With grCSRD\aRemDev(n)
      If \nCSRD_DevType = nDevType And \sCSRD_DevCode = sDevCode
        nRemDevId = \nCSRD_RemDevId
        Break
      EndIf
    EndWith
  Next n
;   ; Added 17May2025
;   If nRemDevId = -1
;     If nDevType = #SCS_DEVTYPE_CS_NETWORK_OUT And sDevCode = "OSC-32"
;   For n = 0 To grCSRD\nMaxRemDev
;     With grCSRD\aRemDev(n)
;       If \nCSRD_DevType = nDevType And \sCSRD_DevCode = sDevCode
;         nRemDevId = \nCSRD_RemDevId
;         Break
;       EndIf
;     EndWith
;   Next n
;     EndIf
;   EndIf
;   ; End added 17May2025
  ProcedureReturn nRemDevId
EndProcedure

Procedure CSRD_GetRemDevIdForLogicalDev(nDevType, sLogicalDev.s)
  ; PROCNAMEC()
  Protected sDevCode.s, nRemDevId, d
  
  For d = 0 To grProd\nMaxCtrlSendLogicalDev
    If grProd\aCtrlSendLogicalDevs(d)\sLogicalDev = sLogicalDev
      Select nDevType
        Case #SCS_DEVTYPE_CS_MIDI_OUT
          nRemDevId = grProd\aCtrlSendLogicalDevs(d)\nCtrlMidiRemDevId
          Break
        Case #SCS_DEVTYPE_CS_NETWORK_OUT
          nRemDevId = grProd\aCtrlSendLogicalDevs(d)\nCtrlNetworkRemDevId
          Break
      EndSelect
    EndIf
  Next d
  ; debugMsg0(sProcName, "nDevType=" + decodeDevType(nDevType) + ", sLogicalDev=" + sLogicalDev + ", returning nRemDevId=" + nRemDevId)
  ProcedureReturn nRemDevId
EndProcedure

Procedure CSRD_GetRemDevIndexForRemDevId(nRemDevId)
  Protected n, nRemDevIndex
  
  nRemDevIndex = -1
  For n = 0 To grCSRD\nMaxRemDev
    If grCSRD\aRemDev(n)\nCSRD_RemDevId = nRemDevId
      nRemDevIndex = n
      Break
    EndIf
  Next n
  ProcedureReturn nRemDevIndex
EndProcedure

Procedure.s CSRD_GetRemDevNameForRemDevId(nRemDevId)
  Protected n, sRemDevName.s
  
  For n = 0 To grCSRD\nMaxRemDev
    If grCSRD\aRemDev(n)\nCSRD_RemDevId = nRemDevId
      sRemDevName = grCSRD\aRemDev(n)\sCSRD_DevName
      Break
    EndIf
  Next n
  ProcedureReturn sRemDevName
EndProcedure

Procedure.s CSRD_GetDevCodeForRemDevId(nRemDevId)
  Protected nRemDevIndex, sDevCode.s
  
  nRemDevIndex = CSRD_GetRemDevIndexForRemDevId(nRemDevId)
  If nRemDevIndex >= 0
    sDevCode = grCSRD\aRemDev(nRemDevIndex)\sCSRD_DevCode
  EndIf
  ProcedureReturn sDevCode
EndProcedure

Procedure CSRD_GetDfltMidiChanForRemDevId(nRemDevId)
  Protected nRemDevIndex, nDfltMidiChan
  
  nRemDevIndex = CSRD_GetRemDevIndexForRemDevId(nRemDevId)
  If nRemDevIndex >= 0
    nDfltMidiChan = grCSRD\aRemDev(nRemDevIndex)\nCSRD_DfltMIDIChan
  EndIf
  ProcedureReturn nDfltMidiChan
EndProcedure

Procedure CSRD_EncodeRemDevMsgType(nRemDevId, sRemDevMsgType.s)
  Protected n, nRemDevMsgType
  
  nRemDevMsgType = #SCS_MSGTYPE_NONE ; nb all \nCSRD_RemDevMsgType are extensions of the #SCS_MSGTYPE_... enumeration as they are all used in populating and using WQM\cboMsgType
  For n = 0 To grCSRD\nMaxRemDevMsgData
    With grCSRD\aRemDevMsgData(n)
      If \nCSRD_RemDevId = nRemDevId And \sCSRD_RemDevMsgType = sRemDevMsgType
        nRemDevMsgType = \nCSRD_RemDevMsgType
        Break
      EndIf
    EndWith
  Next n
  ProcedureReturn nRemDevMsgType
EndProcedure

Procedure.s CSRD_DecodeRemDevMsgType(nRemDevMsgType)
  ; PROCNAMEC()
  Protected n, sRemDevMsgType.s
  
  ; debugMsg(sProcName, #SCS_START + ", nRemDevMsgType=" + nRemDevMsgType)
  For n = 0 To grCSRD\nMaxRemDevMsgData
    With grCSRD\aRemDevMsgData(n)
      ; debugMsg(sProcName, "grCSRD\aRemDevMsgData(" + n + ")\nCSRD_RemDevMsgType=" + \nCSRD_RemDevMsgType)
      If \nCSRD_RemDevMsgType = nRemDevMsgType
        sRemDevMsgType = \sCSRD_RemDevMsgType
        Break
      EndIf
    EndWith
  Next n
  ; debugMsg(sProcName, #SCS_END + ", returning " + sRemDevMsgType)
  ProcedureReturn sRemDevMsgType
EndProcedure

Procedure CSRD_GetMaxRemDevMsgType()
  Protected n, nMaxRemDevMsgType
  
  With grCSRD
    nMaxRemDevMsgType = -1
    For n = 0 To \nMaxRemDevMsgData
      If \aRemDevMsgData(n)\nCSRD_RemDevMsgType > nMaxRemDevMsgType
        nMaxRemDevMsgType = \aRemDevMsgData(n)\nCSRD_RemDevMsgType
        ; do NOT break
      EndIf
    Next n
  EndWith
  ProcedureReturn nMaxRemDevMsgType
EndProcedure

Procedure.s CSRD_GetMsgDescForRemDevMsgType(nRemDevMsgType)
  Protected n, sMsgDesc.s
  
  With grCSRD
    For n = 0 To \nMaxRemDevMsgData
      If \aRemDevMsgData(n)\nCSRD_RemDevMsgType = nRemDevMsgType
        sMsgDesc = \aRemDevMsgData(n)\sCSRD_MsgDesc
        Break
      EndIf
    Next n
  EndWith
  ProcedureReturn sMsgDesc
  
EndProcedure

Procedure.s CSRD_GetMsgShortDescForRemDevMsgType(nRemDevMsgType, nAction=#SCS_MUTE_OFF)
  Protected n, sMsgShortDesc.s
  
  With grCSRD
    For n = 0 To \nMaxRemDevMsgData
      If \aRemDevMsgData(n)\nCSRD_RemDevMsgType = nRemDevMsgType
        sMsgShortDesc = \aRemDevMsgData(n)\sCSRD_MsgShortDesc
        If Left(LCase(sMsgShortDesc),4) = "mute"
          If nAction = #SCS_MUTE_ON
            sMsgShortDesc = grText\sTextMute
          Else
            sMsgShortDesc = grText\sTextUnmute
          EndIf
        EndIf
        Break
      EndIf
    Next n
  EndWith
  ProcedureReturn sMsgShortDesc
  
EndProcedure

Procedure CSRD_GetMsgDataPtrForRemDevMsgType(nRemDevMsgType)
  Protected n, nMsgDataPtr
  
  nMsgDataPtr = -1
  With grCSRD
    For n = 0 To \nMaxRemDevMsgData
      If \aRemDevMsgData(n)\nCSRD_RemDevMsgType = nRemDevMsgType
        nMsgDataPtr = n
        Break
      EndIf
    Next n
  EndWith
  ProcedureReturn nMsgDataPtr
  
EndProcedure

Procedure.s CSRD_GetMsgDataForRemDevMsgType(nRemDevMsgType)
  Protected n, sMsgData.s
  
  With grCSRD
    For n = 0 To \nMaxRemDevMsgData
      If \aRemDevMsgData(n)\nCSRD_RemDevMsgType = nRemDevMsgType
        sMsgData = \aRemDevMsgData(n)\sCSRD_MsgData
        Break
      EndIf
    Next n
  EndWith
  ProcedureReturn sMsgData
  
EndProcedure

Procedure CSRD_GetMaxValDataValueForRemDevMsgType(nRemDevMsgType, nValTypeNr)
  ; PROCNAMEC()
  Protected n, nMaxValDataValue
  
  With grCSRD
    For n = 0 To \nMaxRemDevMsgData
      If \aRemDevMsgData(n)\nCSRD_RemDevMsgType = nRemDevMsgType
        If nValTypeNr = 1
          nMaxValDataValue = \aRemDevMsgData(n)\nCSRD_MaxValDataValue
        Else
          nMaxValDataValue = \aRemDevMsgData(n)\nCSRD_MaxValDataValue2
        EndIf
        Break
      EndIf
    Next n
  EndWith
  ProcedureReturn nMaxValDataValue
  
EndProcedure

Procedure.s CSRD_GetValDescForRemDevMsgType(nRemDevMsgType, nValTypeNr)
  ; PROCNAMEC()
  Protected n, sValDesc.s
  
  ; debugMsg(sProcName, "nRemDevMsgType=" + nRemDevMsgType)
  With grCSRD
    For n = 0 To \nMaxRemDevMsgData
      ; debugMsg(sProcName, "grCSRD\aRemDevMsgData(" + n + ")\nCSRD_RemDevMsgType=" + \aRemDevMsgData(n)\nCSRD_RemDevMsgType + ", \sCSRD_ValDesc=" + \aRemDevMsgData(n)\sCSRD_ValDesc)
      If \aRemDevMsgData(n)\nCSRD_RemDevMsgType = nRemDevMsgType
        If nValTypeNr = 1
          sValDesc = \aRemDevMsgData(n)\sCSRD_ValDesc
        Else
          sValDesc = \aRemDevMsgData(n)\sCSRD_ValDesc2
        EndIf
        Break
      EndIf
    Next n
  EndWith
  ProcedureReturn sValDesc
  
EndProcedure

Procedure.s CSRD_GetValTypeForRemDevMsgType(nRemDevMsgType, nValTypeNr)
  Protected n, sValType.s
  
  With grCSRD
    For n = 0 To \nMaxRemDevMsgData
      If \aRemDevMsgData(n)\nCSRD_RemDevMsgType = nRemDevMsgType
        If nValTypeNr = 1
          sValType = \aRemDevMsgData(n)\sCSRD_ValType
        Else
          sValType = \aRemDevMsgData(n)\sCSRD_ValType2
        EndIf
        Break
      EndIf
    Next n
  EndWith
  ProcedureReturn sValType
  
EndProcedure

Procedure CSRD_GetSelectionTypeForRemDevMsgType(nRemDevMsgType)
  Protected n, nSelectionType
  ; See constants #SCS_SELTYPE_... (CSRD Message Value Selection Types)
  
  With grCSRD
    For n = 0 To \nMaxRemDevMsgData
      If \aRemDevMsgData(n)\nCSRD_RemDevMsgType = nRemDevMsgType
        nSelectionType = \aRemDevMsgData(n)\nCSRD_SelectionType
        Break
      EndIf
    Next n
  EndWith
  ProcedureReturn nSelectionType
  
EndProcedure

Procedure CSRD_GetValBaseForRemDevMsgType(nRemDevMsgType, nValTypeNr)
  Protected n, nValBase
  
  With grCSRD
    nValBase = 1 ; this is the default value
    For n = 0 To \nMaxRemDevMsgData
      If \aRemDevMsgData(n)\nCSRD_RemDevMsgType = nRemDevMsgType
        If nValTypeNr = 1
          nValBase = \aRemDevMsgData(n)\nCSRD_ValBase
        Else
          nValBase = \aRemDevMsgData(n)\nCSRD_ValBase2
        EndIf
        Break
      EndIf
    Next n
  EndWith
  ProcedureReturn nValBase
  
EndProcedure

Procedure.s CSRD_GetValDataCodesForRemDevMsgType(nRemDevMsgType, nValTypeNr)
  Protected n, sValDataCodes.s
  
  With grCSRD
    For n = 0 To \nMaxRemDevMsgData
      If \aRemDevMsgData(n)\nCSRD_RemDevMsgType = nRemDevMsgType
        If nValTypeNr = 1
          sValDataCodes = \aRemDevMsgData(n)\sCSRD_ValDataCodes
        Else
          sValDataCodes = \aRemDevMsgData(n)\sCSRD_ValDataCodes2
        EndIf
        Break
      EndIf
    Next n
  EndWith
  ProcedureReturn sValDataCodes
  
EndProcedure

Procedure CSRD_GetValidValueIndexForValType(nRemDevId, sValType.s)
  PROCNAMEC()
  Protected n, nValidValueIndex
  
  nValidValueIndex = -1
  With grCSRD
    For n = 0 To \nMaxValidValue
      If \aValidValue(n)\nCSRD_RemDevId = nRemDevId And \aValidValue(n)\sCSRD_ValType = sValType
        nValidValueIndex = n
        Break
      EndIf
    Next n
  EndWith
  ProcedureReturn nValidValueIndex
EndProcedure

Procedure.f CSRD_GetMinFaderLevelDBForRemDevMsgType(nRemDevMsgType)
  PROCNAMEC()
  Protected n, fMinFaderLevel_dB, nIndex
  
  With grCSRD
    For n = 0 To \nMaxRemDevMsgData
      If \aRemDevMsgData(n)\nCSRD_RemDevMsgType = nRemDevMsgType
        ; get max level in the array (nb the array has been sorted in descending order of fader level, so the minimum level is in the last entry)
        nIndex = \aRemDevMsgData(n)\nCSRD_MaxFaderValue
        fMinFaderLevel_dB = \aRemDevMsgData(n)\aFdrValue(nIndex)\fCSRD_FdrLevel_dB
        Break
      EndIf
    Next n
  EndWith
  ProcedureReturn fMinFaderLevel_dB
  
EndProcedure

Procedure.f CSRD_GetMaxFaderLevelDBForRemDevMsgType(nRemDevMsgType)
  PROCNAMEC()
  Protected n, fMaxFaderLevel_dB.f
  
  With grCSRD
    For n = 0 To \nMaxRemDevMsgData
      If \aRemDevMsgData(n)\nCSRD_RemDevMsgType = nRemDevMsgType
        ; get max level in the array (nb the array has been sorted in descending order of fader level, so the maximum level is in the first entry)
        fMaxFaderLevel_dB = \aRemDevMsgData(n)\aFdrValue(0)\fCSRD_FdrLevel_dB
        Break
      EndIf
    Next n
  EndWith
  ProcedureReturn fMaxFaderLevel_dB
  
EndProcedure

Procedure.f CSRD_convertDBLevelToBVLevelForRemDevMsgType(nRemDevMsgType, fDBLevel.f)
  ; PROCNAMEC()
  ; Convert dB level to 'BASS Volume' (BASS_ATTRIB_VOL) level
  Static nCurrRemDevMsgType, fMinDBLevel.f
  Protected fBVLevel.f
  
  If nCurrRemDevMsgType <> nRemDevMsgType
    fMinDBLevel = CSRD_GetMinFaderLevelDBForRemDevMsgType(nRemDevMsgType)
  EndIf
  
  If fDBLevel <= fMinDBLevel
    fBVLevel = 0.0 ; BASS Volume 'silent'
  Else
    fBVLevel = Pow(10, (fDBLevel / 20))
  EndIf
  ProcedureReturn fBVLevel
EndProcedure

Procedure CSRD_UnpackValData(nValidValueIndex)
  PROCNAMEC()
  Protected sValData.s, sValDataNum.s, nNextValue
  Protected bValDataValid
  Protected nRangeCount, nRangeItem, nReqdArraySize, nArrayIndex
  Protected nPartCount, nPartIndex, sPart.s, nPartLength, nDashCount, sFirst.s, sLast.s, nFirst, nLast
  Protected n, nLeftBracketPos, sPartPrefix.s, nValBase
  Protected bTrace = #False
  
  debugMsgC(sProcName, #SCS_START + ", nValidValueIndex=" + nValidValueIndex)
  
  With grCSRD\aValidValue(nValidValueIndex)
    bValDataValid = #True
    \nCSRD_MaxValDataValue = \nCSRD_ValBase - 1
    nNextValue = 1
    ; sValData = ReplaceString(\sCSRD_ValData, " ", "") ; remove all spaces
    sValData = Trim(\sCSRD_ValData) ; Changed 5Sep2022 11.9.5.1ab
    debugMsgC(sProcName, "sValData=" + sValData)
    If sValData
      nPartCount = CountString(sValData, ",") + 1
      debugMsgC(sProcName, "nPartCount=" + nPartCount)
      For nPartIndex = 1 To nPartCount
        sPart = StringField(sValData, nPartIndex, ",")
        nLeftBracketPos = FindString(sPart, "(")
        If nLeftBracketPos > 1
          sPartPrefix = Left(sPart, nLeftBracketPos-1)
          sPart = Mid(sPart, nLeftBracketPos)
        Else
          sPartPrefix = ""
        EndIf
        nPartLength = Len(sPart)
        debugMsgC(sProcName, "sPartPrefix=" + sPartPrefix + ", sPart=" + sPart + ", nPartLength=" + nPartLength)
        If nPartLength > 2 And Left(sPart, 1) = "(" And Right(sPart, 1) = ")"
          ; leading and trailing brackets indicate a range, eg (1-100).
          ; the brackets are necessary because some single values contain hyphens, eg "(9-10)" means 9 and 10, but "9-10" means the single value 9-10.
          ; now remove the leading and trailing brackets
          sPart = Mid(sPart, 2, nPartLength-2)
          nDashCount = CountString(sPart, "-")
          If nDashCount > 0
            If nDashCount > 1
              bValDataValid = #False
              debugMsg(sProcName, "bValDataValid=#False, nValidValueIndex=" + nValidValueIndex + ", sValData=" + sValData)
              Break
            EndIf
            sFirst = StringField(sPart, 1, "-")
            sLast = StringField(sPart, 2, "-")
            sValDataNum + "," + sFirst + "-" + sLast
          Else
            sFirst = sPart
            sLast = sFirst
            sValDataNum + "," + sFirst
          EndIf
          ; note that ranges MUST be numeric
          If IsNumeric(sFirst) And IsNumeric(sLast)
            nFirst = Val(sFirst)
            nLast = Val(sLast)
            If nFirst > nLast
              bValDataValid = #False
              debugMsg(sProcName, "bValDataValid=#False, nValidValueIndex=" + nValidValueIndex + ", sValData=" + sValData)
              Break
            EndIf
          Else
            ; sFirst or sLast is not numeric
            bValDataValid = #False
            debugMsg(sProcName, "bValDataValid=#False, nValidValueIndex=" + nValidValueIndex + ", sValData=" + sValData)
            Break
          EndIf
          nRangeCount = nLast - nFirst + 1
          nReqdArraySize = \nCSRD_MaxValDataValue + nRangeCount
          If nReqdArraySize > ArraySize(\sValDataValue())
            ReDim \sValDataValue(nReqdArraySize)
          EndIf
          nArrayIndex = \nCSRD_MaxValDataValue
          For n = 0 To nRangeCount - 1
            nRangeItem = nFirst + n
            nArrayIndex + 1
            \sValDataValue(nArrayIndex) = sPartPrefix + Str(nRangeItem)
          Next n
          nNextValue = nLast + 1
          \nCSRD_MaxValDataValue = nArrayIndex
        Else
          ; add a single item to the array (may be a string, eg ST1, or Grp3-4, or 9-10)
          nReqdArraySize = \nCSRD_MaxValDataValue + 1
          If nReqdArraySize > ArraySize(\sValDataValue())
            ReDim \sValDataValue(nReqdArraySize + 5)
          EndIf
          nArrayIndex = \nCSRD_MaxValDataValue + 1
          \sValDataValue(nArrayIndex) = sPart
          sValDataNum + "," + nNextValue
          nNextValue + 1
          \nCSRD_MaxValDataValue = nArrayIndex
        EndIf ; EndIf Len(sPart) > 2 And Left(sPart, 1) = "(" And Right(sPart, 1) = ")" / Else
      Next nPartIndex
      \sCSRD_ValDataNum = Mid(sValDataNum,2) ; ignore leading comma
    EndIf
    
  EndWith
  
  ProcedureReturn bValDataValid
  
EndProcedure

Procedure CSRD_UnpackFaderValues(nFaderDataIndex)
  PROCNAMEC()
  Protected sFdrData.s, nPartCount, nPartIndex, sPart.s, sLevel.s, sValue.s, sByte1.s, sByte2.s, sFdrValFormat.s
  Protected b2ByteDecimalValueD1, b2ByteDecimalValueD2, nValue, nByte1, nByte2
  Protected nArrayIndex, nReqdArraySize, n
  Protected bTrace = #False
  
  debugMsgC(sProcName, #SCS_START + ", nFaderDataIndex=" + nFaderDataIndex)
  
  With grCSRD\aFaderData(nFaderDataIndex)
    \nCSRD_MaxFaderValue = -1
    sFdrValFormat = \sCSRD_FdrValFormat
    Select sFdrValFormat
      Case "D1"
        b2ByteDecimalValueD1 = #True
      Case "D2"
        b2ByteDecimalValueD2 = #True
    EndSelect
    sFdrData = ReplaceString(\sCSRD_FdrData, " ", "") ; remove all spaces
    If sFdrValFormat
      debugMsgC(sProcName, "sFdrValFormat=" + sFdrValFormat + ", sFdrData=" + sFdrData)
    Else
      debugMsgC(sProcName, "sFdrData=" + sFdrData)
    EndIf
    If sFdrData
      nPartCount = CountString(sFdrData, ",") + 1
      debugMsgC(sProcName, "nPartCount=" + nPartCount)
      nReqdArraySize = nPartCount
      If nReqdArraySize > ArraySize(\aFdrValue())
        ReDim \aFdrValue(nReqdArraySize)
      EndIf
      ; debugMsgC(sProcName, "ArraySize(grCSRD\aFaderData(" + nFaderDataIndex + ")\aFdrValue())=" + ArraySize(\aFdrValue()))
      nArrayIndex = -1
      For nPartIndex = 1 To nPartCount
        nArrayIndex + 1
        sPart = StringField(sFdrData, nPartIndex, ",")
        sLevel = StringField(sPart, 1, "=") ; eg +10, -12 (integer only)
        sValue = StringField(sPart, 2, "=") ; in hex, eg 7F, or 7F.7F if two bytes, OR in decimal if b2ByteDecimalValue=#True (see earlier setting of b2ByteDecimalValue)
        If b2ByteDecimalValueD1
          nValue = Val(sValue)
          nByte1 = (nValue >> 7)
          nByte2 = nValue & $7F
          ; debugMsg(sProcName, "sPart=" + sPart + ", sLevel=" + sLevel + ", nValue=" + nValue + ", nByte1=" + nByte1 + ", nByte2=" + nByte2)
        Else
          sByte1 = StringField(sValue, 1, ".")
          sByte2 = StringField(sValue, 2, ".")
          If b2ByteDecimalValueD2
            nByte1 = Val(sByte1)
            nByte2 = Val(sByte2)
          Else
            nByte1 = Val("$"+sByte1)
            If sByte2
              nByte2 = Val("$"+sByte2)
            Else
              nByte2 = 0
            EndIf
          EndIf
          ; debugMsg(sProcName, "sPart=" + sPart + ", sLevel=" + sLevel + ", sValue=" + sValue + ", sByte1=" + sByte1 + ", sByte2=" + sByte2 + ", Val(" + #DQUOTE$ + "$" + #DQUOTE$ + "+" + sByte1 + ")=" + Val("$"+sByte1))
        EndIf
        \aFdrValue(nArrayIndex)\fCSRD_FdrLevel_dB = ValF(sLevel)
        \aFdrValue(nArrayIndex)\nCSRD_FdrLevel_Byte1 = nByte1
        \aFdrValue(nArrayIndex)\nCSRD_FdrLevel_Byte2 = nByte2
      Next nPartIndex
      \nCSRD_MaxFaderValue = nArrayIndex
      If \nCSRD_MaxFaderValue > 1
        SortStructuredArray(\aFdrValue(), #PB_Sort_Descending, OffsetOf(tyCSRD_FaderValue\fCSRD_FdrLevel_dB), #PB_Float, 0, \nCSRD_MaxFaderValue)
      EndIf
      If bTrace
        For n = 0 To \nCSRD_MaxFaderValue
          If \nCSRD_FdrBytes = 1
            debugMsg(sProcName, "grCSRD\aFaderData(" + nFaderDataIndex + ")\aFdrValue(" + n + ")\fCSRD_FdrLevel_dB=" + StrF(\aFdrValue(n)\fCSRD_FdrLevel_dB,2) + ", nCSRD_FdrLevel_Byte1=$" + decToHex2(\aFdrValue(n)\nCSRD_FdrLevel_Byte1))
          Else
            debugMsg(sProcName, "grCSRD\aFaderData(" + nFaderDataIndex + ")\aFdrValue(" + n + ")\fCSRD_FdrLevel_dB=" + StrF(\aFdrValue(n)\fCSRD_FdrLevel_dB,2) +
                                ", nCSRD_FdrLevel_Byte1=$" + decToHex2(\aFdrValue(n)\nCSRD_FdrLevel_Byte1) + ", nCSRD_FdrLevel_Byte2=$" + decToHex2(\aFdrValue(n)\nCSRD_FdrLevel_Byte2))
          EndIf
        Next n
      EndIf
    EndIf ; EndIf sFdrData
  EndWith
  
EndProcedure

Procedure CSRD_SetRemDevUsedInProd()
  PROCNAMEC()
  Protected n1, n2, d, sRemDevCode.s, nRemDevId, nMaxValDataValue
  
  For n1 = 0 To grCSRD\nMaxRemDev
    grCSRD\aRemDev(n1)\bCSRD_RemDevUsedInProd = #False
  Next n1
  
  For d = 0 To grProd\nMaxCtrlSendLogicalDev
    With grProd\aCtrlSendLogicalDevs(d)
      If \sLogicalDev
        sRemDevCode = \sCtrlMidiRemoteDevCode
        If sRemDevCode
          For n1 = 0 To grCSRD\nMaxRemDev
            If grCSRD\aRemDev(n1)\sCSRD_DevCode = sRemDevCode
              grCSRD\aRemDev(n1)\bCSRD_RemDevUsedInProd = #True
              Break
            EndIf
          Next n1
        EndIf
      EndIf
    EndWith
  Next d
  
  With grCSRD
    For n1 = 0 To \nMaxRemDev
      If \aRemDev(n1)\bCSRD_RemDevUsedInProd
        nRemDevId = \aRemDev(n1)\nCSRD_RemDevId
        For n2 = 0 To \nMaxValidValue
          If \aValidValue(n2)\nCSRD_RemDevId = nRemDevId
            If \aValidValue(n2)\nCSRD_MaxValDataValue > nMaxValDataValue
              nMaxValDataValue = \aValidValue(n2)\nCSRD_MaxValDataValue
            EndIf
          EndIf
        Next n2
      EndIf ; EndIf \aRemDev(n1)\bCSRD_RemDevUsedInProd
    Next n1
    If nMaxValDataValue > ArraySize(\bDataValueSelected())
      ReDim \bDataValueSelected(nMaxValDataValue)
    EndIf
    If nMaxValDataValue > ArraySize(\bDataValueSelected2())
      ReDim \bDataValueSelected2(nMaxValDataValue)
    EndIf
  EndWith
  debugMsg(sProcName, "nMaxValDataValue=" + nMaxValDataValue)
  
EndProcedure

Procedure.s CSRD_buildRemDevValue(nRemDevMsgType, nValTypeNr)
  PROCNAMEC()
  Protected n1, n2, sItemString.s, nMaxItemNo, nValBase, bSelected1, bSelected2
  
  ; debugMsg(sProcName, #SCS_START + ", nRemDevMsgType=" + decodeMsgType(nRemDevMsgType) + ", nValTypeNr=" + nValTypeNr)
  
  With grCSRD
    nValBase = CSRD_GetValBaseForRemDevMsgType(nRemDevMsgType, nValTypeNr)
    If nValTypeNr = 1
      nMaxItemNo = \nMaxDataValueIndex
    Else
      nMaxItemNo = \nMaxDataValueIndex2
    EndIf
    ; debugMsg(sProcName, "nValBase=" + nValBase + ", nMaxItemNo=" + nMaxItemNo)
    n1 = nValBase
    While n1 <= nMaxItemNo
      If nValTypeNr = 1
        If \bDataValueSelected(n1)
          n2 = n1 + 1
          While n2 <= nMaxItemNo
            If \bDataValueSelected(n2) = #False
              Break
            EndIf
            n2 + 1
          Wend
          n2 - 1
          If n2 = n1
            sItemString + "," + Str(n1)
          ElseIf n2 = n1 + 1
            sItemString + "," + Str(n1) + "," + Str(n2)
          Else
            sItemString + "," + Str(n1) + "-" + Str(n2)
          EndIf
          n1 = n2 + 1
        Else
          n1 + 1
        EndIf
      ElseIf nValTypeNr = 2
        ; debugMsg(sProcName, "\bDataValueSelected2(n1)=" + strB(\bDataValueSelected2(n1)))
        If \bDataValueSelected2(n1)
          n2 = n1 + 1
          While n2 <= nMaxItemNo
            If \bDataValueSelected2(n2) = #False
              Break
            EndIf
            n2 + 1
          Wend
          n2 - 1
          If n2 = n1
            sItemString + "," + Str(n1)
          ElseIf n2 = n1 + 1
            sItemString + "," + Str(n1) + "," + Str(n2)
          Else
            sItemString + "," + Str(n1) + "-" + Str(n2)
          EndIf
          n1 = n2 + 1
        Else
          n1 + 1
        EndIf
      EndIf
    Wend
  EndWith
  ; debugMsg(sProcName, #SCS_END + ", returning " + #DQUOTE$ + Mid(sItemString, 2) + #DQUOTE$)
  ProcedureReturn Mid(sItemString, 2) ; cut leading ","
  
EndProcedure

Procedure.s CSRD_buildRemDisplayInfoPart(nMsgDataPtr, nPartStart, nPartEnd)
  PROCNAMEC()
  Protected sInfoPart.s
  Protected n1, n2
  
  debugMsg(sProcName, #SCS_START + ", nMsgDataPtr=" + nMsgDataPtr + ", nPartStart=" + nPartStart + ", nPartEnd=" + nPartEnd)
  
  With grCSRD
    ; debugMsg(sProcName, "\aRemDevMsgData(" + nMsgDataPtr + ")\nCSRD_RemDevMsgType=" + CSRD_DecodeRemDevMsgType(\aRemDevMsgData(nMsgDataPtr)\nCSRD_RemDevMsgType))
    n1 = nPartStart
    ; debugMsg0(sProcName, "nValBase=" + nValBase + ", \bDataValueSelected(" + n1 + ")=" + strB(\bDataValueSelected(n1)) + ", ArraySize(\bDataValueSelected())=" + ArraySize(\bDataValueSelected()))
    While n1 <= nPartEnd
      ; debugMsg(sProcName, "n1=" + n1)
      If \bDataValueSelected(n1)
        n2 = n1 + 1
        While n2 <= nPartEnd
          If \bDataValueSelected(n2) = #False
            Break
          EndIf
          n2 + 1
        Wend
        n2 - 1
        ; nb \bDataValueSelected array is 1-based so scanning starts from index 1, but \sValDataValue array is 0-based, eg Ch01 is in index 0
        If n2 = n1
          sInfoPart + "," + \aRemDevMsgData(nMsgDataPtr)\sValDataValue(n1)
        ElseIf n2 = n1 + 1
          ; if only two items in this sequence (eg ch5 and ch6) then use a comma separator, not a dash, eg "ch5,ch6"
          sInfoPart + "," + \aRemDevMsgData(nMsgDataPtr)\sValDataValue(n1) + "," + \aRemDevMsgData(nMsgDataPtr)\sValDataValue(n2)
        Else
          ; if more than two items in this sequence (eg ch5 to ch9) then use a dash separator between the first and last, eg "ch5-ch9"
          sInfoPart + "," + \aRemDevMsgData(nMsgDataPtr)\sValDataValue(n1) + "-" + \aRemDevMsgData(nMsgDataPtr)\sValDataValue(n2)
        EndIf
        ; debugMsg(sProcName, "sInfoPart=" + sInfoPart)
        n1 = n2 + 1
      Else
        n1 + 1
      EndIf
    Wend
  EndWith
  
  ; debugMsg(sProcName, #SCS_END + ", returning " + #DQUOTE$ + sInfoPart + #DQUOTE$)
  ProcedureReturn sInfoPart

EndProcedure

Procedure.s CSRD_buildRemDisplayInfo(nRemDevMsgType, nValTypeNr=1, bUseScribbleStripItemNames=#True)
  PROCNAMEC()
  Protected sDisplayInfo.s, nMsgDataPtr, nSelType
  Protected nMaxItemNo, sValType.s, nValBase, nFirstItemNo, nLastItemNo, sFirstDataValue.s, sLastDataValue.s, sFirstItemName.s, sLastItemName.s
  Protected sValTypeForScribbleStrip.s
  
  debugMsg(sProcName, #SCS_START + ", nRemDevMsgType=" + nRemDevMsgType + ", nValTypeNr=" + nValTypeNr + ", bUseScribbleStripItemNames=" + strB(bUseScribbleStripItemNames))
  
  nMsgDataPtr = CSRD_GetMsgDataPtrForRemDevMsgType(nRemDevMsgType)
  nSelType = CSRD_GetSelectionTypeForRemDevMsgType(nRemDevMsgType)
  
  With grCSRD
    ; debugMsg(sProcName, "nSelType=" + nSelType + ", \aRemDevMsgData(" + nMsgDataPtr + ")\sCSRD_ValType=" + \aRemDevMsgData(nMsgDataPtr)\sCSRD_ValType + ", \sCSRD_ValType2=" + \aRemDevMsgData(nMsgDataPtr)\sCSRD_ValType2)
    \bRemDisplayInfoUsingItemName = #False
    If nValTypeNr = 1
      sValType = \aRemDevMsgData(nMsgDataPtr)\sCSRD_ValType
      nValBase = \aRemDevMsgData(nMsgDataPtr)\nCSRD_ValBase ; nb default = 1, but may be set to 0
      nMaxItemNo = \nMaxDataValueIndex
    Else
      sValType = \aRemDevMsgData(nMsgDataPtr)\sCSRD_ValType2
      nValBase = \aRemDevMsgData(nMsgDataPtr)\nCSRD_ValBase2 ; nb default = 1, but may be set to 0
      nMaxItemNo = \nMaxDataValueIndex2
    EndIf
    If bUseScribbleStripItemNames
      If nSelType = #SCS_SELTYPE_CBO_AND_GRID
        sValTypeForScribbleStrip = \aRemDevMsgData(nMsgDataPtr)\sCSRD_ValType2
      Else
        sValTypeForScribbleStrip = \aRemDevMsgData(nMsgDataPtr)\sCSRD_ValType
      EndIf
    EndIf
    nFirstItemNo = nValBase
    ; debugMsg(sProcName, "nFirstItemNo=" + nFirstItemNo + ", nMaxItemNo=" + nMaxItemNo)
    ; debugMsg(sProcName, "ArraySize(\aRemDevMsgData())=" + ArraySize(\aRemDevMsgData()))
    ; debugMsg(sProcName, "ArraySize(\aRemDevMsgData(" + nMsgDataPtr + ")\sValDataValue())=" + ArraySize(\aRemDevMsgData(nMsgDataPtr)\sValDataValue()))
    While nFirstItemNo <= nMaxItemNo
      If (nValTypeNr = 1 And \bDataValueSelected(nFirstItemNo)) Or (nValTypeNr = 2 And \bDataValueSelected2(nFirstItemNo))
        If nValTypeNr = 1
          sFirstDataValue = \aRemDevMsgData(nMsgDataPtr)\sValDataValue(nFirstItemNo)
        Else
          sFirstDataValue = \aRemDevMsgData(nMsgDataPtr)\sValDataValue2(nFirstItemNo)
        EndIf
        If bUseScribbleStripItemNames
          sFirstItemName = getScribbleStripItemName(@grCurrScribbleStrip, sValTypeForScribbleStrip, nFirstItemNo)
          sLastItemName = sFirstItemName
          If sFirstItemName
            sFirstDataValue = sFirstItemName
            debugMsg(sProcName, "sFirstDataValue=" + sFirstDataValue)
            \bRemDisplayInfoUsingItemName = #True
          EndIf
        EndIf
        If FindString(sFirstDataValue, "-") > 0
          sDisplayInfo + "," + sFirstDataValue
        Else
          nLastItemNo = nFirstItemNo + 1
          While nLastItemNo <= nMaxItemNo
            If (nValTypeNr = 1 And \bDataValueSelected(nLastItemNo) = #False) Or (nValTypeNr = 2 And \bDataValueSelected2(nLastItemNo) = #False)
              Break
            ElseIf bUseScribbleStripItemNames
              sLastItemName = getScribbleStripItemName(@grCurrScribbleStrip, sValTypeForScribbleStrip, nLastItemNo)
              If sLastItemName
                Break
              EndIf
            EndIf
            If nValTypeNr = 1
              If FindString(\aRemDevMsgData(nMsgDataPtr)\sValDataValue(nLastItemNo), "-") > 0
                Break
              EndIf
            Else
              If FindString(\aRemDevMsgData(nMsgDataPtr)\sValDataValue2(nLastItemNo), "-") > 0
                Break
              EndIf
            EndIf
            nLastItemNo + 1
          Wend
          nLastItemNo - 1
          If (nLastItemNo >= (nFirstItemNo + 2)) And (Len(sFirstItemName) = 0 And Len(sLastItemName) = 0)
            If nValTypeNr = 1
              sLastDataValue = \aRemDevMsgData(nMsgDataPtr)\sValDataValue(nLastItemNo)
            Else
              sLastDataValue = \aRemDevMsgData(nMsgDataPtr)\sValDataValue2(nLastItemNo)
            EndIf
            If bUseScribbleStripItemNames
              sLastItemName = getScribbleStripItemName(@grCurrScribbleStrip, sValTypeForScribbleStrip, nLastItemNo)
              If sLastItemName
                sLastDataValue = sLastItemName
              EndIf
            EndIf
            sDisplayInfo + "," + sFirstDataValue + "-" + sLastDataValue
            nFirstItemNo = nLastItemNo
          Else
            sDisplayInfo + "," + sFirstDataValue
          EndIf
        EndIf
      EndIf
      nFirstItemNo + 1
    Wend
  EndWith
  debugMsg(sProcName, #SCS_END + ", returning " + #DQUOTE$ + Mid(sDisplayInfo, 2) + #DQUOTE$)
  ProcedureReturn Mid(sDisplayInfo, 2) ; cut leading ","
  
EndProcedure

Procedure CSRD_buildRemDisplayInfoForCtrlSendItem(*rSub.tySub, nCtrlSendIndex)
  PROCNAMEC()
  Protected sDisplayInfo.s, nSelType, sValType.s, sOldDisplayInfo.s, bChanged, nValTypeItemNr, sValDataCode.s
  Protected sRemDevDisplayInfo1.s
  
  debugMsg(sProcName, #SCS_START + ", *rSub\sSubLabel=" + *rSub\sSubLabel + ", nCtrlSendIndex=" + nCtrlSendIndex)
  
  With *rSub.tySub\aCtrlSend[nCtrlSendIndex]
    sOldDisplayInfo = \sDisplayInfo
    ; debugMsg(sProcName, "\nRemDevMsgType=" + \nRemDevMsgType + ", \sRemDevMsgType=" + \sRemDevMsgType + ", \nRemDevMuteAction=" + \nRemDevMuteAction + ", sDisplayInfo=" + #DQUOTE$ + sDisplayInfo + #DQUOTE$)
    grCSRD\nMaxDataValueIndex = CSRD_GetMaxValDataValueForRemDevMsgType(\nRemDevMsgType, 1)
    ; debugMsg(sProcName, "grCSRD\nMaxDataValueIndex=" + grCSRD\nMaxDataValueIndex)
    CSRD_populateArrayDataValueSelected(\sRemDevValue, 1)
    nSelType = CSRD_GetSelectionTypeForRemDevMsgType(\nRemDevMsgType)
    sRemDevDisplayInfo1 = CSRD_buildRemDisplayInfo(\nRemDevMsgType, 1) ; NB sets bRemDisplayInfoUsingItemName #True or #False, essential for the following test
    debugMsg(sProcName, "sRemDevDisplayInfo1=" + sRemDevDisplayInfo1)
    Select \nOSCCmdType
      Case #SCS_CS_OSC_MUTEAUXIN, #SCS_CS_OSC_MUTEBUS, #SCS_CS_OSC_MUTECHANNEL, #SCS_CS_OSC_MUTEDCAGROUP, #SCS_CS_OSC_MUTEFXRTN, #SCS_CS_OSC_MUTEMATRIX, #SCS_CS_OSC_MUTEMG
        grCSRD\bRemDisplayInfoUsingItemName = #False
      Case #SCS_CS_OSC_AUXINLEVEL, #SCS_CS_OSC_BUSLEVEL, #SCS_CS_OSC_CHANNELLEVEL, #SCS_CS_OSC_DCALEVEL, #SCS_CS_OSC_FXRTNLEVEL, #SCS_CS_OSC_MATRIXLEVEL
        grCSRD\bRemDisplayInfoUsingItemName = #False
    EndSelect
    If grCSRD\bRemDisplayInfoUsingItemName ; Set by CSRD_buildRemDisplayInfo()
      sDisplayInfo = decodeMsgTypeL(\nRemDevMsgType) + " "
    Else
      sDisplayInfo = decodeMsgTypeShortL(\nRemDevMsgType, \nRemDevMuteAction) + " "
    EndIf
    debugMsg(sProcName, "sDisplayInfo=" + #DQUOTE$ + sDisplayInfo + #DQUOTE$)
    Select nSelType
      Case #SCS_SELTYPE_GRID
        debugMsg(sProcName, "#SCS_SELTYPE_GRID")
        ; NOTE: Multiple values may be selected from a grid (WQM\grdRemDevItem). This is the default selection type.
        sDisplayInfo + CSRD_buildRemDisplayInfo(\nRemDevMsgType, 1)
    debugMsg(sProcName, "sDisplayInfo=" + #DQUOTE$ + sDisplayInfo + #DQUOTE$)
        
      Case #SCS_SELTYPE_CBO
        debugMsg(sProcName, "#SCS_SELTYPE_CBO")
        ; NOTE: Only one value may be chosen from a combobox (WQM\cboRemDevCboItem)
        sDisplayInfo + sRemDevDisplayInfo1
        
      Case #SCS_SELTYPE_FADER, #SCS_SELTYPE_FADER_AND_GRID
        debugMsg(sProcName, "#SCS_SELTYPE_FADER_AND_GRID")
        ; NOTE: Fader, or Fader and Grid
        If \sRemDevLevel
          sDisplayInfo + \sRemDevLevel + "dB "
        EndIf
        sDisplayInfo + sRemDevDisplayInfo1
        
      Case #SCS_SELTYPE_CBO_FADER_AND_GRID
        debugMsg(sProcName, "#SCS_SELTYPE_CBO_FADER_AND_GRID")
        ; NOTE: Combobox, fader and grid (eg combobox for FX send, such as FX1-FX4, fader for FX send level, and grid for channel)
        grCSRD\nMaxDataValueIndex2 = CSRD_GetMaxValDataValueForRemDevMsgType(\nRemDevMsgType, 2)
        CSRD_populateArrayDataValueSelected(\sRemDevValue2, 2)
        sDisplayInfo + sRemDevDisplayInfo1 + " "
        If \sRemDevLevel
          sDisplayInfo + \sRemDevLevel + "dB "
        EndIf
        sDisplayInfo + CSRD_buildRemDisplayInfo(\nRemDevMsgType, 2)
        
      Case #SCS_SELTYPE_CBO_AND_GRID
        debugMsg(sProcName, "#SCS_SELTYPE_CBO_AND_GRID")
        ; NOTE: Combobox and grid
        ; get info initially derived from the combobox
        sValType = CSRD_GetValTypeForRemDevMsgType(\nRemDevMsgType, 1)
        sValDataCode = CSRD_getValDataCodeForValTypeItemNr(\nRemDevId, sValType, \sRemDevValue)
        sDisplayInfo + sValDataCode + " "
    debugMsg(sProcName, "sDisplayInfo=" + #DQUOTE$ + sDisplayInfo + #DQUOTE$)
        If IsInteger(sValType) = #False
          nValTypeItemNr = CSRD_getValTypeItemNrForDataCode(\nRemDevMsgType, 1, sValDataCode)
          sValType = Str(nValTypeItemNr)
        EndIf
        sDisplayInfo + sRemDevDisplayInfo1
    debugMsg(sProcName, "sDisplayInfo=" + #DQUOTE$ + sDisplayInfo + #DQUOTE$)
        ; append to this the info initially derived from the grid
        grCSRD\nMaxDataValueIndex2 = CSRD_GetMaxValDataValueForRemDevMsgType(\nRemDevMsgType, 2)
        CSRD_populateArrayDataValueSelected(\sRemDevValue2, 2)
;         sDisplayInfo + CSRD_buildRemDisplayInfo(\nRemDevMsgType, 2)
;     debugMsg(sProcName, "sDisplayInfo=" + #DQUOTE$ + sDisplayInfo + #DQUOTE$)
        
      Case #SCS_SELTYPE_NONE
        debugMsg(sProcName, "#SCS_SELTYPE_NONE")
        ; NOTE: No value may be chosen as the message type provides a fixed 'value' (eg MuteLR can only mute LR)
        sDisplayInfo + sRemDevDisplayInfo1
        
      Default
        debugMsg(sProcName, "DEFAULT (nSelType=" + nSelType + ")")
        
    EndSelect
    \sDisplayInfo = Trim(sDisplayInfo)
    debugMsg(sProcName, "\sDisplayInfo=" + #DQUOTE$ + \sDisplayInfo + #DQUOTE$)
    If \sDisplayInfo <> sOldDisplayInfo
      bChanged = #True
    EndIf
  EndWith
  
  debugMsg(sProcName, #SCS_END + ", returned bChanged=" + strB(bChanged))
  ProcedureReturn bChanged

EndProcedure

Procedure CSRD_populateArrayDataValueSelected(sRemDevValue.s, nValTypeNr, nRemDevMsgType=-1)
  PROCNAMEC()
  Protected bDataValuesArrayValid, nDataValuesCount
  Protected n
  Protected sWorkList.s
  Protected nPartCount, nPartIndex, sPart.s, nDashCount, nDashPos, sFirst.s, sLast.s, nFirst, nLast, nMaxItemNo
  Protected nValBase, sValDataCodes.s
  Protected bTrace = #False
  
  ; debugMsg(sProcName, #SCS_START + ", sRemDevValue=" + #DQUOTE$ + sRemDevValue + #DQUOTE$ + ", nValTypeNr=" + nValTypeNr + ", nRemDevMsgType=" + nRemDevMsgType)
  
  CSRD_clearDataValueSelectedArray(nValTypeNr)
  
  With grCSRD
    If nValTypeNr = 1
      nMaxItemNo = \nMaxDataValueIndex
      If nMaxItemNo > ArraySize(\bDataValueSelected())
        ReDim \bDataValueSelected(nMaxItemNo)
      EndIf
      For n = 0 To ArraySize(\bDataValueSelected())
        \bDataValueSelected(n) = #False
      Next n
    Else
      nMaxItemNo = \nMaxDataValueIndex2
      If nMaxItemNo > ArraySize(\bDataValueSelected2())
        ReDim \bDataValueSelected2(nMaxItemNo)
      EndIf
      For n = 0 To ArraySize(\bDataValueSelected2())
        \bDataValueSelected2(n) = #False
      Next n
    EndIf
    sWorkList = ReplaceString(sRemDevValue, " ", "") ; remove all spaces
    bDataValuesArrayValid = #True
    If sWorkList
      nPartCount = CountString(sWorkList, ",") + 1
      For nPartIndex = 1 To nPartCount
        sPart = StringField(sWorkList, nPartIndex, ",")
        nDashCount = CountString(sPart, "-")
        If nDashCount > 0
          If nDashCount > 1
            bDataValuesArrayValid = #False
            Break
          EndIf
          nDashPos = FindString(sPart, "-")
          sFirst = StringField(sPart, 1, "-")
          sLast = StringField(sPart, 2, "-")
        Else
          sFirst = sPart
          sLast = ""
        EndIf
        If IsInteger(sFirst)
          nFirst = Val(sFirst)
        ElseIf nRemDevMsgType >= 0
          sValDataCodes = CSRD_GetValDataCodesForRemDevMsgType(nRemDevMsgType, nValTypeNr)
          nFirst = 1
        EndIf
        ; debugMsg(sProcName, "sWorkList=" + #DQUOTE$ + sWorkList + #DQUOTE$ + ", nPartIndex=" + nPartIndex + ", sPart=" + sPart + ", sFirst=" + sFirst + ", sLast=" + sLast + ", nFirst=" + nFirst + ", nValBase=" + nValBase + ", nMaxItemNo=" + nMaxItemNo)
        If nFirst < nValBase Or nFirst > nMaxItemNo
          bDataValuesArrayValid = #False
          Break
        EndIf
        If sLast
          nLast = Val(sLast)
          If nLast < nValBase Or nLast > nMaxItemNo Or nLast < nFirst
            bDataValuesArrayValid = #False
            Break
          EndIf
          For n = nFirst To nLast
            If nValTypeNr = 1
              \bDataValueSelected(n) = #True
              debugMsgC(sProcName, "\bDataValueSelected(" + n + ")=" + strB(\bDataValueSelected(n)))
            Else
              \bDataValueSelected2(n) = #True
              debugMsgC(sProcName, "\bDataValueSelected2(" + n + ")=" + strB(\bDataValueSelected2(n)))
            EndIf
            nDataValuesCount + 1
          Next n
        Else
          If nValTypeNr = 1
            \bDataValueSelected(nFirst) = #True
            debugMsgC(sProcName, "\bDataValueSelected(" + nFirst + ")=" + strB(\bDataValueSelected(nFirst)))
          Else
            \bDataValueSelected2(nFirst) = #True
            debugMsgC(sProcName, "\bDataValueSelected2(" + nFirst + ")=" + strB(\bDataValueSelected2(nFirst)))
          EndIf
          nDataValuesCount + 1
        EndIf
      Next nPartIndex
    EndIf
  EndWith
  
  If bDataValuesArrayValid = #False
    nDataValuesCount = -1
  EndIf
  debugMsgC(sProcName, #SCS_END + ", returning nDataValuesCount=" + nDataValuesCount)
  ProcedureReturn nDataValuesCount
EndProcedure

Procedure CSRD_SelectDataValuesForCtrlSend(pSubPtr, nCtrlSendIndex, nValTypeNr)
  PROCNAMECS(pSubPtr)
  Protected nMsgDataPtr, nMaxDataValue, nValidValueIndex
  Protected sValType.s, sValDataNum.s, sRemDevValue.s
  Protected nDataValuesCount
  
  ; debugMsg(sProcName, #SCS_START + ", nCtrlSendIndex=" + nCtrlSendIndex)
  
  If pSubPtr >= 0 And nCtrlSendIndex >= 0
    With aSub(pSubPtr)\aCtrlSend[nCtrlSendIndex]
      nMsgDataPtr = CSRD_GetMsgDataPtrForRemDevMsgType(\nRemDevMsgType)
      If nMsgDataPtr >= 0
        If nValTypeNr = 1
          sValType = grCSRD\aRemDevMsgData(nMsgDataPtr)\sCSRD_ValType
          sRemDevValue = \sRemDevValue
        Else
          sValType = grCSRD\aRemDevMsgData(nMsgDataPtr)\sCSRD_ValType2
          sRemDevValue = \sRemDevValue2
        EndIf
        nValidValueIndex = CSRD_GetValidValueIndexForValType(\nRemDevId, sValType)
        If nValidValueIndex >= 0
          nMaxDataValue = grCSRD\aValidValue(nValidValueIndex)\nCSRD_MaxValDataValue
        EndIf
        sValDataNum = RemoveString(RemoveString(sRemDevValue, "("), ")")
      EndIf
      If sValDataNum And nMaxDataValue >= 0
        If nValTypeNr = 1
          grCSRD\nMaxDataValueIndex = nMaxDataValue
        Else
          grCSRD\nMaxDataValueIndex2 = nMaxDataValue
        EndIf
        nDataValuesCount = CSRD_populateArrayDataValueSelected(sValDataNum, nValTypeNr)
        If nDataValuesCount < 0
          debugMsg(sProcName, "CSRD_populateArrayDataValueSelected(" + #DQUOTE$ + sValDataNum + #DQUOTE$ + ") returned " + nDataValuesCount + ", nCtrlSendIndex=" + nCtrlSendIndex + ", grCSRD\nMaxDataValueIndex=" + grCSRD\nMaxDataValueIndex)
        EndIf
      EndIf
    EndWith
  EndIf
  ProcedureReturn nDataValuesCount
  
EndProcedure

Procedure CSRD_clearDataValueSelectedArray(nValTypeNr)
  ; PROCNAMEC()
  Protected n
  
  With grCSRD
    ; debugMsg(sProcName, "ArraySize(grCSRD\bDataValueSelected())=" + ArraySize(\bDataValueSelected()))
    If nValTypeNr = 1
      For n = 0 To ArraySize(\bDataValueSelected())
        \bDataValueSelected(n) = #False
      Next n
    Else
      For n = 0 To ArraySize(\bDataValueSelected2())
        \bDataValueSelected2(n) = #False
      Next n
    EndIf
  EndWith
  
EndProcedure

Procedure.s CSRD_GetFdrTypeForRemDevMsgType(nRemDevMsgType)
  Protected n, sFdrType.s
  
  With grCSRD
    For n = 0 To \nMaxRemDevMsgData
      If \aRemDevMsgData(n)\nCSRD_RemDevMsgType = nRemDevMsgType
        sFdrType = \aRemDevMsgData(n)\sCSRD_FdrType
        Break
      EndIf
    Next n
  EndWith
  ProcedureReturn sFdrType
  
EndProcedure

Procedure.s CSRD_GetFdrDataForRemDevMsgType(nRemDevMsgType)
  Protected n, sFdrData.s
  
  With grCSRD
    For n = 0 To \nMaxRemDevMsgData
      If \aRemDevMsgData(n)\nCSRD_RemDevMsgType = nRemDevMsgType
        sFdrData = \aRemDevMsgData(n)\sCSRD_FdrData
        Break
      EndIf
    Next n
  EndWith
  ProcedureReturn sFdrData
  
EndProcedure

Procedure CSRD_GetOSCCmdTypeForRemDevMsgType(nRemDevMsgType)
  PROCNAMEC()
  Protected n, nOSCCmdType
  
  With grCSRD
    For n = 0 To \nMaxRemDevMsgData
      If \aRemDevMsgData(n)\nCSRD_RemDevMsgType = nRemDevMsgType
        nOSCCmdType = \aRemDevMsgData(n)\nCSRD_OSCCmdType
        debugMsg(sProcName, "n=" + n + ", nOSCCmdType=" + nOSCCmdType)
        Break
      EndIf
    Next n
  EndWith
  debugMsg(sProcName, "nRemDevMsgType=" + nRemDevMsgType + ", nOSCCmdType=" + nOSCCmdType)
  ProcedureReturn nOSCCmdType
  
EndProcedure

Procedure.s CSRD_GetFdrDescForRemDevMsgType(nRemDevMsgType)
  ; PROCNAMEC()
  Protected n, sFdrDesc.s
  
  ; debugMsg(sProcName, "nRemDevMsgType=" + nRemDevMsgType)
  With grCSRD
    For n = 0 To \nMaxRemDevMsgData
      ; debugMsg(sProcName, "grCSRD\aRemDevMsgData(" + n + ")\nCSRD_RemDevMsgType=" + \aRemDevMsgData(n)\nCSRD_RemDevMsgType + ", \sCSRD_FdrDesc=" + \aRemDevMsgData(n)\sCSRD_FdrDesc)
      If \aRemDevMsgData(n)\nCSRD_RemDevMsgType = nRemDevMsgType
        sFdrDesc = \aRemDevMsgData(n)\sCSRD_FdrDesc
        Break
      EndIf
    Next n
  EndWith
  ProcedureReturn sFdrDesc
  
EndProcedure

Procedure.a CSRD_GetFaderValueByteForRemDevMsgType(nRemDevMsgType, fFaderValue.f, nByteNo)
  PROCNAMEC()
  Protected n1, n2, nFaderValueByte.a, nMaxIndex
  Protected fPrevLevel.f, fThisLevel.f, nThisBytesValue, nPrevBytesValue, nReqdBytesValue, fDiffFactor.f
  Protected fMinLevelInArray.f, fMaxLevelInArray.f, bFound, bTrace = #False
  ; NOTE: All value bytes are 7-bit only, ie range 0-127. Hence use of << 7, etc, not << 8. Critical when handling 2-byte values, as for A&H SQ series fader levels.
  
  debugMsgC(sProcName, #SCS_START + ", nRemDevMsgType=" + nRemDevMsgType + ", fFaderValue=" + StrF(fFaderValue,2) + ", nByteNo=" + nByteNo)
  
  For n1 = 0 To grCSRD\nMaxRemDevMsgData
    With grCSRD\aRemDevMsgData(n1)
      If \nCSRD_RemDevMsgType = nRemDevMsgType
        nMaxIndex = \nCSRD_MaxFaderValue
        If nMaxIndex >= 0 ; should be #True
          ; get min and max levels in the array (nb the array has been sorted in descending order of fader level, so the maximum level is in the first entry)
          fMaxLevelInArray = \aFdrValue(0)\fCSRD_FdrLevel_dB
          fMinLevelInArray = \aFdrValue(nMaxIndex)\fCSRD_FdrLevel_dB
          ; debugMsg(sProcName, "fMinLevelInArray=" + StrF(fMinLevelInArray,2) + ", fMaxLevelInArray=" + StrF(fMaxLevelInArray,2))
          If fFaderValue >= fMaxLevelInArray
            ; eg fFaderValue = +12dB but max in array is +10dB, so use byte values for +10dB
            debugMsgC(sProcName, "grCSRD\aRemDevMsgData(" + n1 + ")\aFdrValue(0)\fCSRD_FdrLevel_dB=" + \aFdrValue(0)\fCSRD_FdrLevel_dB +
                                 ", \aFdrValue(0)\nCSRD_FdrLevel_Byte1=" + \aFdrValue(0)\nCSRD_FdrLevel_Byte1 + ", \aFdrValue(0)\nCSRD_FdrLevel_Byte2=" + \aFdrValue(0)\nCSRD_FdrLevel_Byte2)
            nReqdBytesValue = (\aFdrValue(0)\nCSRD_FdrLevel_Byte1 << 7) + \aFdrValue(0)\nCSRD_FdrLevel_Byte2
            debugMsgC(sProcName, "grCSRD\aRemDevMsgData(" + n1 + ")\aFdrValue(0)\fCSRD_FdrLevel_dB=" + \aFdrValue(0)\fCSRD_FdrLevel_dB +
                                 ", \aFdrValue(0)\nCSRD_FdrLevel_Byte1=" + \aFdrValue(0)\nCSRD_FdrLevel_Byte1 + ", \aFdrValue(0)\nCSRD_FdrLevel_Byte2=" + \aFdrValue(0)\nCSRD_FdrLevel_Byte2 +
                                 ", nReqdBytesValue=" + nReqdBytesValue)
            bFound = #True
          ElseIf fFaderValue < fMinLevelInArray
            ; eg fFaderValue = -INF or -75dB but min in array is -60dB, so use 0 (which always means -INF)
            nReqdBytesValue = 0
            bFound = #True
          EndIf
          If bFound = #False
            For n2 = 0 To \nCSRD_MaxFaderValue
              fThisLevel = \aFdrValue(n2)\fCSRD_FdrLevel_dB
              If fThisLevel <= fFaderValue
                nThisBytesValue = (\aFdrValue(n2)\nCSRD_FdrLevel_Byte1 << 7) + \aFdrValue(n2)\nCSRD_FdrLevel_Byte2
                If fThisLevel = fFaderValue Or n2 = 0
                  nReqdBytesValue = nThisBytesValue
                Else ; fThisLevel < fFaderLevel and n2 > 0
                  fPrevLevel = \aFdrValue(n2-1)\fCSRD_FdrLevel_dB
                  nPrevBytesValue = (\aFdrValue(n2-1)\nCSRD_FdrLevel_Byte1 << 7) + \aFdrValue(n2-1)\nCSRD_FdrLevel_Byte2
                  fDiffFactor = (fFaderValue - fThisLevel) / (fPrevLevel - fThisLevel)
                  nReqdBytesValue = nThisBytesValue + ((nPrevBytesValue - nThisBytesValue) * fDiffFactor)
                  debugMsgC(sProcName, "fPrevLevel=" + StrF(fPrevLevel,2) + ", fThisLevel=" + StrF(fThisLevel,2) + ", fDiffFactor=" + StrF(fDiffFactor,2) + ", nReqdBytesValue=" + nReqdBytesValue)
                EndIf
                Break 2 ; Break n2 and n1
              EndIf ; EndIf fThisLevel <= fFaderValue
            Next n2
          EndIf ; EndIf bFound = #False
        EndIf ; EndIf nMaxIndex >= 0
        Break ; Break n1
      EndIf ; EndIf \nCSRD_RemDevMsgType = nRemDevMsgType
    Next n1
  EndWith
  If nByteNo = 1
    nFaderValueByte = nReqdBytesValue >> 7
  Else
    nFaderValueByte = nReqdBytesValue & $7F
  EndIf
  debugMsgC(sProcName, #SCS_END + ", returning nFaderValueByte=" + nFaderValueByte)
  ProcedureReturn nFaderValueByte
  
EndProcedure

Procedure CSRD_GetSSValCountForRemDevId(nRemDevId)
  PROCNAMEC()
  Protected n, nSSValCount
  
  With grCSRD
    For n = 0 To \nMaxRemDevMsgData
      If \aRemDevMsgData(n)\nCSRD_RemDevId = nRemDevId
        If \aRemDevMsgData(n)\bCSRD_ValSS
          nSSValCount + 1
        EndIf
      EndIf
    Next n
    ; debugMsg(sProcName, "grCSRD\nMaxRemDevMsgData=" + \nMaxRemDevMsgData + ", nRemDevId=" + nRemDevId + ", nSSValCount=" + nSSValCount)
  EndWith
  ProcedureReturn nSSValCount
  
EndProcedure

Procedure.s CSRD_GetNextPart(sString.s, nStartPos)
  PROCNAMEC()
  Protected sNextPart.s, nPos, nStringLength, sChar.s
  
  nStringLength = Len(sString)
  For nPos = nStartPos To nStringLength
    sChar = Mid(sString, nPos, 1)
    Select sChar
      Case " ", "+", "-", "*", "/", "%", "~" , "#" ; Added "%" 8Apr2022 11.9.1az following forum bug report from 'SchauSbg' ; Added "~" 22Aug2022 11.9.5 ; Added "#" 1Sep2022 11.9.5.1
        Break
    EndSelect
    sNextPart + sChar
  Next nPos
  ProcedureReturn sNextPart
EndProcedure

Procedure.s CSRD_convertStringsToHexStrings(sDataString.s)
  ; Added 3Sep2022 11.9.5.1ab
  PROCNAMEC()
  ; Converts something like:
  ;    "/dca/"$S1"/config/color/"$S2
  ; to:
  ;    2F 64 63 61 2F $S1 2F 63 6F 6E 66 69 67 2F 63 6F 6C 6F 72 2F $S2
  ; Designed for converting CSRD MsgData to hex where it contains meaningful strings
  Protected n, sChar.s, sPrevChar.s, bInString
  Protected sHexString.s
  
  For n = 1 To Len(sDataString)
    sPrevChar = sChar
    sChar = Mid(sDataString, n, 1)
    If sChar = #DQUOTE$
      If bInString
        bInString = #False
      Else
        bInString = #True
        If sPrevChar <> #DQUOTE$
          sHexString + " "
        EndIf
      EndIf
      Continue
    EndIf
    If bInString
      sHexString + Right("0" + Hex(Asc(sChar)), 2) + " "
    Else
      sHexString + sChar
    EndIf
  Next n
  
  ProcedureReturn Trim(sHexString)
  
EndProcedure

Procedure.s CSRD_getValDataCodeForValTypeItemNr(nRemDevId, sValType.s, sRemDevValue.s)
  PROCNAMEC()
  ; EG if ValidValues contains "OFF,RD,GN,YE,BL,MG,CY,WH,OFFi,RDi,GNi,YEi,BLi,MGi,CYi,WHi" for a specific ValType then procedure returns "GN" if sRemDevValue = "3"
  Protected n, sValDataCodeForItemNr.s, nItemNr, sDataCode.s
  
  sValDataCodeForItemNr = sRemDevValue
  If IsInteger(sRemDevValue)
    nItemNr = Val(sRemDevValue)
    If nItemNr > 0
      For n = 0 To grCSRD\nMaxValidValue
        With grCSRD\aValidValue(n)
          If \nCSRD_RemDevId = nRemDevId
            If \sCSRD_ValType = sValType
              sDataCode = Trim(StringField(\sCSRD_ValDataCodes, nItemNr, ","))
              If sDataCode
                ; only set sValDataCodeForItemNr if a code is found for this item number
                sValDataCodeForItemNr = sDataCode
              EndIf
              Break
            EndIf
          EndIf
        EndWith
      Next n
    EndIf
  EndIf
  ProcedureReturn sValDataCodeForItemNr
  
EndProcedure

Procedure CSRD_getValTypeItemNrForDataCode(nRemDevMsgType, nValTypeNr, sDataCode.s)
  PROCNAMEC()
  ; EG if ValidValues contains "OFF,RD,GN,YE,BL,MG,CY,WH,OFFi,RDi,GNi,YEi,BLi,MGi,CYi,WHi" for a specific ValType then procedure returns 3 if sRemDevValue = "GN"
  Protected sValDataCodes.s
  Protected n, nItemNr, nMaxItemNr, nReqdItemNr
  
  With grCSRD
    For n = 0 To \nMaxRemDevMsgData
      If \aRemDevMsgData(n)\nCSRD_RemDevMsgType = nRemDevMsgType
        If nValTypeNr = 1
          sValDataCodes = \aRemDevMsgData(n)\sCSRD_ValDataCodes
        Else
          sValDataCodes = \aRemDevMsgData(n)\sCSRD_ValDataCodes2
        EndIf
        Break
      EndIf
    Next n
  EndWith
  
  nMaxItemNr = CountString(sValDataCodes, ",") + 1
  For nItemNr = 1 To nMaxItemNr
    If Trim(StringField(sValDataCodes, nItemNr, ",")) = sDataCode
      nReqdItemNr = nItemNr
      Break
    EndIf
  Next nItemNr
  ProcedureReturn nReqdItemNr
  
EndProcedure

Procedure CSRD_convertPreRemDevX32CtrlSendCuesToRemDev()
  PROCNAMEC()
  Protected i, j
  Protected nCtrlSendIndex, sTemp.s, bMuteCommand
  
  debugMsg(sProcName, #SCS_START)
  
  For i = 1 To gnLastCue
    If aCue(i)\bSubTypeM
      j = aCue(i)\nFirstSubIndex
      While j >= 0
        If aSub(j)\bSubTypeM
          For nCtrlSendIndex = 0 To #SCS_MAX_CTRL_SEND
            With aSub(j)\aCtrlSend[nCtrlSendIndex]
              If \bIsOSC
                If Len(\sRemDevMsgType) = 0
                  debugMsg(sProcName, getSubLabel(j) + ": \aCtrlSend[" + nCtrlSendIndex + "]\nRemDevId=" + \nRemDevId)
                  If \nRemDevId = 0
                    \nRemDevId = CSRD_GetRemDevIdForLogicalDev(\nDevType, \sCSLogicalDev)
                    debugMsg(sProcName, getSubLabel(j) + ": \aCtrlSend[" + nCtrlSendIndex + "]\nRemDevId=" + \nRemDevId)
                  EndIf
                  Select \nOSCCmdType
                    Case #SCS_CS_OSC_MUTEAUXIN    : \sRemDevMsgType = "MuteAuxIn"   : bMuteCommand = #True
                    Case #SCS_CS_OSC_MUTEBUS      : \sRemDevMsgType = "MuteBus"     : bMuteCommand = #True
                    Case #SCS_CS_OSC_MUTECHANNEL  : \sRemDevMsgType = "MuteCh"      : bMuteCommand = #True
                    Case #SCS_CS_OSC_MUTEDCAGROUP : \sRemDevMsgType = "MuteDCA"     : bMuteCommand = #True
                    Case #SCS_CS_OSC_MUTEFXRTN    : \sRemDevMsgType = "MuteFXRtn"   : bMuteCommand = #True
                    Case #SCS_CS_OSC_MUTEMAINLR   : \sRemDevMsgType = "MuteLR"      : bMuteCommand = #True
                    Case #SCS_CS_OSC_MUTEMAINMC   : \sRemDevMsgType = "MuteMC"      : bMuteCommand = #True
                    Case #SCS_CS_OSC_MUTEMATRIX   : \sRemDevMsgType = "MuteMtx"     : bMuteCommand = #True
                    Case #SCS_CS_OSC_MUTEMG       : \sRemDevMsgType = "MuteMuteGrp" : bMuteCommand = #True
                  EndSelect
                  debugMsg(sProcName,  getSubLabel(j) + ": \nOSCCmdType=" + \nOSCCmdType + " (" + decodeOSCCmdType(\nOSCCmdType) + "), \sRemDevMsgType=" + \sRemDevMsgType)
                  If bMuteCommand
                    If \nRemDevId > 0 ; should be #True
                      \nRemDevMsgType = CSRD_EncodeRemDevMsgType(\nRemDevId, \sRemDevMsgType)
                      \nRemDevMuteAction = \nOSCMuteAction
                      \sRemDevValue = Str(\nOSCItemNr)
                      debugMsg(sProcName, "aSub(" + getSubLabel(j) + ")\aCtrlSend[" + nCtrlSendIndex + "]\nRemDevMsgType=" + \nRemDevMsgType + " (" + CSRD_DecodeRemDevMsgType(\nRemDevMsgType) +
                                          "), \nRemDevMuteAction=" + \nRemDevMuteAction + ", \sRemDevValue=" + \sRemDevValue)
                    EndIf
                  EndIf
                EndIf
              EndIf
            EndWith
          Next nCtrlSendIndex
        EndIf
        j = aSub(j)\nNextSubIndex
      Wend
    EndIf
  Next i
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

; EOF