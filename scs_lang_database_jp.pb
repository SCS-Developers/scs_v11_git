; File: scs_lang_database_jp.pb

; INFO: for instructions, see description at start of scs_lang_database.pbi

EnableExplicit

XIncludeFile "scs_lang_compiler_constants.pbi"

Structure tyLanguage
  sLangCode.s
  sLangName.s
  sCreator.s
EndStructure

Global Dim gaLanguage.tyLanguage(0)
Global gnLanguageCount

Global gsLanguageCode.s = "JP"  ; Japanese
XIncludeFile "scsLangJP.pbi"

Enumeration 1
  #SCS_LANG_DB_CREATE     ; use CREATE to create a completely new database for this language
  #SCS_LANG_DB_READ       ; use READ to read a translation database provided by the translator, so that an export file can be created and copied into scsLangJP.pbi
  #SCS_LANG_DB_UPDATE     ; use UPDATE after fully processing READ to update the translation database with the latest translations, new strings, etc, but also to preserve the comments field
EndEnumeration
; Global gnLangDatabaseAction = #SCS_LANG_DB_UPDATE
Global gnLangDatabaseAction = #SCS_LANG_DB_READ

Procedure restoreLanguage()
  Restore Language_JP
EndProcedure

XIncludeFile "scs_lang_database.pbi"
