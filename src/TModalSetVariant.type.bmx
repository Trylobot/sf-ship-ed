
Type TModalSetVariant Extends TSubroutine
	Field i%,g%
	Field ni%
	Field wi%
	Field line_i%
	Field img_x#,img_y#
	Field wx%,wy%
	Field x%,y%
	Field w%,h%
	Field fg_color%
	Field count%
	Field left_click%
	Field found%
	Field modified%
	Field nearest%
	Field display_str$
	Field skip_lines%
	'///
	Field wep_op_str$
	Field wep_type_str$
	Field wep_range_str$
	Field wep_ammo_str$
	Field wep_damage_str$
	Field wep_energy_str$
	Field wep_head_str$
	Field weapon_slot_id$
	Field weapon_id$
	Field weapon_name$
	Field weapon_slot_ids$[]
	Field weapon_ids$[]
	Field weapon_list$[]
	Field weapon_list_display$[]
	Field wep_i%
	Field weapon_stats:TMap
	Field weapon_slot:TStarfarerShipWeapon
	Field weapon_list_widget:TextWidget
	Field wep_names$
	Field wep_names_tw:TextWidget
	Field wep_g_tw:TextWidget	
	Field op_current%
	Field op_max%
	Field op_str$
	Field op_widget:TextWidget
	Field group_i%
	Field group_offsets%[]
	Field group:TStarfarerVariantWeaponGroup
	Field wep_g$
	Field wep_g_a$
	Field wep_g_i$
	Field fluxMods_max%
	Field selected_hullMod:TMap
	Field hullMods_count%
	Field hullMod:TMap
	Field hullMods:TMap[]
	Field hullMods_lines$[]
	Field hullMods_c$[]
	Field hullmod_id$ 
	Field hullmod_op% 
	Field hullmod_head_str$
	Field hullMods_widget:TextWidget
	Field hullMods_cursor:TextWidget
	'///
	Field cursor_widget:TextWidget
	Field lasteventsource:Object

	Method Activate( ed:TEditor, data:TData, sprite:TSprite )
		ed.program_mode = "variant"
		ed.last_mode = "normal"
		ed.mode = "normal"
		ed.weapon_lock_i = - 1
		ed.variant_hullMod_i = - 1
		ed.group_field_i = - 1
		ni = - 1
    RadioMenuArray( MENU_MODE_VARIANT, modeMenu )
    rebuildFunctionMenu(MENU_MODE_VARIANT)
		DebugLogFile(" Activate Variant Editor")
	EndMethod

	Method Update( ed:TEditor, data:TData, sprite:TSprite )
		If Not data.ship.center Then Return
		If ed.weapon_lock_i <> - 1
			update_weapon_assignment_list( ed, data )
		ElseIf ed.variant_hullMod_i <> - 1
			update_hullmods_list( ed, data )
		ElseIf ed.group_field_i <> - 1
			update_weapon_groups_list( ed, data )
		Else
			update_default_mode( ed, data, sprite )
		EndIf
	End Method

	Method Draw( ed:TEditor, data:TData, sprite:TSprite ) 
		If Not data.ship.center Then Return
		If Not ed.show_data ' would obscure raw data view
			draw_hud( ed, data )
		EndIf
		If ed.weapon_lock_i <> - 1
			draw_weapon_assignment_list()
		ElseIf ed.variant_hullMod_i <> -1
			draw_hullmods_list()
		ElseIf ed.group_field_i <> - 1
			draw_weapon_groups_list( ed, data, sprite )
		Else
			draw_all_weapon_slots( ed, data, sprite )
		EndIf
		SetAlpha( 1 )
	EndMethod


	Method Save( ed:TEditor, data:TData, sprite:TSprite )
	EndMethod

	Method Load( ed:TEditor, data:TData, sprite:TSprite )
	EndMethod

	'/////////////////////

	Method initialize_weapon_groups_list( ed:TEditor, data:TData )
		count = 0
		Local all_assigned_weapon_slot_ids:TMap = CreateMap()
		For g = 0 Until data.variant.weaponGroups.length
			group = data.variant.weaponGroups[g]
			For weapon_slot_id = EachIn group.weapons.Keys()
				'Local weapon_slot:TStarfarerShipWeapon = data.find_weapon_slot_by_id( weapon_slot_id )
				'If weapon_slot And weapon_slot.is_visible_to_variant()
					all_assigned_weapon_slot_ids.Insert( weapon_slot_id, String( group.weapons.ValueForKey( weapon_slot_id )) )
					count :+ 1
				'EndIf
			Next
		Next
		weapon_slot_ids = New String[count]
		weapon_ids = New String[count]
		group_offsets = New Int[count]
		wep_i = 0
		For weapon_slot_id = EachIn all_assigned_weapon_slot_ids.Keys()
			weapon_slot_ids[wep_i] = weapon_slot_id 'should be alphabetical
			weapon_ids[wep_i] = String( all_assigned_weapon_slot_ids.ValueForKey( weapon_slot_id ))
			group_offsets[wep_i] = data.find_assigned_slot_parent_group_index( weapon_slot_id )
			wep_i :+ 1
		Next
		'////
		wep_names = "~n~n"
		skip_lines = 2
		'Local wep_g$ = "1 2 3 4 5~n"
		wep_g_a = ""
		wep_g_i = ""
		For g = 0 Until MAX_VARIANT_WEAPON_GROUPS
			If g < data.variant.weaponGroups.length And data.variant.weaponGroups[g].autofire.value
				wep_g_a :+ "a "
			Else
				wep_g_a :+ "  "
			EndIf
			wep_g_i :+ (g+1)+" "
		Next
		wep_g = wep_g_a+"~n"+wep_g_i+"~n"
		line_i = 0
		For wep_i = 0 Until weapon_slot_ids.length
			'add its name and group to the text edit widget
			weapon_id = weapon_ids[wep_i]
			g = group_offsets[wep_i]
			weapon_stats = TMap( ed.stock_weapon_stats.ValueForKey( weapon_id ))
			If weapon_stats
				weapon_name = String( weapon_stats.ValueForKey("name"))
				If weapon_name
					wep_names :+ weapon_name
				Else
					wep_names :+ weapon_id
				EndIf
			Else
				wep_names :+ weapon_id
			EndIf
			wep_names :+ "  ~n"
			If g > 0 Then wep_g :+ RSet("", 2 * g)
			wep_g :+ (g + 1) + "~n"
			line_i :+ 1
		Next
		wep_names_tw = TextWidget.Create( wep_names )
		wep_g_tw = TextWidget.Create( wep_g )
