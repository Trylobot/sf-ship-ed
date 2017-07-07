
Type TModalSetBuiltInWings Extends TSubroutine
	'Field i%
	'Field w%,h%
	'Field display_str$
	'Field fg_color%
	'Field op_str$
	'Field op_widget:TextWidget
	''///
	'Field selected_hullMod:TMap
	Field wings_count%
	'Field hullMod:TMap
	'Field hullMods:TMap[]
	'Field hullMods_lines$[]
	'Field hullMods_c$[]
	'Field hullmod_id$ 
	'Field hullmod_op% 
	'Field hullmod_head_str$
	'Field hullMods_widget:TextWidget
	'Field hullMods_cursor:TextWidget

	Method Activate( ed:TEditor, data:TData, sprite:TSprite )
		ed.last_mode = ed.mode
		ed.mode = "built_in_wings"
		wings_count = count_keys( ed.stock_wing_stats )
		'ed.builtIn_hullMod_i = 0
		'initialize_hullmods_list( ed, data )
		'DebugLogFile(" Activate Built-In Hullmods Editor")
		'SS.reset()
		
	EndMethod

	Method Update( ed:TEditor, data:TData, sprite:TSprite )
		'update_hullmods_list( ed, data )
	End Method

	Method Draw( ed:TEditor, data:TData, sprite:TSprite )
		'draw_hud( ed, data )
		'draw_hullmods_list()
		'SetAlpha( 1 )
	EndMethod


	Method Save( ed:TEditor, data:TData, sprite:TSprite )
	EndMethod

	Method Load( ed:TEditor, data:TData, sprite:TSprite )
	EndMethod

'	'/////////////////////

'	Function get_hullmod_csv_ordnance_points%( ed:TEditor, data:TData, hullMod_id$ )
'		'uses ship size and hullmod data
'		Local hullMod_stats:TMap = TMap( ed.stock_hullmod_stats.ValueForKey( hullMod_id ))
'		If Not hullMod_stats Then Return 0 'ID not found in csv data
'		Local column_key$ = ""
'		Select data.ship.hullSize
'			Case "FRIGATE"
'				column_key = "cost_frigate"
'			Case "DESTROYER"
'				column_key = "cost_dest"
'			Case "CRUISER"
'				column_key = "cost_cruiser"
'			Case "CAPITAL_SHIP"
'				column_key = "cost_capital"
'			Default
'				Return 0 'hullMod cost cannot be found
'		EndSelect
'		Local value$ = String( hullMod_stats.ValueForKey( column_key ))
'		If Not value Then Return 0 'csv row found, but did not contain column
'		Return value.ToInt()
'	EndFunction

'	'/////////////////////

'	Method initialize_hullmods_list( ed:TEditor, data:TData )
'		hullMods = New TMap[hullMods_count]
'		i = 0
'		For hullMod = EachIn ed.stock_hullmod_stats.Values()
'			hullMods[i] = hullMod
'			If i = ed.builtIn_hullMod_i
'				selected_hullMod = hullMod
'			EndIf
'			i :+ 1
'		Next
'		'////
'		'show hullmods list and cursor
'		hullMods_lines = New String[hullMods_count]
''		hullMods_c = New String[hullMods_count]
'		i = 0
'		For hullMod = EachIn ed.stock_hullmod_stats.Values()
'			hullmod_id = String( hullMod.ValueForKey("id") )
'			display_str = String( hullMod.ValueForKey("name") )
'			hullmod_op = get_hullmod_csv_ordnance_points( ed, data, hullmod_id )

'			display_str = RSet( String.FromInt( hullmod_op ), 3 )+"  "+LSet( display_str, 28 )
'			hullmod_head_str = RSet( "    OP", 6 )+"  "+LSet( "Name", 28 )
'			If SHOW_MORE = 1
'				display_str = display_str +"  "+ LSet( String( hullMod.ValueForKey( "short" )), 65).Replace("~q","")
'				hullmod_head_str = hullmod_head_str +"  "+ LSet( "Description", 65).Replace("~q","")
'			EndIf
'			If SHOW_MORE = 2
'				display_str = display_str +"  "+ LSet( String( hullMod.ValueForKey( "desc" )), 160).Replace("~q","")
'				hullmod_head_str = hullmod_head_str +"  "+ LSet( "Description", 160).Replace("~q","")
'			EndIf

