;  File: scsLangENGB.pbi

EnableExplicit

; parameter substitution provided by $1, $2, etc. See "WMN" / "ExclCueRun" for an example.

; the following code is executed unconditionally on including this .pbi file:
If ArraySize(gaLanguage()) < gnLanguageCount
  ReDim gaLanguage(gnLanguageCount)
EndIf
With gaLanguage(gnLanguageCount)
  \sLangCode = "ENGB"
  \sLangName = "English (GB)"
  \sCreator = "Show Cue Systems Pty Ltd"
EndWith
gnLanguageCount + 1

; language groups and strings
DataSection
  Language_ENGB:
  
  ;- Language group BASS (BASS Audio Library Errors)
  Data.s "", "_GROUP_", "BASS"
  Data.s "1950", "#BASS_ERROR_WMA_LICENSE", "The file is protected (licence required)"

  ;- Language group Btns
  Data.s "", "_GROUP_", "Btns"
  Data.s "", "Center", "Centre"
  Data.s "", "CenterTT", "Centre the pan position"
  
  ;- Language group Common
  Data.s "", "_GROUP_", "Common"
  Data.s "", "LicensedTo", "Licenced to"
  Data.s "-1", "RepeatCanceled", "Repeat cancelled"
  
  ;- Language group Errors (SCS Error Messages)
  Data.s "", "_GROUP_", "Errors"
  Data.s "1828", "CannotAddCues", "Cannot add $1 cue(s) as this would exceed the maximum number of cues allowed with your licence type"
  
  ;- Language group Init (Initialisation)
  Data.s "", "_GROUP_", "Init"
  Data.s "", "FnFavFile1", "Favourite Cue File #1 *"
  Data.s "-1", "WASAPINotStarting", "Warning! WASAPI (Windows Audio Session API) initialisation stalled the last time SCS was started on this computer.\n\nWASAPI will now be ignored.\n\nIf you want to reinstate the use of WASAPI you can do this from $1"
  
  ;- Language group Menu
  Data.s "", "_GROUP_", "Menu"
  Data.s "", "mnuColorSchemeDesigner", "Colour Scheme Designer"
  Data.s "", "mnuColorsMenu", "Colours"
  Data.s "", "mnuFav", "Favourites"
  Data.s "", "mnuFavFiles", "Favourite SCS Cue Files..."
  Data.s "", "mnuFavsInfo", "Select up to 6 items for your Favourites"
  Data.s "-1", "mnuWQPPeakNormAll", "Adjust Relative Levels to apply Peak Normalisation across ALL files (Max $1)"
  Data.s "-1", "mnuWQPLUFSNormAll", "Adjust Relative Levels to apply LUFS Normalisation across ALL files (Max $1)"
  Data.s "-1", "mnuWDDBackColorDefault", "Default background colour"
  Data.s "-1", "mnuWDDBackColorPicker", "Select any background colour"
  Data.s "-1", "mnuGrdColBlack", "Black (default text colour)"
  Data.s "-1", "mnuGrdColPicker", "Select any text colour..."
  
  ;- Language group Network (Various Network-related strings)
  Data.s "", "_GROUP_", "Network"
  Data.s "-1", "CannotFindCueFile", "Cannot find $1 in 'recent files', 'favourites', or the 'initial folder'"

  ;- Language group SMS
  Data.s "", "_GROUP_", "SMS"
  Data.s "2258", "OutputsAdj", "Warning! $1 output channels have been remapped due to the output limitation of your SM-S licence or demo. The available ASIO outputs are $2."
  
  ;- Language group FTCCodes (Fixture Type Channel Short Codes)
  Data.s "", "_GROUP_", "FTCCodes"
  Data.s "-1", "CW", "Colour Wheel"
  
  ;- Language group WAB (About Box)
  Data.s "", "_GROUP_", "WAB"
  Data.s "", "lblLicType", "Licence Type"
  Data.s "", "frLicence", "Licence Details"
  
  ;- Language group WAC (Audio Graph Colors Window)
  Data.s "", "_GROUP_", "WAC"
  Data.s "-1", "Window", "Audio Graph Colours"
  Data.s "-1", "btnUseClassic", "Use SCS Classic Colours"
  Data.s "-1", "btnUseDflts", "Use SCS Default Colours"
  Data.s "-1", "chkRightSameAsLeft", "Right Colour Same As Left Colour"
  Data.s "-1", "lblLeftColor", "Left/Mono Channel Colour"
  Data.s "-1", "lblRightColor", "Right Channel Colour"
  Data.s "3109", "lblColorPlay", "'Playing' Colour"
  Data.s "-1", "lblCursorColor", "Cursor Colour"
  
  ;- Language group WBE (Bulk Edit Window)
  Data.s "", "_GROUP_", "WBE"
  Data.s "3142", "Normalize", "Normalise"
  Data.s "-1", "NormToApply" "Normalisation to apply"
  Data.s "-1", "lblCappedLevelWarning", "Applying gain values marked in this colour can cause signal clipping"
  
  ;- Language group WCS (Color Scheme Designer)
  Data.s "", "_GROUP_", "WCS"
  Data.s "0164", "Window", "Colour Scheme Designer"
  Data.s "0165", "AlreadyUsed", "Colour Scheme Name '$1' is already used."
  Data.s "0168", "btnDelete", "Delete this Colour Scheme"
  Data.s "2376", "btnExport", "Export Colour Scheme"
  Data.s "2377", "btnImport", "Import Colour Scheme"
  Data.s "0170", "btnSave", "Save Colour Scheme"
  Data.s "0172", "btnSaveAs", "Save As Colour Scheme"
  Data.s "2378", "btnSwap", "Swap Background/Text Colours"
  Data.s "2379", "ColCodeDF", "Default Colours"
  Data.s "0195", "DelScheme", "Are you sure you want to delete Colour Scheme $1? This action cannot be undone."
  Data.s "0196", "lblBackColor", "Background Colour"
  Data.s "2752", "lblColNXAction", "Colour for 'Next Manual Cue'"
  Data.s "0198", "lblSample", "Colour Sample"
  Data.s "0199", "lblScheme", "Colour Scheme"
  Data.s "0200", "lblTextColor", "Text Colour"
  Data.s "2381", "lblUseDflt", "Use Default Colours"
  Data.s "2382", "picBackColorTT", "Click to change background colour"
  Data.s "2383", "picTextColorTT", "Click to change text colour"
  Data.s "0201", "Replace", "Do you want to replace this Colour Scheme?"
  Data.s "0202", "Reserved", "'$1' is reserved and cannot be used for your own Colour Scheme Name"
  Data.s "0171", "SaveAsPrompt", "Save as Colour Scheme: (Leave blank to cancel)"
  Data.s "0206", "UsingProd", "Using colour file from production folder: $1"
  Data.s "2753", "ColNXUseNXColors", "Use 'Next Manual Cue' colours specified above"
  Data.s "2754", "ColNXUseCueColors", "Use cue colours"
  Data.s "2755", "ColNXSwapCueColors", "Swap cue background and text colours"
  Data.s "2756", "ColNXLightenOthers", "Lighten colours of OTHER cues"
  Data.s "2757", "ColNXDarkenOthers", "Darken colours of OTHER cues"
  
  ;- Language group WDD (DMX Display)
  Data.s "", "_GROUP_", "WDD"
  Data.s "-1", "mbgBackColor", "Background Colour"
  
  ;- Language group WED (Editor)
  Data.s "", "_GROUP_", "WED"
  Data.s "", "MaxFavs", "The maximum number of Favourites is $1 - you already have $1 so you need to remove one if you want to add '$2'"

  ;- Language group WEP (Production Properties)
  Data.s "", "_GROUP_", "WEP"
  Data.s "5004", "lblFTCTextColor", "DMX Grid Text Colour"
  Data.s "-1", "cvsFTCTextColorTT", "Click to select a different text colour. (The grid's background colour can be changed in the DMX Display window.)"
  
  ;- Language group WFF (Favourite Files)
  Data.s "", "_GROUP_", "WFF"
  Data.s "", "Window", "Favourite SCS Cue Files"
  Data.s "", "lblFavFiles", "Favourite SCS Cue Files:"
  Data.s "", "SaveChanges", "Do you want to save the changes to the Favourite Files?"
  
  ;- Language group WFS (Favourite File Selector)
  Data.s "", "_GROUP_", "WFS"
  Data.s "2649", "Window", "Favourite File Selector"
  
  ;- Language group WIM (Import Cues)
  Data.s "", "_GROUP_", "WIM"
  Data.s "", "btnFavorites", "Favourites"
  
  ;- Language group WLE (Lock Editing and Options)
  Data.s "", "_GROUP_", "WLE"
  Data.s "", "lblAuthString", "SCS Authorisation String"
  Data.s "", "lblSetPassword[0]", "To set or reset the Sound Designer Password, you must enter your SCS Authorisation String."
  Data.s "", "AuthMsg1", "Authorisation String incorrect."
  
    ;- Language group WLP ('Load Production' Window)
  Data.s "", "_GROUP_", "WLP"
  Data.s "-1", "Favorite", "Open Favourite"
  Data.s "-1", "NoFav", "No Favourite Files are currently registered"
  
  ;- Language group WMI (Info Message Window)
  Data.s "", "_GROUP_", "WMI"
  Data.s "", "InitEditCueProps", "Initialising Editor $1 Cue Properties"
  
  ;- Language group WOP (Permanent Options)
  Data.s "", "_GROUP_", "WOP"
  Data.s "", "btnColorSchemeDesigner", "Colour Scheme Designer"
  Data.s "", "CannotUnlockTemp", "Cannot unlock editor as your temporary licence is now running in play-only mode"
  Data.s "", "chkForceSpeakersTT", "Set this option if SCS doesn't appear to recognise more than the two 'front' speakers"
  Data.s "", "lblColorScheme", "Colour Scheme"
  Data.s "", "lblShortcutInfo", "* Other 'Favourite Cue Files' can be accessed using subsequent keys"
  Data.s "3439", "chkNoWASAPITT", "If you do not need to use WASAPI (eg to access all available speakers) then setting this option can significantly reduce device initialisation time"
  
  ;- Language group WPF (Create Production Folder)
  Data.s "", "_GROUP_", "WPF"
  Data.s "947", "chkCopyColorFile", "Include the current Colour File"
  Data.s "2032", "Canceled", "Collection of files cancelled."
  Data.s "2036", "ColorFileCopied", "1 colour file copied"
  
  ;- Language group WQE
  Data.s "", "_GROUP_", "WQE"
  Data.s "2013", "tbPageColor", "Memo Background Colour"
  Data.s "2014", "tbTextBackColor", "Text Background Colour"
  Data.s "2015", "tbTextColor", "Text Colour"
  Data.s "2017", "tbCenter", "Align Centre"
  
  ;- Language group WQF
  Data.s "", "_GROUP_", "WQF"
  Data.s "2214", "GraphAdjN", "Graph Adjusted Levels Normalised"
  Data.s "2216", "GraphFileN", "Graph File Levels Normalised"
  
  ;- Language group WQM (Control Send subcue)
  Data.s "", "_GROUP_", "WQM"
  Data.s "", "Canceled", "Cancelled"

  ;- Language group WRG (Register)
  Data.s "", "_GROUP_", "WRG"
  Data.s "", "lblAuthString", "Authorisation String"
  Data.s "", "LicenseType", "Licence type: $1."
  Data.s "", "LicenseExpires", "Licence expires $1"
  Data.s "", "AuthNotValid", "Authorisation String is not valid for this User Name."
  Data.s "", "LicenseExpired", "This licence expired on $1"
  Data.s "", "lblDemoInfo4", "If you have already purchased an SCS licence then you need to download and install the program using the information supplied in your registration email."

  ;- Language group WSP (Splash)
  Data.s "", "_GROUP_", "WSP"
  Data.s "", "lblLicType", "Licence type"
  Data.s "", "Initializing", "Initialising"
  
  ;- Language group WSS
  Data.s "", "_GROUP_", "WSS"
  Data.s "1957", "AreYouSure", "'Factory Reset' will delete your SCS 11 'preferences' file, but will NOT affect your cue files, device maps or favourite files.\n\nAre you sure you want to 'Factory Reset' and reset all options, settings and window positions?"
  Data.s "1960", "chkFactoryResetTT", "Note: 'Factory Reset' will NOT affect your cue files, device maps or favourite files"
  
  Data.s "", "_END_", ""
EndDataSection

; EOF