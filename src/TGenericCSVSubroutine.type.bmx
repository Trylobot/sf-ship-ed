
Type TGenericCSVSubroutine Extends TSubroutine
	Field i%, j%, field_type%
	Field row:TMap
	Field val$
	Field line_str$
	Field widget_str$
	'hooks into global data
	Field mode_name$
	Field default_filename$
	Field multiselect_prefix$
	Field row_load_identifier$
	Field csv_identifier_field$
	Field stock_stats:TMap
	Field stock_stats_field_order:TList
	Field data_csv_row:TMap
	Field recognized_data_types:TMap
	'loading a specific CSV file, and optionally choosing a row from it
	Field loaded_csv_fullpath$
	Field loaded_csv:TMap
	Field loaded_csv_id_list:TextWidget
	Field loaded_csv_id_list_item_i%
'	Field loaded_csv_id_list_item_cursor:TextWidget
	'editing a CSV row's column data
	Field csv_columns_count%
	Field csv_rows_count%
	Field csv_row_fields:TextWidget
	Field csv_row_values:TextWidget
	Field csv_row_column_i%
'	Field csv_row_column_cursor:TextWidget
	Field csv_row_column_data_types%[]
	Field csv_row_column_data_enum_defs$[][]
	Field csv_row_column_data_numeric_datasets#[][]
	Field csv_row_column_data_numeric_datasets_i%[]
	Field console_cursor_i%
	Field modified% 'current field being edited has been modified
	'size considerations
	Field csv_id_list_scale#
	Field csv_data_box_scale#
	'idle
	Field idle_message:TextWidget
	
	'//// generic
	Const COLUMN_STRING% = 0 'free-form string input entry
	Const COLUMN_ENUM% = 1 'implies multiselect
	Const COLUMN_STATISTIC% = 2 '(default) implies bar-graph comparison dataset
	''//// specialized
	'Const COLUMN_HULL_ID% = 3 '(SHIP) displays a checkmark if the hull ID is recognized
	'Const COLUMN_SYSTEM_ID% = 4 '(SHIP) displays a reasonable amount of system-related data, if found

	'testing
	Field Gadget_fields:TGadget[]
	Field Gadget_values:TGadget[]


	'this function should be overridden, but don't forget to call it
	Method Activate( ed:TEditor, data:TData, sprite:TSprite )
	
	EndMethod

	Method Update( ed:TEditor, data:TData, sprite:TSprite )
		If loaded_csv_id_list
			update_csv_row_selector( ed, data )
		ElseIf csv_row_values
			update_csv_editor( data )

		ElseIf data_csv_row And EventSource() = functionMenu[MENU_FUNCTION_DETAILS]

			initialize_csv_editor( ed, data )
			data.hold_snapshot(True)
		EndIf
	EndMethod

	Method Draw( ed:TEditor, data:TData, sprite:TSprite )
		If loaded_csv_id_list
			draw_csv_row_selector()
		ElseIf csv_row_values
			draw_csv_editor()
		Else
			draw_idle()
		EndIf
	EndMethod

	Method Save( ed:TEditor, data:TData, sprite:TSprite )
		'prompt for a location
		SetPointer(POINTER_WAIT)
		Local save_path$ = loaded_csv_fullpath
		If Not save_path Or save_path = "" Then save_path = APP.data_dir+"/"+default_filename
		save_path = RequestFile(LocalizeString("{{wt_save_CSV1}}") + mode_name + LocalizeString("{{wt_save_CSV2}}"), "csv", True, APP.data_dir + "/" + default_filename )
		If save_path
			loaded_csv_fullpath = save_path
			TCSVLoader.Save_Row( loaded_csv_fullpath, data_csv_row, csv_identifier_field, stock_stats_field_order )
		EndIf

		SetPointer(POINTER_DEFAULT)		
		data.changed = False
	EndMethod

	Method Load( ed:TEditor, data:TData, sprite:TSprite )
		loaded_csv_fullpath = RequestFile( LocalizeString("{{wt_load_CSV1}}") + mode_name + LocalizeString("{{wt_load_CSV2}}"), "csv", False, APP.data_dir + "/" + default_filename )
		If FILETYPE_FILE = FileType( loaded_csv_fullpath )
			APP.data_dir = ExtractDir( loaded_csv_fullpath )+"/"
			APP.save()
			Local loaded_csv:TMap = CreateMap()
			TCSVLoader.Load( loaded_csv_fullpath, csv_identifier_field, loaded_csv )
			If loaded_csv
				'if loaded csv data contains a row with the same ID as the loaded ship, use it
				'else prompt the user to choose one
				If loaded_csv.Contains( row_load_identifier )
					data_csv_row = TMap( loaded_csv.ValueForKey( row_load_identifier ))
					data.set_csv_data( data_csv_row, default_filename )
					initialize_csv_editor( ed, data )
				Else 'none found
					initialize_csv_row_chooser()
				EndIf
			EndIf
		EndIf
	EndMethod

	' CSV Editor ------------

	Method initialize_csv_editor( ed:TEditor, data:TData )

		SetPointer(POINTER_WAIT)
		csv_rows_count = count_keys( stock_stats )
		csv_columns_count = stock_stats_field_order.Count()
		csv_row_column_data_types = New Int[csv_columns_count]
		csv_row_column_data_enum_defs = New String[][csv_columns_count]
		csv_row_column_data_numeric_datasets = New Float[][csv_columns_count]
		csv_row_column_data_numeric_datasets_i = New Int[csv_columns_count]
		i = 0 'column iterator
		widget_str = ""
		For line_str = EachIn stock_stats_field_order
			If line_str.StartsWith( TCSVLoader.EXPLICIT_NULL_PREFIX )
				'skip these
				csv_columns_count :- 1
				Continue
			EndIf
			If widget_str <> "" Then widget_str :+ "~n"
			widget_str :+ line_str
			If recognized_data_types.Contains( line_str )
				csv_row_column_data_types[i] = (Int[]( recognized_data_types.ValueForKey( line_str ) ) )[0]
			Else
				csv_row_column_data_types[i] = COLUMN_STATISTIC
			EndIf
			'/////////////////////////
			If COLUMN_STRING = csv_row_column_data_types[i]
				'do nothing further
			'/////////////////////////
			ElseIf COLUMN_ENUM = csv_row_column_data_types[i]
				Local set:TMap = ed.get_multiselect_values( multiselect_prefix + "." + line_str )
				csv_row_column_data_enum_defs[i] = New String[count_keys( set )]
				j = 0 'enum iterator
				For val = EachIn set.Keys()
					csv_row_column_data_enum_defs[i][j] = val
					j :+ 1
				Next
			'/////////////////////////
			ElseIf COLUMN_STATISTIC = csv_row_column_data_types[i]
				csv_row_column_data_numeric_datasets[i] = New Float[csv_rows_count]
				j = 0 'row iterator
				For row = EachIn stock_stats.Values()
					val = String( row.ValueForKey( line_str ))
					If val
						csv_row_column_data_numeric_datasets[i][j] = val.ToFloat()
					EndIf
					j :+ 1
				Next
				csv_row_column_data_numeric_datasets[i].Sort() 'ascending
				For j = 0 Until csv_rows_count
					val = String( data_csv_row.ValueForKey( line_str ))
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
		For line_str = EachIn csv_row_fields.lines
			If widget_str <> "" Then widget_str :+ "~n"
			widget_str :+ String( data_csv_row.ValueForKey( line_str ) )
		Next
		csv_row_values = TextWidget.Create( widget_str )
		'setup cursor
		csv_row_column_i = 0
		'update_csv_row_column_cursor( data )
		'
		SetPointer(POINTER_DEFAULT)
		If csv_row_column_data_types[csv_row_column_i] = COLUMN_STRING Or COLUMN_STATISTIC Then csv_row_values.lines[csv_row_column_i] = CONSOLE.Update( csv_row_values.lines[csv_row_column_i],, console_cursor_i, modified )
		data.hold_snapshot(True)
		'testing
		Rem
		Gadget_fields= New TGadget[csv_columns_count]
		Gadget_values = New TGadget[csv_columns_count]

		CSVEditor = CreateWindow("CSV Editor", 0, 0, csv_row_fields.w + 10 + csv_row_values.w, csv_row_fields.h + csv_row_values.h + 4 * csv_columns_count, MainWindow )
		Local y% = 10, h% = csv_row_fields.h / csv_columns_count
		For Local j% = 0 Until csv_columns_count - 1
			Gadget_fields[j] = CreateLabel(csv_row_fields.lines[j], 10, y , csv_row_fields.w, h + 4, CSVEditor)
			Select csv_row_column_data_types[j]
			Case COLUMN_STRING, COLUMN_STATISTIC
				Gadget_values[j] = CreateTextArea (10 + csv_row_fields.w, y+2, csv_row_values.w, h , CSVEditor)
				SetGadgetText( Gadget_values[j], csv_row_values.lines[j])			
			End Select
			y :+ (h + 4)
		Next
		EndRem
	EndMethod

	Method update_csv_editor( data:TData )
		'up or down/tab/enter to change selected csv row column index
		'if the field is string or numeric, type to input characters
		'if the field is numeric, alpha keys will be blocked
		'if the field is a multiselect, enum values will be displayed; left or right to choose
		Select EventID()
		Case EVENT_KEYDOWN, EVENT_KEYREPEAT
			Select EventData()
			Case KEY_DOWN, KEY_TAB, KEY_ENTER
				csv_row_column_i = Min( csv_row_column_i + 1, csv_row_fields.lines.length - 1 )
				'update_csv_row_column_cursor( data )
				reset_cursor_color_period()
			Case KEY_UP
				csv_row_column_i = Max( csv_row_column_i - 1, 0 )
				'update_csv_row_column_cursor( data )
				reset_cursor_color_period()
			EndSelect
			Select csv_row_column_data_types[csv_row_column_i]
			Case COLUMN_STRING, COLUMN_STATISTIC
				modified = False
				csv_row_values.lines[csv_row_column_i] = CONSOLE.Update( csv_row_values.lines[csv_row_column_i],, console_cursor_i, modified )
				If modified
					csv_row_values.update_size()
					'update_csv_row_column_cursor( data )
					data_csv_row.Insert( csv_row_fields.lines[csv_row_column_i], csv_row_values.lines[csv_row_column_i] )
					If csv_row_column_data_types[csv_row_column_i] = COLUMN_STATISTIC Then update_numeric_dataset( csv_row_column_i, csv_row_values.lines[csv_row_column_i].ToFloat() )
				EndIf
			Case COLUMN_ENUM
				modified = False
				If EventData() = KEY_RIGHT
					For i = 0 Until csv_row_column_data_enum_defs[csv_row_column_i].Length
						If csv_row_column_data_enum_defs[csv_row_column_i][i] = csv_row_values.lines[csv_row_column_i]
							If (i + 1) < csv_row_column_data_enum_defs[csv_row_column_i].Length
								modified = True
								csv_row_values.lines[csv_row_column_i] = csv_row_column_data_enum_defs[csv_row_column_i][i + 1]
								Exit
							EndIf
						EndIf
					Next
				EndIf
				If EventData() = KEY_LEFT
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
					'update_csv_row_column_cursor( data )
					data_csv_row.Insert( csv_row_fields.lines[csv_row_column_i], csv_row_values.lines[csv_row_column_i] )
					reset_cursor_color_period()
				EndIf
			EndSelect			
		Case EVENT_GADGETACTION, EVENT_MENUACTION
			If EventSource() = functionMenu[MENU_FUNCTION_EXIT]
				csv_row_values = Null
				csv_row_column_i = - 1
				data.hold_snapshot(False)
				'update_csv_row_column_cursor( data )
			EndIf
		End Select
	EndMethod

	Method draw_csv_editor()
		'text
		csv_data_box_scale = 1
		If csv_row_fields.h > H_MAX
			csv_data_box_scale = Float(H_MAX) / Float(csv_row_fields.h)
		EndIf
		draw_container( W_MID+10,H_MID, 10+csv_row_fields.w+20+csv_row_values.w+10,10+csv_row_fields.h+10, 0.0,0.5,,,, csv_data_box_scale )
		draw_string( csv_row_fields, W_MID + 10 + 10, H_MID,,, 0.0, 0.5,,, csv_data_box_scale )
		draw_string( csv_row_values, Int( (W_MID + 10 + 10 + 20 + csv_data_box_scale * csv_row_fields.w) ), H_MID,,, 0.0, 0.5,,, csv_data_box_scale )
		
		'draw_string( csv_row_column_cursor, Int( (W_MID + 10 + 10 + 20 + csv_data_box_scale * csv_row_fields.w - csv_data_box_scale * TextWidth(" ") ) ), H_MID, get_cursor_color(), $000000, 0.0, 0.5,,, csv_data_box_scale )
		Select csv_row_column_data_types[csv_row_column_i]
		Case COLUMN_STRING, COLUMN_STATISTIC
			draw_string( "_", ( (W_MID + 10 + 10 + 20 + csv_data_box_scale * csv_row_fields.w) ) + TextWidth(csv_row_values.lines[csv_row_column_i][..console_cursor_i]), H_MID - (csv_row_values.h / 2.0) + (csv_row_column_i + 0.5) * LINE_HEIGHT, get_cursor_color(), $000000, 0.0, 0.5 )
		Case COLUMN_ENUM
			draw_string( "<-", ( (W_MID + 10 + 10 + 20 + csv_data_box_scale * csv_row_fields.w) ) - TextWidth("<-"), H_MID - (csv_row_values.h / 2.0) + (csv_row_column_i + 0.45) * LINE_HEIGHT, get_cursor_color(), $000000, 0.0, 0.5 )	
			draw_string( "->", ( (W_MID + 10 + 10 + 20 + csv_data_box_scale * csv_row_fields.w) ) + TextWidth(csv_row_values.lines[csv_row_column_i]), H_MID - (csv_row_values.h / 2.0) + (csv_row_column_i + 0.45) * LINE_HEIGHT, get_cursor_color(), $000000, 0.0, 0.5 )
		End Select

		'graph
		If COLUMN_STATISTIC = csv_row_column_data_types[csv_row_column_i]
			draw_bar_graph( W_MID, H_MID, Int(W_MID / 1.2), Int(H_MAX / 1.8), 1.0, 0.5, ..
				csv_row_column_data_numeric_datasets[csv_row_column_i], ..
				csv_row_column_data_numeric_datasets_i[csv_row_column_i], 0.333 )
		EndIf
	EndMethod

	Rem
	Method update_csv_row_column_cursor( data:TData )
		If csv_row_values
			Local a$[csv_row_values.lines.length]			
			a[csv_row_column_i] = csv_row_values.lines[csv_row_column_i]
			csv_row_column_cursor = TextWidget.Create(a)
			Select csv_row_column_data_types[csv_row_column_i]
			Case COLUMN_STRING
				csv_row_column_cursor.lines[csv_row_column_i] = " " + RSet( "", csv_row_column_cursor.lines[csv_row_column_i].Length ) + Chr($2502) 'vertical line
			Case COLUMN_STATISTIC
				csv_row_column_cursor.lines[csv_row_column_i] = " " + RSet( "", csv_row_column_cursor.lines[csv_row_column_i].Length ) + Chr($2502) 'vertical line
			Case COLUMN_ENUM
				csv_row_column_cursor.lines[csv_row_column_i] = "<"+ RSet( "", csv_row_column_cursor.lines[csv_row_column_i].Length ) + ">" 'left/right arrows
			EndSelect