'			If data.has_builtin_hullmod( hullmod_id )
'				display_str = "[b]" + display_str
'			Else
'				display_str = "[ ]" + display_str
'			EndIf
'			hullMods_lines[i] = display_str
''			If i = ed.builtIn_hullMod_i
''				hullMods_c[i] = display_str
''			EndIf
'			i :+ 1
'		Next
'		hullMods_widget = TextWidget.Create( hullMods_lines )
'		'hullMods_cursor = TextWidget.Create( hullMods_c )
'		'hullMods_cursor.w = hullMods_widget.w
'	EndMethod

'	Method update_hullmods_list( ed:TEditor, data:TData )
'		initialize_hullmods_list( ed, data )
'		'bounds enforce (extra check, wrap top/bottom)
'		If ed.builtIn_hullMod_i > (hullMods_count - 1)
'			ed.builtIn_hullMod_i = 0
'		ElseIf ed.select_weapon_i < 0
'			ed.builtIn_hullMod_i = (hullMods_count - 1)
'		EndIf
'		'process input
'		Select EventID()
'		Case EVENT_KEYDOWN, EVENT_KEYREPEAT	
'			Select EventData()
'			Case KEY_ENTER
'				'add/remove hullmod
'				data.toggle_builtin_hullmod( String( selected_hullMod.ValueForKey("id")) )
'				data.update()
'				SS.reset()
'			Case KEY_DOWN 
'				ed.builtIn_hullMod_i :+ 1
'			Case KEY_UP
'				ed.builtIn_hullMod_i :- 1
'			Case KEY_PAGEDOWN 
'				ed.builtIn_hullMod_i :+ 5
'			Case KEY_PAGEUP 
'				ed.builtIn_hullMod_i :- 5	
'			EndSelect
'		Case EVENT_GADGETACTION, EVENT_MENUACTION
'			Select EventSource()
'			Case functionMenu[5]
'				ed.builtIn_hullMod_i = - 1
'			EndSelect
'		End Select
'		'bounds enforce (wrap top/bottom)
'		If ed.builtIn_hullMod_i > (hullMods_count - 1)
'			ed.builtIn_hullMod_i = 0
'		ElseIf ed.builtIn_hullMod_i < 0
'			ed.builtIn_hullMod_i = (hullMods_count - 1)
'		EndIf
'	EndMethod

'	Method draw_hud( ed:TEditor, data:TData )
'		fg_color = $FFFFFF
'		op_str = LocalizeString("{{ui_function_builtInHullmods_opstr}}") + "  "+ data.ship.builtInMods.length + "x"
'		op_widget = TextWidget.Create( op_str )
'		draw_container( 7, LINE_HEIGHT * 3, op_widget.w + 20, op_widget.h + 20, 0.0, 0.5 )
'		draw_string( op_widget, 10+7, LINE_HEIGHT * 3, fg_color, $000000, 0.0, 0.5 )
'	EndMethod

'	Method draw_hullmods_list()

'		Local drawY# = SS.ScrollTo(H_MID  - ( ed.builtIn_hullMod_i + 0.5) * LINE_HEIGHT)
'		draw_container( W_MID - 40 - TextWidth("=> "), drawY - 30, hullMods_widget.w + 20 + TextWidth("=> "), hullMods_widget.h + 40, 0.5, 0,,, 0.75 )
'		draw_string( hullmod_head_str, W_MID - 40 + 10 - TextWidth("=> "), drawY - 20,,, 0.5, 0 )
'		draw_string( hullMods_widget, W_MID - 40 + 10 - TextWidth("=> "), drawY ,,, 0.5, 0 )
'		draw_string( "=> ", W_MID - 40 - TextWidth("=> ") - hullMods_widget.w / 2, H_MID, get_cursor_color(),, 0.5, 0.5 )
'		SetColor(255, 255, 255)
'		SetAlpha( 0.2 )	
'		DrawRect( W_MID - 40 - 20 - TextWidth("=> ") - 0.5 * ( hullMods_widget.w ), H_MID - LINE_HEIGHT / 2 , hullMods_widget.w + 20 + TextWidth("=> "), LINE_HEIGHT )												

'		SetAlpha( 1 )
'	EndMethod

EndType
