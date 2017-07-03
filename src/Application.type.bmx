
Global STARFARER_CORE_DIR$[] = [ ..
	"starsector-core", ..
	"Contents/Resources/Java", ..
	"" ]

Type Application
	Field window_size#[]
	Field images_dir$
	Field weapon_images_dir$
	Field data_dir$
	Field variant_dir$
	Field weapon_dir$
	Field font_size%
	Field data_font_size%
	Field starsector_base_dir$
	Field hide_vanilla_data%
	Field mod_dirs$[]
	Field fps_limit%
	Field custom_bg_image$
	Field performance_mode%
	Field scale_help_UI%
	Field scale_help_UI_scale_level#
	Field fluxmod_limit_override%
	Field UTF8_support%
	Field custom_FONT$
	Field localization_file$

	Function Load:Application()
		Local settings_json$
		Try
			settings_json = LoadString( "sf-ship-ed-settings.json" )
		Catch ex:TStreamException
			settings_json = LoadString( "incbin::release/sf-ship-ed-settings.json" )
		EndTry
		Local app_obj:Application = Application( json.parse( settings_json, "Application" ) )
		'MARK localization
		DebugLogFile("Loading localization file")
		If app_obj.localization_file.length > 0
			Try
				LOC = LoadLanguage( app_obj.localization_file )
			Catch ex:TStreamException
				DebugLogFile( "Localization file load failed, loading ENG as Default" )
				LOC = LoadLanguage( "incbin::release/ENG.ini" )
			EndTry
		Else
			LOC = LoadLanguage( "incbin::release/ENG.ini" )
		EndIf
		SetLocalizationLanguage(LOC)
		SetLocalizationMode(LOCALIZATION_ON | LOCALIZATION_OVERRIDE)	
		'MARK load core files
		app_obj.get_starfarer_dir()
		If app_obj.images_dir.length = 0 Then app_obj.images_dir = app_obj.starsector_base_dir
		If app_obj.data_dir.length = 0          Then app_obj.data_dir = app_obj.starsector_base_dir
		If app_obj.variant_dir.length = 0       Then app_obj.variant_dir = app_obj.starsector_base_dir
		If app_obj.weapon_images_dir.length = 0 Then app_obj.weapon_images_dir = app_obj.starsector_base_dir
		Return app_obj
	EndFunction
	
	Method Save()
		Local settings_json$ = JSON.stringify( Self )
		SaveString( settings_json, "sf-ship-ed-settings.json" )
	End Method
	
	'///////////
	Method get_starfarer_dir()
		If 0 = FileType( starsector_base_dir + STARFARER_CORE_DIR[0] ) ..
		And 0 = FileType( starsector_base_dir + STARFARER_CORE_DIR[1] ) ..
		And 0 = FileType( starsector_base_dir + STARFARER_CORE_DIR[2] )
?MacOS
			starsector_base_dir = RequestFile(LocalizeString("{{wt_load_core}}") , "app") ) + "/"
?Linux
			starsector_base_dir = RequestDir( LocalizeString("{{wt_load_core}}") ) + "/"
?Win32
			starsector_base_dir = RequestDir( LocalizeString("{{wt_load_core}}") ) + "/"			
?
			If starsector_base_dir = "/" Then starsector_base_dir = ""
			If 0 = FileType( starsector_base_dir + STARFARER_CORE_DIR[0] ) ..
			And 0 = FileType( starsector_base_dir + STARFARER_CORE_DIR[1] ) ..
			And 0 = FileType( starsector_base_dir + STARFARER_CORE_DIR[2] )
				Notify( LocalizeString("{{msg_core_nofound1}}") + " ~n" + starsector_base_dir + "~n~n" + LocalizeString("{{msg_core_nofound2}}") )
			Else
				Save()
			EndIf
		EndIf
	EndMethod

EndType

