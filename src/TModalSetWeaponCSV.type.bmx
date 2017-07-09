Type TModalSetWeaponCSV Extends TGenericCSVSubroutine

	Method New()
		mode_name = LocalizeString("{{wt_misc_weapon}}")
		default_filename = "weapon_data.csv"
		multiselect_prefix = "weapon_csv"
		csv_identifier_field = "id"
		recognized_data_types = CreateMap()
		'////
		recognized_data_types.Insert( "name", [COLUMN_STRING] )
		recognized_data_types.Insert( "id", [COLUMN_STRING] )
		recognized_data_types.Insert( "type", [COLUMN_ENUM] )
		recognized_data_types.Insert( "number", [COLUMN_STRING] )
		'////
	EndMethod

	Method Activate( ed:TEditor, data:TData, sprite:TSprite )
		Super.Activate( ed, data, sprite )
		'////
		ed.program_mode = "csv_weapon"
		row_load_identifier = data.weapon.id
		stock_stats = ed.stock_weapon_stats
		stock_stats_field_order = ed.stock_weapon_stats_field_order
		data_csv_row = data.csv_row_weapon
    RadioMenuArray( MENU_MODE_WEAPONSTATS, modeMenu )
    rebuildFunctionMenu(MENU_MODE_WEAPONSTATS)
		DebugLogFile(" Activate Weapon CSV Editor")
	EndMethod

EndType

