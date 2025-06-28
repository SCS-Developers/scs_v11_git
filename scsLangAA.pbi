;  File: scsLangAA.pbi

; for instructions, see description at start of scs_lang_database.pbi
; (change "AA" to required language code)

EnableExplicit

; INFO: File Format of this source file must be UTF8

; parameter substitution provided by $1, $2, etc. See "WMN" / "ExclCueRun" for an example.
; Chr(10) substituted for \n
; Chr(34) substituted for \q

; the following code is executed unconditionally on including this .pbi file:
If ArraySize(gaLanguage()) < gnLanguageCount
  ReDim gaLanguage(gnLanguageCount)
EndIf
With gaLanguage(gnLanguageCount)
  \sLangCode = "AA"               ; language code
  \sLangName = "Spanish"          ; language name
  \sCreator = "Fred Bloggs"   
EndWith
gnLanguageCount + 1

; language groups and strings
DataSection
  Language_AA:
  
  
  Data.s "", "_END_", ""
EndDataSection

; EOF

; IDE Options = PureBasic 5.43 LTS (Windows - x64)
; CursorPosition = 32
; EnableUnicode
; EnableThread
; EnableXP
; EnableOnError
; CPU = 1