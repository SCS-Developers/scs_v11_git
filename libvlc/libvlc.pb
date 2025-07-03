; * Description For titles
Enumeration
	#libvlc_title_menu          = $01
	#libvlc_title_interactive   = $02
EndEnumeration

Enumeration libvlc_video_marquee_option_t 
	#libvlc_marquee_Enable = 0
	#libvlc_marquee_Text                  ;/** string argument */
	#libvlc_marquee_Color
	#libvlc_marquee_Opacity
	#libvlc_marquee_Position
	#libvlc_marquee_Refresh
	#libvlc_marquee_Size
	#libvlc_marquee_Timeout
	#libvlc_marquee_X
	#libvlc_marquee_Y
EndEnumeration

; #* Navigation mode
Enumeration libvlc_navigate_mode_t
	#libvlc_navigate_activate = 0
	#libvlc_navigate_up
	#libvlc_navigate_down
	#libvlc_navigate_left
	#libvlc_navigate_right
	#libvlc_navigate_popup
EndEnumeration

; #* Enumeration of values used To set position (e.g. of video title).
Enumeration libvlc_position_t 
	#libvlc_position_disable=-1
	#libvlc_position_center
	#libvlc_position_left
	#libvlc_position_right
	#libvlc_position_top
	#libvlc_position_top_left
	#libvlc_position_top_right
	#libvlc_position_bottom
	#libvlc_position_bottom_left
	#libvlc_position_bottom_right
EndEnumeration

; #* Enumeration of teletext keys than can be passed via
; #* libvlc_video_set_teletext()
Enumeration libvlc_teletext_key_t 
	#libvlc_teletext_key_red = 'r' << 16
	#libvlc_teletext_key_green = 'g' << 16
	#libvlc_teletext_key_yellow = 'y' << 16
	#libvlc_teletext_key_blue = 'b' << 16
	#libvlc_teletext_key_index = 'i' << 16
EndEnumeration

; #* Enumeration of the Video color primaries.
Enumeration libvlc_video_color_primaries_t 
	#libvlc_video_primaries_BT601_525 = 1
	#libvlc_video_primaries_BT601_625 = 2
	#libvlc_video_primaries_BT709     = 3
	#libvlc_video_primaries_BT2020    = 4
	#libvlc_video_primaries_DCI_P3    = 5
	#libvlc_video_primaries_BT470_M   = 6
EndEnumeration

; #* Enumeration of the Video color spaces.
Enumeration libvlc_video_color_space_t 
	#libvlc_video_colorspace_BT601  = 1
	#libvlc_video_colorspace_BT709  = 2
	#libvlc_video_colorspace_BT2020 = 3
EndEnumeration

; #* Enumeration of the Video transfer functions.
Enumeration libvlc_video_transfer_func_t 
	#libvlc_video_transfer_func_LINEAR     = 1
	#libvlc_video_transfer_func_SRGB       = 2
	#libvlc_video_transfer_func_BT470_BG   = 3
	#libvlc_video_transfer_func_BT470_M    = 4
	#libvlc_video_transfer_func_BT709      = 5
	#libvlc_video_transfer_func_PQ         = 6
	#libvlc_video_transfer_func_SMPTE_240  = 7
	#libvlc_video_transfer_func_HLG        = 8
EndEnumeration

Enumeration libvlc_video_metadata_type_t 
	#libvlc_video_metadata_frame_hdr10 ;/**< libvlc_video_frame_hdr10_metadata_t */
EndEnumeration

; #* Enumeration of the Video engine To be used on output.
; #* can be passed To @a libvlc_video_set_output_callbacks
Enumeration libvlc_video_engine_t 
	; ##/** Disable rendering engine */
	#libvlc_video_engine_disable
	#libvlc_video_engine_opengl
	#libvlc_video_engine_gles2
	; /** Direct3D11 rendering engine */
	#libvlc_video_engine_d3d11
	; /** Direct3D9 rendering engine */
	#libvlc_video_engine_d3d9
EndEnumeration

;  option values For libvlc_video_getset}_adjust_intfloatbool} */
Enumeration libvlc_video_adjust_option_t 
	#libvlc_adjust_Enable = 0
	#libvlc_adjust_Contrast
	#libvlc_adjust_Brightness
	#libvlc_adjust_Hue
	#libvlc_adjust_Saturation
	#libvlc_adjust_Gamma
EndEnumeration

; ##/** option values For libvlc_video_getset}_logo_intstring} */
Enumeration libvlc_video_logo_option_t 
	#libvlc_logo_enable
	#libvlc_logo_file          ; /**< string argument "filedt;filedt;..." */
	#libvlc_logo_x
	#libvlc_logo_y
	#libvlc_logo_delay
	#libvlc_logo_repeat
	#libvlc_logo_opacity
	#libvlc_logo_position
EndEnumeration

; * Audio channels
Enumeration libvlc_audio_output_channel_t 
	#libvlc_AudioChannel_Error   = -1
	#libvlc_AudioChannel_Stereo  =  1
	#libvlc_AudioChannel_RStereo =  2
	#libvlc_AudioChannel_Left    =  3
	#libvlc_AudioChannel_Right   =  4
	#libvlc_AudioChannel_Dolbys  =  5
EndEnumeration

; * Media player roles.
; *
; * \version LibVLC 3.0.0 And later.
; *
; * See \ref libvlc_media_player_set_role()
Enumeration libvlc_media_player_role 
	#libvlc_role_None = 0 ;/**< Don't use a media player role */
	#libvlc_role_Music		; /**< Music (Or radio) playback */
	#libvlc_role_Video		;/**< Video playback */
	#libvlc_role_Communication ;/**< Speech real-time communication */
	#libvlc_role_Game					 ;/**< Video game */
	#libvlc_role_Notification	 ;/**< User interaction feedback */
	#libvlc_role_Animation		 ;/**< Embedded animation (e.g. in web page) */
	#libvlc_role_Production		 ;/**< Audio editting/production */
	#libvlc_role_Accessibility ;/**< Accessibility */
	#libvlc_role_Test					 ;/** Testing */
	#libvlc_role_Last = #libvlc_role_Test
EndEnumeration

Enumeration libvlc_navigate_mode_t
	#libvlc_navigate_activate = 0
	#libvlc_navigate_up
	#libvlc_navigate_down
	#libvlc_navigate_left
	#libvlc_navigate_right
	#libvlc_navigate_popup
EndEnumeration     

Enumeration libvlc_position_t 
	#libvlc_position_disable=-1
	#libvlc_position_center
	#libvlc_position_left
	#libvlc_position_right
	#libvlc_position_top
	#libvlc_position_top_left
	#libvlc_position_top_right
	#libvlc_position_bottom
	#libvlc_position_bottom_left
	#libvlc_position_bottom_right
EndEnumeration  

Enumeration libvlc_teletext_key_t 
	#libvlc_teletext_key_red = 'r' << 16
	#libvlc_teletext_key_green = 'g' << 16
	#libvlc_teletext_key_yellow = 'y' << 16
	#libvlc_teletext_key_blue = 'b' << 16
	#libvlc_teletext_key_index = 'i' << 16
EndEnumeration      

Enumeration libvlc_video_color_primaries_t 
	#libvlc_video_primaries_BT601_525 = 1
	#libvlc_video_primaries_BT601_625 = 2
	#libvlc_video_primaries_BT709     = 3
	#libvlc_video_primaries_BT2020    = 4
	#libvlc_video_primaries_DCI_P3    = 5
	#libvlc_video_primaries_BT470_M   = 6
EndEnumeration      

Enumeration libvlc_video_color_space_t 
	#libvlc_video_colorspace_BT601  = 1
	#libvlc_video_colorspace_BT709  = 2
	#libvlc_video_colorspace_BT2020 = 3
EndEnumeration 

Enumeration libvlc_video_transfer_func_t 
	#libvlc_video_transfer_func_LINEAR     = 1
	#libvlc_video_transfer_func_SRGB       = 2
	#libvlc_video_transfer_func_BT470_BG   = 3
	#libvlc_video_transfer_func_BT470_M    = 4
	#libvlc_video_transfer_func_BT709      = 5
	#libvlc_video_transfer_func_PQ         = 6
	#libvlc_video_transfer_func_SMPTE_240  = 7
	#libvlc_video_transfer_func_HLG        = 8
EndEnumeration 

; Enumeration libvlc_video_metadata_type_t 
; 	#libvlc_video_metadata_frame_hdr10 ;/**< libvlc_video_frame_hdr10_metadata_t */
; EndEnumeration  

Enumeration libvlc_video_marquee_option_t 
	#libvlc_marquee_Enable = 0
	#libvlc_marquee_Text                 ;/** string argument */
	#libvlc_marquee_Color
	#libvlc_marquee_Opacity
	#libvlc_marquee_Position
	#libvlc_marquee_Refresh
	#libvlc_marquee_Size
	#libvlc_marquee_Timeout
	#libvlc_marquee_X
	#libvlc_marquee_Y
EndEnumeration

Enumeration libvlc_media_type_t 
	#libvlc_media_type_unknown
	#libvlc_media_type_file
	#libvlc_media_type_directory
	#libvlc_media_type_disc
	#libvlc_media_type_stream
	#libvlc_media_type_playlist
EndEnumeration

Enumeration libvlc_dialog_question_type
	#LIBVLC_DIALOG_QUESTION_NORMAL
	#LIBVLC_DIALOG_QUESTION_WARNING
	#LIBVLC_DIALOG_QUESTION_CRITICAL
EndEnumeration

Enumeration libvlc_log_level
	#LIBVLC_DEBUG=0   ;/**< Debug message */
	#LIBVLC_NOTICE=2	;/**< Important informational message */
	#LIBVLC_WARNING=3	;/**< Warning (potential error) message */
	#LIBVLC_ERROR_2=4	;/**< Error message */
EndEnumeration    

Enumeration vlc_log_type
	#VLC_MSG_INFO=0 ;/**< Important information */
	#VLC_MSG_ERR		;/**< Error */
	#VLC_MSG_WARN		;/**< Warning */
	#VLC_MSG_DBG		;/**< Debug */
EndEnumeration

Enumeration libvlc_track_type_t
	#libvlc_track_unknown   = -1
	#libvlc_track_audio     
	#libvlc_track_video     
	#libvlc_track_text      
EndEnumeration

Enumeration libvlc_meta_t
	#libvlc_meta_Title
	#libvlc_meta_Artist
	#libvlc_meta_Genre
	#libvlc_meta_Copyright
	#libvlc_meta_Album
	#libvlc_meta_TrackNumber
	#libvlc_meta_Description
	#libvlc_meta_Rating
	#libvlc_meta_Date
	#libvlc_meta_Setting
	#libvlc_meta_URL
	#libvlc_meta_Language
	#libvlc_meta_NowPlaying
	#libvlc_meta_Publisher
	#libvlc_meta_EncodedBy
	#libvlc_meta_ArtworkURL
	#libvlc_meta_TrackID
	#libvlc_meta_TrackTotal
	#libvlc_meta_Director
	#libvlc_meta_Season
	#libvlc_meta_Episode
	#libvlc_meta_ShowName
	#libvlc_meta_Actors
	#libvlc_meta_AlbumArtist
	#libvlc_meta_DiscNumber
	#libvlc_meta_DiscTotal
	;/* Add new meta types HERE */
EndEnumeration

Enumeration libvlc_state_t
	#libvlc_NothingSpecial=0
	#libvlc_Opening
	#libvlc_Buffering ;/* XXX: Deprecated value. Check the
										; * libvlc_MediaPlayerBuffering event To know the
										;* buffering state of a libvlc_media_player */
	#libvlc_Playing
	#libvlc_Paused
	#libvlc_Stopped
	#libvlc_Ended
	#libvlc_Error
EndEnumeration

Enumeration libvlc_media_parse_flag_t
	;     /**
	;      * Parse media If it's a local file
	;      */
	#libvlc_media_parse_local    = $00
	;     /**
	;      * Parse media even If it's a network file
	;      */
	#libvlc_media_parse_network  = $01
	;     /**
	;      * Fetch meta And covert art using local resources
	;      */
	#libvlc_media_fetch_local    = $02
	;     /**
	;      * Fetch meta And covert art using network resources
	;      */
	#libvlc_media_fetch_network  = $04
	;     /**
	;      * Interact With the user (via libvlc_dialog_cbs) when preparsing this item
	;      * (And Not its sub items). Set this flag in order To receive a callback
	;      * when the input is asking For credentials.
	;      */
	#libvlc_media_do_interact    = $08
EndEnumeration

Enumeration libvlc_media_parsed_status_t
	#libvlc_media_parsed_status_skipped = 1
	#libvlc_media_parsed_status_failed
	#libvlc_media_parsed_status_timeout
	#libvlc_media_parsed_status_done
EndEnumeration

Enumeration libvlc_event_e 
	;# /* Append new event types at the End of a category.
	;#  * Do Not remove insert Or re-order any entry.
	;#  * Keep this in sync With lib/event.c:libvlc_event_type_name(). */
	#libvlc_MediaMetaChanged=0
	#libvlc_MediaSubItemAdded
	#libvlc_MediaDurationChanged
	#libvlc_MediaParsedChanged
	#libvlc_MediaFreed
	#libvlc_MediaStateChanged
	#libvlc_MediaSubItemTreeAdded
	
	#libvlc_MediaPlayerMediaChanged=$100
	#libvlc_MediaPlayerNothingSpecial
	#libvlc_MediaPlayerOpening
	#libvlc_MediaPlayerBuffering
	#libvlc_MediaPlayerPlaying
	#libvlc_MediaPlayerPaused
	#libvlc_MediaPlayerStopped
	#libvlc_MediaPlayerForward
	#libvlc_MediaPlayerBackward
	#libvlc_MediaPlayerEndReached
	#libvlc_MediaPlayerEncounteredError
	#libvlc_MediaPlayerTimeChanged
	#libvlc_MediaPlayerPositionChanged
	#libvlc_MediaPlayerSeekableChanged
	#libvlc_MediaPlayerPausableChanged
	#libvlc_MediaPlayerTitleChanged
	#libvlc_MediaPlayerSnapshotTaken
	#libvlc_MediaPlayerLengthChanged
	#libvlc_MediaPlayerVout
	#libvlc_MediaPlayerScrambledChanged
	#libvlc_MediaPlayerESAdded
	#libvlc_MediaPlayerESDeleted
	#libvlc_MediaPlayerESSelected
	#libvlc_MediaPlayerCorked
	#libvlc_MediaPlayerUncorked
	#libvlc_MediaPlayerMuted
	#libvlc_MediaPlayerUnmuted
	#libvlc_MediaPlayerAudioVolume
	#libvlc_MediaPlayerAudioDevice
	#libvlc_MediaPlayerChapterChanged
	
	#libvlc_MediaListItemAdded=$200
	#libvlc_MediaListWillAddItem
	#libvlc_MediaListItemDeleted
	#libvlc_MediaListWillDeleteItem
	#libvlc_MediaListEndReached
	
	#libvlc_MediaListViewItemAdded=$300
	#libvlc_MediaListViewWillAddItem
	#libvlc_MediaListViewItemDeleted
	#libvlc_MediaListViewWillDeleteItem
	
	#libvlc_MediaListPlayerPlayed=$400
	#libvlc_MediaListPlayerNextItemSet
	#libvlc_MediaListPlayerStopped
	
	;# /**
	;#  * \deprecated Useless event it will be triggered only when calling
	;#  * libvlc_media_discoverer_start()
	;#  */
	#libvlc_MediaDiscovererStarted=$500
	;# /**
	;#  * \deprecated Useless event it will be triggered only when calling
	;#  * libvlc_media_discoverer_stop()
	;#  */
	#libvlc_MediaDiscovererEnded
	
	#libvlc_RendererDiscovererItemAdded
	#libvlc_RendererDiscovererItemDeleted
	
	#libvlc_VlmMediaAdded=$600
	#libvlc_VlmMediaRemoved
	#libvlc_VlmMediaChanged
	#libvlc_VlmMediaInstanceStarted
	#libvlc_VlmMediaInstanceStopped
	#libvlc_VlmMediaInstanceStatusInit
	#libvlc_VlmMediaInstanceStatusOpening
	#libvlc_VlmMediaInstanceStatusPlaying
	#libvlc_VlmMediaInstanceStatusPause
	#libvlc_VlmMediaInstanceStatusEnd
	#libvlc_VlmMediaInstanceStatusError
