; File: HTTPControl.pbi

; uses \http-1.0.2\http.pbi

EnableExplicit

Procedure buildHTTPDevDesc(*pHTTPControl.tyHTTPControl)
  PROCNAMEC()
  
  With *pHTTPControl
    \sHTTPDevDesc = Lang("DevType", "HTTPRequest")
  EndWith
  
EndProcedure

Procedure.s buildHTTPSendString(pSubPtr, nCtrlSendIndex, bPrimaryFile=#True)
  PROCNAMECS(pSubPtr)
  Protected nDevMapDevPtr
  Protected sMsg.s
  Protected d
  
  ; debugMsg(sProcName, #SCS_START + ", nCtrlSendIndex=" + nCtrlSendIndex + ", bPrimaryFile=" + strB(bPrimaryFile))
  
  If pSubPtr >= 0
    If bPrimaryFile
      With aSub(pSubPtr)\aCtrlSend[nCtrlSendIndex]
        If \bHTTPSend
          \sSendString = ""
          For d = 0 To grProd\nMaxCtrlSendLogicalDev
            If grProd\aCtrlSendLogicalDevs(d)\sLogicalDev = \sCSLogicalDev
              If grProd\aCtrlSendLogicalDevs(d)\nDevType = \nDevType
                \sSendString = Trim(grProd\aCtrlSendLogicalDevs(d)\sHTTPStart)
                Break
              EndIf
            EndIf
          Next d
          \sSendString + Trim(\sEnteredString)
          sMsg = \sSendString
        EndIf
      EndWith
      
    Else
      With a2ndSub(pSubPtr)\aCtrlSend[nCtrlSendIndex]
        If \bHTTPSend
          \sSendString = ""
          For d = 0 To gr2ndProd\nMaxCtrlSendLogicalDev
            If gr2ndProd\aCtrlSendLogicalDevs(d)\sLogicalDev = \sCSLogicalDev
              If gr2ndProd\aCtrlSendLogicalDevs(d)\nDevType = \nDevType
                \sSendString = Trim(gr2ndProd\aCtrlSendLogicalDevs(d)\sHTTPStart)
                Break
              EndIf
            EndIf
          Next d
          \sSendString + Trim(\sEnteredString)
          sMsg = \sSendString
        EndIf
      EndWith
    EndIf
    
  EndIf
  
  ; debugMsg(sProcName, "returning " + sMsg)
  ProcedureReturn sMsg
  
EndProcedure

Procedure.i sendHTTPString(pMsg.s, pSubPtr, bAddCRLFIfReqd=#False, bCalledFromEditor=#False)
  PROCNAMEC()
  Protected sResult.i, sThisMessage.s
  Protected bLockedMutex
  Protected *pHttpResponseBuffer
  
  debugMsg(sProcName, #SCS_START)
  
  sThisMessage = pMsg
  If sThisMessage
    If bAddCRLFIfReqd
      If Right(sThisMessage,2) <> #CRLF$
        sThisMessage + #CRLF$
      EndIf
    EndIf
    CompilerIf #c_httpsend_in_own_thread
      ; LockHTTPSendMutex(800) ; lock now set in playSubTypeM() before first adding an HTTP message to the array
      If gnHTTPSendMutexLockThread > 0
        bLockedMutex = #True
      EndIf
      With grHTTPControl
        \nMaxHTTPSendMsg + 1
        CompilerIf #cTraceHTTP
          debugMsg(sProcName, "grHTTPControl\nMaxHTTPSendMsg=" + \nMaxHTTPSendMsg)
        CompilerEndIf
        If \nMaxHTTPSendMsg > ArraySize(\aHTTPSendMessage())
          ReDim \aHTTPSendMessage(\nMaxHTTPSendMsg + 5)
        EndIf
        
        If bCalledFromEditor
          \aHTTPSendMessage(\nMaxHTTPSendMsg)\pHTTPResponseBuffer = AllocateMemory(512)
        EndIf
        
        \aHTTPSendMessage(\nMaxHTTPSendMsg)\sHTTPSendMsg = sThisMessage
        \aHTTPSendMessage(\nMaxHTTPSendMsg)\nCueNumber = pSubPtr
        \aHTTPSendMessage(\nMaxHTTPSendMsg)\nHTTPSendIsATest = bCalledFromEditor
        \aHTTPSendMessage(\nMaxHTTPSendMsg)\bHTTPSendMsgSent = #False
      EndWith
      If THR_getThreadState(#SCS_THREAD_HTTP_SEND) <> #SCS_THREAD_STATE_ACTIVE
        debugMsg(sProcName, "calling THR_createOrResumeAThread(#SCS_THREAD_HTTP_SEND)")
        THR_createOrResumeAThread(#SCS_THREAD_HTTP_SEND)
      EndIf
      UnlockHTTPSendMutex()
    CompilerElse
      sResult = SimpleHTTP_GET(sThisMessage, *pHttpResponseBuffer)
      debugMsg(sProcName, "SimpleHTTP_GET(" + #DQUOTE$ + ReplaceString(sThisMessage, #CRLF$, "\r\n") + #DQUOTE$ + ", " + strB(#cTraceHTTP) + ") returned " + #DQUOTE$ + sResult + #DQUOTE$ + ", status=" + gnHTTPGetStatusCode)
    CompilerEndIf
  EndIf
  
  ProcedureReturn sResult
EndProcedure

Procedure addHTTPStringToArray(pMsg.s, pSubPtr, bAddCRLFIfReqd=#False, bCalledFromEditor=#False)
  PROCNAMEC()
  Protected sThisMessage.s
  
  debugMsg(sProcName, #SCS_START + ", pMsg=" + #DQUOTE$ + pMsg + #DQUOTE$ + ", bAddCRLFIfReqd=" + strB(bAddCRLFIfReqd))
  
  sThisMessage = pMsg
  If sThisMessage
    If bAddCRLFIfReqd
      If Right(sThisMessage,2) <> #CRLF$
        sThisMessage + #CRLF$
      EndIf
    EndIf
    With grHTTPControl
      \nMaxHTTPSendMsg + 1
      CompilerIf #cTraceHTTP
        debugMsg(sProcName, "grHTTPControl\nMaxHTTPSendMsg=" + \nMaxHTTPSendMsg)
      CompilerEndIf
      If (\nMaxHTTPSendMsg + 1) => ArraySize(\aHTTPSendMessage())
        ReDim \aHTTPSendMessage(\nMaxHTTPSendMsg + 5)
      EndIf
      
      \aHTTPSendMessage(\nMaxHTTPSendMsg)\nHTTPSendIsATest = bCalledFromEditor
      \aHTTPSendMessage(\nMaxHTTPSendMsg)\sHTTPSendMsg = sThisMessage
      \aHTTPSendMessage(\nMaxHTTPSendMsg)\nCueNumber = pSubPtr
      \aHTTPSendMessage(\nMaxHTTPSendMsg)\bHTTPSendMsgSent = #False
      
    EndWith
  EndIf
  
EndProcedure


; Performs a GET request of the given URL and returns the result as #True if the request completed OK
; If *httpReturnedBuffer is non zero it will return the http response (Page) For Wled this can be a JSON or XML schema
; Because we don't know the memory size of the response we pass in a buffer from AllocateMemory() and this function will resize it and populate it.
; The response could be JSON or XML data or just a Web page from which we can parse the required response data.
Procedure.a SimpleHTTP_GET(nMsgIndex)
  PROCNAMEC()
  
  Protected bResult.a
  Protected hHttpRequest.i
  Protected nProgress.i
  
  HTTPTimeout(5000) ; Allows 5 secs to connect to the server
  
  hHttpRequest = HTTPRequest(#PB_HTTP_Get, URLEncoder(grHTTPControl\aHTTPSendMessage(nMsgIndex)\sHTTPSendMsg), "", #PB_HTTP_Asynchronous)
  
  If hHttpRequest
    Repeat
      nProgress = HTTPProgress(hHttpRequest)
      Select nProgress
        Case #PB_HTTP_Success
          If grHTTPControl\aHTTPSendMessage(nMsgIndex)\nHTTPSendIsATest
            grHTTPControl\aHTTPSendMessage(nMsgIndex)\pHTTPResponseBuffer = HTTPMemory(hHttpRequest)
          EndIf
          grHTTPControl\aHTTPSendMessage(nMsgIndex)\nHTTPGetStatusCode = Val(HTTPInfo(hHttpRequest, #PB_HTTP_StatusCode))
          bResult = #True
          FinishHTTP(hHttpRequest)
          Break
          
        Case #PB_HTTP_Failed
          grHTTPControl\aHTTPSendMessage(nMsgIndex)\nHTTPGetStatusCode = Val(HTTPInfo(hHttpRequest, #PB_HTTP_StatusCode))
          
          If grHTTPControl\aHTTPSendMessage(nMsgIndex)\nHTTPGetStatusCode = 0
            grHTTPControl\aHTTPSendMessage(nMsgIndex)\nHTTPGetStatusCode = 408   ; most likely enforced timeout
          EndIf
          
          FinishHTTP(hHttpRequest)
          Break
          
        Case #PB_HTTP_Aborted
         grHTTPControl\aHTTPSendMessage(nMsgIndex)\nHTTPGetStatusCode = Val(HTTPInfo(hHttpRequest, #PB_HTTP_StatusCode))
         FinishHTTP(hHttpRequest)
          Break
          
        Default
          ; Debug "Current download: " + Progress ; The current download progress, in bytes
      EndSelect
      Delay(25)
    ForEver
  Else
    Debug "Request creation failed"
  EndIf

  ProcedureReturn bResult
EndProcedure

; EOF
