
Type TModalSetSkin Extends TSubroutine
	
	'------------------------------------
	'shared
	Rem
		TODO: don't render the CURSOR_STR as part of the text widget
	    instead, render a thick rectangle with a pointer in the middle of the screen
	    on top of the text widget; that way the widget doesn't need to be rebuilt when the cursor moves
	EndRem
	Field CURSOR_STR$ = ">>"
	Field SHOW_MORE_cached%
	Field ship_hullSize_cached$

	'------------------------------------
	'mode: "changeremove_weaponslots"
	Field weapon_lock_i%

	'------------------------------------
	'mode: "addremove_builtin_weapons"
	Field compatible_weapon_ids$[]
	Field weapon_chooser:TableWidget
	Field selected_weapon_idx%
	Field selected_weapon_id$
	Field weapon_chooser_text:TextWidget

	'------------------------------------
	'mode: "changeremove_engines"
	Field engine_lock_i%

	'------------------------------------
	'mode: "addremove_hullmods"
	Field hullmod_chooser:TableWidget
	Field selected_hullmod_idx%
	Field selected_hullmod_id$
	Field hullmod_chooser_text:TextWidget

	'------------------------------------
	'mode: "addremove_hints"


	
	'--------------------------------------------
	Method Activate( ed:TEditor, data:TData, sprite:TSprite )
		' global editor state (minimize)
		ed.program_mode = "skin"
		ed.last_mode = "none"
		ed.mode = "none"
		'-------
		weapon_lock_i = -1
		selected_weapon_idx = -1
		engine_lock_i = -1
		selected_hullmod_idx = -1
		' set sprite
		sprite.img = Null
    autoload_skin_image( ed, data, sprite )
    If Not sprite.img
    	Local skin:TStarfarerSkin = ed.get_default_skin( data.ship.hullId )
    	If skin
    		data.skin = skin
    		data.update_skin( True )
    		autoload_skin_image( ed, data, sprite )
    	EndIf
    EndIf
    ' menus
    RadioMenuArray( MENU_MODE_SKIN, modeMenu )
    rebuildFunctionMenu( MENU_MODE_SKIN )
		' info verbosity [0=min|1=lots|2=all]
		SHOW_MORE_cached = SHOW_MORE
		ship_hullSize_cached = data.ship.hullSize
    ' debug
		DebugLogFile(" Activate Skin Editor")
	EndMethod

	Method SetEditorMode( ed:TEditor, data:TData, sprite:TSprite, new_mode$ )
		ed.last_mode = ed.mode
		ed.mode = new_mode	
		Select new_mode
			
			Case "changeremove_weaponslots"
				weapon_lock_i = -1
			
			Case "addremove_builtin_weapons"
				weapon_lock_i = -1

			Case "changeremove_engines"
				engine_lock_i = -1
			
			Case "addremove_hullmods"
				selected_hullmod_idx = 0
				initialize_hullmod_chooser( ed, data )
			
			Case "addremove_hints"


		EndSelect
		SS.reset()
	EndMethod

	Method Escape( ed:TEditor, data:TData, sprite:TSprite )
		Select ed.mode
			Case "changeremove_weaponslots", "addremove_builtin_weapons"
				If weapon_lock_i <> -1 Then weapon_lock_i = -1 ' unlock from weapon
				Return
			Case "changeremove_engines"
				If engine_lock_i <> -1 Then engine_lock_i = -1 ' unlock from engine
				Return
		EndSelect
		' default behavior; exit out of current module sub-mode
		ed.last_mode = ed.mode
		ed.mode = "none"
	EndMethod

	Method Update( ed:TEditor, data:TData, sprite:TSprite )
		' check for external data changes which can affect this mode's UI
		If SHOW_MORE_cached <> SHOW_MORE ..
		Or ship_hullSize_cached <> data.ship.hullSize
			' update cache
			SHOW_MORE_cached = SHOW_MORE
			ship_hullSize_cached = data.ship.hullSize
			'
			initialize_hullmod_chooser( ed, data )
		EndIf
		'-----
		Select ed.mode
			
			Case "changeremove_weaponslots"
				process_input_changeremove_weaponslots( ed, data, sprite )
			
			Case "addremove_builtin_weapons"
				process_input_addremove_builtin_weapons( ed, data, sprite )
				update_weapon_chooser( ed, data )
			
			Case "changeremove_engines"
				process_input_changeremove_engines( ed, data, sprite )
			
			Case "addremove_hullmods"
				process_input_addremove_hullmods( ed, data )
				update_hullmod_chooser( ed, data )
		
			Case "addremove_hints"
				process_input_addremove_hints( ed, data )

		EndSelect
	End Method

	Method Draw( ed:TEditor, data:TData, sprite:TSprite ) 
		draw_hud( ed, data )
		Select ed.mode
			
			Case "changeremove_weaponslots"
				draw_weaponslots( ed, data, sprite )
			
			Case "addremove_builtin_weapons"
				draw_builtin_weapon_info( ed, data, sprite )
				draw_weapons_chooser( ed, data )
			
			Case "changeremove_engines"
				draw_engines( ed, data, sprite )
			
			Case "addremove_hullmods"
				draw_hullmods_chooser( ed, data )
			
			Case "addremove_hints"
				'draw_hints_chooser( ed, data )

		EndSelect
		SetAlpha( 1 )
	EndMethod

	Method Save( ed:TEditor, data:TData, sprite:TSprite )
	EndMethod

	Method Load( ed:TEditor, data:TData, sprite:TSprite )
	EndMethod

	'/////////////////////////////////////

	'--------------------------------------
	' init functions

	Method initialize_weapon_chooser( ed:TEditor, data:TData )
		If weapon_lock_i = -1 Then Return
		'---
		Local weapon_slot_type$ = data.get_skin_weapon_slot_type( weapon_lock_i )
		Local weapon_slot_size$ = data.get_skin_weapon_slot_size( weapon_lock_i )
		Local weapon_lock_slot_id$ = data.ship.weaponSlots[weapon_lock_i].id
		Local equipped_weapon_id$ = data.get_skin_equipped_builtin_weapon_id( weapon_lock_slot_id )
		compatible_weapon_ids = ed.select_weapons( weapon_slot_type, weapon_slot_size )
		'---
		Local rows% = 1 + compatible_weapon_ids.Length
		Local cols% = 1 + 1 + 1 + 1 + 1 + 1 ' cursor, status, ops (contextual), name, size, type
		weapon_chooser = New TableWidget
		weapon_chooser.resize(rows,cols)
		weapon_chooser.justify_col(2, JUSTIFY_RIGHT) ' ops
		'-------------------------------------
		'header
		Local r% = 0
		Local c% = 1 + 1 + 0 ' skip: cursor, status
		weapon_chooser.set_cell(r,c, "OPs"); c :+ 1
		weapon_chooser.set_cell(r,c, "Name"); c :+ 1
		weapon_chooser.set_cell(r,c, "Size"); c :+ 1
		weapon_chooser.set_cell(r,c, "Type"); c :+ 1
		'-------------------------------------
		'data
		Local i% = 0
		For Local weapon_id$ = EachIn compatible_weapon_ids
			Local weapon:TStarfarerWeapon = TStarfarerWeapon( ed.stock_weapons.ValueForKey( weapon_id ))
			Local weapon_stats:TMap = TMap( ed.stock_weapon_stats.ValueForKey( weapon_id ))
			' table ptr
			r = 1 + i     ' skip header
			c = 1 + 1 + 0 ' skip cursor, status
			'----------------------------------
			weapon_chooser.set_cell(r,c, String( data.get_weapon_csv_ordnance_points( weapon_id ))); c :+ 1
			weapon_chooser.set_cell(r,c, String( weapon_stats.ValueForKey("name"))); c :+ 1
			weapon_chooser.set_cell(r,c, weapon.size); c :+ 1
			weapon_chooser.set_cell(r,c, weapon.type_); c :+ 1
			'---
			' initial position of chooser selection
			If weapon_id = equipped_weapon_id
				selected_weapon_idx = i
				selected_weapon_id = weapon_id
			EndIf
			i :+ 1
		Next
		update_weapon_chooser( ed, data )
	EndMethod

	Method destroy_weapon_chooser()
		weapon_lock_i = -1
		compatible_weapon_ids = Null
		weapon_chooser = Null
		selected_weapon_idx = -1
		selected_weapon_id = Null
		weapon_chooser_text = Null
	EndMethod

	Method initialize_hullmod_chooser( ed:TEditor, data:TData )
		Local rows% =    1 + ed.stock_hullmod_count
		Local columns% = 1 + 1 + 1 + 1 ' cursor, status, ops (contextual), name
		If SHOW_MORE = 1 Or SHOW_MORE = 2
			columns :+ 1 ' description
		EndIf
		hullmod_chooser = New TableWidget
		hullmod_chooser.resize(rows, columns)
		hullmod_chooser.justify_col(2, JUSTIFY_RIGHT) ' ops
		'---------------------------------------------------------
		' setup header row
		Local r% = 0
		Local c% = 1 + 1 + 0 ' skip: cursor, status
		hullmod_chooser.set_cell(r,c, "OPs"); c :+ 1
		hullmod_chooser.set_cell(r,c, "Name"); c :+ 1
		If SHOW_MORE = 1 Or SHOW_MORE = 2
			hullmod_chooser.set_cell(r,c, "Description"); c :+ 1
		EndIf
		'---------------------------------------------------------
		' create list of known data to choose from
		ed.sort_hullmods_by_ordnance_points()
		Local i% = 0
		For Local hullmod_id$ = EachIn ed.stock_hullmod_ids_sorted
			Local hullmod:TMap = TMap( ed.stock_hullmod_stats.ValueForKey( hullmod_id ))
			' table pointer
			r = 1 + i     ' skip: header
			c = 1 + 1 + 0 ' skip: cursor, status
			'---------------------------------------------------------
			' data cells
			Local op_cost$ = String( data.get_hullmod_csv_ordnance_points( hullmod_id ))
			hullmod_chooser.set_cell(r,c, op_cost); c :+ 1
			Local hullmod_name$ = String( hullmod.ValueForKey("name"))
			hullmod_chooser.set_cell(r,c, hullmod_name); c :+ 1
			' additional data (toggle-able with Q)
			If SHOW_MORE = 1
				Local hullmod_desc$ = LSet(String( hullmod.ValueForKey("short")), 65)
				hullmod_chooser.set_cell(r,c, hullmod_desc); c :+ 1
			ElseIf SHOW_MORE = 2
				Local hullmod_desc$ = LSet(String( hullmod.ValueForKey("desc")), 130)
				hullmod_chooser.set_cell(r,c, hullmod_desc); c :+ 1
			EndIf
			i :+ 1
		Next
		'
		update_hullmod_chooser( ed, data )
	EndMethod

	'--------------------------------------
	' update functions

	Method update_weapon_chooser( ed:TEditor, data:TData )
		If weapon_lock_i = -1 Then Return
		Local weapon_lock_slot_id$ = data.ship.weaponSlots[weapon_lock_i].id
		Local weapon_lock_base_builtin_weapon_id$ = String( data.ship.builtInWeapons.ValueForKey( weapon_lock_slot_id ))
		Local weapon_lock_skin_specifies_weapon% = data.skin_adds_builtin_weapon( weapon_lock_slot_id )
		Local weapon_lock_skin_builtin_weapon_id$ = String( data.skin.builtInWeapons.ValueForKey( weapon_lock_slot_id ))
		' update only: cursor row, status (columns: 0, 1)
		Local i% = 0
		For Local weapon_id$ = EachIn compatible_weapon_ids
			Local weapon:TMap = TMap( ed.stock_weapon_stats.ValueForKey( weapon_id ))
			' table pointer
			Local r% = 1 + i ' skip: header
			Local c% = 0
			'---------------------------------------------------------
			' retain ID of selected weapon
			Local cursor$ = ""
			If i = selected_weapon_idx
				selected_weapon_id = weapon_id
				cursor = CURSOR_STR
			EndIf
			weapon_chooser.set_cell(r,c, cursor); c :+ 1
			'---------------------------------------------------------
			' show status of each weapon as it relates to this skin (and, its "base hull" (ship))
			Local weapon_status$ = "   "
			If weapon_lock_base_builtin_weapon_id = weapon_id Then weapon_status = " b "
			If weapon_lock_skin_builtin_weapon_id = weapon_id Then weapon_status = "[s]"
			If weapon_lock_base_builtin_weapon_id = weapon_id ..
				And weapon_lock_skin_specifies_weapon ..
				And weapon_lock_skin_builtin_weapon_id <> weapon_id Then weapon_status = "---"
			weapon_chooser.set_cell(r,c, weapon_status); c :+ 1
			i :+ 1
		Next
		' cache for rendering
		weapon_chooser_text = weapon_chooser.to_TextWidget()
	EndMethod

	Method update_hullmod_chooser( ed:TEditor, data:TData )
		' update only: cursor row, status (columns: 0, 1)
		Local i% = 0
		For Local hullmod_id$ = EachIn ed.stock_hullmod_ids_sorted
			Local hullmod:TMap = TMap( ed.stock_hullmod_stats.ValueForKey( hullmod_id ))
			' table pointer
			Local r% = 1 + i ' skip: header
			Local c% = 0
			'---------------------------------------------------------
			' retain ID of selected hullmod
			Local cursor$ = ""
			If i = selected_hullmod_idx
				selected_hullmod_id = hullmod_id
				cursor = CURSOR_STR
			EndIf
			hullmod_chooser.set_cell(r,c, cursor); c :+ 1
			'---------------------------------------------------------
			' show status of each hullmod as it relates to this skin (and, its "base hull" (ship))
			Local hullmod_status$ = "   "
			If data.has_builtin_hullmod( hullmod_id )  Then hullmod_status = " b "
			If data.skin_adds_hullmod( hullmod_id )    Then hullmod_status = "[+]"
			If data.skin_removes_hullmod( hullmod_id ) Then hullmod_status = "---"
			hullmod_chooser.set_cell(r,c, hullmod_status); c :+ 1
			i :+ 1
		Next
		' cache for rendering
		hullmod_chooser_text = hullmod_chooser.to_TextWidget()
	EndMethod

	'--------------------------------------
	' input handler functions

	Method process_input_changeremove_weaponslots( ed:TEditor, data:TData, sprite:TSprite )
		If Not data.ship.center Then Return
		'
		Local img_x#, img_y#
		sprite.get_img_xy( MouseX, MouseY, img_x, img_y )
		Local focus_i% = weapon_lock_i
		If focus_i = -1 Then focus_i = data.find_nearest_skin_weapon_slot( img_x,img_y )
		'
		Select EventID()
			Case EVENT_MOUSEMOVE, EVENT_MOUSEDOWN, EVENT_MOUSEUP
				'process input
				Select ModKeyAndMouseKey
					Case 16 '(MODIFIER_LMOUSE)
						'set facing direction
						Select EventID()
							Case EVENT_MOUSEDOWN
								weapon_lock_i = focus_i
								data.set_skin_weapon_slot_angle( weapon_lock_i, img_x,img_y, ed.bounds_symmetrical )
							Case EVENT_MOUSEMOVE
								data.set_skin_weapon_slot_angle( weapon_lock_i, img_x,img_y, ed.bounds_symmetrical )
							Case EVENT_MOUSEUP
								weapon_lock_i = -1
								data.update_skin()
						EndSelect
					Case 18 '(MODIFIER_CONTROL|MODIFIER_LMOUSE)
						'set location
						Select EventID()
							Case EVENT_MOUSEDOWN
								weapon_lock_i = focus_i
								data.set_skin_weapon_slot_location( weapon_lock_i, img_x,img_y, ed.bounds_symmetrical )
							Case EVENT_MOUSEMOVE
								data.set_skin_weapon_slot_location( weapon_lock_i, img_x,img_y, ed.bounds_symmetrical )
							Case EVENT_MOUSEUP
								weapon_lock_i = -1
								data.update_skin()
						EndSelect
					Case 20 '(MODIFIER_ALT|MODIFIER_LMOUSE)
						'set degree of freedom
						Select EventID()
							Case EVENT_MOUSEDOWN
								weapon_lock_i = focus_i
								data.set_skin_weapon_slot_arc( weapon_lock_i, img_x,img_y, ed.bounds_symmetrical )
							Case EVENT_MOUSEMOVE
								data.set_skin_weapon_slot_arc( weapon_lock_i, img_x,img_y, ed.bounds_symmetrical )
							Case EVENT_MOUSEUP
								weapon_lock_i = -1
								data.update_skin()
						EndSelect
				End Select
			Case EVENT_GADGETACTION, EVENT_MENUACTION
				Select EventSource()
					Case functionMenu[MENU_FUNCTION_REMOVE]
						If data.is_skin_weapon_slot_changed( focus_i )
							data.skin_weapon_slot_clear_data( focus_i, ed.bounds_symmetrical )
						ElseIf Not data.is_skin_weapon_slot_removed( focus_i )
							data.skin_weapon_slot_mark_removal( focus_i, ed.bounds_symmetrical )
						EndIf
						data.update_skin()
				EndSelect
		EndSelect
	EndMethod

	Method process_input_addremove_builtin_weapons( ed:TEditor, data:TData, sprite:TSprite )
		If Not data.ship.center Then Return
		'
		Local img_x#, img_y#
		sprite.get_img_xy( MouseX, MouseY, img_x, img_y )
		Local nearest_i% = data.find_nearest_skin_weapon_slot( img_x,img_y )
		Local slot%, slot_id$
		Select EventID()
			Case EVENT_MOUSEDOWN
				If ModKeyAndMouseKey = MODIFIER_LMOUSE ' left mouse click with no modifiers
					If weapon_lock_i = -1
						weapon_lock_i = nearest_i
						If weapon_lock_i <> -1
							'------------------------------------
							initialize_weapon_chooser( ed, data )
							'------------------------------------
						EndIf
					EndIf
				EndIf
			Case EVENT_GADGETACTION, EVENT_MENUACTION
				Select EventSource()
					Case functionMenu[MENU_FUNCTION_REMOVE] ' remove built-in weapon from slot
						slot = weapon_lock_i
						If slot = -1 Then slot = nearest_i
						If slot <> -1
							slot_id = data.ship.weaponSlots[slot].id
							' if there ARE existing changes in this skin for the weapon slot; erase them
							If data.skin_adds_builtin_weapon( slot_id ) ..
							Or data.skin_removes_builtin_weapon( slot_id )
								data.skin_builtin_weapon_clear_data( slot_id )
							Else ' else (NO changes), mark it removed
								data.skin_builtin_weapon_remove( slot_id )
							EndIf
						EndIf
						weapon_lock_i = -1 ' close chooser
				EndSelect
			Case EVENT_KEYDOWN, EVENT_KEYREPEAT
				If weapon_lock_i <> -1
					Select EventData()
						Case KEY_ENTER
							slot_id = data.ship.weaponSlots[weapon_lock_i].id
							data.skin_builtin_weapon_assign( slot_id, selected_weapon_id )
							data.update_skin()
							weapon_lock_i = -1 ' close chooser
						Case KEY_DOWN
							selected_weapon_idx :+ 1
						Case KEY_UP
							selected_weapon_idx :- 1
						Case KEY_PAGEDOWN
							selected_weapon_idx :+ 5
						Case KEY_PAGEUP
							selected_weapon_idx :- 5
					EndSelect
					' wrap cursor
					If compatible_weapon_ids
						If selected_weapon_idx < 0 Then selected_weapon_idx = compatible_weapon_ids.Length - 1 
						If selected_weapon_idx > (compatible_weapon_ids.Length - 1) Then selected_weapon_idx = 0
					EndIf
				EndIf
		EndSelect
	EndMethod

	Method process_input_changeremove_engines( ed:TEditor, data:TData, sprite:TSprite )
		If Not data.ship.center Then Return
		'
		Local img_x#, img_y#
		sprite.get_img_xy( MouseX, MouseY, img_x, img_y )
		Local focus_i% = engine_lock_i
		If focus_i = -1 Then focus_i = data.find_nearest_skin_engine( img_x,img_y )
		'
		Select EventID()
			Case EVENT_MOUSEMOVE, EVENT_MOUSEDOWN, EVENT_MOUSEUP
				'process input
				Select ModKeyAndMouseKey
					Case 16 '(MODIFIER_LMOUSE)
						'set angle
						Select EventID()
							Case EVENT_MOUSEDOWN
								engine_lock_i = focus_i
								data.set_skin_engine_angle( engine_lock_i, img_x,img_y, ed.bounds_symmetrical )
							Case EVENT_MOUSEMOVE
								data.set_skin_engine_angle( engine_lock_i, img_x,img_y, ed.bounds_symmetrical )
							Case EVENT_MOUSEUP
								engine_lock_i = -1
								data.update_skin()
						EndSelect
					Case 18 '(MODIFIER_CONTROL|MODIFIER_LMOUSE)
						'set location
						Select EventID()
							Case EVENT_MOUSEDOWN
								engine_lock_i = focus_i
								data.set_skin_engine_location( engine_lock_i, img_x,img_y, ed.bounds_symmetrical )
							Case EVENT_MOUSEMOVE
								data.set_skin_engine_location( engine_lock_i, img_x,img_y, ed.bounds_symmetrical )
							Case EVENT_MOUSEUP
								engine_lock_i = -1
								data.update_skin()
						EndSelect
					Case 20 '(MODIFIER_ALT|MODIFIER_LMOUSE)
						'set size
						Select EventID()
							Case EVENT_MOUSEDOWN
								engine_lock_i = focus_i
								data.set_skin_engine_size( engine_lock_i, img_x,img_y, ed.bounds_symmetrical )
							Case EVENT_MOUSEMOVE
								data.set_skin_engine_size( engine_lock_i, img_x,img_y, ed.bounds_symmetrical )
							Case EVENT_MOUSEUP
								engine_lock_i = -1
								data.update_skin()
						EndSelect
				End Select
			Case EVENT_GADGETACTION, EVENT_MENUACTION
				Select EventSource()
					Case functionMenu[MENU_FUNCTION_REMOVE]
						If data.is_skin_engine_changed( focus_i )
							data.skin_engine_clear_data( focus_i, ed.bounds_symmetrical )
						ElseIf Not data.is_skin_engine_removed( focus_i )
							data.skin_engine_mark_removal( focus_i, ed.bounds_symmetrical )
						EndIf
						data.update_skin()
				EndSelect
		EndSelect
	EndMethod

	Method process_input_addremove_hullmods( ed:TEditor, data:TData )
		Select EventID()
			Case EVENT_KEYDOWN, EVENT_KEYREPEAT	
				Select EventData()
					Case KEY_ENTER
						'(attempt to) toggle selected hullmod being included in this skin
						'  if NOT on the base hull: toggle its inclusion in skin.builtInMods
						'  if on the base hull: toggle its inclusion in skin.removeBuiltInMods
						If data.has_builtin_hullmod( selected_hullmod_id )
							data.toggle_skin_removeBuiltInMods_hullmod( selected_hullmod_id )
						Else 'Not data.has_builtin_hullmod
							data.toggle_skin_builtin_hullmod( selected_hullmod_id )
						EndIf
						data.update_skin()
						SS.reset()
					Case KEY_DOWN
						selected_hullmod_idx :+ 1
					Case KEY_UP
						selected_hullmod_idx :- 1
					Case KEY_PAGEDOWN 
						selected_hullmod_idx :+ 5
					Case KEY_PAGEUP
						selected_hullmod_idx :- 5
				EndSelect
		End Select
		'bounds enforce (wrap top/bottom)
		If selected_hullmod_idx > (ed.stock_hullmod_count - 1)
			selected_hullmod_idx = 0
		ElseIf selected_hullmod_idx < 0
			selected_hullmod_idx = (ed.stock_hullmod_count - 1)
		EndIf
	EndMethod

	Method process_input_addremove_hints( ed:TEditor, data:TData )
		
	EndMethod

	'--------------------------------------
	' draw functions

	Method draw_hud( ed:TEditor, data:TData )
	EndMethod

	Method draw_weaponslots( ed:TEditor, data:TData, sprite:TSprite )
		If Not data.ship.center Then Return
		' get location of nearest engine, unless it is currently locked (due to button input)
		Local img_x#,img_y#
		sprite.get_img_xy( MouseX, MouseY, img_x,img_y )
		Local focus_i% = weapon_lock_i
		If focus_i = -1 Then focus_i = data.find_nearest_skin_weapon_slot( img_x,img_y )
		' draw "pointers" (weapon slot icons)
		SetRotation( 0 )
		SetScale( 1, 1 )
		SetAlpha( 1 )
		For Local slot% = 0 Until data.ship.weaponSlots.length
			' TODO: should we still be skipping launch bays in the skin? since the type can be changed?
			'   I guess, for now, we will continue to skip them.
			If data.ship.weaponSlots[slot].is_launch_bay()
				Continue ' should not draw as weapon slot
			EndIf
			'
			Local weapon_location#[] = data.get_skin_weapon_slot_location( slot )
			Local weapon_angle# = data.get_skin_weapon_slot_angle( slot )
			Local weapon_arc# = data.get_skin_weapon_slot_arc( slot )
			Local focused% = (slot = focus_i)
			Local x# = sprite.sx + sprite.scale*(data.ship.center[1] + weapon_location[0])
			Local y# = sprite.sy + sprite.scale*(data.ship.center[0] - weapon_location[1])
			Local is_removed% = data.is_skin_weapon_slot_removed( slot )
			draw_weapon_mount( x,y, weapon_angle,weapon_arc, focused,,,,,, is_removed )
		Next
		SetRotation( 0 )
		SetScale( 1, 1 )
		SetAlpha( 1 )
		' get mouse position on screen, mapped to ship's coordinate space
		Local ship_mx#, ship_my#
		ship_mx = +img_x - data.ship.center[1]
		ship_my = -img_y + data.ship.center[0]
		' draw crosshairs
		Local mx# = sprite.sx + img_x*sprite.scale
		Local my# = sprite.sy + img_y*sprite.scale
		draw_crosshairs( mx,my, 16 )
		'
		Local location#[]
		If focus_i <> -1
			location = data.get_skin_weapon_slot_location( focus_i )
		EndIf
		' update contextual mouse text readouts
		Select ModKeyAndMouseKey
			Case 0, 16 ' 0=???, (MODIFIER_LMOUSE)
				If focus_i <> -1
					mouse_str :+ coord_string(location[0],location[1]) ..
					      +"~n"+ json.FormatDouble(data.get_skin_weapon_slot_angle(focus_i),2)+Chr($00B0) +"~n"
				EndIf
			Case 2, 18 ' 2=???, (MODIFIER_CONTROL|MODIFIER_LMOUSE)
				If focus_i <> -1
					mouse_str :+ coord_string(location[0],location[1]) +"~n"
				Else
					mouse_str :+ coord_string(ship_mx,ship_my) +"~n"
				EndIf
			Case 4, 20 ' 4=???, (MODIFIER_ALT|MODIFIER_LMOUSE)
				If focus_i <> -1
					mouse_str :+ json.FormatDouble(data.get_skin_weapon_slot_arc(focus_i),2)+Chr($00B0)+" (arc)~n"
				EndIf
		End Select
		SetAlpha( 1 )
	EndMethod

	Method draw_builtin_weapon_slot_textboxes( ed:TEditor, data:TData, sprite:TSprite, slot% )
		Local xy#[] = data.get_skin_weapon_slot_location( slot )
		Local sz$ = data.get_skin_weapon_slot_size( slot )
		Local tp$ = data.get_skin_weapon_slot_type( slot )
		Local mt$ = data.get_skin_weapon_slot_mount( slot )
		draw_builtin_weapon_slot_info( ed,data,sprite,, xy,sz,tp,mt )
		'If weapon_lock_i = -1
			Local slot_id$ = data.ship.weaponSlots[slot].id
			Local wpid$ = data.get_skin_equipped_builtin_weapon_id( slot_id )
			draw_builtin_assigned_weapon_info( ed,data,sprite,, xy,wpid )
		'EndIf
	EndMethod

	Method draw_builtin_weapon_info( ed:TEditor, data:TData, sprite:TSprite )
		If Not data.ship.center Then Return
		'
		Local img_x#,img_y#
		sprite.get_img_xy( MouseX, MouseY, img_x,img_y )
		Local focus_i% = weapon_lock_i
		If focus_i = -1 Then focus_i = data.find_nearest_skin_weapon_slot( img_x,img_y )
		'---------------
		' text boxes (normal)
		SetRotation( 0 )
		SetScale( 1, 1 )
		SetAlpha( Min( 0.4, 0.5*(sprite.scale/3.0) ))
		If weapon_lock_i = -1
			For Local slot% = 0 Until data.ship.weaponSlots.Length
				draw_builtin_weapon_slot_textboxes( ed,data,sprite, slot )
			Next
		EndIf
		' text boxes (for focused slot, or locked-on slot)
		SetAlpha( 1 )
		draw_builtin_weapon_slot_textboxes( ed,data,sprite, focus_i )
		'---------------
		' weapon icons
		For Local slot% = 0 Until data.ship.weaponSlots.Length
			If weapon_lock_i <> -1 And weapon_lock_i <> slot Then Continue ' selective rendering when locked

		Next
	EndMethod

	Method draw_weapons_chooser( ed:TEditor, data:TData )
		If weapon_lock_i = -1 Then Return ' context-sensitive modal dialog
		Local x# = 10
		Local y# = SS.ScrollTo(H_MID - LINE_HEIGHT*(selected_weapon_idx + 0.5))
		Local ox# = 0.0
		Local oy# = 0.0
		If weapon_chooser_text <> Null
			weapon_chooser_text.draw( x,y, ox,oy )
		EndIf
	EndMethod

	Method draw_engines( ed:TEditor, data:TData, sprite:TSprite )
		If Not data.ship.center Then Return
		' get location of nearest engine, unless it is currently locked (due to button input)
		Local img_x#, img_y#
		sprite.get_img_xy( MouseX, MouseY, img_x, img_y )
		Local focus_i% = engine_lock_i
		If focus_i = -1 Then focus_i = data.find_nearest_skin_engine( img_x,img_y )
		' draw engines
		If data.ship.engineSlots
			For Local slot% = 0 Until data.ship.engineSlots.length
				Local engine_location#[] = data.get_skin_engine_location( slot )
				Local engine_length# = data.get_skin_engine_length( slot )
				Local engine_width# = data.get_skin_engine_width( slot )
				Local engine_angle# = data.get_skin_engine_angle( slot )
				Local focused% = (slot = focus_i)
				Local engine_color%[] = data.get_skin_engine_color( ed, slot )
				Local x# = sprite.sx + sprite.scale*(data.ship.center[1] + engine_location[0])
				Local y# = sprite.sy + sprite.scale*(data.ship.center[0] - engine_location[1])
				Local is_removed% = data.is_skin_engine_removed( slot )
				draw_engine( x,y, engine_length,engine_width,engine_angle, sprite.scale, focused, engine_color,, is_removed )
			Next
		EndIf
		' get mouse position on screen, mapped to ship's coordinate space
		Local ship_mx#, ship_my#
		ship_mx = +img_x - data.ship.center[1]
		ship_my = -img_y + data.ship.center[0]
		' draw crosshairs
		Local mx# = sprite.sx + img_x*sprite.scale
		Local my# = sprite.sy + img_y*sprite.scale
		draw_crosshairs( mx,my, 16 )
		' update contextual mouse text readouts
		Select ModKeyAndMouseKey
			Case 0, 16 ' 0=???, (MODIFIER_LMOUSE)
				If focus_i <> -1
					mouse_str :+ json.FormatDouble(data.get_skin_engine_angle( focus_i ), 2) + Chr($00B0) + "~n"
				EndIf
			Case 2, 18 ' 2=???, (MODIFIER_CONTROL|MODIFIER_LMOUSE)
				If focus_i <> -1
					Local location#[] = data.get_skin_engine_location( focus_i )
					mouse_str :+ coord_string( location[0],location[1] ) + "~n"
				Else
					mouse_str :+ coord_string( ship_mx, ship_my ) + "~n"
				EndIf
			Case 4, 20 ' 4=???, (MODIFIER_ALT|MODIFIER_LMOUSE)
				If focus_i <> -1
					mouse_str :+ json.FormatDouble(data.get_skin_engine_width( focus_i ), 1) ..
					  + "x" +    json.FormatDouble(data.get_skin_engine_length( focus_i ), 1) + "~n"
				EndIf
		End Select
	EndMethod

	Method draw_hullmods_chooser( ed:TEditor, data:TData )
		Local x# = W_MID
		Local y# = SS.ScrollTo(H_MID - LINE_HEIGHT*(selected_hullmod_idx + 0.5))
		Local ox# = 0.5
		Local oy# = 0.0
		If hullmod_chooser_text <> Null
			hullmod_chooser_text.draw( x,y, ox,oy )
		EndIf
	EndMethod