EndEnumeration

Enumeration libvlc_media_slave_type_t
	#libvlc_media_slave_type_subtitle
	#libvlc_media_slave_type_audio
EndEnumeration

Enumeration  	libvlc_thumbnailer_seek_speed_t 
	#libvlc_media_thumbnail_seek_precise
	#libvlc_media_thumbnail_seek_fast 
EndEnumeration

Enumeration libvlc_video_color_space_t 
	#libvlc_video_colorspace_BT601  = 1
	#libvlc_video_colorspace_BT709  = 2
	#libvlc_video_colorspace_BT2020 = 3
EndEnumeration     

Enumeration libvlc_video_color_primaries_t 
	#libvlc_video_primaries_BT601_525 = 1
	#libvlc_video_primaries_BT601_625 = 2
	#libvlc_video_primaries_BT709     = 3
	#libvlc_video_primaries_BT2020    = 4
	#libvlc_video_primaries_DCI_P3    = 5
	#libvlc_video_primaries_BT470_M   = 6
EndEnumeration     

Enumeration libvlc_video_transfer_func_t
	#libvlc_video_transfer_func_LINEAR     = 1
	#libvlc_video_transfer_func_SRGB       = 2
	#libvlc_video_transfer_func_BT470_BG   = 3
	#libvlc_video_transfer_func_BT470_M    = 4
	#libvlc_video_transfer_func_BT709      = 5
	#libvlc_video_transfer_func_PQ         = 6
	#libvlc_video_transfer_func_SMPTE_240  = 7
	#libvlc_video_transfer_func_HLG        = 8
EndEnumeration     

Enumeration libvlc_playback_mode_t
	#libvlc_playback_mode_default
	#libvlc_playback_mode_loop
	#libvlc_playback_mode_repeat
EndEnumeration
  
Structure libvlc_module_description_t Align #PB_Structure_AlignC 
	*psz_name
	*psz_shortname
	*psz_longname
	*psz_help
	*p_next.libvlc_module_description_t
EndStructure

Structure vlc_log_t Align #PB_Structure_AlignC 
	i_object_id.l ;/**< Emitter (temporarily) unique object ID Or 0 */
	*psz_object_type ;/**< Emitter object type name */
	*psz_module			 ;/**< Emitter Module (source code) */
	*psz_header			 ;/**< Additional header (used by VLM media) */
	*file						 ;/**< Source code file name Or NULL */
	line.l					 ;/**< Source code file line number Or -1 */
	*func						 ;/**< Source code calling function name Or NULL */
	tid.l						 ;/**< Emitter thread ID */
EndStructure

Structure libvlc_dialog_cbs Align #PB_Structure_AlignC 
	;     /**
	;      * Called when an error message needs To be displayed
	;      *
	;      * @param p_data opaque pointer For the callback
	;      * @param psz_title title of the dialog
	;      * @param psz_text text of the dialog
	;      */
	*pf_display_error
	
	;     /**
	;      * Called when a login dialog needs To be displayed
	;      *
	;      * You can interact With this dialog by calling libvlc_dialog_post_login()
	;      * To post an answer Or libvlc_dialog_dismiss() To cancel this dialog.
	;      *
	;      * @note To receive this callback, libvlc_dialog_cbs.pf_cancel should Not be
	;      * NULL.
	;      *
	;      * @param p_data opaque pointer For the callback
	;      * @param p_id id used To interact With the dialog
	;      * @param psz_title title of the dialog
	;      * @param psz_text text of the dialog
	;      * @param psz_default_username user name that should be set on the user form
	;      * @param b_ask_store If true, ask the user If he wants To save the
	;      * credentials
	;      */
	*pf_display_login
	
	;     /**
	;      * Called when a question dialog needs To be displayed
	;      *
	;      * You can interact With this dialog by calling libvlc_dialog_post_action()
	;      * To post an answer Or libvlc_dialog_dismiss() To cancel this dialog.
	;      *
	;      * @note To receive this callback, libvlc_dialog_cbs.pf_cancel should Not be
	;      * NULL.
	;      *
	;      * @param p_data opaque pointer For the callback
	;      * @param p_id id used To interact With the dialog
	;      * @param psz_title title of the dialog
	;      * @param psz_text text of the dialog
	;      * @param i_type question type (Or severity) of the dialog
	;      * @param psz_cancel text of the cancel button
	;      * @param psz_action1 text of the first button, If NULL, don't display this
	;      * button
	;      * @param psz_action2 text of the second button, If NULL, don't display
	;      * this button
	;      */
	*pf_display_question
	
	;     /**
	;      * Called when a progress dialog needs To be displayed
	;      *
	;      * If cancellable (psz_cancel != NULL), you can cancel this dialog by
	;      * calling libvlc_dialog_dismiss()
	;      *
	;      * @note To receive this callback, libvlc_dialog_cbs.pf_cancel And
	;      * libvlc_dialog_cbs.pf_update_progress should Not be NULL.
	;      *
	;      * @param p_data opaque pointer For the callback
	;      * @param p_id id used To interact With the dialog
	;      * @param psz_title title of the dialog
	;      * @param psz_text text of the dialog
	;      * @param b_indeterminate true If the progress dialog is indeterminate
	;      * @param f_position initial position of the progress bar (between 0.0 And
	;      * 1.0)
	;      * @param psz_cancel text of the cancel button, If NULL the dialog is Not
	;      * cancellable
	;      */
	*pf_display_progress
	
	;     /**
	;      * Called when a displayed dialog needs To be cancelled
	;      *
	;      * The implementation must call libvlc_dialog_dismiss() To really release
	;      * the dialog.
	;      *
	;      * @param p_data opaque pointer For the callback
	;      * @param p_id id of the dialog
	;      */
	*pf_cancel
	
	;     /**
	;      * Called when a progress dialog needs To be updated
	;      *
	;      * @param p_data opaque pointer For the callback
	;      * @param p_id id of the dialog
	;      * @param f_position osition of the progress bar (between 0.0 And 1.0)
	;      * @param psz_text new text of the progress dialog
	;      */
	*pf_update_progress
EndStructure

Structure libvlc_media_stats_t Align #PB_Structure_AlignC 
	;  	/* Input */
	i_read_bytes.l
	f_input_bitrate.f
	;  	/* Demux */
	i_demux_read_bytes.l
	f_demux_bitrate.f
	i_demux_corrupted.l
	i_demux_discontinuity.l
	;  	/* Decoders */
	i_decoded_video.l
	i_decoded_audio.l
	;  	/* Video Output */
	i_displayed_pictures.l
	i_lost_pictures.l
	;  	/* Audio output */
	i_played_abuffers.l
	i_lost_abuffers.l
	;  	/* Stream output */
	i_sent_packets.l
	i_sent_bytes.l
	f_send_bitrate.f
EndStructure

Structure libvlc_media_slave_t Align #PB_Structure_AlignC 
	*psz_uri
	i_type.l
	i_priority.l
EndStructure


Structure libvlc_track_description_t Align #PB_Structure_AlignC 
	i_id.l
	*psz_name
	*p_next.libvlc_track_description_t
EndStructure

Structure libvlc_title_description_t Align #PB_Structure_AlignC 
	i_duration.q ;/**< duration in milliseconds */
	*psz_name		 ;/**< title name */
	i_flags.l		 ;/**< info If item was recognized As a menu, interactive Or plain content by the demuxer */
EndStructure

Structure libvlc_chapter_description_t Align #PB_Structure_AlignC 
	i_time_offset.q ;/**< time-offset of the chapter in milliseconds */
	i_duration.q		;/**< duration of the chapter in milliseconds */
	*psz_name				;/**< chapter name */
EndStructure

Structure libvlc_audio_output_t Align #PB_Structure_AlignC
	*psz_name
	*psz_description
	*p_next.libvlc_audio_output_t
EndStructure

Structure libvlc_audio_output_device_t Align #PB_Structure_AlignC
	*p_next.libvlc_audio_output_device_t ;/**< Next entry in List */
	*psz_device													 ;/**< Device identifier string */
	*psz_description										 ;/**< User-friendly device description */
																			 ;/* More fields may be added here in later versions */
EndStructure

Structure libvlc_video_setup_device_cfg_t Align #PB_Structure_AlignC
	hardware_decoding.l
EndStructure

Structure libvlc_video_setup_device_info_t Align #PB_Structure_AlignC 
	StructureUnion
		*device_context ;/** ID3D11DeviceContext* */
		*context_mutex	;/** Windows Mutex HANDLE To protect ID3D11DeviceContext usage */
		*device					;/** IDirect3D9* */
		adapter.l				;/** Adapter To use With the IDirect3D9* */
	EndStructureUnion
EndStructure

Structure libvlc_video_render_cfg_t Align #PB_Structure_AlignC 
	width.l                     ;/** rendering video width in pixel */
	height.l										;/** rendering video height in pixel */
	bitdepth.l									;/** rendering video bit depth in bits per channel */
	full_range.l								;/** video is full range Or studio/limited range */
	libvlc_video_color_space_t.l;/** video color space */
	libvlc_video_color_primaries_t.l       ;/** video color primaries */
	libvlc_video_transfer_func_t.l				 ;/** video transfer function */
	*device																 ;/** device used For rendering, IDirect3DDevice9* For D3D9 */
EndStructure

Structure libvlc_video_output_cfg_t Align #PB_Structure_AlignC 
	StructureUnion
		dxgi_format.l  ;/** the rendering DXGI_FORMAT For \ref libvlc_video_engine_d3d11*/
		d3d9_format.l	 ;/** the rendering D3DFORMAT For \ref libvlc_video_engine_d3d9 */
		opengl_format.l;/** the rendering GLint GL_RGBA Or GL_RGB For \ref libvlc_video_engine_opengl And
									 ;For \ref libvlc_video_engine_gles2 */
		*p_surface		 ;/** currently unused */
	EndStructureUnion
	full_range.l          ;/** video is full range Or studio/limited range */
	libvlc_video_color_space_t.l              ;/** video color space */
	libvlc_video_color_primaries_t.l					;/** video color primaries */
	libvlc_video_transfer_func_t.l						;/** video transfer function */
EndStructure

Structure libvlc_video_frame_hdr10_metadata_t Align #PB_Structure_AlignC 
	;      /* similar To SMPTE ST 2086 mastering display color volume */
	RedPrimary.w[2]
	GreenPrimary.w[2]
	BluePrimary.w[2]
	WhitePoint.w[2]
	MaxMasteringLuminance.l
	MinMasteringLuminance.l
	MaxContentLightLevel.w
	MaxFrameAverageLightLevel.w
EndStructure

Structure libvlc_player_program_t Align #PB_Structure_AlignC 
	; /** Id used For libvlc_media_player_select_program() */
	i_group_id.l
	; /** Program name, always valid */
	*psz_name
	;  /** True If the program is selected */
	b_selected.l
	;  /** True If the program is scrambled */
	b_scrambled.l
EndStructure

Structure libvlc_video_viewpoint_t Align #PB_Structure_AlignC 
	f_yaw.f
	f_pitch.f
	f_roll.f
	f_field_of_view.f
	
EndStructure

Structure libvlc_video_track_t Align #PB_Structure_AlignC 
	i_height.l
	i_width.l
	i_sar_num.l
	i_sar_den.l
	i_frame_rate_num.l
	i_frame_rate_den.l
	i_orientation.l
	i_projection.l
	pose.libvlc_video_viewpoint_t
EndStructure

Structure libvlc_audio_track_t Align #PB_Structure_AlignC 
	i_channels.l
	i_rate.l
EndStructure

Structure libvlc_subtitle_track_t
	*psz_encoding
EndStructure

Structure libvlc_media_track_t Align #PB_Structure_AlignC 
	i_codec.l
	i_original_fourcc.l
	i_id.l
	i_type.l
	i_profile.l
	i_level.l
	StructureUnion
		*audio.libvlc_audio_track_t
		*video.libvlc_video_track_t
		*subtitle.libvlc_subtitle_track_t
	EndStructureUnion
	i_bitrate.l
	*psz_language
	*psz_description
EndStructure

Structure pplibvlc_media_track_t Align #PB_Structure_AlignC 
	*track.libvlc_media_track_t[0]
EndStructure

PrototypeC libvlc_new(argc, *argv)	
;Create and initialize a libvlc instance. More...
PrototypeC libvlc_release(libvlc_instance_t)
;Decrement the reference count of a libvlc instance, and destroy it if it reaches zero. More...
PrototypeC	libvlc_retain (libvlc_instance_t)
;Increments the reference count of a libvlc instance. More...
PrototypeC 	libvlc_add_intf (libvlc_instance_t, name.p-utf8)
;Try to start a user interface for the libvlc instance. More...
PrototypeC 	libvlc_set_exit_handler (libvlc_instance_t , *cb, *opaque)
;Registers a callback for the LibVLC exit event. More...
PrototypeC 	libvlc_set_user_agent (libvlc_instance_t , name.p-utf8, http.p-utf8)
;Sets the application name. More...
PrototypeC 	libvlc_set_app_id (libvlc_instance_t , id.p-utf8, version.p-utf8, icon.p-utf8) 
;Sets some meta-information about the application. More...
PrototypeC 	libvlc_get_version () 
;Retrieve libvlc version. More...
PrototypeC 	libvlc_get_compiler () 
;Retrieve libvlc compiler version. More...
PrototypeC 	libvlc_get_changeset () 	
;Retrieve libvlc changeset. More...
PrototypeC libvlc_free(p)
;Frees an heap allocation returned by a LibVLC function. More...
PrototypeC	libvlc_module_description_list_release (libvlc_module_description_t) 
;Release a list of module descriptions. More...
PrototypeC 	libvlc_audio_filter_list_get (libvlc_instance_t ) 
;Returns a list of audio filters that are available. More...
PrototypeC 	libvlc_video_filter_list_get (libvlc_instance_t )
;Returns a list of video filters that are available. More...

