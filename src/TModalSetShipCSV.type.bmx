
Type TModalSetShipCSV Extends TSubroutine
	Global i%, j%
	Global row:TMap
	Global val$
	Global line_str$
	Global widget_str$
	'loading a specific CSV file, and optionally choosing a row from it
	Global loaded_csv_fullpath$
	Global loaded_csv:TMap
	Global loaded_csv_id_list:TextWidget
	Global loaded_csv_id_list_item_i%
	Global loaded_csv_id_list_item_cursor:TextWidget
	'editing a CSV row's column data
	Global csv_columns_count%
	Global csv_rows_count%
	Global csv_row_fields:TextWidget
	Global csv_row_values:TextWidget
	Global csv_row_column_i%
	Global csv_row_column_cursor:TextWidget
	Global csv_row_column_data_types%[]
	Global COLUMN_STRING% = 0 'default; free-form string input entry
	Global COLUMN_ENUM% = 1 'implies multiselect
	Global COLUMN_STATISTIC% = 2 'implies graphical dataset
	Global csv_row_column_data_enum_defs$[][]
	Global csv_row_column_data_numeric_datasets#[][]
	Global csv_row_column_data_numeric_datasets_i%[]
	Global modified% 'current field being edited has been modified
	'idle
	Global idle_message:TextWidget

	Function Activate( ed:TEditor, data:TData, sprite:TSprite )
	EndFunction

	Function Update( ed:TEditor, data:TData, sprite:TSprite )
		If loaded_csv_id_list
			update_csv_row_selector( ed, data )
		ElseIf csv_row_values
			update_csv_editor( data )
		Else
			If KeyHit( KEY_T ) And data.csv_row
				initialize_csv_editor( ed, data )
			EndIf
		EndIf
	EndFunction

	Function Draw( ed:TEditor, data:TData, sprite:TSprite )
		If loaded_csv_id_list
			draw_csv_row_selector()
		ElseIf csv_row_values
			draw_csv_editor()
		Else
			draw_idle()
		EndIf
	EndFunction

	Function Save( ed:TEditor, data:TData, sprite:TSprite )
		'prompt for a location
		Local save_path$ = loaded_csv_fullpath
		If Not save_path Or save_path = "" Then save_path = APP.data_dir+"/ship_data.csv"
		save_path = RequestFile( "SAVE Ship CSV (current row)", "csv", True, APP.data_dir+"/ship_data.csv" )
		FlushKeys()
		If save_path
			loaded_csv_fullpath = save_path
			TCSVLoader.Save_Row( loaded_csv_fullpath, data.csv_row, "id", ed.stock_ship_stats_field_order )
		EndIf
	EndFunction

	Function Load( ed:TEditor, data:TData, sprite:TSprite )
		loaded_csv_fullpath = RequestFile( "LOAD Ship CSV", "csv", False, APP.data_dir+"/ship_data.csv" )
		FlushKeys()
		If FILETYPE_FILE = FileType( loaded_csv_fullpath )
			APP.data_dir = ExtractDir( loaded_csv_fullpath )+"/"
			APP.save()
			loaded_csv = TCSVLoader.Load( loaded_csv_fullpath, "id" )
			'if loaded csv data contains a row with the same ID as the loaded ship, use it
			'else prompt the user to choose one
			If loaded_csv.Contains( data.ship.hullId )
				data.csv_row = TMap( loaded_csv.ValueForKey( data.ship.hullId ))
				initialize_csv_editor( ed, data )
			Else 'none found
				initialize_csv_row_chooser()
			EndIf
		EndIf
	EndFunction

	' CSV Editor ------------

	Function initialize_csv_editor( ed:TEditor, data:TData )
		FlushKeys()
		csv_rows_count = count_keys( ed.stock_ship_stats )
		csv_columns_count = ed.stock_ship_stats_field_order.Count()
		csv_row_column_data_types = New Int[csv_columns_count]
		csv_row_column_data_enum_defs = New String[][csv_columns_count]
		csv_row_column_data_numeric_datasets = New Float[][csv_columns_count]
		csv_row_column_data_numeric_datasets_i = New Int[csv_columns_count]
		i = 0 'column iterator
		widget_str = ""
		For line_str = EachIn ed.stock_ship_stats_field_order
			If widget_str <> "" Then widget_str :+ "~n"
			widget_str :+ line_str
			'special fields
			If line_str = "name" ..
			Or line_str = "id" ..
			Or line_str = "system id" ..
			Or line_str = "designation" ..
			Or line_str = "8/6/5/4%" ..
			Or line_str = "number"
				csv_row_column_data_types[i] = COLUMN_STRING
				'do nothing further
			ElseIf line_str = "shield type"
				csv_row_column_data_types[i] = COLUMN_ENUM
				Local set:TMap = ed.get_multiselect_values( "ship_csv."+line_str )
				csv_row_column_data_enum_defs[i] = New String[count_keys( set )]
				j = 0 'enum iterator
				For val = EachIn set.Keys()
					csv_row_column_data_enum_defs[i][j] = val
					j :+ 1
				Next
			Else 'default; most fields are this
				csv_row_column_data_types[i] = COLUMN_STATISTIC
				csv_row_column_data_numeric_datasets[i] = New Float[csv_rows_count]
				j = 0 'row iterator
				For row = EachIn ed.stock_ship_stats.Values()
					val = String( row.ValueForKey( line_str ))
					If val
						csv_row_column_data_numeric_datasets[i][j] = val.ToFloat()
					EndIf
					j :+ 1
				Next
				csv_row_column_data_numeric_datasets[i].Sort() 'ascending
				For j = 0 Until csv_rows_count
					val = String( data.csv_row.ValueForKey( line_str ))
					If val
						If val.ToFloat() = csv_row_column_data_numeric_datasets[i][j]
							csv_row_column_data_numeric_datasets_i[i] = j
						EndIf
					EndIf
				Next
			EndIf
			i :+ 1
		Next
		csv_row_fields = TextWidget.Create( widget_str )
		widget_str = ""
		For line_str = EachIn ed.stock_ship_stats_field_order
			If widget_str <> "" Then widget_str :+ "~n"
			widget_str :+ String( data.csv_row.ValueForKey( line_str ))
		Next
		csv_row_values = TextWidget.Create( widget_str )
		'setup cursor
		csv_row_column_i = 0
		update_csv_row_column_cursor( data )
	EndFunction

	Function update_csv_editor( data:TData )
		'up or down/tab/enter to change selected csv row column index
		'if the field is string or numeric, type to input characters
		'if the field is numeric, alpha keys will be blocked
		'if the field is a multiselect, enum values will be displayed; left or right to choose
		If KeyHit( KEY_DOWN ) Or KeyHIT( KEY_TAB ) Or KeyHit( KEY_ENTER )
			FlushKeys()
			csv_row_column_i = Min( csv_row_column_i + 1, csv_row_fields.lines.length - 1 )
			update_csv_row_column_cursor( data )
			reset_cursor_color_period()
		EndIf
		If KEYHIT( KEY_UP )
			FlushKeys()
			csv_row_column_i = Max( csv_row_column_i - 1, 0 )
			update_csv_row_column_cursor( data )
			reset_cursor_color_period()
		EndIf
		Select csv_row_column_data_types[csv_row_column_i]
			Case COLUMN_STRING
				modified = False
				csv_row_values.lines[csv_row_column_i] = CONSOLE.Update( csv_row_values.lines[csv_row_column_i],, modified )
				If modified
					csv_row_values.update_size()
					update_csv_row_column_cursor( data )
					data.csv_row.Insert( csv_row_fields.lines[csv_row_column_i], csv_row_values.lines[csv_row_column_i] )
				EndIf
			Case COLUMN_ENUM
				modified = False
				If KeyHit( KEY_RIGHT )
					For i = 0 Until csv_row_column_data_enum_defs[csv_row_column_i].length
						If csv_row_column_data_enum_defs[csv_row_column_i][i] = csv_row_values.lines[csv_row_column_i]
							If (i + 1) < csv_row_column_data_enum_defs[csv_row_column_i].length
								modified = True
								csv_row_values.lines[csv_row_column_i] = csv_row_column_data_enum_defs[csv_row_column_i][i + 1]
								Exit
							EndIf
						EndIf
					Next
				EndIf
				If KeyHit( KEY_LEFT )
					For i = 0 Until csv_row_column_data_enum_defs[csv_row_column_i].length
						If csv_row_column_data_enum_defs[csv_row_column_i][i] = csv_row_values.lines[csv_row_column_i]
							If (i - 1) >= 0
								modified = True
								csv_row_values.lines[csv_row_column_i] = csv_row_column_data_enum_defs[csv_row_column_i][i - 1]
								Exit
							EndIf
						EndIf
					Next
				EndIf
				If modified
					update_csv_row_column_cursor( data )
					data.csv_row.Insert( csv_row_fields.lines[csv_row_column_i], csv_row_values.lines[csv_row_column_i] )
					reset_cursor_color_period()
				EndIf
			Case COLUMN_STATISTIC
				modified = False
				csv_row_values.lines[csv_row_column_i] = CONSOLE.Update( csv_row_values.lines[csv_row_column_i],, modified )
				If modified
					csv_row_values.update_size()
					update_csv_row_column_cursor( data )
					data.csv_row.Insert( csv_row_fields.lines[csv_row_column_i], csv_row_values.lines[csv_row_column_i] )
					update_numeric_dataset( csv_row_column_i, csv_row_values.lines[csv_row_column_i].ToFloat() )
				EndIf
		EndSelect
		If KeyHit( KEY_ESCAPE )
			csv_row_values = Null
			csv_row_column_i = -1
			update_csv_row_column_cursor( data )
		EndIf
	EndFunction

	Function draw_csv_editor()
		'text
		draw_container( W_MID+10,H_MID, 10+csv_row_fields.w+20+csv_row_values.w+10,10+csv_row_fields.h+10, 0.0,0.5 )
		draw_string( csv_row_fields, W_MID+10+10,H_MID,,, 0.0,0.5 )
		draw_string( csv_row_values, W_MID+10+10+20+csv_row_fields.w,H_MID,,, 0.0,0.5)
		draw_string( csv_row_column_cursor, W_MID+10+10+20+csv_row_fields.w-TextWidth(" "),H_MID,get_cursor_color(),$000000, 0.0,0.5 )
		'graph
		If COLUMN_STATISTIC = csv_row_column_data_types[csv_row_column_i]
			draw_bar_graph( W_MID,H_MID, Int(W_MID/1.2),Int(H_MAX/1.8), 1.0,0.5, ..
				csv_row_column_data_numeric_datasets[csv_row_column_i], ..
				csv_row_column_data_numeric_datasets_i[csv_row_column_i], 0.333 )
		EndIf
	EndFunction

	Function update_csv_row_column_cursor( data:TData )
		If csv_row_values
			csv_row_column_cursor = TextWidget.Create( csv_row_values.lines[..] )
			For i% = 0 Until csv_row_column_cursor.lines.length
				If i <> csv_row_column_i
					csv_row_column_cursor.lines[i] = ""
				Else ' i = csv_row_column_i
					Select csv_row_column_data_types[csv_row_column_i]
						Case COLUMN_STRING
							csv_row_column_cursor.lines[i] = " " + RSet( "", csv_row_column_cursor.lines[i].length ) + Chr($2502) 'vertical line
						Case COLUMN_STATISTIC
							csv_row_column_cursor.lines[i] = " " + RSet( "", csv_row_column_cursor.lines[i].length ) + Chr($2502) 'vertical line
						Case COLUMN_ENUM
							csv_row_column_cursor.lines[i] = Chr($25C2) + RSet( "", csv_row_column_cursor.lines[i].length ) + Chr($25B8) 'left/right arrows
					EndSelect
				EndIf
			Next
		Else
			csv_row_column_cursor = Null
		EndIf
	EndFunction

	Function update_numeric_dataset( idx%, val# )
		csv_row_column_data_numeric_datasets[idx][csv_row_column_data_numeric_datasets_i[idx]] = val
		csv_row_column_data_numeric_datasets[idx].Sort()
		For j = 0 Until csv_row_column_data_numeric_datasets[idx].length
			If val = csv_row_column_data_numeric_datasets[idx][j]
				csv_row_column_data_numeric_datasets_i[idx] = j
				Exit
			EndIf
		Next
	EndFunction

	' CSV Manual Row-Chooser ------------

	Function initialize_csv_row_chooser()
		widget_str = ""
		For line_str = EachIn loaded_csv.Keys()
			If widget_str <> "" Then widget_str :+ "~n"
			widget_str :+ line_str
		Next
		loaded_csv_id_list = TextWidget.Create( widget_str )
		loaded_csv_id_list_item_i = 0
		update_csv_row_cursor()
	EndFunction

	Function update_csv_row_selector( ed:TEditor, data:TData )
		'up or down/tab to change selected csv row id
		'enter to finalize choice
		If KeyHit( KEY_DOWN ) Or KeyHIT( KEY_TAB )
			loaded_csv_id_list_item_i = Min( loaded_csv_id_list_item_i + 1, loaded_csv_id_list.lines.length - 1 )
			update_csv_row_cursor()
			reset_cursor_color_period
		ENDIF
		IF KEYHIT( KEY_UP )
			loaded_csv_id_list_item_i = Max( loaded_csv_id_list_item_i - 1, 0 )
			update_csv_row_cursor()
			reset_cursor_color_period
		ENDIF
		If KeyHit( KEY_ENTER )
			'a row has been chosen; load up the csv data editor
			data.csv_row = TMap( loaded_csv.ValueForKey( loaded_csv_id_list.lines[loaded_csv_id_list_item_i] ))
			initialize_csv_editor( ed, data )
			'remove csv ID chooser
			loaded_csv_id_list = Null
			loaded_csv_id_list_item_i = -1
			update_csv_row_cursor()
		EndIf
	EndFunction

	Function draw_csv_row_selector()
		draw_container( W_MID,H_MID, loaded_csv_id_list.w+20,loaded_csv_id_list.h+20, 0.5,0.5 )
		draw_string( loaded_csv_id_list, W_MID,H_MID,,, 0.5,0.5 )
		draw_string( loaded_csv_id_list_item_cursor, W_MID,H_MID,get_cursor_color(),$000000, 0.5,0.5 )
	EndFunction

	Function update_csv_row_cursor()
		If loaded_csv_id_list
			loaded_csv_id_list_item_cursor = TextWidget.Create( loaded_csv_id_list.lines[..] )
			For i% = 0 Until loaded_csv_id_list_item_cursor.lines.length
				If i <> loaded_csv_id_list_item_i Then loaded_csv_id_list_item_cursor.lines[i] = ""
			Next
		Else
			loaded_csv_id_list_item_cursor = Null
		EndIf
	EndFunction

	' Idle message ------------

	Function draw_idle()
		If Not idle_message
			idle_message = TextWidget.Create( "Press T to edit CSV data" )
		EndIf
		draw_container( W_MID,H_MID, idle_message.w+20,idle_message.h+20, 0.5,0.5 )
		draw_string( idle_message, W_MID,H_MID,,, 0.5,0.5 )
	EndFunction

EndType