'		cursor_widget = TextWidget.Create( wep_names )
'		For i = skip_lines Until cursor_widget.lines.length
'			If (i - skip_lines) <> ed.group_field_i
'				cursor_widget.lines[i] = ""
'			EndIf
'		Next
	EndMethod

	'assumes WEAPON-LOCK state
	Method initialize_weapon_assignment_list( ed:TEditor, data:TData )
		ni = ed.weapon_lock_i
		weapon_slot = data.ship.weaponSlots[ed.weapon_lock_i]
		'try to find currently assigned weapon and select it in the list
		weapon_list = ed.select_weapons( weapon_slot.type_, weapon_slot.size )
		found = False
		For group = EachIn data.variant.weaponGroups
			For weapon_slot_id = EachIn group.weapons.Keys()
				If weapon_slot.id = weapon_slot_id
					weapon_id = String( group.weapons.ValueForKey( weapon_slot_id ))
					For i = 0 Until weapon_list.length
						If weapon_list[i] = weapon_id
							ed.select_weapon_i = i
							found = True
							Exit
						EndIf
					Next
					If found Then Exit
				EndIf
			Next
			If found Then Exit
		Next
		'///
		weapon_list_display = weapon_list[..]
		For wi = 0 Until weapon_list_display.length
			weapon_id = weapon_list_display[wi]
			weapon_stats = TMap( ed.stock_weapon_stats.ValueForKey( weapon_id ))
			If weapon_stats
				weapon_name = String( weapon_stats.ValueForKey( "name" ))
				wep_op_str = String( weapon_stats.ValueForKey( "OPs" ))
				wep_type_str = String( weapon_stats.ValueForKey( "type" ))
				wep_range_str = String( weapon_stats.ValueForKey( "range" ))
				wep_ammo_str = String( weapon_stats.ValueForKey( "ammo" ))
				wep_damage_str = String( weapon_stats.ValueForKey( "damage/shot" ))
				wep_energy_str = String( weapon_stats.ValueForKey( "energy/shot" ))
				
				If weapon_name
					weapon_list_display[wi] = RSet(wep_op_str,3)+"  "+LSet(weapon_name,18)
					If SHOW_MORE > 0
						weapon_list_display[wi] = weapon_list_display[wi]+"  "+LSet(wep_type_str,7)+"  "+LSet(wep_range_str,5)
						If SHOW_MORE = 2
							weapon_list_display[wi] = weapon_list_display[wi]+"  "+LSet(wep_ammo_str,4)+"  "+LSet(wep_damage_str,6)+"  "+LSet(wep_energy_str,6)
						EndIf
					EndIf
				EndIf
			EndIf
		Next
		wep_head_str = RSet("OP",3)+"  "+LSet("Name",18)
			If SHOW_MORE > 0
				wep_head_str = wep_head_str+"  "+LSet("Type",7)+"  "+LSet("Range",5)
				If SHOW_MORE = 2
					wep_head_str = wep_head_str+"  "+LSet("Ammo",4)+"  "+LSet("Damage",6)+"  "+LSet("Energy",6)
				EndIf
			EndIf
		weapon_list_widget = TextWidget.Create( weapon_list_display )
		'update_weapon_assignment_list_cursor( ed )
	EndMethod

	Method initialize_hullmods_list( ed:TEditor, data:TData )
		hullMods = New TMap[hullMods_count]
		i = 0
		For hullMod = EachIn ed.stock_hullmod_stats.Values()
			hullMods[i] = hullMod
			If i = ed.variant_hullMod_i
				selected_hullMod = hullMod
			EndIf
			i :+ 1
		Next
		'////
		'show hullmods list and cursor
		hullMods_lines = New String[hullMods_count]
		'hullMods_c = New String[hullMods_count]
		i = 0
		
		For hullMod = EachIn ed.stock_hullmod_stats.Values()
			hullmod_id = String( hullMod.ValueForKey("id"))
			display_str = String( hullMod.ValueForKey("name") )
			hullmod_op = data.get_hullmod_csv_ordnance_points( hullmod_id )

			display_str = RSet( String.FromInt( hullmod_op ), 3 )+"  "+LSet( display_str, 28 )
			hullmod_head_str = RSet( "     OP", 7 )+"  "+LSet( "Name", 28 )
			If SHOW_MORE = 1
				display_str = display_str +"  "+ LSet( String( hullMod.ValueForKey( "short" )), 65).Replace("~q","")
				hullmod_head_str = hullmod_head_str +"  "+ LSet( "Description", 65).Replace("~q","")
			EndIf
			If SHOW_MORE = 2
				display_str = display_str +"  "+ LSet( String( hullMod.ValueForKey( "desc" )), 160).Replace("~q","")
				hullmod_head_str = hullmod_head_str +"  "+ LSet( "Description", 160).Replace("~q","")
			EndIf

			If data.has_builtin_hullmod( hullmod_id )
				display_str = "[b] " + display_str			
			Else If data.has_hullmod( hullmod_id )
				display_str = "[+] " + display_str
			Else
				display_str = "[ ] " + display_str
			EndIf
			hullMods_lines[i] = display_str
