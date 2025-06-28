; File TVideoGrabber_15.4.1.8.pbi
; derived from TVideoGrabber.h

#SCS_TVG_DLL = "TVideoGrabber_15.4.1.8.dll"

EnableExplicit

Global gnTVGLibrary
Global gbTVGAvailable

#tvc_false = 0
#tvc_true = -1

Enumeration ;- TAero
  #tvc_ae_Default = 0
  #tvc_ae_AutoBestRenderingQuality = 1
  #tvc_ae_ForceOnWhenStartingVideo = 2
  #tvc_ae_ForceOffWhenStartingVideo = 3
  #tvc_ae_ForceOnImmediately = 4
  #tvc_ae_ForceOffImmediately = 5
EndEnumeration

Enumeration ;- TApplicationPriority
  #tvc_ap_default = 0
  #tvc_ap_idle = 1
  #tvc_ap_normal = 2
  #tvc_ap_high = 3
  #tvc_ap_realtime = 4
EndEnumeration

Enumeration ;- TASFDeinterlaceMode
  #tvc_adm_NotInterlaced = 0
  #tvc_adm_DeinterlaceNormal = 1
  #tvc_adm_DeinterlaceHalfSize = 2
  #tvc_adm_DeinterlaceHalfSizeDoubleRate = 3
  #tvc_adm_DeinterlaceInverseTelecine = 4
  #tvc_adm_DeinterlaceVerticalHalfSizeDoubleRate = 5
EndEnumeration

Enumeration ;- TASFProfileVersion
  #tvc_apv_ProfileVersion_8 = 0
  #tvc_apv_ProfileVersion_9 = 1
EndEnumeration

Enumeration ;- TAspectRatio
  #tvc_ar_Box = 0
  #tvc_ar_NoResize = 1
  #tvc_ar_Stretch = 2
  #tvc_ar_PanScan = 3
EndEnumeration

Enumeration ;- TAudioChannelRenderMode
  #tvc_acrm_Normal = 0
  #tvc_acrm_RenderLeft = 1
  #tvc_acrm_RenderRight = 2
  #tvc_acrm_MuteLeft = 3
  #tvc_acrm_MuteRight = 4
  #tvc_acrm_Mute_All = 5
  #tvc_acrm_MixLeftAndRight = 6
  #tvc_acrm_PassThru = 7
EndEnumeration

Enumeration ;- TAudioFormat
  #tvc_af_default = 0
  #tvc_af_8000_8b_1ch = 1
  #tvc_af_8000_8b_2ch = 2
  #tvc_af_8000_16b_1ch = 3
  #tvc_af_8000_16b_2ch = 4
  #tvc_af_11025_8b_1ch = 5
  #tvc_af_11025_8b_2ch = 6
  #tvc_af_11025_16b_1ch = 7
  #tvc_af_11025_16b_2ch = 8
  #tvc_af_16000_8b_1ch = 9
  #tvc_af_16000_8b_2ch = 10
  #tvc_af_16000_16b_1ch = 11
  #tvc_af_16000_16b_2ch = 12
  #tvc_af_22050_8b_1ch = 13
  #tvc_af_22050_8b_2ch = 14
  #tvc_af_22050_16b_1ch = 15
  #tvc_af_22050_16b_2ch = 16
  #tvc_af_32000_8b_1ch = 17
  #tvc_af_32000_8b_2ch = 18
  #tvc_af_32000_16b_1ch = 19
  #tvc_af_32000_16b_2ch = 20
  #tvc_af_44100_8b_1ch = 21
  #tvc_af_44100_8b_2ch = 22
  #tvc_af_44100_16b_1ch = 23
  #tvc_af_44100_16b_2ch = 24
  #tvc_af_48000_8b_1ch = 25
  #tvc_af_48000_8b_2ch = 26
  #tvc_af_48000_16b_1ch = 27
  #tvc_af_48000_16b_2ch = 28
EndEnumeration

Enumeration ;- TAudioPCMFormat
  #tvc_PCM_U8 = 0
  #tvc_PCM_S16 = 1
  #tvc_PCM_S32 = 2
  #tvc_PCM_FLT = 3
  #tvc_PCM_DBL = 4
EndEnumeration

Enumeration ;- TAudioSource
  #tvc_as_Default = 0
  #tvc_as_UseExternalAudio = 1
  #tvc_as_UseMixAudioSample = 2
  #tvc_as_SpeakerOutput = 3
  #tvc_as_DefaultWithSpeakerRecording = 4
  #tvc_as_Silent = 5
EndEnumeration

Enumeration ;- TAuthenticationType
  #tvc_at_PublishingPoint = 0
  #tvc_at_IPCamera = 1
  #tvc_at_StreamingUrl = 2
EndEnumeration

Enumeration ;- TAutoFileName
  #tvc_fn_Sequential = 0
  #tvc_fn_DateTime = 1
  #tvc_fn_Counter = 2
  #tvc_fn_Modulo = 3
  #tvc_fn_GUID = 4
EndEnumeration

Enumeration ;- TAVIInfoType
  #tvc_av_Duration = 0
  #tvc_av_FrameCount = 1
  #tvc_av_VideoWidth = 2
  #tvc_av_VideoHeight = 3
  #tvc_av_VideoFrameRateFps = 4
  #tvc_av_VideoCodec = 5
  #tvc_av_AudioCodec = 6
  #tvc_av_AvgBitRate = 7
  #tvc_av_AudioChannels = 8
  #tvc_av_AudioSamplesPerSec = 9
  #tvc_av_AudioBitsPerSample = 10
  #tvc_av_FileSizeInKB = 11
  #tvc_av_AudioStreams = 12
EndEnumeration

Enumeration ;- TAVIMuxConfig
  #tvc_avmx_SetInterleavingMode = 0
  #tvc_avmx_SetInterleave = 1
  #tvc_avmx_SetPreroll = 2
EndEnumeration

Enumeration ;- TBorderStyle
  #tvc_bsNone = 0
  #tvc_bsSingle = 1
EndEnumeration

Enumeration ;- TCameraControl
  #tvc_cc_Pan = 0
  #tvc_cc_Tilt = 1
  #tvc_cc_Roll = 2
  #tvc_cc_Zoom = 3
  #tvc_cc_Exposure = 4
  #tvc_cc_Iris = 5
  #tvc_cc_Focus = 6
EndEnumeration

Enumeration ;- TCardinalDirection
  #tvc_cd_North = 0
  #tvc_cd_NorthEast = 1
  #tvc_cd_East = 2
  #tvc_cd_SouthEast = 3
  #tvc_cd_South = 4
  #tvc_cd_SouthWest = 5
  #tvc_cd_West = 6
  #tvc_cd_NorthWest = 7
  #tvc_cd_Center = 8
EndEnumeration

Enumeration ;- TCompressionMode
  #tvc_cm_NoCompression = 0
  #tvc_cm_CompressOnTheFly = 1
  #tvc_cm_CompressAfterRecording = 2
EndEnumeration

Enumeration ;- TCompressionType
  #tvc_ct_Video = 0
  #tvc_ct_Audio = 1
  #tvc_ct_AudioVideo = 2
EndEnumeration

Enumeration ;- TCurrentState
  #tvc_cs_Down = 0
  #tvc_cs_Preview = 1
  #tvc_cs_Recording = 2
  #tvc_cs_Playback = 3
  #tvc_cs_Reencoding = 4
EndEnumeration

Enumeration ;- TCursors
  #tvc_cr_Default = 0
  #tvc_cr_None = 1
  #tvc_cr_Arrow = 2
  #tvc_cr_cross = 3
  #tvc_cr_IBeam = 4
  #tvc_cr_Size = 5
  #tvc_cr_SizeNESW = 6
  #tvc_cr_SizeNS = 7
  #tvc_cr_SizeNWSE = 8
  #tvc_cr_SizeWE = 9
  #tvc_cr_UpArrow = 10
  #tvc_cr_HourGlass = 11
  #tvc_cr_Drag = 12
  #tvc_cr_NoDrop = 13
  #tvc_cr_HSplit = 14
  #tvc_cr_VSplit = 15
  #tvc_cr_MultiDrag = 16
  #tvc_cr_SQLWait = 17
  #tvc_cr_No = 18
  #tvc_cr_AppStart = 19
  #tvc_cr_Help = 20
  #tvc_cr_HandPoint = 21
  #tvc_cr_SizeAll = 22
EndEnumeration

Enumeration ;- TDialog
  #tvc_dlg_VideoDevice = 0
  #tvc_dlg_VideoCompressor = 1
  #tvc_dlg_AudioCompressor = 2
  #tvc_dlg_StreamConfig = 3
  #tvc_dlg_VfwFormat = 4
  #tvc_dlg_VfwSource = 5
  #tvc_dlg_vfwDisplay = 6
  #tvc_dlg_VideoCrossbar = 7
  #tvc_dlg_AudioCrossbar = 8
  #tvc_dlg_TVTuner = 9
  #tvc_dlg_TVAudio = 10
  #tvc_dlg_AudioDevice = 11
  #tvc_dlg_NetShowConfig = 12
  #tvc_dlg_DScaler = 13
  #tvc_dlg_FFDShowVideo = 14
  #tvc_dlg_FFDShowAudio = 15
  #tvc_dlg_Multiplexer = 16
  #tvc_dlg_None = 17
EndEnumeration

Enumeration ;- TDiscoveryCallbackStatus
  #tvc_dcs_CameraFound = 0
  #tvc_dcs_MulticastCompleted = 1
  #tvc_dcs_IPRangeCompleted = 2
EndEnumeration
   
Enumeration ;- TDragAction
  #tvc_dsDragEnter = 0
  #tvc_dsDragLeave = 1
  #tvc_dsDragMove = 2
EndEnumeration

Enumeration ;- TDVCommand
  #tvc_dv_Play = 0
  #tvc_dv_Stop = 1
  #tvc_dv_Freeze = 2
  #tvc_dv_Thaw = 3
  #tvc_dv_Ff = 4
  #tvc_dv_Rew = 5
  #tvc_dv_Record = 6
  #tvc_dv_RecordFreeze = 7
  #tvc_dv_RecordStrobe = 8
  #tvc_dv_StepFwd = 9
  #tvc_dv_StepRev = 10
  #tvc_dv_ModeShuttle = 11
  #tvc_dv_PlayFastestFwd = 12
  #tvc_dv_PlaySlowestFwd = 13
  #tvc_dv_PlayFastestRev = 14
  #tvc_dv_PlaySlowestRev = 15
EndEnumeration

Enumeration ;- TDVDInfoType
  #tvc_dvd_NumberOfVolumes = 0
  #tvc_dvd_TotalDuration = 1
  #tvc_dvd_NumberOfTitles = 2
  #tvc_dvd_TitleDuration = 3
  #tvc_dvd_TitleFrameRate = 4
  #tvc_dvd_SourceResolutionX = 5
  #tvc_dvd_SourceResolutionY = 6
  #tvc_dvd_TitleFrameCount = 7
EndEnumeration

Enumeration ;- TDVSize
  #tvc_dv_Full = 0
  #tvc_dv_Half = 1
  #tvc_dv_Quarter = 2
  #tvc_dv_DC = 3
EndEnumeration

Enumeration ;- TDVVideoFormat
  #tvc_dvf_Default = 0
  #tvc_dvf_DVSD = 1
  #tvc_dvf_DVHD = 2
  #tvc_dvf_DVSL = 3
EndEnumeration

Enumeration ;- TDVVideoStandard
  #tvc_dvs_Default = 0
  #tvc_dvs_PAL = 1
  #tvc_dvs_NTSC = 2
EndEnumeration

Enumeration ;- TEncoder_int
  #tvc_Enc_IsActive_bool = 0
  #tvc_Enc_Bytes_Written_kb_readonly = 1
  #tvc_Enc_Audio_Enabled_bool = 2
  #tvc_Enc_Audio_Channels = 3
  #tvc_Enc_Audio_SamplesPerSec = 4
  #tvc_Enc_Audio_BitsPerSample = 5
  #tvc_Enc_Audio_BitRate_kb = 6
  #tvc_Enc_Audio_PCM_Format = 7
  #tvc_Enc_Video_Enabled_bool = 8
  #tvc_Enc_Video_Width = 9
  #tvc_Enc_Video_Height = 10
  #tvc_Enc_Video_BitCount = 11
  #tvc_Enc_Video_AvgTimePerFrame = 12
  #tvc_Enc_Video_BitRate_kb = 13
  #tvc_Enc_Video_rc_MinBitRate_kb = 14
  #tvc_Enc_Video_rc_MaxBitRate_kb = 15
  #tvc_Enc_Video_rc_BufferSize_kb = 16
  #tvc_Enc_Video_IDR_Interval = 17
  #tvc_Enc_Video_Max_BFrames = 18
  #tvc_Enc_Video_FrameRate_x100 = 19
  #tvc_Enc_IsRealTime_bool = 20
  #tvc_Enc_IsScreenRecording_bool = 21
  #tvc_Enc_Video_Thread_Count = 22
  #tvc_Enc_Video_GPU_Encoder = 23
  #tvc_Enc_Video_GPU_EncoderDevice = 24
  #tvc_Enc_Video_Quality_min = 25
  #tvc_Enc_Video_Quality_max = 26
EndEnumeration

Enumeration ;- TEncoder_str
  #tvc_Enc_OutputURL = 0
  #tvc_Enc_Video_Codec = 1
  #tvc_Enc_Audio_Codec = 2
  #tvc_Enc_Video_ExtraParams = 3
  #tvc_Enc_Audio_ExtraParams = 4
EndEnumeration

Enumeration ;- TFileSort
  #tvc_fs_TimeAsc = 0
  #tvc_fs_TimeDesc = 1
  #tvc_fs_NameAsc = 2
  #tvc_fs_NameDesc = 3
EndEnumeration

Enumeration ;- TFiltersSet
  #tvc_fs_Datastead = 0
EndEnumeration

Enumeration ;- TFormatType
  #tvc_ft_VideoInfo = 0
  #tvc_ft_VideoInfo2 = 1
  #tvc_ft_DvInfo = 2
  #tvc_ft_Mpeg1Video = 3
  #tvc_ft_Mpeg2Video = 4
  #tvc_ft_Mpeg1Stream = 5
  #tvc_ft_Mpeg2Stream = 6
  #tvc_ft_MpegStreamType = 7
  #tvc_ft_MpegCustom = 8
  #tvc_ft_WaveFormatEx = 9
  #tvc_ft_Mpeg1Audio = 10
  #tvc_ft_Mpeg2Audio = 11
  #tvc_ft_Mpeg3Audio = 12
  #tvc_ft_OGG = 13
  #tvc_ft_GSM = 14
  #tvc_ft_Unknown = 15
EndEnumeration

Enumeration ;- TFrameBitmapInfoType
  #tvc_fb_VideoWidth = 0
  #tvc_fb_VideoHeight = 1
  #tvc_fb_BitmapSize = 2
  #tvc_fb_BitmapStride = 3
  #tvc_fb_BitsPerPixel = 4
EndEnumeration

Enumeration ;- TFrameCaptureDest
  #tvc_fc_TBitmap = 0
  #tvc_fc_BmpFile = 1
  #tvc_fc_JpegFile = 2
  #tvc_fc_Clipboard = 3
  #tvc_fc_TiffFile = 4
  #tvc_fc_PngFile = 5
EndEnumeration

Enumeration ;- TFrameGrabber
  #tvc_fg_BothStreams = 0
  #tvc_fg_PreviewStream = 1
  #tvc_fg_CaptureStream = 2
  #tvc_fg_Disabled = 3
EndEnumeration

Enumeration ;- TFrameGrabberRGBFormat
  #tvc_fgf_Default = 0
  #tvc_fgf_RGB32 = 1
  #tvc_fgf_RGB24 = 2
  #tvc_fgf_RGB565 = 3
  #tvc_fgf_RGB555 = 4
  #tvc_fgf_RGB8 = 5
EndEnumeration

Enumeration ;- TFrameInfoId
  #tvc_fi_FrameNumber = 0
  #tvc_fi_DroppedFrameCount = 1
  #tvc_fi_SampleTime_Hour = 2
  #tvc_fi_SampleTime_Min = 3
  #tvc_fi_SampleTime_Sec = 4
  #tvc_fi_SampleTime_Hs = 5
  #tvc_fi_SampleTime_TotalMin = 6
  #tvc_fi_DVTimeCode_IsAvailable = 7
  #tvc_fi_DVTimeCode_Hour = 8
  #tvc_fi_DVTimeCode_Min = 9
  #tvc_fi_DVTimeCode_Sec = 10
  #tvc_fi_DVTimeCode_Ff = 11
  #tvc_fi_DVTimeCode_TrackNumber = 12
  #tvc_fi_DVDateTime_IsAvailable = 13
  #tvc_fi_DVDateTime_Year = 14
  #tvc_fi_DVDateTime_Month = 15
  #tvc_fi_DVDateTime_Day = 16
  #tvc_fi_DVDateTime_Hour = 17
  #tvc_fi_DVDateTime_Min = 18
  #tvc_fi_DVDateTime_Sec = 19
  #tvc_fi_NTPFrameTime = 20
  #tvc_fi_First_NTP_time_Recorded = 21
EndEnumeration

Enumeration ;- TFrameInfoStringId
  #tvc_fis_DVTimeCode = 0
  #tvc_fis_DVDateTime = 1
  #tvc_fis_TimeCode = 2
  #tvc_fis_FrameTime = 3
  #tvc_fis_FrameNumber = 4
  #tvc_fis_FullInfo = 5
  #tvc_fis_NTPFrameTime = 6
EndEnumeration

Enumeration ;- TGPUEncoder
  #tvc_Enc_GPU_None = 0
  #tvc_Enc_GPU_Auto = 1
  #tvc_Enc_GPU_Intel_QSV = 2
  #tvc_Enc_GPU_NVidia_NVENC = 3
  #tvc_Enc_GPU_AMD_AMF = 4
EndEnumeration

Enumeration ;- TGraphState
  #tvc_gs_Stopped = 0
  #tvc_gs_Paused = 1
  #tvc_gs_Running = 2
EndEnumeration

Enumeration ;- THeaderAttribute
  #tvc_ha_Title = 0
  #tvc_ha_Description = 1
  #tvc_ha_Author = 2
  #tvc_ha_Copyright = 3
  #tvc_ha_AlbumArtist = 4
  #tvc_ha_AlbumTitle = 5
  #tvc_ha_Composer = 6
  #tvc_ha_ContentDistributor = 7
  #tvc_ha_Director = 8
  #tvc_ha_EncodingTime = 9
  #tvc_ha_Genre = 10
  #tvc_ha_Language = 11
  #tvc_ha_ParentalRating = 12
  #tvc_ha_Producer = 13
  #tvc_ha_Provider = 14
  #tvc_ha_ToolName = 15
  #tvc_ha_ToolVersion = 16
  #tvc_ha_Writer = 17
  #tvc_ha_IARL = 18
  #tvc_ha_ICMS = 19
  #tvc_ha_ICMT = 20
  #tvc_ha_ICRD = 21
  #tvc_ha_ICRP = 22
  #tvc_ha_IDIM = 23
  #tvc_ha_IDPI = 24
  #tvc_ha_IENG = 25
  #tvc_ha_IGNR = 26
  #tvc_ha_IKEY = 27
  #tvc_ha_ILGT = 28
  #tvc_ha_IMED = 29
  #tvc_ha_IPLT = 30
  #tvc_ha_IPRD = 31
  #tvc_ha_ISFT = 32
  #tvc_ha_ISHP = 33
  #tvc_ha_ISRC = 34
  #tvc_ha_ISRF = 35
  #tvc_ha_ITCH = 36
EndEnumeration

Enumeration ;- THwAccel
  #tvc_hw_None = 0
  #tvc_hw_Cuda = 1
  #tvc_hw_QuickSync = 2
  #tvc_hw_Dxva2 = 3
  #tvc_hw_d3d11 = 4
EndEnumeration

Enumeration ;- TIPCameraSetting
  #tvc_ips_ConnectionTimeout = 0
  #tvc_ips_ReceiveTimeout = 1
EndEnumeration

Enumeration ;- TJPEGPerformance
  #tvc_jpBestQuality = 0
  #tvc_jpBestSpeed = 1
EndEnumeration

Enumeration ;- TLogoLayout
  #tvc_lg_Centered = 0
  #tvc_lg_Stretched = 1
  #tvc_lg_Repeated = 2
  #tvc_lg_TopLeft = 3
  #tvc_lg_TopRight = 4
  #tvc_lg_BottomLeft = 5
  #tvc_lg_BottomRight = 6
  #tvc_lg_Boxed = 7
EndEnumeration

Enumeration ;- TLogType
  #tvc_e_add_filter = 0
  #tvc_e_add_source_filter = 1
  #tvc_e_audio_compressor_not_suitable = 2
  #tvc_e_bind_moniker_to_filter = 3
  #tvc_e_compressor_possibly_not_suitable = 4
  #tvc_e_create_instance = 5
  #tvc_e_ddraw_caps_not_suitable = 6
  #tvc_e_device_in_use_in_another_graph = 7
  #tvc_e_disk_full = 8
  #tvc_e_failed = 9
  #tvc_e_failed_to_allocate_recording_file = 10
  #tvc_e_failed_to_bind_codec = 11
  #tvc_e_failed_to_connect_crossbar_pin = 12
  #tvc_e_failed_to_connect_to_server = 13
  #tvc_e_failed_to_create_directory = 14
  #tvc_e_failed_to_create_file = 15
  #tvc_e_failed_to_create_temp = 16
  #tvc_e_failed_to_bind_frame_grabber = 17
  #tvc_e_failed_to_load_ASF_profile = 18
  #tvc_e_failed_to_load_ASF_profile_custom_file = 19
  #tvc_e_failed_to_load_set_of_bitmaps = 20
  #tvc_e_failed_to_set_image_overlay = 21
  #tvc_e_failed_to_set_logo = 22
  #tvc_e_failed_to_play_backwards = 23
  #tvc_e_failed_to_render_file = 24
  #tvc_e_failed_to_renew_recording_file = 25
  #tvc_e_failed_to_set_player_speed_ratio_with_audio = 26
  #tvc_e_failed_to_setup_network_streaming = 27
  #tvc_e_failed_to_start_preview = 28
  #tvc_e_failed_to_start_recording = 29
  #tvc_e_file_in_use = 30
  #tvc_e_file_name_not_specified = 31
  #tvc_e_file_not_found = 32
  #tvc_e_get_audio_format = 33
  #tvc_e_get_interface = 34
  #tvc_e_get_video_format = 35
  #tvc_e_graph_error = 36
  #tvc_e_graph_cant_run = 37
  #tvc_e_graph_must_be_restarted = 38
  #tvc_e_hw_deinterlace_not_supported = 39
  #tvc_e_incompatible_options = 40
  #tvc_e_index_out_of_range = 41
  #tvc_e_invalid_directory = 42
  #tvc_e_library_not_found = 43
  #tvc_e_load_filter = 44
  #tvc_e_no_audio_In_device = 45
  #tvc_e_no_device_available = 46
  #tvc_e_no_dialog = 47
  #tvc_e_no_stream_control = 48
  #tvc_e_no_tv_tuner = 49
  #tvc_e_no_device_selected = 50
  #tvc_e_no_video_input_device = 51
  #tvc_e_not_allowed_during_network_streaming = 52
  #tvc_e_not_allowed_with_streaming_URL = 53
  #tvc_e_not_assigned = 54
  #tvc_e_not_multiplexed_master = 55
  #tvc_e_not_previewing = 56
  #tvc_e_not_recording = 57
  #tvc_e_not_reencoding = 58
  #tvc_e_not_streaming = 59
  #tvc_e_out_of_memory = 60
  #tvc_e_pause_resume_disabled = 61
  #tvc_e_pin_not_found = 62
  #tvc_e_interface_not_assigned = 63
  #tvc_e_query_config_avi_mux = 64
  #tvc_e_reencoding = 65
  #tvc_e_recording_cannot_pause = 66
  #tvc_e_render_audio_stream = 67
  #tvc_e_render_video_stream = 68
  #tvc_e_must_restart_master = 69
  #tvc_e_recording_on_motion_failed = 70
  #tvc_e_sendtodv_device_index_out_of_bound = 71
  #tvc_e_sendtodv_deviceindex_and_videodevice_have_same_value = 72
  #tvc_e_sendtodv_failed_to_bind_dv_device = 73
  #tvc_e_set_filter_graph = 74
  #tvc_e_set_interleaving_mode = 75
  #tvc_e_set_master_stream = 76
  #tvc_e_set_output_compatibility_index = 77
  #tvc_e_set_output_file_name = 78
  #tvc_e_set_format = 79
  #tvc_e_start_preview_first = 80
  #tvc_e_stop_player_first = 81
  #tvc_e_stop_preview_first = 82
  #tvc_e_stop_recording_first = 83
  #tvc_e_stop_reencoding_first = 84
  #tvc_e_storage_path_read_only = 85
  #tvc_e_streaming_type_not_specified = 86
  #tvc_e_third_party_filter_already_inserted = 87
  #tvc_e_third_party_filter_error = 88
  #tvc_e_trace_log = 89
  #tvc_e_tv_command_not_allowed_during_tv_tuning = 90
  #tvc_e_tuner_input_not_selected = 91
  #tvc_e_TVideoGrabber_Filter_obsolete = 92
  #tvc_e_value_out_of_range = 93
  #tvc_e_video_compressor_not_suitable = 94
  #tvc_e_window_transparency_failed = 95
  #tvc_e_invalid_size = 96
  #tvc_e_invalid_window_handle = 97
  #tvc_e_tuner_mode_not_supported = 98
  #tvc_e_publishing_point_connection_failed = 99
  #tvc_e_speaker_control_disabled = 100
  #tvc_i_audio_device_associated_to_video_device = 101
  #tvc_i_begin_discovering_device = 102
  #tvc_i_binding_device_or_compressor = 103
  #tvc_i_discovering_device = 104
  #tvc_i_end_discovering_device = 105
  #tvc_i_preallocated_file_size_large_enough = 106
  #tvc_i_preallocated_file_size_changed = 107
  #tvc_i_preallocated_file_not_suitable = 108
  #tvc_i_streaming_to_publishing_point = 109
  #tvc_i_third_party_filter_inserted = 110
  #tvc_i_using_ASF_Profile = 111
  #tvc_i_recording_videosubtype = 112
  #tvc_i_ismpegstream = 113
  #tvc_i_new_recording_filename = 114
  #tvc_i_using_property_group = 115
  #tvc_i_streaming_client_connected = 116
  #tvc_i_streaming_client_disconnected = 117
  #tvc_i_refreshing_preview = 118
  #tvc_i_recording_on_motion = 119
  #tvc_i_window_found = 120
  #tvc_i_limiting_preview = 121
  #tvc_i_codec_recommended = 122
  #tvc_i_tuner_mode = 123
  #tvc_i_DV_date_time_discontinuity = 124
  #tvc_w_cannot_connect_thirdparty_filter = 125
  #tvc_w_cannot_connect_thirdparty_renderer = 126
  #tvc_w_cannot_instantiate_thirdparty_filter = 127
  #tvc_w_cannot_route_crossbar = 128
  #tvc_w_cannot_use_color_key = 129
  #tvc_w_command_delayed = 130
  #tvc_w_does_not_apply_to_dv = 131
  #tvc_w_find_audio_device = 132
  #tvc_w_filter_does_not_save_properties = 133
  #tvc_w_frame_grabber_requires_CPU = 134
  #tvc_w_hold_recording = 135
  #tvc_w_information = 136
  #tvc_w_not_playing = 137
  #tvc_w_player_audio_should_be_disabled = 138
  #tvc_w_recording_cancelled_by_user = 139
  #tvc_w_can_pause_and_ASF_incompatible = 140
  #tvc_w_set_audio_format = 141
  #tvc_w_storage_path_on_network = 142
  #tvc_w_tv_tuner = 143
  #tvc_w_using_nearest_video_size = 144
  #tvc_w_divx_codec_not_installed = 145
  #tvc_w_codec_does_not_support_debugger = 146
  #tvc_w_divx_codec_profile = 147
  #tvc_w_device_partially_supported = 148
  #tvc_w_excessive_grid_size = 149
  #tvc_w_grid_too_large_for_dialog = 150
  #tvc_w_operation_may_lock = 151
  #tvc_w_audio_streaming_needs_audiorecording_property_enabled = 152
  #tvc_w_network_streaming_disabled = 153
  #tvc_w_server_lost_next_retry = 154
  #tvc_w_overlay_mixer_not_available = 155
  #tvc_w_network_streaming_change_requires_application_to_be_restarted = 156
  #tvc_w_standard_renderer_recommended = 157
  #tvc_w_window_transparency_and_recording_not_recommended = 158
  #tvc_w_clip_not_seekable = 159
  #tvc_w_only_WMV_recording_during_network_streaming = 160
  #tvc_w_check_analog_video_standard = 161
  #tvc_w_recording_timer_set = 162
  #tvc_w_stream_time_beyong_script_time = 163
  #tvc_w_generate_new_file = 164
  #tvc_w_hires_timer_not_available = 165
  #tvc_w_applies_to_the_current_recording_method = 166
  #tvc_i_leaving_full_screen_mode = 167
  #tvc_i_stream_info = 168
  #tvc_i_async_url_connection_in_progress = 169
  #tvc_i_async_url_connection_cancelled = 170
  #tvc_e_obsolete = 171
  #tvc_i_codec_info = 172
  #tvc_i_preview_started = 173
  #tvc_i_recording_started = 174
  #tvc_i_reencoding_started = 175
  #tvc_i_recording_completed = 176
  #tvc_i_reencoding_completed = 177
  #tvc_i_player_opened = 178
  #tvc_i_inactive = 179
  #tvc_i_using_stream_index = 180
  #tvc_e_failed_to_start_reencoding = 181
  #tvc_e_recording_failed = 182
  #tvc_e_failed_to_open_player = 183
  #tvc_i_mpe_terminatedsuccess = 184
  #tvc_e_mpe_terminatederror = 185
  #tvc_i_mpe_logcallback = 186
  #tvc_i_duration_updated = 187
  #tvc_e_ptz_command_failed = 188
  #tvc_i_ptz_command_result = 189
  #tvc_w_potential_out_of_range = 190
  #tvc_i_recording_paused = 191
  #tvc_i_configuration_info = 192
  #tvc_w_virtualmachine = 193
  #tvc_i_recording_resumed = 194
  #tvc_e_failed_to_write_sample = 195
  #tvc_e_exception = 196
  #tvc_failed_to_open_url = 197
  #tvc_e_async_url_opening_in_progress = 198
EndEnumeration

Enumeration ;- TMiscDeviceControl
  #tvc_mdc_GPIO = 0
  #tvc_mdc_VPD = 1
  #tvc_mdc_VPD_Data = 2
EndEnumeration

Enumeration ;- TMouseButton
  #tvc_mbLeft = 0
  #tvc_mbRight = 1
  #tvc_mbMiddle = 2
EndEnumeration

Enumeration ;- TMPEGProgramSetting
  #tvc_mps_Program_Number = 0
  #tvc_mps_Program_PCR_PID = 1
  #tvc_mps_VideoStream_PID = 2
  #tvc_mps_AudioStream_PID = 3
  #tvc_mps_VideoStream_Type = 4
  #tvc_mps_AudioStream_Type = 5
  #tvc_mps_VideoFormat_Width = 6
  #tvc_mps_VideoFormat_Height = 7
  #tvc_mps_VideoAspectRatio_X = 8
  #tvc_mps_VideoAspectRatio_Y = 9
  #tvc_mps_ReceiveTimeoutInSeconds = 10
EndEnumeration

Enumeration ;- TMpegStreamType
  #tvc_mpst_Default = 0
  #tvc_mpst_Program = 1
  #tvc_mpst_Program_DVD = 2
  #tvc_mpst_Program_DVD_MC = 3
  #tvc_mpst_Program_SVCD = 4
  #tvc_mpst_MPEG1 = 5
  #tvc_mpst_MPEG1_VCD = 6
EndEnumeration

Enumeration ;- TMultiplexedRole
  #tvc_mr_NotMultiplexed = 0
  #tvc_mr_MultiplexedMosaic4 = 1
  #tvc_mr_MultiplexedMosaic16 = 2
  #tvc_mr_MultiplexedMaster = 3
  #tvc_mr_MultiplexedSlave = 4
EndEnumeration

Enumeration ;- TMultipurposeEncoderInstance
  #tvc_mpe_Recording = 0
  #tvc_mpe_Streaming = 1
  #tvc_mpe_Reencoding = 2
  #tvc_mpe_Edit = 3
EndEnumeration

Enumeration ;- TNDIBandwidthType
  #tvc_nbt_MetadataOnly = 0
  #tvc_nbt_AudioOnly = 1
  #tvc_nbt_LowestBandwidth = 2
  #tvc_nbt_HighestBandwidth = 3
EndEnumeration

Enumeration ;- TNetworkStreaming
  #tvc_ns_Disabled = 0
  #tvc_ns_ASFDirectNetworkStreaming = 1
  #tvc_ns_ASFStreamingToPublishingPoint = 2
  #tvc_ns_NDI = 3
EndEnumeration

Enumeration ;- TNetworkStreamingType
  #tvc_nst_AudioVideoStreaming = 0
  #tvc_nst_VideoStreaming = 1
  #tvc_nst_AudioStreaming = 2
EndEnumeration

Enumeration ;- TNotificationMethod
  #tvc_nm_Timer = 0
  #tvc_nm_Thread = 1
EndEnumeration

Enumeration ;- TONVIFDeviceInfo
  #tvc_onv_Manufacturer = 0
  #tvc_onv_Model = 1
  #tvc_onv_HardwareId = 2
  #tvc_onv_SerialNumber = 3
  #tvc_onv_FirmwareVersion = 4
  #tvc_onv_PTZInfo = 5
  #tvc_onv_PTZPresets = 6
  #tvc_onv_MacAddress = 7
  #tvc_onv_AuxiliaryCommands = 8
  #tvc_onv_XMLReplay = 9
  #tvc_onv_XMLInfo = 10
  #tvc_onv_XMLProfiles = 11
  #tvc_onv_CurrentProfileName = 12
  #tvc_onv_CurrentProfileToken = 13
EndEnumeration

Enumeration ;- TOpenURLAsyncStatus
  #tvc_oas_InProgress_Connecting = 0
  #tvc_oas_InProgress_Connected = 1
  #tvc_oas_Completed_Success = 2
  #tvc_oas_Undefined = 3
  #tvc_oas_Completed_Error = 4
EndEnumeration
   
Enumeration ;- TPlayerState
  #tvc_ps_Closed = 0
  #tvc_ps_Stopped = 1
  #tvc_ps_Paused = 2
  #tvc_ps_Playing = 3
  #tvc_ps_PlayingBackward = 4
  #tvc_ps_FastForwarding = 5
  #tvc_ps_FastRewinding = 6
  #tvc_ps_Downloading = 7
  #tvc_ps_DownloadCompleted = 8
  #tvc_ps_DownloadCancelled = 9
  #tvc_ps_Opened = 10
EndEnumeration

Enumeration ;- TPlaylist
  #tvc_pl_Add = 0
  #tvc_pl_Remove = 1
  #tvc_pl_Clear = 2
  #tvc_pl_Loop = 3
  #tvc_pl_NoLoop = 4
  #tvc_pl_Play = 5
  #tvc_pl_Stop = 6
  #tvc_pl_Next = 7
  #tvc_pl_Previous = 8
  #tvc_pl_SortAlpha = 9
  #tvc_pl_SortRevAlpha = 10
  #tvc_pl_Random = 11
  #tvc_pl_Sequential = 12
  #tvc_pl_SpecifyPositions = 13
  #tvc_pl_Transition = 14
EndEnumeration

Enumeration ;- TPointGreyConfig
  #tvc_pgr_SetRegister = 0
  #tvc_pgr_GetRegister = 1
  #tvc_pgr_SetBufferSize = 2
  #tvc_pgr_GetBufferSize = 3
  #tvc_pgr_SetFormat = 4
  #tvc_pgr_GetFormat = 5
EndEnumeration

Enumeration ;- TRawSampleCaptureLocation
  #tvc_rl_SourceFormat = 0
  #tvc_rl_AfterCompression = 1
EndEnumeration

Enumeration ;- TRecordingMethod
  #tvc_rm_AVI = 0
  #tvc_rm_ASF = 1
  #tvc_rm_SendToDV = 2
  #tvc_rm_MKV = 3
  #tvc_rm_FLV = 4
  #tvc_rm_MP4 = 5
  #tvc_rm_WebM = 6
  #tvc_rm_MPG = 7
  #tvc_rm_Multiplexer = 8
  #tvc_rm_MOV = 9
  #tvc_rm_TS = 10
  #tvc_rm_H264 = 11
  #tvc_rm_MP3 = 12
  #tvc_rm_WMA = 13
  #tvc_rm_WAV = 14
EndEnumeration

Enumeration ;- TRecordingSize
  #tvc_rs_Default = 0
  #tvc_rs_HalfSize = 1
  #tvc_rs_QuarterSize = 2
EndEnumeration

Enumeration ;- TRecordingTimer
  #tvc_rt_Disabled = 0
  #tvc_rt_RecordToNewFile = 1
  #tvc_rt_StopRecording = 2
  #tvc_rt_StartRecording = 3
  #tvc_rt_PauseRecording = 4
  #tvc_rt_FrameCapture = 5
EndEnumeration

Enumeration ;- TRGBSelector
  #tvc_rs_Red = 0
  #tvc_rs_Green = 1
  #tvc_rs_Blue = 2
EndEnumeration

Enumeration ;- TStoragePathMode
  #tvc_spm_AutoFileNameOnly = 0
  #tvc_spm_AnyFile = 1
EndEnumeration

Enumeration ;- TStreamType
  #tvc_st_Video = 0
  #tvc_st_Audio = 1
EndEnumeration

Enumeration ;- TSynchronizationRole
  #tvc_sr_Master = 0
  #tvc_sr_Slave = 1
  #tvc_sr_Mixer = 2
EndEnumeration

Enumeration ;- TSyncPreview
  #tvc_sp_Auto = 0
  #tvc_sp_Disabled = 1
  #tvc_sp_Enabled = 2
EndEnumeration

Enumeration ;- TTextOrientation
  #tvc_to_Horizontal = 0
  #tvc_to_Vertical = 1
  #tvc_to_VerticalInverted = 2
EndEnumeration

Enumeration ;- TTextOverlayAlign
  #tvc_tf_Left = 0
  #tvc_tf_Center = 1
  #tvc_tf_Right = 2
EndEnumeration

Enumeration ;- TTextOverlayGradientMode
  #tvc_gm_Disabled = 0
  #tvc_gm_Horizontal = 1
  #tvc_gm_Vertical = 2
  #tvc_gm_ForwardDiagonal = 3
  #tvc_gm_BackwardDiagonal = 4
EndEnumeration

Enumeration ;- TThirdPartyFilterList
  #tvc_tpf_VideoSource = 0
  #tvc_tpf_VideoPreview = 1
  #tvc_tpf_VideoRecording = 2
  #tvc_tpf_AudioSource = 3
  #tvc_tpf_AudioRendering = 4
  #tvc_tpf_AudioRecording = 5
  #tvc_tpf_VideoRendering = 6
  #tvc_tpf_VideoRenderer = 7
  #tvc_tpf_AudioRenderer = 8
  #tvc_tpf_ThirdPartyVideoSource = 9
  #tvc_tpf_ThirdPartyAudioSource = 10
  #tvc_tpf_AddToGraph = 11
EndEnumeration

Enumeration ;- TThreadPriority
  #tvc_tpIdle = 0
  #tvc_tpLowest = 1
  #tvc_tpLower = 2
  #tvc_tpNormal = 3
  #tvc_tpHigher = 4
  #tvc_tpHighest = 5
  #tvc_tpTimeCritical = 6
EndEnumeration

Enumeration ;- TThreadSyncPoint
  #tvc_tsp_SyncPoint1 = 0
  #tvc_tsp_SyncPoint2 = 1
  #tvc_tsp_SetParent = 2
  #tvc_tsp_UnSetParent = 3
EndEnumeration

Enumeration ;- TTrackbarAction
  #tvc_tba_MouseDown = 0
  #tvc_tba_MouseUp = 1
  #tvc_tba_KeyDown = 2
  #tvc_tba_KeyUp = 3
EndEnumeration

Enumeration ;- TTriState
  #tvc_ts_Undefined = 0
  #tvc_ts_False = 1
  #tvc_ts_True = 2
EndEnumeration

Enumeration ;- TTunerInputType
  #tvc_TunerInputCable = 0
  #tvc_TunerInputAntenna = 1
EndEnumeration

Enumeration ;- TTunerMode
  #tvc_tm_TVTuner = 0
  #tvc_tm_FMRadioTuner = 1
  #tvc_tm_AMRadioTuner = 2
  #tvc_tm_DigitalSatelliteTuner = 3
EndEnumeration

Enumeration ;- TTVChannelInfo
  #tvc_tci_Channel = 0
  #tvc_tci_DefaultVideoFrequency = 1
  #tvc_tci_OverriddenVideoFrequency = 2
  #tvc_tci_TunerVideoFrequency = 3
  #tvc_tci_TunerAudioFrequency = 4
  #tvc_tci_Locked = 5
EndEnumeration

Enumeration ;- Tv360_Angle
  #tvc_v360_fov_Diagonal = 0
  #tvc_v360_fov_Horizontal = 1
  #tvc_v360_fov_Vertical = 2
EndEnumeration

Enumeration ;- Tv360_InOut
  #tvc_v360_in = 0
  #tvc_v360_out = 1
EndEnumeration

Enumeration ;- Tv360_Interpolation
  #tvc_ipl_Bilinear = 0
  #tvc_ipl_Nearest = 1
  #tvc_ipl_Lagrange9 = 2
  #tvc_ipl_Bicubic = 3
  #tvc_ipl_Lanczos = 4
  #tvc_ipl_Spline16 = 5
  #tvc_ipl_Gaussian = 6
  #tvc_ipl_Mitchell = 7
EndEnumeration

Enumeration ;- TV360_MouseAction
  #tvc_ma_Disabled = 0
  #tvc_ma_MouseUp = 1
  #tvc_ma_MouseMove = 2
EndEnumeration

Enumeration ;- Tv360_Projection
  #tvc_ipp_Equirectangular = 0
  #tvc_ipp_Cubemap_3_2 = 1
  #tvc_ipp_Cubemap_6_1 = 2
  #tvc_ipp_Equiangular = 3
  #tvc_ipp_Flat = 4
  #tvc_ipp_Dual_fisheye = 5
  #tvc_ipp_Barrel = 6
  #tvc_ipp_Cubemap_1_6 = 7
  #tvc_ipp_Stereographic = 8
  #tvc_ipp_Mercator = 9
  #tvc_ipp_Ball = 10
  #tvc_ipp_Hammer = 11
  #tvc_ipp_Sinusoidal = 12
  #tvc_ipp_Fisheye = 13
  #tvc_ipp_Pannini = 14
  #tvc_ipp_Cylindrical = 15
  #tvc_ipp_Perspective = 16
  #tvc_ipp_Tetrahedron = 17
  #tvc_ipp_Barrel_split = 18
  #tvc_ipp_Tspyramid = 19
  #tvc_ipp_Hequirectangular = 20
  #tvc_ipp_Equisolid = 21
  #tvc_ipp_Orthographic = 22
  #tvc_ipp_Octahedron = 23
EndEnumeration

Enumeration ;- Tv360_StereoFormat
  #tvc_sf_2DMono = 0
  #tvc_sf_SideBySide = 1
  #tvc_sf_TopBottom = 2
EndEnumeration

Enumeration         ;- TVideoAlignment
  #tvc_oa_LeftTop = 0
  #tvc_oa_CenterTop = 1
  #tvc_oa_RightTop = 2
  #tvc_oa_LeftCenter = 3
  #tvc_oa_Center = 4
  #tvc_oa_RightCenter = 5
  #tvc_oa_LeftBottom = 6
  #tvc_oa_CenterBottom = 7
  #tvc_oa_RightBottom = 8
EndEnumeration

Enumeration ;- TVideoControl
  #tvc_vc_FlipHorizontal = 0
  #tvc_vc_FlipVertical = 1
  #tvc_vc_ExternalTriggerEnable = 2
  #tvc_vc_Trigger = 3
EndEnumeration

Enumeration ;- TVideoDeinterlacing
  #tvc_di_Disabled = 0
  #tvc_di_HalfSize = 1
  #tvc_di_FullSize = 2
  #tvc_di_DScaler = 3
  #tvc_di_AVISynth = 4
  #tvc_di_FFDShow = 5
  #tvc_di_ThirdPartyDeinterlacer = 6
EndEnumeration

Enumeration ;- TVideoQuality
  #tvc_vq_Brightness = 0
  #tvc_vq_Contrast = 1
  #tvc_vq_Hue = 2
  #tvc_vq_Saturation = 3
  #tvc_vq_Sharpness = 4
  #tvc_vq_Gamma = 5
  #tvc_vq_ColorEnable = 6
  #tvc_vq_WhiteBalance = 7
  #tvc_vq_BacklightCompensation = 8
  #tvc_vq_Gain = 9
EndEnumeration

Enumeration ;- TVideoRenderer
  #tvc_vr_AutoSelect = 0
  #tvc_vr_EVR = 1
  #tvc_vr_VMR9 = 2
  #tvc_vr_VMR7 = 3
  #tvc_vr_StandardRenderer = 4
  #tvc_vr_OverlayRenderer = 5
  #tvc_vr_RecordingPriority = 6
  #tvc_vr_None = 7
  #tvc_vr_madVR = 8
EndEnumeration

Enumeration ;- TVideoRendererExternal
  #tvc_vre_None = 0
  #tvc_vre_Matrox_PRO = 1
  #tvc_vre_Decklink_SD = 2
  #tvc_vre_Decklink_Extreme = 3
  #tvc_vre_Pinnacle_MovieBoard = 4
  #tvc_vre_BlackMagic_Decklink = 5
  #tvc_vre_AJA = 6
EndEnumeration

Enumeration ;- TVideoRendererPriority
  #tvc_vrp_Speed = 0
  #tvc_vrp_Quality = 1
  #tvc_vrp_Auto = 2
EndEnumeration
      
Enumeration ;- TVideoRotation
  #tvc_rt_0_deg = 0
  #tvc_rt_90_deg = 1
  #tvc_rt_180_deg = 2
  #tvc_rt_270_deg = 3
  #tvc_rt_0_deg_mirror = 4
  #tvc_rt_90_deg_mirror = 5
  #tvc_rt_180_deg_mirror = 6
  #tvc_rt_270_deg_mirror = 7
  #tvc_rt_custom_angle = 8
  #tvc_rt_custom_angle_mirror = 9
EndEnumeration

Enumeration ;- TVideoSource
  #tvc_vs_VideoCaptureDevice = 0
  #tvc_vs_ScreenRecording = 1
  #tvc_vs_VideoFileOrURL = 2
  #tvc_vs_JPEGsOrBitmaps = 3
  #tvc_vs_IPCamera = 4
  #tvc_vs_Mixer = 5
  #tvc_vs_VideoFromImages = 6
  #tvc_vs_ThirdPartyFilter = 7
EndEnumeration

Enumeration ;- TVideoWindowNotify
  #tvc_vwActive = 0
  #tvc_vwVisible = 1
  #tvc_vwAutoSize = 2
  #tvc_vwEmbedded = 3
  #tvc_vwEmbeddedFitParent = 4
  #tvc_vwDisplayParent = 5
  #tvc_vwColorKeyEnabled = 6
  #tvc_vwAlphaBlendEnabled = 7
  #tvc_vwFullScreen = 8
  #tvc_vwStayOnTop = 9
  #tvc_vwMouseMovesWindow = 10
  #tvc_vwVideoPortEnabled = 11
  #tvc_vwMonitor = 12
  #tvc_vwAspectRatio = 13
  #tvc_vwVideoWidth = 14
  #tvc_vwVideoHeight = 15
  #tvc_vwPanScanRatio = 16
  #tvc_vwColorKeyValue = 17
  #tvc_vwAlphaBlendValue = 18
  #tvc_vwLeft = 19
  #tvc_vwTop = 20
  #tvc_vwLocation = 21
EndEnumeration

Enumeration ;- TVMR9ImageAdjustment
  #tvc_vmr9_Brightness = 0
  #tvc_vmr9_Contrast = 1
  #tvc_vmr9_Hue = 2
  #tvc_vmr9_Saturation = 3
  #tvc_vmr9_Alpha = 4
EndEnumeration

Enumeration ;- TVuMeter
  #tvc_vu_Disabled = 0
  #tvc_vu_Analog = 1
  #tvc_vu_Bargraph = 2
  #tvc_vu_AnalogOverlay = 3
  #tvc_vu_BargraphOverlay = 4
EndEnumeration

Enumeration ;- TVUMeterSetting
  #tvc_vu_Handle = 0
  #tvc_vu_WarningPercent = 1
  #tvc_vu_PeakPercent = 2
  #tvc_vu_BkgndColor = 3
  #tvc_vu_NormalColor = 4
  #tvc_vu_WarningColor = 5
  #tvc_vu_PeakColor = 6
  #tvc_vu_TickSize = 7
  #tvc_vu_TickInterval = 8
  #tvc_vu_NeedleThickness = 9
  #tvc_vu_OverlayLeft = 10
  #tvc_vu_OverlayTop = 11
  #tvc_vu_OverlayWidth = 12
  #tvc_vu_OverlayHeight = 13
  #tvc_vu_Transparent = 14
  #tvc_vu_FlipVert = 15
  #tvc_vu_FlipHorz = 16
  #tvc_vu_CustomPercentValue = 17
  #tvc_vu_LogarithmicScale = 18
EndEnumeration

Enumeration ;- TWebcamStillCaptureButton
  #tvc_wb_Disabled = 0
  #tvc_wb_Enabled = 1
EndEnumeration

;- structures
Structure TFrameInfo
  frameTime.q
  frameTime_TotalMin.q
  frameTime_TotalSec.q
  frameTime_TotalHs.q
  framenumber.q
  droppedframecount.l
  frametime_hour.l
  frametime_min.l
  frametime_sec.l
  frametime_hs.l
  dvtimecode_isavailable.l
  dvtimecode_hour.l
  dvtimecode_min.l
  dvtimecode_sec.l
  dvtimecode_ff.l
  dvtimecode_tracknumber.l
  dvdatetime_isavailable.l
  dvdatetime_year.l
  dvdatetime_month.l
  dvdatetime_day.l
  dvdatetime_hour.l
  dvdatetime_min.l
  dvdatetime_sec.l
  CurrentState.l
  TGraphState.l
  PlayerState.l
  NTPFrameTime.q
EndStructure

Structure TFrameBitmapInfo
  bitmapWidth.l
  bitmapHeight.l
  bitmapBitsPerPixel.l
  bitmapLineSize.l
  bitmapSize.l
  bitmapPlanes.l
  bitmapHandle.l
  bitmapDataPtr.l
  bitmapDC.l
  CurrentXMouseLocation.l
  CurrentYMouseLocation.l
  LastXMouseDownLocation.l
  LastYMouseDownLocation.l
  IsMouseDown.a
  LastMouseButtonClicked.l
  Dummy1.l
  hSec.l
  reserved0.l
EndStructure

;- Prototypes
Prototype   pr_About (*TVGObject)
Prototype.i pr_AnalogVideoStandardIndex (*TVGObject, *Value)
Prototype.i pr_ASFStreaming_GetAuthorizationList (*TVGObject)
Prototype.i pr_ASFStreaming_GetConnectedClients (*TVGObject)
Prototype.i pr_ASFStreaming_GetConnectedClientsCount (*TVGObject)
Prototype.i pr_ASFStreaming_ResetAuthorizations (*TVGObject)
Prototype.i pr_ASFStreaming_SetAuthorization (*TVGObject, Allowed.l, *IP, *Mask)
Prototype.i pr_AssociateMultiplexedSlave (*TVGObject, InputNumber.l, SlaveUniqueID.l)
Prototype.i pr_AudioCompressorIndex (*TVGObject, *Value)
Prototype.i pr_AudioDeviceIndex (*TVGObject, *Value)
Prototype.i pr_AudioInputIndex (*TVGObject, *Value)
Prototype.i pr_AudioRendererIndex (*TVGObject, *Value)
Prototype.i pr_AVIDuration (*TVGObject, *AVIFile, *Duration, *FrameCount)
Prototype.i pr_AVIHeaderInfo (*TVGObject, *AVIFile, HeaderAttribute.l)
; Prototype.i pr_AVIInfo (*TVGObject, *AVIFile, *Duration, *FrameCount, *_VideoWidth, *_VideoHeight, *VideoFrameRateFps, *AvgBitRate, *AudioChannels, *AudioSamplesPerSec, *AudioBitsPerSample, **VideoCodec, **AudioCodec)
Prototype.i pr_AVIInfo (*TVGObject, *AVIFile, *Duration, *FrameCount, *_VideoWidth, *_VideoHeight, *VideoFrameRateFps, *AvgBitRate, *AudioChannels, *AudioSamplesPerSec, *AudioBitsPerSample, *pVideoCodec, *pAudioCodec)
Prototype.i pr_AVIInfo2 (*TVGObject, *AVIFile, AVIInfoType.l)
Prototype.i pr_CameraControlAuto (*TVGObject, Setting.l)
Prototype.i pr_CameraControlDefault (*TVGObject, Setting.l)
Prototype.i pr_CameraControlMax (*TVGObject, Setting.l)
Prototype.i pr_CameraControlMin (*TVGObject, Setting.l)
Prototype.i pr_CameraControlStep (*TVGObject, Setting.l)
Prototype.i pr_CameraControlValue (*TVGObject, Setting.l)
Prototype.i pr_Cancel (*TVGObject)
Prototype.i pr_CanProcessMessages (*TVGObject)
Prototype.i pr_CaptureFrameSyncTo (*TVGObject, Dest.l, *FileName)
Prototype.i pr_CaptureFrameTo (*TVGObject, Dest.l, *FileName)
Prototype   pr_ClearHeaderAttributes (*TVGObject)
Prototype   pr_ClosePlayer (*TVGObject)
Prototype   pr_ContinueProcessing (*TVGObject)
Prototype.i pr_CreatePreallocCapFile (*TVGObject)
Prototype.i pr_CreateVideoGrabber (*TVGObject)
Prototype   pr_DestroyVideoGrabber (*TVGObject)
Prototype   pr_Display_SetLocation (*TVGObject, WindowLeft.l, WindowTop.l, WindowWidth.l, WindowHeight.l)
Prototype.i pr_DrawBitmapOverFrame (*TVGObject, BitmapHandle.l, Stretched.l, LeftLocation.l, TopLocation.l, bmWidth.l, bmHeight.l, Transparent_Enabled.l, UseTransparentColor.l, Transparent_ColorValue.l, AlphaBlend_Enabled.l, AlphaBlend_Value.l, ChromaKey.l, ChromaKeyRGBColor.l, ChromaKeyLeewayPercent.l)
Prototype   pr_DualDisplay_SetLocation (*TVGObject, WindowLeft.l, WindowTop.l, WindowWidth.l, WindowHeight.l)
Prototype.d pr_DVDInfo (*TVGObject, *DVDRootDirectory, DVDInfoType.l, TitleNumber.l)
Prototype.i pr_EnableMultiplexedInput (*TVGObject, InputNumber.l, Enable.l)
Prototype.i pr_EnableMultipurposeEncoder (*TVGObject, MultipurposeEncoderType.l, Enable.l)
Prototype.i pr_EnableThreadMode (*TVGObject)
Prototype.i pr_EnumerateWindows (*TVGObject)
Prototype   pr_FastForwardPlayer (*TVGObject)
Prototype.i pr_FindIndexInListByName (*TVGObject, *List, *SearchedString, IsSubString.l, IgnoreCase.l)
Prototype.i pr_GetAdjustOverlayAspectRatio (*TVGObject)
Prototype.i pr_GetAdjustPixelAspectRatio (*TVGObject)
Prototype.i pr_GetAero (*TVGObject)
Prototype.i pr_GetAnalogVideoStandard (*TVGObject)
Prototype.i pr_GetAnalogVideoStandards (*TVGObject)
Prototype.i pr_GetAnalogVideoStandardsCount (*TVGObject)
Prototype.i pr_GetApplicationPriority (*TVGObject)
Prototype.i pr_GetASFAudioBitRate (*TVGObject)
Prototype.i pr_GetASFAudioChannels (*TVGObject)
Prototype.i pr_GetASFBufferWindow (*TVGObject)
Prototype.i pr_GetASFDeinterlaceMode (*TVGObject)
Prototype.i pr_GetASFFixedFrameRate (*TVGObject)
Prototype.i pr_GetASFDirectStreamingKeepClientsConnected (*TVGObject)
Prototype.i pr_GetASFMediaServerPublishingPoint (*TVGObject)
Prototype.i pr_GetASFMediaServerRemovePublishingPointAfterDisconnect (*TVGObject)
Prototype.i pr_GetASFMediaServerTemplatePublishingPoint (*TVGObject)
Prototype.i pr_GetASFNetworkMaxUsers (*TVGObject)
Prototype.i pr_GetASFNetworkPort (*TVGObject)
Prototype.i pr_GetASFProfile (*TVGObject)
Prototype.i pr_GetASFProfileFromCustomFile (*TVGObject)
Prototype.i pr_GetASFProfiles (*TVGObject)
Prototype.i pr_GetASFProfilesCount (*TVGObject)
Prototype.i pr_GetASFProfileVersion (*TVGObject)
Prototype.i pr_GetASFVideoBitRate (*TVGObject)
Prototype.d pr_GetASFVideoFrameRate (*TVGObject)
Prototype.i pr_GetASFVideoHeight (*TVGObject)
Prototype.i pr_GetASFVideoMaxKeyFrameSpacing (*TVGObject)
Prototype.i pr_GetASFVideoQuality (*TVGObject)
Prototype.i pr_GetASFVideoWidth (*TVGObject)
Prototype.d pr_GetAspectRatioToUse (*TVGObject)
Prototype.i pr_GetAssociateAudioAndVideoDevices (*TVGObject)
Prototype.i pr_GetAudioBalance (*TVGObject)
Prototype.i pr_GetAudioChannelRenderMode (*TVGObject)
Prototype.i pr_GetAudioCodec (*TVGObject)
Prototype.i pr_GetAudioCompressor (*TVGObject)
Prototype.i pr_GetAudioCompressorName (*TVGObject)
Prototype.i pr_GetAudioCompressors (*TVGObject)
Prototype.i pr_GetAudioCompressorsCount (*TVGObject)
Prototype.i pr_GetAudioDevice (*TVGObject)
Prototype.i pr_GetAudioDeviceName (*TVGObject)
Prototype.i pr_GetAudioDeviceRendering (*TVGObject)
Prototype.i pr_GetAudioDevices (*TVGObject)
Prototype.i pr_GetAudioDevicesCount (*TVGObject)
Prototype.i pr_GetAudioFormat (*TVGObject)
Prototype.i pr_GetAudioFormats (*TVGObject)
Prototype.i pr_GetAudioInput (*TVGObject)
Prototype.i pr_GetAudioInputBalance (*TVGObject)
Prototype.i pr_GetAudioInputLevel (*TVGObject)
Prototype.i pr_GetAudioInputMono (*TVGObject)
Prototype.i pr_GetAudioInputs (*TVGObject)
Prototype.i pr_GetAudioInputsCount (*TVGObject)
Prototype.i pr_GetAudioPeakEvent (*TVGObject)
Prototype.i pr_GetAudioRecording (*TVGObject)
Prototype.i pr_GetAudioRenderer (*TVGObject)
Prototype.i pr_GetAudioRendererName (*TVGObject)
Prototype.i pr_GetAudioRenderers (*TVGObject)
Prototype.i pr_GetAudioRenderersCount (*TVGObject)
Prototype.i pr_GetAudioSource (*TVGObject)
Prototype.i pr_GetAudioStreamNumber (*TVGObject)
Prototype.i pr_GetAudioSyncAdjustment (*TVGObject)
Prototype.i pr_GetAudioSyncAdjustmentEnabled (*TVGObject)
Prototype.i pr_GetAudioVolume (*TVGObject)
Prototype.i pr_GetAudioVolumeEnabled (*TVGObject)
Prototype.i pr_GetAutoConnectRelatedPins (*TVGObject)
Prototype.i pr_GetAutoFileName (*TVGObject)
Prototype.i pr_GetAutoFileNameDateTimeFormat (*TVGObject)
Prototype.i pr_GetAutoFileNameMinDigits (*TVGObject)
Prototype.i pr_GetAutoFilePrefix (*TVGObject)
Prototype.i pr_GetAutoFileSuffix (*TVGObject)
Prototype.i pr_GetAutoRefreshPreview (*TVGObject)
Prototype.i pr_GetAutoStartPlayer (*TVGObject)
Prototype.i pr_GetAVIDurationUpdated (*TVGObject)
Prototype.i pr_GetAVIFormatOpenDML (*TVGObject)
Prototype.i pr_GetAVIFormatOpenDMLCompatibilityIndex (*TVGObject)
Prototype.i pr_GetBackgroundColor (*TVGObject)
Prototype.i pr_GetBufferCount (*TVGObject)
Prototype.i pr_GetBurstCount (*TVGObject)
Prototype.i pr_GetBurstInterval (*TVGObject)
Prototype.i pr_GetBurstMode (*TVGObject)
Prototype.i pr_GetBurstType (*TVGObject)
Prototype.i pr_GetBusy (*TVGObject)
Prototype.i pr_GetBusyCursor (*TVGObject)
Prototype.i pr_GetCameraControlSettings (*TVGObject)
Prototype.d pr_GetCameraExposure (*TVGObject)
Prototype.i pr_GetCameraExposureAsString (*TVGObject)
Prototype.i pr_GetCaptureFileExt (*TVGObject)
Prototype.i pr_GetColorKey (*TVGObject)
Prototype.i pr_GetColorKeyEnabled (*TVGObject)
Prototype.i pr_GetCompressionMode (*TVGObject)
Prototype.i pr_GetCompressionType (*TVGObject)
Prototype.i pr_GetCropping_Enabled (*TVGObject)
Prototype.i pr_GetCropping_Height (*TVGObject)
Prototype.i pr_GetCropping_Outbounds (*TVGObject)
Prototype.i pr_GetCropping_Width (*TVGObject)
Prototype.i pr_GetCropping_X (*TVGObject)
Prototype.i pr_GetCropping_XMax (*TVGObject)
Prototype.i pr_GetCropping_Y (*TVGObject)
Prototype.i pr_GetCropping_YMax (*TVGObject)
Prototype.d pr_GetCropping_Zoom (*TVGObject)
Prototype.d pr_GetCurrentFrameRate (*TVGObject)
Prototype.i pr_GetCurrentState (*TVGObject)
Prototype.q pr_GetDeliveredFrames (*TVGObject)
Prototype.i pr_GetDirectShowFilters (*TVGObject)
Prototype.i pr_GetDirectShowFiltersCount (*TVGObject)
Prototype.i pr_GetDisplayActive (*TVGObject, DisplayIndex.l)
Prototype.i pr_GetDisplayAlphaBlendEnabled (*TVGObject, DisplayIndex.l)
Prototype.i pr_GetDisplayAlphaBlendValue (*TVGObject, DisplayIndex.l)
Prototype.i pr_GetDisplayAspectRatio (*TVGObject, DisplayIndex.l)
Prototype.i pr_GetDisplayAutoSize (*TVGObject, DisplayIndex.l)
Prototype.i pr_GetDisplayEmbedded (*TVGObject, DisplayIndex.l)
Prototype.i pr_GetDisplayEmbedded_FitParent (*TVGObject, DisplayIndex.l)
Prototype.i pr_GetDisplayFullScreen (*TVGObject, DisplayIndex.l)
Prototype.i pr_GetDisplayHeight (*TVGObject, DisplayIndex.l)
Prototype.i pr_GetDisplayLeft (*TVGObject, DisplayIndex.l)
Prototype.i pr_GetDisplayMonitor (*TVGObject, DisplayIndex.l)
Prototype.i pr_GetDisplayMouseMovesWindow (*TVGObject, DisplayIndex.l)
Prototype.i pr_GetDisplayPanScanRatio (*TVGObject, DisplayIndex.l)
Prototype.i pr_GetDisplayStayOnTop (*TVGObject, DisplayIndex.l)
Prototype.i pr_GetDisplayTop (*TVGObject, DisplayIndex.l)
Prototype.i pr_GetDisplayTransparentColorEnabled (*TVGObject, DisplayIndex.l)
Prototype.i pr_GetDisplayTransparentColorValue (*TVGObject, DisplayIndex.l)
Prototype.i pr_GetDisplayVideoHeight (*TVGObject, DisplayIndex.l)
Prototype.i pr_GetDisplayVideoPortEnabled (*TVGObject, DisplayIndex.l)
Prototype.i pr_GetDisplayVideoWidth (*TVGObject, DisplayIndex.l)
Prototype.i pr_GetDisplayVideoWindowHandle (*TVGObject, DisplayIndex.l)
Prototype.i pr_GetDisplayVisible (*TVGObject, DisplayIndex.l)
Prototype.i pr_GetDisplayWidth (*TVGObject, DisplayIndex.l)
Prototype.i pr_GetDroppedFrameCount (*TVGObject)
Prototype.i pr_GetDroppedFramesPollingInterval (*TVGObject)
Prototype.i pr_GetDVDateTimeEnabled (*TVGObject)
Prototype.i pr_GetDVDiscontinuityMinimumInterval (*TVGObject)
Prototype.i pr_GetDVDTitle (*TVGObject)
Prototype.i pr_GetDVEncoder_VideoFormat (*TVGObject)
Prototype.i pr_GetDVEncoder_VideoResolution (*TVGObject)
Prototype.i pr_GetDVEncoder_VideoStandard (*TVGObject)
Prototype.i pr_GetDVRecordingInNativeFormatSeparatesStreams (*TVGObject)
Prototype.i pr_GetDVReduceFrameRate (*TVGObject)
Prototype.i pr_GetDVRgb219 (*TVGObject)
Prototype.i pr_GetDVTimeCodeEnabled (*TVGObject)
Prototype.i pr_GetEventNotificationSynchrone (*TVGObject)
Prototype.i pr_GetExtraDLLPath (*TVGObject)
Prototype.i pr_GetFilterInterfaceByName (*TVGObject, *FilterName, *FilterIntf)
Prototype.i pr_GetFixFlickerOrBlackCapture (*TVGObject)
Prototype.i pr_GetFrameBitmapInfo (*TVGObject, FrameBitmapInfoType.l)
Prototype.i pr_GetFrameCaptureHeight (*TVGObject)
Prototype.i pr_GetFrameCaptureWidth (*TVGObject)
Prototype.i pr_GetFrameCaptureWithoutOverlay (*TVGObject)
Prototype.i pr_GetFrameCaptureZoomSize (*TVGObject)
Prototype.i pr_GetFrameGrabber (*TVGObject)
Prototype.i pr_GetFrameGrabberCurrentRGBFormat (*TVGObject)
Prototype.i pr_GetFrameGrabberRGBFormat (*TVGObject)
Prototype.q pr_GetFrameInfo (*TVGObject, FrameId.l, FrameInfoId.l)
Prototype.i pr_GetFrameInfoString (*TVGObject, FrameInfoStringId.l)
Prototype.i pr_GetFrameNumberStartsFromZero (*TVGObject)
Prototype.d pr_GetFrameRate (*TVGObject)
Prototype.i pr_GetFrameRateDivider (*TVGObject)
Prototype.i pr_GetFWCam1394 (*TVGObject, *FWCam1394ID, *Value, *Flags, *Capabilities, *MinValue, *MaxValue, *Default)
Prototype.i pr_GetFWCam1394List (*TVGObject)
Prototype.i pr_GetGetLastFrameWaitTimeoutMs (*TVGObject)
Prototype.i pr_GetGeneratePts (*TVGObject)
Prototype.i pr_GetHoldRecording (*TVGObject)
Prototype.i pr_GetImageOverlay_AlphaBlend (*TVGObject, Index.l)
Prototype.i pr_GetImageOverlay_AlphaBlendValue (*TVGObject, Index.l)
Prototype.i pr_GetImageOverlay_ChromaKey (*TVGObject, Index.l)
Prototype.i pr_GetImageOverlay_ChromaKeyLeewayPercent (*TVGObject, Index.l)
Prototype.i pr_GetImageOverlay_ChromaKeyRGBColor (*TVGObject, Index.l)
Prototype.i pr_GetImageOverlay_Enabled (*TVGObject, Index.l)
Prototype.i pr_GetImageOverlay_Height (*TVGObject, Index.l)
Prototype.i pr_GetImageOverlay_LeftLocation (*TVGObject, Index.l)
Prototype.d pr_GetImageOverlay_RotationAngle (*TVGObject, Index.l)
Prototype.i pr_GetImageOverlay_StretchToVideoSize (*TVGObject, Index.l)
Prototype.i pr_GetImageOverlay_TargetDisplay (*TVGObject, Index.l)
Prototype.i pr_GetImageOverlay_TopLocation (*TVGObject, Index.l)
Prototype.i pr_GetImageOverlay_Transparent (*TVGObject, Index.l)
Prototype.i pr_GetImageOverlay_TransparentColorValue (*TVGObject, Index.l)
Prototype.i pr_GetImageOverlay_UseTransparentColor (*TVGObject, Index.l)
Prototype.i pr_GetImageOverlay_VideoAlignment (*TVGObject, Index.l)
Prototype.i pr_GetImageOverlay_Width (*TVGObject, Index.l)
Prototype.i pr_GetImageOverlayAlphaBlend (*TVGObject)
Prototype.i pr_GetImageOverlayAlphaBlendValue (*TVGObject)
Prototype.i pr_GetImageOverlayChromaKey (*TVGObject)
Prototype.i pr_GetImageOverlayChromaKeyLeewayPercent (*TVGObject)
Prototype.i pr_GetImageOverlayChromaKeyRGBColor (*TVGObject)
Prototype.i pr_GetImageOverlayEnabled (*TVGObject)
Prototype.i pr_GetImageOverlayHeight (*TVGObject)
Prototype.i pr_GetImageOverlayLeftLocation (*TVGObject)
Prototype.d pr_GetImageOverlayRotationAngle (*TVGObject)
Prototype.i pr_GetImageOverlaySelector (*TVGObject)
Prototype.i pr_GetImageOverlayStretchToVideoSize (*TVGObject)
Prototype.i pr_GetImageOverlayTargetDisplay (*TVGObject)
Prototype.i pr_GetImageOverlayTopLocation (*TVGObject)
Prototype.i pr_GetImageOverlayTransparent (*TVGObject)
Prototype.i pr_GetImageOverlayTransparentColorValue (*TVGObject)
Prototype.i pr_GetImageOverlayUseTransparentColor (*TVGObject)
Prototype.i pr_GetImageOverlayVideoAlignment (*TVGObject)
Prototype.i pr_GetImageOverlayWidth (*TVGObject)
Prototype.d pr_GetImageRatio (*TVGObject)
Prototype.i pr_GetInFrameProgressEvent (*TVGObject)
Prototype.i pr_GetIPCameraURL (*TVGObject)
Prototype.i pr_GetIsAnalogVideoDecoderAvailable (*TVGObject)
Prototype.i pr_GetIsAudioCrossbarAvailable (*TVGObject)
Prototype.i pr_GetIsAudioInputBalanceAvailable (*TVGObject)
Prototype.i pr_GetIsCameraControlAvailable (*TVGObject)
Prototype.i pr_GetIsDigitalVideoIn (*TVGObject)
Prototype.i pr_GetIsDVCommandAvailable (*TVGObject)
Prototype.i pr_GetIsHorizontalSyncLocked (*TVGObject)
Prototype.i pr_GetIsMpegStream (*TVGObject)
Prototype.i pr_GetIsPlayerAudioStreamAvailable (*TVGObject)
Prototype.i pr_GetIsPlayerVideoStreamAvailable (*TVGObject)
Prototype.i pr_GetIsRecordingPaused (*TVGObject)
Prototype.i pr_GetIsTVAudioAvailable (*TVGObject)
Prototype.i pr_GetIsTVAutoTuneRunning (*TVGObject)
Prototype.i pr_GetIsTVTunerAvailable (*TVGObject)
Prototype.i pr_GetIsVideoControlAvailable (*TVGObject)
Prototype.i pr_GetIsVideoCrossbarAvailable (*TVGObject)
Prototype.i pr_GetIsVideoInterlaced (*TVGObject)
Prototype.i pr_GetIsVideoPortAvailable (*TVGObject)
Prototype.i pr_GetIsVideoQualityAvailable (*TVGObject)
Prototype.i pr_GetIsWDMVideoDriver (*TVGObject)
Prototype.i pr_GetItemNameFromList (*TVGObject, *List, ItemIndex.l)
Prototype.i pr_GetJPEGPerformance (*TVGObject)
Prototype.i pr_GetJPEGProgressiveDisplay (*TVGObject)
Prototype.i pr_GetJPEGQuality (*TVGObject)
Prototype.i pr_GetLast_BurstFrameCapture_FileName (*TVGObject)
Prototype.i pr_GetLast_CaptureFrameTo_FileName (*TVGObject)
Prototype.i pr_GetLast_Clip_Played (*TVGObject)
Prototype.i pr_GetLast_Recording_FileName (*TVGObject)
Prototype.i pr_GetLastAverageStreamValue (*TVGObject, StreamType.l)
Prototype.i pr_GetLastErrorMessage (*TVGObject)
Prototype.i pr_GetLastFrameAsHBITMAP (*TVGObject, BufferIndex.l, WithOverlays.l, SrcLeftLocation.l, SrcTopLocation.l, SrcWidth.l, SrcHeight.l, DestWidth.l, DestHeight.l, BitmapColorBitCount.l)
Prototype.i pr_GetLastFrameBitmapBits (*TVGObject, BufferIndex.l, WithOverlays.l, ReleaseFrame.l)
Prototype.i pr_GetLastFrameBitmapBits2 (*TVGObject, BufferIndex.l, WithOverlays.l, ReleaseFrame.l, *BitmapWidth, *BitmapHeight, *BitmapLineSize, *BitmapSize, *BitmapBitsPerPixel)
Prototype.i pr_GetLicenseString (*TVGObject)
Prototype.i pr_GetLogoDisplayed (*TVGObject)
Prototype.i pr_GetLogoLayout (*TVGObject)
Prototype.i pr_GetLogString (*TVGObject, Value.l)
Prototype.i pr_GetMiscDeviceControl (*TVGObject, MiscDeviceControl.l, Index.l)
Prototype.i pr_GetMixAudioSamplesLevel (*TVGObject, Index.l)
Prototype.i pr_GetMixer_MosaicColumns (*TVGObject)
Prototype.i pr_GetMixer_MosaicLines (*TVGObject)
Prototype.i pr_GetMotionDetector_CompareBlue (*TVGObject)
Prototype.i pr_GetMotionDetector_CompareGreen (*TVGObject)
Prototype.i pr_GetMotionDetector_CompareRed (*TVGObject)
Prototype.i pr_GetMotionDetector_Enabled (*TVGObject)
Prototype.d pr_GetMotionDetector_GlobalMotionRatio (*TVGObject)
Prototype.i pr_GetMotionDetector_GreyScale (*TVGObject)
Prototype.i pr_GetMotionDetector_Grid (*TVGObject)
Prototype.i pr_GetMotionDetector_GridXCount (*TVGObject)
Prototype.i pr_GetMotionDetector_GridYCount (*TVGObject)
Prototype.i pr_GetMotionDetector_IsGridValid (*TVGObject)
Prototype.d pr_GetMotionDetector_MaxDetectionsPerSecond (*TVGObject)
Prototype.i pr_GetMotionDetector_MotionResetMs (*TVGObject)
Prototype.i pr_GetMotionDetector_ReduceCPULoad (*TVGObject)
Prototype.i pr_GetMotionDetector_ReduceVideoNoise (*TVGObject)
Prototype.i pr_GetMotionDetector_Triggered (*TVGObject)
Prototype.i pr_GetMouseWheelEventEnabled (*TVGObject)
Prototype.i pr_GetMouseWheelControlsZoomAtCursor (*TVGObject)
Prototype.i pr_GetMpegStreamType (*TVGObject)
Prototype.i pr_GetMultiplexedInputEmulation (*TVGObject)
Prototype.i pr_GetMultiplexedRole (*TVGObject)
Prototype.i pr_GetMultiplexedStabilizationDelay (*TVGObject)
Prototype.i pr_GetMultiplexedSwitchDelay (*TVGObject)
Prototype.i pr_GetMultiplexer (*TVGObject)
Prototype.i pr_GetMultiplexerName (*TVGObject)
Prototype.i pr_GetMultiplexers (*TVGObject)
Prototype.i pr_GetMultiplexersCount (*TVGObject)
Prototype.i pr_GetMultipurposeEncoderSettings (*TVGObject, MultipurposeEncoderType.l)
Prototype.i pr_GetMuteAudioRendering (*TVGObject)
Prototype.i pr_GetName (*TVGObject)
Prototype.i pr_GetNDIBandwidthType (*TVGObject)
Prototype.i pr_GetNDIGroups (*TVGObject)
Prototype.i pr_GetNDIName (*TVGObject)
Prototype.i pr_GetNDIReceiveTimeoutMs (*TVGObject)
Prototype.i pr_GetNDISessions (*TVGObject, AsXML.w, ReportURLInfo.w)
Prototype.i pr_GetNearestVideoHeight (*TVGObject, PreferredVideoWidth.l, PreferredVideoHeight.l)
Prototype   pr_GetNearestVideoSize (*TVGObject, PreferredVideoWidth.l, PreferredVideoHeight.l, *NearestVideoWidth, *NearestVideoHeight)
Prototype.i pr_GetNearestVideoWidth (*TVGObject, PreferredVideoWidth.l, PreferredVideoHeight.l)
Prototype.i pr_GetONVIFURLFromServiceURL (*TVGObject, *ServiceURL)
Prototype.i pr_GetNetworkStreaming (*TVGObject)
Prototype.i pr_GetNetworkStreamingType (*TVGObject)
Prototype.i pr_GetNormalCursor (*TVGObject)
Prototype.i pr_GetNotificationMethod (*TVGObject)
Prototype.i pr_GetNotificationPriority (*TVGObject)
Prototype.i pr_GetNotificationSleepTime (*TVGObject)
Prototype.i pr_GetOnFrameBitmapEventSynchrone (*TVGObject)
Prototype.i pr_GetOpenURLAsync (*TVGObject)
Prototype.i pr_GetOverlayAfterTransform (*TVGObject)
Prototype.d pr_GetPixelsDistance (*TVGObject, x1.l, y1.l, x2.l, y2.l)
Prototype.i pr_GetPlayerAudioRendering (*TVGObject)
Prototype.q pr_GetPlayerDuration (*TVGObject)
Prototype.i pr_GetPlayerDVSize (*TVGObject)
Prototype.i pr_GetPlayerFastSeekSpeedRatio (*TVGObject)
Prototype.i pr_GetPlayerFileName (*TVGObject)
Prototype.i pr_GetPlayerForcedCodec (*TVGObject)
Prototype.q pr_GetPlayerFrameCount (*TVGObject)
Prototype.q pr_GetPlayerFramePosition (*TVGObject)
Prototype.d pr_GetPlayerFrameRate (*TVGObject)
Prototype.i pr_GetPlayerHwAccel (*TVGObject)
Prototype.i pr_GetPlayerOpenProgressPercent (*TVGObject)
Prototype.i pr_GetPlayerRefreshPausedDisplay (*TVGObject)
Prototype.d pr_GetPlayerRefreshPausedDisplayFrameRate (*TVGObject)
Prototype.d pr_GetPlayerSpeedRatio (*TVGObject)
Prototype.i pr_GetPlayerSpeedRatioConstantAudioPitch (*TVGObject)
Prototype.i pr_GetPlayerState (*TVGObject)
Prototype.q pr_GetPlayerTimePosition (*TVGObject)
Prototype.i pr_GetPlayerTrackBarSynchrone (*TVGObject)
Prototype.i pr_GetPlaylist (*TVGObject)
Prototype.i pr_GetPlaylistIndex (*TVGObject)
Prototype.i pr_GetPreallocCapFileCopiedAfterRecording (*TVGObject)
Prototype.i pr_GetPreallocCapFileEnabled (*TVGObject)
Prototype.i pr_GetPreallocCapFileName (*TVGObject)
Prototype.i pr_GetPreallocCapFileSizeInMB (*TVGObject)
Prototype.i pr_GetPreviewZoomSize (*TVGObject)
Prototype.i pr_GetQuickDeviceInitialization (*TVGObject)
Prototype.i pr_GetRawAudioSampleCapture (*TVGObject)
Prototype.i pr_GetRawCaptureAsyncEvent (*TVGObject)
Prototype.i pr_GetRawSampleCaptureLocation (*TVGObject)
Prototype.i pr_GetRawVideoSampleCapture (*TVGObject)
Prototype.i pr_GetRecordingAudioBitRate (*TVGObject)
Prototype.i pr_GetRecordingBacktimedFramesCount (*TVGObject)
Prototype.i pr_GetRecordingCanPause (*TVGObject)
Prototype.d pr_GetRecordingDuration (*TVGObject)
Prototype.i pr_GetRecordingFileName (*TVGObject)
Prototype.i pr_GetRecordingFileSizeMaxInMB (*TVGObject)
Prototype.i pr_GetRecordingFourCC (*TVGObject)
Prototype.i pr_GetRecordingHeight (*TVGObject)
Prototype.i pr_GetRecordingInNativeFormat (*TVGObject)
Prototype.i pr_GetRecordingMethod (*TVGObject)
Prototype.i pr_GetRecordingOnMotion_Enabled (*TVGObject)
Prototype.d pr_GetRecordingOnMotion_MotionThreshold (*TVGObject)
Prototype.i pr_GetRecordingOnMotion_NoMotionPauseDelayMs (*TVGObject)
Prototype.i pr_GetRecordingPauseCreatesNewFile (*TVGObject)
Prototype.i pr_GetRecordingSize (*TVGObject)
Prototype.i pr_GetRecordingTimer (*TVGObject)
Prototype.i pr_GetRecordingTimerInterval (*TVGObject)
Prototype.i pr_GetRecordingVideoBitRate (*TVGObject)
Prototype.i pr_GetRecordingWidth (*TVGObject)
Prototype.i pr_GetReencodingIncludeAudioStream (*TVGObject)
Prototype.i pr_GetReencodingIncludeVideoStream (*TVGObject)
Prototype.i pr_GetReencodingMethod (*TVGObject)
Prototype.i pr_GetReencodingNewVideoClip (*TVGObject)
Prototype.i pr_GetReencodingSourceVideoClip (*TVGObject)
Prototype.q pr_GetReencodingStartFrame (*TVGObject)
Prototype.q pr_GetReencodingStartTime (*TVGObject)
Prototype.q pr_GetReencodingStopFrame (*TVGObject)
Prototype.q pr_GetReencodingStopTime (*TVGObject)
Prototype.i pr_GetReencodingUseAudioCompressor (*TVGObject)
Prototype.i pr_GetReencodingUseFrameGrabber (*TVGObject)
Prototype.i pr_GetReencodingUseVideoCompressor (*TVGObject)
Prototype.i pr_GetReencodingWMVOutput (*TVGObject)
Prototype.i pr_GetRGBPixelAt (*TVGObject, x.l, y.l)
Prototype.i pr_GetScreenRecordingLayeredWindows (*TVGObject)
Prototype.i pr_GetScreenRecordingMonitor (*TVGObject)
Prototype.i pr_GetScreenRecordingNonVisibleWindows (*TVGObject)
Prototype.i pr_GetScreenRecordingSizePercent (*TVGObject)
Prototype.i pr_GetScreenRecordingThroughClipboard (*TVGObject)
Prototype.i pr_GetScreenRecordingWithCursor (*TVGObject)
Prototype.i pr_GetSendToDV_DeviceIndex (*TVGObject)
Prototype.i pr_GetSpeakerBalance (*TVGObject)
Prototype.i pr_GetSpeakerControl (*TVGObject)
Prototype.i pr_GetSpeakerVolume (*TVGObject)
Prototype.i pr_GetStoragePath (*TVGObject)
Prototype.i pr_GetStoragePathMode (*TVGObject)
Prototype.i pr_GetStoreDeviceSettingsInRegistry (*TVGObject)
Prototype.i pr_GetStreamingURL (*TVGObject)
Prototype.i pr_GetSyncCommands (*TVGObject)
Prototype.i pr_GetSynchronizationRole (*TVGObject)
Prototype.i pr_GetSynchronized (*TVGObject)
Prototype.i pr_GetSyncPreview (*TVGObject)
Prototype.i pr_GetSystemTempPath (*TVGObject)
Prototype.i pr_GetTextOverlay_Align (*TVGObject, Index.l)
Prototype.i pr_GetTextOverlay_AlphaBlend (*TVGObject, Index.l)
Prototype.i pr_GetTextOverlay_AlphaBlendValue (*TVGObject, Index.l)
Prototype.i pr_GetTextOverlay_BkColor (*TVGObject, Index.l)
Prototype.i pr_GetTextOverlay_Enabled (*TVGObject, Index.l)
Prototype.i pr_GetTextOverlay_Font (*TVGObject, Index.l)
Prototype.i pr_GetTextOverlay_FontColor (*TVGObject, Index.l)
Prototype.i pr_GetTextOverlay_FontSize (*TVGObject, Index.l)
Prototype.i pr_GetTextOverlay_GradientColor (*TVGObject, Index.l)
Prototype.i pr_GetTextOverlay_GradientMode (*TVGObject, Index.l)
Prototype.i pr_GetTextOverlay_HighResFont (*TVGObject, Index.l)
Prototype.i pr_GetTextOverlay_Left (*TVGObject, Index.l)
Prototype.i pr_GetTextOverlay_Orientation (*TVGObject, Index.l)
Prototype.i pr_GetTextOverlay_Right (*TVGObject, Index.l)
Prototype.i pr_GetTextOverlay_Scrolling (*TVGObject, Index.l)
Prototype.i pr_GetTextOverlay_ScrollingSpeed (*TVGObject, Index.l)
Prototype.i pr_GetTextOverlay_Shadow (*TVGObject, Index.l)
Prototype.i pr_GetTextOverlay_ShadowColor (*TVGObject, Index.l)
Prototype.i pr_GetTextOverlay_ShadowDirection (*TVGObject, Index.l)
Prototype.i pr_GetTextOverlay_String (*TVGObject, Index.l)
Prototype.i pr_GetTextOverlay_TargetDisplay (*TVGObject, Index.l)
Prototype.i pr_GetTextOverlay_Top (*TVGObject, Index.l)
Prototype.i pr_GetTextOverlay_Transparent (*TVGObject, Index.l)
Prototype.i pr_GetTextOverlay_VideoAlignment (*TVGObject, Index.l)
Prototype.i pr_GetTextOverlayAlign (*TVGObject)
Prototype.i pr_GetTextOverlayAlphaBlend (*TVGObject)
Prototype.i pr_GetTextOverlayAlphaBlendValue (*TVGObject)
Prototype.i pr_GetTextOverlayBkColor (*TVGObject)
Prototype.i pr_GetTextOverlayEnabled (*TVGObject)
Prototype.i pr_GetTextOverlayFont (*TVGObject)
Prototype.i pr_GetTextOverlayFontColor (*TVGObject)
Prototype.i pr_GetTextOverlayFontSize (*TVGObject)
Prototype.i pr_GetTextOverlayGradientColor (*TVGObject)
Prototype.i pr_GetTextOverlayGradientMode (*TVGObject)
Prototype.i pr_GetTextOverlayHighResFont (*TVGObject)
Prototype.i pr_GetTextOverlayLeft (*TVGObject)
Prototype.i pr_GetTextOverlayOrientation (*TVGObject)
Prototype.i pr_GetTextOverlayRight (*TVGObject)
Prototype.i pr_GetTextOverlayScrolling (*TVGObject)
Prototype.i pr_GetTextOverlayScrollingSpeed (*TVGObject)
Prototype.i pr_GetTextOverlaySelector (*TVGObject)
Prototype.i pr_GetTextOverlayShadow (*TVGObject)
Prototype.i pr_GetTextOverlayShadowColor (*TVGObject)
Prototype.i pr_GetTextOverlayShadowDirection (*TVGObject)
Prototype.i pr_GetTextOverlayString (*TVGObject)
Prototype.i pr_GetTextOverlayTargetDisplay (*TVGObject)
Prototype.i pr_GetTextOverlayTop (*TVGObject)
Prototype.i pr_GetTextOverlayTransparent (*TVGObject)
Prototype.i pr_GetTextOverlayVideoAlignment (*TVGObject)
Prototype.i pr_GetThirdPartyDeinterlacer (*TVGObject)
Prototype.i pr_GetTimeCodeReaderAvailable (*TVGObject)
Prototype.i pr_GetTranslatedCoordinates (*TVGObject, DisplayIndex.l, NativeX.l, NativeY.l, *TranslatedX, *TranslatedY)
Prototype.i pr_GetTranslateMouseCoordinates (*TVGObject)
Prototype.i pr_GetTunerFrequency (*TVGObject)
Prototype.i pr_GetTunerMode (*TVGObject)
Prototype.i pr_GetTVChannel (*TVGObject)
Prototype.i pr_GetTVChannelInfo (*TVGObject, Value.l)
Prototype.i pr_GetTVCountryCode (*TVGObject)
Prototype.i pr_GetTVTunerInputType (*TVGObject)
Prototype.i pr_GetTVUseFrequencyOverrides (*TVGObject)
Prototype.i pr_GetUniqueID (*TVGObject)
Prototype.i pr_GetUseClock (*TVGObject)
Prototype.i pr_Getv360_AspectRatio (*TVGObject)
Prototype.i pr_Getv360_Enabled (*TVGObject)
Prototype.i pr_Getv360_MasterAngle (*TVGObject)
Prototype.i pr_Getv360_MouseAction (*TVGObject)
Prototype.i pr_Getv360_MouseActionPercent (*TVGObject)
Prototype.i pr_GetVCRHorizontalLocking (*TVGObject)
Prototype.i pr_GetVersion (*TVGObject)
Prototype.i pr_GetVideoCodec (*TVGObject)
Prototype.i pr_GetVideoCompression_DataRate (*TVGObject)
Prototype.i pr_GetVideoCompression_KeyFrameRate (*TVGObject)
Prototype.i pr_GetVideoCompression_PFramesPerKeyFrame (*TVGObject)
Prototype.d pr_GetVideoCompression_Quality (*TVGObject)
Prototype.i pr_GetVideoCompression_WindowSize (*TVGObject)
Prototype.i pr_GetVideoCompressionSettings (*TVGObject, *DataRate, *KeyFrameRate, *PFramesPerKeyFrame, *WindowSize, *Quality, *CanQuality, *CanCrunch, *CanKeyFrame, *CanBFrame, *CanWindow)
Prototype.i pr_GetVideoCompressor (*TVGObject)
Prototype.i pr_GetVideoCompressorName (*TVGObject)
Prototype.i pr_GetVideoCompressors (*TVGObject)
Prototype.i pr_GetVideoCompressorsCount (*TVGObject)
Prototype.i pr_GetVideoControlMode (*TVGObject, Mode.l)
Prototype.i pr_GetVideoControlSettings (*TVGObject)
Prototype.i pr_GetVideoCursor (*TVGObject)
Prototype.q pr_GetVideoDelay (*TVGObject)
Prototype.i pr_GetVideoDevice (*TVGObject)
Prototype.i pr_GetVideoDeviceName (*TVGObject)
Prototype.i pr_GetVideoDevices (*TVGObject)
Prototype.i pr_GetVideoDevicesCount (*TVGObject)
Prototype.i pr_GetVideoDevicesId (*TVGObject)
Prototype.i pr_GetVideoDoubleBuffered (*TVGObject)
Prototype.i pr_GetVideoFormat (*TVGObject)
Prototype.i pr_GetVideoFormats (*TVGObject)
Prototype.i pr_GetVideoFormatsCount (*TVGObject)
Prototype.i pr_GetVideoFromImages_BitmapsSortedBy (*TVGObject)
Prototype.i pr_GetVideoFromImages_RepeatIndefinitely (*TVGObject)
Prototype.i pr_GetVideoFromImages_SourceDirectory (*TVGObject)
Prototype.i pr_GetVideoFromImages_TemporaryFile (*TVGObject)
Prototype.i pr_GetVideoHeight (*TVGObject)
Prototype.i pr_GetVideoHeight_PreferredAspectRatio (*TVGObject)
Prototype.i pr_GetVideoHeightFromIndex (*TVGObject, SizeIndex.l)
Prototype.i pr_GetVideoInput (*TVGObject)
Prototype.i pr_GetVideoInputs (*TVGObject)
Prototype.i pr_GetVideoInputsCount (*TVGObject)
Prototype.i pr_GetVideoProcessingBrightness (*TVGObject)
Prototype.i pr_GetVideoProcessingContrast (*TVGObject)
Prototype.i pr_GetVideoProcessingDeinterlacing (*TVGObject)
Prototype.i pr_GetVideoProcessingFlipHorizontal (*TVGObject)
Prototype.i pr_GetVideoProcessingFlipVertical (*TVGObject)
Prototype.i pr_GetVideoProcessingGrayScale (*TVGObject)
Prototype.i pr_GetVideoProcessingHue (*TVGObject)
Prototype.i pr_GetVideoProcessingInvertColors (*TVGObject)
Prototype.i pr_GetVideoProcessingLeftRight (*TVGObject)
Prototype.i pr_GetVideoProcessingPixellization (*TVGObject)
Prototype.i pr_GetVideoProcessingRotation (*TVGObject)
Prototype.d pr_GetVideoProcessingRotationCustomAngle (*TVGObject)
Prototype.i pr_GetVideoProcessingSaturation (*TVGObject)
Prototype.i pr_GetVideoProcessingTopDown (*TVGObject)
Prototype.i pr_GetVideoQualitySettings (*TVGObject)
Prototype.i pr_GetVideoRenderer (*TVGObject)
Prototype.i pr_GetVideoRendererExternal (*TVGObject)
Prototype.i pr_GetVideoRendererExternalIndex (*TVGObject)
Prototype.i pr_GetVideoRendererPriority (*TVGObject)
Prototype.i pr_GetVideoSize (*TVGObject)
Prototype.i pr_GetVideoSizeFromIndex (*TVGObject, SizeIndex.l, *_VideoWidth, *_VideoHeight)
Prototype.i pr_GetVideoSizes (*TVGObject)
Prototype.i pr_GetVideoSizesCount (*TVGObject)
Prototype.i pr_GetVideoSource (*TVGObject)
Prototype.i pr_GetVideoSource_FileOrURL (*TVGObject)
Prototype.q pr_GetVideoSource_FileOrURL_StartTime (*TVGObject)
Prototype.q pr_GetVideoSource_FileOrURL_StopTime (*TVGObject)
Prototype.i pr_GetVideoSources (*TVGObject)
Prototype.i pr_GetVideoSourcesCount (*TVGObject)
Prototype.i pr_GetVideoStreamNumber (*TVGObject)
Prototype.i pr_GetVideoSubtype (*TVGObject)
Prototype.i pr_GetVideoSubtypes (*TVGObject)
Prototype.i pr_GetVideoSubtypesCount (*TVGObject)
Prototype.i pr_GetVideoVisibleWhenStopped (*TVGObject)
Prototype.i pr_GetVideoWidth (*TVGObject)
Prototype.i pr_GetVideoWidth_PreferredAspectRatio (*TVGObject)
Prototype.i pr_GetVideoWidthFromIndex (*TVGObject, SizeIndex.l)
Prototype.i pr_GetVirtualAudioStreamControl (*TVGObject)
Prototype.i pr_GetVirtualVideoStreamControl (*TVGObject)
Prototype.i pr_GetVMR9ImageAdjustmentBounds (*TVGObject, MainDisplay.l, VMR9ControlSetting.l, *MinValue, *MaxValue, *StepSize, *DefaultValue, *CurrentValue)
Prototype.i pr_GetVuMeter (*TVGObject)
Prototype.i pr_GetVuMeter_Enabled (*TVGObject, Index)
Prototype.i pr_GetVUMeterSetting (*TVGObject, ChannelIndex.l, VUMeterSetting.l)
Prototype.i pr_GetWebcamStillCaptureButton (*TVGObject)
Prototype.i pr_GetZoomCoeff (*TVGObject)
Prototype.i pr_GetZoomXCenter (*TVGObject)
Prototype.i pr_GetZoomYCenter (*TVGObject)
Prototype.i pr_GraphState (*TVGObject)
Prototype   pr_InitSyncMgr (*TVGObject, FromDeb.l, Is_DM.l)
Prototype.i pr_IsAudioDeviceASoundCard (*TVGObject, DeviceIndex.l)
Prototype.i pr_IsAudioDeviceConnected (*TVGObject, DeviceIndex.l)
Prototype.i pr_IsAudioRendererConnected (*TVGObject, RendererIndex.l)
Prototype.i pr_IsCameraControlSettingAvailable (*TVGObject, Setting.l)
Prototype.i pr_IsDialogAvailable (*TVGObject, Dialog.l)
Prototype.i pr_IsDirectX8OrHigherInstalled (*TVGObject)
Prototype.i pr_IsDVDevice (*TVGObject, Index.l)
Prototype.i pr_IsPlaylistActive (*TVGObject)
Prototype.i pr_IsPreviewStarted (*TVGObject)
Prototype.i pr_IsServerResponding (*TVGObject, *URL, Timeout_Seconds.l)
Prototype.i pr_IsURLResponding (*TVGObject)
Prototype.i pr_IsURLVideoStreamAvailable (*TVGObject, TimeOut_Ms.l)
Prototype.i pr_IsVideoControlModeAvailable (*TVGObject, Mode.l)
Prototype.i pr_IsVideoDeviceConnected (*TVGObject, DeviceIndex.l)
Prototype.i pr_IsVideoQualitySettingAvailable (*TVGObject, Setting.l)
Prototype.i pr_IsVideoSignalDetected (*TVGObject, DetectConnexantBlueScreen.l, DetectCustomRGB.l, CustomR.l, CustomG.l, CustomB.l, UseAsMaxValues.l)
Prototype.i pr_IsVMR9ImageAdjustmentAvailable (*TVGObject, MainDisplay.l)
Prototype.i pr_LoadCompressorSettingsFromDataString (*TVGObject, IsVideoCompressor.l, CompressorIndex.l, *DataString)
Prototype.i pr_LoadCompressorSettingsFromTextFile (*TVGObject, IsVideoCompressor.l, CompressorIndex.l, *FileName)
Prototype.i pr_MixAudioSamples (*TVGObject, *pSampleBuffer, SampleBufferSize.l, SampleDataLength.l, SampleFormatType.l, *pFormat, SampleStartTime.q, SampleStopTime.q)
Prototype.i pr_Mixer_Activation (*TVGObject, Id.l, Activate.l)
Prototype.i pr_Mixer_AddAudioToMixer (*TVGObject, SourceUniqueID.l)
Prototype.i pr_Mixer_AddToMixer (*TVGObject, SourceUniqueID.l, SourceVideoInput.l, MosaicLine.l, MosaicColumn.l, AlternatedGroup.l, AlternatedTimeIntervalInMs.l, ReplacePreviouslyAdded.l, CanEraseBackground.l)
Prototype.i pr_Mixer_AudioActivation (*TVGObject, Id.l, Activate.l)
Prototype.i pr_Mixer_RemoveAudioFromMixer (*TVGObject, Id.l)
Prototype.i pr_Mixer_RemoveFromMixer (*TVGObject, Id.l)
Prototype.i pr_Mixer_SetOverlayAttributes (*TVGObject, Id.l, Transparent_Enabled.l, UseTransparentColor.l, Transparent_ColorValue.l, AlphaBlend_Enabled.l, AlphaBlend_Value.l, ChromaKey_Enabled.l, ChromaKeyRGBColor.l, ChromaKeyLeewayPercent.l, RotationAngle.d)
Prototype.i pr_Mixer_SetupPIPFromSource (*TVGObject, SourceUniqueID.l, Source_Left.l, Source_Top.l, Source_Width.l, Source_Height.l, ActivatePIP.l, PIP_Left.l, PIP_Top.l, PIP_Width.l, PIP_Height.l, MoveToTop.l)
Prototype.i pr_Monitor_Primary_Index (*TVGObject)
Prototype.i pr_MonitorBounds (*TVGObject, MonitorNumber.l, *LeftBound, *TopBound, *RightBound, *BottomBound)
Prototype.i pr_MonitorsCount (*TVGObject)
Prototype.i pr_MotionDetector_CellColorIntensity (*TVGObject, RGBSelector.l, x.l, y.l)
Prototype.d pr_MotionDetector_CellMotionRatio (*TVGObject, x.l, y.l)
Prototype.i pr_MotionDetector_Get2DTextGrid (*TVGObject)
Prototype.i pr_MotionDetector_Get2DTextMotion (*TVGObject)
Prototype.i pr_MotionDetector_GetCellLocation (*TVGObject, x.l, y.l, *XLocation, *YLocation)
Prototype.i pr_MotionDetector_GetCellSensitivity (*TVGObject, x.l, y.l, *Value)
Prototype.i pr_MotionDetector_GetCellSize (*TVGObject, *XSize, *YSize)
Prototype.i pr_MotionDetector_GlobalColorIntensity (*TVGObject, RGBSelector.l)
Prototype   pr_MotionDetector_GloballyIncOrDecSensitivity (*TVGObject, Value.l)
Prototype   pr_MotionDetector_Reset (*TVGObject)
Prototype   pr_MotionDetector_ResetGlobalSensitivity (*TVGObject, Value.l)
Prototype.i pr_MotionDetector_SetCellSensitivity (*TVGObject, x.l, y.l, Value.l)
Prototype   pr_MotionDetector_SetGridSize (*TVGObject, x.l, y.l)
Prototype   pr_MotionDetector_ShowGridDialog (*TVGObject)
Prototype   pr_MotionDetector_TriggerNow (*TVGObject)
Prototype.i pr_MotionDetector_UseThisReferenceSample (*TVGObject, Bitmap_.l, *BMPFile, *JPEGFile)
Prototype.i pr_MPEGProgramSetting (*TVGObject, MPEGProgramSettingValue.l, Value.l)
Prototype.i pr_MultiplexerIndex (*TVGObject, *Value)
Prototype.i pr_MultipurposeEncoder_Convert100nsToHhMmSsZzz (*TVGObject, Time100ns.q)
Prototype.i pr_MultipurposeEncoder_GetCurrentInfo (*TVGObject, MultipurposeEncoderType.l, *InputsTotalDurationMs, *FrameCount, *fps, *quality, *SizeWrittenKb, *TimeMs, *BitRateKbps, *DuplicatedCount, *DroppedCount, *ExitCode)
Prototype.i pr_MultipurposeEncoder_GetLastLog (*TVGObject, MultipurposeEncoderType.l)
Prototype.i pr_MultipurposeEncoder_QuickConfigure_UDPStreaming_H264 (*TVGObject, LogTofile.l, VideoEnabled.l, AudioEnabled.l, *DestinationIP, DestinationPort.l, VideoBitRateKb.l, AudioBitRateKb.l)
Prototype.i pr_MultipurposeEncoder_ReindexClip (*TVGObject, *CurrentFileName, *NewFileName)
Prototype   pr_NotifyPlayerTrackbarAction (*TVGObject, TrackbarAction.l)
Prototype.i pr_ONVIF_GetBool (*TVGObject, *ParamIdentifier, *Value)
Prototype.i pr_ONVIF_GetDouble (*TVGObject, *ParamIdentifier, *Value)
Prototype.i pr_ONVIF_GetInt (*TVGObject, *ParamIdentifier, *Value)
Prototype.i pr_ONVIF_GetStr (*TVGObject, *ParamIdentifier, *Value)
Prototype.i pr_ONVIF_SetBool (*TVGObject, *ParamIdentifier, Value.l)
Prototype.i pr_ONVIF_SetDouble (*TVGObject, *ParamIdentifier, Value.d)
Prototype.i pr_ONVIF_SetInt (*TVGObject, *ParamIdentifier, Value.l)
Prototype.i pr_ONVIF_SetStr (*TVGObject, *ParamIdentifier, *Value)
Prototype.i pr_ONVIFCancelDiscovery (*TVGObject)
Prototype.i pr_ONVIFDeviceInfo (*TVGObject, ONVIFDeviceInfoType)
Prototype.i pr_ONVIFDiscoverCameras_IPRange (*TVGObject, *First_IP, *Last_IP, timeout_seconds_or_0_for_default.l)
Prototype.i pr_ONVIFDiscoverCameras_Multicast (*TVGObject, timeout_seconds_or_0_for_default.l)
Prototype.i pr_ONVIFEnumCamerasDiscovered (*TVGObject, CameraIndex.l, *CameraType, *CameraONVIFUrl)
Prototype.i pr_ONVIFPTZGetLimits (*TVGObject, *Pan_Min, *Pan_Max, *Tilt_Min, *Tilt_Max, *Zoom_Min, *Zoom_Max)
Prototype.i pr_ONVIFPTZGetPosition (*TVGObject, *Pan, *Tilt, *Zoom, *UTCTime, *IsMoving)
Prototype.i pr_ONVIFPTZPreset (*TVGObject, *PresetAction, *PresetName)
Prototype.i pr_ONVIFPTZSendAuxiliaryCommand (*TVGObject, *AuxiliaryCommand)
Prototype.i pr_ONVIFPTZSetPosition (*TVGObject, Pan.d, Tilt.d, Zoom.d, SpeedRatio.d, IsRelative.l)
Prototype.i pr_ONVIFPTZStartMove (*TVGObject, *PTZType, OppositeDirection.l, SpeedRatio.d, DurationMs.l)
Prototype.i pr_ONVIFPTZStopMove (*TVGObject, *PTZType)
Prototype.i pr_ONVIFSnapShot (*TVGObject, OnRawVideoSampleCallbackEnabled.l, SaveToFile.l, *FileName)
Prototype.i pr_OpenDVD (*TVGObject)
Prototype.i pr_OpenPlayer (*TVGObject)
Prototype.i pr_OpenPlayerAtFramePositions (*TVGObject, StartFrame.q, StopFrame.q, KeepBounds.l, CloseAndReopenIfAlreadyOpened.l)
Prototype.i pr_OpenPlayerAtTimePositions (*TVGObject, StartTime.q, StopTime.q, KeepBounds.l, CloseAndReopenIfAlreadyOpened.l)
Prototype.i pr_OpenURLAsyncStatus (*TVGObject)
Prototype   pr_PausePlayer (*TVGObject)
Prototype.i pr_PausePreview (*TVGObject)
Prototype.i pr_PauseRecording (*TVGObject)
Prototype.i pr_PlayerFrameStep (*TVGObject, FrameCount.l)
Prototype.i pr_Playlist (*TVGObject, PlaylistAction.l, *VideoClip)
Prototype.i pr_PointGreyConfig (*TVGObject, ConfigType.l, *PGRActionValue, ulRegister.l, ulMode.l, ulLeft.l, ulTop.l, ulWidth.l, ulHeight.l, ulPercentage.l, ulFormat.l)
Prototype.i pr_PreloadFilters (*TVGObject, *FilterName_or_Empty_for_All_Filters)
Prototype.i pr_PutMiscDeviceControl (*TVGObject, MiscDeviceControl.l, Index.l, Value.l)
Prototype.i pr_RecordingKBytesWrittenToDisk (*TVGObject)
Prototype.i pr_RecordToNewFileNow (*TVGObject, *NewRecordingFileName, ResetStreamTime.l)
Prototype.i pr_ReencodeVideoClip (*TVGObject, *SourceVideoClip, *NewVideoClip, IncludeVideoStream.l, IncludeAudioStream.l, UseFrameGrabber.l, UseCurrentVideoCompressor.l, UseCurrentAudioCompressor.l)
Prototype   pr_RefreshDevicesAndCompressorsLists (*TVGObject)
Prototype   pr_RefreshPlayerOverlays (*TVGObject)
Prototype.i pr_ResetPreview (*TVGObject)
Prototype.i pr_ResetVideoDeviceSettings (*TVGObject)
Prototype.i pr_ResumePreview (*TVGObject)
Prototype.i pr_ResumeRecording (*TVGObject)
Prototype   pr_RetrieveInitialXYAfterRotation (*TVGObject, x.l, y.l, *OriginalX, *OriginalY)
Prototype   pr_RewindPlayer (*TVGObject)
Prototype   pr_RunPlayer (*TVGObject)
Prototype   pr_RunPlayerBackwards (*TVGObject)
Prototype.i pr_SaveCompressorSettingsToDataString (*TVGObject, IsVideoCompressor.l, CompressorIndex.l)
Prototype.i pr_SaveCompressorSettingsToTextFile (*TVGObject, IsVideoCompressor.l, CompressorIndex.l, *FileName)
Prototype.i pr_ScheduleNextActionAtAbsoluteDateTime (*TVGObject, Year.l, Month.l, Day.l, Hour.l, Min.l, Sec.l, MSec.l)
Prototype.i pr_ScheduleNextActionAtAbsoluteTime (*TVGObject, Hour.l, Min.l, Sec.l, MSec.l)
Prototype.i pr_ScheduleNextActionFromNow (*TVGObject, Day.l, Hour.l, Min.l, Sec.l, MSec.l)
Prototype.i pr_ScreenRecordingUsingCoordinates (*TVGObject, FunctionEnabled.l, scLeft.l, scTop.l, scWidth.l, scHeight.l)
Prototype.i pr_SendCameraCommand (*TVGObject, Pan.l, Tilt.l, Relative.l)
Prototype.i pr_SendDVCommand (*TVGObject, DVCommand.l)
Prototype.i pr_SendImageToVideoFromBitmaps (*TVGObject, *ImageFilePath, BitmapHandle.l, CanFreeBitmapHandle.l, EndOfData.l)
Prototype.i pr_SendImageToVideoFromBitmaps2 (*TVGObject, *pBtmapInfo, *pBitmapBits, EndOfData.l)
Prototype.i pr_SendIPCameraCommand (*TVGObject, *IPCameraCommand)
Prototype   pr_Set_OnDeviceArrivalOrRemoval (*TVGObject, *Value)
Prototype   pr_SetAdjustOverlayAspectRatio (*TVGObject, Value.l)
Prototype   pr_SetAdjustPixelAspectRatio (*TVGObject, Value.l)
Prototype   pr_SetAero (*TVGObject, Value.l)
Prototype   pr_SetAnalogVideoStandard (*TVGObject, Value.l)
Prototype   pr_SetApplicationPriority (*TVGObject, Value.l)
Prototype   pr_SetASFAudioBitRate (*TVGObject, Value.l)
Prototype   pr_SetASFAudioChannels (*TVGObject, Value.l)
Prototype   pr_SetASFBufferWindow (*TVGObject, Value.l)
Prototype   pr_SetASFDeinterlaceMode (*TVGObject, Value.l)
Prototype   pr_SetASFDirectStreamingKeepClientsConnected (*TVGObject, Value.l)
Prototype   pr_SetASFFixedFrameRate (*TVGObject, Value.l)
Prototype   pr_SetASFMediaServerPublishingPoint (*TVGObject, *Value)
Prototype   pr_SetASFMediaServerRemovePublishingPointAfterDisconnect (*TVGObject, Value.l)
Prototype   pr_SetASFMediaServerTemplatePublishingPoint (*TVGObject, *Value)
Prototype   pr_SetASFNetworkMaxUsers (*TVGObject, Value.l)
Prototype   pr_SetASFNetworkPort (*TVGObject, Value.l)
Prototype   pr_SetASFProfile (*TVGObject, Value.l)
Prototype   pr_SetASFProfileFromCustomFile (*TVGObject, *Value)
Prototype   pr_SetASFProfileVersion (*TVGObject, Value.l)
Prototype   pr_SetASFVideoBitRate (*TVGObject, Value.l)
Prototype   pr_SetASFVideoFrameRate (*TVGObject, Value.d)
Prototype   pr_SetASFVideoHeight (*TVGObject, Value.l)
Prototype   pr_SetASFVideoMaxKeyFrameSpacing (*TVGObject, Value.l)
Prototype   pr_SetASFVideoQuality (*TVGObject, Value.l)
Prototype   pr_SetASFVideoWidth (*TVGObject, Value.l)
Prototype   pr_SetAspectRatioToUse (*TVGObject, Value.d)
Prototype   pr_SetAssociateAudioAndVideoDevices (*TVGObject, Value.l)
Prototype   pr_SetAudioBalance (*TVGObject, Value.l)
Prototype   pr_SetAudioChannelRenderMode (*TVGObject, Value.l)
Prototype   pr_SetAudioCompressor (*TVGObject, Value.l)
Prototype   pr_SetAudioDevice (*TVGObject, Value.l)
Prototype   pr_SetAudioDeviceRendering (*TVGObject, Value.l)
Prototype   pr_SetAudioFormat (*TVGObject, Value.l)
Prototype   pr_SetAudioInput (*TVGObject, Value.l)
Prototype   pr_SetAudioInputBalance (*TVGObject, Value.l)
Prototype   pr_SetAudioInputLevel (*TVGObject, Value.l)
Prototype   pr_SetAudioInputMono (*TVGObject, Value.l)
Prototype   pr_SetAudioPeakEvent (*TVGObject, Value.l)
Prototype   pr_SetAudioRecording (*TVGObject, Value.l)
Prototype   pr_SetAudioRenderer (*TVGObject, Value.l)
Prototype   pr_SetAudioRendererAdditional (*TVGObject, Value.l)
Prototype   pr_SetAudioSource (*TVGObject, Value.l)
Prototype   pr_SetAudioStreamNumber (*TVGObject, Value.l)
Prototype   pr_SetAudioSyncAdjustment (*TVGObject, Value.l)
Prototype   pr_SetAudioSyncAdjustmentEnabled (*TVGObject, Value.l)
Prototype   pr_SetAudioVolume (*TVGObject, Value.l)
Prototype   pr_SetAudioVolumeEnabled (*TVGObject, Value.l)
Prototype   pr_SetAuthentication (*TVGObject, AuthenticationType.l, *UserName, *Password)
Prototype   pr_SetAutoConnectRelatedPins (*TVGObject, Value.l)
Prototype   pr_SetAutoFileName (*TVGObject, Value.l)
Prototype   pr_SetAutoFileNameDateTimeFormat (*TVGObject, *Value)
Prototype   pr_SetAutoFileNameMinDigits (*TVGObject, Value.l)
Prototype   pr_SetAutoFilePrefix (*TVGObject, *Value)
Prototype   pr_SetAutoFileSuffix (*TVGObject, *Value)
Prototype   pr_SetAutoRefreshPreview (*TVGObject, Value.l)
Prototype   pr_SetAutoStartPlayer (*TVGObject, Value.l)
Prototype   pr_SetAVIDurationUpdated (*TVGObject, Value.l)
Prototype   pr_SetAVIFormatOpenDML (*TVGObject, Value.l)
Prototype   pr_SetAVIFormatOpenDMLCompatibilityIndex (*TVGObject, Value.l)
Prototype   pr_SetAVIMuxConfig (*TVGObject, AVIMuxSetting.l, Value.l)
Prototype   pr_SetBackgroundColor (*TVGObject, Value.l)
Prototype   pr_SetBufferCount (*TVGObject, Value.l)
Prototype   pr_SetBurstCount (*TVGObject, Value.l)
Prototype   pr_SetBurstInterval (*TVGObject, Value.l)
Prototype   pr_SetBurstMode (*TVGObject, Value.l)
Prototype   pr_SetBurstType (*TVGObject, Value.l)
Prototype   pr_SetBusyCursor (*TVGObject, Value.l)
Prototype   pr_SetCallbackSender (*TVGObject, *Sender)
Prototype.i pr_SetCameraControl (*TVGObject, Setting.l, SetAuto.l, SetDefault.l, SetValue.l)
Prototype   pr_SetCameraControlSettings (*TVGObject, Value.l)
Prototype   pr_SetCameraExposure (*TVGObject, Value.d)
Prototype   pr_SetCaptureFileExt (*TVGObject, *Value)
Prototype   pr_SetColorKey (*TVGObject, Value.l)
Prototype   pr_SetColorKeyEnabled (*TVGObject, Value.l)
Prototype   pr_SetCompressionMode (*TVGObject, Value.l)
Prototype   pr_SetCompressionType (*TVGObject, Value.l)
Prototype   pr_SetCropping_Enabled (*TVGObject, Value.l)
Prototype   pr_SetCropping_Height (*TVGObject, Value.l)
Prototype   pr_SetCropping_Outbounds (*TVGObject, Value.l)
Prototype   pr_SetCropping_Width (*TVGObject, Value.l)
Prototype   pr_SetCropping_X (*TVGObject, Value.l)
Prototype   pr_SetCropping_Y (*TVGObject, Value.l)
Prototype   pr_SetCropping_Zoom (*TVGObject, Value.d)
Prototype   pr_SetDisplayActive (*TVGObject, DisplayIndex.l, Value.l)
Prototype   pr_SetDisplayAlphaBlendEnabled (*TVGObject, DisplayIndex.l, Value.l)
Prototype   pr_SetDisplayAlphaBlendValue (*TVGObject, DisplayIndex.l, Value.l)
Prototype   pr_SetDisplayAspectRatio (*TVGObject, DisplayIndex.l, Value.l)
Prototype.i pr_SetDisplayAssociatedRenderer (*TVGObject, DisplayIndex.l, *Value)
Prototype   pr_SetDisplayAutoSize (*TVGObject, DisplayIndex.l, Value.l)
Prototype   pr_SetDisplayEmbedded (*TVGObject, DisplayIndex.l, Value.l)
Prototype   pr_SetDisplayEmbedded_FitParent (*TVGObject, DisplayIndex.l, Value.l)
Prototype   pr_SetDisplayFullScreen (*TVGObject, DisplayIndex.l, Value.l)
Prototype   pr_SetDisplayHeight (*TVGObject, DisplayIndex.l, Value.l)
Prototype   pr_SetDisplayLeft (*TVGObject, DisplayIndex.l, Value.l)
Prototype.i pr_SetDisplayLocation (*TVGObject, DisplayIndex.l, WindowLeft.l, WindowTop.l, WindowWidth.l, WindowHeight.l)
Prototype   pr_SetDisplayMonitor (*TVGObject, DisplayIndex.l, Value.l)
Prototype   pr_SetDisplayMouseMovesWindow (*TVGObject, DisplayIndex.l, Value.l)
Prototype   pr_SetDisplayPanScanRatio (*TVGObject, DisplayIndex.l, Value.l)
Prototype.i pr_SetDisplayParent (*TVGObject, DisplayIndex.l, DisplayParent.l)
Prototype   pr_SetDisplayStayOnTop (*TVGObject, DisplayIndex.l, Value.l)
Prototype   pr_SetDisplayTop (*TVGObject, DisplayIndex.l, Value.l)
Prototype   pr_SetDisplayTransparentColorEnabled (*TVGObject, DisplayIndex.l, Value.l)
Prototype   pr_SetDisplayTransparentColorValue (*TVGObject, DisplayIndex.l, Value.l)
Prototype   pr_SetDisplayVideoPortEnabled (*TVGObject, DisplayIndex.l, Value.l)
Prototype   pr_SetDisplayVisible (*TVGObject, DisplayIndex.l, Value.l)
Prototype   pr_SetDisplayWidth (*TVGObject, DisplayIndex.l, Value.l)
Prototype   pr_SetDroppedFramesPollingInterval (*TVGObject, Value.l)
Prototype   pr_SetDVDateTimeEnabled (*TVGObject, Value.l)
Prototype   pr_SetDVDiscontinuityMinimumInterval (*TVGObject, Value.l)
Prototype   pr_SetDVDTitle (*TVGObject, Value.l)
Prototype   pr_SetDVEncoder_VideoFormat (*TVGObject, Value.l)
Prototype   pr_SetDVEncoder_VideoResolution (*TVGObject, Value.l)
Prototype   pr_SetDVEncoder_VideoStandard (*TVGObject, Value.l)
Prototype   pr_SetDVRecordingInNativeFormatSeparatesStreams (*TVGObject, Value.l)
Prototype   pr_SetDVReduceFrameRate (*TVGObject, Value.l)
Prototype   pr_SetDVRgb219 (*TVGObject, Value.l)
Prototype   pr_SetDVTimeCodeEnabled (*TVGObject, Value.l)
Prototype   pr_SetEventNotificationSynchrone (*TVGObject, Value.l)
Prototype   pr_SetExtraDLLPath (*TVGObject, *Value)
Prototype   pr_SetFixFlickerOrBlackCapture (*TVGObject, Value.l)
Prototype   pr_SetFrameCaptureBounds (*TVGObject, LeftPosition.l, TopPosition.l, RightPosition.l, BottomPosition.l)
Prototype   pr_SetFrameCaptureHeight (*TVGObject, Value.l)
Prototype   pr_SetFrameCaptureWidth (*TVGObject, Value.l)
Prototype   pr_SetFrameCaptureWithoutOverlay (*TVGObject, Value.l)
Prototype   pr_SetFrameCaptureZoomSize (*TVGObject, Value.l)
Prototype   pr_SetFrameGrabber (*TVGObject, Value.l)
Prototype   pr_SetFrameGrabberRGBFormat (*TVGObject, Value.l)
Prototype   pr_SetFrameNumberStartsFromZero (*TVGObject, Value.l)
Prototype   pr_SetFrameRate (*TVGObject, Value.d)
Prototype   pr_SetFrameRateDivider (*TVGObject, Value.l)
Prototype   pr_SetFWCam1394 (*TVGObject, *FWCam1394ID, Value.l)
Prototype   pr_SetGetLastFrameWaitTimeoutMs (*TVGObject, Value.l)
Prototype   pr_SetGeneratePts (*TVGObject, Value.l)
Prototype   pr_SetHeaderAttribute (*TVGObject, HeaderAttribute.l, *Value)
Prototype   pr_SetHoldRecording (*TVGObject, Value.l)
Prototype   pr_SetImageOverlay_AlphaBlend (*TVGObject, Index.l, Value.l)
Prototype   pr_SetImageOverlay_AlphaBlendValue (*TVGObject, Index.l, Value.l)
Prototype   pr_SetImageOverlay_Attributes (*TVGObject, LeftLocation.l, TopLocation.l, StretchedWidth.l, StretchedHeight.l, Transparent_Enabled.l, UseTransparentColor.l, Transparent_ColorValue.l, AlphaBlend_Enabled.l, AlphaBlend_Value.l)
Prototype   pr_SetImageOverlay_Attributes2 (*TVGObject, Index.l, LeftLocation.l, TopLocation.l, StretchedWidth.l, StretchedHeight.l, Transparent_Enabled.l, UseTransparentColor.l, Transparent_ColorValue.l, AlphaBlend_Enabled.l, AlphaBlend_Value.l)
Prototype   pr_SetImageOverlay_ChromaKey (*TVGObject, Index.l, Value.l)
Prototype   pr_SetImageOverlay_ChromaKeyLeewayPercent (*TVGObject, Index.l, Value.l)
Prototype   pr_SetImageOverlay_ChromaKeyRGBColor (*TVGObject, Index.l, Value.l)
Prototype   pr_SetImageOverlay_Enabled (*TVGObject, Index.l, Value.l)
Prototype   pr_SetImageOverlay_Height (*TVGObject, Index.l, Value.l)
Prototype   pr_SetImageOverlay_LeftLocation (*TVGObject, Index.l, Value.l)
Prototype   pr_SetImageOverlay_RotationAngle (*TVGObject, Index.l, Value.d)
Prototype   pr_SetImageOverlay_StretchToVideoSize (*TVGObject, Index.l, Value.l)
Prototype   pr_SetImageOverlay_TargetDisplay (*TVGObject, Index.l, Value.l)
Prototype   pr_SetImageOverlay_TopLocation (*TVGObject, Index.l, Value.l)
Prototype   pr_SetImageOverlay_Transparent (*TVGObject, Index.l, Value.l)
Prototype   pr_SetImageOverlay_TransparentColorValue (*TVGObject, Index.l, Value.l)
Prototype   pr_SetImageOverlay_UseTransparentColor (*TVGObject, Index.l, Value.l)
Prototype   pr_SetImageOverlay_VideoAlignment (*TVGObject, Index.l, Value.l)
Prototype   pr_SetImageOverlay_Width (*TVGObject, Index.l, Value.l)
Prototype   pr_SetImageOverlayAlphaBlend (*TVGObject, Value.l)
Prototype   pr_SetImageOverlayAlphaBlendValue (*TVGObject, Value.l)
Prototype   pr_SetImageOverlayChromaKey (*TVGObject, Value.l)
Prototype   pr_SetImageOverlayChromaKeyLeewayPercent (*TVGObject, Value.l)
Prototype   pr_SetImageOverlayChromaKeyRGBColor (*TVGObject, Value.l)
Prototype   pr_SetImageOverlayEnabled (*TVGObject, Value.l)
Prototype.i pr_SetImageOverlayFromBMPFile (*TVGObject, *FileName)
Prototype.i pr_SetImageOverlayFromBMPFile2 (*TVGObject, Index.l, *FileName)
Prototype.i pr_SetImageOverlayFromHBitmap (*TVGObject, Bitmap.l)
Prototype.i pr_SetImageOverlayFromHBitmap2 (*TVGObject, Index.l, Bitmap.l)
Prototype.i pr_SetImageOverlayFromHBitmap3 (*TVGObject, Index.l, Bitmap.l, ReleaseBitmap.l)
Prototype.i pr_SetImageOverlayFromImageFile (*TVGObject, *FileName)
Prototype.i pr_SetImageOverlayFromImageFile2 (*TVGObject, Index.l, *FileName)
Prototype.i pr_SetImageOverlayFromJPEGFile (*TVGObject, *FileName)
Prototype.i pr_SetImageOverlayFromJPEGFile2 (*TVGObject, Index.l, *FileName)
Prototype   pr_SetImageOverlayHeight (*TVGObject, Value.l)
Prototype   pr_SetImageOverlayLeftLocation (*TVGObject, Value.l)
Prototype   pr_SetImageOverlayRotationAngle (*TVGObject, Value.d)
Prototype   pr_SetImageOverlaySelector (*TVGObject, Value.l)
Prototype   pr_SetImageOverlayStretchToVideoSize (*TVGObject, Value.l)
Prototype   pr_SetImageOverlayTargetDisplay (*TVGObject, Value.l)
Prototype   pr_SetImageOverlayTopLocation (*TVGObject, Value.l)
Prototype   pr_SetImageOverlayTransparent (*TVGObject, Value.l)
Prototype   pr_SetImageOverlayTransparentColorValue (*TVGObject, Value.l)
Prototype   pr_SetImageOverlayUseTransparentColor (*TVGObject, Value.l)
Prototype   pr_SetImageOverlayVideoAlignment (*TVGObject, Value.l)
Prototype   pr_SetImageOverlayWidth (*TVGObject, Value.l)
Prototype.i pr_SetIPCameraSetting (*TVGObject, Setting.l, Value.l)
Prototype   pr_SetIPCameraURL (*TVGObject, *Value)
Prototype   pr_SetJPEGPerformance (*TVGObject, Value.l)
Prototype   pr_SetJPEGProgressiveDisplay (*TVGObject, Value.l)
Prototype   pr_SetJPEGQuality (*TVGObject, Value.l)
Prototype   pr_SetLicenseString (*TVGObject, *PassedValue)
Prototype   pr_SetLocation (*TVGObject, lLeft.l, lTop.l, lWidth.l, lHeight.l)
Prototype   pr_SetLogoDisplayed (*TVGObject, Value.l)
Prototype.i pr_SetLogoFromBMPFile (*TVGObject, *FileName)
Prototype.i pr_SetLogoFromHBitmap (*TVGObject, Bitmap.l)
Prototype.i pr_SetLogoFromJPEGFile (*TVGObject, *FileName)
Prototype   pr_SetLogoLayout (*TVGObject, Value.l)
Prototype   pr_SetMixAudioSamplesLevel (*TVGObject, Index.l, Value.l)
Prototype   pr_SetMixer_MosaicColumns (*TVGObject, Value.l)
Prototype   pr_SetMixer_MosaicLines (*TVGObject, Value.l)
Prototype   pr_SetMotionDetector_CompareBlue (*TVGObject, Value.l)
Prototype   pr_SetMotionDetector_CompareGreen (*TVGObject, Value.l)
Prototype   pr_SetMotionDetector_CompareRed (*TVGObject, Value.l)
Prototype   pr_SetMotionDetector_Enabled (*TVGObject, Value.l)
Prototype   pr_SetMotionDetector_GreyScale (*TVGObject, Value.l)
Prototype   pr_SetMotionDetector_Grid (*TVGObject, *Value)
Prototype   pr_SetMotionDetector_MaxDetectionsPerSecond (*TVGObject, Value.d)
Prototype   pr_SetMotionDetector_MotionResetMs (*TVGObject, Value.l)
Prototype   pr_SetMotionDetector_ReduceCPULoad (*TVGObject, Value.l)
Prototype   pr_SetMotionDetector_ReduceVideoNoise (*TVGObject, Value.l)
Prototype   pr_SetMotionDetector_Triggered (*TVGObject, Value.l)
Prototype   pr_SetMouseWheelEventEnabled (*TVGObject, Value.l)
Prototype   pr_SetMouseWheelControlsZoomAtCursor (*TVGObject, Value.l)
Prototype   pr_SetMpegStreamType (*TVGObject, Value.l)
Prototype   pr_SetMultiplexedInputEmulation (*TVGObject, Value.l)
Prototype   pr_SetMultiplexedRole (*TVGObject, Value.l)
Prototype   pr_SetMultiplexedStabilizationDelay (*TVGObject, Value.l)
Prototype   pr_SetMultiplexedSwitchDelay (*TVGObject, Value.l)
Prototype   pr_SetMultiplexer (*TVGObject, Value.l)
Prototype   pr_SetMultiplexerFilterByName (*TVGObject, *Value)
Prototype   pr_SetMultipurposeEncoderSettings (*TVGObject, MultipurposeEncoderType.l, *Settings)
Prototype   pr_SetMuteAudioRendering (*TVGObject, Value.l)
Prototype   pr_SetName (*TVGObject, *Value)
Prototype   pr_SetNDIBandwidthType (*TVGObject, Value.l)
Prototype   pr_SetNDIGroups (*TVGObject, *Value)
Prototype   pr_SetNDIName (*TVGObject, *Value)
Prototype   pr_SetNDIReceiveTimeoutMs (*TVGObject, Value.l)
Prototype   pr_SetNetworkStreaming (*TVGObject, Value.l)
Prototype   pr_SetNetworkStreamingType (*TVGObject, Value.l)
Prototype   pr_SetNormalCursor (*TVGObject, Value.l)
Prototype   pr_SetNotificationMethod (*TVGObject, Value.l)
Prototype   pr_SetNotificationPriority (*TVGObject, Value.l)
Prototype   pr_SetNotificationSleepTime (*TVGObject, Value.l)
Prototype   pr_SetOnAudioBufferNegotiation (*TVGObject, *Event)
Prototype   pr_SetOnAudioDeviceSelected (*TVGObject, *Event)
Prototype   pr_SetOnAudioPeak (*TVGObject, *Event)
Prototype   pr_SetOnAuthenticationNeeded (*TVGObject, *Event)
Prototype   pr_SetOnAVIDurationUpdated (*TVGObject, *Event)
Prototype   pr_SetOnBacktimedFramesCountReached (*TVGObject, *Event)
Prototype   pr_SetOnBitmapsLoadingProgress (*TVGObject, *Event)
Prototype   pr_SetOnClick (*TVGObject, *Event)
Prototype   pr_SetOnClientConnection (*TVGObject, *Event)
Prototype   pr_SetOnColorKeyChange (*TVGObject, *Event)
Prototype   pr_SetOnCopyPreallocDataCompleted (*TVGObject, *Event)
Prototype   pr_SetOnCopyPreallocDataProgress (*TVGObject, *Event)
Prototype   pr_SetOnCopyPreallocDataStarted (*TVGObject, *Event)
Prototype   pr_SetOnCreatePreallocFileCompleted (*TVGObject, *Event)
Prototype   pr_SetOnCreatePreallocFileProgress (*TVGObject, *Event)
Prototype   pr_SetOnCreatePreallocFileStarted (*TVGObject, *Event)
Prototype   pr_SetOnDblClick (*TVGObject, *Event)
Prototype   pr_SetOnDeviceArrivalOrRemoval (*TVGObject, *Event)
Prototype   pr_SetOnDeviceLost (*TVGObject, *Event)
Prototype   pr_SetOnDeviceReconnected (*TVGObject, *Event)
Prototype   pr_SetOnDeviceReconnecting (*TVGObject, *Event)
Prototype   pr_SetOnDirectNetworkStreamingHostUrl (*TVGObject, *Event)
Prototype   pr_SetOnDiskFull (*TVGObject, *Event)
Prototype   pr_SetOnDoEvents (*TVGObject, *Value)
Prototype   pr_SetOnDragDrop (*TVGObject, *Event)
Prototype   pr_SetOnDragDropFiles (*TVGObject, *Event)
Prototype   pr_SetOnDragOver (*TVGObject, *Event)
Prototype   pr_SetOnDVCommandCompleted (*TVGObject, *Event)
Prototype   pr_SetOnDVDiscontinuity (*TVGObject, *Event)
Prototype   pr_SetOnEnumerateWindows (*TVGObject, *Event)
Prototype   pr_SetOnFilterSelected (*TVGObject, *Event)
Prototype   pr_SetOnFirstFrameReceived (*TVGObject, *Event)
Prototype   pr_SetOnFrameBitmap (*TVGObject, *Event)
Prototype   pr_SetOnFrameBitmapEventSynchrone (*TVGObject, Value.l)
Prototype   pr_SetOnFrameCaptureCompleted (*TVGObject, *Event)
Prototype   pr_SetOnFrameOverlayUsingDC (*TVGObject, *Event)
Prototype   pr_SetOnFrameOverlayUsingDIB (*TVGObject, *Event)
Prototype   pr_SetOnFrameProgress (*TVGObject, *Event)
Prototype   pr_SetOnFrameProgress2 (*TVGObject, *Event)
Prototype   pr_SetOnGraphBuilt (*TVGObject, *Event)
Prototype   pr_SetOnInactive (*TVGObject, *Event)
Prototype   pr_SetOnKeyPress (*TVGObject, *Event)
Prototype   pr_SetOnLastCommandCompleted (*TVGObject, *Event)
Prototype   pr_SetOnLeavingFullScreen (*TVGObject, *Event)
Prototype   pr_SetOnLog (*TVGObject, *Event)
Prototype   pr_SetOnMotionDetected (*TVGObject, *Event)
Prototype   pr_SetOnMotionNotDetected (*TVGObject, *Event)
Prototype   pr_SetOnMouseDown (*TVGObject, *Event)
Prototype   pr_SetOnMouseDown_Video (*TVGObject, *Event)
Prototype   pr_SetOnMouseDown_Window (*TVGObject, *Event)
Prototype   pr_SetOnMouseEnter (*TVGObject, *Event)
Prototype   pr_SetOnMouseLeave (*TVGObject, *Event)
Prototype   pr_SetOnMouseMove (*TVGObject, *Event)
Prototype   pr_SetOnMouseMove_Video (*TVGObject, *Event)
Prototype   pr_SetOnMouseMove_Window (*TVGObject, *Event)
Prototype   pr_SetOnMouseUp (*TVGObject, *Event)
Prototype   pr_SetOnMouseUp_Video (*TVGObject, *Event)
Prototype   pr_SetOnMouseUp_Window (*TVGObject, *Event)
Prototype   pr_SetOnMouseWheel (*TVGObject, *Event)
Prototype   pr_SetOnMultipurposeEncoderCompleted (*TVGObject, *Event)
Prototype   pr_SetOnMultipurposeEncoderError (*TVGObject, *Event)
Prototype   pr_SetOnMultipurposeEncoderProgress (*TVGObject, *Event)
Prototype   pr_SetOnNoVideoDevices (*TVGObject, *Event)
Prototype   pr_SetOnNTPTimeStamp (*TVGObject, *Event)
Prototype   pr_SetOnONVIFDiscoveryCompleted (*TVGObject, *Event)
Prototype   pr_SetOnPlayerBufferingData (*TVGObject, *Event)
Prototype   pr_SetOnPlayerDurationUpdated (*TVGObject, *Event)
Prototype   pr_SetOnPlayerEndOfPlaylist (*TVGObject, *Event)
Prototype   pr_SetOnPlayerEndOfStream (*TVGObject, *Event)
Prototype   pr_SetOnPlayerOpened (*TVGObject, *Event)
Prototype   pr_SetOnPlayerStateChanged (*TVGObject, *Event)
Prototype   pr_SetOnPlayerUpdateTrackbarPosition (*TVGObject, *Event)
Prototype   pr_SetOnPreviewStarted (*TVGObject, *Event)
Prototype   pr_SetOnRawAudioSample (*TVGObject, *Event) ;, *pSampleBuffer, SampleBufferSize.l, SampleDataLength.l, FormatType.l, *pFormat, *pWaveFormatEx, SampleStartTime.d, SampleStopTime.d)
Prototype   pr_SetOnRawVideoSample (*TVGObject, *Event) ;, *pSampleBuffer, SampleBufferSize.l, SampleDataLength.l, FormatType.l, *pFormat, *pBitmapInfoHeader, SampleStartTime.d, SampleStopTime.d)
Prototype   pr_SetOnRecordingCompleted (*TVGObject, *Event)
Prototype   pr_SetOnRecordingPaused (*TVGObject, *Event)
Prototype   pr_SetOnRecordingReadyToStart (*TVGObject, *Event)
Prototype   pr_SetOnRecordingStarted (*TVGObject, *Event)
Prototype   pr_SetOnReencodingCompleted (*TVGObject, *Event)
Prototype   pr_SetOnReencodingProgress (*TVGObject, *Event)
Prototype   pr_SetOnReencodingStarted (*TVGObject, *Event)
Prototype   pr_SetOnReinitializing (*TVGObject, *Event)
Prototype   pr_SetOnResizeVideo (*TVGObject, *Event)
Prototype   pr_SetOnStoppingGraph (*TVGObject, *Event)
Prototype   pr_SetOnStoppingGraphCompleted (*TVGObject, *Event)
Prototype   pr_SetOnTextOverlayScrollingCompleted (*TVGObject, *Event)
Prototype   pr_SetOnThirdPartyFilterAdded (*TVGObject, *Event)
Prototype   pr_SetOnThirdPartyFilterConnected (*TVGObject, *Event)
Prototype   pr_SetOnThirdPartyFilterConnected2 (*TVGObject, *Event)
Prototype   pr_SetOnThreadSync (*TVGObject, *Event)
Prototype   pr_SetOnTVChannelScanCompleted (*TVGObject, *Event)
Prototype   pr_SetOnTVChannelScanStarted (*TVGObject, *Event)
Prototype   pr_SetOnTVChannelSelected (*TVGObject, *Event)
Prototype   pr_SetOnVideoCompressionSettings (*TVGObject, *Event)
Prototype   pr_SetOnVideoDeviceSelected (*TVGObject, *Event)
Prototype   pr_SetOnVideoFromBitmapsNextFrameNeeded (*TVGObject, *Event)
Prototype   pr_SetOpenURLAsync (*TVGObject, Value.l)
Prototype   pr_SetOverlayAfterTransform (*TVGObject, Value.l)
Prototype   pr_SetParentWindow (*TVGObject, Value.l)
Prototype   pr_SetPlayerAudioRendering (*TVGObject, Value.l)
Prototype   pr_SetPlayerDuration (*TVGObject, Value.q)
Prototype   pr_SetPlayerDVSize (*TVGObject, Value.l)
Prototype   pr_SetPlayerFastSeekSpeedRatio (*TVGObject, Value.l)
Prototype   pr_SetPlayerFileName (*TVGObject, *Value)
Prototype   pr_SetPlayerForcedCodec (*TVGObject, *Value)
Prototype   pr_SetPlayerFramePosition (*TVGObject, Value.q)
Prototype   pr_SetPlayerHwAccel (*TVGObject, Value.l)
Prototype   pr_SetPlayerRefreshPausedDisplay (*TVGObject, Value.l)
Prototype   pr_SetPlayerRefreshPausedDisplayFrameRate (*TVGObject, Value.d)
Prototype   pr_SetPlayerSpeedRatio (*TVGObject, Value.d)
Prototype   pr_SetPlayerSpeedRatioConstantAudioPitch (*TVGObject, Value.l)
Prototype   pr_SetPlayerTimePosition (*TVGObject, Value.q)
Prototype   pr_SetPlayerTrackBarSynchrone (*TVGObject, Value.l)
Prototype   pr_SetPlaylistIndex (*TVGObject, Value.l)
Prototype   pr_SetPreallocCapFileCopiedAfterRecording (*TVGObject, Value.l)
Prototype   pr_SetPreallocCapFileEnabled (*TVGObject, Value.l)
Prototype   pr_SetPreallocCapFileName (*TVGObject, *Value)
Prototype   pr_SetPreallocCapFileSizeInMB (*TVGObject, Value.l)
Prototype   pr_SetPreviewZoomSize (*TVGObject, Value.l)
Prototype   pr_SetQuickDeviceInitialization (*TVGObject, Value.l)
Prototype   pr_SetRawAudioSampleCapture (*TVGObject, Value.l)
Prototype   pr_SetRawCaptureAsyncEvent (*TVGObject, Value.l)
Prototype   pr_SetRawSampleCaptureLocation (*TVGObject, Value.l)
Prototype   pr_SetRawVideoSampleCapture (*TVGObject, Value.l)
Prototype   pr_SetRecordingAudioBitRate (*TVGObject, Value.l)
Prototype   pr_SetRecordingBacktimedFramesCount (*TVGObject, Value.l)
Prototype   pr_SetRecordingCanPause (*TVGObject, Value.l)
Prototype   pr_SetRecordingFileName (*TVGObject, *Value)
Prototype   pr_SetRecordingFileSizeMaxInMB (*TVGObject, Value.l)
Prototype   pr_SetRecordingInNativeFormat (*TVGObject, Value.l)
Prototype   pr_SetRecordingMethod (*TVGObject, Value.l)
Prototype   pr_SetRecordingOnMotion_Enabled (*TVGObject, Value.l)
Prototype   pr_SetRecordingOnMotion_MotionThreshold (*TVGObject, Value.d)
Prototype   pr_SetRecordingOnMotion_NoMotionPauseDelayMs (*TVGObject, Value.l)
Prototype   pr_SetRecordingPauseCreatesNewFile (*TVGObject, Value.l)
Prototype   pr_SetRecordingSize (*TVGObject, Value.l)
Prototype   pr_SetRecordingTimer (*TVGObject, Value.l)
Prototype   pr_SetRecordingTimerInterval (*TVGObject, Value.l)
Prototype   pr_SetRecordingVideoBitRate (*TVGObject, Value.l)
Prototype   pr_SetReencodingIncludeAudioStream (*TVGObject, Value.l)
Prototype   pr_SetReencodingIncludeVideoStream (*TVGObject, Value.l)
Prototype   pr_SetReencodingMethod (*TVGObject, Value.l)
Prototype   pr_SetReencodingNewVideoClip (*TVGObject, *Value)
Prototype   pr_SetReencodingSourceVideoClip (*TVGObject, *Value)
Prototype   pr_SetReencodingStartFrame (*TVGObject, Value.q)
Prototype   pr_SetReencodingStartTime (*TVGObject, Value.q)
Prototype   pr_SetReencodingStopFrame (*TVGObject, Value.q)
Prototype   pr_SetReencodingStopTime (*TVGObject, Value.q)
Prototype   pr_SetReencodingUseAudioCompressor (*TVGObject, Value.l)
Prototype   pr_SetReencodingUseFrameGrabber (*TVGObject, Value.l)
Prototype   pr_SetReencodingUseVideoCompressor (*TVGObject, Value.l)
Prototype   pr_SetReencodingWMVOutput (*TVGObject, Value.l)
Prototype   pr_SetScreenRecordingLayeredWindows (*TVGObject, Value.l)
Prototype   pr_SetScreenRecordingMonitor (*TVGObject, Value.l)
Prototype   pr_SetScreenRecordingNonVisibleWindows (*TVGObject, Value.l)
Prototype   pr_SetScreenRecordingSizePercent (*TVGObject, Value.l)
Prototype   pr_SetScreenRecordingThroughClipboard (*TVGObject, Value.l)
Prototype   pr_SetScreenRecordingWithCursor (*TVGObject, Value.l)
Prototype   pr_SetSendToDV_DeviceIndex (*TVGObject, Value.l)
Prototype   pr_SetSpeakerBalance (*TVGObject, Value.l)
Prototype   pr_SetSpeakerControl (*TVGObject, Value.l)
Prototype   pr_SetSpeakerVolume (*TVGObject, Value.l)
Prototype   pr_SetStoragePath (*TVGObject, *Value)
Prototype   pr_SetStoragePathMode (*TVGObject, Value.l)
Prototype   pr_SetStoreDeviceSettingsInRegistry (*TVGObject, Value.l)
Prototype   pr_SetSyncCommands (*TVGObject, Value.l)
Prototype   pr_SetSynchronizationRole (*TVGObject, Value.l)
Prototype   pr_SetSynchronized (*TVGObject, Value.l)
Prototype   pr_SetSyncPreview (*TVGObject, Value.l)
Prototype   pr_SetTextOverlay_Align (*TVGObject, Index.l, Value.l)
Prototype   pr_SetTextOverlay_AlphaBlend (*TVGObject, Index.l, Value.l)
Prototype   pr_SetTextOverlay_AlphaBlendValue (*TVGObject, Index.l, Value.l)
Prototype   pr_SetTextOverlay_BkColor (*TVGObject, Index.l, Value.l)
Prototype   pr_SetTextOverlay_CustomVar (*TVGObject, Index.l, VarIndex.l, *VarText)
Prototype   pr_SetTextOverlay_Enabled (*TVGObject, Index.l, Value.l)
Prototype   pr_SetTextOverlay_Font (*TVGObject, Index.l, *Value)
Prototype   pr_SetTextOverlay_FontColor (*TVGObject, Index.l, Value.l)
Prototype   pr_SetTextOverlay_FontSize (*TVGObject, Index.l, Value.l)
Prototype   pr_SetTextOverlay_GradientColor (*TVGObject, Index.l, Value.l)
Prototype   pr_SetTextOverlay_GradientMode (*TVGObject, Index.l, Value.l)
Prototype   pr_SetTextOverlay_HighResFont (*TVGObject, Index.l, Value.l)
Prototype   pr_SetTextOverlay_Left (*TVGObject, Index.l, Value.l)
Prototype   pr_SetTextOverlay_Orientation (*TVGObject, Index.l, Value.l)
Prototype   pr_SetTextOverlay_Right (*TVGObject, Index.l, Value.l)
Prototype   pr_SetTextOverlay_Scrolling (*TVGObject, Index.l, Value.l)
Prototype   pr_SetTextOverlay_ScrollingSpeed (*TVGObject, Index.l, Value.l)
Prototype   pr_SetTextOverlay_Shadow (*TVGObject, Index.l, Value.l)
Prototype   pr_SetTextOverlay_ShadowColor (*TVGObject, Index.l, Value.l)
Prototype   pr_SetTextOverlay_ShadowDirection (*TVGObject, Index.l, Value.l)
Prototype   pr_SetTextOverlay_String (*TVGObject, Index.l, *Value)
Prototype   pr_SetTextOverlay_TargetDisplay (*TVGObject, Index.l, Value.l)
Prototype   pr_SetTextOverlay_Top (*TVGObject, Index.l, Value.l)
Prototype   pr_SetTextOverlay_Transparent (*TVGObject, Index.l, Value.l)
Prototype   pr_SetTextOverlay_VideoAlignment (*TVGObject, Index.l, Value.l)
Prototype   pr_SetTextOverlayAlign (*TVGObject, Value.l)
Prototype   pr_SetTextOverlayAlphaBlend (*TVGObject, Value.l)
Prototype   pr_SetTextOverlayAlphaBlendValue (*TVGObject, Value.l)
Prototype   pr_SetTextOverlayBkColor (*TVGObject, Value.l)
Prototype   pr_SetTextOverlayEnabled (*TVGObject, Value.l)
Prototype   pr_SetTextOverlayFont (*TVGObject, *Value)
Prototype   pr_SetTextOverlayFontColor (*TVGObject, Value.l)
Prototype   pr_SetTextOverlayFontSize (*TVGObject, Value.l)
Prototype   pr_SetTextOverlayGradientColor (*TVGObject, Value.l)
Prototype   pr_SetTextOverlayGradientMode (*TVGObject, Value.l)
Prototype   pr_SetTextOverlayHighResFont (*TVGObject, Value.l)
Prototype   pr_SetTextOverlayLeft (*TVGObject, Value.l)
Prototype   pr_SetTextOverlayOrientation (*TVGObject, Value.l)
Prototype   pr_SetTextOverlayRight (*TVGObject, Value.l)
Prototype   pr_SetTextOverlayScrolling (*TVGObject, Value.l)
Prototype   pr_SetTextOverlayScrollingSpeed (*TVGObject, Value.l)
Prototype   pr_SetTextOverlaySelector (*TVGObject, Value.l)
Prototype   pr_SetTextOverlayShadow (*TVGObject, Value.l)
Prototype   pr_SetTextOverlayShadowColor (*TVGObject, Value.l)
Prototype   pr_SetTextOverlayShadowDirection (*TVGObject, Value.l)
Prototype   pr_SetTextOverlayString (*TVGObject, *Value)
Prototype   pr_SetTextOverlayTargetDisplay (*TVGObject, Value.l)
Prototype   pr_SetTextOverlayTop (*TVGObject, Value.l)
Prototype   pr_SetTextOverlayTransparent (*TVGObject, Value.l)
Prototype   pr_SetTextOverlayVideoAlignment (*TVGObject, Value.l)
Prototype   pr_SetThirdPartyDeinterlacer (*TVGObject, *Value)
Prototype   pr_SetTranslateMouseCoordinates (*TVGObject, Value.l)
Prototype   pr_SetTunerFrequency (*TVGObject, Value.l)
Prototype   pr_SetTunerMode (*TVGObject, Value.l)
Prototype   pr_SetTVChannel (*TVGObject, Value.l)
Prototype   pr_SetTVCountryCode (*TVGObject, Value.l)
Prototype   pr_SetTVTunerInputType (*TVGObject, Value.l)
Prototype   pr_SetTVUseFrequencyOverrides (*TVGObject, Value.l)
Prototype   pr_SetUseClock (*TVGObject, Value.l)
Prototype   pr_Setv360_AspectRatio (*TVGObject, Value.d)
Prototype   pr_Setv360_Enabled (*TVGObject, Value.l)
Prototype   pr_Setv360_MasterAngle (*TVGObject, Value.l)
Prototype   pr_Setv360_MouseAction (*TVGObject, Value.l)
Prototype   pr_Setv360_MouseActionPercent (*TVGObject, Value.l)
Prototype   pr_SetVCRHorizontalLocking (*TVGObject, Value.l)
Prototype   pr_SetVersion (*TVGObject, *Value)
Prototype   pr_SetVideoCompression_DataRate (*TVGObject, Value.l)
Prototype   pr_SetVideoCompression_KeyFrameRate (*TVGObject, Value.l)
Prototype   pr_SetVideoCompression_PFramesPerKeyFrame (*TVGObject, Value.l)
Prototype   pr_SetVideoCompression_Quality (*TVGObject, Value.d)
Prototype   pr_SetVideoCompression_WindowSize (*TVGObject, Value.l)
Prototype.i pr_SetVideoCompressionDefaults (*TVGObject)
Prototype.i pr_SetVideoCompressionSettings (*TVGObject, DataRate.l, KeyFrameRate.l, PFramesPerKeyFrame.l, WindowSize.l, Quality.d)
Prototype   pr_SetVideoCompressor (*TVGObject, Value.l)
Prototype.i pr_SetVideoControlMode (*TVGObject, FlipHorizontal.l, FlipVertical.l, ExternalTriggerEnable.l, Trigger.l)
Prototype.i pr_SetVideoControlMode2 (*TVGObject, Mode.l, Value.l)
Prototype   pr_SetVideoControlSettings (*TVGObject, Value.l)
Prototype   pr_SetVideoCursor (*TVGObject, Value.l)
Prototype   pr_SetVideoDelay (*TVGObject, Value.q)
Prototype   pr_SetVideoDevice (*TVGObject, Value.l)
Prototype   pr_SetVideoDoubleBuffered (*TVGObject, Value.l)
Prototype   pr_SetVideoFormat (*TVGObject, Value.l)
Prototype   pr_SetVideoFromImages_BitmapsSortedBy (*TVGObject, Value.l)
Prototype   pr_SetVideoFromImages_RepeatIndefinitely (*TVGObject, Value.l)
Prototype   pr_SetVideoFromImages_SourceDirectory (*TVGObject, *Value)
Prototype   pr_SetVideoFromImages_TemporaryFile (*TVGObject, *Value)
Prototype   pr_SetVideoInput (*TVGObject, Value.l)
Prototype   pr_SetVideoProcessingBrightness (*TVGObject, Value.l)
Prototype   pr_SetVideoProcessingContrast (*TVGObject, Value.l)
Prototype   pr_SetVideoProcessingDeinterlacing (*TVGObject, Value.l)
Prototype   pr_SetVideoProcessingFlipHorizontal (*TVGObject, Value.l)
Prototype   pr_SetVideoProcessingFlipVertical (*TVGObject, Value.l)
Prototype   pr_SetVideoProcessingGrayScale (*TVGObject, Value.l)
Prototype   pr_SetVideoProcessingHue (*TVGObject, Value.l)
Prototype   pr_SetVideoProcessingInvertColors (*TVGObject, Value.l)
Prototype   pr_SetVideoProcessingLeftRight (*TVGObject, Value.l)
Prototype   pr_SetVideoProcessingPixellization (*TVGObject, Value.l)
Prototype   pr_SetVideoProcessingRotation (*TVGObject, Value.l)
Prototype   pr_SetVideoProcessingRotationCustomAngle (*TVGObject, Value.d)
Prototype   pr_SetVideoProcessingSaturation (*TVGObject, Value.l)
Prototype   pr_SetVideoProcessingTopDown (*TVGObject, Value.l)
Prototype.i pr_SetVideoQuality (*TVGObject, Setting.l, SetAuto.l, SetDefault.l, SetValue.l)
Prototype   pr_SetVideoQualitySettings (*TVGObject, Value.l)
Prototype   pr_SetVideoRenderer (*TVGObject, Value.l)
Prototype   pr_SetVideoRendererExternal (*TVGObject, Value.l)
Prototype   pr_SetVideoRendererExternalIndex (*TVGObject, Value.l)
Prototype   pr_SetVideoRendererPriority (*TVGObject, Value.l)
Prototype   pr_SetVideoSize (*TVGObject, Value.l)
Prototype   pr_SetVideoSource (*TVGObject, Value.l)
Prototype   pr_SetVideoSource_FileOrURL (*TVGObject, *Value)
Prototype   pr_SetVideoSource_FileOrURL_StartTime (*TVGObject, Value.q)
Prototype   pr_SetVideoSource_FileOrURL_StopTime (*TVGObject, Value.q)
Prototype   pr_SetVideoStreamNumber (*TVGObject, Value.l)
Prototype   pr_SetVideoSubtype (*TVGObject, Value.l)
Prototype   pr_SetVideoVisibleWhenStopped (*TVGObject, Value.l)
Prototype   pr_SetVirtualAudioStreamControl (*TVGObject, Value.l)
Prototype   pr_SetVirtualVideoStreamControl (*TVGObject, Value.l)
Prototype.i pr_SetVMR9ImageAdjustmentValue (*TVGObject, MainDisplay.l, VMR9ControlSetting.l, Value.l, FixRange.l)
Prototype   pr_SetVuMeter (*TVGObject, Value.l)
Prototype   pr_SetVuMeter_Enabled (*TVGObject, Index.l, Value.l)
Prototype   pr_SetVUMeterSetting (*TVGObject, ChannelIndex.l, VUMeterSetting.l, *Value)
Prototype   pr_SetWebcamStillCaptureButton (*TVGObject, Value.l)
Prototype.i pr_SetWindowRecordingByHandle (*TVGObject, Window_Handle.l)
Prototype.i pr_SetWindowRecordingByName (*TVGObject, *WindowName, ExactMatch.l)
Prototype.i pr_SetWindowTransparency (*TVGObject, WndHandle.l, UseColorKey.l, UseAlpha.l, AlphaValue.l)
Prototype   pr_SetZoomCoeff (*TVGObject, Value.l)
Prototype   pr_SetZoomXCenter (*TVGObject, Value.l)
Prototype   pr_SetZoomYCenter (*TVGObject, Value.l)
Prototype   pr_ShowDebugWindow (*TVGObject)
Prototype.i pr_ShowDialog (*TVGObject, Dialog.l)
Prototype.i pr_StartAudioRecording (*TVGObject)
Prototype.i pr_StartAudioRendering (*TVGObject)
Prototype.i pr_StartPreview (*TVGObject)
Prototype.i pr_StartPTZ (*TVGObject)
Prototype.i pr_StartRecording (*TVGObject)
Prototype.i pr_StartReencoding (*TVGObject)
Prototype.i pr_StartSynchronized (*TVGObject)
Prototype.i pr_Stop (*TVGObject)
Prototype   pr_StopPlayer (*TVGObject)
Prototype   pr_StopPreview (*TVGObject)
Prototype   pr_StopRecording (*TVGObject)
Prototype.i pr_StopReencoding (*TVGObject)
Prototype.i pr_TextOverlay_CreateCustomFont (*TVGObject, Index.l, fHeight.l, fWidth.l, fEscapement.l, fOrientation.l, fWeight.l, fItalic.l, fUnderline.l, fStrikeOut.l, fCharSet.l, fOutputPrecision.l, fClipPrecision.l, fQuality.l, fPitchAndFamily.l, *FontFacename)
Prototype.i pr_ThirdPartyFilter_AddToList (*TVGObject, Location.l, *GUIDString, *OptionalDLLFilePath, *FilterName, Enable.l, CanSaveFilterState.l)
Prototype.i pr_ThirdPartyFilter_ClearList (*TVGObject)
Prototype.i pr_ThirdPartyFilter_Enable (*TVGObject, Location.l, *GUIDString, Enable.l)
Prototype.i pr_ThirdPartyFilter_RemoveFromList (*TVGObject, Location.l, *GUIDString)
Prototype.i pr_ThirdPartyFilter_ShowDialog (*TVGObject, Location.l, *GUIDString)
Prototype.i pr_TVClearFrequencyOverrides (*TVGObject)
Prototype.i pr_TVGetMinMaxChannels (*TVGObject, *MinChannel, *MaxChannel)
Prototype.i pr_TVSetChannelFrequencyOverride (*TVGObject, TVChannel.l, FrequencyInHz.l)
Prototype.i pr_TVStartAutoScan (*TVGObject)
Prototype.i pr_TVStartAutoScanChannels (*TVGObject, MinChannel.l, MaxChannel.l, Interval_ms.l)
Prototype.i pr_TVStopAutoScan (*TVGObject)
Prototype   pr_UpdateTrackbarBounds (*TVGObject)
Prototype   pr_UseNearestVideoSize (*TVGObject, PreferredWidth.l, PreferredHeight.l, Stretch.l)
Prototype.i pr_v360_AddYawPitchRoll (*TVGObject, Yaw.d, Pitch.d, Roll.d)
Prototype.d pr_v360_GetAngle (*TVGObject, Direction.l, Angle.l)
Prototype   pr_v360_GetYawPitchRoll (*TVGObject, *Yaw, *Pitch, *Roll)
Prototype   pr_v360_ResetAnglesToDefault (*TVGObject)
Prototype.i pr_v360_SetAngle (*TVGObject, Direction.l, Angle.l, Value.d)
Prototype.i pr_v360_SetInterpolation (*TVGObject, Value.l)
Prototype.i pr_v360_SetProjection (*TVGObject, Direction.l, Value.l)
Prototype.i pr_v360_SetStereoFormat (*TVGObject, Direction.l, Value.l)
Prototype.i pr_v360_SetTranspose (*TVGObject, Direction.l, Value.l)
Prototype.i pr_v360_SetYawPitchRoll (*TVGObject, Yaw.d, Pitch.d, Roll.d)
Prototype.i pr_VDECGetHorizontalLocked (*TVGObject, *plLocked)
Prototype.i pr_VDECGetNumberOfLines (*TVGObject, *plNumberOfLines)
Prototype.i pr_VDECGetOutputEnable (*TVGObject, *plOutputEnable)
Prototype.i pr_VDECGetVCRHorizontalLocking (*TVGObject, *plVCRHorizontalLocking)
Prototype.i pr_VDECPutOutputEnable (*TVGObject, lOutputEnable.l)
Prototype.i pr_VDECPutTVFormat (*TVGObject, lAnalogVideoStandard.l)
Prototype.i pr_VDECPutVCRHorizontalLocking (*TVGObject, lVCRHorizontalLocking.l)
Prototype.i pr_VideoCompressorIndex (*TVGObject, *Value)
Prototype.i pr_VideoDeviceIndex (*TVGObject, *Value)
Prototype.i pr_VideoDeviceIndexFromId (*TVGObject, *Value)
Prototype.i pr_VideoFromImages_CreateSetOfBitmaps (*TVGObject)
Prototype.i pr_VideoInputIndex (*TVGObject, *Value)
Prototype.i pr_VideoQualityAuto (*TVGObject, Setting.l)
Prototype.i pr_VideoQualityDefault (*TVGObject, Setting.l)
Prototype.i pr_VideoQualityMax (*TVGObject, Setting.l)
Prototype.i pr_VideoQualityMin (*TVGObject, Setting.l)
Prototype.i pr_VideoQualityStep (*TVGObject, Setting.l)
Prototype.i pr_VideoQualityValue (*TVGObject, Setting.l)
Prototype.i pr_VideoSizeIndex (*TVGObject, *Value)
Prototype.i pr_VideoSubtypeIndex (*TVGObject, *Value)
Prototype.i pr_WriteScriptCommand (*TVGObject, *ScriptType, *ScriptArgument)
Prototype.i pr_zReservedInternal1 (*TVGObject, *Param1, *Param2)
Prototype.i pr_zReservedInternal2 (*TVGObject, Param1.l)
Prototype.i pr_zReservedInternal3 (*TVGObject)
Prototype.i pr_zReservedInternal4 (*TVGObject, *Param1, *Param2)

Procedure openTVGLibrary()
  Protected sLibName.s = #SCS_TVG_DLL
  Protected bResult

  If gnTVGLibrary
    ProcedureReturn gbTVGAvailable
  EndIf
  
  gnTVGLibrary = OpenLibrary(#PB_Any, sLibName)
  Debug "openTVGLibrary: sLibName=" + sLibName
  Debug "openTVGLibrary: gnTVGLibrary=" + gnTVGLibrary
  If gnTVGLibrary
    ; nb library must stay open until end of run or functions will fail
    bResult = #True

    ;- GetFunctions
    Global TVG_About.pr_About                                                                                                 = GetFunction(gnTVGLibrary, "_About")
    Global TVG_AnalogVideoStandardIndex.pr_AnalogVideoStandardIndex                                                           = GetFunction(gnTVGLibrary, "_AnalogVideoStandardIndex")
    Global TVG_ASFStreaming_GetAuthorizationList.pr_ASFStreaming_GetAuthorizationList                                         = GetFunction(gnTVGLibrary, "_ASFStreaming_GetAuthorizationList")
    Global TVG_ASFStreaming_GetConnectedClients.pr_ASFStreaming_GetConnectedClients                                           = GetFunction(gnTVGLibrary, "_ASFStreaming_GetConnectedClients")
    Global TVG_ASFStreaming_GetConnectedClientsCount.pr_ASFStreaming_GetConnectedClientsCount                                 = GetFunction(gnTVGLibrary, "_ASFStreaming_GetConnectedClientsCount")
    Global TVG_ASFStreaming_ResetAuthorizations.pr_ASFStreaming_ResetAuthorizations                                           = GetFunction(gnTVGLibrary, "_ASFStreaming_ResetAuthorizations")
    Global TVG_ASFStreaming_SetAuthorization.pr_ASFStreaming_SetAuthorization                                                 = GetFunction(gnTVGLibrary, "_ASFStreaming_SetAuthorization")
    Global TVG_AssociateMultiplexedSlave.pr_AssociateMultiplexedSlave                                                         = GetFunction(gnTVGLibrary, "_AssociateMultiplexedSlave")
    Global TVG_AudioCompressorIndex.pr_AudioCompressorIndex                                                                   = GetFunction(gnTVGLibrary, "_AudioCompressorIndex")
    Global TVG_AudioDeviceIndex.pr_AudioDeviceIndex                                                                           = GetFunction(gnTVGLibrary, "_AudioDeviceIndex")
    Global TVG_AudioInputIndex.pr_AudioInputIndex                                                                             = GetFunction(gnTVGLibrary, "_AudioInputIndex")
    Global TVG_AudioRendererIndex.pr_AudioRendererIndex                                                                       = GetFunction(gnTVGLibrary, "_AudioRendererIndex")
    Global TVG_AVIDuration.pr_AVIDuration                                                                                     = GetFunction(gnTVGLibrary, "_AVIDuration")
    Global TVG_AVIHeaderInfo.pr_AVIHeaderInfo                                                                                 = GetFunction(gnTVGLibrary, "_AVIHeaderInfo")
    Global TVG_AVIInfo.pr_AVIInfo                                                                                             = GetFunction(gnTVGLibrary, "_AVIInfo")
    Global TVG_AVIInfo2.pr_AVIInfo2                                                                                           = GetFunction(gnTVGLibrary, "_AVIInfo2")
    Global TVG_CameraControlAuto.pr_CameraControlAuto                                                                         = GetFunction(gnTVGLibrary, "_CameraControlAuto")
    Global TVG_CameraControlDefault.pr_CameraControlDefault                                                                   = GetFunction(gnTVGLibrary, "_CameraControlDefault")
    Global TVG_CameraControlMax.pr_CameraControlMax                                                                           = GetFunction(gnTVGLibrary, "_CameraControlMax")
    Global TVG_CameraControlMin.pr_CameraControlMin                                                                           = GetFunction(gnTVGLibrary, "_CameraControlMin")
    Global TVG_CameraControlStep.pr_CameraControlStep                                                                         = GetFunction(gnTVGLibrary, "_CameraControlStep")
    Global TVG_CameraControlValue.pr_CameraControlValue                                                                       = GetFunction(gnTVGLibrary, "_CameraControlValue")
    Global TVG_Cancel.pr_Cancel                                                                                               = GetFunction(gnTVGLibrary, "_Cancel")
    Global TVG_CanProcessMessages.pr_CanProcessMessages                                                                       = GetFunction(gnTVGLibrary, "_CanProcessMessages")
    Global TVG_CaptureFrameSyncTo.pr_CaptureFrameSyncTo                                                                       = GetFunction(gnTVGLibrary, "_CaptureFrameSyncTo")
    Global TVG_CaptureFrameTo.pr_CaptureFrameTo                                                                               = GetFunction(gnTVGLibrary, "_CaptureFrameTo")
    Global TVG_ClearHeaderAttributes.pr_ClearHeaderAttributes                                                                 = GetFunction(gnTVGLibrary, "_ClearHeaderAttributes")
    Global TVG_ClosePlayer.pr_ClosePlayer                                                                                     = GetFunction(gnTVGLibrary, "_ClosePlayer")
    Global TVG_ContinueProcessing.pr_ContinueProcessing                                                                       = GetFunction(gnTVGLibrary, "_ContinueProcessing")
    Global TVG_CreatePreallocCapFile.pr_CreatePreallocCapFile                                                                 = GetFunction(gnTVGLibrary, "_CreatePreallocCapFile")
    Global TVG_CreateVideoGrabber.pr_CreateVideoGrabber                                                                       = GetFunction(gnTVGLibrary, "_CreateVideoGrabber")
    Global TVG_DestroyVideoGrabber.pr_DestroyVideoGrabber                                                                     = GetFunction(gnTVGLibrary, "_DestroyVideoGrabber")
    Global TVG_Display_SetLocation.pr_Display_SetLocation                                                                     = GetFunction(gnTVGLibrary, "_Display_SetLocation")
    Global TVG_DrawBitmapOverFrame.pr_DrawBitmapOverFrame                                                                     = GetFunction(gnTVGLibrary, "_DrawBitmapOverFrame")
    Global TVG_DualDisplay_SetLocation.pr_DualDisplay_SetLocation                                                             = GetFunction(gnTVGLibrary, "_DualDisplay_SetLocation")
    Global TVG_DVDInfo.pr_DVDInfo                                                                                             = GetFunction(gnTVGLibrary, "_DVDInfo")
    Global TVG_EnableMultiplexedInput.pr_EnableMultiplexedInput                                                               = GetFunction(gnTVGLibrary, "_EnableMultiplexedInput")
    Global TVG_EnableMultipurposeEncoder.pr_EnableMultipurposeEncoder                                                         = GetFunction(gnTVGLibrary, "_EnableMultipurposeEncoder")
    Global TVG_EnableThreadMode.pr_EnableThreadMode                                                                           = GetFunction(gnTVGLibrary, "_EnableThreadMode")
    Global TVG_EnumerateWindows.pr_EnumerateWindows                                                                           = GetFunction(gnTVGLibrary, "_EnumerateWindows")
    Global TVG_FastForwardPlayer.pr_FastForwardPlayer                                                                         = GetFunction(gnTVGLibrary, "_FastForwardPlayer")
    Global TVG_FindIndexInListByName.pr_FindIndexInListByName                                                                 = GetFunction(gnTVGLibrary, "_FindIndexInListByName")
    Global TVG_GetAdjustOverlayAspectRatio.pr_GetAdjustOverlayAspectRatio                                                     = GetFunction(gnTVGLibrary, "_GetAdjustOverlayAspectRatio")
    Global TVG_GetAdjustPixelAspectRatio.pr_GetAdjustPixelAspectRatio                                                         = GetFunction(gnTVGLibrary, "_GetAdjustPixelAspectRatio")
    Global TVG_GetAero.pr_GetAero                                                                                             = GetFunction(gnTVGLibrary, "_GetAero")
    Global TVG_GetAnalogVideoStandard.pr_GetAnalogVideoStandard                                                               = GetFunction(gnTVGLibrary, "_GetAnalogVideoStandard")
    Global TVG_GetAnalogVideoStandards.pr_GetAnalogVideoStandards                                                             = GetFunction(gnTVGLibrary, "_GetAnalogVideoStandards")
    Global TVG_GetAnalogVideoStandardsCount.pr_GetAnalogVideoStandardsCount                                                   = GetFunction(gnTVGLibrary, "_GetAnalogVideoStandardsCount")
    Global TVG_GetApplicationPriority.pr_GetApplicationPriority                                                               = GetFunction(gnTVGLibrary, "_GetApplicationPriority")
    Global TVG_GetASFAudioBitRate.pr_GetASFAudioBitRate                                                                       = GetFunction(gnTVGLibrary, "_GetASFAudioBitRate")
    Global TVG_GetASFAudioChannels.pr_GetASFAudioChannels                                                                     = GetFunction(gnTVGLibrary, "_GetASFAudioChannels")
    Global TVG_GetASFBufferWindow.pr_GetASFBufferWindow                                                                       = GetFunction(gnTVGLibrary, "_GetASFBufferWindow")
    Global TVG_GetASFDeinterlaceMode.pr_GetASFDeinterlaceMode                                                                 = GetFunction(gnTVGLibrary, "_GetASFDeinterlaceMode")
    Global TVG_GetASFDirectStreamingKeepClientsConnected.pr_GetASFDirectStreamingKeepClientsConnected                         = GetFunction(gnTVGLibrary, "_GetASFDirectStreamingKeepClientsConnected")
    Global TVG_GetASFFixedFrameRate.pr_GetASFFixedFrameRate                                                                   = GetFunction(gnTVGLibrary, "_GetASFFixedFrameRate")
    Global TVG_GetASFMediaServerPublishingPoint.pr_GetASFMediaServerPublishingPoint                                           = GetFunction(gnTVGLibrary, "_GetASFMediaServerPublishingPoint")
    Global TVG_GetASFMediaServerRemovePublishingPointAfterDisconnect.pr_GetASFMediaServerRemovePublishingPointAfterDisconnect = GetFunction(gnTVGLibrary, "_GetASFMediaServerRemovePublishingPointAfterDisconnect")
    Global TVG_GetASFMediaServerTemplatePublishingPoint.pr_GetASFMediaServerTemplatePublishingPoint                           = GetFunction(gnTVGLibrary, "_GetASFMediaServerTemplatePublishingPoint")
    Global TVG_GetASFNetworkMaxUsers.pr_GetASFNetworkMaxUsers                                                                 = GetFunction(gnTVGLibrary, "_GetASFNetworkMaxUsers")
    Global TVG_GetASFNetworkPort.pr_GetASFNetworkPort                                                                         = GetFunction(gnTVGLibrary, "_GetASFNetworkPort")
    Global TVG_GetASFProfile.pr_GetASFProfile                                                                                 = GetFunction(gnTVGLibrary, "_GetASFProfile")
    Global TVG_GetASFProfileFromCustomFile.pr_GetASFProfileFromCustomFile                                                     = GetFunction(gnTVGLibrary, "_GetASFProfileFromCustomFile")
    Global TVG_GetASFProfiles.pr_GetASFProfiles                                                                               = GetFunction(gnTVGLibrary, "_GetASFProfiles")
    Global TVG_GetASFProfilesCount.pr_GetASFProfilesCount                                                                     = GetFunction(gnTVGLibrary, "_GetASFProfilesCount")
    Global TVG_GetASFProfileVersion.pr_GetASFProfileVersion                                                                   = GetFunction(gnTVGLibrary, "_GetASFProfileVersion")
    Global TVG_GetASFVideoBitRate.pr_GetASFVideoBitRate                                                                       = GetFunction(gnTVGLibrary, "_GetASFVideoBitRate")
    Global TVG_GetASFVideoFrameRate.pr_GetASFVideoFrameRate                                                                   = GetFunction(gnTVGLibrary, "_GetASFVideoFrameRate")
    Global TVG_GetASFVideoHeight.pr_GetASFVideoHeight                                                                         = GetFunction(gnTVGLibrary, "_GetASFVideoHeight")
    Global TVG_GetASFVideoMaxKeyFrameSpacing.pr_GetASFVideoMaxKeyFrameSpacing                                                 = GetFunction(gnTVGLibrary, "_GetASFVideoMaxKeyFrameSpacing")
    Global TVG_GetASFVideoQuality.pr_GetASFVideoQuality                                                                       = GetFunction(gnTVGLibrary, "_GetASFVideoQuality")
    Global TVG_GetASFVideoWidth.pr_GetASFVideoWidth                                                                           = GetFunction(gnTVGLibrary, "_GetASFVideoWidth")
    Global TVG_GetAspectRatioToUse.pr_GetAspectRatioToUse                                                                     = GetFunction(gnTVGLibrary, "_GetAspectRatioToUse")
    Global TVG_GetAssociateAudioAndVideoDevices.pr_GetAssociateAudioAndVideoDevices                                           = GetFunction(gnTVGLibrary, "_GetAssociateAudioAndVideoDevices")
    Global TVG_GetAudioBalance.pr_GetAudioBalance                                                                             = GetFunction(gnTVGLibrary, "_GetAudioBalance")
    Global TVG_GetAudioChannelRenderMode.pr_GetAudioChannelRenderMode                                                         = GetFunction(gnTVGLibrary, "_GetAudioChannelRenderMode")
    Global TVG_GetAudioCodec.pr_GetAudioCodec                                                                                 = GetFunction(gnTVGLibrary, "_GetAudioCodec")
    Global TVG_GetAudioCompressor.pr_GetAudioCompressor                                                                       = GetFunction(gnTVGLibrary, "_GetAudioCompressor")
    Global TVG_GetAudioCompressorName.pr_GetAudioCompressorName                                                               = GetFunction(gnTVGLibrary, "_GetAudioCompressorName")
    Global TVG_GetAudioCompressors.pr_GetAudioCompressors                                                                     = GetFunction(gnTVGLibrary, "_GetAudioCompressors")
    Global TVG_GetAudioCompressorsCount.pr_GetAudioCompressorsCount                                                           = GetFunction(gnTVGLibrary, "_GetAudioCompressorsCount")
    Global TVG_GetAudioDevice.pr_GetAudioDevice                                                                               = GetFunction(gnTVGLibrary, "_GetAudioDevice")
    Global TVG_GetAudioDeviceName.pr_GetAudioDeviceName                                                                       = GetFunction(gnTVGLibrary, "_GetAudioDeviceName")
    Global TVG_GetAudioDeviceRendering.pr_GetAudioDeviceRendering                                                             = GetFunction(gnTVGLibrary, "_GetAudioDeviceRendering")
    Global TVG_GetAudioDevices.pr_GetAudioDevices                                                                             = GetFunction(gnTVGLibrary, "_GetAudioDevices")
    Global TVG_GetAudioDevicesCount.pr_GetAudioDevicesCount                                                                   = GetFunction(gnTVGLibrary, "_GetAudioDevicesCount")
    Global TVG_GetAudioFormat.pr_GetAudioFormat                                                                               = GetFunction(gnTVGLibrary, "_GetAudioFormat")
    Global TVG_GetAudioFormats.pr_GetAudioFormats                                                                             = GetFunction(gnTVGLibrary, "_GetAudioFormats")
    Global TVG_GetAudioInput.pr_GetAudioInput                                                                                 = GetFunction(gnTVGLibrary, "_GetAudioInput")
    Global TVG_GetAudioInputBalance.pr_GetAudioInputBalance                                                                   = GetFunction(gnTVGLibrary, "_GetAudioInputBalance")
    Global TVG_GetAudioInputLevel.pr_GetAudioInputLevel                                                                       = GetFunction(gnTVGLibrary, "_GetAudioInputLevel")
    Global TVG_GetAudioInputMono.pr_GetAudioInputMono                                                                         = GetFunction(gnTVGLibrary, "_GetAudioInputMono")
    Global TVG_GetAudioInputs.pr_GetAudioInputs                                                                               = GetFunction(gnTVGLibrary, "_GetAudioInputs")
    Global TVG_GetAudioInputsCount.pr_GetAudioInputsCount                                                                     = GetFunction(gnTVGLibrary, "_GetAudioInputsCount")
    Global TVG_GetAudioPeakEvent.pr_GetAudioPeakEvent                                                                         = GetFunction(gnTVGLibrary, "_GetAudioPeakEvent")
    Global TVG_GetAudioRecording.pr_GetAudioRecording                                                                         = GetFunction(gnTVGLibrary, "_GetAudioRecording")
    Global TVG_GetAudioRenderer.pr_GetAudioRenderer                                                                           = GetFunction(gnTVGLibrary, "_GetAudioRenderer")
    Global TVG_GetAudioRendererName.pr_GetAudioRendererName                                                                   = GetFunction(gnTVGLibrary, "_GetAudioRendererName")
    Global TVG_GetAudioRenderers.pr_GetAudioRenderers                                                                         = GetFunction(gnTVGLibrary, "_GetAudioRenderers")
    Global TVG_GetAudioRenderersCount.pr_GetAudioRenderersCount                                                               = GetFunction(gnTVGLibrary, "_GetAudioRenderersCount")
    Global TVG_GetAudioSource.pr_GetAudioSource                                                                               = GetFunction(gnTVGLibrary, "_GetAudioSource")
    Global TVG_GetAudioStreamNumber.pr_GetAudioStreamNumber                                                                   = GetFunction(gnTVGLibrary, "_GetAudioStreamNumber")
    Global TVG_GetAudioSyncAdjustment.pr_GetAudioSyncAdjustment                                                               = GetFunction(gnTVGLibrary, "_GetAudioSyncAdjustment")
    Global TVG_GetAudioSyncAdjustmentEnabled.pr_GetAudioSyncAdjustmentEnabled                                                 = GetFunction(gnTVGLibrary, "_GetAudioSyncAdjustmentEnabled")
    Global TVG_GetAudioVolume.pr_GetAudioVolume                                                                               = GetFunction(gnTVGLibrary, "_GetAudioVolume")
    Global TVG_GetAudioVolumeEnabled.pr_GetAudioVolumeEnabled                                                                 = GetFunction(gnTVGLibrary, "_GetAudioVolumeEnabled")
    Global TVG_GetAutoConnectRelatedPins.pr_GetAutoConnectRelatedPins                                                         = GetFunction(gnTVGLibrary, "_GetAutoConnectRelatedPins")
    Global TVG_GetAutoFileName.pr_GetAutoFileName                                                                             = GetFunction(gnTVGLibrary, "_GetAutoFileName")
    Global TVG_GetAutoFileNameDateTimeFormat.pr_GetAutoFileNameDateTimeFormat                                                 = GetFunction(gnTVGLibrary, "_GetAutoFileNameDateTimeFormat")
    Global TVG_GetAutoFileNameMinDigits.pr_GetAutoFileNameMinDigits                                                           = GetFunction(gnTVGLibrary, "_GetAutoFileNameMinDigits")
    Global TVG_GetAutoFilePrefix.pr_GetAutoFilePrefix                                                                         = GetFunction(gnTVGLibrary, "_GetAutoFilePrefix")
    Global TVG_GetAutoFileSuffix.pr_GetAutoFilePrefix                                                                         = GetFunction(gnTVGLibrary, "_GetAutoFileSuffix")
    Global TVG_GetAutoRefreshPreview.pr_GetAutoRefreshPreview                                                                 = GetFunction(gnTVGLibrary, "_GetAutoRefreshPreview")
    Global TVG_GetAutoStartPlayer.pr_GetAutoStartPlayer                                                                       = GetFunction(gnTVGLibrary, "_GetAutoStartPlayer")
    Global TVG_GetAVIDurationUpdated.pr_GetAVIDurationUpdated                                                                 = GetFunction(gnTVGLibrary, "_GetAVIDurationUpdated")
    Global TVG_GetAVIFormatOpenDML.pr_GetAVIFormatOpenDML                                                                     = GetFunction(gnTVGLibrary, "_GetAVIFormatOpenDML")
    Global TVG_GetAVIFormatOpenDMLCompatibilityIndex.pr_GetAVIFormatOpenDMLCompatibilityIndex                                 = GetFunction(gnTVGLibrary, "_GetAVIFormatOpenDMLCompatibilityIndex")
    Global TVG_GetBackgroundColor.pr_GetBackgroundColor                                                                       = GetFunction(gnTVGLibrary, "_GetBackgroundColor")
    Global TVG_GetBufferCount.pr_GetBufferCount                                                                               = GetFunction(gnTVGLibrary, "_GetBufferCount")
    Global TVG_GetBurstCount.pr_GetBurstCount                                                                                 = GetFunction(gnTVGLibrary, "_GetBurstCount")
    Global TVG_GetBurstInterval.pr_GetBurstInterval                                                                           = GetFunction(gnTVGLibrary, "_GetBurstInterval")
    Global TVG_GetBurstMode.pr_GetBurstMode                                                                                   = GetFunction(gnTVGLibrary, "_GetBurstMode")
    Global TVG_GetBurstType.pr_GetBurstType                                                                                   = GetFunction(gnTVGLibrary, "_GetBurstType")
    Global TVG_GetBusy.pr_GetBusy                                                                                             = GetFunction(gnTVGLibrary, "_GetBusy")
    Global TVG_GetBusyCursor.pr_GetBusyCursor                                                                                 = GetFunction(gnTVGLibrary, "_GetBusyCursor")
    Global TVG_GetCameraControlSettings.pr_GetCameraControlSettings                                                           = GetFunction(gnTVGLibrary, "_GetCameraControlSettings")
    Global TVG_GetCameraExposure.pr_GetCameraExposure                                                                         = GetFunction(gnTVGLibrary, "_GetCameraExposure")
    Global TVG_GetCameraExposureAsString.pr_GetCameraExposureAsString                                                         = GetFunction(gnTVGLibrary, "_GetCameraExposureAsString")
    Global TVG_GetCaptureFileExt.pr_GetCaptureFileExt                                                                         = GetFunction(gnTVGLibrary, "_GetCaptureFileExt")
    Global TVG_GetColorKey.pr_GetColorKey                                                                                     = GetFunction(gnTVGLibrary, "_GetColorKey")
    Global TVG_GetColorKeyEnabled.pr_GetColorKeyEnabled                                                                       = GetFunction(gnTVGLibrary, "_GetColorKeyEnabled")
    Global TVG_GetCompressionMode.pr_GetCompressionMode                                                                       = GetFunction(gnTVGLibrary, "_GetCompressionMode")
    Global TVG_GetCompressionType.pr_GetCompressionType                                                                       = GetFunction(gnTVGLibrary, "_GetCompressionType")
    Global TVG_GetCropping_Enabled.pr_GetCropping_Enabled                                                                     = GetFunction(gnTVGLibrary, "_GetCropping_Enabled")
    Global TVG_GetCropping_Height.pr_GetCropping_Height                                                                       = GetFunction(gnTVGLibrary, "_GetCropping_Height")
    Global TVG_GetCropping_Outbounds.pr_GetCropping_Outbounds                                                                 = GetFunction(gnTVGLibrary, "_GetCropping_Outbounds")
    Global TVG_GetCropping_Width.pr_GetCropping_Width                                                                         = GetFunction(gnTVGLibrary, "_GetCropping_Width")
    Global TVG_GetCropping_X.pr_GetCropping_X                                                                                 = GetFunction(gnTVGLibrary, "_GetCropping_X")
    Global TVG_GetCropping_XMax.pr_GetCropping_XMax                                                                           = GetFunction(gnTVGLibrary, "_GetCropping_XMax")
    Global TVG_GetCropping_Y.pr_GetCropping_Y                                                                                 = GetFunction(gnTVGLibrary, "_GetCropping_Y")
    Global TVG_GetCropping_YMax.pr_GetCropping_YMax                                                                           = GetFunction(gnTVGLibrary, "_GetCropping_YMax")
    Global TVG_GetCropping_Zoom.pr_GetCropping_Zoom                                                                           = GetFunction(gnTVGLibrary, "_GetCropping_Zoom")
    Global TVG_GetCurrentFrameRate.pr_GetCurrentFrameRate                                                                     = GetFunction(gnTVGLibrary, "_GetCurrentFrameRate")
    Global TVG_GetCurrentState.pr_GetCurrentState                                                                             = GetFunction(gnTVGLibrary, "_GetCurrentState")
    Global TVG_GetDeliveredFrames.pr_GetDeliveredFrames                                                                       = GetFunction(gnTVGLibrary, "_GetDeliveredFrames")
    Global TVG_GetDirectShowFilters.pr_GetDirectShowFilters                                                                   = GetFunction(gnTVGLibrary, "_GetDirectShowFilters")
    Global TVG_GetDirectShowFiltersCount.pr_GetDirectShowFiltersCount                                                         = GetFunction(gnTVGLibrary, "_GetDirectShowFiltersCount")
    Global TVG_GetDisplayActive.pr_GetDisplayActive                                                                           = GetFunction(gnTVGLibrary, "_GetDisplayActive")
    Global TVG_GetDisplayAlphaBlendEnabled.pr_GetDisplayAlphaBlendEnabled                                                     = GetFunction(gnTVGLibrary, "_GetDisplayAlphaBlendEnabled")
    Global TVG_GetDisplayAlphaBlendValue.pr_GetDisplayAlphaBlendValue                                                         = GetFunction(gnTVGLibrary, "_GetDisplayAlphaBlendValue")
    Global TVG_GetDisplayAspectRatio.pr_GetDisplayAspectRatio                                                                 = GetFunction(gnTVGLibrary, "_GetDisplayAspectRatio")
    Global TVG_GetDisplayAutoSize.pr_GetDisplayAutoSize                                                                       = GetFunction(gnTVGLibrary, "_GetDisplayAutoSize")
    Global TVG_GetDisplayEmbedded.pr_GetDisplayEmbedded                                                                       = GetFunction(gnTVGLibrary, "_GetDisplayEmbedded")
    Global TVG_GetDisplayEmbedded_FitParent.pr_GetDisplayEmbedded_FitParent                                                   = GetFunction(gnTVGLibrary, "_GetDisplayEmbedded_FitParent")
    Global TVG_GetDisplayFullScreen.pr_GetDisplayFullScreen                                                                   = GetFunction(gnTVGLibrary, "_GetDisplayFullScreen")
    Global TVG_GetDisplayHeight.pr_GetDisplayHeight                                                                           = GetFunction(gnTVGLibrary, "_GetDisplayHeight")
    Global TVG_GetDisplayLeft.pr_GetDisplayLeft                                                                               = GetFunction(gnTVGLibrary, "_GetDisplayLeft")
    Global TVG_GetDisplayMonitor.pr_GetDisplayMonitor                                                                         = GetFunction(gnTVGLibrary, "_GetDisplayMonitor")
    Global TVG_GetDisplayMouseMovesWindow.pr_GetDisplayMouseMovesWindow                                                       = GetFunction(gnTVGLibrary, "_GetDisplayMouseMovesWindow")
    Global TVG_GetDisplayPanScanRatio.pr_GetDisplayPanScanRatio                                                               = GetFunction(gnTVGLibrary, "_GetDisplayPanScanRatio")
    Global TVG_GetDisplayStayOnTop.pr_GetDisplayStayOnTop                                                                     = GetFunction(gnTVGLibrary, "_GetDisplayStayOnTop")
    Global TVG_GetDisplayTop.pr_GetDisplayTop                                                                                 = GetFunction(gnTVGLibrary, "_GetDisplayTop")
    Global TVG_GetDisplayTransparentColorEnabled.pr_GetDisplayTransparentColorEnabled                                         = GetFunction(gnTVGLibrary, "_GetDisplayTransparentColorEnabled")
    Global TVG_GetDisplayTransparentColorValue.pr_GetDisplayTransparentColorValue                                             = GetFunction(gnTVGLibrary, "_GetDisplayTransparentColorValue")
    Global TVG_GetDisplayVideoHeight.pr_GetDisplayVideoHeight                                                                 = GetFunction(gnTVGLibrary, "_GetDisplayVideoHeight")
    Global TVG_GetDisplayVideoPortEnabled.pr_GetDisplayVideoPortEnabled                                                       = GetFunction(gnTVGLibrary, "_GetDisplayVideoPortEnabled")
    Global TVG_GetDisplayVideoWidth.pr_GetDisplayVideoWidth                                                                   = GetFunction(gnTVGLibrary, "_GetDisplayVideoWidth")
    Global TVG_GetDisplayVideoWindowHandle.pr_GetDisplayVideoWindowHandle                                                     = GetFunction(gnTVGLibrary, "_GetDisplayVideoWindowHandle")
    Global TVG_GetDisplayVisible.pr_GetDisplayVisible                                                                         = GetFunction(gnTVGLibrary, "_GetDisplayVisible")
    Global TVG_GetDisplayWidth.pr_GetDisplayWidth                                                                             = GetFunction(gnTVGLibrary, "_GetDisplayWidth")
    Global TVG_GetDroppedFrameCount.pr_GetDroppedFrameCount                                                                   = GetFunction(gnTVGLibrary, "_GetDroppedFrameCount")
    Global TVG_GetDroppedFramesPollingInterval.pr_GetDroppedFramesPollingInterval                                             = GetFunction(gnTVGLibrary, "_GetDroppedFramesPollingInterval")
    Global TVG_GetDVDateTimeEnabled.pr_GetDVDateTimeEnabled                                                                   = GetFunction(gnTVGLibrary, "_GetDVDateTimeEnabled")
    Global TVG_GetDVDiscontinuityMinimumInterval.pr_GetDVDiscontinuityMinimumInterval                                         = GetFunction(gnTVGLibrary, "_GetDVDiscontinuityMinimumInterval")
    Global TVG_GetDVDTitle.pr_GetDVDTitle                                                                                     = GetFunction(gnTVGLibrary, "_GetDVDTitle")
    Global TVG_GetDVEncoder_VideoFormat.pr_GetDVEncoder_VideoFormat                                                           = GetFunction(gnTVGLibrary, "_GetDVEncoder_VideoFormat")
    Global TVG_GetDVEncoder_VideoResolution.pr_GetDVEncoder_VideoResolution                                                   = GetFunction(gnTVGLibrary, "_GetDVEncoder_VideoResolution")
    Global TVG_GetDVEncoder_VideoStandard.pr_GetDVEncoder_VideoStandard                                                       = GetFunction(gnTVGLibrary, "_GetDVEncoder_VideoStandard")
    Global TVG_GetDVRecordingInNativeFormatSeparatesStreams.pr_GetDVRecordingInNativeFormatSeparatesStreams                   = GetFunction(gnTVGLibrary, "_GetDVRecordingInNativeFormatSeparatesStreams")
    Global TVG_GetDVReduceFrameRate.pr_GetDVReduceFrameRate                                                                   = GetFunction(gnTVGLibrary, "_GetDVReduceFrameRate")
    Global TVG_GetDVRgb219.pr_GetDVRgb219                                                                                     = GetFunction(gnTVGLibrary, "_GetDVRgb219")
    Global TVG_GetDVTimeCodeEnabled.pr_GetDVTimeCodeEnabled                                                                   = GetFunction(gnTVGLibrary, "_GetDVTimeCodeEnabled")
    Global TVG_GetEventNotificationSynchrone.pr_GetEventNotificationSynchrone                                                 = GetFunction(gnTVGLibrary, "_GetEventNotificationSynchrone")
    Global TVG_GetExtraDLLPath.pr_GetExtraDLLPath                                                                             = GetFunction(gnTVGLibrary, "_GetExtraDLLPath")
    Global TVG_GetFilterInterfaceByName.pr_GetFilterInterfaceByName                                                 					= GetFunction(gnTVGLibrary, "_GetFilterInterfaceByName")
    Global TVG_GetFixFlickerOrBlackCapture.pr_GetFixFlickerOrBlackCapture                                                     = GetFunction(gnTVGLibrary, "_GetFixFlickerOrBlackCapture")
    Global TVG_GetFrameCaptureHeight.pr_GetFrameCaptureHeight                                                                 = GetFunction(gnTVGLibrary, "_GetFrameCaptureHeight")
    Global TVG_GetFrameBitmapInfo.pr_GetFrameBitmapInfo                                                                       = GetFunction(gnTVGLibrary, "_GetFrameBitmapInfo")
    Global TVG_GetFrameCaptureWidth.pr_GetFrameCaptureWidth                                                                   = GetFunction(gnTVGLibrary, "_GetFrameCaptureWidth")
    Global TVG_GetFrameCaptureWithoutOverlay.pr_GetFrameCaptureWithoutOverlay                                                 = GetFunction(gnTVGLibrary, "_GetFrameCaptureWithoutOverlay")
    Global TVG_GetFrameCaptureZoomSize.pr_GetFrameCaptureZoomSize                                                             = GetFunction(gnTVGLibrary, "_GetFrameCaptureZoomSize")
    Global TVG_GetFrameGrabber.pr_GetFrameGrabber                                                                             = GetFunction(gnTVGLibrary, "_GetFrameGrabber")
    Global TVG_GetFrameGrabberCurrentRGBFormat.pr_GetFrameGrabberCurrentRGBFormat                                             = GetFunction(gnTVGLibrary, "_GetFrameGrabberCurrentRGBFormat")
    Global TVG_GetFrameGrabberRGBFormat.pr_GetFrameGrabberRGBFormat                                                           = GetFunction(gnTVGLibrary, "_GetFrameGrabberRGBFormat")
    Global TVG_GetFrameInfo.pr_GetFrameInfo                                                                                   = GetFunction(gnTVGLibrary, "_GetFrameInfo")
    Global TVG_GetFrameInfoString.pr_GetFrameInfoString                                                                       = GetFunction(gnTVGLibrary, "_GetFrameInfoString")
    Global TVG_GetFWCam1394.pr_GetFWCam1394                                                                                   = GetFunction(gnTVGLibrary, "_GetFWCam1394")
    Global TVG_GetFWCam1394List.pr_GetFWCam1394List                                                                           = GetFunction(gnTVGLibrary, "_GetFWCam1394List")
    Global TVG_GetFrameNumberStartsFromZero.pr_GetFrameNumberStartsFromZero                                                   = GetFunction(gnTVGLibrary, "_GetFrameNumberStartsFromZero")
    Global TVG_GetFrameRate.pr_GetFrameRate                                                                                   = GetFunction(gnTVGLibrary, "_GetFrameRate")
    Global TVG_GetFrameRateDivider.pr_GetFrameRateDivider                                                                     = GetFunction(gnTVGLibrary, "_GetFrameRateDivider")
    Global TVG_GetGetLastFrameWaitTimeoutMs.pr_GetGetLastFrameWaitTimeoutMs                                                   = GetFunction(gnTVGLibrary, "_GetGetLastFrameWaitTimeoutMs")
    Global TVG_GetGeneratePts.pr_GetGeneratePts                                                                               = GetFunction(gnTVGLibrary, "_GetGeneratePts")
    Global TVG_GetHoldRecording.pr_GetHoldRecording                                                                           = GetFunction(gnTVGLibrary, "_GetHoldRecording")
    Global TVG_GetImageOverlay_AlphaBlend.pr_GetImageOverlay_AlphaBlend                                                       = GetFunction(gnTVGLibrary, "_GetImageOverlay_AlphaBlend")
    Global TVG_GetImageOverlay_AlphaBlendValue.pr_GetImageOverlay_AlphaBlendValue                                             = GetFunction(gnTVGLibrary, "_GetImageOverlay_AlphaBlendValue")
    Global TVG_GetImageOverlay_ChromaKey.pr_GetImageOverlay_ChromaKey                                                         = GetFunction(gnTVGLibrary, "_GetImageOverlay_ChromaKey")
    Global TVG_GetImageOverlay_ChromaKeyLeewayPercent.pr_GetImageOverlay_ChromaKeyLeewayPercent                               = GetFunction(gnTVGLibrary, "_GetImageOverlay_ChromaKeyLeewayPercent")
    Global TVG_GetImageOverlay_ChromaKeyRGBColor.pr_GetImageOverlay_ChromaKeyRGBColor                                         = GetFunction(gnTVGLibrary, "_GetImageOverlay_ChromaKeyRGBColor")
    Global TVG_GetImageOverlay_Enabled.pr_GetImageOverlay_Enabled                                                             = GetFunction(gnTVGLibrary, "_GetImageOverlay_Enabled")
    Global TVG_GetImageOverlay_Height.pr_GetImageOverlay_Height                                                               = GetFunction(gnTVGLibrary, "_GetImageOverlay_Height")
    Global TVG_GetImageOverlay_LeftLocation.pr_GetImageOverlay_LeftLocation                                                   = GetFunction(gnTVGLibrary, "_GetImageOverlay_LeftLocation")
    Global TVG_GetImageOverlay_RotationAngle.pr_GetImageOverlay_RotationAngle                                                 = GetFunction(gnTVGLibrary, "_GetImageOverlay_RotationAngle")
    Global TVG_GetImageOverlay_StretchToVideoSize.pr_GetImageOverlay_StretchToVideoSize                                       = GetFunction(gnTVGLibrary, "_GetImageOverlay_StretchToVideoSize")
    Global TVG_GetImageOverlay_TargetDisplay.pr_GetImageOverlay_TargetDisplay                                                 = GetFunction(gnTVGLibrary, "_GetImageOverlay_TargetDisplay")
    Global TVG_GetImageOverlay_TopLocation.pr_GetImageOverlay_TopLocation                                                     = GetFunction(gnTVGLibrary, "_GetImageOverlay_TopLocation")
    Global TVG_GetImageOverlay_Transparent.pr_GetImageOverlay_Transparent                                                     = GetFunction(gnTVGLibrary, "_GetImageOverlay_Transparent")
    Global TVG_GetImageOverlay_TransparentColorValue.pr_GetImageOverlay_TransparentColorValue                                 = GetFunction(gnTVGLibrary, "_GetImageOverlay_TransparentColorValue")
    Global TVG_GetImageOverlay_UseTransparentColor.pr_GetImageOverlay_UseTransparentColor                                     = GetFunction(gnTVGLibrary, "_GetImageOverlay_UseTransparentColor")
    Global TVG_GetImageOverlay_VideoAlignment.pr_GetImageOverlay_VideoAlignment                                               = GetFunction(gnTVGLibrary, "_GetImageOverlay_VideoAlignment")
    Global TVG_GetImageOverlay_Width.pr_GetImageOverlay_Width                                                                 = GetFunction(gnTVGLibrary, "_GetImageOverlay_Width")
    Global TVG_GetImageOverlayAlphaBlend.pr_GetImageOverlayAlphaBlend                                                         = GetFunction(gnTVGLibrary, "_GetImageOverlayAlphaBlend")
    Global TVG_GetImageOverlayAlphaBlendValue.pr_GetImageOverlayAlphaBlendValue                                               = GetFunction(gnTVGLibrary, "_GetImageOverlayAlphaBlendValue")
    Global TVG_GetImageOverlayChromaKey.pr_GetImageOverlayChromaKey                                                           = GetFunction(gnTVGLibrary, "_GetImageOverlayChromaKey")
    Global TVG_GetImageOverlayChromaKeyLeewayPercent.pr_GetImageOverlayChromaKeyLeewayPercent                                 = GetFunction(gnTVGLibrary, "_GetImageOverlayChromaKeyLeewayPercent")
    Global TVG_GetImageOverlayChromaKeyRGBColor.pr_GetImageOverlayChromaKeyRGBColor                                           = GetFunction(gnTVGLibrary, "_GetImageOverlayChromaKeyRGBColor")
    Global TVG_GetImageOverlayEnabled.pr_GetImageOverlayEnabled                                                               = GetFunction(gnTVGLibrary, "_GetImageOverlayEnabled")
    Global TVG_GetImageOverlayHeight.pr_GetImageOverlayHeight                                                                 = GetFunction(gnTVGLibrary, "_GetImageOverlayHeight")
    Global TVG_GetImageOverlayLeftLocation.pr_GetImageOverlayLeftLocation                                                     = GetFunction(gnTVGLibrary, "_GetImageOverlayLeftLocation")
    Global TVG_GetImageOverlayRotationAngle.pr_GetImageOverlayRotationAngle                                                   = GetFunction(gnTVGLibrary, "_GetImageOverlayRotationAngle")
    Global TVG_GetImageOverlaySelector.pr_GetImageOverlaySelector                                                             = GetFunction(gnTVGLibrary, "_GetImageOverlaySelector")
    Global TVG_GetImageOverlayStretchToVideoSize.pr_GetImageOverlayStretchToVideoSize                                         = GetFunction(gnTVGLibrary, "_GetImageOverlayStretchToVideoSize")
    Global TVG_GetImageOverlayTargetDisplay.pr_GetImageOverlayTargetDisplay                                                   = GetFunction(gnTVGLibrary, "_GetImageOverlayTargetDisplay")
    Global TVG_GetImageOverlayTopLocation.pr_GetImageOverlayTopLocation                                                       = GetFunction(gnTVGLibrary, "_GetImageOverlayTopLocation")
    Global TVG_GetImageOverlayTransparent.pr_GetImageOverlayTransparent                                                       = GetFunction(gnTVGLibrary, "_GetImageOverlayTransparent")
    Global TVG_GetImageOverlayTransparentColorValue.pr_GetImageOverlayTransparentColorValue                                   = GetFunction(gnTVGLibrary, "_GetImageOverlayTransparentColorValue")
    Global TVG_GetImageOverlayUseTransparentColor.pr_GetImageOverlayUseTransparentColor                                       = GetFunction(gnTVGLibrary, "_GetImageOverlayUseTransparentColor")
    Global TVG_GetImageOverlayVideoAlignment.pr_GetImageOverlayVideoAlignment                                                 = GetFunction(gnTVGLibrary, "_GetImageOverlayVideoAlignment")
    Global TVG_GetImageOverlayWidth.pr_GetImageOverlayWidth                                                                   = GetFunction(gnTVGLibrary, "_GetImageOverlayWidth")
    Global TVG_GetImageRatio.pr_GetImageRatio                                                                                 = GetFunction(gnTVGLibrary, "_GetImageRatio")
    Global TVG_GetInFrameProgressEvent.pr_GetInFrameProgressEvent                                                             = GetFunction(gnTVGLibrary, "_GetInFrameProgressEvent")
    Global TVG_GetIPCameraURL.pr_GetIPCameraURL                                                                               = GetFunction(gnTVGLibrary, "_GetIPCameraURL")
    Global TVG_GetIsAnalogVideoDecoderAvailable.pr_GetIsAnalogVideoDecoderAvailable                                           = GetFunction(gnTVGLibrary, "_GetIsAnalogVideoDecoderAvailable")
    Global TVG_GetIsAudioCrossbarAvailable.pr_GetIsAudioCrossbarAvailable                                                     = GetFunction(gnTVGLibrary, "_GetIsAudioCrossbarAvailable")
    Global TVG_GetIsAudioInputBalanceAvailable.pr_GetIsAudioInputBalanceAvailable                                             = GetFunction(gnTVGLibrary, "_GetIsAudioInputBalanceAvailable")
    Global TVG_GetIsCameraControlAvailable.pr_GetIsCameraControlAvailable                                                     = GetFunction(gnTVGLibrary, "_GetIsCameraControlAvailable")
    Global TVG_GetIsDigitalVideoIn.pr_GetIsDigitalVideoIn                                                                     = GetFunction(gnTVGLibrary, "_GetIsDigitalVideoIn")
    Global TVG_GetIsDVCommandAvailable.pr_GetIsDVCommandAvailable                                                             = GetFunction(gnTVGLibrary, "_GetIsDVCommandAvailable")
    Global TVG_GetIsHorizontalSyncLocked.pr_GetIsHorizontalSyncLocked                                                         = GetFunction(gnTVGLibrary, "_GetIsHorizontalSyncLocked")
    Global TVG_GetIsMpegStream.pr_GetIsMpegStream                                                                             = GetFunction(gnTVGLibrary, "_GetIsMpegStream")
    Global TVG_GetIsPlayerAudioStreamAvailable.pr_GetIsPlayerAudioStreamAvailable                                             = GetFunction(gnTVGLibrary, "_GetIsPlayerAudioStreamAvailable")
    Global TVG_GetIsPlayerVideoStreamAvailable.pr_GetIsPlayerVideoStreamAvailable                                             = GetFunction(gnTVGLibrary, "_GetIsPlayerVideoStreamAvailable")
    Global TVG_GetIsRecordingPaused.pr_GetIsRecordingPaused                                                                   = GetFunction(gnTVGLibrary, "_GetIsRecordingPaused")
    Global TVG_GetIsTVAudioAvailable.pr_GetIsTVAudioAvailable                                                                 = GetFunction(gnTVGLibrary, "_GetIsTVAudioAvailable")
    Global TVG_GetIsTVAutoTuneRunning.pr_GetIsTVAutoTuneRunning                                                               = GetFunction(gnTVGLibrary, "_GetIsTVAutoTuneRunning")
    Global TVG_GetIsTVTunerAvailable.pr_GetIsTVTunerAvailable                                                                 = GetFunction(gnTVGLibrary, "_GetIsTVTunerAvailable")
    Global TVG_GetIsVideoControlAvailable.pr_GetIsVideoControlAvailable                                                       = GetFunction(gnTVGLibrary, "_GetIsVideoControlAvailable")
    Global TVG_GetIsVideoCrossbarAvailable.pr_GetIsVideoCrossbarAvailable                                                     = GetFunction(gnTVGLibrary, "_GetIsVideoCrossbarAvailable")
    Global TVG_GetIsVideoInterlaced.pr_GetIsVideoInterlaced                                                                   = GetFunction(gnTVGLibrary, "_GetIsVideoInterlaced")
    Global TVG_GetIsVideoPortAvailable.pr_GetIsVideoPortAvailable                                                             = GetFunction(gnTVGLibrary, "_GetIsVideoPortAvailable")
    Global TVG_GetIsVideoQualityAvailable.pr_GetIsVideoQualityAvailable                                                       = GetFunction(gnTVGLibrary, "_GetIsVideoQualityAvailable")
    Global TVG_GetIsWDMVideoDriver.pr_GetIsWDMVideoDriver                                                                     = GetFunction(gnTVGLibrary, "_GetIsWDMVideoDriver")
    Global TVG_GetItemNameFromList.pr_GetItemNameFromList                                                                     = GetFunction(gnTVGLibrary, "_GetItemNameFromList")
    Global TVG_GetJPEGPerformance.pr_GetJPEGPerformance                                                                       = GetFunction(gnTVGLibrary, "_GetJPEGPerformance")
    Global TVG_GetJPEGProgressiveDisplay.pr_GetJPEGProgressiveDisplay                                                         = GetFunction(gnTVGLibrary, "_GetJPEGProgressiveDisplay")
    Global TVG_GetJPEGQuality.pr_GetJPEGQuality                                                                               = GetFunction(gnTVGLibrary, "_GetJPEGQuality")
    Global TVG_GetLast_BurstFrameCapture_FileName.pr_GetLast_BurstFrameCapture_FileName                                       = GetFunction(gnTVGLibrary, "_GetLast_BurstFrameCapture_FileName")
    Global TVG_GetLast_CaptureFrameTo_FileName.pr_GetLast_CaptureFrameTo_FileName                                             = GetFunction(gnTVGLibrary, "_GetLast_CaptureFrameTo_FileName")
    Global TVG_GetLast_Clip_Played.pr_GetLast_Clip_Played                                                                     = GetFunction(gnTVGLibrary, "_GetLast_Clip_Played")
    Global TVG_GetLast_Recording_FileName.pr_GetLast_Recording_FileName                                                       = GetFunction(gnTVGLibrary, "_GetLast_Recording_FileName")
    Global TVG_GetLastAverageStreamValue.pr_GetLastAverageStreamValue                                                         = GetFunction(gnTVGLibrary, "_GetLastAverageStreamValue")
    Global TVG_GetLastErrorMessage.pr_GetLastErrorMessage                                                                     = GetFunction(gnTVGLibrary, "_GetLastErrorMessage")
    Global TVG_GetLastFrameAsHBITMAP.pr_GetLastFrameAsHBITMAP                                                                 = GetFunction(gnTVGLibrary, "_GetLastFrameAsHBITMAP")
    Global TVG_GetLastFrameBitmapBits.pr_GetLastFrameBitmapBits                                                               = GetFunction(gnTVGLibrary, "_GetLastFrameBitmapBits")
		Global TVG_GetLastFrameBitmapBits2.pr_GetLastFrameBitmapBits2                                                             = GetFunction(gnTVGLibrary, "_GetLastFrameBitmapBits2")
    Global TVG_GetLicenseString.pr_GetLicenseString                                                                           = GetFunction(gnTVGLibrary, "_GetLicenseString")
    Global TVG_GetLogoDisplayed.pr_GetLogoDisplayed                                                                           = GetFunction(gnTVGLibrary, "_GetLogoDisplayed")
    Global TVG_GetLogoLayout.pr_GetLogoLayout                                                                                 = GetFunction(gnTVGLibrary, "_GetLogoLayout")
    Global TVG_GetLogString.pr_GetLogString                                                                                   = GetFunction(gnTVGLibrary, "_GetLogString")
    Global TVG_GetMiscDeviceControl.pr_GetMiscDeviceControl                                                                   = GetFunction(gnTVGLibrary, "_GetMiscDeviceControl")
    Global TVG_GetMixAudioSamplesLevel.pr_GetMixAudioSamplesLevel                                                             = GetFunction(gnTVGLibrary, "_GetMixAudioSamplesLevel")
    Global TVG_GetMixer_MosaicColumns.pr_GetMixer_MosaicColumns                                                               = GetFunction(gnTVGLibrary, "_GetMixer_MosaicColumns")
    Global TVG_GetMixer_MosaicLines.pr_GetMixer_MosaicLines                                                                   = GetFunction(gnTVGLibrary, "_GetMixer_MosaicLines")
    Global TVG_GetMotionDetector_CompareBlue.pr_GetMotionDetector_CompareBlue                                                 = GetFunction(gnTVGLibrary, "_GetMotionDetector_CompareBlue")
    Global TVG_GetMotionDetector_CompareGreen.pr_GetMotionDetector_CompareGreen                                               = GetFunction(gnTVGLibrary, "_GetMotionDetector_CompareGreen")
    Global TVG_GetMotionDetector_CompareRed.pr_GetMotionDetector_CompareRed                                                   = GetFunction(gnTVGLibrary, "_GetMotionDetector_CompareRed")
    Global TVG_GetMotionDetector_Enabled.pr_GetMotionDetector_Enabled                                                         = GetFunction(gnTVGLibrary, "_GetMotionDetector_Enabled")
    Global TVG_GetMotionDetector_GlobalMotionRatio.pr_GetMotionDetector_GlobalMotionRatio                                     = GetFunction(gnTVGLibrary, "_GetMotionDetector_GlobalMotionRatio")
    Global TVG_GetMotionDetector_GreyScale.pr_GetMotionDetector_GreyScale                                                     = GetFunction(gnTVGLibrary, "_GetMotionDetector_GreyScale")
    Global TVG_GetMotionDetector_Grid.pr_GetMotionDetector_Grid                                                               = GetFunction(gnTVGLibrary, "_GetMotionDetector_Grid")
    Global TVG_GetMotionDetector_GridXCount.pr_GetMotionDetector_GridXCount                                                   = GetFunction(gnTVGLibrary, "_GetMotionDetector_GridXCount")
    Global TVG_GetMotionDetector_GridYCount.pr_GetMotionDetector_GridYCount                                                   = GetFunction(gnTVGLibrary, "_GetMotionDetector_GridYCount")
    Global TVG_GetMotionDetector_IsGridValid.pr_GetMotionDetector_IsGridValid                                                 = GetFunction(gnTVGLibrary, "_GetMotionDetector_IsGridValid")
    Global TVG_GetMotionDetector_MaxDetectionsPerSecond.pr_GetMotionDetector_MaxDetectionsPerSecond                           = GetFunction(gnTVGLibrary, "_GetMotionDetector_MaxDetectionsPerSecond")
    Global TVG_GetMotionDetector_MotionResetMs.pr_GetMotionDetector_MotionResetMs                                             = GetFunction(gnTVGLibrary, "_GetMotionDetector_MotionResetMs")
    Global TVG_GetMotionDetector_ReduceCPULoad.pr_GetMotionDetector_ReduceCPULoad                                             = GetFunction(gnTVGLibrary, "_GetMotionDetector_ReduceCPULoad")
    Global TVG_GetMotionDetector_ReduceVideoNoise.pr_GetMotionDetector_ReduceVideoNoise                                       = GetFunction(gnTVGLibrary, "_GetMotionDetector_ReduceVideoNoise")
    Global TVG_GetMotionDetector_Triggered.pr_GetMotionDetector_Triggered                                                     = GetFunction(gnTVGLibrary, "_GetMotionDetector_Triggered")
    Global TVG_GetMouseWheelEventEnabled.pr_GetMouseWheelEventEnabled                                                         = GetFunction(gnTVGLibrary, "_GetMouseWheelEventEnabled")
    Global TVG_GetMouseWheelControlsZoomAtCursor.pr_GetMouseWheelControlsZoomAtCursor                                         = GetFunction(gnTVGLibrary, "_GetMouseWheelControlsZoomAtCursor")
    Global TVG_GetMpegStreamType.pr_GetMpegStreamType                                                                         = GetFunction(gnTVGLibrary, "_GetMpegStreamType")
    Global TVG_GetMultiplexedInputEmulation.pr_GetMultiplexedInputEmulation                                                   = GetFunction(gnTVGLibrary, "_GetMultiplexedInputEmulation")
    Global TVG_GetMultiplexedRole.pr_GetMultiplexedRole                                                                       = GetFunction(gnTVGLibrary, "_GetMultiplexedRole")
    Global TVG_GetMultiplexedStabilizationDelay.pr_GetMultiplexedStabilizationDelay                                           = GetFunction(gnTVGLibrary, "_GetMultiplexedStabilizationDelay")
    Global TVG_GetMultiplexedSwitchDelay.pr_GetMultiplexedSwitchDelay                                                         = GetFunction(gnTVGLibrary, "_GetMultiplexedSwitchDelay")
    Global TVG_GetMultiplexer.pr_GetMultiplexer                                                                               = GetFunction(gnTVGLibrary, "_GetMultiplexer")
    Global TVG_GetMultiplexerName.pr_GetMultiplexerName                                                                       = GetFunction(gnTVGLibrary, "_GetMultiplexerName")
    Global TVG_GetMultiplexers.pr_GetMultiplexers                                                                             = GetFunction(gnTVGLibrary, "_GetMultiplexers")
    Global TVG_GetMultiplexersCount.pr_GetMultiplexersCount                                                                   = GetFunction(gnTVGLibrary, "_GetMultiplexersCount")
    Global TVG_GetMultipurposeEncoderSettings.pr_GetMultipurposeEncoderSettings                                               = GetFunction(gnTVGLibrary, "_GetMultipurposeEncoderSettings")
    Global TVG_GetMuteAudioRendering.pr_GetMuteAudioRendering                                                                 = GetFunction(gnTVGLibrary, "_GetMuteAudioRendering")
    Global TVG_GetName.pr_GetName                                                                                             = GetFunction(gnTVGLibrary, "_GetName")
    Global TVG_GetNDIBandwidthType.pr_GetNDIBandwidthType                                                                     = GetFunction(gnTVGLibrary, "_GetNDIBandwidthType")
    Global TVG_GetNDIGroups.pr_GetNDIGroups                                                                                   = GetFunction(gnTVGLibrary, "_GetNDIGroups")
    Global TVG_GetNDIName.pr_GetNDIName                                                                                       = GetFunction(gnTVGLibrary, "_GetNDIName")
    Global TVG_GetNDIReceiveTimeoutMs.pr_GetNDIReceiveTimeoutMs                                                               = GetFunction(gnTVGLibrary, "_GetNDIReceiveTimeoutMs")
    Global TVG_GetNDISessions.pr_GetNDISessions                                                                               = GetFunction(gnTVGLibrary, "_GetNDISessions")
    Global TVG_GetNearestVideoHeight.pr_GetNearestVideoHeight                                                                 = GetFunction(gnTVGLibrary, "_GetNearestVideoHeight")
    Global TVG_GetNearestVideoSize.pr_GetNearestVideoSize                                                                     = GetFunction(gnTVGLibrary, "_GetNearestVideoSize")
    Global TVG_GetNearestVideoWidth.pr_GetNearestVideoWidth                                                                   = GetFunction(gnTVGLibrary, "_GetNearestVideoWidth")
    Global TVG_GetONVIFURLFromServiceURL.pr_GetONVIFURLFromServiceURL                                                         = GetFunction(gnTVGLibrary, "_GetONVIFURLFromServiceURL")
    Global TVG_GetNetworkStreaming.pr_GetNetworkStreaming                                                                     = GetFunction(gnTVGLibrary, "_GetNetworkStreaming")
    Global TVG_GetNetworkStreamingType.pr_GetNetworkStreamingType                                                             = GetFunction(gnTVGLibrary, "_GetNetworkStreamingType")
    Global TVG_GetNormalCursor.pr_GetNormalCursor                                                                             = GetFunction(gnTVGLibrary, "_GetNormalCursor")
    Global TVG_GetNotificationMethod.pr_GetNotificationMethod                                                                 = GetFunction(gnTVGLibrary, "_GetNotificationMethod")
    Global TVG_GetNotificationPriority.pr_GetNotificationPriority                                                             = GetFunction(gnTVGLibrary, "_GetNotificationPriority")
    Global TVG_GetNotificationSleepTime.pr_GetNotificationSleepTime                                                           = GetFunction(gnTVGLibrary, "_GetNotificationSleepTime")
    Global TVG_GetOnFrameBitmapEventSynchrone.pr_GetOnFrameBitmapEventSynchrone                                               = GetFunction(gnTVGLibrary, "_GetOnFrameBitmapEventSynchrone")
    Global TVG_GetOpenURLAsync.pr_GetOpenURLAsync                                                                             = GetFunction(gnTVGLibrary, "_GetOpenURLAsync")
    Global TVG_GetOverlayAfterTransform.pr_GetOverlayAfterTransform                                                           = GetFunction(gnTVGLibrary, "_GetOverlayAfterTransform")
    Global TVG_GetPixelsDistance.pr_GetPixelsDistance                                                                         = GetFunction(gnTVGLibrary, "_GetPixelsDistance")
    Global TVG_GetPlayerAudioRendering.pr_GetPlayerAudioRendering                                                             = GetFunction(gnTVGLibrary, "_GetPlayerAudioRendering")
    Global TVG_GetPlayerDuration.pr_GetPlayerDuration                                                                         = GetFunction(gnTVGLibrary, "_GetPlayerDuration")
    Global TVG_GetPlayerDVSize.pr_GetPlayerDVSize                                                                             = GetFunction(gnTVGLibrary, "_GetPlayerDVSize")
    Global TVG_GetPlayerFastSeekSpeedRatio.pr_GetPlayerFastSeekSpeedRatio                                                     = GetFunction(gnTVGLibrary, "_GetPlayerFastSeekSpeedRatio")
    Global TVG_GetPlayerFileName.pr_GetPlayerFileName                                                                         = GetFunction(gnTVGLibrary, "_GetPlayerFileName")
    Global TVG_GetPlayerForcedCodec.pr_GetPlayerForcedCodec                                                                   = GetFunction(gnTVGLibrary, "_GetPlayerForcedCodec")
    Global TVG_GetPlayerFrameCount.pr_GetPlayerFrameCount                                                                     = GetFunction(gnTVGLibrary, "_GetPlayerFrameCount")
    Global TVG_GetPlayerFramePosition.pr_GetPlayerFramePosition                                                               = GetFunction(gnTVGLibrary, "_GetPlayerFramePosition")
    Global TVG_GetPlayerFrameRate.pr_GetPlayerFrameRate                                                                       = GetFunction(gnTVGLibrary, "_GetPlayerFrameRate")
    Global TVG_GetPlayerHwAccel.pr_GetPlayerHwAccel                                                                           = GetFunction(gnTVGLibrary, "_GetPlayerHwAccel")
    Global TVG_GetPlayerOpenProgressPercent.pr_GetPlayerOpenProgressPercent                                                   = GetFunction(gnTVGLibrary, "_GetPlayerOpenProgressPercent")
    Global TVG_GetPlayerRefreshPausedDisplay.pr_GetPlayerRefreshPausedDisplay                                                 = GetFunction(gnTVGLibrary, "_GetPlayerRefreshPausedDisplay")
    Global TVG_GetPlayerRefreshPausedDisplayFrameRate.pr_GetPlayerRefreshPausedDisplayFrameRate                               = GetFunction(gnTVGLibrary, "_GetPlayerRefreshPausedDisplayFrameRate")
    Global TVG_GetPlayerSpeedRatio.pr_GetPlayerSpeedRatio                                                                     = GetFunction(gnTVGLibrary, "_GetPlayerSpeedRatio")
    Global TVG_GetPlayerSpeedRatioConstantAudioPitch.pr_GetPlayerSpeedRatioConstantAudioPitch                                 = GetFunction(gnTVGLibrary, "_GetPlayerSpeedRatioConstantAudioPitch")
    Global TVG_GetPlayerState.pr_GetPlayerState                                                                               = GetFunction(gnTVGLibrary, "_GetPlayerState")
    Global TVG_GetPlayerTimePosition.pr_GetPlayerTimePosition                                                                 = GetFunction(gnTVGLibrary, "_GetPlayerTimePosition")
    Global TVG_GetPlayerTrackBarSynchrone.pr_GetPlayerTrackBarSynchrone                                                       = GetFunction(gnTVGLibrary, "_GetPlayerTrackBarSynchrone")
    Global TVG_GetPlaylist.pr_GetPlaylist                                                                                     = GetFunction(gnTVGLibrary, "_GetPlaylist")
    Global TVG_GetPlaylistIndex.pr_GetPlaylistIndex                                                                           = GetFunction(gnTVGLibrary, "_GetPlaylistIndex")
    Global TVG_GetPreallocCapFileCopiedAfterRecording.pr_GetPreallocCapFileCopiedAfterRecording                               = GetFunction(gnTVGLibrary, "_GetPreallocCapFileCopiedAfterRecording")
    Global TVG_GetPreallocCapFileEnabled.pr_GetPreallocCapFileEnabled                                                         = GetFunction(gnTVGLibrary, "_GetPreallocCapFileEnabled")
    Global TVG_GetPreallocCapFileName.pr_GetPreallocCapFileName                                                               = GetFunction(gnTVGLibrary, "_GetPreallocCapFileName")
    Global TVG_GetPreallocCapFileSizeInMB.pr_GetPreallocCapFileSizeInMB                                                       = GetFunction(gnTVGLibrary, "_GetPreallocCapFileSizeInMB")
    Global TVG_GetPreviewZoomSize.pr_GetPreviewZoomSize                                                                       = GetFunction(gnTVGLibrary, "_GetPreviewZoomSize")
    Global TVG_GetQuickDeviceInitialization.pr_GetQuickDeviceInitialization                                                   = GetFunction(gnTVGLibrary, "_GetQuickDeviceInitialization")
    Global TVG_GetRawAudioSampleCapture.pr_GetRawAudioSampleCapture                                                           = GetFunction(gnTVGLibrary, "_GetRawAudioSampleCapture")
    Global TVG_GetRawCaptureAsyncEvent.pr_GetRawCaptureAsyncEvent                                                             = GetFunction(gnTVGLibrary, "_GetRawCaptureAsyncEvent")
    Global TVG_GetRawSampleCaptureLocation.pr_GetRawSampleCaptureLocation                                                     = GetFunction(gnTVGLibrary, "_GetRawSampleCaptureLocation")
    Global TVG_GetRawVideoSampleCapture.pr_GetRawVideoSampleCapture                                                           = GetFunction(gnTVGLibrary, "_GetRawVideoSampleCapture")
    Global TVG_GetRecordingAudioBitRate.pr_GetRecordingAudioBitRate                                                           = GetFunction(gnTVGLibrary, "_GetRecordingAudioBitRate")
    Global TVG_GetRecordingBacktimedFramesCount.pr_GetRecordingBacktimedFramesCount                                           = GetFunction(gnTVGLibrary, "_GetRecordingBacktimedFramesCount")
    Global TVG_GetRecordingCanPause.pr_GetRecordingCanPause                                                                   = GetFunction(gnTVGLibrary, "_GetRecordingCanPause")
    Global TVG_GetRecordingDuration.pr_GetRecordingDuration                                                                   = GetFunction(gnTVGLibrary, "_GetRecordingDuration")
    Global TVG_GetRecordingFileName.pr_GetRecordingFileName                                                                   = GetFunction(gnTVGLibrary, "_GetRecordingFileName")
    Global TVG_GetRecordingFileSizeMaxInMB.pr_GetRecordingFileSizeMaxInMB                                                     = GetFunction(gnTVGLibrary, "_GetRecordingFileSizeMaxInMB")
    Global TVG_GetRecordingFourCC.pr_GetRecordingFourCC                                                                       = GetFunction(gnTVGLibrary, "_GetRecordingFourCC")
    Global TVG_GetRecordingHeight.pr_GetRecordingHeight                                                                       = GetFunction(gnTVGLibrary, "_GetRecordingHeight")
    Global TVG_GetRecordingInNativeFormat.pr_GetRecordingInNativeFormat                                                       = GetFunction(gnTVGLibrary, "_GetRecordingInNativeFormat")
    Global TVG_GetRecordingMethod.pr_GetRecordingMethod                                                                       = GetFunction(gnTVGLibrary, "_GetRecordingMethod")
    Global TVG_GetRecordingOnMotion_Enabled.pr_GetRecordingOnMotion_Enabled                                                   = GetFunction(gnTVGLibrary, "_GetRecordingOnMotion_Enabled")
    Global TVG_GetRecordingOnMotion_MotionThreshold.pr_GetRecordingOnMotion_MotionThreshold                                   = GetFunction(gnTVGLibrary, "_GetRecordingOnMotion_MotionThreshold")
    Global TVG_GetRecordingOnMotion_NoMotionPauseDelayMs.pr_GetRecordingOnMotion_NoMotionPauseDelayMs                         = GetFunction(gnTVGLibrary, "_GetRecordingOnMotion_NoMotionPauseDelayMs")
    Global TVG_GetRecordingPauseCreatesNewFile.pr_GetRecordingPauseCreatesNewFile                                             = GetFunction(gnTVGLibrary, "_GetRecordingPauseCreatesNewFile")
    Global TVG_GetRecordingSize.pr_GetRecordingSize                                                                           = GetFunction(gnTVGLibrary, "_GetRecordingSize")
    Global TVG_GetRecordingTimer.pr_GetRecordingTimer                                                                         = GetFunction(gnTVGLibrary, "_GetRecordingTimer")
    Global TVG_GetRecordingTimerInterval.pr_GetRecordingTimerInterval                                                         = GetFunction(gnTVGLibrary, "_GetRecordingTimerInterval")
    Global TVG_GetRecordingVideoBitRate.pr_GetRecordingVideoBitRate                                                           = GetFunction(gnTVGLibrary, "_GetRecordingVideoBitRate")
    Global TVG_GetRecordingWidth.pr_GetRecordingWidth                                                                         = GetFunction(gnTVGLibrary, "_GetRecordingWidth")
    Global TVG_GetReencodingIncludeAudioStream.pr_GetReencodingIncludeAudioStream                                             = GetFunction(gnTVGLibrary, "_GetReencodingIncludeAudioStream")
    Global TVG_GetReencodingIncludeVideoStream.pr_GetReencodingIncludeVideoStream                                             = GetFunction(gnTVGLibrary, "_GetReencodingIncludeVideoStream")
    Global TVG_GetReencodingMethod.pr_GetReencodingMethod                                                                     = GetFunction(gnTVGLibrary, "_GetReencodingMethod")
    Global TVG_GetReencodingNewVideoClip.pr_GetReencodingNewVideoClip                                                         = GetFunction(gnTVGLibrary, "_GetReencodingNewVideoClip")
    Global TVG_GetReencodingSourceVideoClip.pr_GetReencodingSourceVideoClip                                                   = GetFunction(gnTVGLibrary, "_GetReencodingSourceVideoClip")
    Global TVG_GetReencodingStartFrame.pr_GetReencodingStartFrame                                                             = GetFunction(gnTVGLibrary, "_GetReencodingStartFrame")
    Global TVG_GetReencodingStartTime.pr_GetReencodingStartTime                                                               = GetFunction(gnTVGLibrary, "_GetReencodingStartTime")
    Global TVG_GetReencodingStopFrame.pr_GetReencodingStopFrame                                                               = GetFunction(gnTVGLibrary, "_GetReencodingStopFrame")
    Global TVG_GetReencodingStopTime.pr_GetReencodingStopTime                                                                 = GetFunction(gnTVGLibrary, "_GetReencodingStopTime")
    Global TVG_GetReencodingUseAudioCompressor.pr_GetReencodingUseAudioCompressor                                             = GetFunction(gnTVGLibrary, "_GetReencodingUseAudioCompressor")
    Global TVG_GetReencodingUseFrameGrabber.pr_GetReencodingUseFrameGrabber                                                   = GetFunction(gnTVGLibrary, "_GetReencodingUseFrameGrabber")
    Global TVG_GetReencodingUseVideoCompressor.pr_GetReencodingUseVideoCompressor                                             = GetFunction(gnTVGLibrary, "_GetReencodingUseVideoCompressor")
    Global TVG_GetReencodingWMVOutput.pr_GetReencodingWMVOutput                                                               = GetFunction(gnTVGLibrary, "_GetReencodingWMVOutput")
    Global TVG_GetRGBPixelAt.pr_GetRGBPixelAt                                                                                 = GetFunction(gnTVGLibrary, "_GetRGBPixelAt")
    Global TVG_GetScreenRecordingLayeredWindows.pr_GetScreenRecordingLayeredWindows                                           = GetFunction(gnTVGLibrary, "_GetScreenRecordingLayeredWindows")
    Global TVG_GetScreenRecordingMonitor.pr_GetScreenRecordingMonitor                                                         = GetFunction(gnTVGLibrary, "_GetScreenRecordingMonitor")
    Global TVG_GetScreenRecordingNonVisibleWindows.pr_GetScreenRecordingNonVisibleWindows                                     = GetFunction(gnTVGLibrary, "_GetScreenRecordingNonVisibleWindows")
    Global TVG_GetScreenRecordingSizePercent.pr_GetScreenRecordingSizePercent                                                 = GetFunction(gnTVGLibrary, "_GetScreenRecordingSizePercent")
    Global TVG_GetScreenRecordingThroughClipboard.pr_GetScreenRecordingThroughClipboard                                       = GetFunction(gnTVGLibrary, "_GetScreenRecordingThroughClipboard")
    Global TVG_GetScreenRecordingWithCursor.pr_GetScreenRecordingWithCursor                                                   = GetFunction(gnTVGLibrary, "_GetScreenRecordingWithCursor")
    Global TVG_GetSendToDV_DeviceIndex.pr_GetSendToDV_DeviceIndex                                                             = GetFunction(gnTVGLibrary, "_GetSendToDV_DeviceIndex")
    Global TVG_GetSpeakerBalance.pr_GetSpeakerBalance                                                                         = GetFunction(gnTVGLibrary, "_GetSpeakerBalance")
    Global TVG_GetSpeakerControl.pr_GetSpeakerControl                                                                         = GetFunction(gnTVGLibrary, "_GetSpeakerControl")
    Global TVG_GetSpeakerVolume.pr_GetSpeakerVolume                                                                           = GetFunction(gnTVGLibrary, "_GetSpeakerVolume")
    Global TVG_GetStoragePath.pr_GetStoragePath                                                                               = GetFunction(gnTVGLibrary, "_GetStoragePath")
    Global TVG_GetStoragePathMode.pr_GetStoragePathMode                                                                       = GetFunction(gnTVGLibrary, "_GetStoragePathMode")
    Global TVG_GetStoreDeviceSettingsInRegistry.pr_GetStoreDeviceSettingsInRegistry                                           = GetFunction(gnTVGLibrary, "_GetStoreDeviceSettingsInRegistry")
    Global TVG_GetStreamingURL.pr_GetStreamingURL                                                                             = GetFunction(gnTVGLibrary, "_GetStreamingURL")
    Global TVG_GetSyncCommands.pr_GetSyncCommands                                                                             = GetFunction(gnTVGLibrary, "_GetSyncCommands")
    Global TVG_GetSynchronizationRole.pr_GetSynchronizationRole                                                               = GetFunction(gnTVGLibrary, "_GetSynchronizationRole")
    Global TVG_GetSynchronized.pr_GetSynchronized                                                                             = GetFunction(gnTVGLibrary, "_GetSynchronized")
    Global TVG_GetSyncPreview.pr_GetSyncPreview                                                                               = GetFunction(gnTVGLibrary, "_GetSyncPreview")
    Global TVG_GetSystemTempPath.pr_GetSystemTempPath                                                                         = GetFunction(gnTVGLibrary, "_GetSystemTempPath")
    Global TVG_GetTextOverlay_Align.pr_GetTextOverlay_Align                                                                   = GetFunction(gnTVGLibrary, "_GetTextOverlay_Align")
    Global TVG_GetTextOverlay_AlphaBlend.pr_GetTextOverlay_AlphaBlend                                                         = GetFunction(gnTVGLibrary, "_GetTextOverlay_AlphaBlend")
    Global TVG_GetTextOverlay_AlphaBlendValue.pr_GetTextOverlay_AlphaBlendValue                                               = GetFunction(gnTVGLibrary, "_GetTextOverlay_AlphaBlendValue")
    Global TVG_GetTextOverlay_BkColor.pr_GetTextOverlay_BkColor                                                               = GetFunction(gnTVGLibrary, "_GetTextOverlay_BkColor")
    Global TVG_GetTextOverlay_Enabled.pr_GetTextOverlay_Enabled                                                               = GetFunction(gnTVGLibrary, "_GetTextOverlay_Enabled")
    Global TVG_GetTextOverlay_Font.pr_GetTextOverlay_Font                                                                     = GetFunction(gnTVGLibrary, "_GetTextOverlay_Font")
    Global TVG_GetTextOverlay_FontColor.pr_GetTextOverlay_FontColor                                                           = GetFunction(gnTVGLibrary, "_GetTextOverlay_FontColor")
    Global TVG_GetTextOverlay_FontSize.pr_GetTextOverlay_FontSize                                                             = GetFunction(gnTVGLibrary, "_GetTextOverlay_FontSize")
    Global TVG_GetTextOverlay_GradientColor.pr_GetTextOverlay_GradientColor                                                   = GetFunction(gnTVGLibrary, "_GetTextOverlay_GradientColor")
    Global TVG_GetTextOverlay_GradientMode.pr_GetTextOverlay_GradientMode                                                     = GetFunction(gnTVGLibrary, "_GetTextOverlay_GradientMode")
    Global TVG_GetTextOverlay_HighResFont.pr_GetTextOverlay_HighResFont                                                       = GetFunction(gnTVGLibrary, "_GetTextOverlay_HighResFont")
    Global TVG_GetTextOverlay_Left.pr_GetTextOverlay_Left                                                                     = GetFunction(gnTVGLibrary, "_GetTextOverlay_Left")
    Global TVG_GetTextOverlay_Orientation.pr_GetTextOverlay_Orientation                                                       = GetFunction(gnTVGLibrary, "_GetTextOverlay_Orientation")
    Global TVG_GetTextOverlay_Right.pr_GetTextOverlay_Right                                                                   = GetFunction(gnTVGLibrary, "_GetTextOverlay_Right")
    Global TVG_GetTextOverlay_Scrolling.pr_GetTextOverlay_Scrolling                                                           = GetFunction(gnTVGLibrary, "_GetTextOverlay_Scrolling")
    Global TVG_GetTextOverlay_ScrollingSpeed.pr_GetTextOverlay_ScrollingSpeed                                                 = GetFunction(gnTVGLibrary, "_GetTextOverlay_ScrollingSpeed")
    Global TVG_GetTextOverlay_Shadow.pr_GetTextOverlay_Shadow                                                                 = GetFunction(gnTVGLibrary, "_GetTextOverlay_Shadow")
    Global TVG_GetTextOverlay_ShadowColor.pr_GetTextOverlay_ShadowColor                                                       = GetFunction(gnTVGLibrary, "_GetTextOverlay_ShadowColor")
    Global TVG_GetTextOverlay_ShadowDirection.pr_GetTextOverlay_ShadowDirection                                               = GetFunction(gnTVGLibrary, "_GetTextOverlay_ShadowDirection")
    Global TVG_GetTextOverlay_String.pr_GetTextOverlay_String                                                                 = GetFunction(gnTVGLibrary, "_GetTextOverlay_String")
    Global TVG_GetTextOverlay_TargetDisplay.pr_GetTextOverlay_TargetDisplay                                                   = GetFunction(gnTVGLibrary, "_GetTextOverlay_TargetDisplay")
    Global TVG_GetTextOverlay_Top.pr_GetTextOverlay_Top                                                                       = GetFunction(gnTVGLibrary, "_GetTextOverlay_Top")
    Global TVG_GetTextOverlay_Transparent.pr_GetTextOverlay_Transparent                                                       = GetFunction(gnTVGLibrary, "_GetTextOverlay_Transparent")
    Global TVG_GetTextOverlay_VideoAlignment.pr_GetTextOverlay_VideoAlignment                                                 = GetFunction(gnTVGLibrary, "_GetTextOverlay_VideoAlignment")
    Global TVG_GetTextOverlayAlign.pr_GetTextOverlayAlign                                                                     = GetFunction(gnTVGLibrary, "_GetTextOverlayAlign")
    Global TVG_GetTextOverlayAlphaBlend.pr_GetTextOverlayAlphaBlend                                                           = GetFunction(gnTVGLibrary, "_GetTextOverlayAlphaBlend")
    Global TVG_GetTextOverlayAlphaBlendValue.pr_GetTextOverlayAlphaBlendValue                                                 = GetFunction(gnTVGLibrary, "_GetTextOverlayAlphaBlendValue")
    Global TVG_GetTextOverlayBkColor.pr_GetTextOverlayBkColor                                                                 = GetFunction(gnTVGLibrary, "_GetTextOverlayBkColor")
    Global TVG_GetTextOverlayEnabled.pr_GetTextOverlayEnabled                                                                 = GetFunction(gnTVGLibrary, "_GetTextOverlayEnabled")
    Global TVG_GetTextOverlayFont.pr_GetTextOverlayFont                                                                       = GetFunction(gnTVGLibrary, "_GetTextOverlayFont")
    Global TVG_GetTextOverlayFontColor.pr_GetTextOverlayFontColor                                                             = GetFunction(gnTVGLibrary, "_GetTextOverlayFontColor")
    Global TVG_GetTextOverlayFontSize.pr_GetTextOverlayFontSize                                                               = GetFunction(gnTVGLibrary, "_GetTextOverlayFontSize")
    Global TVG_GetTextOverlayGradientColor.pr_GetTextOverlayGradientColor                                                     = GetFunction(gnTVGLibrary, "_GetTextOverlayGradientColor")
    Global TVG_GetTextOverlayGradientMode.pr_GetTextOverlayGradientMode                                                       = GetFunction(gnTVGLibrary, "_GetTextOverlayGradientMode")
    Global TVG_GetTextOverlayHighResFont.pr_GetTextOverlayHighResFont                                                         = GetFunction(gnTVGLibrary, "_GetTextOverlayHighResFont")
    Global TVG_GetTextOverlayLeft.pr_GetTextOverlayLeft                                                                       = GetFunction(gnTVGLibrary, "_GetTextOverlayLeft")
    Global TVG_GetTextOverlayOrientation.pr_GetTextOverlayOrientation                                                         = GetFunction(gnTVGLibrary, "_GetTextOverlayOrientation")
    Global TVG_GetTextOverlayRight.pr_GetTextOverlayRight                                                                     = GetFunction(gnTVGLibrary, "_GetTextOverlayRight")
    Global TVG_GetTextOverlayScrolling.pr_GetTextOverlayScrolling                                                             = GetFunction(gnTVGLibrary, "_GetTextOverlayScrolling")
    Global TVG_GetTextOverlayScrollingSpeed.pr_GetTextOverlayScrollingSpeed                                                   = GetFunction(gnTVGLibrary, "_GetTextOverlayScrollingSpeed")
    Global TVG_GetTextOverlaySelector.pr_GetTextOverlaySelector                                                               = GetFunction(gnTVGLibrary, "_GetTextOverlaySelector")
    Global TVG_GetTextOverlayShadow.pr_GetTextOverlayShadow                                                                   = GetFunction(gnTVGLibrary, "_GetTextOverlayShadow")
    Global TVG_GetTextOverlayShadowColor.pr_GetTextOverlayShadowColor                                                         = GetFunction(gnTVGLibrary, "_GetTextOverlayShadowColor")
    Global TVG_GetTextOverlayShadowDirection.pr_GetTextOverlayShadowDirection                                                 = GetFunction(gnTVGLibrary, "_GetTextOverlayShadowDirection")
    Global TVG_GetTextOverlayString.pr_GetTextOverlayString                                                                   = GetFunction(gnTVGLibrary, "_GetTextOverlayString")
    Global TVG_GetTextOverlayTargetDisplay.pr_GetTextOverlayTargetDisplay                                                     = GetFunction(gnTVGLibrary, "_GetTextOverlayTargetDisplay")
    Global TVG_GetTextOverlayTop.pr_GetTextOverlayTop                                                                         = GetFunction(gnTVGLibrary, "_GetTextOverlayTop")
    Global TVG_GetTextOverlayTransparent.pr_GetTextOverlayTransparent                                                         = GetFunction(gnTVGLibrary, "_GetTextOverlayTransparent")
    Global TVG_GetTextOverlayVideoAlignment.pr_GetTextOverlayVideoAlignment                                                   = GetFunction(gnTVGLibrary, "_GetTextOverlayVideoAlignment")
    Global TVG_GetThirdPartyDeinterlacer.pr_GetThirdPartyDeinterlacer                                                         = GetFunction(gnTVGLibrary, "_GetThirdPartyDeinterlacer")
    Global TVG_GetTimeCodeReaderAvailable.pr_GetTimeCodeReaderAvailable                                                       = GetFunction(gnTVGLibrary, "_GetTimeCodeReaderAvailable")
    Global TVG_GetTranslatedCoordinates.pr_GetTranslatedCoordinates                                                           = GetFunction(gnTVGLibrary, "_GetTranslatedCoordinates")
    Global TVG_GetTranslateMouseCoordinates.pr_GetTranslateMouseCoordinates                                                   = GetFunction(gnTVGLibrary, "_GetTranslateMouseCoordinates")
    Global TVG_GetTunerFrequency.pr_GetTunerFrequency                                                                         = GetFunction(gnTVGLibrary, "_GetTunerFrequency")
    Global TVG_GetTunerMode.pr_GetTunerMode                                                                                   = GetFunction(gnTVGLibrary, "_GetTunerMode")
    Global TVG_GetTVChannel.pr_GetTVChannel                                                                                   = GetFunction(gnTVGLibrary, "_GetTVChannel")
    Global TVG_GetTVChannelInfo.pr_GetTVChannelInfo                                                                           = GetFunction(gnTVGLibrary, "_GetTVChannelInfo")
    Global TVG_GetTVCountryCode.pr_GetTVCountryCode                                                                           = GetFunction(gnTVGLibrary, "_GetTVCountryCode")
    Global TVG_GetTVTunerInputType.pr_GetTVTunerInputType                                                                     = GetFunction(gnTVGLibrary, "_GetTVTunerInputType")
    Global TVG_GetTVUseFrequencyOverrides.pr_GetTVUseFrequencyOverrides                                                       = GetFunction(gnTVGLibrary, "_GetTVUseFrequencyOverrides")
    Global TVG_GetUniqueID.pr_GetUniqueID                                                                                     = GetFunction(gnTVGLibrary, "_GetUniqueID")
    Global TVG_GetUseClock.pr_GetUseClock                                                                                     = GetFunction(gnTVGLibrary, "_GetUseClock")
    Global TVG_Getv360_AspectRatio.pr_Getv360_AspectRatio                                                                     = GetFunction(gnTVGLibrary, "_Getv360_AspectRatio")
    Global TVG_Getv360_Enabled.pr_Getv360_Enabled                                                                             = GetFunction(gnTVGLibrary, "_Getv360_Enabled")
    Global TVG_Getv360_MasterAngle.pr_Getv360_MasterAngle                                                                     = GetFunction(gnTVGLibrary, "_Getv360_MasterAngle")
    Global TVG_Getv360_MouseAction.pr_Getv360_MouseAction                                                                     = GetFunction(gnTVGLibrary, "_Getv360_MouseAction")
    Global TVG_Getv360_MouseActionPercent.pr_Getv360_MouseActionPercent                                                       = GetFunction(gnTVGLibrary, "_Getv360_MouseActionPercent")
    Global TVG_GetVCRHorizontalLocking.pr_GetVCRHorizontalLocking                                                             = GetFunction(gnTVGLibrary, "_GetVCRHorizontalLocking")
    Global TVG_GetVersion.pr_GetVersion                                                                                       = GetFunction(gnTVGLibrary, "_GetVersion")
    Global TVG_GetVideoCodec.pr_GetVideoCodec                                                                                 = GetFunction(gnTVGLibrary, "_GetVideoCodec")
    Global TVG_GetVideoCompression_DataRate.pr_GetVideoCompression_DataRate                                                   = GetFunction(gnTVGLibrary, "_GetVideoCompression_DataRate")
    Global TVG_GetVideoCompression_KeyFrameRate.pr_GetVideoCompression_KeyFrameRate                                           = GetFunction(gnTVGLibrary, "_GetVideoCompression_KeyFrameRate")
    Global TVG_GetVideoCompression_PFramesPerKeyFrame.pr_GetVideoCompression_PFramesPerKeyFrame                               = GetFunction(gnTVGLibrary, "_GetVideoCompression_PFramesPerKeyFrame")
    Global TVG_GetVideoCompression_Quality.pr_GetVideoCompression_Quality                                                     = GetFunction(gnTVGLibrary, "_GetVideoCompression_Quality")
    Global TVG_GetVideoCompression_WindowSize.pr_GetVideoCompression_WindowSize                                               = GetFunction(gnTVGLibrary, "_GetVideoCompression_WindowSize")
    Global TVG_GetVideoCompressionSettings.pr_GetVideoCompressionSettings                                                     = GetFunction(gnTVGLibrary, "_GetVideoCompressionSettings")
    Global TVG_GetVideoCompressor.pr_GetVideoCompressor                                                                       = GetFunction(gnTVGLibrary, "_GetVideoCompressor")
    Global TVG_GetVideoCompressorName.pr_GetVideoCompressorName                                                               = GetFunction(gnTVGLibrary, "_GetVideoCompressorName")
    Global TVG_GetVideoCompressors.pr_GetVideoCompressors                                                                     = GetFunction(gnTVGLibrary, "_GetVideoCompressors")
    Global TVG_GetVideoCompressorsCount.pr_GetVideoCompressorsCount                                                           = GetFunction(gnTVGLibrary, "_GetVideoCompressorsCount")
    Global TVG_GetVideoControlMode.pr_GetVideoControlMode                                                                     = GetFunction(gnTVGLibrary, "_GetVideoControlMode")
    Global TVG_GetVideoControlSettings.pr_GetVideoControlSettings                                                             = GetFunction(gnTVGLibrary, "_GetVideoControlSettings")
    Global TVG_GetVideoCursor.pr_GetVideoCursor                                                                               = GetFunction(gnTVGLibrary, "_GetVideoCursor")
    Global TVG_GetVideoDelay.pr_GetVideoDelay                                                                                 = GetFunction(gnTVGLibrary, "_GetVideoDelay")
    Global TVG_GetVideoDevice.pr_GetVideoDevice                                                                               = GetFunction(gnTVGLibrary, "_GetVideoDevice")
    Global TVG_GetVideoDeviceName.pr_GetVideoDeviceName                                                                       = GetFunction(gnTVGLibrary, "_GetVideoDeviceName")
    Global TVG_GetVideoDevices.pr_GetVideoDevices                                                                             = GetFunction(gnTVGLibrary, "_GetVideoDevices")
    Global TVG_GetVideoDevicesCount.pr_GetVideoDevicesCount                                                                   = GetFunction(gnTVGLibrary, "_GetVideoDevicesCount")
    Global TVG_GetVideoDevicesId.pr_GetVideoDevicesId                                                                         = GetFunction(gnTVGLibrary, "_GetVideoDevicesId")
    Global TVG_GetVideoDoubleBuffered.pr_GetVideoDoubleBuffered                                                               = GetFunction(gnTVGLibrary, "_GetVideoDoubleBuffered")
    Global TVG_GetVideoFormat.pr_GetVideoFormat                                                                               = GetFunction(gnTVGLibrary, "_GetVideoFormat")
    Global TVG_GetVideoFormats.pr_GetVideoFormats                                                                             = GetFunction(gnTVGLibrary, "_GetVideoFormats")
    Global TVG_GetVideoFormatsCount.pr_GetVideoFormatsCount                                                                   = GetFunction(gnTVGLibrary, "_GetVideoFormatsCount")
    Global TVG_GetVideoFromImages_BitmapsSortedBy.pr_GetVideoFromImages_BitmapsSortedBy                                       = GetFunction(gnTVGLibrary, "_GetVideoFromImages_BitmapsSortedBy")
    Global TVG_GetVideoFromImages_RepeatIndefinitely.pr_GetVideoFromImages_RepeatIndefinitely                                 = GetFunction(gnTVGLibrary, "_GetVideoFromImages_RepeatIndefinitely")
    Global TVG_GetVideoFromImages_SourceDirectory.pr_GetVideoFromImages_SourceDirectory                                       = GetFunction(gnTVGLibrary, "_GetVideoFromImages_SourceDirectory")
    Global TVG_GetVideoFromImages_TemporaryFile.pr_GetVideoFromImages_TemporaryFile                                           = GetFunction(gnTVGLibrary, "_GetVideoFromImages_TemporaryFile")
    Global TVG_GetVideoHeight.pr_GetVideoHeight                                                                               = GetFunction(gnTVGLibrary, "_GetVideoHeight")
    Global TVG_GetVideoHeight_PreferredAspectRatio.pr_GetVideoHeight_PreferredAspectRatio                                     = GetFunction(gnTVGLibrary, "_GetVideoHeight_PreferredAspectRatio")
    Global TVG_GetVideoHeightFromIndex.pr_GetVideoHeightFromIndex                                                             = GetFunction(gnTVGLibrary, "_GetVideoHeightFromIndex")
    Global TVG_GetVideoInput.pr_GetVideoInput                                                                                 = GetFunction(gnTVGLibrary, "_GetVideoInput")
    Global TVG_GetVideoInputs.pr_GetVideoInputs                                                                               = GetFunction(gnTVGLibrary, "_GetVideoInputs")
    Global TVG_GetVideoInputsCount.pr_GetVideoInputsCount                                                                     = GetFunction(gnTVGLibrary, "_GetVideoInputsCount")
    Global TVG_GetVideoProcessingBrightness.pr_GetVideoProcessingBrightness                                                   = GetFunction(gnTVGLibrary, "_GetVideoProcessingBrightness")
    Global TVG_GetVideoProcessingContrast.pr_GetVideoProcessingContrast                                                       = GetFunction(gnTVGLibrary, "_GetVideoProcessingContrast")
    Global TVG_GetVideoProcessingDeinterlacing.pr_GetVideoProcessingDeinterlacing                                             = GetFunction(gnTVGLibrary, "_GetVideoProcessingDeinterlacing")
    Global TVG_GetVideoProcessingFlipHorizontal.pr_GetVideoProcessingFlipHorizontal                                           = GetFunction(gnTVGLibrary, "_GetVideoProcessingLeftRight")
    Global TVG_GetVideoProcessingFlipVertical.pr_GetVideoProcessingFlipVertical                                               = GetFunction(gnTVGLibrary, "_GetVideoProcessingTopDown")
    Global TVG_GetVideoProcessingGrayScale.pr_GetVideoProcessingGrayScale                                                     = GetFunction(gnTVGLibrary, "_GetVideoProcessingGrayScale")
    Global TVG_GetVideoProcessingHue.pr_GetVideoProcessingHue                                                                 = GetFunction(gnTVGLibrary, "_GetVideoProcessingHue")
    Global TVG_GetVideoProcessingInvertColors.pr_GetVideoProcessingInvertColors                                               = GetFunction(gnTVGLibrary, "_GetVideoProcessingInvertColors")
    Global TVG_GetVideoProcessingLeftRight.pr_GetVideoProcessingLeftRight                                                     = GetFunction(gnTVGLibrary, "_GetVideoProcessingLeftRight")
    Global TVG_GetVideoProcessingPixellization.pr_GetVideoProcessingPixellization                                             = GetFunction(gnTVGLibrary, "_GetVideoProcessingPixellization")
    Global TVG_GetVideoProcessingRotation.pr_GetVideoProcessingRotation                                                       = GetFunction(gnTVGLibrary, "_GetVideoProcessingRotation")
    Global TVG_GetVideoProcessingRotationCustomAngle.pr_GetVideoProcessingRotationCustomAngle                                 = GetFunction(gnTVGLibrary, "_GetVideoProcessingRotationCustomAngle")
    Global TVG_GetVideoProcessingSaturation.pr_GetVideoProcessingSaturation                                                   = GetFunction(gnTVGLibrary, "_GetVideoProcessingSaturation")
    Global TVG_GetVideoProcessingTopDown.pr_GetVideoProcessingTopDown                                                         = GetFunction(gnTVGLibrary, "_GetVideoProcessingTopDown")
    Global TVG_GetVideoQualitySettings.pr_GetVideoQualitySettings                                                             = GetFunction(gnTVGLibrary, "_GetVideoQualitySettings")
    Global TVG_GetVideoRenderer.pr_GetVideoRenderer                                                                           = GetFunction(gnTVGLibrary, "_GetVideoRenderer")
    Global TVG_GetVideoRendererExternal.pr_GetVideoRendererExternal                                                           = GetFunction(gnTVGLibrary, "_GetVideoRendererExternal")
    Global TVG_GetVideoRendererExternalIndex.pr_GetVideoRendererExternalIndex                                                 = GetFunction(gnTVGLibrary, "_GetVideoRendererExternalIndex")
    Global TVG_GetVideoRendererPriority.pr_GetVideoRendererPriority                                                           = GetFunction(gnTVGLibrary, "_GetVideoRendererPriority")
    Global TVG_GetVideoSize.pr_GetVideoSize                                                                                   = GetFunction(gnTVGLibrary, "_GetVideoSize")
    Global TVG_GetVideoSizeFromIndex.pr_GetVideoSizeFromIndex                                                                 = GetFunction(gnTVGLibrary, "_GetVideoSizeFromIndex")
    Global TVG_GetVideoSizes.pr_GetVideoSizes                                                                                 = GetFunction(gnTVGLibrary, "_GetVideoSizes")
    Global TVG_GetVideoSizesCount.pr_GetVideoSizesCount                                                                       = GetFunction(gnTVGLibrary, "_GetVideoSizesCount")
    Global TVG_GetVideoSource.pr_GetVideoSource                                                                               = GetFunction(gnTVGLibrary, "_GetVideoSource")
    Global TVG_GetVideoSource_FileOrURL.pr_GetVideoSource_FileOrURL                                                           = GetFunction(gnTVGLibrary, "_GetVideoSource_FileOrURL")
    Global TVG_GetVideoSource_FileOrURL_StartTime.pr_GetVideoSource_FileOrURL_StartTime                                       = GetFunction(gnTVGLibrary, "_GetVideoSource_FileOrURL_StartTime")
    Global TVG_GetVideoSource_FileOrURL_StopTime.pr_GetVideoSource_FileOrURL_StopTime                                         = GetFunction(gnTVGLibrary, "_GetVideoSource_FileOrURL_StopTime")
    Global TVG_GetVideoSources.pr_GetVideoSources                                                                             = GetFunction(gnTVGLibrary, "_GetVideoSources")
    Global TVG_GetVideoSourcesCount.pr_GetVideoSourcesCount                                                                   = GetFunction(gnTVGLibrary, "_GetVideoSourcesCount")
    Global TVG_GetVideoStreamNumber.pr_GetVideoStreamNumber                                                                   = GetFunction(gnTVGLibrary, "_GetVideoStreamNumber")
    Global TVG_GetVideoSubtype.pr_GetVideoSubtype                                                                             = GetFunction(gnTVGLibrary, "_GetVideoSubtype")
    Global TVG_GetVideoSubtypes.pr_GetVideoSubtypes                                                                           = GetFunction(gnTVGLibrary, "_GetVideoSubtypes")
    Global TVG_GetVideoSubtypesCount.pr_GetVideoSubtypesCount                                                                 = GetFunction(gnTVGLibrary, "_GetVideoSubtypesCount")
    Global TVG_GetVideoVisibleWhenStopped.pr_GetVideoVisibleWhenStopped                                                       = GetFunction(gnTVGLibrary, "_GetVideoVisibleWhenStopped")
    Global TVG_GetVideoWidth.pr_GetVideoWidth                                                                                 = GetFunction(gnTVGLibrary, "_GetVideoWidth")
    Global TVG_GetVideoWidth_PreferredAspectRatio.pr_GetVideoWidth_PreferredAspectRatio                                       = GetFunction(gnTVGLibrary, "_GetVideoWidth_PreferredAspectRatio")
    Global TVG_GetVideoWidthFromIndex.pr_GetVideoWidthFromIndex                                                               = GetFunction(gnTVGLibrary, "_GetVideoWidthFromIndex")
    Global TVG_GetVirtualAudioStreamControl.pr_GetVirtualAudioStreamControl                                                   = GetFunction(gnTVGLibrary, "_GetVirtualAudioStreamControl")
    Global TVG_GetVirtualVideoStreamControl.pr_GetVirtualVideoStreamControl                                                   = GetFunction(gnTVGLibrary, "_GetVirtualVideoStreamControl")
    Global TVG_GetVMR9ImageAdjustmentBounds.pr_GetVMR9ImageAdjustmentBounds                                                   = GetFunction(gnTVGLibrary, "_GetVMR9ImageAdjustmentBounds")
    Global TVG_GetVuMeter.pr_GetVuMeter                                                                                       = GetFunction(gnTVGLibrary, "_GetVuMeter")
    Global TVG_GetVuMeter_Enabled.pr_GetVuMeter_Enabled                                                                       = GetFunction(gnTVGLibrary, "_GetVuMeter_Enabled")
    Global TVG_GetVUMeterSetting.pr_GetVUMeterSetting                                                                         = GetFunction(gnTVGLibrary, "_GetVUMeterSetting")
    Global TVG_GetWebcamStillCaptureButton.pr_GetWebcamStillCaptureButton                                                     = GetFunction(gnTVGLibrary, "_GetWebcamStillCaptureButton")
    Global TVG_GetZoomCoeff.pr_GetZoomCoeff                                                                                   = GetFunction(gnTVGLibrary, "_GetZoomCoeff")
    Global TVG_GetZoomXCenter.pr_GetZoomXCenter                                                                               = GetFunction(gnTVGLibrary, "_GetZoomXCenter")
    Global TVG_GetZoomYCenter.pr_GetZoomYCenter                                                                               = GetFunction(gnTVGLibrary, "_GetZoomYCenter")
    Global TVG_GraphState.pr_GraphState                                                                                       = GetFunction(gnTVGLibrary, "_GraphState")
    Global TVG_InitSyncMgr.pr_InitSyncMgr                                                                                     = GetFunction(gnTVGLibrary, "_InitSyncMgr")
    Global TVG_IsAudioDeviceASoundCard.pr_IsAudioDeviceASoundCard                                                             = GetFunction(gnTVGLibrary, "_IsAudioDeviceASoundCard")
    Global TVG_IsAudioDeviceConnected.pr_IsAudioDeviceConnected                                                               = GetFunction(gnTVGLibrary, "_IsAudioDeviceConnected")
    Global TVG_IsAudioRendererConnected.pr_IsAudioRendererConnected                                                           = GetFunction(gnTVGLibrary, "_IsAudioRendererConnected")
    Global TVG_IsCameraControlSettingAvailable.pr_IsCameraControlSettingAvailable                                             = GetFunction(gnTVGLibrary, "_IsCameraControlSettingAvailable")
    Global TVG_IsDialogAvailable.pr_IsDialogAvailable                                                                         = GetFunction(gnTVGLibrary, "_IsDialogAvailable")
    Global TVG_IsDirectX8OrHigherInstalled.pr_IsDirectX8OrHigherInstalled                                                     = GetFunction(gnTVGLibrary, "_IsDirectX8OrHigherInstalled")
    Global TVG_IsDVDevice.pr_IsDVDevice                                                                                       = GetFunction(gnTVGLibrary, "_IsDVDevice")
    Global TVG_IsPlaylistActive.pr_IsPlaylistActive                                                                           = GetFunction(gnTVGLibrary, "_IsPlaylistActive")
    Global TVG_IsPreviewStarted.pr_IsPreviewStarted                                                                           = GetFunction(gnTVGLibrary, "_IsPreviewStarted")
    Global TVG_IsServerResponding.pr_IsServerResponding                                                                       = GetFunction(gnTVGLibrary, "_IsServerResponding")
    Global TVG_IsURLResponding.pr_IsURLResponding                                                                             = GetFunction(gnTVGLibrary, "_IsURLResponding")
    Global TVG_IsURLVideoStreamAvailable.pr_IsURLVideoStreamAvailable                                                         = GetFunction(gnTVGLibrary, "_IsURLVideoStreamAvailable")
    Global TVG_IsVideoControlModeAvailable.pr_IsVideoControlModeAvailable                                                     = GetFunction(gnTVGLibrary, "_IsVideoControlModeAvailable")
    Global TVG_IsVideoDeviceConnected.pr_IsVideoDeviceConnected                                                               = GetFunction(gnTVGLibrary, "_IsVideoDeviceConnected")
    Global TVG_IsVideoQualitySettingAvailable.pr_IsVideoQualitySettingAvailable                                               = GetFunction(gnTVGLibrary, "_IsVideoQualitySettingAvailable")
    Global TVG_IsVideoSignalDetected.pr_IsVideoSignalDetected                                                                 = GetFunction(gnTVGLibrary, "_IsVideoSignalDetected")
    Global TVG_IsVMR9ImageAdjustmentAvailable.pr_IsVMR9ImageAdjustmentAvailable                                               = GetFunction(gnTVGLibrary, "_IsVMR9ImageAdjustmentAvailable")
    Global TVG_LoadCompressorSettingsFromDataString.pr_LoadCompressorSettingsFromDataString                                   = GetFunction(gnTVGLibrary, "_LoadCompressorSettingsFromDataString")
    Global TVG_LoadCompressorSettingsFromTextFile.pr_LoadCompressorSettingsFromTextFile                                       = GetFunction(gnTVGLibrary, "_LoadCompressorSettingsFromTextFile")
    Global TVG_MixAudioSamples.pr_MixAudioSamples                                                                             = GetFunction(gnTVGLibrary, "_MixAudioSamples")
    Global TVG_Mixer_Activation.pr_Mixer_Activation                                                                           = GetFunction(gnTVGLibrary, "_Mixer_Activation")
    Global TVG_Mixer_AddAudioToMixer.pr_Mixer_AddAudioToMixer                                                                 = GetFunction(gnTVGLibrary, "_Mixer_AddAudioToMixer")
    Global TVG_Mixer_AddToMixer.pr_Mixer_AddToMixer                                                                           = GetFunction(gnTVGLibrary, "_Mixer_AddToMixer")
    Global TVG_Mixer_AudioActivation.pr_Mixer_AudioActivation                                                                 = GetFunction(gnTVGLibrary, "_Mixer_AudioActivation")
    Global TVG_Mixer_RemoveAudioFromMixer.pr_Mixer_RemoveAudioFromMixer                                                       = GetFunction(gnTVGLibrary, "_Mixer_RemoveAudioFromMixer")
    Global TVG_Mixer_RemoveFromMixer.pr_Mixer_RemoveFromMixer                                                                 = GetFunction(gnTVGLibrary, "_Mixer_RemoveFromMixer")
    Global TVG_Mixer_SetOverlayAttributes.pr_Mixer_SetOverlayAttributes                                                       = GetFunction(gnTVGLibrary, "_Mixer_SetOverlayAttributes")
    Global TVG_Mixer_SetupPIPFromSource.pr_Mixer_SetupPIPFromSource                                                           = GetFunction(gnTVGLibrary, "_Mixer_SetupPIPFromSource")
    Global TVG_Monitor_Primary_Index.pr_Monitor_Primary_Index                                                                 = GetFunction(gnTVGLibrary, "_Monitor_Primary_Index")
    Global TVG_MonitorBounds.pr_MonitorBounds                                                                                 = GetFunction(gnTVGLibrary, "_MonitorBounds")
    Global TVG_MonitorsCount.pr_MonitorsCount                                                                                 = GetFunction(gnTVGLibrary, "_MonitorsCount")
    Global TVG_MotionDetector_CellColorIntensity.pr_MotionDetector_CellColorIntensity                                         = GetFunction(gnTVGLibrary, "_MotionDetector_CellColorIntensity")
    Global TVG_MotionDetector_CellMotionRatio.pr_MotionDetector_CellMotionRatio                                               = GetFunction(gnTVGLibrary, "_MotionDetector_CellMotionRatio")
    Global TVG_MotionDetector_Get2DTextGrid.pr_MotionDetector_Get2DTextGrid                                                   = GetFunction(gnTVGLibrary, "_MotionDetector_Get2DTextGrid")
    Global TVG_MotionDetector_Get2DTextMotion.pr_MotionDetector_Get2DTextMotion                                               = GetFunction(gnTVGLibrary, "_MotionDetector_Get2DTextMotion")
    Global TVG_MotionDetector_GetCellLocation.pr_MotionDetector_GetCellLocation                                               = GetFunction(gnTVGLibrary, "_MotionDetector_GetCellLocation")
    Global TVG_MotionDetector_GetCellSensitivity.pr_MotionDetector_GetCellSensitivity                                         = GetFunction(gnTVGLibrary, "_MotionDetector_GetCellSensitivity")
    Global TVG_MotionDetector_GetCellSize.pr_MotionDetector_GetCellSize                                                       = GetFunction(gnTVGLibrary, "_MotionDetector_GetCellSize")
    Global TVG_MotionDetector_GlobalColorIntensity.pr_MotionDetector_GlobalColorIntensity                                     = GetFunction(gnTVGLibrary, "_MotionDetector_GlobalColorIntensity")
    Global TVG_MotionDetector_GloballyIncOrDecSensitivity.pr_MotionDetector_GloballyIncOrDecSensitivity                       = GetFunction(gnTVGLibrary, "_MotionDetector_GloballyIncOrDecSensitivity")
    Global TVG_MotionDetector_Reset.pr_MotionDetector_Reset                                                                   = GetFunction(gnTVGLibrary, "_MotionDetector_Reset")
    Global TVG_MotionDetector_ResetGlobalSensitivity.pr_MotionDetector_ResetGlobalSensitivity                                 = GetFunction(gnTVGLibrary, "_MotionDetector_ResetGlobalSensitivity")
    Global TVG_MotionDetector_SetCellSensitivity.pr_MotionDetector_SetCellSensitivity                                         = GetFunction(gnTVGLibrary, "_MotionDetector_SetCellSensitivity")
    Global TVG_MotionDetector_SetGridSize.pr_MotionDetector_SetGridSize                                                       = GetFunction(gnTVGLibrary, "_MotionDetector_SetGridSize")
    Global TVG_MotionDetector_ShowGridDialog.pr_MotionDetector_ShowGridDialog                                                 = GetFunction(gnTVGLibrary, "_MotionDetector_ShowGridDialog")
    Global TVG_MotionDetector_TriggerNow.pr_MotionDetector_TriggerNow                                                         = GetFunction(gnTVGLibrary, "_MotionDetector_TriggerNow")
    Global TVG_MotionDetector_UseThisReferenceSample.pr_MotionDetector_UseThisReferenceSample                                 = GetFunction(gnTVGLibrary, "_MotionDetector_UseThisReferenceSample")
    Global TVG_MPEGProgramSetting.pr_MPEGProgramSetting                                                                       = GetFunction(gnTVGLibrary, "_MPEGProgramSetting")
    Global TVG_MultiplexerIndex.pr_MultiplexerIndex                                                                           = GetFunction(gnTVGLibrary, "_MultiplexerIndex")
    Global TVG_MultipurposeEncoder_Convert100nsToHhMmSsZzz.pr_MultipurposeEncoder_Convert100nsToHhMmSsZzz                     = GetFunction(gnTVGLibrary, "_MultipurposeEncoder_Convert100nsToHhMmSsZzz")
    Global TVG_MultipurposeEncoder_GetCurrentInfo.pr_MultipurposeEncoder_GetCurrentInfo                                       = GetFunction(gnTVGLibrary, "_MultipurposeEncoder_GetCurrentInfo")
    Global TVG_MultipurposeEncoder_GetLastLog.pr_MultipurposeEncoder_GetLastLog                                               = GetFunction(gnTVGLibrary, "_MultipurposeEncoder_GetLastLog")
    Global TVG_MultipurposeEncoder_QuickConfigure_UDPStreaming_H264.pr_MultipurposeEncoder_QuickConfigure_UDPStreaming_H264   = GetFunction(gnTVGLibrary, "_MultipurposeEncoder_QuickConfigure_UDPStreaming_H264")
    Global TVG_MultipurposeEncoder_ReindexClip.pr_MultipurposeEncoder_ReindexClip                                             = GetFunction(gnTVGLibrary, "_MultipurposeEncoder_ReindexClip")
    Global TVG_NotifyPlayerTrackbarAction.pr_NotifyPlayerTrackbarAction                                                       = GetFunction(gnTVGLibrary, "_NotifyPlayerTrackbarAction")
    Global TVG_ONVIF_GetBool.pr_ONVIF_GetBool                                                                                 = GetFunction(gnTVGLibrary, "_ONVIF_GetBool")
    Global TVG_ONVIF_GetDouble.pr_ONVIF_GetDouble                                                                             = GetFunction(gnTVGLibrary, "_ONVIF_GetDouble")
    Global TVG_ONVIF_GetInt.pr_ONVIF_GetInt                                                                                   = GetFunction(gnTVGLibrary, "_ONVIF_GetInt")
    Global TVG_ONVIF_GetStr.pr_ONVIF_GetStr                                                                                   = GetFunction(gnTVGLibrary, "_ONVIF_GetStr")
    Global TVG_ONVIF_SetBool.pr_ONVIF_SetBool                                                                                 = GetFunction(gnTVGLibrary, "_ONVIF_SetBool")
    Global TVG_ONVIF_SetDouble.pr_ONVIF_SetDouble                                                                             = GetFunction(gnTVGLibrary, "_ONVIF_SetDouble")
    Global TVG_ONVIF_SetInt.pr_ONVIF_SetInt                                                                                   = GetFunction(gnTVGLibrary, "_ONVIF_SetInt")
    Global TVG_ONVIF_SetStr.pr_ONVIF_SetStr                                                                                   = GetFunction(gnTVGLibrary, "_ONVIF_SetStr")
    Global TVG_ONVIFCancelDiscovery.pr_ONVIFCancelDiscovery                                                                   = GetFunction(gnTVGLibrary, "_ONVIFCancelDiscovery")
    Global TVG_ONVIFDeviceInfo.pr_ONVIFDeviceInfo                                                                             = GetFunction(gnTVGLibrary, "_ONVIFDeviceInfo")
    Global TVG_ONVIFDiscoverCameras_IPRange.pr_ONVIFDiscoverCameras_IPRange                                                   = GetFunction(gnTVGLibrary, "_ONVIFDiscoverCameras_IPRange")
    Global TVG_ONVIFDiscoverCameras_Multicast.pr_ONVIFDiscoverCameras_Multicast                                               = GetFunction(gnTVGLibrary, "_ONVIFDiscoverCameras_Multicast")
    Global TVG_ONVIFEnumCamerasDiscovered.pr_ONVIFEnumCamerasDiscovered                                                       = GetFunction(gnTVGLibrary, "_ONVIFEnumCamerasDiscovered")
    Global TVG_ONVIFPTZGetLimits.pr_ONVIFPTZGetLimits                                                                         = GetFunction(gnTVGLibrary, "_ONVIFPTZGetLimits")
    Global TVG_ONVIFPTZGetPosition.pr_ONVIFPTZGetPosition                                                                     = GetFunction(gnTVGLibrary, "_ONVIFPTZGetPosition")
    Global TVG_ONVIFPTZPreset.pr_ONVIFPTZPreset                                                                               = GetFunction(gnTVGLibrary, "_ONVIFPTZPreset")
    Global TVG_ONVIFPTZSendAuxiliaryCommand.pr_ONVIFPTZSendAuxiliaryCommand                                                   = GetFunction(gnTVGLibrary, "_ONVIFPTZSendAuxiliaryCommand")
    Global TVG_ONVIFPTZSetPosition.pr_ONVIFPTZSetPosition                                                                     = GetFunction(gnTVGLibrary, "_ONVIFPTZSetPosition")
    Global TVG_ONVIFPTZStartMove.pr_ONVIFPTZStartMove                                                                         = GetFunction(gnTVGLibrary, "_ONVIFPTZStartMove")
    Global TVG_ONVIFPTZStopMove.pr_ONVIFPTZStopMove                                                                           = GetFunction(gnTVGLibrary, "_ONVIFPTZStopMove")
    Global TVG_ONVIFSnapShot.pr_ONVIFSnapShot                                                                                 = GetFunction(gnTVGLibrary, "_ONVIFSnapShot")
    Global TVG_OpenDVD.pr_OpenDVD                                                                                             = GetFunction(gnTVGLibrary, "_OpenDVD")
    Global TVG_OpenPlayer.pr_OpenPlayer                                                                                       = GetFunction(gnTVGLibrary, "_OpenPlayer")
    Global TVG_OpenPlayerAtFramePositions.pr_OpenPlayerAtFramePositions                                                       = GetFunction(gnTVGLibrary, "_OpenPlayerAtFramePositions")
    Global TVG_OpenPlayerAtTimePositions.pr_OpenPlayerAtTimePositions                                                         = GetFunction(gnTVGLibrary, "_OpenPlayerAtTimePositions")
    Global TVG_OpenURLAsyncStatus.pr_OpenURLAsyncStatus                                                                       = GetFunction(gnTVGLibrary, "_OpenURLAsyncStatus")
    Global TVG_PausePlayer.pr_PausePlayer                                                                                     = GetFunction(gnTVGLibrary, "_PausePlayer")
    Global TVG_PausePreview.pr_PausePreview                                                                                   = GetFunction(gnTVGLibrary, "_PausePreview")
    Global TVG_PauseRecording.pr_PauseRecording                                                                               = GetFunction(gnTVGLibrary, "_PauseRecording")
    Global TVG_PlayerFrameStep.pr_PlayerFrameStep                                                                             = GetFunction(gnTVGLibrary, "_PlayerFrameStep")
    Global TVG_Playlist.pr_Playlist                                                                                           = GetFunction(gnTVGLibrary, "_Playlist")
    Global TVG_PointGreyConfig.pr_PointGreyConfig                                                                             = GetFunction(gnTVGLibrary, "_PointGreyConfig")
    Global TVG_PreloadFilters.pr_PreloadFilters                                                                               = GetFunction(gnTVGLibrary, "_PreloadFilters")
    Global TVG_PutMiscDeviceControl.pr_PutMiscDeviceControl                                                                   = GetFunction(gnTVGLibrary, "_PutMiscDeviceControl")
    Global TVG_RecordingKBytesWrittenToDisk.pr_RecordingKBytesWrittenToDisk                                                   = GetFunction(gnTVGLibrary, "_RecordingKBytesWrittenToDisk")
    Global TVG_RecordToNewFileNow.pr_RecordToNewFileNow                                                                       = GetFunction(gnTVGLibrary, "_RecordToNewFileNow")
    Global TVG_ReencodeVideoClip.pr_ReencodeVideoClip                                                                         = GetFunction(gnTVGLibrary, "_ReencodeVideoClip")
    Global TVG_RefreshDevicesAndCompressorsLists.pr_RefreshDevicesAndCompressorsLists                                         = GetFunction(gnTVGLibrary, "_RefreshDevicesAndCompressorsLists")
    Global TVG_RefreshPlayerOverlays.pr_RefreshPlayerOverlays                                                                 = GetFunction(gnTVGLibrary, "_RefreshPlayerOverlays")
    Global TVG_ResetPreview.pr_ResetPreview                                                                                   = GetFunction(gnTVGLibrary, "_ResetPreview")
    Global TVG_ResetVideoDeviceSettings.pr_ResetVideoDeviceSettings                                                           = GetFunction(gnTVGLibrary, "_ResetVideoDeviceSettings")
    Global TVG_ResumePreview.pr_ResumePreview                                                                                 = GetFunction(gnTVGLibrary, "_ResumePreview")
    Global TVG_ResumeRecording.pr_ResumeRecording                                                                             = GetFunction(gnTVGLibrary, "_ResumeRecording")
    Global TVG_RetrieveInitialXYAfterRotation.pr_RetrieveInitialXYAfterRotation                                               = GetFunction(gnTVGLibrary, "_RetrieveInitialXYAfterRotation")
    Global TVG_RewindPlayer.pr_RewindPlayer                                                                                   = GetFunction(gnTVGLibrary, "_RewindPlayer")
    Global TVG_RunPlayer.pr_RunPlayer                                                                                         = GetFunction(gnTVGLibrary, "_RunPlayer")
    Global TVG_RunPlayerBackwards.pr_RunPlayerBackwards                                                                       = GetFunction(gnTVGLibrary, "_RunPlayerBackwards")
    Global TVG_SaveCompressorSettingsToDataString.pr_SaveCompressorSettingsToDataString                                       = GetFunction(gnTVGLibrary, "_SaveCompressorSettingsToDataString")
    Global TVG_SaveCompressorSettingsToTextFile.pr_SaveCompressorSettingsToTextFile                                           = GetFunction(gnTVGLibrary, "_SaveCompressorSettingsToTextFile")
    Global TVG_ScheduleNextActionAtAbsoluteDateTime.pr_ScheduleNextActionAtAbsoluteDateTime                                   = GetFunction(gnTVGLibrary, "_ScheduleNextActionAtAbsoluteDateTime")
    Global TVG_ScheduleNextActionAtAbsoluteTime.pr_ScheduleNextActionAtAbsoluteTime                                           = GetFunction(gnTVGLibrary, "_ScheduleNextActionAtAbsoluteTime")
    Global TVG_ScheduleNextActionFromNow.pr_ScheduleNextActionFromNow                                                         = GetFunction(gnTVGLibrary, "_ScheduleNextActionFromNow")
    Global TVG_ScreenRecordingUsingCoordinates.pr_ScreenRecordingUsingCoordinates                                             = GetFunction(gnTVGLibrary, "_ScreenRecordingUsingCoordinates")
    Global TVG_SendCameraCommand.pr_SendCameraCommand                                                                         = GetFunction(gnTVGLibrary, "_SendCameraCommand")
    Global TVG_SendDVCommand.pr_SendDVCommand                                                                                 = GetFunction(gnTVGLibrary, "_SendDVCommand")
    Global TVG_SendImageToVideoFromBitmaps.pr_SendImageToVideoFromBitmaps                                                     = GetFunction(gnTVGLibrary, "_SendImageToVideoFromBitmaps")
    Global TVG_SendImageToVideoFromBitmaps2.pr_SendImageToVideoFromBitmaps2                                                   = GetFunction(gnTVGLibrary, "_SendImageToVideoFromBitmaps2")
    Global TVG_SendIPCameraCommand.pr_SendIPCameraCommand                                                                     = GetFunction(gnTVGLibrary, "_SendIPCameraCommand")
    Global TVG_Set_OnDeviceArrivalOrRemoval.pr_Set_OnDeviceArrivalOrRemoval                                                   = GetFunction(gnTVGLibrary, "_Set_OnDeviceArrivalOrRemoval")
    Global TVG_SetAdjustOverlayAspectRatio.pr_SetAdjustOverlayAspectRatio                                                     = GetFunction(gnTVGLibrary, "_SetAdjustOverlayAspectRatio")
    Global TVG_SetAdjustPixelAspectRatio.pr_SetAdjustPixelAspectRatio                                                         = GetFunction(gnTVGLibrary, "_SetAdjustPixelAspectRatio")
    Global TVG_SetAero.pr_SetAero                                                                                             = GetFunction(gnTVGLibrary, "_SetAero")
    Global TVG_SetAnalogVideoStandard.pr_SetAnalogVideoStandard                                                               = GetFunction(gnTVGLibrary, "_SetAnalogVideoStandard")
    Global TVG_SetApplicationPriority.pr_SetApplicationPriority                                                               = GetFunction(gnTVGLibrary, "_SetApplicationPriority")
    Global TVG_SetASFAudioBitRate.pr_SetASFAudioBitRate                                                                       = GetFunction(gnTVGLibrary, "_SetASFAudioBitRate")
    Global TVG_SetASFAudioChannels.pr_SetASFAudioChannels                                                                     = GetFunction(gnTVGLibrary, "_SetASFAudioChannels")
    Global TVG_SetASFBufferWindow.pr_SetASFBufferWindow                                                                       = GetFunction(gnTVGLibrary, "_SetASFBufferWindow")
    Global TVG_SetASFDeinterlaceMode.pr_SetASFDeinterlaceMode                                                                 = GetFunction(gnTVGLibrary, "_SetASFDeinterlaceMode")
    Global TVG_SetASFDirectStreamingKeepClientsConnected.pr_SetASFDirectStreamingKeepClientsConnected                         = GetFunction(gnTVGLibrary, "_SetASFDirectStreamingKeepClientsConnected")
    Global TVG_SetASFFixedFrameRate.pr_SetASFFixedFrameRate                                                                   = GetFunction(gnTVGLibrary, "_SetASFFixedFrameRate")
    Global TVG_SetASFMediaServerPublishingPoint.pr_SetASFMediaServerPublishingPoint                                           = GetFunction(gnTVGLibrary, "_SetASFMediaServerPublishingPoint")
    Global TVG_SetASFMediaServerRemovePublishingPointAfterDisconnect.pr_SetASFMediaServerRemovePublishingPointAfterDisconnect = GetFunction(gnTVGLibrary, "_SetASFMediaServerRemovePublishingPointAfterDisconnect")
    Global TVG_SetASFMediaServerTemplatePublishingPoint.pr_SetASFMediaServerTemplatePublishingPoint                           = GetFunction(gnTVGLibrary, "_SetASFMediaServerTemplatePublishingPoint")
    Global TVG_SetASFNetworkMaxUsers.pr_SetASFNetworkMaxUsers                                                                 = GetFunction(gnTVGLibrary, "_SetASFNetworkMaxUsers")
    Global TVG_SetASFNetworkPort.pr_SetASFNetworkPort                                                                         = GetFunction(gnTVGLibrary, "_SetASFNetworkPort")
    Global TVG_SetASFProfile.pr_SetASFProfile                                                                                 = GetFunction(gnTVGLibrary, "_SetASFProfile")
    Global TVG_SetASFProfileFromCustomFile.pr_SetASFProfileFromCustomFile                                                     = GetFunction(gnTVGLibrary, "_SetASFProfileFromCustomFile")
    Global TVG_SetASFProfileVersion.pr_SetASFProfileVersion                                                                   = GetFunction(gnTVGLibrary, "_SetASFProfileVersion")
    Global TVG_SetASFVideoBitRate.pr_SetASFVideoBitRate                                                                       = GetFunction(gnTVGLibrary, "_SetASFVideoBitRate")
    Global TVG_SetASFVideoFrameRate.pr_SetASFVideoFrameRate                                                                   = GetFunction(gnTVGLibrary, "_SetASFVideoFrameRate")
    Global TVG_SetASFVideoHeight.pr_SetASFVideoHeight                                                                         = GetFunction(gnTVGLibrary, "_SetASFVideoHeight")
    Global TVG_SetASFVideoMaxKeyFrameSpacing.pr_SetASFVideoMaxKeyFrameSpacing                                                 = GetFunction(gnTVGLibrary, "_SetASFVideoMaxKeyFrameSpacing")
    Global TVG_SetASFVideoQuality.pr_SetASFVideoQuality                                                                       = GetFunction(gnTVGLibrary, "_SetASFVideoQuality")
    Global TVG_SetASFVideoWidth.pr_SetASFVideoWidth                                                                           = GetFunction(gnTVGLibrary, "_SetASFVideoWidth")
    Global TVG_SetAspectRatioToUse.pr_SetAspectRatioToUse                                                                     = GetFunction(gnTVGLibrary, "_SetAspectRatioToUse")
    Global TVG_SetAssociateAudioAndVideoDevices.pr_SetAssociateAudioAndVideoDevices                                           = GetFunction(gnTVGLibrary, "_SetAssociateAudioAndVideoDevices")
    Global TVG_SetAudioBalance.pr_SetAudioBalance                                                                             = GetFunction(gnTVGLibrary, "_SetAudioBalance")
    Global TVG_SetAudioChannelRenderMode.pr_SetAudioChannelRenderMode                                                         = GetFunction(gnTVGLibrary, "_SetAudioChannelRenderMode")
    Global TVG_SetAudioCompressor.pr_SetAudioCompressor                                                                       = GetFunction(gnTVGLibrary, "_SetAudioCompressor")
    Global TVG_SetAudioDevice.pr_SetAudioDevice                                                                               = GetFunction(gnTVGLibrary, "_SetAudioDevice")
    Global TVG_SetAudioDeviceRendering.pr_SetAudioDeviceRendering                                                             = GetFunction(gnTVGLibrary, "_SetAudioDeviceRendering")
    Global TVG_SetAudioFormat.pr_SetAudioFormat                                                                               = GetFunction(gnTVGLibrary, "_SetAudioFormat")
    Global TVG_SetAudioInput.pr_SetAudioInput                                                                                 = GetFunction(gnTVGLibrary, "_SetAudioInput")
    Global TVG_SetAudioInputBalance.pr_SetAudioInputBalance                                                                   = GetFunction(gnTVGLibrary, "_SetAudioInputBalance")
    Global TVG_SetAudioInputLevel.pr_SetAudioInputLevel                                                                       = GetFunction(gnTVGLibrary, "_SetAudioInputLevel")
    Global TVG_SetAudioInputMono.pr_SetAudioInputMono                                                                         = GetFunction(gnTVGLibrary, "_SetAudioInputMono")
    Global TVG_SetAudioPeakEvent.pr_SetAudioPeakEvent                                                                         = GetFunction(gnTVGLibrary, "_SetAudioPeakEvent")
    Global TVG_SetAudioRecording.pr_SetAudioRecording                                                                         = GetFunction(gnTVGLibrary, "_SetAudioRecording")
    Global TVG_SetAudioRenderer.pr_SetAudioRenderer                                                                           = GetFunction(gnTVGLibrary, "_SetAudioRenderer")
    Global TVG_SetAudioRendererAdditional.pr_SetAudioRendererAdditional                                                       = GetFunction(gnTVGLibrary, "_SetAudioRendererAdditional")
    Global TVG_SetAudioSource.pr_SetAudioSource                                                                               = GetFunction(gnTVGLibrary, "_SetAudioSource")
    Global TVG_SetAudioStreamNumber.pr_SetAudioStreamNumber                                                                   = GetFunction(gnTVGLibrary, "_SetAudioStreamNumber")
    Global TVG_SetAudioSyncAdjustment.pr_SetAudioSyncAdjustment                                                               = GetFunction(gnTVGLibrary, "_SetAudioSyncAdjustment")
    Global TVG_SetAudioSyncAdjustmentEnabled.pr_SetAudioSyncAdjustmentEnabled                                                 = GetFunction(gnTVGLibrary, "_SetAudioSyncAdjustmentEnabled")
    Global TVG_SetAudioVolume.pr_SetAudioVolume                                                                               = GetFunction(gnTVGLibrary, "_SetAudioVolume")
    Global TVG_SetAudioVolumeEnsabled.pr_SetAudioVolumeEnabled                                                                = GetFunction(gnTVGLibrary, "_SetAudioVolumeEnabled")
    Global TVG_SetAuthentication.pr_SetAuthentication                                                                         = GetFunction(gnTVGLibrary, "_SetAuthentication")
    Global TVG_SetAutoConnectRelatedPins.pr_SetAutoConnectRelatedPins                                                         = GetFunction(gnTVGLibrary, "_SetAutoConnectRelatedPins")
    Global TVG_SetAutoFileName.pr_SetAutoFileName                                                                             = GetFunction(gnTVGLibrary, "_SetAutoFileName")
    Global TVG_SetAutoFileNameDateTimeFormat.pr_SetAutoFileNameDateTimeFormat                                                 = GetFunction(gnTVGLibrary, "_SetAutoFileNameDateTimeFormat")
    Global TVG_SetAutoFileNameMinDigits.pr_SetAutoFileNameMinDigits                                                           = GetFunction(gnTVGLibrary, "_SetAutoFileNameMinDigits")
    Global TVG_SetAutoFilePrefix.pr_SetAutoFilePrefix                                                                         = GetFunction(gnTVGLibrary, "_SetAutoFilePrefix")
    Global TVG_SetAutoFileSuffix.pr_SetAutoFilePrefix                                                                         = GetFunction(gnTVGLibrary, "_SetAutoFileSuffix")
    Global TVG_SetAutoRefreshPreview.pr_SetAutoRefreshPreview                                                                 = GetFunction(gnTVGLibrary, "_SetAutoRefreshPreview")
    Global TVG_SetAutoStartPlayer.pr_SetAutoStartPlayer                                                                       = GetFunction(gnTVGLibrary, "_SetAutoStartPlayer")
    Global TVG_SetAVIDurationUpdated.pr_SetAVIDurationUpdated                                                                 = GetFunction(gnTVGLibrary, "_SetAVIDurationUpdated")
    Global TVG_SetAVIFormatOpenDML.pr_SetAVIFormatOpenDML                                                                     = GetFunction(gnTVGLibrary, "_SetAVIFormatOpenDML")
    Global TVG_SetAVIFormatOpenDMLCompatibilityIndex.pr_SetAVIFormatOpenDMLCompatibilityIndex                                 = GetFunction(gnTVGLibrary, "_SetAVIFormatOpenDMLCompatibilityIndex")
    Global TVG_SetAVIMuxConfig.pr_SetAVIMuxConfig                                                                             = GetFunction(gnTVGLibrary, "_SetAVIMuxConfig")
    Global TVG_SetBackgroundColor.pr_SetBackgroundColor                                                                       = GetFunction(gnTVGLibrary, "_SetBackgroundColor")
    Global TVG_SetBufferCount.pr_SetBufferCount                                                                               = GetFunction(gnTVGLibrary, "_SetBufferCount")
    Global TVG_SetBurstCount.pr_SetBurstCount                                                                                 = GetFunction(gnTVGLibrary, "_SetBurstCount")
    Global TVG_SetBurstInterval.pr_SetBurstInterval                                                                           = GetFunction(gnTVGLibrary, "_SetBurstInterval")
    Global TVG_SetBurstMode.pr_SetBurstMode                                                                                   = GetFunction(gnTVGLibrary, "_SetBurstMode")
    Global TVG_SetBurstType.pr_SetBurstType                                                                                   = GetFunction(gnTVGLibrary, "_SetBurstType")
    Global TVG_SetBusyCursor.pr_SetBusyCursor                                                                                 = GetFunction(gnTVGLibrary, "_SetBusyCursor")
    Global TVG_SetCallbackSender.pr_SetCallbackSender                                                                         = GetFunction(gnTVGLibrary, "_SetCallbackSender")
    Global TVG_SetCameraControl.pr_SetCameraControl                                                                           = GetFunction(gnTVGLibrary, "_SetCameraControl")
    Global TVG_SetCameraControlSettings.pr_SetCameraControlSettings                                                           = GetFunction(gnTVGLibrary, "_SetCameraControlSettings")
    Global TVG_SetCameraExposure.pr_SetCameraExposure                                                                         = GetFunction(gnTVGLibrary, "_SetCameraExposure")
    Global TVG_SetCaptureFileExt.pr_SetCaptureFileExt                                                                         = GetFunction(gnTVGLibrary, "_SetCaptureFileExt")
    Global TVG_SetColorKey.pr_SetColorKey                                                                                     = GetFunction(gnTVGLibrary, "_SetColorKey")
    Global TVG_SetColorKeyEnabled.pr_SetColorKeyEnabled                                                                       = GetFunction(gnTVGLibrary, "_SetColorKeyEnabled")
    Global TVG_SetCompressionMode.pr_SetCompressionMode                                                                       = GetFunction(gnTVGLibrary, "_SetCompressionMode")
    Global TVG_SetCompressionType.pr_SetCompressionType                                                                       = GetFunction(gnTVGLibrary, "_SetCompressionType")
    Global TVG_SetCropping_Enabled.pr_SetCropping_Enabled                                                                     = GetFunction(gnTVGLibrary, "_SetCropping_Enabled")
    Global TVG_SetCropping_Height.pr_SetCropping_Height                                                                       = GetFunction(gnTVGLibrary, "_SetCropping_Height")
    Global TVG_SetCropping_Outbounds.pr_SetCropping_Outbounds                                                                 = GetFunction(gnTVGLibrary, "_SetCropping_Outbounds")
    Global TVG_SetCropping_Width.pr_SetCropping_Width                                                                         = GetFunction(gnTVGLibrary, "_SetCropping_Width")
    Global TVG_SetCropping_X.pr_SetCropping_X                                                                                 = GetFunction(gnTVGLibrary, "_SetCropping_X")
    Global TVG_SetCropping_Y.pr_SetCropping_Y                                                                                 = GetFunction(gnTVGLibrary, "_SetCropping_Y")
    Global TVG_SetCropping_Zoom.pr_SetCropping_Zoom                                                                           = GetFunction(gnTVGLibrary, "_SetCropping_Zoom")
    Global TVG_SetDisplayActive.pr_SetDisplayActive                                                                           = GetFunction(gnTVGLibrary, "_SetDisplayActive")
    Global TVG_SetDisplayAlphaBlendEnabled.pr_SetDisplayAlphaBlendEnabled                                                     = GetFunction(gnTVGLibrary, "_SetDisplayAlphaBlendEnabled")
    Global TVG_SetDisplayAlphaBlendValue.pr_SetDisplayAlphaBlendValue                                                         = GetFunction(gnTVGLibrary, "_SetDisplayAlphaBlendValue")
    Global TVG_SetDisplayAspectRatio.pr_SetDisplayAspectRatio                                                                 = GetFunction(gnTVGLibrary, "_SetDisplayAspectRatio")
    Global TVG_SetDisplayAssociatedRenderer.pr_SetDisplayAssociatedRenderer                                                   = GetFunction(gnTVGLibrary, "_SetDisplayAssociatedRenderer")
    Global TVG_SetDisplayAutoSize.pr_SetDisplayAutoSize                                                                       = GetFunction(gnTVGLibrary, "_SetDisplayAutoSize")
    Global TVG_SetDisplayEmbedded.pr_SetDisplayEmbedded                                                                       = GetFunction(gnTVGLibrary, "_SetDisplayEmbedded")
    Global TVG_SetDisplayEmbedded_FitParent.pr_SetDisplayEmbedded_FitParent                                                   = GetFunction(gnTVGLibrary, "_SetDisplayEmbedded_FitParent")
    Global TVG_SetDisplayFullScreen.pr_SetDisplayFullScreen                                                                   = GetFunction(gnTVGLibrary, "_SetDisplayFullScreen")
    Global TVG_SetDisplayHeight.pr_SetDisplayHeight                                                                           = GetFunction(gnTVGLibrary, "_SetDisplayHeight")
    Global TVG_SetDisplayLeft.pr_SetDisplayLeft                                                                               = GetFunction(gnTVGLibrary, "_SetDisplayLeft")
    Global TVG_SetDisplayLocation.pr_SetDisplayLocation                                                                       = GetFunction(gnTVGLibrary, "_SetDisplayLocation")
    Global TVG_SetDisplayMonitor.pr_SetDisplayMonitor                                                                         = GetFunction(gnTVGLibrary, "_SetDisplayMonitor")
    Global TVG_SetDisplayMouseMovesWindow.pr_SetDisplayMouseMovesWindow                                                       = GetFunction(gnTVGLibrary, "_SetDisplayMouseMovesWindow")
    Global TVG_SetDisplayPanScanRatio.pr_SetDisplayPanScanRatio                                                               = GetFunction(gnTVGLibrary, "_SetDisplayPanScanRatio")
    Global TVG_SetDisplayParent.pr_SetDisplayParent                                                                           = GetFunction(gnTVGLibrary, "_SetDisplayParent")
    Global TVG_SetDisplayStayOnTop.pr_SetDisplayStayOnTop                                                                     = GetFunction(gnTVGLibrary, "_SetDisplayStayOnTop")
    Global TVG_SetDisplayTop.pr_SetDisplayTop                                                                                 = GetFunction(gnTVGLibrary, "_SetDisplayTop")
    Global TVG_SetDisplayTransparentColorEnabled.pr_SetDisplayTransparentColorEnabled                                         = GetFunction(gnTVGLibrary, "_SetDisplayTransparentColorEnabled")
    Global TVG_SetDisplayTransparentColorValue.pr_SetDisplayTransparentColorValue                                             = GetFunction(gnTVGLibrary, "_SetDisplayTransparentColorValue")
    Global TVG_SetDisplayVideoPortEnabled.pr_SetDisplayVideoPortEnabled                                                       = GetFunction(gnTVGLibrary, "_SetDisplayVideoPortEnabled")
    Global TVG_SetDisplayVisible.pr_SetDisplayVisible                                                                         = GetFunction(gnTVGLibrary, "_SetDisplayVisible")
    Global TVG_SetDisplayWidth.pr_SetDisplayWidth                                                                             = GetFunction(gnTVGLibrary, "_SetDisplayWidth")
    Global TVG_SetDroppedFramesPollingInterval.pr_SetDroppedFramesPollingInterval                                             = GetFunction(gnTVGLibrary, "_SetDroppedFramesPollingInterval")
    Global TVG_SetDVDateTimeEnabled.pr_SetDVDateTimeEnabled                                                                   = GetFunction(gnTVGLibrary, "_SetDVDateTimeEnabled")
    Global TVG_SetDVDiscontinuityMinimumInterval.pr_SetDVDiscontinuityMinimumInterval                                         = GetFunction(gnTVGLibrary, "_SetDVDiscontinuityMinimumInterval")
    Global TVG_SetDVDTitle.pr_SetDVDTitle                                                                                     = GetFunction(gnTVGLibrary, "_SetDVDTitle")
    Global TVG_SetDVEncoder_VideoFormat.pr_SetDVEncoder_VideoFormat                                                           = GetFunction(gnTVGLibrary, "_SetDVEncoder_VideoFormat")
    Global TVG_SetDVEncoder_VideoResolution.pr_SetDVEncoder_VideoResolution                                                   = GetFunction(gnTVGLibrary, "_SetDVEncoder_VideoResolution")
    Global TVG_SetDVEncoder_VideoStandard.pr_SetDVEncoder_VideoStandard                                                       = GetFunction(gnTVGLibrary, "_SetDVEncoder_VideoStandard")
    Global TVG_SetDVRecordingInNativeFormatSeparatesStreams.pr_SetDVRecordingInNativeFormatSeparatesStreams                   = GetFunction(gnTVGLibrary, "_SetDVRecordingInNativeFormatSeparatesStreams")
    Global TVG_SetDVReduceFrameRate.pr_SetDVReduceFrameRate                                                                   = GetFunction(gnTVGLibrary, "_SetDVReduceFrameRate")
    Global TVG_SetDVRgb219.pr_SetDVRgb219                                                                                     = GetFunction(gnTVGLibrary, "_SetDVRgb219")
    Global TVG_SetDVTimeCodeEnabled.pr_SetDVTimeCodeEnabled                                                                   = GetFunction(gnTVGLibrary, "_SetDVTimeCodeEnabled")
    Global TVG_SetEventNotificationSynchrone.pr_SetEventNotificationSynchrone                                                 = GetFunction(gnTVGLibrary, "_SetEventNotificationSynchrone")
    Global TVG_SetExtraDLLPath.pr_SetExtraDLLPath                                                                             = GetFunction(gnTVGLibrary, "_SetExtraDLLPath")
    Global TVG_SetFixFlickerOrBlackCapture.pr_SetFixFlickerOrBlackCapture                                                     = GetFunction(gnTVGLibrary, "_SetFixFlickerOrBlackCapture")
    Global TVG_SetFrameCaptureBounds.pr_SetFrameCaptureBounds                                                                 = GetFunction(gnTVGLibrary, "_SetFrameCaptureBounds")
    Global TVG_SetFrameCaptureHeight.pr_SetFrameCaptureHeight                                                                 = GetFunction(gnTVGLibrary, "_SetFrameCaptureHeight")
    Global TVG_SetFrameCaptureWidth.pr_SetFrameCaptureWidth                                                                   = GetFunction(gnTVGLibrary, "_SetFrameCaptureWidth")
    Global TVG_SetFrameCaptureWithoutOverlay.pr_SetFrameCaptureWithoutOverlay                                                 = GetFunction(gnTVGLibrary, "_SetFrameCaptureWithoutOverlay")
    Global TVG_SetFrameCaptureZoomSize.pr_SetFrameCaptureZoomSize                                                             = GetFunction(gnTVGLibrary, "_SetFrameCaptureZoomSize")
    Global TVG_SetFrameGrabber.pr_SetFrameGrabber                                                                             = GetFunction(gnTVGLibrary, "_SetFrameGrabber")
    Global TVG_SetFrameGrabberRGBFormat.pr_SetFrameGrabberRGBFormat                                                           = GetFunction(gnTVGLibrary, "_SetFrameGrabberRGBFormat")
    Global TVG_SetFrameNumberStartsFromZero.pr_SetFrameNumberStartsFromZero                                                   = GetFunction(gnTVGLibrary, "_SetFrameNumberStartsFromZero")
    Global TVG_SetFrameRate.pr_SetFrameRate                                                                                   = GetFunction(gnTVGLibrary, "_SetFrameRate")
    Global TVG_SetFrameRateDivider.pr_SetFrameRateDivider                                                                     = GetFunction(gnTVGLibrary, "_SetFrameRateDivider")
    Global TVG_SetFWCam1394.pr_SetFWCam1394                                                                                   = GetFunction(gnTVGLibrary, "_SetFWCam1394")
    Global TVG_SetGetLastFrameWaitTimeoutMs.pr_SetGetLastFrameWaitTimeoutMs                                                   = GetFunction(gnTVGLibrary, "_SetGetLastFrameWaitTimeoutMs")
    Global TVG_SetGeneratePts.pr_SetGeneratePts                                                                               = GetFunction(gnTVGLibrary, "_SetGeneratePts")
    Global TVG_SetHeaderAttribute.pr_SetHeaderAttribute                                                                       = GetFunction(gnTVGLibrary, "_SetHeaderAttribute")
    Global TVG_SetHoldRecording.pr_SetHoldRecording                                                                           = GetFunction(gnTVGLibrary, "_SetHoldRecording")
    Global TVG_SetImageOverlay_AlphaBlend.pr_SetImageOverlay_AlphaBlend                                                       = GetFunction(gnTVGLibrary, "_SetImageOverlay_AlphaBlend")
    Global TVG_SetImageOverlay_AlphaBlendValue.pr_SetImageOverlay_AlphaBlendValue                                             = GetFunction(gnTVGLibrary, "_SetImageOverlay_AlphaBlendValue")
    Global TVG_SetImageOverlay_Attributes.pr_SetImageOverlay_Attributes                                                       = GetFunction(gnTVGLibrary, "_SetImageOverlay_Attributes")
    Global TVG_SetImageOverlay_Attributes2.pr_SetImageOverlay_Attributes2                                                     = GetFunction(gnTVGLibrary, "_SetImageOverlay_Attributes2")
    Global TVG_SetImageOverlay_ChromaKey.pr_SetImageOverlay_ChromaKey                                                         = GetFunction(gnTVGLibrary, "_SetImageOverlay_ChromaKey")
    Global TVG_SetImageOverlay_ChromaKeyLeewayPercent.pr_SetImageOverlay_ChromaKeyLeewayPercent                               = GetFunction(gnTVGLibrary, "_SetImageOverlay_ChromaKeyLeewayPercent")
    Global TVG_SetImageOverlay_ChromaKeyRGBColor.pr_SetImageOverlay_ChromaKeyRGBColor                                         = GetFunction(gnTVGLibrary, "_SetImageOverlay_ChromaKeyRGBColor")
    Global TVG_SetImageOverlay_Enabled.pr_SetImageOverlay_Enabled                                                             = GetFunction(gnTVGLibrary, "_SetImageOverlay_Enabled")
    Global TVG_SetImageOverlay_Height.pr_SetImageOverlay_Height                                                               = GetFunction(gnTVGLibrary, "_SetImageOverlay_Height")
    Global TVG_SetImageOverlay_LeftLocation.pr_SetImageOverlay_LeftLocation                                                   = GetFunction(gnTVGLibrary, "_SetImageOverlay_LeftLocation")
    Global TVG_SetImageOverlay_RotationAngle.pr_SetImageOverlay_RotationAngle                                                 = GetFunction(gnTVGLibrary, "_SetImageOverlay_RotationAngle")
    Global TVG_SetImageOverlay_StretchToVideoSize.pr_SetImageOverlay_StretchToVideoSize                                       = GetFunction(gnTVGLibrary, "_SetImageOverlay_StretchToVideoSize")
    Global TVG_SetImageOverlay_TargetDisplay.pr_SetImageOverlay_TargetDisplay                                                 = GetFunction(gnTVGLibrary, "_SetImageOverlay_TargetDisplay")
    Global TVG_SetImageOverlay_TopLocation.pr_SetImageOverlay_TopLocation                                                     = GetFunction(gnTVGLibrary, "_SetImageOverlay_TopLocation")
    Global TVG_SetImageOverlay_Transparent.pr_SetImageOverlay_Transparent                                                     = GetFunction(gnTVGLibrary, "_SetImageOverlay_Transparent")
    Global TVG_SetImageOverlay_TransparentColorValue.pr_SetImageOverlay_TransparentColorValue                                 = GetFunction(gnTVGLibrary, "_SetImageOverlay_TransparentColorValue")
    Global TVG_SetImageOverlay_UseTransparentColor.pr_SetImageOverlay_UseTransparentColor                                     = GetFunction(gnTVGLibrary, "_SetImageOverlay_UseTransparentColor")
    Global TVG_SetImageOverlay_VideoAlignment.pr_SetImageOverlay_VideoAlignment                                               = GetFunction(gnTVGLibrary, "_SetImageOverlay_VideoAlignment")
    Global TVG_SetImageOverlay_Width.pr_SetImageOverlay_Width                                                                 = GetFunction(gnTVGLibrary, "_SetImageOverlay_Width")
    Global TVG_SetImageOverlayAlphaBlend.pr_SetImageOverlayAlphaBlend                                                         = GetFunction(gnTVGLibrary, "_SetImageOverlayAlphaBlend")
    Global TVG_SetImageOverlayAlphaBlendValue.pr_SetImageOverlayAlphaBlendValue                                               = GetFunction(gnTVGLibrary, "_SetImageOverlayAlphaBlendValue")
    Global TVG_SetImageOverlayChromaKey.pr_SetImageOverlayChromaKey                                                           = GetFunction(gnTVGLibrary, "_SetImageOverlayChromaKey")
    Global TVG_SetImageOverlayChromaKeyLeewayPercent.pr_SetImageOverlayChromaKeyLeewayPercent                                 = GetFunction(gnTVGLibrary, "_SetImageOverlayChromaKeyLeewayPercent")
    Global TVG_SetImageOverlayChromaKeyRGBColor.pr_SetImageOverlayChromaKeyRGBColor                                           = GetFunction(gnTVGLibrary, "_SetImageOverlayChromaKeyRGBColor")
    Global TVG_SetImageOverlayEnabled.pr_SetImageOverlayEnabled                                                               = GetFunction(gnTVGLibrary, "_SetImageOverlayEnabled")
    Global TVG_SetImageOverlayFromBMPFile.pr_SetImageOverlayFromBMPFile                                                       = GetFunction(gnTVGLibrary, "_SetImageOverlayFromBMPFile")
    Global TVG_SetImageOverlayFromBMPFile2.pr_SetImageOverlayFromBMPFile2                                                     = GetFunction(gnTVGLibrary, "_SetImageOverlayFromBMPFile2")
    Global TVG_SetImageOverlayFromHBitmap.pr_SetImageOverlayFromHBitmap                                                       = GetFunction(gnTVGLibrary, "_SetImageOverlayFromHBitmap")
    Global TVG_SetImageOverlayFromHBitmap2.pr_SetImageOverlayFromHBitmap2                                                     = GetFunction(gnTVGLibrary, "_SetImageOverlayFromHBitmap2")
    Global TVG_SetImageOverlayFromHBitmap3.pr_SetImageOverlayFromHBitmap3                                                     = GetFunction(gnTVGLibrary, "_SetImageOverlayFromHBitmap3")
    Global TVG_SetImageOverlayFromImageFile.pr_SetImageOverlayFromImageFile                                                   = GetFunction(gnTVGLibrary, "_SetImageOverlayFromImageFile")
    Global TVG_SetImageOverlayFromImageFile2.pr_SetImageOverlayFromImageFile2                                                 = GetFunction(gnTVGLibrary, "_SetImageOverlayFromImageFile2")
    Global TVG_SetImageOverlayFromJPEGFile.pr_SetImageOverlayFromJPEGFile                                                     = GetFunction(gnTVGLibrary, "_SetImageOverlayFromJPEGFile")
    Global TVG_SetImageOverlayFromJPEGFile2.pr_SetImageOverlayFromJPEGFile2                                                   = GetFunction(gnTVGLibrary, "_SetImageOverlayFromJPEGFile2")
    Global TVG_SetImageOverlayHeight.pr_SetImageOverlayHeight                                                                 = GetFunction(gnTVGLibrary, "_SetImageOverlayHeight")
    Global TVG_SetImageOverlayLeftLocation.pr_SetImageOverlayLeftLocation                                                     = GetFunction(gnTVGLibrary, "_SetImageOverlayLeftLocation")
    Global TVG_SetImageOverlayRotationAngle.pr_SetImageOverlayRotationAngle                                                   = GetFunction(gnTVGLibrary, "_SetImageOverlayRotationAngle")
    Global TVG_SetImageOverlaySelector.pr_SetImageOverlaySelector                                                             = GetFunction(gnTVGLibrary, "_SetImageOverlaySelector")
    Global TVG_SetImageOverlayStretchToVideoSize.pr_SetImageOverlayStretchToVideoSize                                         = GetFunction(gnTVGLibrary, "_SetImageOverlayStretchToVideoSize")
    Global TVG_SetImageOverlayTargetDisplay.pr_SetImageOverlayTargetDisplay                                                   = GetFunction(gnTVGLibrary, "_SetImageOverlayTargetDisplay")
    Global TVG_SetImageOverlayTopLocation.pr_SetImageOverlayTopLocation                                                       = GetFunction(gnTVGLibrary, "_SetImageOverlayTopLocation")
    Global TVG_SetImageOverlayTransparent.pr_SetImageOverlayTransparent                                                       = GetFunction(gnTVGLibrary, "_SetImageOverlayTransparent")
    Global TVG_SetImageOverlayTransparentColorValue.pr_SetImageOverlayTransparentColorValue                                   = GetFunction(gnTVGLibrary, "_SetImageOverlayTransparentColorValue")
    Global TVG_SetImageOverlayUseTransparentColor.pr_SetImageOverlayUseTransparentColor                                       = GetFunction(gnTVGLibrary, "_SetImageOverlayUseTransparentColor")
    Global TVG_SetImageOverlayVideoAlignment.pr_SetImageOverlayVideoAlignment                                                 = GetFunction(gnTVGLibrary, "_SetImageOverlayVideoAlignment")
    Global TVG_SetImageOverlayWidth.pr_SetImageOverlayWidth                                                                   = GetFunction(gnTVGLibrary, "_SetImageOverlayWidth")
    Global TVG_SetIPCameraSetting.pr_SetIPCameraSetting                                                                       = GetFunction(gnTVGLibrary, "_SetIPCameraSetting")
    Global TVG_SetIPCameraURL.pr_SetIPCameraURL                                                                               = GetFunction(gnTVGLibrary, "_SetIPCameraURL")
    Global TVG_SetJPEGPerformance.pr_SetJPEGPerformance                                                                       = GetFunction(gnTVGLibrary, "_SetJPEGPerformance")
    Global TVG_SetJPEGProgressiveDisplay.pr_SetJPEGProgressiveDisplay                                                         = GetFunction(gnTVGLibrary, "_SetJPEGProgressiveDisplay")
    Global TVG_SetJPEGQuality.pr_SetJPEGQuality                                                                               = GetFunction(gnTVGLibrary, "_SetJPEGQuality")
    Global TVG_SetLicenseString.pr_SetLicenseString                                                                           = GetFunction(gnTVGLibrary, "_SetLicenseString")
    Global TVG_SetLocation.pr_SetLocation                                                                                     = GetFunction(gnTVGLibrary, "_SetLocation")
    Global TVG_SetLogoDisplayed.pr_SetLogoDisplayed                                                                           = GetFunction(gnTVGLibrary, "_SetLogoDisplayed")
    Global TVG_SetLogoFromBMPFile.pr_SetLogoFromBMPFile                                                                       = GetFunction(gnTVGLibrary, "_SetLogoFromBMPFile")
    Global TVG_SetLogoFromHBitmap.pr_SetLogoFromHBitmap                                                                       = GetFunction(gnTVGLibrary, "_SetLogoFromHBitmap")
    Global TVG_SetLogoFromJPEGFile.pr_SetLogoFromJPEGFile                                                                     = GetFunction(gnTVGLibrary, "_SetLogoFromJPEGFile")
    Global TVG_SetLogoLayout.pr_SetLogoLayout                                                                                 = GetFunction(gnTVGLibrary, "_SetLogoLayout")
    Global TVG_SetMixAudioSamplesLevel.pr_SetMixAudioSamplesLevel                                                             = GetFunction(gnTVGLibrary, "_SetMixAudioSamplesLevel")
    Global TVG_SetMixer_MosaicColumns.pr_SetMixer_MosaicColumns                                                               = GetFunction(gnTVGLibrary, "_SetMixer_MosaicColumns")
    Global TVG_SetMixer_MosaicLines.pr_SetMixer_MosaicLines                                                                   = GetFunction(gnTVGLibrary, "_SetMixer_MosaicLines")
    Global TVG_SetMotionDetector_CompareBlue.pr_SetMotionDetector_CompareBlue                                                 = GetFunction(gnTVGLibrary, "_SetMotionDetector_CompareBlue")
    Global TVG_SetMotionDetector_CompareGreen.pr_SetMotionDetector_CompareGreen                                               = GetFunction(gnTVGLibrary, "_SetMotionDetector_CompareGreen")
    Global TVG_SetMotionDetector_CompareRed.pr_SetMotionDetector_CompareRed                                                   = GetFunction(gnTVGLibrary, "_SetMotionDetector_CompareRed")
    Global TVG_SetMotionDetector_Enabled.pr_SetMotionDetector_Enabled                                                         = GetFunction(gnTVGLibrary, "_SetMotionDetector_Enabled")
    Global TVG_SetMotionDetector_GreyScale.pr_SetMotionDetector_GreyScale                                                     = GetFunction(gnTVGLibrary, "_SetMotionDetector_GreyScale")
    Global TVG_SetMotionDetector_Grid.pr_SetMotionDetector_Grid                                                               = GetFunction(gnTVGLibrary, "_SetMotionDetector_Grid")
    Global TVG_SetMotionDetector_MaxDetectionsPerSecond.pr_SetMotionDetector_MaxDetectionsPerSecond                           = GetFunction(gnTVGLibrary, "_SetMotionDetector_MaxDetectionsPerSecond")
    Global TVG_SetMotionDetector_MotionResetMs.pr_SetMotionDetector_MotionResetMs                                             = GetFunction(gnTVGLibrary, "_SetMotionDetector_MotionResetMs")
    Global TVG_SetMotionDetector_ReduceCPULoad.pr_SetMotionDetector_ReduceCPULoad                                             = GetFunction(gnTVGLibrary, "_SetMotionDetector_ReduceCPULoad")
    Global TVG_SetMotionDetector_ReduceVideoNoise.pr_SetMotionDetector_ReduceVideoNoise                                       = GetFunction(gnTVGLibrary, "_SetMotionDetector_ReduceVideoNoise")
    Global TVG_SetMotionDetector_Triggered.pr_SetMotionDetector_Triggered                                                     = GetFunction(gnTVGLibrary, "_SetMotionDetector_Triggered")
    Global TVG_SetMouseWheelEventEnabled.pr_SetMouseWheelEventEnabled                                                         = GetFunction(gnTVGLibrary, "_SetMouseWheelEventEnabled")
    Global TVG_SetMouseWheelControlsZoomAtCursor.pr_SetMouseWheelControlsZoomAtCursor                                         = GetFunction(gnTVGLibrary, "_SetMouseWheelControlsZoomAtCursor")
    Global TVG_SetMpegStreamType.pr_SetMpegStreamType                                                                         = GetFunction(gnTVGLibrary, "_SetMpegStreamType")
    Global TVG_SetMultiplexedInputEmulation.pr_SetMultiplexedInputEmulation                                                   = GetFunction(gnTVGLibrary, "_SetMultiplexedInputEmulation")
    Global TVG_SetMultiplexedRole.pr_SetMultiplexedRole                                                                       = GetFunction(gnTVGLibrary, "_SetMultiplexedRole")
    Global TVG_SetMultiplexedStabilizationDelay.pr_SetMultiplexedStabilizationDelay                                           = GetFunction(gnTVGLibrary, "_SetMultiplexedStabilizationDelay")
    Global TVG_SetMultiplexedSwitchDelay.pr_SetMultiplexedSwitchDelay                                                         = GetFunction(gnTVGLibrary, "_SetMultiplexedSwitchDelay")
    Global TVG_SetMultiplexer.pr_SetMultiplexer                                                                               = GetFunction(gnTVGLibrary, "_SetMultiplexer")
    Global TVG_SetMultiplexerFilterByName.pr_SetMultiplexerFilterByName                                                       = GetFunction(gnTVGLibrary, "_SetMultiplexerFilterByName")
    Global TVG_SetMultipurposeEncoderSettings.pr_SetMultipurposeEncoderSettings                                               = GetFunction(gnTVGLibrary, "_SetMultipurposeEncoderSettings")
    Global TVG_SetMuteAudioRendering.pr_SetMuteAudioRendering                                                                 = GetFunction(gnTVGLibrary, "_SetMuteAudioRendering")
    Global TVG_SetName.pr_SetName                                                                                             = GetFunction(gnTVGLibrary, "_SetName")
    Global TVG_SetNDIBandwidthType.pr_SetNDIBandwidthType                                                                     = GetFunction(gnTVGLibrary, "_SetNDIBandwidthType")
    Global TVG_SetNDIGroups.pr_SetNDIGroups                                                                                   = GetFunction(gnTVGLibrary, "_SetNDIGroups")
    Global TVG_SetNDIName.pr_SetNDIName                                                                                       = GetFunction(gnTVGLibrary, "_SetNDIName")
    Global TVG_SetNDIReceiveTimeoutMs.pr_SetNDIReceiveTimeoutMs                                                               = GetFunction(gnTVGLibrary, "_SetNDIReceiveTimeoutMs")
    Global TVG_SetNetworkStreaming.pr_SetNetworkStreaming                                                                     = GetFunction(gnTVGLibrary, "_SetNetworkStreaming")
    Global TVG_SetNetworkStreamingType.pr_SetNetworkStreamingType                                                             = GetFunction(gnTVGLibrary, "_SetNetworkStreamingType")
    Global TVG_SetNormalCursor.pr_SetNormalCursor                                                                             = GetFunction(gnTVGLibrary, "_SetNormalCursor")
    Global TVG_SetNotificationMethod.pr_SetNotificationMethod                                                                 = GetFunction(gnTVGLibrary, "_SetNotificationMethod")
    Global TVG_SetNotificationPriority.pr_SetNotificationPriority                                                             = GetFunction(gnTVGLibrary, "_SetNotificationPriority")
    Global TVG_SetNotificationSleepTime.pr_SetNotificationSleepTime                                                           = GetFunction(gnTVGLibrary, "_SetNotificationSleepTime")
    Global TVG_SetOnAudioBufferNegotiation.pr_SetOnAudioBufferNegotiation                                                     = GetFunction(gnTVGLibrary, "_SetOnAudioBufferNegotiation")
    Global TVG_SetOnAudioDeviceSelected.pr_SetOnAudioDeviceSelected                                                           = GetFunction(gnTVGLibrary, "_SetOnAudioDeviceSelected")
    Global TVG_SetOnAudioPeak.pr_SetOnAudioPeak                                                                               = GetFunction(gnTVGLibrary, "_SetOnAudioPeak")
    Global TVG_SetOnAuthenticationNeeded.pr_SetOnAuthenticationNeeded                                                         = GetFunction(gnTVGLibrary, "_SetOnAuthenticationNeeded")
    Global TVG_SetOnAVIDurationUpdated.pr_SetOnAVIDurationUpdated                                                             = GetFunction(gnTVGLibrary, "_SetOnAVIDurationUpdated")
    Global TVG_SetOnBacktimedFramesCountReached.pr_SetOnBacktimedFramesCountReached                                           = GetFunction(gnTVGLibrary, "_SetOnBacktimedFramesCountReached")
    Global TVG_SetOnBitmapsLoadingProgress.pr_SetOnBitmapsLoadingProgress                                                     = GetFunction(gnTVGLibrary, "_SetOnBitmapsLoadingProgress")
    Global TVG_SetOnClick.pr_SetOnClick                                                                                       = GetFunction(gnTVGLibrary, "_SetOnClick")
    Global TVG_SetOnClientConnection.pr_SetOnClientConnection                                                                 = GetFunction(gnTVGLibrary, "_SetOnClientConnection")
    Global TVG_SetOnColorKeyChange.pr_SetOnColorKeyChange                                                                     = GetFunction(gnTVGLibrary, "_SetOnColorKeyChange")
    Global TVG_SetOnCopyPreallocDataCompleted.pr_SetOnCopyPreallocDataCompleted                                               = GetFunction(gnTVGLibrary, "_SetOnCopyPreallocDataCompleted")
    Global TVG_SetOnCopyPreallocDataProgress.pr_SetOnCopyPreallocDataProgress                                                 = GetFunction(gnTVGLibrary, "_SetOnCopyPreallocDataProgress")
    Global TVG_SetOnCopyPreallocDataStarted.pr_SetOnCopyPreallocDataStarted                                                   = GetFunction(gnTVGLibrary, "_SetOnCopyPreallocDataStarted")
    Global TVG_SetOnCreatePreallocFileCompleted.pr_SetOnCreatePreallocFileCompleted                                           = GetFunction(gnTVGLibrary, "_SetOnCreatePreallocFileCompleted")
    Global TVG_SetOnCreatePreallocFileProgress.pr_SetOnCreatePreallocFileProgress                                             = GetFunction(gnTVGLibrary, "_SetOnCreatePreallocFileProgress")
    Global TVG_SetOnCreatePreallocFileStarted.pr_SetOnCreatePreallocFileStarted                                               = GetFunction(gnTVGLibrary, "_SetOnCreatePreallocFileStarted")
    Global TVG_SetOnDblClick.pr_SetOnDblClick                                                                                 = GetFunction(gnTVGLibrary, "_SetOnDblClick")
    Global TVG_SetOnDeviceArrivalOrRemoval.pr_SetOnDeviceArrivalOrRemoval                                                     = GetFunction(gnTVGLibrary, "_SetOnDeviceArrivalOrRemoval")
    Global TVG_SetOnDeviceLost.pr_SetOnDeviceLost                                                                             = GetFunction(gnTVGLibrary, "_SetOnDeviceLost")
    Global TVG_SetOnDeviceReconnected.pr_SetOnDeviceReconnected                                                               = GetFunction(gnTVGLibrary, "_SetOnDeviceReconnected")
    Global TVG_SetOnDeviceReconnecting.pr_SetOnDeviceReconnecting                                                             = GetFunction(gnTVGLibrary, "_SetOnDeviceReconnecting")
    Global TVG_SetOnDirectNetworkStreamingHostUrl.pr_SetOnDirectNetworkStreamingHostUrl                                       = GetFunction(gnTVGLibrary, "_SetOnDirectNetworkStreamingHostUrl")
    Global TVG_SetOnDiskFull.pr_SetOnDiskFull                                                                                 = GetFunction(gnTVGLibrary, "_SetOnDiskFull")
    Global TVG_SetOnDoEvents.pr_SetOnDoEvents                                                                                 = GetFunction(gnTVGLibrary, "_SetOnDoEvents")
    Global TVG_SetOnDragDrop.pr_SetOnDragDrop                                                                                 = GetFunction(gnTVGLibrary, "_SetOnDragDrop")
    Global TVG_SetOnDragDropFiles.pr_SetOnDragDropFiles                                                                       = GetFunction(gnTVGLibrary, "_SetOnDragDropFiles")
    Global TVG_SetOnDragOver.pr_SetOnDragOver                                                                                 = GetFunction(gnTVGLibrary, "_SetOnDragOver")
    Global TVG_SetOnDVCommandCompleted.pr_SetOnDVCommandCompleted                                                             = GetFunction(gnTVGLibrary, "_SetOnDVCommandCompleted")
    Global TVG_SetOnDVDiscontinuity.pr_SetOnDVDiscontinuity                                                                   = GetFunction(gnTVGLibrary, "_SetOnDVDiscontinuity")
    Global TVG_SetOnEnumerateWindows.pr_SetOnEnumerateWindows                                                                 = GetFunction(gnTVGLibrary, "_SetOnEnumerateWindows")
    Global TVG_SetOnFilterSelected.pr_SetOnFilterSelected                                                                     = GetFunction(gnTVGLibrary, "_SetOnFilterSelected")
    Global TVG_SetOnFirstFrameReceived.pr_SetOnFirstFrameReceived                                                             = GetFunction(gnTVGLibrary, "_SetOnFirstFrameReceived")
    Global TVG_SetOnFrameBitmap.pr_SetOnFrameBitmap                                                                           = GetFunction(gnTVGLibrary, "_SetOnFrameBitmap")
    Global TVG_SetOnFrameBitmapEventSynchrone.pr_SetOnFrameBitmapEventSynchrone                                               = GetFunction(gnTVGLibrary, "_SetOnFrameBitmapEventSynchrone")
    Global TVG_SetOnFrameCaptureCompleted.pr_SetOnFrameCaptureCompleted                                                       = GetFunction(gnTVGLibrary, "_SetOnFrameCaptureCompleted")
    Global TVG_SetOnFrameOverlayUsingDC.pr_SetOnFrameOverlayUsingDC                                                           = GetFunction(gnTVGLibrary, "_SetOnFrameOverlayUsingDC")
    Global TVG_SetOnFrameOverlayUsingDIB.pr_SetOnFrameOverlayUsingDIB                                                         = GetFunction(gnTVGLibrary, "_SetOnFrameOverlayUsingDIB")
    Global TVG_SetOnFrameProgress.pr_SetOnFrameProgress                                                                       = GetFunction(gnTVGLibrary, "_SetOnFrameProgress")
    Global TVG_SetOnFrameProgress2.pr_SetOnFrameProgress2                                                                     = GetFunction(gnTVGLibrary, "_SetOnFrameProgress2")
    Global TVG_SetOnGraphBuilt.pr_SetOnGraphBuilt                                                                             = GetFunction(gnTVGLibrary, "_SetOnGraphBuilt")
    Global TVG_SetOnInactive.pr_SetOnInactive                                                                                 = GetFunction(gnTVGLibrary, "_SetOnInactive")
    Global TVG_SetOnKeyPress.pr_SetOnKeyPress                                                                                 = GetFunction(gnTVGLibrary, "_SetOnKeyPress")
    Global TVG_SetOnLastCommandCompleted.pr_SetOnLastCommandCompleted                                                         = GetFunction(gnTVGLibrary, "_SetOnLastCommandCompleted")
    Global TVG_SetOnLeavingFullScreen.pr_SetOnLeavingFullScreen                                                               = GetFunction(gnTVGLibrary, "_SetOnLeavingFullScreen")
    Global TVG_SetOnLog.pr_SetOnLog                                                                                           = GetFunction(gnTVGLibrary, "_SetOnLog")
    Global TVG_SetOnMotionDetected.pr_SetOnMotionDetected                                                                     = GetFunction(gnTVGLibrary, "_SetOnMotionDetected")
    Global TVG_SetOnMotionNotDetected.pr_SetOnMotionNotDetected                                                               = GetFunction(gnTVGLibrary, "_SetOnMotionNotDetected")
    Global TVG_SetOnMouseDown.pr_SetOnMouseDown                                                                               = GetFunction(gnTVGLibrary, "_SetOnMouseDown")
    Global TVG_SetOnMouseDown_Video.pr_SetOnMouseDown_Video                                                                   = GetFunction(gnTVGLibrary, "_SetOnMouseDown_Video")
    Global TVG_SetOnMouseDown_Window.pr_SetOnMouseDown_Window                                                                 = GetFunction(gnTVGLibrary, "_SetOnMouseDown_Window")
    Global TVG_SetOnMouseEnter.pr_SetOnMouseEnter                                                                             = GetFunction(gnTVGLibrary, "_SetOnMouseEnter")
    Global TVG_SetOnMouseLeave.pr_SetOnMouseLeave                                                                             = GetFunction(gnTVGLibrary, "_SetOnMouseLeave")
    Global TVG_SetOnMouseMove.pr_SetOnMouseMove                                                                               = GetFunction(gnTVGLibrary, "_SetOnMouseMove")
    Global TVG_SetOnMouseMove_Video.pr_SetOnMouseMove_Video                                                                   = GetFunction(gnTVGLibrary, "_SetOnMouseMove_Video")
    Global TVG_SetOnMouseMove_Window.pr_SetOnMouseMove_Window                                                                 = GetFunction(gnTVGLibrary, "_SetOnMouseMove_Window")
    Global TVG_SetOnMouseUp.pr_SetOnMouseUp                                                                                   = GetFunction(gnTVGLibrary, "_SetOnMouseUp")
    Global TVG_SetOnMouseUp_Video.pr_SetOnMouseUp_Video                                                                       = GetFunction(gnTVGLibrary, "_SetOnMouseUp_Video")
    Global TVG_SetOnMouseUp_Window.pr_SetOnMouseUp_Window                                                                     = GetFunction(gnTVGLibrary, "_SetOnMouseUp_Window")
    Global TVG_SetOnMouseWheel.pr_SetOnMouseWheel                                                                             = GetFunction(gnTVGLibrary, "_SetOnMouseWheel")
    Global TVG_SetOnMultipurposeEncoderCompleted.pr_SetOnMultipurposeEncoderCompleted                                         = GetFunction(gnTVGLibrary, "_SetOnMultipurposeEncoderCompleted")
    Global TVG_SetOnMultipurposeEncoderError.pr_SetOnMultipurposeEncoderError                                                 = GetFunction(gnTVGLibrary, "_SetOnMultipurposeEncoderError")
    Global TVG_SetOnMultipurposeEncoderProgress.pr_SetOnMultipurposeEncoderProgress                                           = GetFunction(gnTVGLibrary, "_SetOnMultipurposeEncoderProgress")
    Global TVG_SetOnNoVideoDevices.pr_SetOnNoVideoDevices                                                                     = GetFunction(gnTVGLibrary, "_SetOnNoVideoDevices")
    Global TVG_SetOnNTPTimeStamp.pr_SetOnNTPTimeStamp                                                                         = GetFunction(gnTVGLibrary, "_SetOnNTPTimeStamp")
    Global TVG_SetOnONVIFDiscoveryCompleted.pr_SetOnONVIFDiscoveryCompleted                                                   = GetFunction(gnTVGLibrary, "_SetOnONVIFDiscoveryCompleted")
    Global TVG_SetOnPlayerBufferingData.pr_SetOnPlayerBufferingData                                                           = GetFunction(gnTVGLibrary, "_SetOnPlayerBufferingData")
    Global TVG_SetOnPlayerDurationUpdated.pr_SetOnPlayerDurationUpdated                                                       = GetFunction(gnTVGLibrary, "_SetOnPlayerDurationUpdated")
    Global TVG_SetOnPlayerEndOfPlaylist.pr_SetOnPlayerEndOfPlaylist                                                           = GetFunction(gnTVGLibrary, "_SetOnPlayerEndOfPlaylist")
    Global TVG_SetOnPlayerEndOfStream.pr_SetOnPlayerEndOfStream                                                               = GetFunction(gnTVGLibrary, "_SetOnPlayerEndOfStream")
    Global TVG_SetOnPlayerOpened.pr_SetOnPlayerOpened                                                                         = GetFunction(gnTVGLibrary, "_SetOnPlayerOpened")
    Global TVG_SetOnPlayerStateChanged.pr_SetOnPlayerStateChanged                                                             = GetFunction(gnTVGLibrary, "_SetOnPlayerStateChanged")
    Global TVG_SetOnPlayerUpdateTrackbarPosition.pr_SetOnPlayerUpdateTrackbarPosition                                         = GetFunction(gnTVGLibrary, "_SetOnPlayerUpdateTrackbarPosition")
    Global TVG_SetOnPreviewStarted.pr_SetOnPreviewStarted                                                                     = GetFunction(gnTVGLibrary, "_SetOnPreviewStarted")
    Global TVG_SetOnRawAudioSample.pr_SetOnRawAudioSample                                                                     = GetFunction(gnTVGLibrary, "_SetOnRawAudioSample")
    Global TVG_SetOnRawVideoSample.pr_SetOnRawVideoSample                                                                     = GetFunction(gnTVGLibrary, "_SetOnRawVideoSample")
    Global TVG_SetOnRecordingCompleted.pr_SetOnRecordingCompleted                                                             = GetFunction(gnTVGLibrary, "_SetOnRecordingCompleted")
    Global TVG_SetOnRecordingPaused.pr_SetOnRecordingPaused                                                                   = GetFunction(gnTVGLibrary, "_SetOnRecordingPaused")
    Global TVG_SetOnRecordingReadyToStart.pr_SetOnRecordingReadyToStart                                                       = GetFunction(gnTVGLibrary, "_SetOnRecordingReadyToStart")
    Global TVG_SetOnRecordingStarted.pr_SetOnRecordingStarted                                                                 = GetFunction(gnTVGLibrary, "_SetOnRecordingStarted")
    Global TVG_SetOnReencodingCompleted.pr_SetOnReencodingCompleted                                                           = GetFunction(gnTVGLibrary, "_SetOnReencodingCompleted")
    Global TVG_SetOnReencodingProgress.pr_SetOnReencodingProgress                                                             = GetFunction(gnTVGLibrary, "_SetOnReencodingProgress")
    Global TVG_SetOnReencodingStarted.pr_SetOnReencodingStarted                                                               = GetFunction(gnTVGLibrary, "_SetOnReencodingStarted")
    Global TVG_SetOnReinitializing.pr_SetOnReinitializing                                                                     = GetFunction(gnTVGLibrary, "_SetOnReinitializing")
    Global TVG_SetOnResizeVideo.pr_SetOnResizeVideo                                                                           = GetFunction(gnTVGLibrary, "_SetOnResizeVideo")
    Global TVG_SetOnStoppingGraph.pr_SetOnStoppingGraph                                                                       = GetFunction(gnTVGLibrary, "_SetOnStoppingGraph")
    Global TVG_SetOnStoppingGraphCompleted.pr_SetOnStoppingGraphCompleted                                                     = GetFunction(gnTVGLibrary, "_SetOnStoppingGraphCompleted")
    Global TVG_SetOnTextOverlayScrollingCompleted.pr_SetOnTextOverlayScrollingCompleted                                       = GetFunction(gnTVGLibrary, "_SetOnTextOverlayScrollingCompleted")
    Global TVG_SetOnThirdPartyFilterAdded.pr_SetOnThirdPartyFilterAdded                                                       = GetFunction(gnTVGLibrary, "_SetOnThirdPartyFilterAdded")
    Global TVG_SetOnThirdPartyFilterConnected.pr_SetOnThirdPartyFilterConnected                                               = GetFunction(gnTVGLibrary, "_SetOnThirdPartyFilterConnected")
    Global TVG_SetOnThirdPartyFilterConnected2.pr_SetOnThirdPartyFilterConnected2                                             = GetFunction(gnTVGLibrary, "_SetOnThirdPartyFilterConnected2")
    Global TVG_SetOnThreadSync.pr_SetOnThreadSync                                                                             = GetFunction(gnTVGLibrary, "_SetOnThreadSync")
    Global TVG_SetOnTVChannelScanCompleted.pr_SetOnTVChannelScanCompleted                                                     = GetFunction(gnTVGLibrary, "_SetOnTVChannelScanCompleted")
    Global TVG_SetOnTVChannelScanStarted.pr_SetOnTVChannelScanStarted                                                         = GetFunction(gnTVGLibrary, "_SetOnTVChannelScanStarted")
    Global TVG_SetOnTVChannelSelected.pr_SetOnTVChannelSelected                                                               = GetFunction(gnTVGLibrary, "_SetOnTVChannelSelected")
    Global TVG_SetOnVideoCompressionSettings.pr_SetOnVideoCompressionSettings                                                 = GetFunction(gnTVGLibrary, "_SetOnVideoCompressionSettings")
    Global TVG_SetOnVideoDeviceSelected.pr_SetOnVideoDeviceSelected                                                           = GetFunction(gnTVGLibrary, "_SetOnVideoDeviceSelected")
    Global TVG_SetOnVideoFromBitmapsNextFrameNeeded.pr_SetOnVideoFromBitmapsNextFrameNeeded                                   = GetFunction(gnTVGLibrary, "_SetOnVideoFromBitmapsNextFrameNeeded")
    Global TVG_SetOpenURLAsync.pr_SetOpenURLAsync                                                                             = GetFunction(gnTVGLibrary, "_SetOpenURLAsync")
    Global TVG_SetOverlayAfterTransform.pr_SetOverlayAfterTransform                                                           = GetFunction(gnTVGLibrary, "_SetOverlayAfterTransform")
    Global TVG_SetParentWindow.pr_SetParentWindow                                                                             = GetFunction(gnTVGLibrary, "_SetParentWindow")
    Global TVG_SetPlayerAudioRendering.pr_SetPlayerAudioRendering                                                             = GetFunction(gnTVGLibrary, "_SetPlayerAudioRendering")
    Global TVG_SetPlayerDuration.pr_SetPlayerDuration                                                                         = GetFunction(gnTVGLibrary, "_SetPlayerDuration")
    Global TVG_SetPlayerDVSize.pr_SetPlayerDVSize                                                                             = GetFunction(gnTVGLibrary, "_SetPlayerDVSize")
    Global TVG_SetPlayerFastSeekSpeedRatio.pr_SetPlayerFastSeekSpeedRatio                                                     = GetFunction(gnTVGLibrary, "_SetPlayerFastSeekSpeedRatio")
    Global TVG_SetPlayerFileName.pr_SetPlayerFileName                                                                         = GetFunction(gnTVGLibrary, "_SetPlayerFileName")
    Global TVG_SetPlayerForcedCodec.pr_SetPlayerForcedCodec                                                                   = GetFunction(gnTVGLibrary, "_SetPlayerForcedCodec")
    Global TVG_SetPlayerFramePosition.pr_SetPlayerFramePosition                                                               = GetFunction(gnTVGLibrary, "_SetPlayerFramePosition")
    Global TVG_SetPlayerHwAccel.pr_SetPlayerHwAccel                                                                           = GetFunction(gnTVGLibrary, "_SetPlayerHwAccel")
    Global TVG_SetPlayerRefreshPausedDisplay.pr_SetPlayerRefreshPausedDisplay                                                 = GetFunction(gnTVGLibrary, "_SetPlayerRefreshPausedDisplay")
    Global TVG_SetPlayerRefreshPausedDisplayFrameRate.pr_SetPlayerRefreshPausedDisplayFrameRate                               = GetFunction(gnTVGLibrary, "_SetPlayerRefreshPausedDisplayFrameRate")
    Global TVG_SetPlayerSpeedRatio.pr_SetPlayerSpeedRatio                                                                     = GetFunction(gnTVGLibrary, "_SetPlayerSpeedRatio")
    Global TVG_SetPlayerSpeedRatioConstantAudioPitch.pr_SetPlayerSpeedRatioConstantAudioPitch                                 = GetFunction(gnTVGLibrary, "_SetPlayerSpeedRatioConstantAudioPitch")
    Global TVG_SetPlayerTimePosition.pr_SetPlayerTimePosition                                                                 = GetFunction(gnTVGLibrary, "_SetPlayerTimePosition")
    Global TVG_SetPlayerTrackBarSynchrone.pr_SetPlayerTrackBarSynchrone                                                       = GetFunction(gnTVGLibrary, "_SetPlayerTrackBarSynchrone")
    Global TVG_SetPlaylistIndex.pr_SetPlaylistIndex                                                                           = GetFunction(gnTVGLibrary, "_SetPlaylistIndex")
    Global TVG_SetPreallocCapFileCopiedAfterRecording.pr_SetPreallocCapFileCopiedAfterRecording                               = GetFunction(gnTVGLibrary, "_SetPreallocCapFileCopiedAfterRecording")
    Global TVG_SetPreallocCapFileEnabled.pr_SetPreallocCapFileEnabled                                                         = GetFunction(gnTVGLibrary, "_SetPreallocCapFileEnabled")
    Global TVG_SetPreallocCapFileName.pr_SetPreallocCapFileName                                                               = GetFunction(gnTVGLibrary, "_SetPreallocCapFileName")
    Global TVG_SetPreallocCapFileSizeInMB.pr_SetPreallocCapFileSizeInMB                                                       = GetFunction(gnTVGLibrary, "_SetPreallocCapFileSizeInMB")
    Global TVG_SetPreviewZoomSize.pr_SetPreviewZoomSize                                                                       = GetFunction(gnTVGLibrary, "_SetPreviewZoomSize")
    Global TVG_SetQuickDeviceInitialization.pr_SetQuickDeviceInitialization                                                   = GetFunction(gnTVGLibrary, "_SetQuickDeviceInitialization")
    Global TVG_SetRawAudioSampleCapture.pr_SetRawAudioSampleCapture                                                           = GetFunction(gnTVGLibrary, "_SetRawAudioSampleCapture")
    Global TVG_SetRawCaptureAsyncEvent.pr_SetRawCaptureAsyncEvent                                                             = GetFunction(gnTVGLibrary, "_SetRawCaptureAsyncEvent")
    Global TVG_SetRawSampleCaptureLocation.pr_SetRawSampleCaptureLocation                                                     = GetFunction(gnTVGLibrary, "_SetRawSampleCaptureLocation")
    Global TVG_SetRawVideoSampleCapture.pr_SetRawVideoSampleCapture                                                           = GetFunction(gnTVGLibrary, "_SetRawVideoSampleCapture")
    Global TVG_SetRecordingAudioBitRate.pr_SetRecordingAudioBitRate                                                           = GetFunction(gnTVGLibrary, "_SetRecordingAudioBitRate")
    Global TVG_SetRecordingBacktimedFramesCount.pr_SetRecordingBacktimedFramesCount                                           = GetFunction(gnTVGLibrary, "_SetRecordingBacktimedFramesCount")
    Global TVG_SetRecordingCanPause.pr_SetRecordingCanPause                                                                   = GetFunction(gnTVGLibrary, "_SetRecordingCanPause")
    Global TVG_SetRecordingFileName.pr_SetRecordingFileName                                                                   = GetFunction(gnTVGLibrary, "_SetRecordingFileName")
    Global TVG_SetRecordingFileSizeMaxInMB.pr_SetRecordingFileSizeMaxInMB                                                     = GetFunction(gnTVGLibrary, "_SetRecordingFileSizeMaxInMB")
    Global TVG_SetRecordingInNativeFormat.pr_SetRecordingInNativeFormat                                                       = GetFunction(gnTVGLibrary, "_SetRecordingInNativeFormat")
    Global TVG_SetRecordingMethod.pr_SetRecordingMethod                                                                       = GetFunction(gnTVGLibrary, "_SetRecordingMethod")
    Global TVG_SetRecordingOnMotion_Enabled.pr_SetRecordingOnMotion_Enabled                                                   = GetFunction(gnTVGLibrary, "_SetRecordingOnMotion_Enabled")
    Global TVG_SetRecordingOnMotion_MotionThreshold.pr_SetRecordingOnMotion_MotionThreshold                                   = GetFunction(gnTVGLibrary, "_SetRecordingOnMotion_MotionThreshold")
    Global TVG_SetRecordingOnMotion_NoMotionPauseDelayMs.pr_SetRecordingOnMotion_NoMotionPauseDelayMs                         = GetFunction(gnTVGLibrary, "_SetRecordingOnMotion_NoMotionPauseDelayMs")
    Global TVG_SetRecordingPauseCreatesNewFile.pr_SetRecordingPauseCreatesNewFile                                             = GetFunction(gnTVGLibrary, "_SetRecordingPauseCreatesNewFile")
    Global TVG_SetRecordingSize.pr_SetRecordingSize                                                                           = GetFunction(gnTVGLibrary, "_SetRecordingSize")
    Global TVG_SetRecordingTimer.pr_SetRecordingTimer                                                                         = GetFunction(gnTVGLibrary, "_SetRecordingTimer")
    Global TVG_SetRecordingTimerInterval.pr_SetRecordingTimerInterval                                                         = GetFunction(gnTVGLibrary, "_SetRecordingTimerInterval")
    Global TVG_SetRecordingVideoBitRate.pr_SetRecordingVideoBitRate                                                           = GetFunction(gnTVGLibrary, "_SetRecordingVideoBitRate")
    Global TVG_SetReencodingIncludeAudioStream.pr_SetReencodingIncludeAudioStream                                             = GetFunction(gnTVGLibrary, "_SetReencodingIncludeAudioStream")
    Global TVG_SetReencodingIncludeVideoStream.pr_SetReencodingIncludeVideoStream                                             = GetFunction(gnTVGLibrary, "_SetReencodingIncludeVideoStream")
    Global TVG_SetReencodingMethod.pr_SetReencodingMethod                                                                     = GetFunction(gnTVGLibrary, "_SetReencodingMethod")
    Global TVG_SetReencodingNewVideoClip.pr_SetReencodingNewVideoClip                                                         = GetFunction(gnTVGLibrary, "_SetReencodingNewVideoClip")
    Global TVG_SetReencodingSourceVideoClip.pr_SetReencodingSourceVideoClip                                                   = GetFunction(gnTVGLibrary, "_SetReencodingSourceVideoClip")
    Global TVG_SetReencodingStartFrame.pr_SetReencodingStartFrame                                                             = GetFunction(gnTVGLibrary, "_SetReencodingStartFrame")
    Global TVG_SetReencodingStartTime.pr_SetReencodingStartTime                                                               = GetFunction(gnTVGLibrary, "_SetReencodingStartTime")
    Global TVG_SetReencodingStopFrame.pr_SetReencodingStopFrame                                                               = GetFunction(gnTVGLibrary, "_SetReencodingStopFrame")
    Global TVG_SetReencodingStopTime.pr_SetReencodingStopTime                                                                 = GetFunction(gnTVGLibrary, "_SetReencodingStopTime")
    Global TVG_SetReencodingUseAudioCompressor.pr_SetReencodingUseAudioCompressor                                             = GetFunction(gnTVGLibrary, "_SetReencodingUseAudioCompressor")
    Global TVG_SetReencodingUseFrameGrabber.pr_SetReencodingUseFrameGrabber                                                   = GetFunction(gnTVGLibrary, "_SetReencodingUseFrameGrabber")
    Global TVG_SetReencodingUseVideoCompressor.pr_SetReencodingUseVideoCompressor                                             = GetFunction(gnTVGLibrary, "_SetReencodingUseVideoCompressor")
    Global TVG_SetReencodingWMVOutput.pr_SetReencodingWMVOutput                                                               = GetFunction(gnTVGLibrary, "_SetReencodingWMVOutput")
    Global TVG_SetScreenRecordingLayeredWindows.pr_SetScreenRecordingLayeredWindows                                           = GetFunction(gnTVGLibrary, "_SetScreenRecordingLayeredWindows")
    Global TVG_SetScreenRecordingMonitor.pr_SetScreenRecordingMonitor                                                         = GetFunction(gnTVGLibrary, "_SetScreenRecordingMonitor")
    Global TVG_SetScreenRecordingNonVisibleWindows.pr_SetScreenRecordingNonVisibleWindows                                     = GetFunction(gnTVGLibrary, "_SetScreenRecordingNonVisibleWindows")
    Global TVG_SetScreenRecordingSizePercent.pr_SetScreenRecordingSizePercent                                                 = GetFunction(gnTVGLibrary, "_SetScreenRecordingSizePercent")
    Global TVG_SetScreenRecordingThroughClipboard.pr_SetScreenRecordingThroughClipboard                                       = GetFunction(gnTVGLibrary, "_SetScreenRecordingThroughClipboard")
    Global TVG_SetScreenRecordingWithCursor.pr_SetScreenRecordingWithCursor                                                   = GetFunction(gnTVGLibrary, "_SetScreenRecordingWithCursor")
    Global TVG_SetSendToDV_DeviceIndex.pr_SetSendToDV_DeviceIndex                                                             = GetFunction(gnTVGLibrary, "_SetSendToDV_DeviceIndex")
    Global TVG_SetSpeakerBalance.pr_SetSpeakerBalance                                                                         = GetFunction(gnTVGLibrary, "_SetSpeakerBalance")
    Global TVG_SetSpeakerControl.pr_SetSpeakerControl                                                                         = GetFunction(gnTVGLibrary, "_SetSpeakerControl")
    Global TVG_SetSpeakerVolume.pr_SetSpeakerVolume                                                                           = GetFunction(gnTVGLibrary, "_SetSpeakerVolume")
    Global TVG_SetStoragePath.pr_SetStoragePath                                                                               = GetFunction(gnTVGLibrary, "_SetStoragePath")
    Global TVG_SetStoragePathMode.pr_SetStoragePathMode                                                                       = GetFunction(gnTVGLibrary, "_SetStoragePathMode")
    Global TVG_SetStoreDeviceSettingsInRegistry.pr_SetStoreDeviceSettingsInRegistry                                           = GetFunction(gnTVGLibrary, "_SetStoreDeviceSettingsInRegistry")
    Global TVG_SetSyncCommands.pr_SetSyncCommands                                                                             = GetFunction(gnTVGLibrary, "_SetSyncCommands")
    Global TVG_SetSynchronizationRole.pr_SetSynchronizationRole                                                               = GetFunction(gnTVGLibrary, "_SetSynchronizationRole")
    Global TVG_SetSynchronized.pr_SetSynchronized                                                                             = GetFunction(gnTVGLibrary, "_SetSynchronized")
    Global TVG_SetSyncPreview.pr_SetSyncPreview                                                                               = GetFunction(gnTVGLibrary, "_SetSyncPreview")
    Global TVG_SetTextOverlay_Align.pr_SetTextOverlay_Align                                                                   = GetFunction(gnTVGLibrary, "_SetTextOverlay_Align")
    Global TVG_SetTextOverlay_AlphaBlend.pr_SetTextOverlay_AlphaBlend                                                         = GetFunction(gnTVGLibrary, "_SetTextOverlay_AlphaBlend")
    Global TVG_SetTextOverlay_AlphaBlendValue.pr_SetTextOverlay_AlphaBlendValue                                               = GetFunction(gnTVGLibrary, "_SetTextOverlay_AlphaBlendValue")
    Global TVG_SetTextOverlay_BkColor.pr_SetTextOverlay_BkColor                                                               = GetFunction(gnTVGLibrary, "_SetTextOverlay_BkColor")
    Global TVG_SetTextOverlay_CustomVar.pr_SetTextOverlay_CustomVar                                                           = GetFunction(gnTVGLibrary, "_SetTextOverlay_CustomVar")
    Global TVG_SetTextOverlay_Enabled.pr_SetTextOverlay_Enabled                                                               = GetFunction(gnTVGLibrary, "_SetTextOverlay_Enabled")
    Global TVG_SetTextOverlay_Font.pr_SetTextOverlay_Font                                                                     = GetFunction(gnTVGLibrary, "_SetTextOverlay_Font")
    Global TVG_SetTextOverlay_FontColor.pr_SetTextOverlay_FontColor                                                           = GetFunction(gnTVGLibrary, "_SetTextOverlay_FontColor")
    Global TVG_SetTextOverlay_FontSize.pr_SetTextOverlay_FontSize                                                             = GetFunction(gnTVGLibrary, "_SetTextOverlay_FontSize")
    Global TVG_SetTextOverlay_GradientColor.pr_SetTextOverlay_GradientColor                                                   = GetFunction(gnTVGLibrary, "_SetTextOverlay_GradientColor")
    Global TVG_SetTextOverlay_GradientMode.pr_SetTextOverlay_GradientMode                                                     = GetFunction(gnTVGLibrary, "_SetTextOverlay_GradientMode")
    Global TVG_SetTextOverlay_HighResFont.pr_SetTextOverlay_HighResFont                                                       = GetFunction(gnTVGLibrary, "_SetTextOverlay_HighResFont")
    Global TVG_SetTextOverlay_Left.pr_SetTextOverlay_Left                                                                     = GetFunction(gnTVGLibrary, "_SetTextOverlay_Left")
    Global TVG_SetTextOverlay_Orientation.pr_SetTextOverlay_Orientation                                                       = GetFunction(gnTVGLibrary, "_SetTextOverlay_Orientation")
    Global TVG_SetTextOverlay_Right.pr_SetTextOverlay_Right                                                                   = GetFunction(gnTVGLibrary, "_SetTextOverlay_Right")
    Global TVG_SetTextOverlay_Scrolling.pr_SetTextOverlay_Scrolling                                                           = GetFunction(gnTVGLibrary, "_SetTextOverlay_Scrolling")
    Global TVG_SetTextOverlay_ScrollingSpeed.pr_SetTextOverlay_ScrollingSpeed                                                 = GetFunction(gnTVGLibrary, "_SetTextOverlay_ScrollingSpeed")
    Global TVG_SetTextOverlay_Shadow.pr_SetTextOverlay_Shadow                                                                 = GetFunction(gnTVGLibrary, "_SetTextOverlay_Shadow")
    Global TVG_SetTextOverlay_ShadowColor.pr_SetTextOverlay_ShadowColor                                                       = GetFunction(gnTVGLibrary, "_SetTextOverlay_ShadowColor")
    Global TVG_SetTextOverlay_ShadowDirection.pr_SetTextOverlay_ShadowDirection                                               = GetFunction(gnTVGLibrary, "_SetTextOverlay_ShadowDirection")
    Global TVG_SetTextOverlay_String.pr_SetTextOverlay_String                                                                 = GetFunction(gnTVGLibrary, "_SetTextOverlay_String")
    Global TVG_SetTextOverlay_TargetDisplay.pr_SetTextOverlay_TargetDisplay                                                   = GetFunction(gnTVGLibrary, "_SetTextOverlay_TargetDisplay")
    Global TVG_SetTextOverlay_Top.pr_SetTextOverlay_Top                                                                       = GetFunction(gnTVGLibrary, "_SetTextOverlay_Top")
    Global TVG_SetTextOverlay_Transparent.pr_SetTextOverlay_Transparent                                                       = GetFunction(gnTVGLibrary, "_SetTextOverlay_Transparent")
    Global TVG_SetTextOverlay_VideoAlignment.pr_SetTextOverlay_VideoAlignment                                                 = GetFunction(gnTVGLibrary, "_SetTextOverlay_VideoAlignment")
    Global TVG_SetTextOverlayAlign.pr_SetTextOverlayAlign                                                                     = GetFunction(gnTVGLibrary, "_SetTextOverlayAlign")
    Global TVG_SetTextOverlayAlphaBlend.pr_SetTextOverlayAlphaBlend                                                           = GetFunction(gnTVGLibrary, "_SetTextOverlayAlphaBlend")
    Global TVG_SetTextOverlayAlphaBlendValue.pr_SetTextOverlayAlphaBlendValue                                                 = GetFunction(gnTVGLibrary, "_SetTextOverlayAlphaBlendValue")
    Global TVG_SetTextOverlayBkColor.pr_SetTextOverlayBkColor                                                                 = GetFunction(gnTVGLibrary, "_SetTextOverlayBkColor")
    Global TVG_SetTextOverlayEnabled.pr_SetTextOverlayEnabled                                                                 = GetFunction(gnTVGLibrary, "_SetTextOverlayEnabled")
    Global TVG_SetTextOverlayFont.pr_SetTextOverlayFont                                                                       = GetFunction(gnTVGLibrary, "_SetTextOverlayFont")
    Global TVG_SetTextOverlayFontColor.pr_SetTextOverlayFontColor                                                             = GetFunction(gnTVGLibrary, "_SetTextOverlayFontColor")
    Global TVG_SetTextOverlayFontSize.pr_SetTextOverlayFontSize                                                               = GetFunction(gnTVGLibrary, "_SetTextOverlayFontSize")
    Global TVG_SetTextOverlayGradientColor.pr_SetTextOverlayGradientColor                                                     = GetFunction(gnTVGLibrary, "_SetTextOverlayGradientColor")
    Global TVG_SetTextOverlayGradientMode.pr_SetTextOverlayGradientMode                                                       = GetFunction(gnTVGLibrary, "_SetTextOverlayGradientMode")
    Global TVG_SetTextOverlayHighResFont.pr_SetTextOverlayHighResFont                                                         = GetFunction(gnTVGLibrary, "_SetTextOverlayHighResFont")
    Global TVG_SetTextOverlayLeft.pr_SetTextOverlayLeft                                                                       = GetFunction(gnTVGLibrary, "_SetTextOverlayLeft")
    Global TVG_SetTextOverlayOrientation.pr_SetTextOverlayOrientation                                                         = GetFunction(gnTVGLibrary, "_SetTextOverlayOrientation")
    Global TVG_SetTextOverlayRight.pr_SetTextOverlayRight                                                                     = GetFunction(gnTVGLibrary, "_SetTextOverlayRight")
    Global TVG_SetTextOverlayScrolling.pr_SetTextOverlayScrolling                                                             = GetFunction(gnTVGLibrary, "_SetTextOverlayScrolling")
    Global TVG_SetTextOverlayScrollingSpeed.pr_SetTextOverlayScrollingSpeed                                                   = GetFunction(gnTVGLibrary, "_SetTextOverlayScrollingSpeed")
    Global TVG_SetTextOverlaySelector.pr_SetTextOverlaySelector                                                               = GetFunction(gnTVGLibrary, "_SetTextOverlaySelector")
    Global TVG_SetTextOverlayShadow.pr_SetTextOverlayShadow                                                                   = GetFunction(gnTVGLibrary, "_SetTextOverlayShadow")
    Global TVG_SetTextOverlayShadowColor.pr_SetTextOverlayShadowColor                                                         = GetFunction(gnTVGLibrary, "_SetTextOverlayShadowColor")
    Global TVG_SetTextOverlayShadowDirection.pr_SetTextOverlayShadowDirection                                                 = GetFunction(gnTVGLibrary, "_SetTextOverlayShadowDirection")
    Global TVG_SetTextOverlayString.pr_SetTextOverlayString                                                                   = GetFunction(gnTVGLibrary, "_SetTextOverlayString")
    Global TVG_SetTextOverlayTargetDisplay.pr_SetTextOverlayTargetDisplay                                                     = GetFunction(gnTVGLibrary, "_SetTextOverlayTargetDisplay")
    Global TVG_SetTextOverlayTop.pr_SetTextOverlayTop                                                                         = GetFunction(gnTVGLibrary, "_SetTextOverlayTop")
    Global TVG_SetTextOverlayTransparent.pr_SetTextOverlayTransparent                                                         = GetFunction(gnTVGLibrary, "_SetTextOverlayTransparent")
    Global TVG_SetTextOverlayVideoAlignment.pr_SetTextOverlayVideoAlignment                                                   = GetFunction(gnTVGLibrary, "_SetTextOverlayVideoAlignment")
    Global TVG_SetThirdPartyDeinterlacer.pr_SetThirdPartyDeinterlacer                                                         = GetFunction(gnTVGLibrary, "_SetThirdPartyDeinterlacer")
    Global TVG_SetTranslateMouseCoordinates.pr_SetTranslateMouseCoordinates                                                   = GetFunction(gnTVGLibrary, "_SetTranslateMouseCoordinates")
    Global TVG_SetTunerFrequency.pr_SetTunerFrequency                                                                         = GetFunction(gnTVGLibrary, "_SetTunerFrequency")
    Global TVG_SetTunerMode.pr_SetTunerMode                                                                                   = GetFunction(gnTVGLibrary, "_SetTunerMode")
    Global TVG_SetTVChannel.pr_SetTVChannel                                                                                   = GetFunction(gnTVGLibrary, "_SetTVChannel")
    Global TVG_SetTVCountryCode.pr_SetTVCountryCode                                                                           = GetFunction(gnTVGLibrary, "_SetTVCountryCode")
    Global TVG_SetTVTunerInputType.pr_SetTVTunerInputType                                                                     = GetFunction(gnTVGLibrary, "_SetTVTunerInputType")
    Global TVG_SetTVUseFrequencyOverrides.pr_SetTVUseFrequencyOverrides                                                       = GetFunction(gnTVGLibrary, "_SetTVUseFrequencyOverrides")
    Global TVG_SetUseClock.pr_SetUseClock                                                                                     = GetFunction(gnTVGLibrary, "_SetUseClock")
    Global TVG_Setv360_AspectRatio.pr_Setv360_AspectRatio                                                                     = GetFunction(gnTVGLibrary, "_Setv360_AspectRatio")
    Global TVG_Setv360_Enabled.pr_Setv360_Enabled                                                                             = GetFunction(gnTVGLibrary, "_Setv360_Enabled")
    Global TVG__Setv360_MasterAngle.pr_Setv360_MasterAngle                                                                    = GetFunction(gnTVGLibrary, "_Setv360_MasterAngle")
    Global TVG_Setv360_MouseAction.pr_Setv360_MouseAction                                                                     = GetFunction(gnTVGLibrary, "_Setv360_MouseAction")
    Global TVG_Setv360_MouseActionPercent.pr_Setv360_MouseActionPercent                                                       = GetFunction(gnTVGLibrary, "_Setv360_MouseActionPercent")
    Global TVG_SetVCRHorizontalLocking.pr_SetVCRHorizontalLocking                                                             = GetFunction(gnTVGLibrary, "_SetVCRHorizontalLocking")
    Global TVG_SetVersion.pr_SetVersion                                                                                       = GetFunction(gnTVGLibrary, "_SetVersion")
    Global TVG_SetVideoCompression_DataRate.pr_SetVideoCompression_DataRate                                                   = GetFunction(gnTVGLibrary, "_SetVideoCompression_DataRate")
    Global TVG_SetVideoCompression_KeyFrameRate.pr_SetVideoCompression_KeyFrameRate                                           = GetFunction(gnTVGLibrary, "_SetVideoCompression_KeyFrameRate")
    Global TVG_SetVideoCompression_PFramesPerKeyFrame.pr_SetVideoCompression_PFramesPerKeyFrame                               = GetFunction(gnTVGLibrary, "_SetVideoCompression_PFramesPerKeyFrame")
    Global TVG_SetVideoCompression_Quality.pr_SetVideoCompression_Quality                                                     = GetFunction(gnTVGLibrary, "_SetVideoCompression_Quality")
    Global TVG_SetVideoCompression_WindowSize.pr_SetVideoCompression_WindowSize                                               = GetFunction(gnTVGLibrary, "_SetVideoCompression_WindowSize")
    Global TVG_SetVideoCompressionDefaults.pr_SetVideoCompressionDefaults                                                     = GetFunction(gnTVGLibrary, "_SetVideoCompressionDefaults")
    Global TVG_SetVideoCompressionSettings.pr_SetVideoCompressionSettings                                                     = GetFunction(gnTVGLibrary, "_SetVideoCompressionSettings")
    Global TVG_SetVideoCompressor.pr_SetVideoCompressor                                                                       = GetFunction(gnTVGLibrary, "_SetVideoCompressor")
    Global TVG_SetVideoControlMode.pr_SetVideoControlMode                                                                     = GetFunction(gnTVGLibrary, "_SetVideoControlMode")
    Global TVG_SetVideoControlMode2.pr_SetVideoControlMode2                                                                   = GetFunction(gnTVGLibrary, "_SetVideoControlMode2")
    Global TVG_SetVideoControlSettings.pr_SetVideoControlSettings                                                             = GetFunction(gnTVGLibrary, "_SetVideoControlSettings")
    Global TVG_SetVideoCursor.pr_SetVideoCursor                                                                               = GetFunction(gnTVGLibrary, "_SetVideoCursor")
    Global TVG_SetVideoDelay.pr_SetVideoDelay                                                                                 = GetFunction(gnTVGLibrary, "_SetVideoDelay")
    Global TVG_SetVideoDevice.pr_SetVideoDevice                                                                               = GetFunction(gnTVGLibrary, "_SetVideoDevice")
    Global TVG_SetVideoDoubleBuffered.pr_SetVideoDoubleBuffered                                                               = GetFunction(gnTVGLibrary, "_SetVideoDoubleBuffered")
    Global TVG_SetVideoFormat.pr_SetVideoFormat                                                                               = GetFunction(gnTVGLibrary, "_SetVideoFormat")
    Global TVG_SetVideoFromImages_BitmapsSortedBy.pr_SetVideoFromImages_BitmapsSortedBy                                       = GetFunction(gnTVGLibrary, "_SetVideoFromImages_BitmapsSortedBy")
    Global TVG_SetVideoFromImages_RepeatIndefinitely.pr_SetVideoFromImages_RepeatIndefinitely                                 = GetFunction(gnTVGLibrary, "_SetVideoFromImages_RepeatIndefinitely")
    Global TVG_SetVideoFromImages_SourceDirectory.pr_SetVideoFromImages_SourceDirectory                                       = GetFunction(gnTVGLibrary, "_SetVideoFromImages_SourceDirectory")
    Global TVG_SetVideoFromImages_TemporaryFile.pr_SetVideoFromImages_TemporaryFile                                           = GetFunction(gnTVGLibrary, "_SetVideoFromImages_TemporaryFile")
    Global TVG_SetVideoInput.pr_SetVideoInput                                                                                 = GetFunction(gnTVGLibrary, "_SetVideoInput")
    Global TVG_SetVideoProcessingBrightness.pr_SetVideoProcessingBrightness                                                   = GetFunction(gnTVGLibrary, "_SetVideoProcessingBrightness")
    Global TVG_SetVideoProcessingContrast.pr_SetVideoProcessingContrast                                                       = GetFunction(gnTVGLibrary, "_SetVideoProcessingContrast")
    Global TVG_SetVideoProcessingDeinterlacing.pr_SetVideoProcessingDeinterlacing                                             = GetFunction(gnTVGLibrary, "_SetVideoProcessingDeinterlacing")
    Global TVG_SetVideoProcessingFlipHorizontal.pr_SetVideoProcessingFlipHorizontal                                           = GetFunction(gnTVGLibrary, "_SetVideoProcessingLeftRight")
    Global TVG_SetVideoProcessingFlipVertical.pr_SetVideoProcessingFlipVertical                                               = GetFunction(gnTVGLibrary, "_SetVideoProcessingTopDown")
    Global TVG_SetVideoProcessingGrayScale.pr_SetVideoProcessingGrayScale                                                     = GetFunction(gnTVGLibrary, "_SetVideoProcessingGrayScale")
    Global TVG_SetVideoProcessingHue.pr_SetVideoProcessingHue                                                                 = GetFunction(gnTVGLibrary, "_SetVideoProcessingHue")
    Global TVG_SetVideoProcessingInvertColors.pr_SetVideoProcessingInvertColors                                               = GetFunction(gnTVGLibrary, "_SetVideoProcessingInvertColors")
    Global TVG_SetVideoProcessingLeftRight.pr_SetVideoProcessingLeftRight                                                     = GetFunction(gnTVGLibrary, "_SetVideoProcessingLeftRight")
    Global TVG_SetVideoProcessingPixellization.pr_SetVideoProcessingPixellization                                             = GetFunction(gnTVGLibrary, "_SetVideoProcessingPixellization")
    Global TVG_SetVideoProcessingRotation.pr_SetVideoProcessingRotation                                                       = GetFunction(gnTVGLibrary, "_SetVideoProcessingRotation")
    Global TVG_SetVideoProcessingRotationCustomAngle.pr_SetVideoProcessingRotationCustomAngle                                 = GetFunction(gnTVGLibrary, "_SetVideoProcessingRotationCustomAngle")
    Global TVG_SetVideoProcessingSaturation.pr_SetVideoProcessingSaturation                                                   = GetFunction(gnTVGLibrary, "_SetVideoProcessingSaturation")
    Global TVG_SetVideoProcessingTopDown.pr_SetVideoProcessingTopDown                                                         = GetFunction(gnTVGLibrary, "_SetVideoProcessingTopDown")
    Global TVG_SetVideoQuality.pr_SetVideoQuality                                                                             = GetFunction(gnTVGLibrary, "_SetVideoQuality")
    Global TVG_SetVideoQualitySettings.pr_SetVideoQualitySettings                                                             = GetFunction(gnTVGLibrary, "_SetVideoQualitySettings")
    Global TVG_SetVideoRenderer.pr_SetVideoRenderer                                                                           = GetFunction(gnTVGLibrary, "_SetVideoRenderer")
    Global TVG_SetVideoRendererExternal.pr_SetVideoRendererExternal                                                           = GetFunction(gnTVGLibrary, "_SetVideoRendererExternal")
    Global TVG_SetVideoRendererExternalIndex.pr_SetVideoRendererExternalIndex                                                 = GetFunction(gnTVGLibrary, "_SetVideoRendererExternalIndex")
    Global TVG_SetVideoRendererPriority.pr_SetVideoRendererPriority                                                           = GetFunction(gnTVGLibrary, "_SetVideoRendererPriority")
    Global TVG_SetVideoSize.pr_SetVideoSize                                                                                   = GetFunction(gnTVGLibrary, "_SetVideoSize")
    Global TVG_SetVideoSource.pr_SetVideoSource                                                                               = GetFunction(gnTVGLibrary, "_SetVideoSource")
    Global TVG_SetVideoSource_FileOrURL.pr_SetVideoSource_FileOrURL                                                           = GetFunction(gnTVGLibrary, "_SetVideoSource_FileOrURL")
    Global TVG_SetVideoSource_FileOrURL_StartTime.pr_SetVideoSource_FileOrURL_StartTime                                       = GetFunction(gnTVGLibrary, "_SetVideoSource_FileOrURL_StartTime")
    Global TVG_SetVideoSource_FileOrURL_StopTime.pr_SetVideoSource_FileOrURL_StopTime                                         = GetFunction(gnTVGLibrary, "_SetVideoSource_FileOrURL_StopTime")
    Global TVG_SetVideoStreamNumber.pr_SetVideoStreamNumber                                                                   = GetFunction(gnTVGLibrary, "_SetVideoStreamNumber")
    Global TVG_SetVideoSubtype.pr_SetVideoSubtype                                                                             = GetFunction(gnTVGLibrary, "_SetVideoSubtype")
    Global TVG_SetVideoVisibleWhenStopped.pr_SetVideoVisibleWhenStopped                                                       = GetFunction(gnTVGLibrary, "_SetVideoVisibleWhenStopped")
    Global TVG_SetVirtualAudioStreamControl.pr_SetVirtualAudioStreamControl                                                   = GetFunction(gnTVGLibrary, "_SetVirtualAudioStreamControl")
    Global TVG_SetVirtualVideoStreamControl.pr_SetVirtualVideoStreamControl                                                   = GetFunction(gnTVGLibrary, "_SetVirtualVideoStreamControl")
    Global TVG_SetVMR9ImageAdjustmentValue.pr_SetVMR9ImageAdjustmentValue                                                     = GetFunction(gnTVGLibrary, "_SetVMR9ImageAdjustmentValue")
    Global TVG_SetVuMeter.pr_SetVuMeter                                                                                       = GetFunction(gnTVGLibrary, "_SetVuMeter")
    Global TVG_SetVUMeter_Enabled.pr_SetVUMeter_Enabled                                                                       = GetFunction(gnTVGLibrary, "_SetVUMeter_Enabled")
    Global TVG_SetVUMeterSetting.pr_SetVUMeterSetting                                                                         = GetFunction(gnTVGLibrary, "_SetVUMeterSetting")
    Global TVG_SetWebcamStillCaptureButton.pr_SetWebcamStillCaptureButton                                                     = GetFunction(gnTVGLibrary, "_SetWebcamStillCaptureButton")
    Global TVG_SetWindowRecordingByHandle.pr_SetWindowRecordingByHandle                                                       = GetFunction(gnTVGLibrary, "_SetWindowRecordingByHandle")
    Global TVG_SetWindowRecordingByName.pr_SetWindowRecordingByName                                                           = GetFunction(gnTVGLibrary, "_SetWindowRecordingByName")
    Global TVG_SetWindowTransparency.pr_SetWindowTransparency                                                                 = GetFunction(gnTVGLibrary, "_SetWindowTransparency")
    Global TVG_SetZoomCoeff.pr_SetZoomCoeff                                                                                   = GetFunction(gnTVGLibrary, "_SetZoomCoeff")
    Global TVG_SetZoomXCenter.pr_SetZoomXCenter                                                                               = GetFunction(gnTVGLibrary, "_SetZoomXCenter")
    Global TVG_SetZoomYCenter.pr_SetZoomYCenter                                                                               = GetFunction(gnTVGLibrary, "_SetZoomYCenter")
    Global TVG_ShowDebugWindow.pr_ShowDebugWindow                                                                             = GetFunction(gnTVGLibrary, "_ShowDebugWindow")
    Global TVG_ShowDialog.pr_ShowDialog                                                                                       = GetFunction(gnTVGLibrary, "_ShowDialog")
    Global TVG_StartAudioRecording.pr_StartAudioRecording                                                                     = GetFunction(gnTVGLibrary, "_StartAudioRecording")
    Global TVG_StartAudioRendering.pr_StartAudioRendering                                                                     = GetFunction(gnTVGLibrary, "_StartAudioRendering")
    Global TVG_StartPreview.pr_StartPreview                                                                                   = GetFunction(gnTVGLibrary, "_StartPreview")
    Global TVG_StartPTZ.pr_StartPTZ                                                                                           = GetFunction(gnTVGLibrary, "_StartPTZ")
    Global TVG_StartRecording.pr_StartRecording                                                                               = GetFunction(gnTVGLibrary, "_StartRecording")
    Global TVG_StartReencoding.pr_StartReencoding                                                                             = GetFunction(gnTVGLibrary, "_StartReencoding")
    Global TVG_StartSynchronized.pr_StartSynchronized                                                                         = GetFunction(gnTVGLibrary, "_StartSynchronized")
    Global TVG_Stop.pr_Stop                                                                                                   = GetFunction(gnTVGLibrary, "_Stop")
    Global TVG_StopPlayer.pr_StopPlayer                                                                                       = GetFunction(gnTVGLibrary, "_StopPlayer")
    Global TVG_StopPreview.pr_StopPreview                                                                                     = GetFunction(gnTVGLibrary, "_StopPreview")
    Global TVG_StopRecording.pr_StopRecording                                                                                 = GetFunction(gnTVGLibrary, "_StopRecording")
    Global TVG_StopReencoding.pr_StopReencoding                                                                               = GetFunction(gnTVGLibrary, "_StopReencoding")
    Global TVG_TextOverlay_CreateCustomFont.pr_TextOverlay_CreateCustomFont                                                   = GetFunction(gnTVGLibrary, "_TextOverlay_CreateCustomFont")
    Global TVG_ThirdPartyFilter_AddToList.pr_ThirdPartyFilter_AddToList                                                       = GetFunction(gnTVGLibrary, "_ThirdPartyFilter_AddToList")
    Global TVG_ThirdPartyFilter_ClearList.pr_ThirdPartyFilter_ClearList                                                       = GetFunction(gnTVGLibrary, "_ThirdPartyFilter_ClearList")
    Global TVG_ThirdPartyFilter_Enable.pr_ThirdPartyFilter_Enable                                                             = GetFunction(gnTVGLibrary, "_ThirdPartyFilter_Enable")
    Global TVG_ThirdPartyFilter_RemoveFromList.pr_ThirdPartyFilter_RemoveFromList                                             = GetFunction(gnTVGLibrary, "_ThirdPartyFilter_RemoveFromList")
    Global TVG_ThirdPartyFilter_ShowDialog.pr_ThirdPartyFilter_ShowDialog                                                     = GetFunction(gnTVGLibrary, "_ThirdPartyFilter_ShowDialog")
    Global TVG_TVClearFrequencyOverrides.pr_TVClearFrequencyOverrides                                                         = GetFunction(gnTVGLibrary, "_TVClearFrequencyOverrides")
    Global TVG_TVGetMinMaxChannels.pr_TVGetMinMaxChannels                                                                     = GetFunction(gnTVGLibrary, "_TVGetMinMaxChannels")
    Global TVG_TVSetChannelFrequencyOverride.pr_TVSetChannelFrequencyOverride                                                 = GetFunction(gnTVGLibrary, "_TVSetChannelFrequencyOverride")
    Global TVG_TVStartAutoScan.pr_TVStartAutoScan                                                                             = GetFunction(gnTVGLibrary, "_TVStartAutoScan")
    Global TVG_TVStartAutoScanChannels.pr_TVStartAutoScanChannels                                                             = GetFunction(gnTVGLibrary, "_TVStartAutoScanChannels")
    Global TVG_TVStopAutoScan.pr_TVStopAutoScan                                                                               = GetFunction(gnTVGLibrary, "_TVStopAutoScan")
    Global TVG_UpdateTrackbarBounds.pr_UpdateTrackbarBounds                                                                   = GetFunction(gnTVGLibrary, "_UpdateTrackbarBounds")
    Global TVG_UseNearestVideoSize.pr_UseNearestVideoSize                                                                     = GetFunction(gnTVGLibrary, "_UseNearestVideoSize")
    Global TVG_v360_AddYawPitchRoll.pr_v360_AddYawPitchRoll                                                                   = GetFunction(gnTVGLibrary, "_v360_AddYawPitchRoll")
    Global TVG_v360_GetAngle.pr_v360_GetAngle                                                                                 = GetFunction(gnTVGLibrary, "_v360_GetAngle")
    Global TVG_v360_GetYawPitchRoll.pr_v360_GetYawPitchRoll                                                                   = GetFunction(gnTVGLibrary, "_v360_GetYawPitchRoll")
    Global TVG_v360_ResetAnglesToDefault.pr_v360_ResetAnglesToDefault                                                         = GetFunction(gnTVGLibrary, "_v360_ResetAnglesToDefault")
    Global TVG_v360_SetAngle.pr_v360_SetAngle                                                                                 = GetFunction(gnTVGLibrary, "_v360_SetAngle")
    Global TVG_v360_SetInterpolatione.pr_v360_SetInterpolation                                                                = GetFunction(gnTVGLibrary, "_v360_SetInterpolation")
    Global TVG_v360_SetProjection.pr_v360_SetProjection                                                                       = GetFunction(gnTVGLibrary, "_v360_SetProjection")
    Global TVG_v360_SetStereoFormat.pr_v360_SetStereoFormat                                                                   = GetFunction(gnTVGLibrary, "_v360_SetStereoFormat")
    Global TVG_v360_SetTranspose.pr_v360_SetTranspose                                                                         = GetFunction(gnTVGLibrary, "_v360_SetTranspose")
    Global TVG_v360_SetYawPitchRoll.pr_v360_SetYawPitchRoll                                                                   = GetFunction(gnTVGLibrary, "_v360_SetYawPitchRoll")
    Global TVG_VDECGetHorizontalLocked.pr_VDECGetHorizontalLocked                                                             = GetFunction(gnTVGLibrary, "_VDECGetHorizontalLocked")
    Global TVG_VDECGetNumberOfLines.pr_VDECGetNumberOfLines                                                                   = GetFunction(gnTVGLibrary, "_VDECGetNumberOfLines")
    Global TVG_VDECGetOutputEnable.pr_VDECGetOutputEnable                                                                     = GetFunction(gnTVGLibrary, "_VDECGetOutputEnable")
    Global TVG_VDECGetVCRHorizontalLocking.pr_VDECGetVCRHorizontalLocking                                                     = GetFunction(gnTVGLibrary, "_VDECGetVCRHorizontalLocking")
    Global TVG_VDECPutOutputEnable.pr_VDECPutOutputEnable                                                                     = GetFunction(gnTVGLibrary, "_VDECPutOutputEnable")
    Global TVG_VDECPutTVFormat.pr_VDECPutTVFormat                                                                             = GetFunction(gnTVGLibrary, "_VDECPutTVFormat")
    Global TVG_VDECPutVCRHorizontalLocking.pr_VDECPutVCRHorizontalLocking                                                     = GetFunction(gnTVGLibrary, "_VDECPutVCRHorizontalLocking")
    Global TVG_VideoCompressorIndex.pr_VideoCompressorIndex                                                                   = GetFunction(gnTVGLibrary, "_VideoCompressorIndex")
    Global TVG_VideoDeviceIndex.pr_VideoDeviceIndex                                                                           = GetFunction(gnTVGLibrary, "_VideoDeviceIndex")
    Global TVG_VideoDeviceIndex.pr_VideoDeviceIndex                                                                           = GetFunction(gnTVGLibrary, "_VideoDeviceIndex")
    Global TVG_VideoDeviceIndexFromId.pr_VideoDeviceIndexFromId                                                               = GetFunction(gnTVGLibrary, "_VideoDeviceIndexFromId")
    Global TVG_VideoFromImages_CreateSetOfBitmaps.pr_VideoFromImages_CreateSetOfBitmaps                                       = GetFunction(gnTVGLibrary, "_VideoFromImages_CreateSetOfBitmaps")
    Global TVG_VideoInputIndex.pr_VideoInputIndex                                                                             = GetFunction(gnTVGLibrary, "_VideoInputIndex")
    Global TVG_VideoQualityAuto.pr_VideoQualityAuto                                                                           = GetFunction(gnTVGLibrary, "_VideoQualityAuto")
    Global TVG_VideoQualityDefault.pr_VideoQualityDefault                                                                     = GetFunction(gnTVGLibrary, "_VideoQualityDefault")
    Global TVG_VideoQualityMax.pr_VideoQualityMax                                                                             = GetFunction(gnTVGLibrary, "_VideoQualityMax")
    Global TVG_VideoQualityMin.pr_VideoQualityMin                                                                             = GetFunction(gnTVGLibrary, "_VideoQualityMin")
    Global TVG_VideoQualityStep.pr_VideoQualityStep                                                                           = GetFunction(gnTVGLibrary, "_VideoQualityStep")
    Global TVG_VideoQualityValue.pr_VideoQualityValue                                                                         = GetFunction(gnTVGLibrary, "_VideoQualityValue")
    Global TVG_VideoSizeIndex.pr_VideoSizeIndex                                                                               = GetFunction(gnTVGLibrary, "_VideoSizeIndex")
    Global TVG_VideoSubtypeIndex.pr_VideoSubtypeIndex                                                                         = GetFunction(gnTVGLibrary, "_VideoSubtypeIndex")
    Global TVG_WriteScriptCommand.pr_WriteScriptCommand                                                                       = GetFunction(gnTVGLibrary, "_WriteScriptCommand")
    Global TVG_zReservedInternal1.pr_zReservedInternal1                                                                       = GetFunction(gnTVGLibrary, "_zReservedInternal1")
    Global TVG_zReservedInternal2.pr_zReservedInternal2                                                                       = GetFunction(gnTVGLibrary, "_zReservedInternal2")
    Global TVG_zReservedInternal3.pr_zReservedInternal3                                                                       = GetFunction(gnTVGLibrary, "_zReservedInternal3")
    Global TVG_zReservedInternal4.pr_zReservedInternal4                                                                       = GetFunction(gnTVGLibrary, "_zReservedInternal4")

    ;- Debug
    Debug "TVG_CreateVideoGrabber=" + TVG_CreateVideoGrabber

  EndIf

  ProcedureReturn bResult

EndProcedure

Procedure closeTVGLibrary()
  If gnTVGLibrary
    CloseLibrary(gnTVGLibrary)
    gnTVGLibrary = 0
  EndIf
EndProcedure

; unconditional procedure call - executed during program load
Debug "calling checkTVGAvailable()"
gbTVGAvailable = openTVGLibrary()
Debug "gbTVGAvailable=" + Str(gbTVGAvailable)

; EOF