'			csv_row_column_cursor = TextWidget.Create( csv_row_values.lines[..] )
'			For i% = 0 Until csv_row_column_cursor.lines.length
'				If i <> csv_row_column_i
'					csv_row_column_cursor.lines[i] = ""
'				Else ' i = csv_row_column_i
'					Select csv_row_column_data_types[csv_row_column_i]
'						Case COLUMN_STRING
'							csv_row_column_cursor.lines[i] = " " + RSet( "", csv_row_column_cursor.lines[i].Length ) + Chr($2502) 'vertical line
'						Case COLUMN_STATISTIC
'							csv_row_column_cursor.lines[i] = " " + RSet( "", csv_row_column_cursor.lines[i].Length ) + Chr($2502) 'vertical line
'						Case COLUMN_ENUM
'							csv_row_column_cursor.lines[i] = Chr($25C2) + RSet( "", csv_row_column_cursor.lines[i].Length ) + Chr($25B8) 'left/right arrows
'					EndSelect
'				EndIf
'			Next
		Else
			csv_row_column_cursor = Null
		EndIf
	EndMethod
	EndRem

	Method update_numeric_dataset( idx%, val# )
		csv_row_column_data_numeric_datasets[idx][csv_row_column_data_numeric_datasets_i[idx]] = val
		csv_row_column_data_numeric_datasets[idx].Sort()
		For j = 0 Until csv_row_column_data_numeric_datasets[idx].length
			If val = csv_row_column_data_numeric_datasets[idx][j]
				csv_row_column_data_numeric_datasets_i[idx] = j
				Exit
			EndIf
		Next
	EndMethod

	' CSV Manual Row-Chooser ------------

	Method initialize_csv_row_chooser()
		widget_str = ""
		For line_str = EachIn loaded_csv.Keys()
			If widget_str <> "" Then widget_str :+ "~n"
			widget_str :+ line_str
		Next
		loaded_csv_id_list = TextWidget.Create( widget_str )
		loaded_csv_id_list_item_i = 0
		'update_csv_row_cursor()
	EndMethod

	Method update_csv_row_selector( ed:TEditor, data:TData )
		'up or down/tab to change selected csv row id
		
		'enter to finalize choice
		Select EventID()
		Case EVENT_KEYDOWN, EVENT_KEYREPEAT
			Select EventData()
			Case KEY_DOWN, KEY_TAB
				loaded_csv_id_list_item_i = Min( loaded_csv_id_list_item_i + 1, loaded_csv_id_list.lines.length - 1 )
				'update_csv_row_cursor()
				reset_cursor_color_period
			Case KEY_UP
				loaded_csv_id_list_item_i = Max( loaded_csv_id_list_item_i - 1, 0 )
				'update_csv_row_cursor()
				reset_cursor_color_period
			Case KEY_ENTER
				'a row has been chosen; load up the csv data editor
				data_csv_row = TMap( loaded_csv.ValueForKey( loaded_csv_id_list.lines[loaded_csv_id_list_item_i] ))
				data.set_csv_data( data_csv_row, default_filename )
				initialize_csv_editor( ed, data )
				'remove csv ID chooser
				loaded_csv_id_list = Null
				loaded_csv_id_list_item_i = -1
				'update_csv_row_cursor()	
			EndSelect
		Case EVENT_GADGETACTION, EVENT_MENUACTION
			If EventSource() = functionMenu[MENU_FUNCTION_EXIT]
				loaded_csv_id_list = Null
				loaded_csv_id_list_item_i = - 1
				data.hold_snapshot(False)
				'update_csv_row_cursor()	
			EndIf
		End Select	
	EndMethod

	Method draw_csv_row_selector()

		
		Local drawY# = SS.ScrollTo( H_MID - ( (loaded_csv_id_list_item_i + 0.5) * LINE_HEIGHT) )
		draw_container( W_MID - TextWidth("=> "), drawY - 10, loaded_csv_id_list.w + 20 + TextWidth("=>  "), loaded_csv_id_list.h + 20, 0.5, 0,,, 0.75 )
		draw_string( loaded_csv_id_list, W_MID, drawY,,, 0.5, 0 )
		'draw_string( loaded_csv_id_list_item_cursor, W_MID,H_MID, get_cursor_color(),, 0.5,0.5 )
		draw_string( "=> ", W_MID - TextWidth("=> ") - loaded_csv_id_list.w / 2, H_MID, get_cursor_color(),, 0.5, 0.5 )
		SetAlpha( 0.2 )	
		DrawRect( W_MID - 20 - TextWidth("=>  ") - 0.5 * ( loaded_csv_id_list.w ), H_MID - LINE_HEIGHT / 2 , loaded_csv_id_list.w + 20 + TextWidth("=>  "), LINE_HEIGHT )												
		SetAlpha( 1 )
	EndMethod



	Rem
	Method update_csv_row_cursor()
		If loaded_csv_id_list
			Local a$[loaded_csv_id_list.lines.length]
			a[loaded_csv_id_list_item_i] = loaded_csv_id_list.lines[loaded_csv_id_list_item_i]
			loaded_csv_id_list_item_cursor = TextWidget.Create(a)
		Else
			loaded_csv_id_list_item_cursor = Null
		EndIf
	EndMethod
	EndRem

	' Idle message ------------

	Method draw_idle()
		If Not idle_message
			idle_message = TextWidget.Create( LocalizeString("{{ui_function_CSV_idle}}"))
		EndIf
		draw_container( W_MID,H_MID, idle_message.w+20,idle_message.h+20, 0.5,0.5 )
		draw_string( idle_message, W_MID,H_MID,,, 0.5,0.5 )
	EndMethod

EndType