PrototypeC libvlc_errmsg () 
;A human-readable error message for the last LibVLC error in the calling thread. More...
PrototypeC 	libvlc_clearerr () 
;Clears the LibVLC error status for the current thread. More...
PrototypeC 	libvlc_vprinterr (fmt.p-utf8, va_list) 
;Sets the LibVLC error status and message for the current thread. More...
; PrototypeC 	libvlc_printerr (fmt,...)
;Sets the LibVLC error status and message for the current thread. More...

PrototypeC.l libvlc_event_attach(libvlc_media_player_t,libvlc_event_type_t,libvlc_callback_t,user_data)
;Register for an event notification. More...
PrototypeC libvlc_event_detach(libvlc_media_player_t,libvlc_event_type_t,libvlc_callback_t,user_data)
;Unregister an event notification. More...

PrototypeC 	libvlc_log_get_context ( libvlc_log_t, *module, *file,  *line)
;  	Gets log message Debug infos. More...
PrototypeC 	libvlc_log_get_object ( libvlc_log_t , *name, *header,  *id)
;  	Gets log message info. More...
PrototypeC 	libvlc_log_unset (libvlc_instance_t )
;  	Unsets the logging callback. More...
PrototypeC 	libvlc_log_set (libvlc_instance_t , libvlc_log_cb ,  *Data)
;  	Sets the logging callback For a LibVLC instance. More...
PrototypeC 	libvlc_log_set_file (libvlc_instance_t ,  *stream)
;Sets up logging To a file. More...


PrototypeC.q 	libvlc_clock ()
;  	Return the current time As defined by LibVLC. More...
; PrototypeC.q 	libvlc_delay ( pts.q)
;  	Return the Delay (in microseconds) Until a certain timestamp. More...

PrototypeC 	libvlc_dialog_set_callbacks (libvlc_instance_t, libvlc_dialog_cbs ,  *p_data)
;  	Register callbacks in order To handle VLC dialogs. More...
PrototypeC	libvlc_dialog_set_context (libvlc_dialog_id ,  *p_context)
;  	Associate an opaque pointer With the dialog id. More...
PrototypeC 	libvlc_dialog_get_context (libvlc_dialog_id )
;  	Return the opaque pointer associated With the dialog id. More...
PrototypeC.l 	libvlc_dialog_post_login (libvlc_dialog_id , *psz_username.p-utf8, *psz_password.p-utf8,  b_store)
;  	Post a login answer. More...
PrototypeC.l libvlc_dialog_post_action (libvlc_dialog_id ,  i_action)
;  	Post a question answer. More...
PrototypeC.l libvlc_dialog_dismiss (libvlc_dialog_id )
;  	Dismiss a dialog. More...

PrototypeC 	libvlc_media_new_location (libvlc_instance_t , psz_mrl.p-utf8)
;  	Create a media With a certain given media resource location, For instance a valid URL. More...
PrototypeC 	libvlc_media_new_path (libvlc_instance_t , path.p-utf8)
;  	Create a media For a certain file path. More...
PrototypeC 	libvlc_media_new_fd (libvlc_instance_t ,  fd)
;  	Create a media For an already open file descriptor. More...
PrototypeC 	libvlc_media_new_callbacks (libvlc_instance_t , libvlc_media_open_cb , libvlc_media_read_cb , libvlc_media_seek_cb , libvlc_media_close_cb ,  *opaque)
;  	Create a media With custom callbacks To Read the Data from. More...
PrototypeC 	libvlc_media_new_as_node (libvlc_instance_t , psz_name.p-utf8)
;  	Create a media As an empty node With a given name. More...
PrototypeC 	libvlc_media_add_option (libvlc_media_t , psz_options.p-utf8)
;  	Add an option To the media. More...
PrototypeC 	libvlc_media_add_option_flag (libvlc_media_t , psz_options.p-utf8,  i_flags)
;  	Add an option To the media With configurable flags. More...
PrototypeC 	libvlc_media_retain (libvlc_media_t )
;  	Retain a reference To a media descriptor object (libvlc_media_t). More...
PrototypeC 	libvlc_media_release (libvlc_media_t )
;  	Decrement the reference count of a media descriptor object. More...
PrototypeC 	libvlc_media_get_mrl (libvlc_media_t )
;  	Get the media resource locator (mrl) from a media descriptor object. More...
PrototypeC 	libvlc_media_duplicate (libvlc_media_t )
;  	Duplicate a media descriptor object. More...
PrototypeC 	libvlc_media_get_meta (libvlc_media_t , libvlc_meta_t )
;  	Read the meta of the media. More...
PrototypeC 	libvlc_media_set_meta (libvlc_media_t , libvlc_meta_t , psz_value.p-utf8)
;  	Set the meta of the media (this function will Not save the meta, call libvlc_media_save_meta in order To save the meta) More...
PrototypeC.l 	libvlc_media_save_meta (libvlc_media_t )
;  	Save the meta previously set. More...
PrototypeC.l	libvlc_media_get_state (libvlc_media_t )
;  	Get current state of media descriptor object. More...
PrototypeC.l 	libvlc_media_get_stats (libvlc_media_t , libvlc_media_stats_t )
;  	Get the current statistics about the media. More...
PrototypeC 	libvlc_media_subitems (libvlc_media_t )
;  	Get subitems of media descriptor object. More...
PrototypeC	libvlc_media_event_manager (libvlc_media_t )
;  	Get event manager from media descriptor object. More...
PrototypeC.q 	libvlc_media_get_duration (libvlc_media_t )
;  	Get duration (in ms) of media descriptor object item. More...
PrototypeC.l 	libvlc_media_parse_with_options (libvlc_media_t , libvlc_media_parse_flag_t ,  timeout.l)
;  	Parse the media asynchronously With options. More...
PrototypeC 	libvlc_media_parse_stop (libvlc_media_t )
;  	Stop the parsing of the media. More...
PrototypeC	libvlc_media_get_parsed_status (libvlc_media_t )
;  	Get Parsed status For media descriptor object. More...
PrototypeC 	libvlc_media_set_user_data (libvlc_media_t ,  *p_new_user_data)
;  	Sets media descriptor's user_data. More...
PrototypeC 	libvlc_media_get_user_data (libvlc_media_t )
;  	Get media descriptor's user_data. More...
PrototypeC 	libvlc_media_get_tracklist (libvlc_media_t , libvlc_track_type_t )
;  	Get the track List For one type. More...
PrototypeC 	libvlc_media_get_codec_description (libvlc_track_type_t ,  i_codec)
;  	Get codec description from media elementary stream. More...
PrototypeC.l	libvlc_media_get_type (libvlc_media_t )
;  	Get the media type of the media descriptor object. More...
PrototypeC 	libvlc_media_thumbnail_request_by_time (libvlc_media_t ,  time.q, libvlc_thumbnailer_seek_speed_t ,   width,   height,  crop, libvlc_picture_type_t , libvlc_time_t )
;  	libvlc_media_request_thumbnail_by_time Start an asynchronous thumbnail generation More...
PrototypeC	libvlc_media_thumbnail_request_by_pos (libvlc_media_t ,  pos.f, libvlc_thumbnailer_seek_speed_t ,   width,   height,  crop, libvlc_picture_type_t , libvlc_time_t )
;  	libvlc_media_request_thumbnail_by_pos Start an asynchronous thumbnail generation More...
PrototypeC 	libvlc_media_thumbnail_request_cancel (libvlc_media_thumbnail_request_t )
;  	libvlc_media_thumbnail_cancel cancels a thumbnailing request More...
PrototypeC 	libvlc_media_thumbnail_request_destroy (libvlc_media_thumbnail_request_t)
;  	libvlc_media_thumbnail_destroy destroys a thumbnail request More...
PrototypeC.l 	libvlc_media_slaves_add (libvlc_media_t , libvlc_media_slave_type_t ,   i_priority, psz_uri.p-utf8)
;  	Add a slave To the current media. More...
PrototypeC 	libvlc_media_slaves_clear (libvlc_media_t )
;  	Clear all slaves previously added by libvlc_media_slaves_add() Or ernally. More...
PrototypeC.l 	libvlc_media_slaves_get (libvlc_media_t , libvlc_media_slave_t )
;  	Get a media descriptor's slave list. More...
PrototypeC 	libvlc_media_slaves_release (libvlc_media_slave_t ,   i_count)
;  	Release a media descriptor's slave list. More...
PrototypeC 	libvlc_media_parse (libvlc_media_t )
;  	Parse a media. More...
PrototypeC 	libvlc_media_parse_async (libvlc_media_t )
;  	Parse a media. More...
PrototypeC.l 	libvlc_media_is_parsed (libvlc_media_t )
;  	Return true is the media descriptor object is parsed. More...
PrototypeC.l	libvlc_media_tracks_get (libvlc_media_t , libvlc_media_track_t )
;  	Get media descriptor's elementary streams description. More...
PrototypeC 	libvlc_media_tracks_release (libvlc_media_track_t ,  i_count)
;  	Release media descriptor's elementary streams description array. More...

