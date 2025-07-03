
PrototypeC snprintf(a, b, c, d):Global snprintf.snprintf = GetFunction(OpenLibrary(#PB_Any, "msvcrt"), "_vsnprintf")

IncludeFile "libvlc.pb"
EnableExplicit

Structure vlc_subtitle_track
	i_codec.l
	i_original_fourcc.l
	i_id.l
	i_type.l
	i_profile.l
	i_level.l
	;subtitle
	psz_encoding.s
	
	i_bitrate.l
	psz_language.s
	psz_description.s
	
	codecdescription.s
EndStructure

Structure vlc_audio_track
	i_codec.l
	i_original_fourcc.l
	i_id.l
	i_type.l
	i_profile.l
	i_level.l
	;audio
	i_channels.l
	i_rate.l
	
	i_bitrate.l
	psz_language.s
	psz_description.s
	
	codecdescription.s
EndStructure

Structure vlc_video_track
	i_codec.l
	i_original_fourcc.l
	i_id.l
	i_type.l
	i_profile.l
	i_level.l
	;video
	i_height.l
	i_width.l
	i_sar_num.l
	i_sar_den.l
	i_frame_rate_num.l
	i_frame_rate_den.l
	i_orientation.l
	i_projection.l	
	;libvlc_video_viewpoint_t
	f_yaw.f
	f_pitch.f
	f_roll.f
	f_field_of_view.f
	
	i_bitrate.l
	psz_language.s
	psz_description.s
	
	codecdescription.s
EndStructure

Structure vlc_track_description
	i_id.l
	psz_name.s
EndStructure

Structure vlc_audio_output_device
	psz_device.s													; /**< Device identifier string */
	psz_description.s												; /**< User-friendly device description */
EndStructure

Structure vlc_audio_output
	psz_name.s
	psz_description.s
EndStructure

Structure vlc
	libvlc.i
	libvlc_media_player.i
	libvlc_media_list.i
	libvlc_media_list_player.i
	libvlc_event_Buffering.i
	libvlc_event_Playing.i
	libvlc_event_NextItemSet.i
	libvlc_event_log.l
	is_muted.l
	windowfull.i
	windowmin.i
	vol.l
	gadget.i
	windowoldstate.l
	windowstate.l
	
	is_Buffering.l
	is_paused.l
	is_NextItemSet.l
	download_rate.l
	download_timer.l
	download_size.q
EndStructure

Global vlc_libisloaded = 0


Procedure vlc_loadlibvlc(libvlcpath.s)
	Protected cd.s = GetCurrentDirectory()
	SetCurrentDirectory(GetPathPart(libvlcpath))
	vlc_libisloaded = libvlc_loadapi(OpenLibrary(#PB_Any,GetFilePart(libvlcpath)))
	SetCurrentDirectory(cd)
EndProcedure

ProcedureC vlc_eventPlaying(e,*vlc.vlc)
	With *vlc
		libvlc_audio_set_mute(\libvlc_media_player,\is_muted)
		libvlc_audio_set_volume(\libvlc_media_player,\vol)
	EndWith
EndProcedure

ProcedureC vlc_eventBuffering(e,*vlc.vlc)
	*vlc\is_Buffering = 1
EndProcedure

ProcedureC vlc_eventNextItemSet(e,*vlc.vlc)
	FillMemory(*vlc+ OffsetOf(vlc\is_Buffering), SizeOf(vlc)- OffsetOf(vlc\is_Buffering))
	*vlc\is_NextItemSet = 1
EndProcedure

Procedure.s vlc_safePeekS(ps,len = -1)
	If ps:ProcedureReturn PeekS(ps, len, #PB_UTF8):EndIf
EndProcedure

Procedure.s vlc_stringformat(fmt,va_list)
	Protected sret.s
	Protected c = snprintf(0,0,fmt,va_list)
	If c
		Protected pm = AllocateMemory(c)
		If pm
			snprintf(pm,c,fmt,va_list)
			sret  = vlc_safePeekS(pm,c)
			FreeMemory(pm)
		EndIf
	EndIf
	ProcedureReturn sret
EndProcedure

ProcedureC vlc_eventdebug (*vlc.vlc,  level,  libvlc_log_t, fmt, va_list)
	Select level
		Case #LIBVLC_DEBUG
			Debug "#LIBVLC_DEBUG	: "+vlc_stringformat(fmt,va_list)
		Case #LIBVLC_NOTICE
			Debug "#LIBVLC_NOTICE	: "+vlc_stringformat(fmt,va_list)
		Case #LIBVLC_WARNING
			Debug "#LIBVLC_WARNING	: "+vlc_stringformat(fmt,va_list)
		Case #LIBVLC_ERROR
			Debug "#LIBVLC_ERROR	: "+vlc_stringformat(fmt,va_list)
	EndSelect
EndProcedure

Procedure vlc_showdebug(*vlc.vlc, on)
	If vlc_libisloaded = 0:ProcedureReturn:EndIf
	With *vlc
		\libvlc_event_log = on
		If on
			ProcedureReturn libvlc_log_set(\libvlc,@vlc_eventdebug(),*vlc)
		Else
			ProcedureReturn libvlc_log_unset(\libvlc)
		EndIf
	EndWith
EndProcedure

Procedure vlc_createplayer(hwnd,showlog=0,*arg=0,argsize=0)
	If vlc_libisloaded = 0:ProcedureReturn:EndIf
	Protected *vlc.vlc = AllocateMemory(SizeOf(vlc))
	If *vlc
		With *vlc
			\libvlc = libvlc_new(argsize,*arg)
			If \libvlc
				If showlog
					\libvlc_event_log = showlog
					libvlc_log_set(\libvlc,@vlc_eventdebug(),*vlc)
				EndIf
				\libvlc_media_player = libvlc_media_player_new(\libvlc)
				If \libvlc_media_player
					\libvlc_media_list= libvlc_media_list_new(\libvlc)
					\libvlc_media_list_player = libvlc_media_list_player_new(\libvlc)
					libvlc_media_list_player_set_media_player(\libvlc_media_list_player,\libvlc_media_player)
					libvlc_media_list_player_set_media_list(\libvlc_media_list_player,\libvlc_media_list)
					libvlc_media_player_set_hwnd( \libvlc_media_player, hwnd)
					libvlc_video_set_key_input(\libvlc_media_player,0)
					libvlc_video_set_mouse_input(\libvlc_media_player,0)
					\vol = 100
					\is_muted = 0
					\libvlc_event_Buffering = libvlc_media_player_event_manager(\libvlc_media_player)
					\libvlc_event_Playing = libvlc_media_player_event_manager(\libvlc_media_player)
					\libvlc_event_NextItemSet = libvlc_media_list_player_event_manager(\libvlc_media_list_player)
					If \libvlc_event_Buffering And \libvlc_event_Playing  And \libvlc_event_NextItemSet
						libvlc_event_attach(\libvlc_event_Buffering,#libvlc_MediaPlayerBuffering,@vlc_eventBuffering(),*vlc)
						libvlc_event_attach(\libvlc_event_Playing,#libvlc_MediaPlayerPlaying,@vlc_eventPlaying(),*vlc)
						libvlc_event_attach(\libvlc_event_NextItemSet,#libvlc_MediaListPlayerNextItemSet,@vlc_eventNextItemSet(),*vlc)
					EndIf
				EndIf
			EndIf
			If \libvlc_media_player = 0
				FreeMemory(*vlc)
				*vlc = 0
			EndIf
		EndWith
	EndIf
	ProcedureReturn *vlc
EndProcedure

Procedure vlc_freeplayer(*vlc.vlc)
	If vlc_libisloaded = 0:ProcedureReturn:EndIf
	If *vlc = 0 : ProcedureReturn : EndIf
	With *vlc
		If \windowfull:CloseWindow(\windowfull):EndIf
		If \windowmin:CloseWindow(\windowmin):EndIf
		If \libvlc_event_log
			libvlc_log_unset(\libvlc)
		EndIf
		libvlc_media_player_stop(\libvlc_media_player)
		If \libvlc_event_Buffering
			libvlc_event_detach(\libvlc_event_Buffering,#libvlc_MediaPlayerBuffering,@vlc_eventBuffering(),*vlc)
		EndIf
		If \libvlc_event_Playing
			libvlc_event_detach(\libvlc_event_Playing,#libvlc_MediaPlayerPlaying,@vlc_eventPlaying(),*vlc)
		EndIf
		If \libvlc_event_NextItemSet
			libvlc_event_detach(\libvlc_event_NextItemSet,#libvlc_MediaListPlayerNextItemSet,@vlc_eventNextItemSet(),*vlc)
		EndIf		
		If \libvlc_media_list
			libvlc_media_list_release(\libvlc_media_list)
		EndIf
		If \libvlc_media_list_player
			libvlc_media_list_player_release(\libvlc_media_list_player)
		EndIf
		libvlc_media_player_release(\libvlc_media_player)
		libvlc_release(\libvlc)
	EndWith
	FreeMemory(*vlc)
EndProcedure

Procedure vlc_loadmedia(*vlc.vlc,path.s,option.s)
	If vlc_libisloaded = 0:ProcedureReturn:EndIf
	If *vlc = 0 : ProcedureReturn : EndIf
	With *vlc
		Protected libvlc_media,parse_flags
		If FileSize(path) > 0
			libvlc_media = libvlc_media_new_path(\libvlc,path)
			parse_flags = #libvlc_media_parse_local
		Else
			libvlc_media = libvlc_media_new_location(\libvlc,path)
			parse_flags = #libvlc_media_parse_network
		EndIf
		If libvlc_media
 			libvlc_media_add_option(libvlc_media,option)    
		EndIf
	EndWith
	ProcedureReturn libvlc_media
EndProcedure

Procedure vlc_play(*vlc.vlc,path.s,option.s=":network-caching=1000")
	If vlc_libisloaded = 0:ProcedureReturn:EndIf
	If *vlc = 0 : ProcedureReturn : EndIf
	With *vlc
		libvlc_media_player_stop(\libvlc_media_player)
		FillMemory(*vlc+ OffsetOf(vlc\is_Buffering), SizeOf(vlc)- OffsetOf(vlc\is_Buffering))
		Protected libvlc_media = vlc_loadmedia(*vlc,path,option)
		If libvlc_media
			libvlc_media_player_set_media(\libvlc_media_player,libvlc_media)
			libvlc_media_release(libvlc_media)
			libvlc_media_player_play(\libvlc_media_player)	
		EndIf
		ProcedureReturn libvlc_media
	EndWith
EndProcedure

Procedure vlc_getmedia(*vlc.vlc)
	If vlc_libisloaded = 0:ProcedureReturn:EndIf
	If *vlc = 0 : ProcedureReturn : EndIf
	ProcedureReturn libvlc_media_player_get_media(*vlc\libvlc_media_player)
EndProcedure

Procedure vlc_getmediaplayer(*vlc.vlc)
	If vlc_libisloaded = 0:ProcedureReturn:EndIf
	If *vlc = 0 : ProcedureReturn : EndIf
	ProcedureReturn *vlc\libvlc_media_player
EndProcedure

Procedure vlc_addplaylist(*vlc.vlc,path.s,play = 0,option.s=":network-caching=1000")
	If vlc_libisloaded = 0:ProcedureReturn:EndIf
	If *vlc = 0 : ProcedureReturn : EndIf
	With *vlc
		If \libvlc_media_list
			Protected libvlc_media = vlc_loadmedia(*vlc,path,option)
			If libvlc_media
				libvlc_media_list_add_media(\libvlc_media_list,libvlc_media)
				libvlc_media_release(libvlc_media)
				If play:libvlc_media_list_player_play_item(\libvlc_media_list_player,libvlc_media):EndIf
			EndIf
			ProcedureReturn libvlc_media
		EndIf
	EndWith
EndProcedure

Procedure vlc_removeplaylistmedia(*vlc.vlc,libvlc_media)
	If vlc_libisloaded = 0:ProcedureReturn:EndIf
	If *vlc = 0 : ProcedureReturn : EndIf
	With *vlc
		If \libvlc_media_list 
			Protected idx.l = libvlc_media_list_index_of_item(\libvlc_media_list,libvlc_media)
			If idx <> -1:ProcedureReturn libvlc_media_list_remove_index(\libvlc_media_list,idx):EndIf
		EndIf
	EndWith
EndProcedure

Procedure vlc_clearplaylist(*vlc.vlc)
	If vlc_libisloaded = 0:ProcedureReturn:EndIf
	If *vlc = 0 : ProcedureReturn : EndIf
	With *vlc
		If \libvlc_media_list And \libvlc_media_list_player
			libvlc_media_list_release(\libvlc_media_list)
			\libvlc_media_list = libvlc_media_list_new(\libvlc)
			libvlc_media_list_player_set_media_list(\libvlc_media_list_player,\libvlc_media_list)
		EndIf
	EndWith
EndProcedure

Procedure vlc_setplaylistmode(*vlc.vlc, mode)
	If vlc_libisloaded = 0:ProcedureReturn:EndIf
	If *vlc = 0 : ProcedureReturn : EndIf
	With *vlc
		If \libvlc_media_list_player:ProcedureReturn libvlc_media_list_player_set_playback_mode(\libvlc_media_list_player, mode):EndIf
	EndWith
EndProcedure
Macro vlc_setplaylistmodeloop(vlc)
	vlc_setplaylistmode(vlc, #libvlc_playback_mode_loop )
EndMacro
Macro vlc_setplaylistmoderepeat(vlc)
	vlc_setplaylistmode(vlc, #libvlc_playback_mode_repeat )
EndMacro
Macro vlc_setplaylistmodedefault(vlc)
	vlc_setplaylistmode(vlc, #libvlc_playback_mode_default )
EndMacro

Procedure vlc_playplaylist(*vlc.vlc)
	If vlc_libisloaded = 0:ProcedureReturn:EndIf
	If *vlc = 0 : ProcedureReturn : EndIf
	With *vlc
		If \libvlc_media_list_player:ProcedureReturn libvlc_media_list_player_play(\libvlc_media_list_player):EndIf
	EndWith
EndProcedure

Procedure vlc_playplaylistmedia(*vlc.vlc,libvlc_media)
	If vlc_libisloaded = 0:ProcedureReturn:EndIf
	If *vlc = 0 : ProcedureReturn : EndIf
	With *vlc
		If \libvlc_media_list_player:ProcedureReturn libvlc_media_list_player_play_item(\libvlc_media_list_player,libvlc_media):EndIf
	EndWith
EndProcedure

Procedure vlc_playplaylistnext(*vlc.vlc)
	If vlc_libisloaded = 0:ProcedureReturn:EndIf
	If *vlc = 0 : ProcedureReturn : EndIf
	With *vlc
		If \libvlc_media_list_player:ProcedureReturn libvlc_media_list_player_next(\libvlc_media_list_player):EndIf
	EndWith
EndProcedure

Procedure vlc_playplaylistprevious(*vlc.vlc)
	If vlc_libisloaded = 0:ProcedureReturn:EndIf
	If *vlc = 0 : ProcedureReturn : EndIf
	With *vlc
		If \libvlc_media_list_player:ProcedureReturn libvlc_media_list_player_previous(\libvlc_media_list_player):EndIf
	EndWith
EndProcedure

Procedure vlc_replay(*vlc.vlc)
	If vlc_libisloaded = 0:ProcedureReturn:EndIf
	If *vlc = 0 : ProcedureReturn : EndIf
	With *vlc
		libvlc_media_player_stop(\libvlc_media_player)
		libvlc_media_player_play(\libvlc_media_player)
	EndWith
EndProcedure

Procedure vlc_stopplayer(*vlc.vlc)
	If vlc_libisloaded = 0:ProcedureReturn:EndIf
	If *vlc = 0 : ProcedureReturn : EndIf
	ProcedureReturn libvlc_media_player_stop(*vlc\libvlc_media_player)
EndProcedure

Procedure vlc_pauseplay(*vlc.vlc)
	If vlc_libisloaded = 0:ProcedureReturn:EndIf
	If *vlc = 0 : ProcedureReturn : EndIf
	With *vlc
		If \is_paused:\is_paused = 0:Else:\is_paused = 1:EndIf
		If libvlc_media_player_is_playing(\libvlc_media_player) = 0 And \is_paused = 1
			\is_paused = 0
		EndIf
		libvlc_media_player_set_pause(\libvlc_media_player,\is_paused)
		ProcedureReturn \is_paused
	EndWith
EndProcedure

Procedure vlc_onoffsound(*vlc.vlc)
	If vlc_libisloaded = 0:ProcedureReturn:EndIf
	If *vlc = 0 : ProcedureReturn : EndIf
	With *vlc
		If \is_muted: \is_muted = 0:Else:\is_muted = 1:EndIf
		libvlc_audio_set_mute(\libvlc_media_player,\is_muted)
		If libvlc_audio_get_mute(\libvlc_media_player) = 1 And \is_muted = 0
			\is_muted = 1
		EndIf
		ProcedureReturn \is_muted
	EndWith
EndProcedure

Procedure vlc_setposition(*vlc.vlc,ppos.q,max.q = 100)
	If vlc_libisloaded = 0:ProcedureReturn:EndIf
	If *vlc = 0 : ProcedureReturn : EndIf
	With *vlc
		If libvlc_media_player_is_seekable(\libvlc_media_player)
			Protected fpos.d
			If max > 0
				If ppos:fpos.d = ppos / max:EndIf
				ppos = libvlc_media_player_get_length(\libvlc_media_player) * fpos		
				ProcedureReturn libvlc_media_player_set_time(\libvlc_media_player,ppos,1)
			EndIf
		EndIf
	EndWith
EndProcedure

Procedure vlc_setvolume(*vlc.vlc,vol)
	If vlc_libisloaded = 0:ProcedureReturn:EndIf
	If *vlc = 0 : ProcedureReturn : EndIf
	With *vlc
		\vol = vol
		libvlc_audio_set_volume(\libvlc_media_player,\vol)
	EndWith
EndProcedure

Procedure.q vlc_getlength(*vlc.vlc)
	If vlc_libisloaded = 0:ProcedureReturn:EndIf
	If *vlc = 0 : ProcedureReturn : EndIf
	ProcedureReturn libvlc_media_player_get_length(*vlc\libvlc_media_player)
EndProcedure

Procedure.q vlc_gettime(*vlc.vlc)
	If vlc_libisloaded = 0:ProcedureReturn:EndIf
	If *vlc = 0 : ProcedureReturn : EndIf
	ProcedureReturn libvlc_media_player_get_time(*vlc\libvlc_media_player)
EndProcedure

Procedure vlc_getmediastats(*vlc.vlc,*libvlc_media_stats.libvlc_media_stats_t)
	If vlc_libisloaded = 0:ProcedureReturn:EndIf
	If *vlc = 0 : ProcedureReturn : EndIf  
	With *vlc
		Protected libvlc_media = libvlc_media_player_get_media(\libvlc_media_player)
		If libvlc_media:ProcedureReturn libvlc_media_get_stats(libvlc_media,*libvlc_media_stats):EndIf     
	EndWith
EndProcedure

Procedure vlc_getreadrate(*vlc.vlc)
	If vlc_libisloaded = 0:ProcedureReturn:EndIf
	If *vlc = 0 : ProcedureReturn : EndIf
	With *vlc
		Protected libvlc_media_stats.libvlc_media_stats_t
		If vlc_getmediastats(*vlc,@libvlc_media_stats)
			Protected time.q = ElapsedMilliseconds()
			Protected el = time - \download_timer
			If el > 999
				\download_rate =  ((libvlc_media_stats\i_read_bytes-\download_size) * 1000) 
				If \download_rate > 0
					\download_rate / el
					\download_rate /1024
				Else
					\download_rate = 0
				EndIf
				\download_timer = time
				\download_size = libvlc_media_stats\i_read_bytes
			EndIf
			ProcedureReturn \download_rate
		EndIf
	EndWith
EndProcedure

Procedure.s vlc_getcodecdescription(i_type,i_codec)
	ProcedureReturn vlc_safePeekS(libvlc_media_get_codec_description(i_type,i_codec))
EndProcedure

Macro copymediatrackinfo(llist)
	llist\i_codec = *mt\track[i]\i_codec
	llist\i_original_fourcc = *mt\track[i]\i_original_fourcc
	llist\i_id = *mt\track[i]\i_id
	llist\i_type = *mt\track[i]\i_type
	llist\i_profile = *mt\track[i]\i_profile
	llist\i_level = *mt\track[i]\i_level
	llist\i_bitrate = *mt\track[i]\i_bitrate
	llist\psz_language = vlc_safePeekS(*mt\track[i]\psz_description)
	llist\psz_description = vlc_safePeekS(*mt\track[i]\psz_description)
	llist\codecdescription = vlc_getcodecdescription(*mt\track[i]\i_type ,*mt\track[i]\i_codec)
EndMacro
Procedure vlc_getmediatracklist(*vlc.vlc,List videotrackinfo.vlc_video_track(),List audiotrackinfo.vlc_audio_track(),
                                List subtrackinfo.vlc_subtitle_track())
	ClearList(videotrackinfo())
	ClearList(audiotrackinfo())
	ClearList(subtrackinfo())
	If vlc_libisloaded = 0:ProcedureReturn:EndIf
	If *vlc = 0 : ProcedureReturn : EndIf  
	With *vlc
		Protected libvlc_media = libvlc_media_player_get_media(\libvlc_media_player)
		If libvlc_media
			Protected *mt.pplibvlc_media_track_t
			Protected c=  libvlc_media_tracks_get(libvlc_media,@*mt)
			Protected i
			For i = 0 To c-1
				Select *mt\track[i]\i_type 
					Case #libvlc_track_video
						AddElement(videotrackinfo())
						copymediatrackinfo(videotrackinfo())
						videotrackinfo()\i_height = *mt\track[i]\video\i_height
						videotrackinfo()\i_width = *mt\track[i]\video\i_width
						videotrackinfo()\i_sar_num = *mt\track[i]\video\i_sar_num
						videotrackinfo()\i_sar_den = *mt\track[i]\video\i_sar_den
						videotrackinfo()\i_frame_rate_num = *mt\track[i]\video\i_frame_rate_num
						videotrackinfo()\i_frame_rate_den = *mt\track[i]\video\i_frame_rate_den
						videotrackinfo()\i_orientation = *mt\track[i]\video\i_orientation
						videotrackinfo()\i_projection = *mt\track[i]\video\i_projection
						videotrackinfo()\f_yaw = *mt\track[i]\video\pose\f_yaw
						videotrackinfo()\f_pitch = *mt\track[i]\video\pose\f_pitch
						videotrackinfo()\f_roll = *mt\track[i]\video\pose\f_roll
						videotrackinfo()\f_field_of_view = *mt\track[i]\video\pose\f_field_of_view
					Case #libvlc_track_audio
						AddElement(audiotrackinfo())
						copymediatrackinfo(audiotrackinfo())
						audiotrackinfo()\i_channels = *mt\track[i]\audio\i_channels
						audiotrackinfo()\i_rate = *mt\track[i]\audio\i_rate
					Case #libvlc_track_text
						AddElement(subtrackinfo())
						copymediatrackinfo(subtrackinfo())
						subtrackinfo()\psz_encoding = vlc_safePeekS(*mt\track[i]\subtitle\psz_encoding)
					Case #libvlc_track_unknown
				EndSelect
			Next   
			libvlc_media_tracks_release(*mt,c)
			ProcedureReturn c
		EndIf
	EndWith
EndProcedure

Procedure.s vlc_getmeta(*vlc.vlc,type)
	If vlc_libisloaded = 0:ProcedureReturn:EndIf
	If *vlc = 0 : ProcedureReturn : EndIf  
	With *vlc
		Protected libvlc_media = libvlc_media_player_get_media(\libvlc_media_player)
		If libvlc_media:ProcedureReturn vlc_safePeekS(libvlc_media_get_meta(libvlc_media, type)):EndIf
	EndWith
EndProcedure

Procedure.s vlc_getmedialoaction(*vlc.vlc)
	If vlc_libisloaded = 0:ProcedureReturn:EndIf
	If *vlc = 0 : ProcedureReturn : EndIf  
	With *vlc
		Protected libvlc_media = libvlc_media_player_get_media(\libvlc_media_player)
		If libvlc_media:ProcedureReturn vlc_safePeekS(libvlc_media_get_mrl(libvlc_media)):EndIf
	EndWith
EndProcedure

Procedure vlc_getplayerstate(*vlc.vlc)
	If vlc_libisloaded = 0:ProcedureReturn:EndIf
	If *vlc = 0 : ProcedureReturn : EndIf  
	With *vlc
		Protected state = libvlc_media_player_get_state(\libvlc_media_player)
		If \is_NextItemSet
			state = #libvlc_MediaListPlayerNextItemSet
			\is_NextItemSet = 0
		ElseIf \is_Buffering
			state = #libvlc_Buffering
			\is_Buffering = 0
		EndIf
		ProcedureReturn state
	EndWith
EndProcedure

Procedure.s vlc_version()
	ProcedureReturn vlc_safePeekS(libvlc_get_version ())
EndProcedure

Procedure vlc_getvideowidth(*vlc.vlc,vn = 0)
	If vlc_libisloaded = 0:ProcedureReturn:EndIf
	If *vlc = 0 : ProcedureReturn : EndIf
	Protected w.l,h.l
	libvlc_video_get_size(*vlc\libvlc_media_player,vn,@w,@h)
	ProcedureReturn w
EndProcedure

Procedure vlc_getvideoheight(*vlc.vlc,vn = 0)
	If vlc_libisloaded = 0:ProcedureReturn:EndIf
	If *vlc = 0 : ProcedureReturn : EndIf
	Protected w.l,h.l
	libvlc_video_get_size(*vlc\libvlc_media_player,vn,@w,@h)
	ProcedureReturn h
EndProcedure

Procedure vlc_setvideoaspectratio(*vlc.vlc,spectratio.s);"( "1:1( "4:3( "5:4( 16:9( "16:10( "221:100( "235:100( "239:100"
	If vlc_libisloaded = 0:ProcedureReturn:EndIf
	If *vlc = 0 : ProcedureReturn : EndIf
	ProcedureReturn libvlc_video_set_aspect_ratio(*vlc\libvlc_media_player,spectratio)
EndProcedure

Procedure.s vlc_getvideoaspectratio(*vlc.vlc)
	If vlc_libisloaded = 0:ProcedureReturn:EndIf
	If *vlc = 0 : ProcedureReturn : EndIf
	Protected p = libvlc_video_get_aspect_ratio(*vlc\libvlc_media_player)
	If p
		Protected r.s = vlc_safePeekS(p)
		libvlc_free(p)
		ProcedureReturn r
	EndIf
EndProcedure

Procedure.f vlc_getvideoscale(*vlc.vlc)
	If vlc_libisloaded = 0:ProcedureReturn:EndIf
	If *vlc = 0 : ProcedureReturn : EndIf
	ProcedureReturn libvlc_video_get_scale(*vlc\libvlc_media_player)
EndProcedure

Procedure vlc_setvideoscale(*vlc.vlc,scale.f)
	If vlc_libisloaded = 0:ProcedureReturn:EndIf
	If *vlc = 0 : ProcedureReturn : EndIf
	ProcedureReturn libvlc_video_set_scale(*vlc\libvlc_media_player,scale)
EndProcedure

Procedure vlc_getaudiotrackdescriptionlist(*vlc.vlc, List Listtrackdescription.vlc_track_description())
	ClearList(Listtrackdescription())
	If vlc_libisloaded = 0:ProcedureReturn:EndIf
	If *vlc = 0 : ProcedureReturn : EndIf
	With *vlc
		Protected ct = libvlc_audio_get_track_count(\libvlc_media_player)
		Protected *p_track.libvlc_track_description_t = libvlc_audio_get_track_description(\libvlc_media_player)
		If *p_track
			Protected *sp_track = *p_track
			Protected i
			For i = 1 To ct
				AddElement(Listtrackdescription())
				Listtrackdescription()\psz_name = vlc_safePeekS(*p_track\psz_name)
				Listtrackdescription()\i_id = *p_track\i_id
				*p_track = *p_track\p_next
			Next
			libvlc_track_description_list_release(*sp_track)
			ProcedureReturn ct
		EndIf
	EndWith
EndProcedure

Procedure vlc_setaudiotrack(*vlc.vlc,i_id)
	If vlc_libisloaded = 0:ProcedureReturn:EndIf
	If *vlc = 0 : ProcedureReturn : EndIf
	ProcedureReturn libvlc_audio_set_track(*vlc\libvlc_media_player,i_id)
EndProcedure

Procedure vlc_getaudiotrack(*vlc.vlc)
	If vlc_libisloaded = 0:ProcedureReturn:EndIf
	If *vlc = 0 : ProcedureReturn : EndIf
	ProcedureReturn libvlc_audio_get_track(*vlc\libvlc_media_player)
EndProcedure

Procedure vlc_getaudiooutputlist(*vlc.vlc, List Listoutput.vlc_audio_output())
	ClearList(Listoutput())
	If vlc_libisloaded = 0:ProcedureReturn:EndIf
	If *vlc = 0 : ProcedureReturn : EndIf
	With *vlc
		Protected ct = 0
		Protected *p_do.libvlc_audio_output_t = libvlc_audio_output_list_get(\libvlc)
		If *p_do
			Protected *sp_do = *p_do
			If *p_do
				Repeat
					ct+1
					AddElement(Listoutput())
					Listoutput()\psz_name = vlc_safePeekS(*p_do\psz_name)	
					Listoutput()\psz_description = vlc_safePeekS(*p_do\psz_description)	
					*p_do = *p_do\p_next
				Until *p_do = 0
				libvlc_audio_output_list_release(*sp_do)
				ProcedureReturn ct
			EndIf
		EndIf
	EndWith
EndProcedure

Procedure vlc_setaudiooutput(*vlc.vlc,psz_name .s)
	If vlc_libisloaded = 0:ProcedureReturn:EndIf
	If *vlc = 0 : ProcedureReturn : EndIf
	ProcedureReturn libvlc_audio_output_set(*vlc\libvlc_media_player,psz_name)
EndProcedure

Procedure vlc_getaudiooutputdeviceenumlist(*vlc.vlc, List Listoutputdevice.vlc_audio_output_device())
	ClearList(Listoutputdevice())
	If vlc_libisloaded = 0:ProcedureReturn:EndIf
	If *vlc = 0 : ProcedureReturn : EndIf
	With *vlc
		Protected ct = 0
		Protected *p_do.libvlc_audio_output_device_t = libvlc_audio_output_device_enum(\libvlc_media_player)
		If *p_do
			Protected *sp_do = *p_do
			If *p_do
				Repeat
					ct+1
					AddElement(Listoutputdevice())
					Listoutputdevice()\psz_device = vlc_safePeekS(*p_do\psz_device)	
					Listoutputdevice()\psz_description = vlc_safePeekS(*p_do\psz_description)	
					*p_do = *p_do\p_next
				Until *p_do = 0
				libvlc_audio_output_device_list_release(*sp_do)
				ProcedureReturn ct
			EndIf
		EndIf
	EndWith
EndProcedure

Procedure vlc_getaudiooutputdevicelist(*vlc.vlc, List Listoutputdevice.vlc_audio_output_device(),aout.s)
	ClearList(Listoutputdevice())
	If vlc_libisloaded = 0:ProcedureReturn:EndIf
	If *vlc = 0 : ProcedureReturn : EndIf
	With *vlc
		Protected ct = 0
		Protected *p_do.libvlc_audio_output_device_t = libvlc_audio_output_device_list_get(\libvlc,aout)
		If *p_do
			Protected *sp_do = *p_do
			If *p_do
				Repeat
					ct+1
					AddElement(Listoutputdevice())
					Listoutputdevice()\psz_device = vlc_safePeekS(*p_do\psz_device)	
					Listoutputdevice()\psz_description = vlc_safePeekS(*p_do\psz_description)	
					*p_do = *p_do\p_next
				Until *p_do = 0
				libvlc_audio_output_device_list_release(*sp_do)
				ProcedureReturn ct
			EndIf
		EndIf
	EndWith
EndProcedure

Procedure vlc_setaudiooutputdevice(*vlc.vlc,sModule.s,psz_device.s)
	If vlc_libisloaded = 0:ProcedureReturn:EndIf
	If *vlc = 0 : ProcedureReturn : EndIf
	Protected pModule = 0
	If sModule <> "":pModule = UTF8(sModule):EndIf
	Protected r = libvlc_audio_output_device_set(*vlc\libvlc_media_player,pModule,psz_device)
	If pModule:FreeMemory(pModule):EndIf
	ProcedureReturn r
EndProcedure

Procedure.s vlc_getaudiooutputdevice(*vlc.vlc)
	If vlc_libisloaded = 0:ProcedureReturn:EndIf
	If *vlc = 0 : ProcedureReturn : EndIf
	Protected p = libvlc_audio_output_device_get(*vlc\libvlc_media_player)
	If p
		Protected r.s = vlc_safePeekS(p)
		libvlc_free(p)
		ProcedureReturn r
	EndIf
EndProcedure

Procedure vlc_getcpudescriptionlist(*vlc.vlc, List Listtrackdescription.vlc_track_description())
	ClearList(Listtrackdescription())
	If vlc_libisloaded = 0:ProcedureReturn:EndIf
	If *vlc = 0 : ProcedureReturn : EndIf
	With *vlc
		Protected ct = libvlc_video_get_spu_count(\libvlc_media_player)
		Protected *p_track.libvlc_track_description_t = libvlc_video_get_spu_description(\libvlc_media_player)
		If *p_track
			Protected *sp_track = *p_track
			Protected i
			For i = 1 To ct
				AddElement(Listtrackdescription())
				Listtrackdescription()\psz_name = vlc_safePeekS(*p_track\psz_name)	
				Listtrackdescription()\i_id = *p_track\i_id
				*p_track = *p_track\p_next
			Next
			libvlc_track_description_list_release(*sp_track)
			ProcedureReturn ct
		EndIf
	EndWith
EndProcedure

Procedure vlc_setcpu(*vlc.vlc,i_id)
	If vlc_libisloaded = 0:ProcedureReturn:EndIf
	If *vlc = 0 : ProcedureReturn : EndIf
	ProcedureReturn libvlc_video_set_spu(*vlc\libvlc_media_player,i_id)
EndProcedure

Procedure vlc_getcpu(*vlc.vlc)
	If vlc_libisloaded = 0:ProcedureReturn:EndIf
	If *vlc = 0 : ProcedureReturn : EndIf
	ProcedureReturn libvlc_video_get_spu(*vlc\libvlc_media_player)
EndProcedure

Procedure.q vlc_getcpudelay(*vlc.vlc)
	If vlc_libisloaded = 0:ProcedureReturn:EndIf
	If *vlc = 0 : ProcedureReturn : EndIf
	ProcedureReturn libvlc_video_get_spu_delay(*vlc\libvlc_media_player)
EndProcedure

Procedure vlc_setcpudelay(*vlc.vlc,i_delay.q)
	If vlc_libisloaded = 0:ProcedureReturn:EndIf
	If *vlc = 0 : ProcedureReturn : EndIf
	ProcedureReturn libvlc_video_set_spu_delay(*vlc\libvlc_media_player,i_delay)
EndProcedure

Procedure vlc_getvideotrackdescriptionlist(*vlc.vlc, List Listtrackdescription.vlc_track_description())
	ClearList(Listtrackdescription())
	If vlc_libisloaded = 0:ProcedureReturn:EndIf
	If *vlc = 0 : ProcedureReturn : EndIf
	With *vlc
		Protected ct = libvlc_video_get_track_count(\libvlc_media_player)
		Protected *p_track.libvlc_track_description_t = libvlc_video_get_track_description(\libvlc_media_player)
		If *p_track
			Protected *sp_track = *p_track
			Protected i
			For i = 1 To ct
				AddElement(Listtrackdescription())
				Listtrackdescription()\psz_name = vlc_safePeekS(*p_track\psz_name)	
				Listtrackdescription()\i_id = *p_track\i_id
				*p_track = *p_track\p_next
			Next
			libvlc_track_description_list_release(*sp_track)
			ProcedureReturn ct
		EndIf
	EndWith
EndProcedure

Procedure vlc_setvideotrack(*vlc.vlc,i_id)
	If vlc_libisloaded = 0:ProcedureReturn:EndIf
	If *vlc = 0 : ProcedureReturn : EndIf
	ProcedureReturn libvlc_video_set_track(*vlc\libvlc_media_player,i_id)
EndProcedure

Procedure vlc_getvideotrack(*vlc.vlc)
	If vlc_libisloaded = 0:ProcedureReturn:EndIf
	If *vlc = 0 : ProcedureReturn : EndIf
	ProcedureReturn libvlc_video_get_track(*vlc\libvlc_media_player)
EndProcedure

Procedure vlc_setaudiochannel(*vlc.vlc,channel)
	If vlc_libisloaded = 0:ProcedureReturn:EndIf
	If *vlc = 0 : ProcedureReturn : EndIf
	ProcedureReturn libvlc_audio_set_channel(*vlc\libvlc_media_player,channel)
EndProcedure

Macro vlc_setaudioStereochannel(vlc)
	vlc_setaudiochannel(vlc,#libvlc_AudioChannel_Stereo)
EndMacro
Macro vlc_setaudioRStereochannel(vlc)
	vlc_setaudiochannel(vlc,#libvlc_AudioChannel_RStereo)
EndMacro
Macro vlc_setaudioLeftchannel(vlc)
	vlc_setaudiochannel(vlc,#libvlc_AudioChannel_Left)
EndMacro
Macro vlc_setaudioRightchannel(vlc)
	vlc_setaudiochannel(vlc,#libvlc_AudioChannel_Right)
EndMacro
Macro vlc_setaudioDolbyschannel(vlc)
	vlc_setaudiochannel(vlc,#libvlc_AudioChannel_Dolbys)
EndMacro

DisableExplicit




; 
; 

; IDE Options = PureBasic 5.73 LTS (Windows - x64)
; CursorPosition = 11
; FirstLine = 770
; Folding = ------------
; EnableThread
; EnableXP