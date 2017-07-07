
Type TModalSetBuiltInWings Extends TSubroutine
	
	Field CURSOR_STR$ = ">>"
	Field SHOW_MORE_cached%
	Field wing_count%
	Field wing_chooser:TableWidget
	Field selected_wing_id$
	Field wing_chooser_text:TextWidget


	Method Activate( ed:TEditor, data:TData, sprite:TSprite )
		ed.last_mode = ed.mode
		ed.mode = "built_in_wings"
		ed.builtIn_wing_i = 0
		SHOW_MORE_cached = SHOW_MORE
		wing_count = count_keys( ed.stock_wing_stats )
		initialize_wing_chooser( ed, data )
		update_wing_chooser( ed, data )
		SS.reset()
	EndMethod

	Method Update( ed:TEditor, data:TData, sprite:TSprite )
		If SHOW_MORE <> SHOW_MORE_cached
			' number of visible columns changed; reconstruct table
			SHOW_MORE_cached = SHOW_MORE
			wing_count = count_keys( ed.stock_wing_stats )
			initialize_wing_chooser( ed, data )
		EndIf
		process_input( ed, data )
		update_wing_chooser( ed, data )
	End Method

	Method Draw( ed:TEditor, data:TData, sprite:TSprite )
		draw_hud( ed, data )
		draw_wings_list( ed, data )
		SetAlpha( 1 )
	EndMethod

	Method Save( ed:TEditor, data:TData, sprite:TSprite )
	EndMethod

	Method Load( ed:TEditor, data:TData, sprite:TSprite )
	EndMethod