EndType


'--------------------------------------
' loader functions and misc.

Function load_skin_image( ed:TEditor, data:TData, sprite:TSprite, image_path$ = Null )
  image_path$ = RequestFile( LocalizeString("{{wt_load_image_skin}}"), "png", False, APP.skin_images_dir )
  If FILETYPE_FILE = FileType( image_path )
    APP.skin_images_dir = ExtractDir( image_path )+"/"
    APP.save()
    load_skin_image__driver( ed, data, sprite, image_path )
    'image has been explicitly requested and successfully loaded
    'update data path if possible
    'examples:
    'C:\Dev\BlitzMax\starfarer_ship_editor\ms_right.png
    'C:\Games\Starfarer\mods\sc2\graphics\sc2\ships\sc2_earthling_cruiser.png
    image_path = image_path.Replace( "\", "/" ) 'just in case!
    Local scan$ = image_path
    While scan.length > "graphics".length 'to cover C:/ and /
      scan = ExtractDir( scan )'C:/Games/Starfarer/mods/sc2/graphics/sc2/ships
      If scan.EndsWith( "graphics" )'C:/Games/Starfarer/mods/sc2/graphics
        Local to_remove$ = ExtractDir( scan )+"/"'C:/Games/Starfarer/mods/sc2/
          image_path = image_path.Replace( to_remove, "" )'graphics/sc2/ships/sc2_earthling_cruiser.png
          If image_path.StartsWith( "graphics" ) 'just in case!
            data.skin.spriteName = image_path
            data.update_skin()
          EndIf
        Exit
      EndIf
    EndWhile
  EndIf
  FlushEvent()
End Function

Function autoload_skin_image( ed:TEditor, data:TData, sprite:TSprite )
  Local img_path$ = resource_search( data.skin.spriteName )
  If img_path <> Null
    load_skin_image__driver( ed, data, sprite, img_path )
  EndIf
EndFunction

Function load_skin_image__driver( ed:TEditor, data:TData, sprite:TSprite, image_path$ )
  sprite.img = LoadImage( image_path, 0 )
  If sprite.img
  	'image has been loaded
  	'  skins assume the same dimensions & center of mass as the base hull(ship)
    sprite.scale = ZOOM_LEVELS[ed.selected_zoom_level]
  End If
EndFunction


Function load_skin_data( ed:TEditor, data:TData, sprite:TSprite, use_new% = False, data_path$ = Null )
  'SKIN data
  If Not use_new
    Local skin_path$ = RequestFile( LocalizeString("{{wt_load_skin}}"), "skin", False, APP.skin_dir )
    FlushKeys()
    If FileType( skin_path ) <> FILETYPE_FILE Then Return
    APP.skin_dir = ExtractDir( skin_path ) + "/"
    APP.save()
    data.decode_skin( LoadTextAs( skin_path, CODE_MODE ) )
    'load ship by skin's baseHullId, needed for skin mode hud and other sensible things
    Local baseHull:TStarfarerShip = TStarfarerShip( ed.stock_ships.ValueForKey( data.skin.baseHullId ))
    If baseHull <> Null
    	data.ship = baseHull
    	data.update()
    EndIf
    'load skin's sprite
    autoload_skin_image( ed, data, sprite )
    Rem

    TODO: Variants of Skins
    	
    	variant data will probably need to know whether it is:
      - a variant of a "normal" *.ship file (TStarfarerShip)
      - or a variant of a "skin" *.skin file (TStarfarerSkin -> TStarfarerShip)
      
      SOLUTION 1: perhaps we could create a "virtual" TStarfarerShip that mirrors what we would get
        if we in theory loaded the skin into the game?
        something to look into anyway, possibly will need to for v3.0.0 anyhow
        - we could "automatically" create these "ghost ships"
          for all skin files, and flag them as skins so we know not to save them
          that way variants don't even have to know the difference
      
      SOLUTION 2: create a new TStarfarerSkinVariant "meta" type
      	its only purpose would be to manage the interactions
	      	  between a ship, its skin, and a variant on top of that skin
	      	  (variants normally assume they point at "real" ships)
        it could have the following fields:
					Field baseHull:TStarfarerShip ' regular file, stand-alone
					Field hullSkin:TStarfarerSkin ' regular file, references baseHull
					Field mergedHull:TStarfarerShip ' points to and merges <baseHull,hullSkin>, creating a (temporary) "ghost ship"
					Field mergedHullVariant:TStarfarerVariant ' points to mergedHull

			SOLUTION 3: don't create anything new; instead, add conditional branches
			  to the variant modal's logic, that fires when the hull ID is not found among the stock ship data
			  falling back to skin data, and proceeding; after all, the link need not be explicit
			  only duck-typed.


    ' code transplanted from  load_ship_data(...)
    'VARIANT data
    'if the currently loaded variant doesn't reference the loaded hull, load one that does if possible
    If Not ed.verify_variant_association( data.ship.hullId, data.variant.variantId )
      data.variant = ed.get_default_variant( data.ship.hullId )
    EndIf
    data.update_variant_enforce_hull_compatibility( ed )
    data.update_variant()

    EndRem

  Else
    data.skin = New TStarfarerSkin
    data.skin.baseHullId = data.ship.hullId
    data.skin.skinHullId = data.ship.hullId+"_skin"
    data.skin.hullName = data.ship.hullName+" Skin"
    data.skin.spriteName = data.ship.spriteName
  EndIf
  data.update_skin()
End Function