PrototypeC 	libvlc_media_player_new (libvlc_instance_t )
; 	Create an empty Media Player object. More...
PrototypeC 	libvlc_media_player_new_from_media (libvlc_media_t )
; 	Create a Media Player object from a Media. More...
PrototypeC	libvlc_media_player_release (libvlc_media_player_t )
; 	Release a media_player after use Decrement the reference count of a media player object. More...
PrototypeC	libvlc_media_player_retain (libvlc_media_player_t )
; 	Retain a reference To a media player object. More...
PrototypeC	libvlc_media_player_set_media (libvlc_media_player_t , libvlc_media_t )
; 	Set the media that will be used by the media_player. More...
PrototypeC 	libvlc_media_player_get_media (libvlc_media_player_t )
; 	Get the media used by the media_player. More...
PrototypeC	libvlc_media_player_event_manager (libvlc_media_player_t )
; 	Get the Event Manager from which the media player send event. More...
PrototypeC.l 	libvlc_media_player_is_playing (libvlc_media_player_t )
; 	is_playing More...
PrototypeC.l 	libvlc_media_player_play (libvlc_media_player_t )
; 	Play. More...
PrototypeC	libvlc_media_player_set_pause (libvlc_media_player_t ,  do_pause)
; 	Pause Or resume (no effect If there is no media) More...
PrototypeC	libvlc_media_player_pause (libvlc_media_player_t )
; 	Toggle pause (no effect If there is no media) More...
PrototypeC.l 	libvlc_media_player_stop_async (libvlc_media_player_t )
; 	Stop asynchronously. More...
PrototypeC.l 	libvlc_media_player_stop (libvlc_media_player_t )
; 	Stop asynchronously. More...
PrototypeC.l 	libvlc_media_player_set_renderer (libvlc_media_player_t , libvlc_renderer_item_t )
; 	Set a renderer To the media player. More...
PrototypeC	libvlc_video_set_callbacks (libvlc_media_player_t , libvlc_video_lock_cb , libvlc_video_unlock_cb , libvlc_video_display_cb ,  *opaque)
; 	Set callbacks And private Data To render decoded video To a custom area in memory. More...
PrototypeC	libvlc_video_set_format (libvlc_media_player_t , chroma.p-utf8,  width,  height,  pitch)
; 	Set decoded video chroma And dimensions. More...
PrototypeC	libvlc_video_set_format_callbacks (libvlc_media_player_t , libvlc_video_format_cb , libvlc_video_cleanup_cb )
; 	Set decoded video chroma And dimensions. More...
PrototypeC.l 	libvlc_video_set_output_callbacks (libvlc_media_player_t , libvlc_video_engine_t , libvlc_video_output_setup_cb , libvlc_video_output_cleanup_cb , libvlc_video_output_set_resize_cb , libvlc_video_update_output_cb , libvlc_video_swap_cb , libvlc_video_makeCurrent_cb , libvlc_video_getProcAddress_cb , libvlc_video_frameMetadata_cb , libvlc_video_output_select_plane_cb ,  *opaque)
; 	Set callbacks And Data To render decoded video To a custom texture. More...
PrototypeC	libvlc_media_player_set_nsobject (libvlc_media_player_t ,  *drawable)
; 	Set the NSView handler where the media player should render its video output. More...
PrototypeC 	libvlc_media_player_get_nsobject (libvlc_media_player_t )
; 	Get the NSView handler previously set With libvlc_media_player_set_nsobject(). More...
PrototypeC	libvlc_media_player_set_xwindow (libvlc_media_player_t ,  drawable)
; 	Set an X Window System drawable where the media player should render its video output. More...
PrototypeC 	libvlc_media_player_get_xwindow (libvlc_media_player_t )
; 	Get the X Window System window identifier previously set With libvlc_media_player_set_xwindow(). More...
PrototypeC	libvlc_media_player_set_hwnd (libvlc_media_player_t ,  *drawable)
; 	Set a Win32/Win64 API window handle (HWND) where the media player should render its video output. More...
PrototypeC 	libvlc_media_player_get_hwnd (libvlc_media_player_t )
; 	Get the Windows API window handle (HWND) previously set With libvlc_media_player_set_hwnd(). More...
PrototypeC	libvlc_media_player_set_android_context (libvlc_media_player_t ,  *p_awindow_handler)
; 	Set the android context. More...
PrototypeC	libvlc_audio_set_callbacks (libvlc_media_player_t , libvlc_audio_play_cb , libvlc_audio_pause_cb , libvlc_audio_resume_cb , libvlc_audio_flush_cb , libvlc_audio_drain_cb ,  *opaque)
; 	Sets callbacks And private Data For decoded audio. More...
PrototypeC	libvlc_audio_set_volume_callback (libvlc_media_player_t , libvlc_audio_set_volume_cb )
; 	Set callbacks And private Data For decoded audio. More...
PrototypeC	libvlc_audio_set_format_callbacks (libvlc_media_player_t , libvlc_audio_setup_cb , libvlc_audio_cleanup_cb )
; 	Sets decoded audio format via callbacks. More...
PrototypeC	libvlc_audio_set_format (libvlc_media_player_t , format.p-utf8,  rate,  channels)
; 	Sets a fixed decoded audio format. More...
PrototypeC.q	libvlc_media_player_get_length (libvlc_media_player_t )
; 	Get the current movie length (in ms). More...
PrototypeC.q	libvlc_media_player_get_time (libvlc_media_player_t )
; 	Get the current movie time (in ms). More...
PrototypeC.l 	libvlc_media_player_set_time (libvlc_media_player_t , libvlc_time_t.q,  b_fast)
; 	Set the movie time (in ms). More...
PrototypeC.f 	libvlc_media_player_get_position (libvlc_media_player_t )
; 	Get movie position As percentage between 0.0 And 1.0. More...
PrototypeC.l 	libvlc_media_player_set_position (libvlc_media_player_t ,  f_pos.f,  b_fast)
; 	Set movie position As percentage between 0.0 And 1.0. More...
PrototypeC	libvlc_media_player_set_chapter (libvlc_media_player_t ,  i_chapter)
; 	Set movie chapter (If applicable). More...
PrototypeC.l 	libvlc_media_player_get_chapter (libvlc_media_player_t )
; 	Get movie chapter. More...
PrototypeC.l 	libvlc_media_player_get_chapter_count (libvlc_media_player_t )
; 	Get movie chapter count. More...
PrototypeC.l 	libvlc_media_player_get_chapter_count_for_title (libvlc_media_player_t ,  i_title)
; 	Get title chapter count. More...
PrototypeC	libvlc_media_player_set_title (libvlc_media_player_t ,  i_title)
; 	Set movie title. More...
PrototypeC 	libvlc_media_player_get_title (libvlc_media_player_t )
; 	Get movie title. More...
PrototypeC 	libvlc_media_player_get_title_count (libvlc_media_player_t )
; 	Get movie title count. More...
PrototypeC	libvlc_media_player_previous_chapter (libvlc_media_player_t )
; 	Set previous chapter (If applicable) More...
PrototypeC	libvlc_media_player_next_chapter (libvlc_media_player_t )
; 	Set Next chapter (If applicable) More...
PrototypeC.f 	libvlc_media_player_get_rate (libvlc_media_player_t )
; 	Get the requested movie play rate. More...
PrototypeC.l 	libvlc_media_player_set_rate (libvlc_media_player_t ,  rate.f)
; 	Set movie play rate. More...
PrototypeC.l 	libvlc_media_player_get_state (libvlc_media_player_t )
; 	Get current movie state. More...
PrototypeC.l 	libvlc_media_player_has_vout (libvlc_media_player_t )
; 	How many video outputs does this media player have? More...
PrototypeC.l 	libvlc_media_player_is_seekable (libvlc_media_player_t )
; 	Is this media player seekable? More...
PrototypeC.l 	libvlc_media_player_can_pause (libvlc_media_player_t )
; 	Can this media player be paused? More...
PrototypeC.l 	libvlc_media_player_program_scrambled (libvlc_media_player_t )
; 	Check If the current program is scrambled. More...
PrototypeC	libvlc_media_player_next_frame (libvlc_media_player_t )
; 	Display the Next frame (If supported) More...
PrototypeC	libvlc_media_player_navigate (libvlc_media_player_t ,  navigate)
; 	Navigate through DVD Menu. More...
PrototypeC	libvlc_media_player_set_video_title_display (libvlc_media_player_t , libvlc_position_t ,   timeout)
; 	Set If, And how, the video title will be shown when media is played. More...
PrototypeC 	libvlc_media_player_get_tracklist (libvlc_media_player_t , libvlc_track_type_t )
; 	Get the track List For one type. More...
PrototypeC 	libvlc_media_player_get_selected_track (libvlc_media_player_t , libvlc_track_type_t )
; 	Get the selected track For one type. More...
PrototypeC 	libvlc_media_player_get_track_from_id (libvlc_media_player_t , psz_id.p-utf8)
PrototypeC	libvlc_media_player_select_track (libvlc_media_player_t , libvlc_media_track_t )
; 	Select a track. More...
PrototypeC	libvlc_media_player_unselect_track_type (libvlc_media_player_t , libvlc_track_type_t )
; 	Unselect all tracks For a given type. More...
PrototypeC	libvlc_media_player_select_tracks (libvlc_media_player_t , libvlc_track_type_t ,  libvlc_media_track_t ,  track_count)
; 	Select multiple tracks For one type. More...
PrototypeC	libvlc_media_player_select_tracks_by_ids (libvlc_media_player_t , libvlc_track_type_t , psz_ids.p-utf8)
; 	Select tracks by their string identifier. More...
PrototypeC.l 	libvlc_media_player_add_slave (libvlc_media_player_t , libvlc_media_slave_type_t , psz_uri.p-utf8,  b_select)
; 	Add a slave To the current media player. More...
PrototypeC	libvlc_player_program_delete (libvlc_player_program_t )
; 	Delete a program struct. More...
PrototypeC.l 	libvlc_player_programlist_count ( libvlc_player_programlist_t )
; 	Get the number of programs in a programlist. More...
PrototypeC 	libvlc_player_programlist_at (libvlc_player_programlist_t ,  index)
; 	Get a program at a specific index. More...
PrototypeC	libvlc_player_programlist_delete (libvlc_player_programlist_t )
; 	Release a programlist. More...
PrototypeC	libvlc_media_player_select_program_id (libvlc_media_player_t ,  i_group_id)
; 	Select program With a given program id. More...
PrototypeC 	libvlc_media_player_get_selected_program (libvlc_media_player_t )
; 	Get the selected program. More...
PrototypeC 	libvlc_media_player_get_program_from_id (libvlc_media_player_t ,  i_group_id)
; 	Get a program struct from a program id. More...
PrototypeC 	libvlc_media_player_get_programlist (libvlc_media_player_t )
; 	Get the program List. More...
PrototypeC	libvlc_track_description_list_release (libvlc_track_description_t )
;Release (free) libvlc_track_description_t. More...

PrototypeC	libvlc_toggle_fullscreen (libvlc_media_player_t )
; 	Toggle fullscreen status on non-embedded video outputs. More...
PrototypeC	libvlc_set_fullscreen (libvlc_media_player_t ,  b_fullscreen)
; 	Enable Or disable fullscreen. More...
PrototypeC.l 	libvlc_get_fullscreen (libvlc_media_player_t )
; 	Get current fullscreen status. More...
PrototypeC	libvlc_video_set_key_input (libvlc_media_player_t ,  on)
; 	Enable Or disable key press events handling, according To the LibVLC hotkeys configuration. More...
PrototypeC	libvlc_video_set_mouse_input (libvlc_media_player_t ,  on)
; 	Enable Or disable mouse click events handling. More...
PrototypeC.l 	libvlc_video_get_size (libvlc_media_player_t ,  num,  *px,  *py)
; 	Get the pixel dimensions of a video. More...
PrototypeC.l 	libvlc_video_get_cursor (libvlc_media_player_t ,  num,  *px,  *py)
; 	Get the mouse poer coordinates over a video. More...
PrototypeC.f 	libvlc_video_get_scale (libvlc_media_player_t )
; 	Get the current video scaling factor. More...
PrototypeC	libvlc_video_set_scale (libvlc_media_player_t ,  f_factor.f)
; 	Set the video scaling factor. More...
PrototypeC 	libvlc_video_get_aspect_ratio (libvlc_media_player_t )
; 	Get current video aspect ratio. More...
PrototypeC	libvlc_video_set_aspect_ratio (libvlc_media_player_t , psz_aspect.p-utf8)
; 	Set new video aspect ratio. More...
PrototypeC 	libvlc_video_new_viewpoint ()
; 	Create a video viewpo Structure. More...
PrototypeC.l 	libvlc_video_update_viewpoint (libvlc_media_player_t ,  libvlc_video_viewpo_t ,  b_absolute)
; 	Update the video viewpo information. More...
PrototypeC.q 	libvlc_video_get_spu_delay (libvlc_media_player_t )
; 	Get the current subtitle delay. More...
PrototypeC.f 	libvlc_video_get_spu_text_scale (libvlc_media_player_t )
; 	Get the current subtitle text scale. More...
PrototypeC	libvlc_video_set_spu_text_scale (libvlc_media_player_t ,  f_scale.f)
; 	Set the subtitle text scale. More...
PrototypeC.l 	libvlc_video_set_spu_delay (libvlc_media_player_t , i_delay.q)
; 	Set the subtitle delay. More...
PrototypeC.l 	libvlc_media_player_get_full_title_descriptions (libvlc_media_player_t , libvlc_title_description_t)
; 	Get the full description of available titles. More...
PrototypeC	libvlc_title_descriptions_release (libvlc_title_description_t ,  i_count)
; 	Release a title description. More...
PrototypeC.l 	libvlc_media_player_get_full_chapter_descriptions (libvlc_media_player_t ,  i_chapters_of_title, libvlc_chapter_description_t )
; 	Get the full description of available chapters. More...
PrototypeC	libvlc_chapter_descriptions_release (libvlc_chapter_description_t ,  i_count)
; 	Release a chapter description. More...
PrototypeC	libvlc_video_set_crop_ratio (libvlc_media_player_t ,  num,  den)
; 	Set/unset the video crop ratio. More...
PrototypeC	libvlc_video_set_crop_window (libvlc_media_player_t ,  x,  y,  width,  height)
; 	Set the video crop window. More...
PrototypeC	libvlc_video_set_crop_border (libvlc_media_player_t ,  left,  right,  top,  bottom)
; 	Set the video crop borders. More...
PrototypeC.l 	libvlc_video_get_teletext (libvlc_media_player_t )
; 	Get current teletext page requested Or 0 If it's disabled. More...
PrototypeC	libvlc_video_set_teletext (libvlc_media_player_t ,  i_page)
; 	Set new teletext page To retrieve. More...
PrototypeC.l 	libvlc_video_take_snapshot (libvlc_media_player_t ,  num, psz_filepath.p-utf8,   i_width,   i_height)
; 	Take a snapshot of the current video window. More...
PrototypeC	libvlc_video_set_deinterlace (libvlc_media_player_t ,  deinterlace, psz_mode.p-utf8)
; 	Enable Or disable deerlace filter. More...
PrototypeC.l 	libvlc_video_get_marquee_int (libvlc_media_player_t ,  option)
; 	Get an eger marquee option value. More...
PrototypeC	libvlc_video_set_marquee_int (libvlc_media_player_t ,  option,  i_val)
; 	Enable, disable Or set an eger marquee option. More...
PrototypeC	libvlc_video_set_marquee_string (libvlc_media_player_t ,  option, psz_text.p-utf8)
; 	Set a marquee string option. More...
PrototypeC.l 	libvlc_video_get_logo_int (libvlc_media_player_t ,  option)
; 	Get eger logo option. More...
PrototypeC	libvlc_video_set_logo_int (libvlc_media_player_t ,  option,  value)
; 	Set logo option As eger. More...
PrototypeC	libvlc_video_set_logo_string (libvlc_media_player_t ,  option, psz_value.p-utf8)
; 	Set logo option As string. More...
PrototypeC.l 	libvlc_video_get_adjust_int (libvlc_media_player_t ,  option)
; 	Get eger adjust option. More...
PrototypeC	libvlc_video_set_adjust_int (libvlc_media_player_t ,  option,  value)
; 	Set adjust option As eger. More...
PrototypeC.f 	libvlc_video_get_adjust_float (libvlc_media_player_t ,  option)
; 	Get float adjust option. More...
PrototypeC	libvlc_video_set_adjust_float (libvlc_media_player_t ,  option,  value.f)
; 	Set adjust option As float. More...
PrototypeC.l 	libvlc_video_get_track_count (libvlc_media_player_t )
; 	Get number of available video tracks. More...
PrototypeC 	libvlc_video_get_track_description (libvlc_media_player_t )
; 	Get the description of available video tracks. More...
PrototypeC.l 	libvlc_video_get_track (libvlc_media_player_t )
; 	Get current video track. More...
PrototypeC.l 	libvlc_video_set_track (libvlc_media_player_t ,  i_track)
; 	Set video track. More...
PrototypeC.l 	libvlc_video_get_spu (libvlc_media_player_t )
; 	Get current video subtitle. More...
PrototypeC.l 	libvlc_video_get_spu_count (libvlc_media_player_t )
; 	Get the number of available video subtitles. More...
PrototypeC 	libvlc_video_get_spu_description (libvlc_media_player_t )
; 	Get the description of available video subtitles. More...
PrototypeC.l 	libvlc_video_set_spu (libvlc_media_player_t ,  i_spu)
;Set new video subtitle. More...

