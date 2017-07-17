
Type TModalSetShipCSV Extends TGenericCSVSubroutine

	Method New()
		mode_name = LocalizeString("{{wt_misc_ship}}")
		default_filename = "ship_data.csv"
		multiselect_prefix = "ship_csv"
		csv_identifier_field = "id"
		recognized_data_types = CreateMap()
		'////
		recognized_data_types.Insert( "name", [COLUMN_STRING] )
		recognized_data_types.Insert( "id", [COLUMN_STRING] )
		recognized_data_types.Insert( "system id", [COLUMN_STRING] )
		recognized_data_types.Insert( "designation", [COLUMN_STRING] )
		recognized_data_types.Insert( "number", [COLUMN_STRING] )
		'////
		recognized_data_types.Insert( "shield type", [COLUMN_ENUM] )
	EndMethod

	Method Activate( ed:TEditor, data:TData, sprite:TSprite )
		Super.Activate( ed, data, sprite )
		'////
		ed.program_mode = "csv"
		row_load_identifier = data.ship.hullId
		stock_stats = ed.stock_ship_stats
		stock_stats_field_order = ed.stock_ship_stats_field_order
		data_csv_row = data.csv_row
    RadioMenuArray( MENU_MODE_SHIPSTATS, modeMenu )
    rebuildFunctionMenu(MENU_MODE_SHIPSTATS)
		DebugLogFile(" Activate Ship CSV Editor")
	EndMethod

EndType

