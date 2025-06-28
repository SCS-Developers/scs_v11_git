; File: scs_lang_database_aa.pb

; INFO: for instructions, see description at start of scs_lang_database.pbi
; (change "AA" to required language code)

EnableExplicit

XIncludeFile "scs_lang_compiler_constants.pbi"

Structure tyLanguage
  sLangCode.s
  sLangName.s
  sCreator.s
EndStructure

Global Dim gaLanguage.tyLanguage(0)
Global gnLanguageCount

Global gsLanguageCode.s = "AA"
XIncludeFile "scsLangAA.pbi"

Enumeration 1
  #SCS_LANG_DB_CREATE     ; use CREATE to create a completely new database for this language
  #SCS_LANG_DB_READ       ; use READ to read a translation database provided by the translator, so that an export file can be created and copied into scsLangAA.pbi
  #SCS_LANG_DB_UPDATE     ; use UPDATE after fully processing READ to update the translation database with the latest translations, new strings, etc, but also to preserve the comments field
EndEnumeration
Global gnLangDatabaseAction = #SCS_LANG_DB_CREATE

Procedure restoreLanguage()
  Restore Language_AA
EndProcedure

XIncludeFile "scs_lang_database.pbi"      ; English (US)