PrototypeC 	libvlc_audio_output_list_get (libvlc_instance_t )
; 	Gets the List of available audio output modules. More...
PrototypeC	libvlc_audio_output_list_release (libvlc_audio_output_t )
; 	Frees the List of available audio output modules. More...
PrototypeC.l 	libvlc_audio_output_set (libvlc_media_player_t , psz_name.p-utf8)
; 	Selects an audio output Module. More...
PrototypeC	libvlc_audio_output_device_enum (libvlc_media_player_t )
; 	Gets a List of potential audio output devices,. More...
PrototypeC 	libvlc_audio_output_device_list_get (libvlc_instance_t , aout.p-utf8)
; 	Gets a List of audio output devices For a given audio output Module,. More...
PrototypeC	libvlc_audio_output_device_list_release (libvlc_audio_output_device_t )
; 	Frees a List of available audio output devices. More...
PrototypeC	libvlc_audio_output_device_set (libvlc_media_player_t , sModule, device_id.p-utf8)
; 	Configures an explicit audio output device. More...
PrototypeC 	libvlc_audio_output_device_get (libvlc_media_player_t )
; 	Get the current audio output device identifier. More...
PrototypeC	libvlc_audio_toggle_mute (libvlc_media_player_t )
; 	Toggle mute status. More...
PrototypeC.l 	libvlc_audio_get_mute (libvlc_media_player_t )
; 	Get current mute status. More...
PrototypeC	libvlc_audio_set_mute (libvlc_media_player_t ,  status)
; 	Set mute status. More...
PrototypeC.l 	libvlc_audio_get_volume (libvlc_media_player_t )
; 	Get current software audio volume. More...
PrototypeC.l 	libvlc_audio_set_volume (libvlc_media_player_t ,  i_volume)
; 	Set current software audio volume. More...
PrototypeC.l 	libvlc_audio_get_channel (libvlc_media_player_t )
; 	Get current audio channel. More...
PrototypeC.l 	libvlc_audio_set_channel (libvlc_media_player_t ,  channel)
; 	Set current audio channel. More...
PrototypeC.q 	libvlc_audio_get_delay (libvlc_media_player_t )
; 	Get current audio delay. More...
PrototypeC.l 	libvlc_audio_set_delay (libvlc_media_player_t ,  i_delay.q)
; 	Set current audio delay. More...
PrototypeC.l 	libvlc_audio_equalizer_get_preset_count ()
; 	Get the number of equalizer presets. More...
PrototypeC 	libvlc_audio_equalizer_get_preset_name ( u_index)
; 	Get the name of a particular equalizer preset. More...
PrototypeC.l 	libvlc_audio_equalizer_get_band_count ()
; 	Get the number of distinct frequency bands For an equalizer. More...
PrototypeC.f 	libvlc_audio_equalizer_get_band_frequency ( u_index)
; 	Get a particular equalizer band frequency. More...
PrototypeC 	libvlc_audio_equalizer_new ()
; 	Create a new Default equalizer, With all frequency values zeroed. More...
PrototypeC 	libvlc_audio_equalizer_new_from_preset ( u_index)
; 	Create a new equalizer, With initial frequency values copied from an existing preset. More...
PrototypeC	libvlc_audio_equalizer_release (libvlc_equalizer_t)
; 	Release a previously created equalizer instance. More...
PrototypeC.l 	libvlc_audio_equalizer_set_preamp (libvlc_equalizer_t ,  f_preamp.f)
; 	Set a new pre-amplification value For an equalizer. More...
PrototypeC.f 	libvlc_audio_equalizer_get_preamp (libvlc_equalizer_t )
; 	Get the current pre-amplification value from an equalizer. More...
PrototypeC.l 	libvlc_audio_equalizer_set_amp_at_index (libvlc_equalizer_t ,  f_amp.f,  u_band)
; 	Set a new amplification value For a particular equalizer frequency band. More...
PrototypeC.f 	libvlc_audio_equalizer_get_amp_at_index (libvlc_equalizer_t ,  u_band)
; 	Get the amplification value For a particular equalizer frequency band. More...
PrototypeC.l 	libvlc_media_player_set_equalizer (libvlc_media_player_t , libvlc_equalizer_t )
; 	Apply new equalizer settings To a media player. More...
PrototypeC.l 	libvlc_media_player_get_role (libvlc_media_player_t )
; 	Gets the media role. More...
PrototypeC.l 	libvlc_media_player_set_role (libvlc_media_player_t ,  role)
; 	Sets the media role. More...
PrototypeC.l 	libvlc_audio_get_track_count (libvlc_media_player_t )
; 	Get number of available audio tracks. More...
PrototypeC 	libvlc_audio_get_track_description (libvlc_media_player_t )
; 	Get the description of available audio tracks. More...
PrototypeC.l 	libvlc_audio_get_track (libvlc_media_player_t )
; 	Get current audio track. More...
PrototypeC.l 	libvlc_audio_set_track (libvlc_media_player_t ,  i_track)
;Set current audio track. More...

PrototypeC 	libvlc_media_list_new (libvlc_instance_t)
;  	Create an empty media List. More...
PrototypeC 	libvlc_media_list_release (libvlc_media_list_t )
;  	Release media List created With libvlc_media_list_new(). More...
PrototypeC 	libvlc_media_list_retain (libvlc_media_list_t )
;  	Retain reference To a media List. More...
PrototypeC 	libvlc_media_list_set_media (libvlc_media_list_t , libvlc_media_t)
;  	Associate media instance With this media List instance. More...
PrototypeC 	libvlc_media_list_media (libvlc_media_list_t )
;  	Get media instance from this media List instance. More...
PrototypeC.l	libvlc_media_list_add_media (libvlc_media_list_t , libvlc_media_t )
;  	Add media instance To media List The libvlc_media_list_lock should be held upon entering this function. More...
PrototypeC.l 	libvlc_media_list_insert_media (libvlc_media_list_t , libvlc_media_t ,i_pos)
;  	Insert media instance in media List on a position The libvlc_media_list_lock should be held upon entering this function. More...
PrototypeC.l 	libvlc_media_list_remove_index (libvlc_media_list_t ,i_pos)
;  	Remove media instance from media List on a position The libvlc_media_list_lock should be held upon entering this function. More...
PrototypeC.l 	libvlc_media_list_count (libvlc_media_list_t )
;  	Get count on media List items The libvlc_media_list_lock should be held upon entering this function. More...
PrototypeC 	libvlc_media_list_item_at_index (libvlc_media_list_t ,i_pos)
;  	List media instance in media List at a position The libvlc_media_list_lock should be held upon entering this function. More...
PrototypeC.l 	libvlc_media_list_index_of_item (libvlc_media_list_t , libvlc_media_t )
;  	Find index position of List media instance in media List. More...
PrototypeC.l 	libvlc_media_list_is_readonly (libvlc_media_list_t )
;  	This indicates If this media List is Read-only from a user point of view. More...
PrototypeC 	libvlc_media_list_lock (libvlc_media_list_t )
;  	Get lock on media List items. More...
PrototypeC 	libvlc_media_list_unlock (libvlc_media_list_t )
;  	Release lock on media List items The libvlc_media_list_lock should be held upon entering this function. More...
PrototypeC 	libvlc_media_list_event_manager (libvlc_media_list_t )
;  	Get libvlc_event_manager from this media List instance. More...

PrototypeC	libvlc_media_list_player_new (libvlc_instance_t)
;  	Create new media_list_player. More...
PrototypeC 	libvlc_media_list_player_release (libvlc_media_list_player_t)
;  	Release a media_list_player after use Decrement the reference count of a media player object. More...
PrototypeC 	libvlc_media_list_player_retain (libvlc_media_list_player_t)
;  	Retain a reference To a media player List object. More...
PrototypeC	libvlc_media_list_player_event_manager (libvlc_media_list_player_t)
;  	Return the event manager of this media_list_player. More...
PrototypeC 	libvlc_media_list_player_set_media_player (libvlc_media_list_player_t, libvlc_media_player_t)
;  	Replace media player in media_list_player With this instance. More...
PrototypeC	libvlc_media_list_player_get_media_player (libvlc_media_list_player_t)
;  	Get media player of the media_list_player instance. More...
PrototypeC 	libvlc_media_list_player_set_media_list (libvlc_media_list_player_t, libvlc_media_list_t)
;  	Set the media List associated With the player. More...
PrototypeC 	libvlc_media_list_player_play (libvlc_media_list_player_t)
;  	Play media List. More...
PrototypeC 	libvlc_media_list_player_pause (libvlc_media_list_player_t)
;  	Toggle pause (Or resume) media List. More...
PrototypeC 	libvlc_media_list_player_set_pause (libvlc_media_list_player_t, do_pause)
;  	Pause Or resume media List. More...
PrototypeC.l 	libvlc_media_list_player_is_playing (libvlc_media_list_player_t)
;  	Is media List playing? More...
PrototypeC.l	libvlc_media_list_player_get_state (libvlc_media_list_player_t)
;  	Get current libvlc_state of media List player. More...
PrototypeC.l 	libvlc_media_list_player_play_item_at_index (libvlc_media_list_player_t, i_index)
;  	Play media List item at position index. More...
PrototypeC.l 	libvlc_media_list_player_play_item (libvlc_media_list_player_t, libvlc_media_t)
;  	Play the given media item. More...
PrototypeC 	libvlc_media_list_player_stop_async (libvlc_media_list_player_t)
;  	Stop playing media List. More...
PrototypeC.l 	libvlc_media_list_player_next (libvlc_media_list_player_t)
;  	Play Next item from media List. More...
PrototypeC.l 	libvlc_media_list_player_previous (libvlc_media_list_player_t)
;  	Play previous item from media List. More...
PrototypeC 	libvlc_media_list_player_set_playback_mode (libvlc_media_list_player_t, libvlc_playback_mode_t )
;  	Sets the playback mode For the playlist. More...

PrototypeC	pf_display_error( *p_data, *psz_title,
          	                  *psz_text)
PrototypeC	pf_display_login( *p_data, libvlc_dialog_id,
          	                  *psz_title, *psz_text,
          	                  *psz_default_username,
          	                  b_ask_store)
PrototypeC	pf_display_question( *p_data, libvlc_dialog_id ,
          	                     *psz_title, *psz_text,
          	                     libvlc_dialog_question_type ,
          	                     *psz_cancel, *psz_action1,
          	                     *psz_action2)
PrototypeC	pf_display_progress( *p_data, libvlc_dialog_id ,
          	                     *psz_title, *psz_text,
          	                     b_indeterminate,  f_position.f,
          	                     *psz_cancel)
PrototypeC	pf_cancel( *p_data, libvlc_dialog_id )
PrototypeC	pf_update_progress( *p_data, libvlc_dialog_id ,
          	                    f_position.f, *psz_text)
PrototypeC libvlc_callback_t( libvlc_event_t, *p_data)
;Callback function notification. More...

PrototypeC libvlc_log_cb ( *Data,  level,  libvlc_log_t, fmt.p-utf8, va_list)
; Callback Prototype For LibVLC log message handler.

PrototypeC.l	libvlc_media_open_cb( *opaque,  *datap,  *sizep) ;*sizep.q
;  	Callback Prototype To open a custom bitstream input media. More...
PrototypeC	libvlc_media_read_cb ( *opaque, buf.p-utf8,  len)
;  	Callback Prototype To Read Data from a custom bitstream input media. More...
PrototypeC	libvlc_media_seek_cb ( *opaque, offset.q)
;  	Callback Prototype To seek a custom bitstream input media. More...
PrototypeC	libvlc_media_close_cb ( *opaque)
;  	Callback Prototype To close a custom bitstream input media. More...

PrototypeC	libvlc_video_lock_cb( *opaque,  *planes)
; 	Callback Prototype To allocate And lock a picture buffer. More...
PrototypeC 	libvlc_video_unlock_cb( *opaque,  *picture,  *planes)
; 	Callback Prototype To unlock a picture buffer. More...
PrototypeC 	libvlc_video_display_cb( *opaque,  *picture)
; 	Callback Prototype To display a picture. More...
PrototypeC	libvlc_video_format_cb( *opaque,  *chroma.p-utf8,  *width,  *height,  *pitches,  *lines)
; 	Callback Prototype To configure picture buffers format. More...
PrototypeC 	libvlc_video_cleanup_cb( *opaque)
; 	Callback Prototype To configure picture buffers format. More...
PrototypeC	libvlc_video_output_setup_cb( *opaque,  libvlc_video_setup_device_cfg_t , libvlc_video_setup_device_info_t )
; 	Callback Prototype called To initialize user Data. More...
PrototypeC 	libvlc_video_output_cleanup_cb( *opaque)
; 	Callback Prototype called To release user Data. More...
PrototypeC 	libvlc_video_update_output_cb( *opaque,  libvlc_video_render_cfg_t , libvlc_video_output_cfg_t )
; 	Callback Prototype called on video size changes. More...
PrototypeC 	libvlc_video_swap_cb( *opaque)
; 	Callback Prototype called after performing drawing calls. More...
PrototypeC	libvlc_video_makeCurrent_cb( *opaque,  enter)
; 	Callback Prototype To set up the OpenGL context For rendering. More...
PrototypeC 	libvlc_video_getProcAddress_cb( *opaque,   *fct_name.p-utf8)
; 	Callback Prototype To load opengl functions. More...
PrototypeC 	libvlc_video_frameMetadata_cb( *opaque, libvlc_video_metadata_type_t ,   *metadata)
; 	Callback Prototype To receive metadata before rendering. More...
PrototypeC report_size_change( *report_opaque,  width,  height)
PrototypeC 	libvlc_video_output_set_resize_cb( *opaque, report_size_change,  *report_opaque)
; 	Set the callback To call when the host app resizes the rendering area. More...
PrototypeC 	libvlc_video_output_select_plane_cb( *opaque,  plane,  *output)
; 	Tell the host the rendering For the given plane is about To start. More...
PrototypeC 	libvlc_audio_play_cb( *Data,   *samples,  count,  pts.q)
; 	Callback Prototype For audio playback. More...
PrototypeC 	libvlc_audio_pause_cb( *Data,  pts.q)
; 	Callback Prototype For audio pause. More...
PrototypeC 	libvlc_audio_resume_cb( *Data,  pts.q)
; 	Callback Prototype For audio resumption. More...
PrototypeC 	libvlc_audio_flush_cb( *Data,  pts.q)
; 	Callback Prototype For audio buffer flush. More...
PrototypeC 	libvlc_audio_drain_cb( *Data)
; 	Callback Prototype For audio buffer drain. More...
PrototypeC 	libvlc_audio_set_volume_cb( *Data,  volume.f,  mute)
; 	Callback Prototype For audio volume change. More...
PrototypeC 	libvlc_audio_setup_cb( *opaque,  *format.p-utf8,  *rate,  *channels)
; 	Callback Prototype To setup the audio playback. More...
PrototypeC 	libvlc_audio_cleanup_cb( *Data)
; 	Callback Prototype For audio playback cleanup. More...

