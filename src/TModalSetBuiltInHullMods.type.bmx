
Type TModalSetBuiltInHullMods Extends TSubroutine
	Field i%
	Field w%,h%
	Field display_str$
	Field fg_color%
	Field op_str$
	Field op_widget:TextWidget
	'///
	Field selected_hullMod:TMap
	Field hullMods_count%
	Field hullMod:TMap
	Field hullMods:TMap[]
	Field hullMods_lines$[]
	Field hullMods_c$[]
	Field hullmod_id$ 
	Field hullmod_op% 
	Field hullMods_widget:TextWidget
	Field hullMods_cursor:TextWidget

	Method Activate( ed:TEditor, data:TData, sprite:TSprite )
		ed.last_mode = ed.mode
		ed.mode = "built_in_hullmods"
		'enter HULLMODS mode
		hullMods_count = count_keys( ed.stock_hullmod_stats )
		ed.builtIn_hullMod_i = 0
		initialize_hullmods_list( ed, data )
	EndMethod

	Method Update( ed:TEditor, data:TData, sprite:TSprite )
		update_hullmods_list( ed, data )
	End Method

	Method Draw( ed:TEditor, data:TData, sprite:TSprite ) 
		draw_hud( ed, data )
		draw_hullmods_list()
		SetAlpha( 1 )
	EndMethod


	Method Save( ed:TEditor, data:TData, sprite:TSprite )
	EndMethod

	Method Load( ed:TEditor, data:TData, sprite:TSprite )
	EndMethod

	'/////////////////////

	Function get_hullmod_csv_ordnance_points%( ed:TEditor, data:TData, hullMod_id$ )
		'uses ship size and hullmod data
		Local hullMod_stats:TMap = TMap( ed.stock_hullmod_stats.ValueForKey( hullMod_id ))
		If Not hullMod_stats Then Return 0 'ID not found in csv data
		Local column_key$ = ""
		Select data.ship.hullSize
			Case "FRIGATE"
				column_key = "cost_frigate"
			Case "DESTROYER"
				column_key = "cost_dest"
			Case "CRUISER"
				column_key = "cost_cruiser"
			Case "CAPITAL_SHIP"
				column_key = "cost_capital"
			Default
				Return 0 'hullMod cost cannot be found
		EndSelect
		Local value$ = String( hullMod_stats.ValueForKey( column_key ))
		If Not value Then Return 0 'csv row found, but did not contain column
		Return value.ToInt()
	EndFunction

	'/////////////////////

	Method initialize_hullmods_list( ed:TEditor, data:TData )
		hullMods = New TMap[hullMods_count]
		i = 0
		For hullMod = EachIn ed.stock_hullmod_stats.Values()
			hullMods[i] = hullMod
			if i = ed.builtIn_hullMod_i
				selected_hullMod = hullMod
			Endif
			i :+ 1
		Next
		'////
		'show hullmods list and cursor
		hullMods_lines = New String[hullMods_count]
		hullMods_c = New String[hullMods_count]
		i = 0
		For hullMod = EachIn ed.stock_hullmod_stats.Values()
			hullmod_id = String( hullMod.ValueForKey("id"))
			display_str = String( hullMod.ValueForKey("name") )
			hullmod_op = get_hullmod_csv_ordnance_points( ed, data, hullmod_id )
			display_str = RSet( String.FromInt( hullmod_op ), 3 )+"  "+display_str
			If data.has_builtin_hullmod( hullmod_id )
				display_str = Chr(9679)+" "+display_str 'BLACK CIRCLE
			Else
				display_str = "  "+display_str
			EndIf
			hullMods_lines[i] = display_str
			If i = ed.builtIn_hullMod_i
				hullMods_c[i] = display_str
			EndIf
			i :+ 1
		Next
		hullMods_widget = TextWidget.create( hullMods_lines )
		hullMods_cursor = TextWidget.create( hullMods_c )
		hullMods_cursor.w = hullMods_widget.w
	EndMethod

	Method update_hullmods_list( ed:TEditor, data:TData )
		initialize_hullmods_list( ed, data )
		'bounds enforce (extra check)
		If ed.builtIn_hullMod_i > (hullMods_count - 1)
			ed.builtIn_hullMod_i = (hullMods_count - 1)
		ElseIf ed.select_weapon_i < 0
			ed.builtIn_hullMod_i = 0
		EndIf
		'process input
		If KeyHit( KEY_ENTER )
			'add/remove hullmod
			data.toggle_builtin_hullmod( String( selected_hullMod.ValueForKey("id")) )
			data.update()
		EndIf
		If KeyHit( KEY_DOWN )
			ed.builtIn_hullMod_i :+ 1
		EndIf
		If KeyHit( KEY_UP )
			ed.builtIn_hullMod_i :- 1
		EndIf
		'bounds enforce
		If ed.builtIn_hullMod_i > (hullMods_count - 1)
			ed.builtIn_hullMod_i = (hullMods_count - 1)
		ElseIf ed.builtIn_hullMod_i < 0
			ed.builtIn_hullMod_i = 0
		EndIf
		If (KeyHit( KEY_ESCAPE ) Or KeyHit( KEY_HOME ))
			ed.builtIn_hullMod_i = -1
		EndIf
		If KeyHIT( KEY_H )
			ed.builtIn_hullMod_i = -1
		EndIf
	EndMethod

	Method draw_hud( ed:TEditor, data:TData )
		fg_color = $FFFFFF
		op_str = "Hull Modifications  "+data.ship.builtInMods.length+"x"
		op_widget = TextWidget.Create( op_str )
		draw_container( W_MID,3-10, op_widget.w+20,op_widget.h+20, 0.5,0.0 )
		draw_string( op_widget, W_MID,3, fg_color,$000000, 0.5,0.0 )
	EndMethod

	Method draw_hullmods_list()
		draw_container( W_MID, H_MID, hullMods_widget.w + 20, hullMods_widget.h + 20, 0.5,0.5,,, 0.75 )
		draw_string( hullMods_widget, W_MID,H_MID,,, 0.5,0.5 )
		draw_string( hullMods_cursor, W_MID,H_MID, get_cursor_color(),, 0.5,0.5 )
	EndMethod

EndType
