; File: ETCImport.pbi

; based on code supplied by Roger Forsey, 9 Dec 2013 - see email "Enhancement request for SCS - Import lighting control cues"


Procedure importETC_CueList(strControlFile.s)
  ; was named CueList() in original code
  PROCNAMEC()
	; Purpose: Read ETC CSV exported show file and create an dictionary array containing a list of the show cues.
	; Accepts: Path/exported ETC show file.
	; Returns: True = dicCueNumbers contains a list of cues found in ETC file.
	;                False = Error found in file format.
	
	Protected strFileLine.s	; File line.
	Protected bStart_Targets	; START_TARGETS key found.
	Protected bEnd_Targets	; END_TARGETS found.
	Protected Dim sArray.s(10)
	Protected nFieldCount
	Protected sField.s
	Protected sETCCue.s, sLabel.s, bNextCueEnabled
	Protected sResult.s
	Protected n
  Protected bETCCueFound, nIndex
  Protected nFollowColumn
  
  nFollowColumn = Asc("W") - Asc("A")   ; nb column numbers are 0-based, so column A = 0
  debugMsg(sProcName, "nFollowColumn=" + nFollowColumn)
  
  With grETCImport
    \nCueCount = 0
    gnNextFileNo + 1
    \nControlFile = gnNextFileNo
    If ReadFile(\nControlFile, strControlFile, #PB_File_SharedRead) = #False
      ProcedureReturn
    EndIf
    
    bStart_Targets = #False	; Init
    bEnd_Targets = #False	; Init
    ; sResult = "CueList() Error"	; Prime failed return.
    sResult = sProcName + " Error"	; Prime failed return.
    
    While Eof(\nControlFile) = 0
      strFileLine = Trim(ReadString(\nControlFile, #PB_Ascii))
      
      If Len(strFileLine) > 0
        
        If bStart_Targets
          
          ; debugMsg(sProcName, strFileLine)
          
          If strFileLine = "END_TARGETS"
            ; debugMsg(sProcName, strFileLine)	; Log.
            bEnd_Targets = #True
            sResult = ""	; Return success
            Break
            
          EndIf
          
          ; Process the target line like "1,Cue,1,45,,,4,0,4,0,4,0,4,0,4,0,4,,,,,,,,,,,,"
          ; Split the line into an array.
          ; sArray = Split(strFileLine, ",")
          nFieldCount = CountString(strFileLine,",") + 1
          If nFieldCount > 1
            If ArraySize(sArray()) < nFieldCount
              ReDim sArray(nFieldCount)
            EndIf
            For n = 1 To nFieldCount
              sArray(n-1) = Trim(StringField(strFileLine, n, ","))
            Next n
            
            If sArray(1) = "Cue"
              sETCCue = sArray(3)
              bETCCueFound = #False
              For n = 0 To (\nCueCount - 1)
                If \sETCCue(n) = sETCCue
                  bETCCueFound = #True
                  Break
                EndIf
              Next n
              If bETCCueFound
                ; Do nothing
              Else
                If Len(sArray(5)) > 0
                  sLabel = sArray(5)
                Else
                  sLabel = ""
                EndIf
                ; note that if the 'FOLLOW' field is set then the *following* cue is to be disabled - hence the naming of the variable bNextCueEnabled
                If Len(Trim(sArray(nFollowColumn))) > 0
                  bNextCueEnabled = #False
                Else
                  bNextCueEnabled = #True
                EndIf
                nIndex = \nCueCount
                If nIndex > ArraySize(\sETCCue())
                  ReDim \sETCCue(nIndex+50)
                  ReDim \sLabel(nIndex+50)
                  ReDim \bNextCueEnabled(nIndex+50)
                EndIf
                \sETCCue(nIndex) = sETCCue ; Add the unique cue number and label to the dictionary array as key and item.
                \sLabel(nIndex) = sLabel
                \bNextCueEnabled(nIndex) = bNextCueEnabled
                debugMsg(sProcName, "\sETCCue(" + nIndex + ")=" + \sETCCue(nIndex) + ", \sLabel(" + nIndex + ")=" + \sLabel(nIndex) + ", \bNextCueEnabled=" + strB(\bNextCueEnabled(nIndex)))
                \nCueCount + 1
              EndIf
            EndIf
            
          EndIf
          
        Else
          
          If strFileLine = "START_TARGETS"
            ; debugMsg(sProcName, strFileLine)	; Log.
            strFileLine = Trim(ReadString(\nControlFile, #PB_Ascii))	; Read and skip the headings line
            bStart_Targets = #True
          EndIf
        EndIf
        
      EndIf
      
    Wend
    
    ; Cleanup
    CloseFile(\nControlFile)
    
    debugMsg(sProcName, "\nCueCount=" + Str(\nCueCount))
    
  EndWith
  
EndProcedure

; EOF