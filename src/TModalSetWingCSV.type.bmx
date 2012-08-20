
Type TModalSetWingCSV Extends TGenericCSVSubroutine

	Function Activate( ed:TEditor, data:TData, sprite:TSprite )
		mode_name = "Wing"
		default_filename = "wing_data.csv"
		row_load_identifier = data.variant.variantId
		csv_identifier_field = "variant"
		stock_data = ed.stock_wing_stats
		stock_data_field_order = ed.stock_wing_stats_field_order
		data_csv_row = data.csv_row_wing
	EndFunction

EndType

