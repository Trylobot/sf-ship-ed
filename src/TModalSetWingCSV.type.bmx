
Type TModalSetWingCSV Extends TGenericCSVSubroutine
	
	Field recognized_data_types_wing:TMap
	Field csv_row_column_data_types_wing%[]
	Field f_x%,f_y%
	Field sep%
	Field hide_main_ship%
	'////
	Const COLUMN_FIGHTER_FORMATION% = 5 '(WING) shows the current formation graphically

	Method New()
		mode_name = LocalizeString("{{wt_misc_wing}}")
		default_filename = "wing_data.csv"
		multiselect_prefix = "wing_csv"
		csv_identifier_field = "variant"
		recognized_data_types = CreateMap()
		hide_main_ship = False
		'////
		recognized_data_types.Insert( "id", [COLUMN_STRING] )
		recognized_data_types.Insert( "variant", [COLUMN_STRING] )
		recognized_data_types.Insert( "hyperdrive", [COLUMN_STRING] )
		recognized_data_types.Insert( "number", [COLUMN_STRING] )
		recognized_data_types.Insert( "num", [COLUMN_STRING] ) ' displays formation without clutter
		'////
		recognized_data_types.Insert( "formation", [COLUMN_ENUM] )
		recognized_data_types.Insert( "role", [COLUMN_ENUM] )
		'////////////////////////////////////////
		recognized_data_types_wing = CreateMap()
		recognized_data_types_wing.Insert( "formation", [COLUMN_FIGHTER_FORMATION] )
		recognized_data_types_wing.Insert( "num", [COLUMN_FIGHTER_FORMATION] )
	EndMethod

	Method Activate( ed:TEditor, data:TData, sprite:TSprite )
		Super.Activate( ed, data, sprite )
		'////
		ed.program_mode = "csv_wing"
		row_load_identifier = data.variant.variantId
		stock_stats = ed.stock_wing_stats
		stock_stats_field_order = ed.stock_wing_stats_field_order
		data_csv_row = data.csv_row_wing
		hide_main_ship = False
		DebugLogFile(" Activate Wing CSV Editor")
	EndMethod

	Method Update( ed:TEditor, data:TData, sprite:TSprite )
		Super.Update( ed, data, sprite )
		'////
		If Not loaded_csv_id_list ..
		And csv_row_values ..
		And csv_row_column_data_types_wing ..
		And COLUMN_FIGHTER_FORMATION = csv_row_column_data_types_wing[csv_row_column_i]
			hide_main_ship = True
		Else
			hide_main_ship = False
		EndIf
	EndMethod

	Method Draw( ed:TEditor, data:TData, sprite:TSprite )
		If Not loaded_csv_id_list ..
		And csv_row_values ..
		And csv_row_column_data_types_wing ..
		And COLUMN_FIGHTER_FORMATION = csv_row_column_data_types_wing[csv_row_column_i]
			draw_fighter_formation(  sprite, ..
				String(data_csv_row.ValueForKey("formation")), ..
				String(data_csv_row.ValueForKey("num")).ToInt() )
		EndIf
		'////
		Super.Draw( ed, data, sprite )
	EndMethod

	Method initialize_csv_editor( ed:TEditor, data:TData )
		Super.initialize_csv_editor( ed, data )
		csv_row_column_data_types_wing = New Int[csv_columns_count]
		i = 0 'column iterator
		For line_str = EachIn stock_stats_field_order
			If line_str.StartsWith( TCSVLoader.EXPLICIT_NULL_PREFIX )
				'skip these
				Continue
			EndIf
			If recognized_data_types_wing.Contains( line_str )
				csv_row_column_data_types_wing[i] = (Int[]( recognized_data_types_wing.ValueForKey( line_str )))[0]
			EndIf
			If COLUMN_FIGHTER_FORMATION = csv_row_column_data_types_wing[i]
				'special initialization goes here
			EndIf
			i :+ 1
		Next
	EndMethod

	Method draw_fighter_formation( sprite:TSprite, formation$, num% )
		If Not sprite Or Not sprite.img Or Not formation Or num < 1 Then Return
		SetRotation( 90 )
		SetAlpha( 1 )
		SetColor( 255, 255, 255 )
		SetScale( sprite.scale, sprite.scale )
		Local size% = Max( sprite.img.width, sprite.img.height )
		'positions
		f_x = 3.0*W_MID/4.0 + sprite.pan_x
		f_y = H_MID + sprite.pan_y
		sep = sprite.scale*size
		Select formation
			Case "V"
				If num > 6 Then num = 6
				If num >= 1 Then DrawImage( sprite.img, f_x, f_y )
				If num >= 2 Then DrawImage( sprite.img, f_x-Int(0.75*sep), f_y-sep )
				If num >= 3 Then DrawImage( sprite.img, f_x-Int(0.75*sep), f_y+sep )
				If num >= 4 Then DrawImage( sprite.img, f_x-2*Int(0.75*sep), f_y-2*sep )
				If num >= 5 Then DrawImage( sprite.img, f_x-2*Int(0.75*sep), f_y+2*sep )
				If num >= 6 Then DrawImage( sprite.img, f_x-3*Int(0.75*sep), f_y-3*sep )
			Case "CLAW"
				If num > 6 Then num = 6
				If num >= 1 Then DrawImage( sprite.img, f_x-3*Int(0.75*sep), f_y-Int(0.5*sep) )
				If num >= 2 Then DrawImage( sprite.img, f_x-3*Int(0.75*sep), f_y+Int(0.5*sep) )
				If num >= 3 Then DrawImage( sprite.img, f_x-2.5*Int(0.75*sep), f_y-Int(1.5*sep) )
				If num >= 4 Then DrawImage( sprite.img, f_x-2.5*Int(0.75*sep), f_y+Int(1.5*sep) )
				If num >= 5 Then DrawImage( sprite.img, f_x-Int(0.75*sep), f_y-Int(2.25*sep) )
				If num >= 6 Then DrawImage( sprite.img, f_x-Int(0.75*sep), f_y+Int(2.25*sep) )
			Case "BOX"
				If num > 4 Then num = 4
				If num >= 1 Then DrawImage( sprite.img, f_x, f_y-Int(0.5*sep) )
				If num >= 2 Then DrawImage( sprite.img, f_x, f_y+Int(0.5*sep) )
				If num >= 3 Then DrawImage( sprite.img, f_x-sep, f_y-Int(0.5*sep) )
				If num >= 4 Then DrawImage( sprite.img, f_x-sep, f_y+Int(0.5*sep) )
		EndSelect
		SetScale( 1, 1 )
	EndMethod

EndType

