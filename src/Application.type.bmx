
Global STARFARER_CORE_DIR$[] = [ ..
	"starsector-core", ..
	"Contents/Resources/Java", ..
	"" ]

Type Application
	Field width%
	Field height%
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

	Function Load:Application()
		Local settings_json$
		Try
			settings_json = LoadString( "sf-ship-ed-settings.json" )
		Catch ex:TStreamException
			settings_json = LoadString( "incbin::release/sf-ship-ed-settings.json" )
		EndTry
		Local app_obj:Application = Application( json.parse( settings_json, "Application" ))
		app_obj.get_starfarer_dir()
		If app_obj.images_dir.length = 0        Then app_obj.images_dir = app_obj.starsector_base_dir
		If app_obj.data_dir.length = 0          Then app_obj.data_dir = app_obj.starsector_base_dir
		If app_obj.variant_dir.length = 0       Then app_obj.variant_dir = app_obj.starsector_base_dir
		If app_obj.weapon_images_dir.length = 0 Then app_obj.weapon_images_dir = app_obj.starsector_base_dir
		Return app_obj
	EndFunction
	
	Method Save()
		Local settings_json$ = json.stringify( self )
		SaveString( settings_json, "sf-ship-ed-settings.json" )
	End Method
	
	'///////////
	Method get_starfarer_dir()
		If  0 = FileType( starsector_base_dir+STARFARER_CORE_DIR[0] ) ..
		And 0 = FileType( starsector_base_dir+STARFARER_CORE_DIR[1] ) ..
		And 0 = FileType( starsector_base_dir+STARFARER_CORE_DIR[2] )
			starsector_base_dir = RequestDir( "Starfarer Install Directory" )+"/"
			FlushKeys()
			If  0 = FileType( starsector_base_dir+STARFARER_CORE_DIR[0] ) ..
			And 0 = FileType( starsector_base_dir+STARFARER_CORE_DIR[1] ) ..
			And 0 = FileType( starsector_base_dir+STARFARER_CORE_DIR[2] )
				Notify( "Starfarer does not appear to be found at ~n"+starsector_base_dir+"~n~nHowever, the program will continue anyway as best it can." )
			Else
				Save()
			EndIf
		EndIf
	EndMethod

EndType

