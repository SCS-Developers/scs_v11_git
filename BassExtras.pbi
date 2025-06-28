; file BassExtras.pbi

EnableExplicit

CompilerIf #PB_Compiler_Unicode
  #SCS_BASS_UNICODE = #BASS_UNICODE
CompilerElse
  #SCS_BASS_UNICODE = 0
CompilerEndIf

; BASS_WMA constants
#BASS_ERROR_WMA_LICENSE = 1000     ; the file is protected
#BASS_ERROR_WMA = 1001             ; Windows Media (9 or above) is not installed
#BASS_ERROR_WMA_WM9 = #BASS_ERROR_WMA
#BASS_ERROR_WMA_DENIED = 1002      ; access denied (user/pass is invalid)
#BASS_ERROR_WMA_INDIVIDUAL = 1004  ; individualization is needed
#BASS_ERROR_WMA_PUBINIT = 1005     ; publishing point initialization problem

#BASS_CONFIG_WMA_BASSFILE = $10103
#BASS_CONFIG_NOTIMERES = 29        ; undocumented

#BASS_CTYPE_STREAM_WMA = $10300
#BASS_CTYPE_STREAM_WMA_MP3 = $10301

; EOF