'			If i = ed.variant_hullMod_i
'				hullMods_c[i] = display_str
'			EndIf
			i :+ 1
		Next
		hullMods_widget = TextWidget.Create( hullMods_lines )
		'hullMods_cursor = TextWidget.Create( hullMods_c )
		'hullMods_cursor.w = hullMods_widget.w
	EndMethod

	Method update_weapon_assignment_list( ed:TEditor, data:TData )
		initialize_weapon_assignment_list( ed, data )
		'bounds check
		If ed.select_weapon_i > (weapon_list.length - 1)
			ed.select_weapon_i = (weapon_list.length - 1)
		ElseIf ed.select_weapon_i < 0
			ed.select_weapon_i = 0
		EndIf
		'process input
		Select EventID()
		Case EVENT_KEYDOWN, EVENT_KEYREPEAT
			modified = False
			Select EventData()
			Case KEY_ENTER
				data.unassign_weapon_from_slot( weapon_slot.id )
				data.assign_weapon_to_slot( weapon_slot.id, weapon_list[ed.select_weapon_i], 0 )
				data.update_variant()
				ed.weapon_lock_i = - 1
				data.hold_snapshot(False)
				updata_weapondrawermenu(ed)
			Case KEY_DOWN
				ed.select_weapon_i :+ 1
				modified = True			
			Case KEY_UP
				ed.select_weapon_i :- 1
				modified = True
			Case KEY_PAGEDOWN
				ed.select_weapon_i :+ 5
				modified = True
			Case KEY_PAGEUP
				ed.select_weapon_i :- 5
				modified = True										
			End Select
			If modified
				'bounds check
				If ed.select_weapon_i > (weapon_list.length - 1)
					ed.select_weapon_i = (weapon_list.length - 1)
				ElseIf ed.select_weapon_i < 0
					ed.select_weapon_i = 0
				EndIf
				data.unassign_weapon_from_slot( weapon_slot.id )
				data.assign_weapon_to_slot( weapon_slot.id, weapon_list[ed.select_weapon_i], 0 )
				data.update_variant()
			EndIf
		Case EVENT_GADGETACTION, EVENT_MENUACTION
			Select EventSource()
			Case functionMenu[MENU_FUNCTION_EXIT]
				ed.weapon_lock_i = - 1
				data.hold_snapshot(False)
				updata_weapondrawermenu(ed)
			Case functionMenu[MENU_FUNCTION_REMOVE]
				data.unassign_weapon_from_slot( weapon_slot.id )
				data.update_variant()
				ed.weapon_lock_i = - 1
				data.hold_snapshot(False)
				updata_weapondrawermenu(ed)
			EndSelect
		EndSelect		
	EndMethod
	
	Rem
	Method update_weapon_assignment_list_cursor( ed:TEditor )
		cursor_widget = TextWidget.Create( weapon_list_display[..] )
		For i = 0 Until cursor_widget.lines.length
			If i <> ed.select_weapon_i
				cursor_widget.lines[i] = ""
			Else 'is current
				'do nothing
			EndIf
		Next
	EndMethod
	EndRem
	
	Method update_hullmods_list( ed:TEditor, data:TData )
		initialize_hullmods_list( ed, data )
		'bounds enforce (extra check)
		If ed.variant_hullMod_i > (hullMods_count - 1)
			ed.variant_hullMod_i = (hullMods_count - 1)
		ElseIf ed.select_weapon_i < 0
			ed.variant_hullMod_i = 0
		EndIf
		'process input
		Select EventID()
		Case EVENT_KEYDOWN, EVENT_KEYREPEAT
			Select EventData()
			Case KEY_ENTER
				'add/remove hullmod
				data.toggle_hullmod( String( selected_hullMod.ValueForKey("id")) )
				data.update_variant()
			Case KEY_DOWN
				ed.variant_hullMod_i :+ 1
				If ed.variant_hullMod_i > (hullMods_count - 1) Then ed.variant_hullMod_i = (hullMods_count - 1)
			Case KEY_UP
				ed.variant_hullMod_i :- 1
				If ed.select_weapon_i < 0 Then ed.variant_hullMod_i = 0
			Case KEY_PAGEDOWN
				ed.variant_hullMod_i :+ 5
				If ed.variant_hullMod_i > (hullMods_count - 1) Then ed.variant_hullMod_i = (hullMods_count - 1)
			Case KEY_PAGEUP
				ed.variant_hullMod_i :- 5
				If ed.select_weapon_i < 0 Then ed.variant_hullMod_i = 0
			Case KEY_ESCAPE
				ed.variant_hullMod_i = - 1
				data.hold_snapshot(False)
				updata_weapondrawermenu(ed)
			End Select
		End Select	
	EndMethod

	Method update_weapon_groups_list( ed:TEditor, data:TData )
		Select EventID()
		Case EVENT_KEYDOWN, EVENT_KEYREPEAT
			modified = False
			Select EventData()
			Case KEY_DOWN, KEY_UP
				If EventData() = KEY_DOWN Then ed.group_field_i :+ 1 Else ed.group_field_i :- 1
				ed.group_field_i = (ed.group_field_i Mod (count ) + (count ) ) Mod (count )
				modified = True
			Case KEY_LEFT, KEY_RIGHT
				Local j% = group_offsets[ed.group_field_i]
				If EventData() = KEY_RIGHT Then j :+ 1 Else j :- 1
				j = (j Mod MAX_VARIANT_WEAPON_GROUPS + MAX_VARIANT_WEAPON_GROUPS) Mod MAX_VARIANT_WEAPON_GROUPS
				data.unassign_weapon_from_slot( weapon_slot_ids[ed.group_field_i] )
				data.assign_weapon_to_slot( weapon_slot_ids[ed.group_field_i], weapon_ids[ed.group_field_i], j )
				data.update_variant()
				modified = True
			Case KEY_A
				data.toggle_weapon_group_autofire( group_offsets[ed.group_field_i] )
				data.update_variant()
				modified = True
			End Select
			If modified Then initialize_weapon_groups_list( ed, data )
		Case EVENT_GADGETACTION, EVENT_MENUACTION
			Select EventSource()
			Case functionMenu[MENU_FUNCTION_EXIT], functionMenuSub[MENU_MODE_VARIANT][MENU_SUBFUNCTION_VARIANT_WEAPONGROUPS]
				ed.group_field_i = - 1
				data.hold_snapshot(False)
				updata_weapondrawermenu(ed)
			EndSelect
		EndSelect
	EndMethod
	
	Method update_default_mode( ed:TEditor, data:TData, sprite:TSprite )
		fluxMods_max = ed.get_max_fluxMods( data.ship.hullSize )
		hullMods_count = count_keys( ed.stock_hullmod_stats )
		'get input
		Select EventID()
		Case EVENT_MOUSEDOWN, EVENT_MOUSEUP, EVENT_MOUSEMOVE
			sprite.get_img_xy( MouseX, MouseY, img_x, img_y )
			'locate nearest entity
			ni = data.find_nearest_variant_weapon_slot( img_x, img_y )
			If ni = - 1 Then Return
			weapon_slot = data.ship.weaponSlots[ni]
			'CLICK to select weapon slot to assign weapon to (not for built-in weapons)
			If EventID() = EVENT_MOUSEDOWN And ModKeyAndMouseKey = MODIFIER_LMOUSE 'left mouse click, no mod keys
				'enter WEAPON LOCK mode
				If Not weapon_slot.is_builtin()
					ed.weapon_lock_i = ni
					data.hold_snapshot(True)
					initialize_weapon_assignment_list( ed, data )
					SS.reset()
					
				EndIf
			EndIf
		Case EVENT_GADGETACTION, EVENT_MENUACTION
			Select EventSource()
			Case functionMenu[MENU_FUNCTION_REMOVE] ' backsapce
				'strip non built-in weapon in slot
				If ni = - 1 Then Return
				If Not weapon_slot.is_builtin()
					data.unassign_weapon_from_slot( weapon_slot.id )
					data.update_variant()
				EndIf
			Case functionMenuSub[MENU_MODE_VARIANT][MENU_SUBFUNCTION_VARIANT_WEAPONGROUPS] 'G
				If data.ship.weaponSlots And data.ship.weaponSlots.Length > 0
					'enter WEAPON GROUPS mode
					ed.group_field_i = 0
					initialize_weapon_groups_list( ed, data )
					If weapon_slot_ids.length <= 0 Then ed.group_field_i = - 1.. 'no weapons
					Else data.hold_snapshot(True)
				EndIf
			Case functionMenuSub[MENU_MODE_VARIANT][MENU_SUBFUNCTION_VARIANT_VENT_ADD] 'F add Vents
				If Not data.modify_fluxVents( fluxMods_max, False ) Then Return
				data.update_variant()
			Case functionMenuSub[MENU_MODE_VARIANT][MENU_SUBFUNCTION_VARIANT_VENT_REMOVE] 'F add/remove Vents
				If Not data.modify_fluxVents( fluxMods_max, True ) Then Return
				data.update_variant()
			Case functionMenuSub[MENU_MODE_VARIANT][MENU_SUBFUNCTION_VARIANT_CAP_ADD] 'C add/remove Capacitors
				If Not data.modify_fluxCapacitors( fluxMods_max, False ) Then Return
				data.update_variant()
			Case functionMenuSub[MENU_MODE_VARIANT][MENU_SUBFUNCTION_VARIANT_CAP_REMOVE] 'C add/remove Capacitors
				If Not data.modify_fluxCapacitors( fluxMods_max, True ) Then Return
				data.update_variant()
			Case functionMenuSub[MENU_MODE_VARIANT][MENU_SUBFUNCTION_VARIANT_HULLMOD] 'H edit hullmods
				'enter HULLMODS mode
				ed.variant_hullMod_i = 0
				initialize_hullmods_list( ed, data )
				data.hold_snapshot(True)
				SS.reset()				
			Case functionMenuSub[MENU_MODE_VARIANT][MENU_SUBFUNCTION_VARIANT_STRIPALL] '/(slash)
				load_variant_data( ed, data, sprite, True ) 'strip all	
			EndSelect
		EndSelect
		updata_weapondrawermenu(ed)
	EndMethod

	Method draw_hud( ed:TEditor, data:TData )
		op_current = data.calc_variant_used_ordnance_points()
		op_max = data.get_ship_csv_ordnance_points()
		fg_color = $FFFFFF
		If op_current > op_max Then fg_color = $FF2020
		op_str = ..
			LocalizeString("{{ui_function_variant_opstr1}}") + op_current + "/" + op_max + "~n" + ..
			LocalizeString("{{ui_function_variant_opstr2}}") + data.variant.fluxVents + "/" + fluxMods_max + "~n" + ..
			LocalizeString("{{ui_function_variant_opstr3}}") + data.variant.fluxCapacitors + "/" + fluxMods_max + "~n" + ..
			LocalizeString("{{ui_function_variant_opstr4}}") + data.variant.hullMods.length + "x"
		op_widget = TextWidget.Create( op_str )
		draw_container( 7, LINE_HEIGHT * 2, op_widget.w + 20, op_widget.h + 20, 0.0, 0.0 )
		draw_string( op_widget, 7 + 10, LINE_HEIGHT * 2 + 10, fg_color, $000000, 0.0, 0.0 )
	EndMethod

	Method draw_all_weapon_slots( ed:TEditor, data:TData, sprite:TSprite )
		'draw pointers
		nearest = False
		
		'FIRST PASS: draw text boxes but make "really faint" if zoomed out too far
		For i = 0 Until data.ship.weaponSlots.Length
			If Not data.ship.weaponSlots[i].is_visible_to_variant()
				Continue 'skip these
			EndIf
			nearest = (i = ni)
			If Not nearest And ed.weapon_lock_i <> -1
				Continue ' do not draw other weapons when selecting a weapon
			EndIf
			weapon_slot = data.ship.weaponSlots[i]
			wx = sprite.sx + ( weapon_slot.locations[0] + data.ship.center[1])*sprite.Scale
			wy = sprite.sy + (-weapon_slot.locations[1] + data.ship.center[0])*sprite.Scale
			SetRotation( 0 )
			SetScale( 1, 1 )
			SetAlpha( 1 )
			If Not nearest
				SetAlpha( Min( 0.5, 0.5*(sprite.scale/3.0) ))
			EndIf
			draw_weapon_slot_info( ed,data,sprite, weapon_slot )
			If ed.weapon_lock_i = -1 'the select-a-weapon list will be drawn instead if it's non-null
				draw_assigned_weapon_info( ed,data,sprite, weapon_slot )
			EndIf
		Next
		
		'SECOND PASS: draw slot mount icons
		For i = 0 Until data.ship.weaponSlots.Length
			If Not data.ship.weaponSlots[i].is_visible_to_variant()
				Continue 'skip these
			EndIf
			nearest = (i = ni)
			If Not nearest And ed.weapon_lock_i <> -1
				Continue ' do not draw other weapons when selecting a weapon
			EndIf
			weapon_slot = data.ship.weaponSlots[i]
			wx = sprite.sx + ( weapon_slot.locations[0] + data.ship.center[1])*sprite.Scale
			wy = sprite.sy + (-weapon_slot.locations[1] + data.ship.center[0])*sprite.Scale
			SetRotation( 0 )
			SetScale( 1, 1 )
			SetAlpha( 1 )
			'draw_dot( wx, wy, nearest )
			If Not nearest
				SetAlpha( 0.5 )
			EndIf
			draw_variant_weapon_mount( wx, wy, weapon_slot )
		Next
		SetAlpha( 1 )

		'THIRD PASS: draw the nearest weapon mount, if there is one set
		If ni <> - 1
			weapon_slot = data.ship.weaponSlots[ni]
			wx = sprite.sx + (weapon_slot.locations[0] + data.ship.center[1])*sprite.Scale
			wy = sprite.sy + (-weapon_slot.locations[1] + data.ship.center[0])*sprite.Scale
			draw_weapon_slot_info( ed,data,sprite, weapon_slot )
			If ed.weapon_lock_i = -1 'the select-a-weapon list will be drawn instead if it's non-null
				draw_assigned_weapon_info( ed,data,sprite, weapon_slot )
			EndIf
			draw_variant_weapon_mount( wx, wy, weapon_slot )
		EndIf
	EndMethod

	Method draw_weapon_groups_list( ed:TEditor, data:TData, sprite:TSprite )
		'draw pertinent weapon slot
		If ed.group_field_i <> -1
			For weapon_slot = EachIn data.ship.weaponSlots
				If weapon_slot_ids[ed.group_field_i] = weapon_slot.id
					'  found slot on ship
					If weapon_slot.is_visible_to_variant()
						wx = sprite.sx + (weapon_slot.locations[0] + data.ship.center[1])*sprite.Scale
						wy = sprite.sy + (-weapon_slot.locations[1] + data.ship.center[0])*sprite.Scale
						If Not weapon_slot.is_builtin()
							'  "normal" (variant data) weapon
							draw_weapon_slot_info( ed,data,sprite, weapon_slot )
							draw_assigned_weapon_info( ed,data,sprite, weapon_slot )
							draw_variant_weapon_mount( wx,wy, weapon_slot )
						Else
							'  "built-in" (ship data) weapon
							draw_builtin_weapon_slot_info( ed,data,sprite, weapon_slot )
							draw_builtin_assigned_weapon_info( ed,data,sprite, weapon_slot )
							draw_builtin_weapon_mount( wx,wy, weapon_slot )
						EndIf
						Exit
					EndIf
				EndIf
			Next
		EndIf
		'draw textbox
		draw_container( 20, H_MID, wep_names_tw.w + wep_g_tw.w + 20 + TextWidth("=> "), wep_names_tw.h + 20, 0.0, 0.5 )
		draw_string( wep_names_tw, 20 + 10 + 10, H_MID,,, 0.0, 0.5 )
		draw_string( wep_g_tw, wep_names_tw.w + wep_g_tw.w + 20 + TextWidth("=> "), H_MID,,, 1.0, 0.5 )
		'draw_string( cursor_widget, W_MID, H_MID, get_cursor_color(), $000000, 1.0, 0.5 )
		draw_string( "=> ", 20, H_MID - (wep_names_tw.h / 2.0) + (ed.group_field_i + 2 + 0.5) * LINE_HEIGHT, get_cursor_color(), $000000, 0.0, 0.5 )	
	EndMethod

	Method draw_weapon_assignment_list()
		SetColor( 0,0,0 )
		SetRotation( 0 )
		SetScale( 1, 1 )
		SetAlpha( 1 )
		SetImageFont( FONT )
		'draw box around text area
		'if applicable:
		'  draw lines connecting box to target weapon or engine
		'  draw actual weapon or engine preview
			Rem
			x = wx - weapon_list_widget.w - 20 - 30 'W_MID/2 - weapon_list_widget.w/2 - 10
			y = wy - weapon_list_widget.h / 2 - 10 'H_MID/2 - weapon_list_widget.h/2 - 10
			w = weapon_list_widget.w + 20
			h = weapon_list_widget.h + 20
			SetColor( 0, 0, 0 )
			SetAlpha( 0.40 )
			DrawRect( x,y, w,h )
			SetAlpha( 1 )
			SetColor( 0, 0, 0 )
			DrawRectLines( x-1, y-1, w+2, h+2 )
			DrawRectLines( x+1, y+1, w-2, h-2 )
			SetColor( 255, 255, 255 )
			DrawRectLines( x,y, w,h )
			'draw options
			draw_string( weapon_list_widget, (wx - 40), wy,,, 1.0, 0.5 )
			SetColor( 0,0,0 )
			SetAlpha( 1 )
			'draw cursor
			draw_string( cursor_widget, (wx - 40), wy, get_cursor_color(), $000000, 1.0, 0.5 )
			SetAlpha( 1 )
			EndRem
		x = wx - weapon_list_widget.w - 20 - 30 - TextWidth("=> ")
		y = SS.ScrollTo( wy - 10 - ( (ed.select_weapon_i + 0.5) * LINE_HEIGHT) )
		w = weapon_list_widget.w + 20 + TextWidth("=> ")


		h = weapon_list_widget.h + 20
		SetColor( 0, 0, 0 )
		SetAlpha( 0.40 )
		DrawRect( x, y -10, w, h )
		SetAlpha( 0.9 )
		SetColor( 0, 0, 0 )
		DrawRectLines( x - 1, y - 1, w + 2, h + 2 )
		DrawRectLines( x + 1, y + 1, w - 2, h - 2 )
		SetColor( 255, 255, 255 )
		DrawRectLines( x, y - 10, w, h )
		'draw options

		draw_string( wep_head_str, (wx - 40), y,,, 1.0, 0.5 )
		draw_string( weapon_list_widget, (wx - 40), y+10 + weapon_list_widget.h / 2,,, 1.0, 0.5 )
		SetColor( 0, 0, 0 )
		SetAlpha( 0.8 )
		'draw cursor

		draw_string( "=> ", (wx - 40) - (weapon_list_widget.w ), wy , get_cursor_color(),, 1.0, 0.5 )		
		SetAlpha( 1 )
		SetColor( 255, 255, 255 )
		SetAlpha( 0.2 )	

		DrawRect( x, wy - LINE_HEIGHT / 2, w, LINE_HEIGHT )												

		SetAlpha( 1 )
	EndMethod

	Method draw_hullmods_list()
		Local drawY# = SS.ScrollTo( H_MID - ( (ed.variant_hullMod_i + 0.5) * LINE_HEIGHT) )
		draw_container( W_MID - 40 - TextWidth("=>"), drawY - 30, hullMods_widget.w + 20 + TextWidth("=>"), hullMods_widget.h + 40, 0.5, 0,,, 0.75 )
		draw_string( hullmod_head_str, W_MID - 40, drawY - 20,,, 0.5, 0 )
		draw_string( hullMods_widget, W_MID - 40, drawY,,, 0.5, 0 )
		draw_string( "=>", W_MID - 40 - TextWidth("=>") - hullMods_widget.w / 2, H_MID, get_cursor_color(),, 0.5, 0.5 )
		SetAlpha( 0.2 )	
		DrawRect( W_MID - 40 - 18 - TextWidth("=>") - 0.5 * ( hullMods_widget.w ), H_MID - 1 - LINE_HEIGHT / 2 , hullMods_widget.w + 20 + TextWidth("=>"), LINE_HEIGHT )												
		SetAlpha( 1 )
	EndMethod

EndType


Function load_variant_data( ed:TEditor, data:TData, sprite:TSprite, use_new% = False, data_path$ = Null )
  'VARIANT data
  If Not use_new
    Local variant_path$ = RequestFile( LocalizeString("{{wt_load_variant}}"), "variant", False, APP.variant_dir )
    FlushKeys()
    If FileType( variant_path ) <> FILETYPE_FILE Then Return
    APP.variant_dir = ExtractDir( variant_path ) + "/"
    APP.save()
    data.decode_variant( LoadTextAs( variant_path, CODE_MODE ) )
    data.update_variant_enforce_hull_compatibility( ed )
    data.update_variant()
  Else
    data.variant = New TStarfarerVariant
    data.variant.hullId = data.ship.hullId
    data.variant.variantId = data.ship.hullId+"_variant"
    data.update_variant_enforce_hull_compatibility( ed )
    data.update_variant()
  EndIf
  'FIGHTER WING CSV/STATS data'
  'if the current wing data doesn't reference the loaded variant, load one that does if possible
  If Not ed.verify_wing_data_association( data.variant.variantId, String(data.csv_row_wing.ValueForKey("id")))
    data.csv_row_wing = ed.get_default_wing( data.variant.variantId )
  EndIf
End Function

