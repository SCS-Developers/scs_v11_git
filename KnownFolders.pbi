; File: KnownFolders.pbi
; code by GJ-68 in PB Forum Topic "SHGetKnownFolderPath_()" at http://www.purebasic.fr/english/viewtopic.php?f=5&t=55173

EnableExplicit

DataSection
  FOLDERID_NetworkFolder: ; {D20BEEC4-5CA8-4905-AE3B-BF251EA09B53}
  Data.l $D20BEEC4
  Data.w $5CA8,$4905
  Data.b $AE,$3B,$BF,$25,$1E,$A0,$9B,$53
  
  FOLDERID_ComputerFolder: ; {0AC0837C-BBF8-452A-850D-79D08E667CA7}
  Data.l $0AC0837C
  Data.w $BBF8,$452A
  Data.b $85,$0D,$79,$D0,$8E,$66,$7C,$A7
  
  FOLDERID_InternetFolder: ; {4D9F7874-4E0C-4904-967B-40B0D20C3E4B}
  Data.l $4D9F7874
  Data.w $4E0C,$4904
  Data.b $96,$7B,$40,$B0,$D2,$0C,$3E,$4B
  
  FOLDERID_ControlPanelFolder: ; {82A74AEB-AEB4-465C-A014-D097EE346D63}
  Data.l $82A74AEB
  Data.w $AEB4,$465C
  Data.b $A0,$14,$D0,$97,$EE,$34,$6D,$63
  
  FOLDERID_PrintersFolder: ; {76FC4E2D-D6AD-4519-A663-37BD56068185}
  Data.l $76FC4E2D
  Data.w $D6AD,$4519
  Data.b $A6,$63,$37,$BD,$56,$06,$81,$85
  
  FOLDERID_SyncManagerFolder: ; {43668BF8-C14E-49B2-97C9-747784D784B7}
  Data.l $43668BF8
  Data.w $C14E,$49B2
  Data.b $97,$C9,$74,$77,$84,$D7,$84,$B7
  
  FOLDERID_SyncSetupFolder: ; {0F214138-B1D3-4A90-BBA9-27CBC0C5389A}
  Data.l $F214138
  Data.w $B1D3,$4A90
  Data.b $BB,$A9,$27,$CB,$C0,$C5,$38,$9A
  
  FOLDERID_ConflictFolder: ; {4BFEFB45-347D-4006-A5BE-AC0CB0567192}
  Data.l $4BFEFB45
  Data.w $347D,$4006
  Data.b $A5,$BE,$AC,$0C,$B0,$56,$71,$92
  
  FOLDERID_SyncResultsFolder: ; {289A9A43-BE44-4057-A41B-587A76D7E7F9}
  Data.l $289A9A43
  Data.w $BE44,$4057
  Data.b $A4,$1B,$58,$7A,$76,$D7,$E7,$F9
  
  FOLDERID_RecycleBinFolder: ; {B7534046-3ECB-4C18-BE4E-64CD4CB7D6AC}
  Data.l $B7534046
  Data.w $3ECB,$4C18
  Data.b $BE,$4E,$64,$CD,$4C,$B7,$D6,$AC
  
  FOLDERID_ConnectionsFolder: ; {6F0CD92B-2E97-45D1-88FF-B0D186B8DEDD}
  Data.l $6F0CD92B
  Data.w $2E97,$45D1
  Data.b $88,$FF,$B0,$D1,$86,$B8,$DE,$DD
  
  FOLDERID_Fonts: ; {FD228CB7-AE11-4AE3-864C-16F3910AB8FE}
  Data.l $FD228CB7
  Data.w $AE11,$4AE3
  Data.b $86,$4C,$16,$F3,$91,$0A,$B8,$FE
  
  FOLDERID_Desktop: ; {B4BFCC3A-DB2C-424C-B029-7FE99A87C641}
  Data.l $B4BFCC3A
  Data.w $DB2C,$424C
  Data.b $B0,$29,$7F,$E9,$9A,$87,$C6,$41
  
  FOLDERID_Startup: ; {B97D20BB-F46A-4C97-BA10-5E3608430854}
  Data.l $B97D20BB
  Data.w $F46A,$4C97
  Data.b $BA,$10,$5E,$36,$08,$43,$08,$54
  
  FOLDERID_Programs: ; {A77F5D77-2E2B-44C3-A6A2-ABA601054A51}
  Data.l $A77F5D77
  Data.w $2E2B,$44C3
  Data.b $A6,$A2,$AB,$A6,$01,$05,$4A,$51
  
  FOLDERID_StartMenu: ; {625B53C3-AB48-4EC1-BA1F-A1EF4146FC19}
  Data.l $625B53C3
  Data.w $AB48,$4EC1
  Data.b $BA,$1F,$A1,$EF,$41,$46,$FC,$19
  
  FOLDERID_Recent: ; {AE50C081-EBD2-438A-8655-8A092E34987A}
  Data.l $AE50C081
  Data.w $EBD2,$438A
  Data.b $86,$55,$8A,$09,$2E,$34,$98,$7A
  
  FOLDERID_SendTo: ; {8983036C-27C0-404B-8F08-102D10DCFD74}
  Data.l $8983036C
  Data.w $27C0,$404B
  Data.b $8F,$08,$10,$2D,$10,$DC,$FD,$74
  
  FOLDERID_Documents: ; {FDD39AD0-238F-46AF-ADB4-6C85480369C7}
  Data.l $FDD39AD0
  Data.w $238F,$46AF
  Data.b $AD,$B4,$6C,$85,$48,$03,$69,$C7
  
  FOLDERID_Favorites: ; {1777F761-68AD-4D8A-87BD-30B759FA33DD}
  Data.l $1777F761
  Data.w $68AD,$4D8A
  Data.b $87,$BD,$30,$B7,$59,$FA,$33,$DD
  
  FOLDERID_NetHood: ; {C5ABBF53-E17F-4121-8900-86626FC2C973}
  Data.l $C5ABBF53
  Data.w $E17F,$4121
  Data.b $89,$00,$86,$62,$6F,$C2,$C9,$73
  
  FOLDERID_PrintHood: ; {9274BD8D-CFD1-41C3-B35E-B13F55A758F4}
  Data.l $9274BD8D
  Data.w $CFD1,$41C3
  Data.b $B3,$5E,$B1,$3F,$55,$A7,$58,$F4
  
  FOLDERID_Templates: ; {A63293E8-664E-48DB-A079-DF759E0509F7}
  Data.l $A63293E8
  Data.w $664E,$48DB
  Data.b $A0,$79,$DF,$75,$9E,$05,$09,$F7
  
  FOLDERID_CommonStartup: ; {82A5EA35-D9CD-47C5-9629-E15D2F714E6E}
  Data.l $82A5EA35
  Data.w $D9CD,$47C5
  Data.b $96,$29,$E1,$5D,$2F,$71,$4E,$6E
  
  FOLDERID_CommonPrograms: ; {0139D44E-6AFE-49F2-8690-3DAFCAE6FFB8}
  Data.l $0139D44E
  Data.w $6AFE,$49F2
  Data.b $86,$90,$3D,$AF,$CA,$E6,$FF,$B8
  
  FOLDERID_CommonStartMenu: ; {A4115719-D62E-491D-AA7C-E74B8BE3B067}
  Data.l $A4115719
  Data.w $D62E,$491D
  Data.b $AA,$7C,$E7,$4B,$8B,$E3,$B0,$67
  
  FOLDERID_PublicDesktop: ; {C4AA340D-F20F-4863-AFEF-F87EF2E6BA25}
  Data.l $C4AA340D
  Data.w $F20F,$4863
  Data.b $AF,$EF,$F8,$7E,$F2,$E6,$BA,$25
  
  FOLDERID_ProgramData: ; {62AB5D82-FDC1-4DC3-A9DD-070D1D495D97}
  Data.l $62AB5D82
  Data.w $FDC1,$4DC3
  Data.b $A9,$DD,$07,$0D,$1D,$49,$5D,$97
  
  FOLDERID_CommonTemplates: ; {B94237E7-57AC-4347-9151-B08C6C32D1F7}
  Data.l $B94237E7
  Data.w $57AC,$4347
  Data.b $91,$51,$B0,$8C,$6C,$32,$D1,$F7
  
  FOLDERID_PublicDocuments: ; {ED4824AF-DCE4-45A8-81E2-FC7965083634}
  Data.l $ED4824AF
  Data.w $DCE4,$45A8
  Data.b $81,$E2,$FC,$79,$65,$08,$36,$34
  
  FOLDERID_RoamingAppData: ; {3EB685DB-65F9-4CF6-A03A-E3EF65729F3D}
  Data.l $3EB685DB
  Data.w $65F9,$4CF6
  Data.b $A0,$3A,$E3,$EF,$65,$72,$9F,$3D
  
  FOLDERID_LocalAppData: ; {F1B32785-6FBA-4FCF-9D55-7B8E7F157091}
  Data.l $F1B32785
  Data.w $6FBA,$4FCF
  Data.b $9D,$55,$7B,$8E,$7F,$15,$70,$91
  
  FOLDERID_LocalAppDataLow: ; {A520A1A4-1780-4FF6-BD18-167343C5AF16}
  Data.l $A520A1A4
  Data.w $1780,$4FF6
  Data.b $BD,$18,$16,$73,$43,$C5,$AF,$16
  
  FOLDERID_InternetCache: ; {352481E8-33BE-4251-BA85-6007CAEDCF9D}
  Data.l $352481E8
  Data.w $33BE,$4251
  Data.b $BA,$85,$60,$07,$CA,$ED,$CF,$9D
  
  FOLDERID_Cookies: ; {2B0F765D-C0E9-4171-908E-08A611B84FF6}
  Data.l $2B0F765D
  Data.w $C0E9,$4171
  Data.b $90,$8E,$08,$A6,$11,$B8,$4F,$F6
  
  FOLDERID_History: ; {D9DC8A3B-B784-432E-A781-5A1130A75963}
  Data.l $D9DC8A3B
  Data.w $B784,$432E
  Data.b $A7,$81,$5A,$11,$30,$A7,$59,$63
  
  FOLDERID_System: ; {1AC14E77-02E7-4E5D-B744-2EB1AE5198B7}
  Data.l $1AC14E77
  Data.w $02E7,$4E5D
  Data.b $B7,$44,$2E,$B1,$AE,$51,$98,$B7
  
  FOLDERID_SystemX86: ; {D65231B0-B2F1-4857-A4CE-A8E7C6EA7D27}
  Data.l $D65231B0
  Data.w $B2F1,$4857
  Data.b $A4,$CE,$A8,$E7,$C6,$EA,$7D,$27
  
  FOLDERID_Windows: ; {F38BF404-1D43-42F2-9305-67DE0B28FC23}
  Data.l $F38BF404
  Data.w $1D43,$42F2
  Data.b $93,$05,$67,$DE,$0B,$28,$FC,$23
  
  FOLDERID_Profile: ; {5E6C858F-0E22-4760-9AFE-EA3317B67173}
  Data.l $5E6C858F
  Data.w $0E22,$4760
  Data.b $9A,$FE,$EA,$33,$17,$B6,$71,$73
  
  FOLDERID_Pictures: ; {33E28130-4E1E-4676-835A-98395C3BC3BB}
  Data.l $33E28130
  Data.w $4E1E,$4676
  Data.b $83,$5A,$98,$39,$5C,$3B,$C3,$BB
  
  FOLDERID_ProgramFilesX86: ; {7C5A40EF-A0FB-4BFC-874A-C0F2E0B9FA8E}
  Data.l $7C5A40EF
  Data.w $A0FB,$4BFC
  Data.b $87,$4A,$C0,$F2,$E0,$B9,$FA,$8E
  
  FOLDERID_ProgramFilesCommonX86: ; {DE974D24-D9C6-4D3E-BF91-F4455120B917}
  Data.l $DE974D24
  Data.w $D9C6,$4D3E
  Data.b $BF,$91,$F4,$45,$51,$20,$B9,$17
  
  FOLDERID_ProgramFilesX64: ; {6D809377-6AF0-444B-8957-A3773F02200E}
  Data.l $6D809377
  Data.w $6AF0,$444B
  Data.b $89,$57,$A3,$77,$3F,$02,$20,$0E 
  
  FOLDERID_ProgramFilesCommonX64: ; {6365D5A7-0F0D-45E5-87F6-0DA56B6A4F7D}
  Data.l $6365D5A7
  Data.w $F0D,$45E5
  Data.b $87,$F6,$D,$A5,$6B,$6A,$4F,$7D 
  
  FOLDERID_ProgramFiles: ; {905E63B6-C1BF-494E-B29C-65B732D3D21A}
  Data.l $905E63B6
  Data.w $C1BF,$494E
  Data.b $B2,$9C,$65,$B7,$32,$D3,$D2,$1A
  
  FOLDERID_ProgramFilesCommon: ; {F7F1ED05-9F6D-47A2-AAAE-29D317C6F066}
  Data.l $F7F1ED05
  Data.w $9F6D,$47A2
  Data.b $AA,$AE,$29,$D3,$17,$C6,$F0,$66
  
  FOLDERID_UserProgramFiles: ; {5CD7AEE2-2219-4A67-B85D-6C9CE15660CB}
  Data.l $5CD7AEE2
  Data.w $2219,$4A67
  Data.b $B8,$5D,$6C,$9C,$E1,$56,$60,$CB
  
  FOLDERID_UserProgramFilesCommon: ; {BCBD3057-CA5C-4622-B42D-BC56DB0AE516}
  Data.l $BCBD3057
  Data.w $CA5C,$4622
  Data.b $B4,$2D,$BC,$56,$DB,$0A,$E5,$16
  
  FOLDERID_AdminTools: ; {724EF170-A42D-4FEF-9F26-B60E846FBA4F}
  Data.l $724EF170
  Data.w $A42D,$4FEF
  Data.b $9F,$26,$B6,$0E,$84,$6F,$BA,$4F
  
  FOLDERID_CommonAdminTools: ; {D0384E7D-BAC3-4797-8F14-CBA229B392B5}
  Data.l $D0384E7D
  Data.w $BAC3,$4797
  Data.b $8F,$14,$CB,$A2,$29,$B3,$92,$B5
  
  FOLDERID_Music: ; {4BD8D571-6D19-48D3-BE97-422220080E43}
  Data.l $4BD8D571
  Data.w $6D19,$48D3
  Data.b $BE,$97,$42,$22,$20,$08,$0E,$43
  
  FOLDERID_Videos: ; {18989B1D-99B5-455B-841C-AB7C74E4DDFC}
  Data.l $18989B1D
  Data.w $99B5,$455B
  Data.b $84,$1C,$AB,$7C,$74,$E4,$DD,$FC
  
  FOLDERID_Ringtones: ; {C870044B-F49E-4126-A9C3-B52A1FF411E8}
  Data.l $C870044B
  Data.w $F49E,$4126
  Data.b $A9,$C3,$B5,$2A,$1F,$F4,$11,$E8
  
  FOLDERID_PublicPictures: ; {B6EBFB86-6907-413C-9AF7-4FC2ABF07CC5}
  Data.l $B6EBFB86
  Data.w $6907,$413C
  Data.b $9A,$F7,$4F,$C2,$AB,$F0,$7C,$C5
  
  FOLDERID_PublicMusic: ; {3214FAB5-9757-4298-BB61-92A9DEAA44FF}
  Data.l $3214FAB5
  Data.w $9757,$4298
  Data.b $BB,$61,$92,$A9,$DE,$AA,$44,$FF
  
  FOLDERID_PublicVideos: ; {2400183A-6185-49FB-A2D8-4A392A602BA3}
  Data.l $2400183A
  Data.w $6185,$49FB
  Data.b $A2,$D8,$4A,$39,$2A,$60,$2B,$A3
  
  FOLDERID_PublicRingtones: ; {E555AB60-153B-4D17-9F04-A5FE99FC15EC}
  Data.l $E555AB60
  Data.w $153B,$4D17
  Data.b $9F,$04,$A5,$FE,$99,$FC,$15,$EC
  
  FOLDERID_ResourceDir: ; {8AD10C31-2ADB-4296-A8F7-E4701232C972}
  Data.l $8AD10C31
  Data.w $2ADB,$4296
  Data.b $A8,$F7,$E4,$70,$12,$32,$C9,$72
  
  FOLDERID_LocalizedResourcesDir: ; {2A00375E-224C-49DE-B8D1-440DF7EF3DDC}
  Data.l $2A00375E
  Data.w $224C,$49DE
  Data.b $B8,$D1,$44,$0D,$F7,$EF,$3D,$DC
  
  FOLDERID_CommonOEMLinks: ; {C1BAE2D0-10DF-4334-BEDD-7AA20B227A9D}
  Data.l $C1BAE2D0
  Data.w $10DF,$4334
  Data.b $BE,$DD,$7A,$A2,$0B,$22,$7A,$9D
  
  FOLDERID_CDBurning: ; {9E52AB10-F80D-49DF-ACB8-4330F5687855}
  Data.l $9E52AB10
  Data.w $F80D,$49DF
  Data.b $AC,$B8,$43,$30,$F5,$68,$78,$55
  
  FOLDERID_UserProfiles: ; {0762D272-C50A-4BB0-A382-697DCD729B80}
  Data.l $0762D272
  Data.w $C50A,$4BB0
  Data.b $A3,$82,$69,$7D,$CD,$72,$9B,$80
  
  FOLDERID_Playlists: ; {DE92C1C7-837F-4F69-A3BB-86E631204A23}
  Data.l $DE92C1C7
  Data.w $837F,$4F69
  Data.b $A3,$BB,$86,$E6,$31,$20,$4A,$23
  
  FOLDERID_SamplePlaylists: ; {15CA69B3-30EE-49C1-ACE1-6B5EC372AFB5}
  Data.l $15CA69B3
  Data.w $30EE,$49C1
  Data.b $AC,$E1,$6B,$5E,$C3,$72,$AF,$B5
  
  FOLDERID_SampleMusic: ; {B250C668-F57D-4EE1-A63C-290EE7D1AA1F}
  Data.l $B250C668
  Data.w $F57D,$4EE1
  Data.b $A6,$3C,$29,$0E,$E7,$D1,$AA,$1F
  
  FOLDERID_SamplePictures: ; {C4900540-2379-4C75-844B-64E6FAF8716B}
  Data.l $C4900540
  Data.w $2379,$4C75
  Data.b $84,$4B,$64,$E6,$FA,$F8,$71,$6B
  
  FOLDERID_SampleVideos: ; {859EAD94-2E85-48AD-A71A-0969CB56A6CD}
  Data.l $859EAD94
  Data.w $2E85,$48AD
  Data.b $A7,$1A,$09,$69,$CB,$56,$A6,$CD
  
  FOLDERID_PhotoAlbums: ; {69D2CF90-FC33-4FB7-9A0C-EBB0F0FCB43C}
  Data.l $69D2CF90
  Data.w $FC33,$4FB7
  Data.b $9A,$0C,$EB,$B0,$F0,$FC,$B4,$3C
  
  FOLDERID_Public: ; {DFDF76A2-C82A-4D63-906A-5644AC457385}
  Data.l $DFDF76A2
  Data.w $C82A,$4D63
  Data.b $90,$6A,$56,$44,$AC,$45,$73,$85
  
  FOLDERID_ChangeRemovePrograms: ; {DF7266AC-9274-4867-8D55-3BD661DE872D}
  Data.l $DF7266AC
  Data.w $9274,$4867
  Data.b $8D,$55,$3B,$D6,$61,$DE,$87,$2D
  
  FOLDERID_AppUpdates: ; {A305CE99-F527-492B-8B1A-7E76FA98D6E4}
  Data.l $A305CE99
  Data.w $F527,$492B
  Data.b $8B,$1A,$7E,$76,$FA,$98,$D6,$E4
  
  FOLDERID_AddNewPrograms: ; {DE61D971-5EBC-4F02-A3A9-6C82895E5C04}
  Data.l $DE61D971
  Data.w $5EBC,$4F02
  Data.b $A3,$A9,$6C,$82,$89,$5E,$5C,$04
  
  FOLDERID_Downloads: ; {374DE290-123F-4565-9164-39C4925E467B}
  Data.l $374DE290
  Data.w $123F,$4565
  Data.b $91,$64,$39,$C4,$92,$5E,$46,$7B
  
  FOLDERID_PublicDownloads: ; {3D644C9B-1FB8-4F30-9B45-F670235F79C0}
  Data.l $3D644C9B
  Data.w $1FB8,$4F30
  Data.b $9B,$45,$F6,$70,$23,$5F,$79,$C0
  
  FOLDERID_SavedSearches: ; {7D1D3A04-DEBB-4115-95CF-2F29DA2920DA}
  Data.l $7D1D3A04
  Data.w $DEBB,$4115
  Data.b $95,$CF,$2F,$29,$DA,$29,$20,$DA
  
  FOLDERID_QuickLaunch: ; {52A4F021-7B75-48A9-9F6B-4B87A210BC8F}
  Data.l $52A4F021
  Data.w $7B75,$48A9
  Data.b $9F,$6B,$4B,$87,$A2,$10,$BC,$8F
  
  FOLDERID_Contacts: ; {56784854-C6CB-462B-8169-88E350ACB882}
  Data.l $56784854
  Data.w $C6CB,$462B
  Data.b $81,$69,$88,$E3,$50,$AC,$B8,$82
  
  FOLDERID_PublicGameTasks: ; {DEBF2536-E1A8-4C59-B6A2-414586476AEA}
  Data.l $DEBF2536
  Data.w $E1A8,$4C59
  Data.b $B6,$A2,$41,$45,$86,$47,$6A,$EA
  
  FOLDERID_GameTasks: ; {054FAE61-4DD8-4787-80B6-090220C4B700}
  Data.l $54FAE61
  Data.w $4DD8,$4787
  Data.b $80,$B6,$9,$2,$20,$C4,$B7,$0
  
  FOLDERID_SavedGames: ; {4C5C32FF-BB9D-43B0-B5B4-2D72E54EAAA4}
  Data.l $4C5C32FF
  Data.w $BB9D,$43B0
  Data.b $B5,$B4,$2D,$72,$E5,$4E,$AA,$A4
  
  FOLDERID_Games: ; {CAC52C1A-B53D-4EDC-92D7-6B2E8AC19434}
  Data.l $CAC52C1A
  Data.w $B53D,$4EDC
  Data.b $92,$D7,$6B,$2E,$8A,$C1,$94,$34
  
  FOLDERID_SEARCH_MAPI: ; {98EC0E18-2098-4D44-8644-66979315A281}
  Data.l $98EC0E18
  Data.w $2098,$4D44
  Data.b $86,$44,$66,$97,$93,$15,$A2,$81
  
  FOLDERID_SEARCH_CSC: ; {EE32E446-31CA-4ABA-814F-A5EBD2FD6D5E}
  Data.l $EE32E446
  Data.w $31CA,$4ABA
  Data.b $81,$4F,$A5,$EB,$D2,$FD,$6D,$5E
  
  FOLDERID_Links: ; {BFB9D5E0-C6A9-404C-B2B2-AE6DB6AF4968}
  Data.l $BFB9D5E0
  Data.w $C6A9,$404C
  Data.b $B2,$B2,$AE,$6D,$B6,$AF,$49,$68
  
  FOLDERID_UsersFiles: ; {F3CE0F7C-4901-4ACC-8648-D5D44B04EF8F}
  Data.l $F3CE0F7C
  Data.w $4901,$4ACC
  Data.b $86,$48,$D5,$D4,$4B,$04,$EF,$8F
  
  FOLDERID_UsersLibraries: ; {A302545D-DEFF-464B-ABE8-61C8648D939B}
  Data.l $A302545D
  Data.w $DEFF,$464B
  Data.b $AB,$E8,$61,$C8,$64,$8D,$93,$9B
  
  FOLDERID_SearchHome: ; {190337D1-B8CA-4121-A639-6D472D16972A}
  Data.l $190337D1
  Data.w $B8CA,$4121
  Data.b $A6,$39,$6D,$47,$2D,$16,$97,$2A
  
  FOLDERID_OriginalImages: ; {2C36C0AA-5812-4B87-BFD0-4CD0DFB19B39}
  Data.l $2C36C0AA
  Data.w $5812,$4B87
  Data.b $BF,$D0,$4C,$D0,$DF,$B1,$9B,$39
  
  FOLDERID_DocumentsLibrary: ; {7B0DB17D-9CD2-4A93-9733-46CC89022E7C}
  Data.l $7B0DB17D
  Data.w $9CD2,$4A93
  Data.b $97,$33,$46,$CC,$89,$02,$2E,$7C
  
  FOLDERID_MusicLibrary: ; {2112AB0A-C86A-4FFE-A368-0DE96E47012E}
  Data.l $2112AB0A
  Data.w $C86A,$4FFE
  Data.b $A3,$68,$D,$E9,$6E,$47,$1,$2E
  
  FOLDERID_PicturesLibrary: ; {A990AE9F-A03B-4E80-94BC-9912D7504104}
  Data.l $A990AE9F
  Data.w $A03B,$4E80
  Data.b $94,$BC,$99,$12,$D7,$50,$41,$4
  
  FOLDERID_VideosLibrary: ; {491E922F-5643-4AF4-A7EB-4E7A138D8174}
  Data.l $491E922F
  Data.w $5643,$4AF4
  Data.b $A7,$EB,$4E,$7A,$13,$8D,$81,$74
  
  FOLDERID_RecordedTVLibrary: ; {1A6FDBA2-F42D-4358-A798-B74D745926C5}
  Data.l $1A6FDBA2
  Data.w $F42D,$4358
  Data.b $A7,$98,$B7,$4D,$74,$59,$26,$C5
  
  FOLDERID_HomeGroup: ; {52528A6B-B9E3-4ADD-B60D-588C2DBA842D}
  Data.l $52528A6B
  Data.w $B9E3,$4ADD
  Data.b $B6,$D,$58,$8C,$2D,$BA,$84,$2D
  
  FOLDERID_DeviceMetadataStore: ; {5CE4A5E9-E4EB-479D-B89F-130C02886155}
  Data.l $5CE4A5E9
  Data.w $E4EB,$479D
  Data.b $B8,$9F,$13,$0C,$02,$88,$61,$55
  
  FOLDERID_Libraries: ; {1B3EA5DC-B587-4786-B4EF-BD1DC332AEAE}
  Data.l $1B3EA5DC
  Data.w $B587,$4786
  Data.b $B4,$EF,$BD,$1D,$C3,$32,$AE,$AE
  
  FOLDERID_PublicLibraries: ; {48DAF80B-E6CF-4F4E-B800-0E69D84EE384}
  Data.l $48DAF80B
  Data.w $E6CF,$4F4E
  Data.b $B8,$00,$0E,$69,$D8,$4E,$E3,$84
  
  FOLDERID_UserPinned: ; {9E3995AB-1F9C-4F13-B827-48B24B6C7174}
  Data.l $9E3995AB
  Data.w $1F9C,$4F13
  Data.b $B8,$27,$48,$B2,$4B,$6C,$71,$74
  
  FOLDERID_ImplicitAppShortcuts: ; {BCB5256F-79F6-4CEE-B725-DC34E402FD46}
  Data.l $BCB5256F
  Data.w $79F6,$4CEE
  Data.b $B7,$25,$DC,$34,$E4,$2,$FD,$46
EndDataSection
 
; jaPBe Version=3.12.12.878
; Build=0
; Language=0x0000 Language Neutral
; FirstLine=0
; CursorPosition=2
; ExecutableFormat=Windows
; DontSaveDeclare
; EOF