'	'/////////////////////

	Method initialize_wing_chooser( ed:TEditor, data:TData )
		Local rows% =    1 + wing_count ' header, wings
		Local columns% = 1 + 1 + 1      ' cursor, count, data 
		If SHOW_MORE = 1 Or SHOW_MORE = 2
			columns :+ 3 ' additional columns
		EndIf
		wing_chooser = New TableWidget
		wing_chooser.resize(rows, columns)
		'---------------------------------------------------------
		' setup header row
		Local r% = 0
		Local c% = 1 + 1 + 0 ' skip: cursor, count
		wing_chooser.set_cell(r,c, "Wing ID"); c :+ 1
		If SHOW_MORE = 1 Or SHOW_MORE = 2
			wing_chooser.set_cell(r,c, "Role Desc."); c :+ 1
			wing_chooser.set_cell(r,c, "Hull Name"); c :+ 1
			wing_chooser.set_cell(r,c, "Variant ID"); c :+ 1
		EndIf
		'---------------------------------------------------------
		' create list of known data to choose from
		Local i% = 0
		For Local wing:TMap = EachIn ed.stock_wing_stats.Values()
			' table pointer
			r = 1 + i ' skip: header
			c = 1 + 1 + 0 ' skip: cursor, count (happens in update_wing_chooser())
			'---------------------------------------------------------
			' data cells
			Local wing_id$ = String( wing.ValueForKey("id"))
			wing_chooser.set_cell(r,c, wing_id); c :+ 1
			' additional data (toggle-able with Q)
			If SHOW_MORE = 1 Or SHOW_MORE = 2
				' gather additional data
				Local wing_variant_id$ = String( wing.ValueForKey("variant"))
				Local wing_role_desc$ = String( wing.ValueForKey("role desc"))
				' try to find ship name of fighters in wing by lookup through already-loaded data
				Local wing_ship_name$ = ""
				Local wing_variant:TStarfarerVariant = TStarfarerVariant( ed.stock_variants.ValueForKey( wing_variant_id ))
				If wing_variant <> Null
					Local wing_ship:TStarfarerShip = TStarfarerShip( ed.stock_ships.ValueForKey( wing_variant.hullId ))
					If wing_ship <> Null
						'Note: could also try to lookup ship in ship_data.csv if not found here
						'  not sure what to do if they conflict;
						'TODO: research: are both hull names used? which one takes precedence in-game?
						wing_ship_name = wing_ship.hullName
					EndIf
				EndIf
				wing_chooser.set_cell(r,c, wing_role_desc); c :+ 1
				wing_chooser.set_cell(r,c, wing_ship_name); c :+ 1
				wing_chooser.set_cell(r,c, wing_variant_id); c :+ 1
			EndIf
			i :+ 1
		Next
	EndMethod

	Method update_wing_chooser( ed:TEditor, data:TData )
		' render table into text widget with precalculated dimensions in screen pixels
		'
		' assume: the chooser table is already the correct number of cells
		'   and, that all the data fields contain static data
		' update only: cursor row, wing counts (columns: 0, 1)
		Local i% = 0
		For Local wing:TMap = EachIn ed.stock_wing_stats.Values()
			' table pointer
			Local r% = 1 + i ' skip: header
			Local c% = 0
			'---------------------------------------------------------
			' retain ID of selected wing
			Local wing_id$ = String( wing.ValueForKey("id"))
			Local cursor$ = ""
			If i = ed.builtIn_wing_i
				selected_wing_id = wing_id
				cursor = CURSOR_STR
			EndIf
			wing_chooser.set_cell(r,c, cursor); c :+ 1
			'---------------------------------------------------------
			' show how many of each wing are currently equipped to this ship
			Local has_wings_count% = data.count_builtin_wings( wing_id )
			Local has_wings_count_display$ = ""
			If has_wings_count > 0
				has_wings_count_display = "x" + has_wings_count
			EndIf
			wing_chooser.set_cell(r,c, has_wings_count_display); c :+ 1
			i :+ 1
		Next
		' cache for rendering
		wing_chooser_text = wing_chooser.to_TextWidget()
	EndMethod

	Method process_input( ed:TEditor, data:TData )
		'process input
		Select EventID()
			Case EVENT_KEYDOWN, EVENT_KEYREPEAT	
				Select EventData()
					Case KEY_ENTER
						'add 1x of selected wing id to ship's built-in wings list
						data.add_builtin_wing( selected_wing_id )
						data.update()
						SS.reset()
					Case KEY_DOWN 
						ed.builtIn_wing_i :+ 1
					Case KEY_UP
						ed.builtIn_wing_i :- 1
					Case KEY_PAGEDOWN 
						ed.builtIn_wing_i :+ 5
					Case KEY_PAGEUP 
						ed.builtIn_wing_i :- 5
					Case KEY_BACKSPACE
						data.remove_last_builtin_wing()
						data.update()
				EndSelect
			Case EVENT_GADGETACTION, EVENT_MENUACTION
				Select EventSource()
					Case functionMenu[MENU_FUNCTION_EXIT]
						ed.builtIn_wing_i = -1
				EndSelect
		End Select
		'bounds enforce (wrap top/bottom)
		If ed.builtIn_wing_i > (wing_count - 1)
			ed.builtIn_wing_i = 0
		ElseIf ed.builtIn_wing_i < 0
			ed.builtIn_wing_i = (wing_count - 1)
		EndIf		
	EndMethod

	Method draw_wings_list( ed:TEditor, data:TData )
		Local x# = W_MID
		Local y# = SS.ScrollTo(H_MID - LINE_HEIGHT*(ed.builtIn_wing_i + 0.5))
		Local ox# = 0.5
		Local oy# = 0.0
		If wing_chooser_text <> Null
			wing_chooser_text.draw( x,y, ox,oy )
		EndIf
	EndMethod

	Method draw_hud( ed:TEditor, data:TData )
		' draw:
		' - current ship filename
		' - list of built-in wings currently equipped, by wing id
		'     show the fighters' hull names instead of ids, if the name is not blank
		'     more bonus points: draw the wings' fighters' ships' sprites
		'     triple bonus points: in the formation & count of the wing
		'     even more bonus points: in a fancy fucking frame, like the in-game editor


		'	fg_color = $FFFFFF
		'	op_str = LocalizeString("{{ui_function_builtInHullmods_opstr}}") + "  "+ data.ship.builtInMods.length + "x"
		'	op_widget = TextWidget.Create( op_str )
		'	draw_container( 7, LINE_HEIGHT * 3, op_widget.w + 20, op_widget.h + 20, 0.0, 0.5 )
		'	draw_string( op_widget, 10+7, LINE_HEIGHT * 3, fg_color, $000000, 0.0, 0.5 )
	EndMethod

EndType
