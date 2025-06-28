; File: scs_PB_demo_x86_Lambert.pb

; =============================================================================================
; WARNING!!! When compiling, make sure name of executable is scs11demoLS.exe, NOT scs11demo.exe
; =============================================================================================

EnableExplicit

; conditional compilation constants
#cDemo = #True
#cWorkshop = #False

; compile for a language translator?
#cTranslator = #False

; Tutorial Video and Screen Shot settings
#cTutorialVideoOrScreenShots = #False

#cAgent = #True

#SCS_AGENT_NAME = "Lambert Studios"
#SCS_URL_LINK = "https://www.lambertstudios.net/scs"
#SCS_URL_DISPLAY = "www.lambertstudios.net/scs"
#SCS_REGISTER_URL_LINK = "https://www.lambertstudios.net/scs"
#SCS_REGISTER_URL_DISPLAY = "www.lambertstudios.net/scs"

#SCS_DEFAULT_LANGUAGE = "ENUS"

XIncludeFile "TopLevel.pbi"

; EOF