Global libvlc_new.libvlc_new
Global libvlc_release.libvlc_release
Global libvlc_retain.libvlc_retain
Global libvlc_add_intf.libvlc_add_intf
Global libvlc_set_exit_handler.libvlc_set_exit_handler
Global libvlc_set_user_agent.libvlc_set_user_agent
Global libvlc_set_app_id.libvlc_set_app_id
Global libvlc_get_version.libvlc_get_version
Global libvlc_get_compiler.libvlc_get_compiler
Global libvlc_get_changeset.libvlc_get_changeset
Global libvlc_free.libvlc_free
Global libvlc_module_description_list_release.libvlc_module_description_list_release
Global libvlc_audio_filter_list_get.libvlc_audio_filter_list_get
Global libvlc_video_filter_list_get.libvlc_video_filter_list_get
Global libvlc_errmsg.libvlc_errmsg
Global libvlc_clearerr.libvlc_clearerr
Global libvlc_vprinterr.libvlc_vprinterr
Global libvlc_event_attach.libvlc_event_attach
Global libvlc_event_detach.libvlc_event_detach
Global libvlc_log_get_context.libvlc_log_get_context
Global libvlc_log_get_object.libvlc_log_get_object
Global libvlc_log_unset.libvlc_log_unset
Global libvlc_log_set.libvlc_log_set
Global libvlc_log_set_file.libvlc_log_set_file
Global libvlc_clock.libvlc_clock
Global libvlc_dialog_set_callbacks.libvlc_dialog_set_callbacks
Global libvlc_dialog_set_context.libvlc_dialog_set_context
Global libvlc_dialog_get_context.libvlc_dialog_get_context
Global libvlc_dialog_post_login.libvlc_dialog_post_login
Global libvlc_dialog_post_action.libvlc_dialog_post_action
Global libvlc_dialog_dismiss.libvlc_dialog_dismiss
Global libvlc_media_new_location.libvlc_media_new_location
Global libvlc_media_new_path.libvlc_media_new_path
Global libvlc_media_new_fd.libvlc_media_new_fd
Global libvlc_media_new_callbacks.libvlc_media_new_callbacks
Global libvlc_media_new_as_node.libvlc_media_new_as_node
Global libvlc_media_add_option.libvlc_media_add_option
Global libvlc_media_add_option_flag.libvlc_media_add_option_flag
Global libvlc_media_retain.libvlc_media_retain
Global libvlc_media_release.libvlc_media_release
Global libvlc_media_get_mrl.libvlc_media_get_mrl
Global libvlc_media_duplicate.libvlc_media_duplicate
Global libvlc_media_get_meta.libvlc_media_get_meta
Global libvlc_media_set_meta.libvlc_media_set_meta
Global libvlc_media_save_meta.libvlc_media_save_meta
Global libvlc_media_get_state.libvlc_media_get_state
Global libvlc_media_get_stats.libvlc_media_get_stats
Global libvlc_media_subitems.libvlc_media_subitems
Global libvlc_media_event_manager.libvlc_media_event_manager
Global libvlc_media_get_duration.libvlc_media_get_duration
Global libvlc_media_parse_with_options.libvlc_media_parse_with_options
Global libvlc_media_parse_stop.libvlc_media_parse_stop
Global libvlc_media_get_parsed_status.libvlc_media_get_parsed_status
Global libvlc_media_set_user_data.libvlc_media_set_user_data
Global libvlc_media_get_user_data.libvlc_media_get_user_data
Global libvlc_media_get_tracklist.libvlc_media_get_tracklist
Global libvlc_media_get_codec_description.libvlc_media_get_codec_description
Global libvlc_media_get_type.libvlc_media_get_type
Global libvlc_media_thumbnail_request_by_time.libvlc_media_thumbnail_request_by_time
Global libvlc_media_thumbnail_request_by_pos.libvlc_media_thumbnail_request_by_pos
Global libvlc_media_thumbnail_request_cancel.libvlc_media_thumbnail_request_cancel
Global libvlc_media_thumbnail_request_destroy.libvlc_media_thumbnail_request_destroy
Global libvlc_media_slaves_add.libvlc_media_slaves_add
Global libvlc_media_slaves_clear.libvlc_media_slaves_clear
Global libvlc_media_slaves_get.libvlc_media_slaves_get
Global libvlc_media_slaves_release.libvlc_media_slaves_release
Global libvlc_media_parse.libvlc_media_parse
Global libvlc_media_parse_async.libvlc_media_parse_async
Global libvlc_media_is_parsed.libvlc_media_is_parsed
Global libvlc_media_tracks_get.libvlc_media_tracks_get
Global libvlc_media_tracks_release.libvlc_media_tracks_release
Global libvlc_media_player_new.libvlc_media_player_new
Global libvlc_media_player_new_from_media.libvlc_media_player_new_from_media
Global libvlc_media_player_release.libvlc_media_player_release
Global libvlc_media_player_retain.libvlc_media_player_retain
Global libvlc_media_player_set_media.libvlc_media_player_set_media
Global libvlc_media_player_get_media.libvlc_media_player_get_media
Global libvlc_media_player_event_manager.libvlc_media_player_event_manager
Global libvlc_media_player_is_playing.libvlc_media_player_is_playing
Global libvlc_media_player_play.libvlc_media_player_play
Global libvlc_media_player_set_pause.libvlc_media_player_set_pause
Global libvlc_media_player_pause.libvlc_media_player_pause
Global libvlc_media_player_stop_async.libvlc_media_player_stop_async
Global libvlc_media_player_stop.libvlc_media_player_stop
Global libvlc_media_player_set_renderer.libvlc_media_player_set_renderer
Global libvlc_video_set_callbacks.libvlc_video_set_callbacks
Global libvlc_video_set_format.libvlc_video_set_format
Global libvlc_video_set_format_callbacks.libvlc_video_set_format_callbacks
Global libvlc_video_set_output_callbacks.libvlc_video_set_output_callbacks
Global libvlc_media_player_set_nsobject.libvlc_media_player_set_nsobject
Global libvlc_media_player_get_nsobject.libvlc_media_player_get_nsobject
Global libvlc_media_player_set_xwindow.libvlc_media_player_set_xwindow
Global libvlc_media_player_get_xwindow.libvlc_media_player_get_xwindow
Global libvlc_media_player_set_hwnd.libvlc_media_player_set_hwnd
Global libvlc_media_player_get_hwnd.libvlc_media_player_get_hwnd
Global libvlc_media_player_set_android_context.libvlc_media_player_set_android_context
Global libvlc_audio_set_callbacks.libvlc_audio_set_callbacks
Global libvlc_audio_set_volume_callback.libvlc_audio_set_volume_callback
Global libvlc_audio_set_format_callbacks.libvlc_audio_set_format_callbacks
Global libvlc_audio_set_format.libvlc_audio_set_format
Global libvlc_media_player_get_length.libvlc_media_player_get_length
Global libvlc_media_player_get_time.libvlc_media_player_get_time
Global libvlc_media_player_set_time.libvlc_media_player_set_time
Global libvlc_media_player_get_position.libvlc_media_player_get_position
Global libvlc_media_player_set_position.libvlc_media_player_set_position
Global libvlc_media_player_set_chapter.libvlc_media_player_set_chapter
Global libvlc_media_player_get_chapter.libvlc_media_player_get_chapter
Global libvlc_media_player_get_chapter_count.libvlc_media_player_get_chapter_count
Global libvlc_media_player_get_chapter_count_for_title.libvlc_media_player_get_chapter_count_for_title
Global libvlc_media_player_set_title.libvlc_media_player_set_title
Global libvlc_media_player_get_title.libvlc_media_player_get_title
Global libvlc_media_player_get_title_count.libvlc_media_player_get_title_count
Global libvlc_media_player_previous_chapter.libvlc_media_player_previous_chapter
Global libvlc_media_player_next_chapter.libvlc_media_player_next_chapter
Global libvlc_media_player_get_rate.libvlc_media_player_get_rate
Global libvlc_media_player_set_rate.libvlc_media_player_set_rate
Global libvlc_media_player_get_state.libvlc_media_player_get_state
Global libvlc_media_player_has_vout.libvlc_media_player_has_vout
Global libvlc_media_player_is_seekable.libvlc_media_player_is_seekable
Global libvlc_media_player_can_pause.libvlc_media_player_can_pause
Global libvlc_media_player_program_scrambled.libvlc_media_player_program_scrambled
Global libvlc_media_player_next_frame.libvlc_media_player_next_frame
Global libvlc_media_player_navigate.libvlc_media_player_navigate
Global libvlc_media_player_set_video_title_display.libvlc_media_player_set_video_title_display
Global libvlc_media_player_get_tracklist.libvlc_media_player_get_tracklist
Global libvlc_media_player_get_selected_track.libvlc_media_player_get_selected_track
Global libvlc_media_player_get_track_from_id.libvlc_media_player_get_track_from_id
Global libvlc_media_player_select_track.libvlc_media_player_select_track
Global libvlc_media_player_unselect_track_type.libvlc_media_player_unselect_track_type
Global libvlc_media_player_select_tracks.libvlc_media_player_select_tracks
Global libvlc_media_player_select_tracks_by_ids.libvlc_media_player_select_tracks_by_ids
Global libvlc_media_player_add_slave.libvlc_media_player_add_slave
Global libvlc_player_program_delete.libvlc_player_program_delete
Global libvlc_player_programlist_count.libvlc_player_programlist_count
Global libvlc_player_programlist_at.libvlc_player_programlist_at
Global libvlc_player_programlist_delete.libvlc_player_programlist_delete
Global libvlc_media_player_select_program_id.libvlc_media_player_select_program_id
Global libvlc_media_player_get_selected_program.libvlc_media_player_get_selected_program
Global libvlc_media_player_get_program_from_id.libvlc_media_player_get_program_from_id
Global libvlc_media_player_get_programlist.libvlc_media_player_get_programlist
Global libvlc_track_description_list_release.libvlc_track_description_list_release
Global libvlc_toggle_fullscreen.libvlc_toggle_fullscreen
Global libvlc_set_fullscreen.libvlc_set_fullscreen
Global libvlc_get_fullscreen.libvlc_get_fullscreen
Global libvlc_video_set_key_input.libvlc_video_set_key_input
Global libvlc_video_set_mouse_input.libvlc_video_set_mouse_input
Global libvlc_video_get_size.libvlc_video_get_size
Global libvlc_video_get_cursor.libvlc_video_get_cursor
Global libvlc_video_get_scale.libvlc_video_get_scale
Global libvlc_video_set_scale.libvlc_video_set_scale
Global libvlc_video_get_aspect_ratio.libvlc_video_get_aspect_ratio
Global libvlc_video_set_aspect_ratio.libvlc_video_set_aspect_ratio
Global libvlc_video_new_viewpoint.libvlc_video_new_viewpoint
Global libvlc_video_update_viewpoint.libvlc_video_update_viewpoint
Global libvlc_video_get_spu_delay.libvlc_video_get_spu_delay
Global libvlc_video_get_spu_text_scale.libvlc_video_get_spu_text_scale
Global libvlc_video_set_spu_text_scale.libvlc_video_set_spu_text_scale
Global libvlc_video_set_spu_delay.libvlc_video_set_spu_delay
Global libvlc_media_player_get_full_title_descriptions.libvlc_media_player_get_full_title_descriptions
Global libvlc_title_descriptions_release.libvlc_title_descriptions_release
Global libvlc_media_player_get_full_chapter_descriptions.libvlc_media_player_get_full_chapter_descriptions
Global libvlc_chapter_descriptions_release.libvlc_chapter_descriptions_release
Global libvlc_video_set_crop_ratio.libvlc_video_set_crop_ratio
Global libvlc_video_set_crop_window.libvlc_video_set_crop_window
Global libvlc_video_set_crop_border.libvlc_video_set_crop_border
Global libvlc_video_get_teletext.libvlc_video_get_teletext
Global libvlc_video_set_teletext.libvlc_video_set_teletext
Global libvlc_video_take_snapshot.libvlc_video_take_snapshot
Global libvlc_video_set_deinterlace.libvlc_video_set_deinterlace
Global libvlc_video_get_marquee_int.libvlc_video_get_marquee_int
Global libvlc_video_set_marquee_int.libvlc_video_set_marquee_int
Global libvlc_video_set_marquee_string.libvlc_video_set_marquee_string
Global libvlc_video_get_logo_int.libvlc_video_get_logo_int
Global libvlc_video_set_logo_int.libvlc_video_set_logo_int
Global libvlc_video_set_logo_string.libvlc_video_set_logo_string
Global libvlc_video_get_adjust_int.libvlc_video_get_adjust_int
Global libvlc_video_set_adjust_int.libvlc_video_set_adjust_int
Global libvlc_video_get_adjust_float.libvlc_video_get_adjust_float
Global libvlc_video_set_adjust_float.libvlc_video_set_adjust_float
Global libvlc_video_get_track_count.libvlc_video_get_track_count
Global libvlc_video_get_track_description.libvlc_video_get_track_description
Global libvlc_video_get_track.libvlc_video_get_track
Global libvlc_video_set_track.libvlc_video_set_track
Global libvlc_video_get_spu.libvlc_video_get_spu
Global libvlc_video_get_spu_count.libvlc_video_get_spu_count
Global libvlc_video_get_spu_description.libvlc_video_get_spu_description
Global libvlc_video_set_spu.libvlc_video_set_spu
Global libvlc_audio_output_list_get.libvlc_audio_output_list_get
Global libvlc_audio_output_list_release.libvlc_audio_output_list_release
Global libvlc_audio_output_set.libvlc_audio_output_set
Global libvlc_audio_output_device_enum.libvlc_audio_output_device_enum
Global libvlc_audio_output_device_list_get.libvlc_audio_output_device_list_get
Global libvlc_audio_output_device_list_release.libvlc_audio_output_device_list_release
Global libvlc_audio_output_device_set.libvlc_audio_output_device_set
Global libvlc_audio_output_device_get.libvlc_audio_output_device_get
Global libvlc_audio_toggle_mute.libvlc_audio_toggle_mute
Global libvlc_audio_get_mute.libvlc_audio_get_mute
Global libvlc_audio_set_mute.libvlc_audio_set_mute
Global libvlc_audio_get_volume.libvlc_audio_get_volume
Global libvlc_audio_set_volume.libvlc_audio_set_volume
Global libvlc_audio_get_channel.libvlc_audio_get_channel
Global libvlc_audio_set_channel.libvlc_audio_set_channel
Global libvlc_audio_get_delay.libvlc_audio_get_delay
Global libvlc_audio_set_delay.libvlc_audio_set_delay
Global libvlc_audio_equalizer_get_preset_count.libvlc_audio_equalizer_get_preset_count
Global libvlc_audio_equalizer_get_preset_name.libvlc_audio_equalizer_get_preset_name
Global libvlc_audio_equalizer_get_band_count.libvlc_audio_equalizer_get_band_count
Global libvlc_audio_equalizer_get_band_frequency.libvlc_audio_equalizer_get_band_frequency
Global libvlc_audio_equalizer_new.libvlc_audio_equalizer_new
Global libvlc_audio_equalizer_new_from_preset.libvlc_audio_equalizer_new_from_preset
Global libvlc_audio_equalizer_release.libvlc_audio_equalizer_release
Global libvlc_audio_equalizer_set_preamp.libvlc_audio_equalizer_set_preamp
Global libvlc_audio_equalizer_get_preamp.libvlc_audio_equalizer_get_preamp
Global libvlc_audio_equalizer_set_amp_at_index.libvlc_audio_equalizer_set_amp_at_index
Global libvlc_audio_equalizer_get_amp_at_index.libvlc_audio_equalizer_get_amp_at_index
Global libvlc_media_player_set_equalizer.libvlc_media_player_set_equalizer
Global libvlc_media_player_get_role.libvlc_media_player_get_role
Global libvlc_media_player_set_role.libvlc_media_player_set_role
Global libvlc_audio_get_track_count.libvlc_audio_get_track_count
Global libvlc_audio_get_track_description.libvlc_audio_get_track_description
Global libvlc_audio_get_track.libvlc_audio_get_track
Global libvlc_audio_set_track.libvlc_audio_set_track
Global libvlc_media_list_new.libvlc_media_list_new
Global libvlc_media_list_release.libvlc_media_list_release
Global libvlc_media_list_retain.libvlc_media_list_retain
Global libvlc_media_list_set_media.libvlc_media_list_set_media
Global libvlc_media_list_media.libvlc_media_list_media
Global libvlc_media_list_add_media.libvlc_media_list_add_media
Global libvlc_media_list_insert_media.libvlc_media_list_insert_media
Global libvlc_media_list_remove_index.libvlc_media_list_remove_index
Global libvlc_media_list_count.libvlc_media_list_count
Global libvlc_media_list_item_at_index.libvlc_media_list_item_at_index
Global libvlc_media_list_index_of_item.libvlc_media_list_index_of_item
Global libvlc_media_list_is_readonly.libvlc_media_list_is_readonly
Global libvlc_media_list_lock.libvlc_media_list_lock
Global libvlc_media_list_unlock.libvlc_media_list_unlock
Global libvlc_media_list_event_manager.libvlc_media_list_event_manager
Global libvlc_media_list_player_new.libvlc_media_list_player_new
Global libvlc_media_list_player_release.libvlc_media_list_player_release
Global libvlc_media_list_player_retain.libvlc_media_list_player_retain
Global libvlc_media_list_player_event_manager.libvlc_media_list_player_event_manager
Global libvlc_media_list_player_set_media_player.libvlc_media_list_player_set_media_player
Global libvlc_media_list_player_get_media_player.libvlc_media_list_player_get_media_player
Global libvlc_media_list_player_set_media_list.libvlc_media_list_player_set_media_list
Global libvlc_media_list_player_play.libvlc_media_list_player_play
Global libvlc_media_list_player_pause.libvlc_media_list_player_pause
Global libvlc_media_list_player_set_pause.libvlc_media_list_player_set_pause
Global libvlc_media_list_player_is_playing.libvlc_media_list_player_is_playing
Global libvlc_media_list_player_get_state.libvlc_media_list_player_get_state
Global libvlc_media_list_player_play_item_at_index.libvlc_media_list_player_play_item_at_index
Global libvlc_media_list_player_play_item.libvlc_media_list_player_play_item
Global libvlc_media_list_player_stop_async.libvlc_media_list_player_stop_async
Global libvlc_media_list_player_next.libvlc_media_list_player_next
Global libvlc_media_list_player_previous.libvlc_media_list_player_previous
Global libvlc_media_list_player_set_playback_mode.libvlc_media_list_player_set_playback_mode

