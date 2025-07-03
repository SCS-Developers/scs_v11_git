IncludeFile "vlc.pb"

; Enable Threadsafe!

vlc_loadlibvlc("C:\Program Files\VideoLAN\VLC\libvlc.dll") ; select vlc dll
OpenWindow(0,0,0,800,700,"")
CanvasGadget(1,0,0,800,700)
vlc = vlc_createplayer(GadgetID(1),1)
vlc_setvolume(vlc,80)
; vlc_play(vlc,"https://www.youtube.com/watch?v=sOlP10fDclE&ab_channel=ClassicMrBean") ; not work for youtube video
; vlc_addplaylist(vlc,"https://www.youtube.com/watch?v=sOlP10fDclE&ab_channel=ClassicMrBean")
vlc_addplaylist(vlc, "C:\Users\Mike\Videos\Alaska.mp4")
vlc_playplaylist(vlc)
While WaitWindowEvent() <> #PB_Event_CloseWindow
Wend
vlc_freeplayer(vlc)
