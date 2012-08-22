
Type TModalSetWingCSV Extends TGenericCSVSubroutine

	'Const COLUMN_STRING% = 0 'free-form string input entry
	'Const COLUMN_ENUM% = 1 'implies multiselect
	'Const COLUMN_STATISTIC% = 2 '(default) implies bar-graph comparison dataset
	''//// specialized
	'Const COLUMN_HULL_ID% = 3 '(SHIP) displays a checkmark if the hull ID is recognized
	'Const COLUMN_SYSTEM_ID% = 4 '(SHIP) displays a reasonable amount of system-related data, if found
	''////
	'Const COLUMN_FIGHTER_FORMATION% = 5 '(WING) shows the current formation graphically

	Function Activate( ed:TEditor, data:TData, sprite:TSprite )
		Super.Activate( ed, data, sprite )
		'////
		mode_name = "Wing"
		default_filename = "wing_data.csv"
		row_load_identifier = data.variant.variantId
		csv_identifier_field = "variant"
		stock_stats = ed.stock_wing_stats
		stock_stats_field_order = ed.stock_wing_stats_field_order
		data_csv_row = data.csv_row_wing
		'////
		recognized_data_types.Insert( "id", [COLUMN_STRING] )
		recognized_data_types.Insert( "variant", [COLUMN_STRING] )
		recognized_data_types.Insert( "formation", [COLUMN_ENUM] )
		recognized_data_types.Insert( "role", [COLUMN_ENUM] )
	EndFunction

EndType