Procedure libvlc_loadapi(libvlc)
	libvlc_new=GetFunction(libvlc,"libvlc_new")
	If libvlc_new= 0:ProcedureReturn:EndIf
	libvlc_release=GetFunction(libvlc,"libvlc_release")
	libvlc_retain=GetFunction(libvlc,"libvlc_retain")
	libvlc_add_intf=GetFunction(libvlc,"libvlc_add_intf")
	libvlc_set_exit_handler=GetFunction(libvlc,"libvlc_set_exit_handler")
	libvlc_set_user_agent=GetFunction(libvlc,"libvlc_set_user_agent")
	libvlc_set_app_id=GetFunction(libvlc,"libvlc_set_app_id")
	libvlc_get_version=GetFunction(libvlc,"libvlc_get_version")
	libvlc_get_compiler=GetFunction(libvlc,"libvlc_get_compiler")
	libvlc_get_changeset=GetFunction(libvlc,"libvlc_get_changeset")
	libvlc_free=GetFunction(libvlc,"libvlc_free")
	libvlc_module_description_list_release=GetFunction(libvlc,"libvlc_module_description_list_release")
	libvlc_audio_filter_list_get=GetFunction(libvlc,"libvlc_audio_filter_list_get")
	libvlc_video_filter_list_get=GetFunction(libvlc,"libvlc_video_filter_list_get")
	libvlc_errmsg=GetFunction(libvlc,"libvlc_errmsg")
	libvlc_clearerr=GetFunction(libvlc,"libvlc_clearerr")
	libvlc_vprinterr=GetFunction(libvlc,"libvlc_vprinterr")
	libvlc_event_attach=GetFunction(libvlc,"libvlc_event_attach")
	libvlc_event_detach=GetFunction(libvlc,"libvlc_event_detach")
	libvlc_log_get_context=GetFunction(libvlc,"libvlc_log_get_context")
	libvlc_log_get_object=GetFunction(libvlc,"libvlc_log_get_object")
	libvlc_log_unset=GetFunction(libvlc,"libvlc_log_unset")
	libvlc_log_set=GetFunction(libvlc,"libvlc_log_set")
	libvlc_log_set_file=GetFunction(libvlc,"libvlc_log_set_file")
	libvlc_clock=GetFunction(libvlc,"libvlc_clock")
	libvlc_dialog_set_callbacks=GetFunction(libvlc,"libvlc_dialog_set_callbacks")
	libvlc_dialog_set_context=GetFunction(libvlc,"libvlc_dialog_set_context")
	libvlc_dialog_get_context=GetFunction(libvlc,"libvlc_dialog_get_context")
	libvlc_dialog_post_login=GetFunction(libvlc,"libvlc_dialog_post_login")
	libvlc_dialog_post_action=GetFunction(libvlc,"libvlc_dialog_post_action")
	libvlc_dialog_dismiss=GetFunction(libvlc,"libvlc_dialog_dismiss")
	libvlc_media_new_location=GetFunction(libvlc,"libvlc_media_new_location")
	libvlc_media_new_path=GetFunction(libvlc,"libvlc_media_new_path")
	libvlc_media_new_fd=GetFunction(libvlc,"libvlc_media_new_fd")
	libvlc_media_new_callbacks=GetFunction(libvlc,"libvlc_media_new_callbacks")
	libvlc_media_new_as_node=GetFunction(libvlc,"libvlc_media_new_as_node")
	libvlc_media_add_option=GetFunction(libvlc,"libvlc_media_add_option")
	libvlc_media_add_option_flag=GetFunction(libvlc,"libvlc_media_add_option_flag")
	libvlc_media_retain=GetFunction(libvlc,"libvlc_media_retain")
	libvlc_media_release=GetFunction(libvlc,"libvlc_media_release")
	libvlc_media_get_mrl=GetFunction(libvlc,"libvlc_media_get_mrl")
	libvlc_media_duplicate=GetFunction(libvlc,"libvlc_media_duplicate")
	libvlc_media_get_meta=GetFunction(libvlc,"libvlc_media_get_meta")
	libvlc_media_set_meta=GetFunction(libvlc,"libvlc_media_set_meta")
	libvlc_media_save_meta=GetFunction(libvlc,"libvlc_media_save_meta")
	libvlc_media_get_state=GetFunction(libvlc,"libvlc_media_get_state")
	libvlc_media_get_stats=GetFunction(libvlc,"libvlc_media_get_stats")
	libvlc_media_subitems=GetFunction(libvlc,"libvlc_media_subitems")
	libvlc_media_event_manager=GetFunction(libvlc,"libvlc_media_event_manager")
	libvlc_media_get_duration=GetFunction(libvlc,"libvlc_media_get_duration")
	libvlc_media_parse_with_options=GetFunction(libvlc,"libvlc_media_parse_with_options")
	libvlc_media_parse_stop=GetFunction(libvlc,"libvlc_media_parse_stop")
	libvlc_media_get_parsed_status=GetFunction(libvlc,"libvlc_media_get_parsed_status")
	libvlc_media_set_user_data=GetFunction(libvlc,"libvlc_media_set_user_data")
	libvlc_media_get_user_data=GetFunction(libvlc,"libvlc_media_get_user_data")
	libvlc_media_get_tracklist=GetFunction(libvlc,"libvlc_media_get_tracklist")
	libvlc_media_get_codec_description=GetFunction(libvlc,"libvlc_media_get_codec_description")
	libvlc_media_get_type=GetFunction(libvlc,"libvlc_media_get_type")
	libvlc_media_thumbnail_request_by_time=GetFunction(libvlc,"libvlc_media_thumbnail_request_by_time")
	libvlc_media_thumbnail_request_by_pos=GetFunction(libvlc,"libvlc_media_thumbnail_request_by_pos")
	libvlc_media_thumbnail_request_cancel=GetFunction(libvlc,"libvlc_media_thumbnail_request_cancel")
	libvlc_media_thumbnail_request_destroy=GetFunction(libvlc,"libvlc_media_thumbnail_request_destroy")
	libvlc_media_slaves_add=GetFunction(libvlc,"libvlc_media_slaves_add")
	libvlc_media_slaves_clear=GetFunction(libvlc,"libvlc_media_slaves_clear")
	libvlc_media_slaves_get=GetFunction(libvlc,"libvlc_media_slaves_get")
	libvlc_media_slaves_release=GetFunction(libvlc,"libvlc_media_slaves_release")
	libvlc_media_parse=GetFunction(libvlc,"libvlc_media_parse")
	libvlc_media_parse_async=GetFunction(libvlc,"libvlc_media_parse_async")
	libvlc_media_is_parsed=GetFunction(libvlc,"libvlc_media_is_parsed")
	libvlc_media_tracks_get=GetFunction(libvlc,"libvlc_media_tracks_get")
	libvlc_media_tracks_release=GetFunction(libvlc,"libvlc_media_tracks_release")
	libvlc_media_player_new=GetFunction(libvlc,"libvlc_media_player_new")
	libvlc_media_player_new_from_media=GetFunction(libvlc,"libvlc_media_player_new_from_media")
	libvlc_media_player_release=GetFunction(libvlc,"libvlc_media_player_release")
	libvlc_media_player_retain=GetFunction(libvlc,"libvlc_media_player_retain")
	libvlc_media_player_set_media=GetFunction(libvlc,"libvlc_media_player_set_media")
	libvlc_media_player_get_media=GetFunction(libvlc,"libvlc_media_player_get_media")
	libvlc_media_player_event_manager=GetFunction(libvlc,"libvlc_media_player_event_manager")
	libvlc_media_player_is_playing=GetFunction(libvlc,"libvlc_media_player_is_playing")
	libvlc_media_player_play=GetFunction(libvlc,"libvlc_media_player_play")
	libvlc_media_player_set_pause=GetFunction(libvlc,"libvlc_media_player_set_pause")
	libvlc_media_player_pause=GetFunction(libvlc,"libvlc_media_player_pause")
	libvlc_media_player_stop_async=GetFunction(libvlc,"libvlc_media_player_stop_async")
	libvlc_media_player_stop=GetFunction(libvlc,"libvlc_media_player_stop")
	libvlc_media_player_set_renderer=GetFunction(libvlc,"libvlc_media_player_set_renderer")
	libvlc_video_set_callbacks=GetFunction(libvlc,"libvlc_video_set_callbacks")
	libvlc_video_set_format=GetFunction(libvlc,"libvlc_video_set_format")
	libvlc_video_set_format_callbacks=GetFunction(libvlc,"libvlc_video_set_format_callbacks")
	libvlc_video_set_output_callbacks=GetFunction(libvlc,"libvlc_video_set_output_callbacks")
	libvlc_media_player_set_nsobject=GetFunction(libvlc,"libvlc_media_player_set_nsobject")
	libvlc_media_player_get_nsobject=GetFunction(libvlc,"libvlc_media_player_get_nsobject")
	libvlc_media_player_set_xwindow=GetFunction(libvlc,"libvlc_media_player_set_xwindow")
	libvlc_media_player_get_xwindow=GetFunction(libvlc,"libvlc_media_player_get_xwindow")
	libvlc_media_player_set_hwnd=GetFunction(libvlc,"libvlc_media_player_set_hwnd")
	libvlc_media_player_get_hwnd=GetFunction(libvlc,"libvlc_media_player_get_hwnd")
	libvlc_media_player_set_android_context=GetFunction(libvlc,"libvlc_media_player_set_android_context")
	libvlc_audio_set_callbacks=GetFunction(libvlc,"libvlc_audio_set_callbacks")
	libvlc_audio_set_volume_callback=GetFunction(libvlc,"libvlc_audio_set_volume_callback")
	libvlc_audio_set_format_callbacks=GetFunction(libvlc,"libvlc_audio_set_format_callbacks")
	libvlc_audio_set_format=GetFunction(libvlc,"libvlc_audio_set_format")
	libvlc_media_player_get_length=GetFunction(libvlc,"libvlc_media_player_get_length")
	libvlc_media_player_get_time=GetFunction(libvlc,"libvlc_media_player_get_time")
	libvlc_media_player_set_time=GetFunction(libvlc,"libvlc_media_player_set_time")
	libvlc_media_player_get_position=GetFunction(libvlc,"libvlc_media_player_get_position")
	libvlc_media_player_set_position=GetFunction(libvlc,"libvlc_media_player_set_position")
	libvlc_media_player_set_chapter=GetFunction(libvlc,"libvlc_media_player_set_chapter")
	libvlc_media_player_get_chapter=GetFunction(libvlc,"libvlc_media_player_get_chapter")
	libvlc_media_player_get_chapter_count=GetFunction(libvlc,"libvlc_media_player_get_chapter_count")
	libvlc_media_player_get_chapter_count_for_title=GetFunction(libvlc,"libvlc_media_player_get_chapter_count_for_title")
	libvlc_media_player_set_title=GetFunction(libvlc,"libvlc_media_player_set_title")
	libvlc_media_player_get_title=GetFunction(libvlc,"libvlc_media_player_get_title")
	libvlc_media_player_get_title_count=GetFunction(libvlc,"libvlc_media_player_get_title_count")
	libvlc_media_player_previous_chapter=GetFunction(libvlc,"libvlc_media_player_previous_chapter")
	libvlc_media_player_next_chapter=GetFunction(libvlc,"libvlc_media_player_next_chapter")
	libvlc_media_player_get_rate=GetFunction(libvlc,"libvlc_media_player_get_rate")
	libvlc_media_player_set_rate=GetFunction(libvlc,"libvlc_media_player_set_rate")
	libvlc_media_player_get_state=GetFunction(libvlc,"libvlc_media_player_get_state")
	libvlc_media_player_has_vout=GetFunction(libvlc,"libvlc_media_player_has_vout")
	libvlc_media_player_is_seekable=GetFunction(libvlc,"libvlc_media_player_is_seekable")
	libvlc_media_player_can_pause=GetFunction(libvlc,"libvlc_media_player_can_pause")
	libvlc_media_player_program_scrambled=GetFunction(libvlc,"libvlc_media_player_program_scrambled")
	libvlc_media_player_next_frame=GetFunction(libvlc,"libvlc_media_player_next_frame")
	libvlc_media_player_navigate=GetFunction(libvlc,"libvlc_media_player_navigate")
	libvlc_media_player_set_video_title_display=GetFunction(libvlc,"libvlc_media_player_set_video_title_display")
	libvlc_media_player_get_tracklist=GetFunction(libvlc,"libvlc_media_player_get_tracklist")
	libvlc_media_player_get_selected_track=GetFunction(libvlc,"libvlc_media_player_get_selected_track")
	libvlc_media_player_get_track_from_id=GetFunction(libvlc,"libvlc_media_player_get_track_from_id")
	libvlc_media_player_select_track=GetFunction(libvlc,"libvlc_media_player_select_track")
	libvlc_media_player_unselect_track_type=GetFunction(libvlc,"libvlc_media_player_unselect_track_type")
	libvlc_media_player_select_tracks=GetFunction(libvlc,"libvlc_media_player_select_tracks")
	libvlc_media_player_select_tracks_by_ids=GetFunction(libvlc,"libvlc_media_player_select_tracks_by_ids")
	libvlc_media_player_add_slave=GetFunction(libvlc,"libvlc_media_player_add_slave")
	libvlc_player_program_delete=GetFunction(libvlc,"libvlc_player_program_delete")
	libvlc_player_programlist_count=GetFunction(libvlc,"libvlc_player_programlist_count")
	libvlc_player_programlist_at=GetFunction(libvlc,"libvlc_player_programlist_at")
	libvlc_player_programlist_delete=GetFunction(libvlc,"libvlc_player_programlist_delete")
	libvlc_media_player_select_program_id=GetFunction(libvlc,"libvlc_media_player_select_program_id")
	libvlc_media_player_get_selected_program=GetFunction(libvlc,"libvlc_media_player_get_selected_program")
	libvlc_media_player_get_program_from_id=GetFunction(libvlc,"libvlc_media_player_get_program_from_id")
	libvlc_media_player_get_programlist=GetFunction(libvlc,"libvlc_media_player_get_programlist")
	libvlc_track_description_list_release=GetFunction(libvlc,"libvlc_track_description_list_release")
	libvlc_toggle_fullscreen=GetFunction(libvlc,"libvlc_toggle_fullscreen")
	libvlc_set_fullscreen=GetFunction(libvlc,"libvlc_set_fullscreen")
	libvlc_get_fullscreen=GetFunction(libvlc,"libvlc_get_fullscreen")
	libvlc_video_set_key_input=GetFunction(libvlc,"libvlc_video_set_key_input")
	libvlc_video_set_mouse_input=GetFunction(libvlc,"libvlc_video_set_mouse_input")
	libvlc_video_get_size=GetFunction(libvlc,"libvlc_video_get_size")
	libvlc_video_get_cursor=GetFunction(libvlc,"libvlc_video_get_cursor")
	libvlc_video_get_scale=GetFunction(libvlc,"libvlc_video_get_scale")
	libvlc_video_set_scale=GetFunction(libvlc,"libvlc_video_set_scale")
	libvlc_video_get_aspect_ratio=GetFunction(libvlc,"libvlc_video_get_aspect_ratio")
	libvlc_video_set_aspect_ratio=GetFunction(libvlc,"libvlc_video_set_aspect_ratio")
	libvlc_video_new_viewpoint=GetFunction(libvlc,"libvlc_video_new_viewpoint")
	libvlc_video_update_viewpoint=GetFunction(libvlc,"libvlc_video_update_viewpoint")
	libvlc_video_get_spu_delay=GetFunction(libvlc,"libvlc_video_get_spu_delay")
	libvlc_video_get_spu_text_scale=GetFunction(libvlc,"libvlc_video_get_spu_text_scale")
	libvlc_video_set_spu_text_scale=GetFunction(libvlc,"libvlc_video_set_spu_text_scale")
	libvlc_video_set_spu_delay=GetFunction(libvlc,"libvlc_video_set_spu_delay")
	libvlc_media_player_get_full_title_descriptions=GetFunction(libvlc,"libvlc_media_player_get_full_title_descriptions")
	libvlc_title_descriptions_release=GetFunction(libvlc,"libvlc_title_descriptions_release")
	libvlc_media_player_get_full_chapter_descriptions=GetFunction(libvlc,"libvlc_media_player_get_full_chapter_descriptions")
	libvlc_chapter_descriptions_release=GetFunction(libvlc,"libvlc_chapter_descriptions_release")
	libvlc_video_set_crop_ratio=GetFunction(libvlc,"libvlc_video_set_crop_ratio")
	libvlc_video_set_crop_window=GetFunction(libvlc,"libvlc_video_set_crop_window")
	libvlc_video_set_crop_border=GetFunction(libvlc,"libvlc_video_set_crop_border")
	libvlc_video_get_teletext=GetFunction(libvlc,"libvlc_video_get_teletext")
	libvlc_video_set_teletext=GetFunction(libvlc,"libvlc_video_set_teletext")
	libvlc_video_take_snapshot=GetFunction(libvlc,"libvlc_video_take_snapshot")
	libvlc_video_set_deinterlace=GetFunction(libvlc,"libvlc_video_set_deinterlace")
	libvlc_video_get_marquee_int=GetFunction(libvlc,"libvlc_video_get_marquee_int")
	libvlc_video_set_marquee_int=GetFunction(libvlc,"libvlc_video_set_marquee_int")
	libvlc_video_set_marquee_string=GetFunction(libvlc,"libvlc_video_set_marquee_string")
	libvlc_video_get_logo_int=GetFunction(libvlc,"libvlc_video_get_logo_int")
	libvlc_video_set_logo_int=GetFunction(libvlc,"libvlc_video_set_logo_int")
	libvlc_video_set_logo_string=GetFunction(libvlc,"libvlc_video_set_logo_string")
	libvlc_video_get_adjust_int=GetFunction(libvlc,"libvlc_video_get_adjust_int")
	libvlc_video_set_adjust_int=GetFunction(libvlc,"libvlc_video_set_adjust_int")
	libvlc_video_get_adjust_float=GetFunction(libvlc,"libvlc_video_get_adjust_float")
	libvlc_video_set_adjust_float=GetFunction(libvlc,"libvlc_video_set_adjust_float")
	libvlc_video_get_track_count=GetFunction(libvlc,"libvlc_video_get_track_count")
	libvlc_video_get_track_description=GetFunction(libvlc,"libvlc_video_get_track_description")
	libvlc_video_get_track=GetFunction(libvlc,"libvlc_video_get_track")
	libvlc_video_set_track=GetFunction(libvlc,"libvlc_video_set_track")
	libvlc_video_get_spu=GetFunction(libvlc,"libvlc_video_get_spu")
	libvlc_video_get_spu_count=GetFunction(libvlc,"libvlc_video_get_spu_count")
	libvlc_video_get_spu_description=GetFunction(libvlc,"libvlc_video_get_spu_description")
	libvlc_video_set_spu=GetFunction(libvlc,"libvlc_video_set_spu")
	libvlc_audio_output_list_get=GetFunction(libvlc,"libvlc_audio_output_list_get")
	libvlc_audio_output_list_release=GetFunction(libvlc,"libvlc_audio_output_list_release")
	libvlc_audio_output_set=GetFunction(libvlc,"libvlc_audio_output_set")
	libvlc_audio_output_device_enum=GetFunction(libvlc,"libvlc_audio_output_device_enum")
	libvlc_audio_output_device_list_get=GetFunction(libvlc,"libvlc_audio_output_device_list_get")
	libvlc_audio_output_device_list_release=GetFunction(libvlc,"libvlc_audio_output_device_list_release")
	libvlc_audio_output_device_set=GetFunction(libvlc,"libvlc_audio_output_device_set")
	libvlc_audio_output_device_get=GetFunction(libvlc,"libvlc_audio_output_device_get")
	libvlc_audio_toggle_mute=GetFunction(libvlc,"libvlc_audio_toggle_mute")
	libvlc_audio_get_mute=GetFunction(libvlc,"libvlc_audio_get_mute")
	libvlc_audio_set_mute=GetFunction(libvlc,"libvlc_audio_set_mute")
	libvlc_audio_get_volume=GetFunction(libvlc,"libvlc_audio_get_volume")
	libvlc_audio_set_volume=GetFunction(libvlc,"libvlc_audio_set_volume")
	libvlc_audio_get_channel=GetFunction(libvlc,"libvlc_audio_get_channel")
	libvlc_audio_set_channel=GetFunction(libvlc,"libvlc_audio_set_channel")
	libvlc_audio_get_delay=GetFunction(libvlc,"libvlc_audio_get_delay")
	libvlc_audio_set_delay=GetFunction(libvlc,"libvlc_audio_set_delay")
	libvlc_audio_equalizer_get_preset_count=GetFunction(libvlc,"libvlc_audio_equalizer_get_preset_count")
	libvlc_audio_equalizer_get_preset_name=GetFunction(libvlc,"libvlc_audio_equalizer_get_preset_name")
	libvlc_audio_equalizer_get_band_count=GetFunction(libvlc,"libvlc_audio_equalizer_get_band_count")
	libvlc_audio_equalizer_get_band_frequency=GetFunction(libvlc,"libvlc_audio_equalizer_get_band_frequency")
	libvlc_audio_equalizer_new=GetFunction(libvlc,"libvlc_audio_equalizer_new")
	libvlc_audio_equalizer_new_from_preset=GetFunction(libvlc,"libvlc_audio_equalizer_new_from_preset")
	libvlc_audio_equalizer_release=GetFunction(libvlc,"libvlc_audio_equalizer_release")
	libvlc_audio_equalizer_set_preamp=GetFunction(libvlc,"libvlc_audio_equalizer_set_preamp")
	libvlc_audio_equalizer_get_preamp=GetFunction(libvlc,"libvlc_audio_equalizer_get_preamp")
	libvlc_audio_equalizer_set_amp_at_index=GetFunction(libvlc,"libvlc_audio_equalizer_set_amp_at_index")
	libvlc_audio_equalizer_get_amp_at_index=GetFunction(libvlc,"libvlc_audio_equalizer_get_amp_at_index")
	libvlc_media_player_set_equalizer=GetFunction(libvlc,"libvlc_media_player_set_equalizer")
	libvlc_media_player_get_role=GetFunction(libvlc,"libvlc_media_player_get_role")
	libvlc_media_player_set_role=GetFunction(libvlc,"libvlc_media_player_set_role")
	libvlc_audio_get_track_count=GetFunction(libvlc,"libvlc_audio_get_track_count")
	libvlc_audio_get_track_description=GetFunction(libvlc,"libvlc_audio_get_track_description")
	libvlc_audio_get_track=GetFunction(libvlc,"libvlc_audio_get_track")
	libvlc_audio_set_track=GetFunction(libvlc,"libvlc_audio_set_track")
	libvlc_media_list_new=GetFunction(libvlc,"libvlc_media_list_new")
	libvlc_media_list_release=GetFunction(libvlc,"libvlc_media_list_release")
	libvlc_media_list_retain=GetFunction(libvlc,"libvlc_media_list_retain")
	libvlc_media_list_set_media=GetFunction(libvlc,"libvlc_media_list_set_media")
	libvlc_media_list_media=GetFunction(libvlc,"libvlc_media_list_media")
	libvlc_media_list_add_media=GetFunction(libvlc,"libvlc_media_list_add_media")
	libvlc_media_list_insert_media=GetFunction(libvlc,"libvlc_media_list_insert_media")
	libvlc_media_list_remove_index=GetFunction(libvlc,"libvlc_media_list_remove_index")
	libvlc_media_list_count=GetFunction(libvlc,"libvlc_media_list_count")
	libvlc_media_list_item_at_index=GetFunction(libvlc,"libvlc_media_list_item_at_index")
	libvlc_media_list_index_of_item=GetFunction(libvlc,"libvlc_media_list_index_of_item")
	libvlc_media_list_is_readonly=GetFunction(libvlc,"libvlc_media_list_is_readonly")
	libvlc_media_list_lock=GetFunction(libvlc,"libvlc_media_list_lock")
	libvlc_media_list_unlock=GetFunction(libvlc,"libvlc_media_list_unlock")
	libvlc_media_list_event_manager=GetFunction(libvlc,"libvlc_media_list_event_manager")
	
	libvlc_media_list_player_new=GetFunction(libvlc,"libvlc_media_list_player_new")
	libvlc_media_list_player_release=GetFunction(libvlc,"libvlc_media_list_player_release")
	libvlc_media_list_player_retain=GetFunction(libvlc,"libvlc_media_list_player_retain")
	libvlc_media_list_player_event_manager=GetFunction(libvlc,"libvlc_media_list_player_event_manager")
	libvlc_media_list_player_set_media_player=GetFunction(libvlc,"libvlc_media_list_player_set_media_player")
	libvlc_media_list_player_get_media_player=GetFunction(libvlc,"libvlc_media_list_player_get_media_player")
	libvlc_media_list_player_set_media_list=GetFunction(libvlc,"libvlc_media_list_player_set_media_list")
	libvlc_media_list_player_play=GetFunction(libvlc,"libvlc_media_list_player_play")
	libvlc_media_list_player_pause=GetFunction(libvlc,"libvlc_media_list_player_pause")
	libvlc_media_list_player_set_pause=GetFunction(libvlc,"libvlc_media_list_player_set_pause")
	libvlc_media_list_player_is_playing=GetFunction(libvlc,"libvlc_media_list_player_is_playing")
	libvlc_media_list_player_get_state=GetFunction(libvlc,"libvlc_media_list_player_get_state")
	libvlc_media_list_player_play_item_at_index=GetFunction(libvlc,"libvlc_media_list_player_play_item_at_index")
	libvlc_media_list_player_play_item=GetFunction(libvlc,"libvlc_media_list_player_play_item")
	libvlc_media_list_player_stop_async=GetFunction(libvlc,"libvlc_media_list_player_stop_async")
	libvlc_media_list_player_next=GetFunction(libvlc,"libvlc_media_list_player_next")
	libvlc_media_list_player_previous=GetFunction(libvlc,"libvlc_media_list_player_previous")
	libvlc_media_list_player_set_playback_mode=GetFunction(libvlc,"libvlc_media_list_player_set_playback_mode")
	
	;LibVLC 4.0.0 and later.
	; libvlc_media_get_tracklist
	; libvlc_media_thumbnail_request_by_time
	; libvlc_media_thumbnail_request_by_pos
	; libvlc_media_thumbnail_request_cancel
	; libvlc_media_thumbnail_request_destroy
	; libvlc_media_player_stop_async
	; libvlc_video_set_output_callbacks
	; libvlc_media_player_get_tracklist
	; libvlc_media_player_get_selected_track
	; libvlc_media_player_get_track_from_id
	; libvlc_media_player_select_track
	; libvlc_media_player_unselect_track_type
	; libvlc_media_player_select_tracks
	; libvlc_media_player_select_tracks_by_ids
	; libvlc_player_program_delete
	; libvlc_player_programlist_count
	; libvlc_player_programlist_at
	; libvlc_player_programlist_delete
	; libvlc_media_player_select_program_id
	; libvlc_media_player_get_selected_program
	; libvlc_media_player_get_program_from_id
	; libvlc_media_player_get_programlist
	; libvlc_video_get_spu_text_scale
	; libvlc_video_set_spu_text_scale
	; libvlc_video_set_crop_ratio
	; libvlc_video_set_crop_window
	; libvlc_video_set_crop_border
	ProcedureReturn libvlc_get_version
EndProcedure
; IDE Options = PureBasic 5.73 LTS (Windows - x64)
; CursorPosition = 1895
; FirstLine = 1860
; Folding = -
; EnableXP