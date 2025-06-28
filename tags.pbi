; File: tags.pbi

; Author: Wraith, 2k5-2k6
; consult "tags-readme.txt" for details

; INFO: This supports the tags library supplied by Ian Luck, NOT the tags library supplied by '3delite', which costs €625 

; Current version. Just increments each release.
#TAGS_VERSION = 18

CompilerIf #PB_Compiler_Processor = #PB_Processor_x64
  Import "libs_x64\tags.lib"
CompilerElse
  Import "libs_x86\tags.lib"
CompilerEndIf
    TAGS_GetVersion.l()
    TAGS_SetUTF8.l(enable.l)
    TAGS_Read.i(Handle.l, fmt.p-ascii)
    TAGS_ReadEx.i(Handle.l, fmt.p-ascii, tagtype.l, codepage.l)
    TAGS_GetLastErrorDesc.l()
  EndImport
