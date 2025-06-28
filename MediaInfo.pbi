; File: MediaInfo.pbi

;- MediaInfo_stream_t
; Kinds of Stream
Enumeration
  #MediaInfo_Stream_General 	
  #MediaInfo_Stream_Video 	
  #MediaInfo_Stream_Audio 	
  #MediaInfo_Stream_Text 	
  #MediaInfo_Stream_Chapters 	
  #MediaInfo_Stream_Image 	
  #MediaInfo_Stream_Menu 	
  #MediaInfo_Stream_Max 
EndEnumeration

;- MediaInfo_info_t
; Kinds of Info
Enumeration
  #MediaInfo_Info_Name 	
  #MediaInfo_Info_Text 	
  #MediaInfo_Info_Measure 	
  #MediaInfo_Info_Options 	
  #MediaInfo_Info_Name_Text 	
  #MediaInfo_Info_Measure_Text 	
  #MediaInfo_Info_Info 	
  #MediaInfo_Info_HowTo 	
  #MediaInfo_Info_Max 
EndEnumeration

Prototype.i pr_MediaInfo_New()
Prototype.i pr_MediaInfo_Open(nHandle.i, *sFile)
Prototype.i pr_MediaInfo_Inform(nHandle.i, nSize.l)
Prototype.i pr_MediaInfo_Get(nHandle.i, nStreamKind, nStreamNumber, *sParameter, nKindOfInfo, nKindOfSearch)
Prototype.i pr_MediaInfo_Delete(nHandle.i)

Global gnMediaInfoLib.i

Procedure openMediaInfoLib()
  PROCNAMEC()
  Protected sLibName.s
  
  debugMsg(sProcName, #SCS_START)
  
  ; NB MediaInfo.dll downloaded from "https://mediaarea.net/en/MediaInfo/Download/Windows"
  ; Download the 32-bit 'without installer' version and copy MediaInfo.dll to the SCS executable folders,
  ; viz \scs_v11_curr_development and \scs_v11_curr_development\Runtime
  ; Look first in the SCS executable folder (gsAppPath) - the dll should be there, but if it's not then allow PB code to find the library in any of the default library locations
  sLibName = gsAppPath + "MediaInfo.dll"
  debugMsg(sProcName, "sLibName=" + #DQUOTE$ + sLibName + #DQUOTE$)
  debugMsg(sProcName, "FileSize(sLibName)=" + FileSize(sLibName))
  gnMediaInfoLib = OpenLibrary(#PB_Any, sLibName)
  ; debugMsg(sProcName, "gnMediaInfoLib=" + gnMediaInfoLib)
  If IsLibrary(gnMediaInfoLib) = #False
    sLibName = gsInitialCurrentDirectory + "MediaInfo.dll"
    debugMsg(sProcName, "sLibName=" + #DQUOTE$ + sLibName + #DQUOTE$)
    debugMsg(sProcName, "FileSize(sLibName)=" + FileSize(sLibName))
    gnMediaInfoLib = OpenLibrary(#PB_Any, sLibName)
    debugMsg(sProcName, "gnMediaInfoLib=" + gnMediaInfoLib)
    If IsLibrary(gnMediaInfoLib) = #False
      sLibName = "MediaInfo.dll"
      debugMsg(sProcName, "sLibName=" + #DQUOTE$ + sLibName + #DQUOTE$)
      debugMsg(sProcName, "FileSize(sLibName)=" + FileSize(sLibName))
      gnMediaInfoLib = OpenLibrary(#PB_Any, sLibName)
      debugMsg(sProcName, "gnMediaInfoLib=" + gnMediaInfoLib)
    EndIf
  EndIf
  
  debugMsg(sProcName, "gnMediaInfoLib=" + Str(gnMediaInfoLib) + ", sLibName=" + #DQUOTE$ + sLibName + #DQUOTE$)
  
  If gnMediaInfoLib
    Global MediaInfo_New.pr_MediaInfo_New = GetFunction(gnMediaInfoLib, "MediaInfo_New")
    Global MediaInfo_Open.pr_MediaInfo_Open = GetFunction(gnMediaInfoLib, "MediaInfo_Open")
    Global MediaInfo_Inform.pr_MediaInfo_Inform = GetFunction(gnMediaInfoLib, "MediaInfo_Inform")
    Global MediaInfo_Get.pr_MediaInfo_Get = GetFunction(gnMediaInfoLib, "MediaInfo_Get")
    Global MediaInfo_Delete.pr_MediaInfo_Delete = GetFunction(gnMediaInfoLib, "MediaInfo_Delete")
    debugMsg(sProcName, "MediaInfo_New=" + MediaInfo_New)
    debugMsg(sProcName, "MediaInfo_Open=" + MediaInfo_Open)
    debugMsg(sProcName, "MediaInfo_Inform=" + MediaInfo_Inform)
    debugMsg(sProcName, "MediaInfo_Get=" + MediaInfo_Get)
    debugMsg(sProcName, "MediaInfo_Delete=" + MediaInfo_Delete)
  EndIf
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure closeMediaInfoLib()
  If gnMediaInfoLib
    CloseLibrary(gnMediaInfoLib)
  EndIf
EndProcedure

; EOF