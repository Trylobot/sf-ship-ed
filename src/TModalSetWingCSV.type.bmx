
Type TModalSetWingCSV Extends TGenericCSVSubroutine
	
	Global recognized_data_types_wing:TMap
	Global csv_row_column_data_types_wing%[]
	'////
	Const COLUMN_FIGHTER_FORMATION% = 5 '(WING) shows the current formation graphically

	Function Activate( ed:TEditor, data:TData, sprite:TSprite )
		Super.Activate( ed, data, sprite )
		'////
		mode_name = "Wing"
		default_filename = "wing_data.csv"
		multiselect_prefix = "wing_csv"
		row_load_identifier = data.variant.variantId
		csv_identifier_field = "variant"
		stock_stats = ed.stock_wing_stats
		stock_stats_field_order = ed.stock_wing_stats_field_order
		data_csv_row = data.csv_row_wing
		'////
		recognized_data_types.Insert( "id", [COLUMN_STRING] )
		recognized_data_types.Insert( "variant", [COLUMN_STRING] )
		recognized_data_types.Insert( "hyperdrive", [COLUMN_STRING] )
		recognized_data_types.Insert( "number", [COLUMN_STRING] )
		'////
		recognized_data_types.Insert( "formation", [COLUMN_ENUM] )
		recognized_data_types.Insert( "role", [COLUMN_ENUM] )
		'////////////////////////////////////////
		recognized_data_types_wing = CreateMap()
		recognized_data_types_wing.Insert( "formation", [COLUMN_FIGHTER_FORMATION] )
		recognized_data_types_wing.Insert( "num", [COLUMN_FIGHTER_FORMATION] )
		'////
		csv_row_column_data_types_wing = New Int[csv_columns_count]
	EndFunction

	Function initialize_csv_editor( ed:TEditor, data:TData )
		Super.initialize_csv_editor( ed, data )
		i = 0 'column iterator
		For line_str = EachIn stock_stats_field_order
			If recognized_data_types_wing.Contains( line_str )
				csv_row_column_data_types_wing[i] = (Int[]( recognized_data_types_wing.ValueForKey( line_str )))[0]
			EndIf
			If COLUMN_FIGHTER_FORMATION = csv_row_column_data_types_wing[i]
				'special initialization goes here
			EndIf
			i :+ 1
		Next
	EndFunction

	Function Draw( ed:TEditor, data:TData, sprite:TSprite )
		Super.Draw( ed, data, sprite )
		If Not loaded_csv_id_list And csv_row_values
			If csv_row_column_data_types_wing
				If COLUMN_FIGHTER_FORMATION = csv_row_column_data_types_wing[csv_row_column_i]
					draw_fighter_formation( ..
						sprite.img, ..
						String(data_csv_row.ValueForKey("formation")), ..
						String(data_csv_row.ValueForKey("num")).ToInt() )
				EndIf
			EndIf
		EndIf
	EndFunction

	Function draw_fighter_formation( img:TImage, formation$, num% )
		If Not img Or Not formation Or num <= 0 Then Return
		'background

		If num > 6
		Else
			Select formation
				Case "V"
					'If num >= 1 Then 
				Case "CLAW"

				Case "BOX"

			EndSelect
		EndIf
	EndFunction

EndType

