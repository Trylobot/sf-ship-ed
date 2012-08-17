'TODO: strip
Const MAX_WEAPON_GROUPS% = 5

Function modal_update_set_variant( ed:TEditor, data:TData, sprite:TSprite )
	If Not data.ship.center Then Return
	Local fluxMods_max% = ed.get_max_fluxMods( data.ship.hullSize )
	Local hullMods_count% = count_keys( ed.stock_hullmod_stats )
	'get input
	Local left_click% = MouseHit( 1 )
	Local img_x#, img_y#
	sprite.get_img_xy( MouseX(), MouseY(), img_x, img_y )
	'locate nearest entity
	Local ni% = data.find_nearest_weapon_slot( img_x, img_y )
	
	'choose weapon for previously selected slot
	If ed.weapon_lock_i <> -1
		'load valid weapons list for the slot
		Local weapon_slot:TStarfarerShipWeapon = data.ship.weaponSlots[ed.weapon_lock_i]
		Local weapon_list$[] = ed.select_weapons( weapon_slot.type_, weapon_slot.size )
		'bounds enforce (extra check)
		If ed.select_weapon_i > (weapon_list.length - 1)
			ed.select_weapon_i = (weapon_list.length - 1)
		ElseIf ed.select_weapon_i < 0
			ed.select_weapon_i = 0
		EndIf
		'process input
		If KeyHit( KEY_ENTER )
			data.unassign_weapon_from_slot( weapon_slot.id )
			data.assign_weapon_to_slot( weapon_slot.id, weapon_list[ed.select_weapon_i], 0 )
			data.update_variant()
			ed.weapon_lock_i = -1
		EndIf
		If KeyHit( KEY_ESCAPE )
			ed.weapon_lock_i = -1
		EndIf
		If KeyHIT( KEY_BACKSPACE ) And ed.variant_hullMod_i = -1
			data.unassign_weapon_from_slot( weapon_slot.id )
			data.update_variant()
			ed.weapon_lock_i = -1
		EndIf
		Local modified% = False
		If KeyHit( KEY_DOWN )
			ed.select_weapon_i :+ 1
			If ed.select_weapon_i > (weapon_list.length - 1)
				ed.select_weapon_i = (weapon_list.length - 1)
			Else
				modified = True
			EndIf
		EndIf
		If KeyHit( KEY_UP )
			ed.select_weapon_i :- 1
			If ed.select_weapon_i < 0
				ed.select_weapon_i = 0
			Else
				modified = True
			EndIf
		EndIf
		If modified
			data.unassign_weapon_from_slot( weapon_slot.id )
			data.assign_weapon_to_slot( weapon_slot.id, weapon_list[ed.select_weapon_i], 0 )
			data.update_variant()
		EndIf
	
	Else 'ed.weapon_lock_i = -1
		If ni <> -1
			Local weapon_slot:TStarfarerShipWeapon = data.ship.weaponSlots[ni]
			'select weapon slot to assign weapon to
			If left_click%
				ed.weapon_lock_i = ni
				'try to find currently assigned weapon and select it in the list
				Local weapon_list$[] = ed.select_weapons( weapon_slot.type_, weapon_slot.size )
				Local found% = false
				For Local group:TStarfarerVariantWeaponGroup = EachIn data.variant.weaponGroups
					For Local existing_weapon_slot_id$ = EachIn group.weapons.Keys()
						If weapon_slot.id = existing_weapon_slot_id
							Local existing_weapon_id$ = String( group.weapons.ValueForKey( existing_weapon_slot_id ))
							For Local i% = 0 Until weapon_list.length
								If weapon_list[i] = existing_weapon_id
									ed.select_weapon_i = i
									found = true
									Exit
								EndIf
							Next
							If found Then Exit
						EndIf
					Next
					If found Then Exit
				Next
			EndIf
			If KeyHIT( KEY_BACKSPACE )
				data.unassign_weapon_from_slot( weapon_slot.id )
				data.update_variant()
			EndIf
		EndIf
		If KeyHit( KEY_F )
			data.modify_fluxVents( fluxMods_max, SHIFT Or CONTROL Or ALT )
			data.update_variant()
		EndIf
		If KeyHit( KEY_C )
			data.modify_fluxCapacitors( fluxMods_max, SHIFT Or CONTROL Or ALT )
			data.update_variant()
		EndIf
		
		If ed.variant_hullMod_i <> -1
			'selecting a hullmod
			Local hullMods:TMap[] = New TMap[hullMods_count]
			Local i% = 0
			Local selected_hullMod:TMap
			For Local hullMod:TMap = EachIn ed.stock_hullmod_stats.Values()
				hullMods[i] = hullMod
				if i = ed.variant_hullMod_i
					selected_hullMod = hullMod
				Endif
				i :+ 1
			Next
			'bounds enforce (extra check)
			If ed.variant_hullMod_i > (hullMods_count - 1)
				ed.variant_hullMod_i = (hullMods_count - 1)
			ElseIf ed.select_weapon_i < 0
				ed.variant_hullMod_i = 0
			EndIf
			'process input
			If KeyHit( KEY_ENTER )
				'add/remove hullmod
				data.toggle_hullmod( String( selected_hullMod.ValueForKey("id")) )
				data.update_variant()
			EndIf
			If KeyHit( KEY_DOWN )
				ed.variant_hullMod_i :+ 1
			EndIf
			If KeyHit( KEY_UP )
				ed.variant_hullMod_i :- 1
			EndIf
			'bounds enforce
			If ed.variant_hullMod_i > (hullMods_count - 1)
				ed.variant_hullMod_i = (hullMods_count - 1)
			ElseIf ed.variant_hullMod_i < 0
				ed.variant_hullMod_i = 0
			EndIf
			If KeyHit( KEY_ESCAPE )
				ed.variant_hullMod_i = -1
			EndIf
			If KeyHIT( KEY_H )
				ed.variant_hullMod_i = -1
			EndIf
		Else
			'allow to select a hullmod
			If KeyHIT( KEY_H )
				ed.variant_hullMod_i = 0
			EndIf
		EndIf

		If ed.group_field_i <> -1
			Local max_group_offset% = (MAX_WEAPON_GROUPS - 1) '[ 0, 1, 2, 3, 4 ]
			Local count%
			For Local g% = 0 Until data.variant.weaponGroups.length
				count :+ count_keys( data.variant.weaponGroups[g].weapons )
			Next
			Local slot_ids$[] = new String[count]
			Local weapon_ids$[] = new String[count]
			Local group_offsets%[] = new Int[count]
			Local group_i% = 0, wep_i% = 0
			For Local group:TStarfarerVariantWeaponGroup = EachIn data.variant.weaponGroups
				For Local slot_id$ = EachIn group.weapons.Keys()
					slot_ids[wep_i] = slot_id
					weapon_ids[wep_i] = String( group.weapons.ValueForKey( slot_id ))
					group_offsets[wep_i] = group_i
					wep_i :+ 1
				Next
				group_i :+ 1
			Next
			If KeyHit( KEY_DOWN )
				ed.group_field_i :+ 1
				If ed.group_field_i > (count - 1)
					ed.group_field_i = (count - 1)
				Else
					reset_cursor_color_period()
				EndIf
			EndIf
			If KeyHit( KEY_UP )
				ed.group_field_i :- 1
				If ed.group_field_i < 0
					ed.group_field_i = 0
				Else
					reset_cursor_color_period()
				EndIf
			EndIf
			Local modified% = False
			If KeyHit( KEY_RIGHT )
				If group_offsets[ed.group_field_i] < max_group_offset
					data.unassign_weapon_from_slot( slot_ids[ed.group_field_i] )
					data.assign_weapon_to_slot( slot_ids[ed.group_field_i], weapon_ids[ed.group_field_i], group_offsets[ed.group_field_i] + 1 )
					data.update_variant()
					modified = True
					reset_cursor_color_period()
				EndIf
			EndIf
			If KeyHit( KEY_LEFT )
				If group_offsets[ed.group_field_i] > 0
					data.unassign_weapon_from_slot( slot_ids[ed.group_field_i] )
					data.assign_weapon_to_slot( slot_ids[ed.group_field_i], weapon_ids[ed.group_field_i], group_offsets[ed.group_field_i] - 1 )
					data.update_variant()
					modified = True
					reset_cursor_color_period()
				EndIf
			EndIf
			If KeyHit( KEY_A )
				data.toggle_weapon_group_autofire( group_offsets[ed.group_field_i] )
				data.update_variant()
			EndIf
			If modified
				reset_cursor_color_period()
				'locate slot again
				wep_i = 0
				For Local group:TStarfarerVariantWeaponGroup = EachIn data.variant.weaponGroups
					For Local slot_id$ = EachIn group.weapons.Keys()
						If slot_id = slot_ids[ed.group_field_i]
							ed.group_field_i = wep_i
							Exit
						EndIf
						wep_i :+ 1
					Next
				Next
			EndIf
			If KeyHit( KEY_ESCAPE )
				ed.group_field_i = -1
			EndIf
			'editing groups
			If KeyHit( KEY_G )
				ed.group_field_i = -1
			EndIf
		Else
			'allow to edit groups
			If KeyHit( KEY_G )
				ed.group_field_i = 0
			EndIf
		EndIf
	EndIf
End Function

Function modal_draw_set_variant( ed:TEditor, data:TData, sprite:TSprite ) 
	If Not data.ship.center Then Return
	Local hullMods_count% = count_keys( ed.stock_hullmod_stats )
	'draw HUD
	Local op_current%, op_max%
	op_current = calc_variant_used_ordnance_points( ed, data )
	op_max = get_ship_csv_ordnance_points( ed, data )
	Local fg_color% = $FFFFFF
	If op_current > op_max Then fg_color = $FF2020
	Local op_str$ = ..
		"   Ordnance Points  "+op_current+"/"+op_max+"~n"+..
		"        Flux Vents  "+data.variant.fluxVents+"~n"+..
		"   Flux Capacitors  "+data.variant.fluxCapacitors+"~n"+..
		"Hull Modifications  "+data.variant.hullMods.length+"x"
	Local op_widget:TextWidget = TextWidget.Create( op_str )
	draw_container( W_MID,3-10, op_widget.w+20,op_widget.h+20, 0.5,0.0 )
	draw_string( op_widget, W_MID,3, fg_color,$000000, 0.5,0.0 )
	'get input
	Local img_x#, img_y#
	sprite.get_img_xy( MouseX(), MouseY(), img_x, img_y )
	'locate nearest entity
	Local ni% = data.find_nearest_weapon_slot( img_x, img_y )
	If ed.weapon_lock_i <> -1
		ni = ed.weapon_lock_i
	End If
	'prepare to show list of weapons
	Local weapon_slot:TStarfarerShipWeapon
	Local weapon_list$[]
	Local weapon_list_widget:TextWidget
	Local cursor_widget:TextWidget
	If ed.weapon_lock_i <> -1
		weapon_slot = data.ship.weaponSlots[ed.weapon_lock_i]
		weapon_list = ed.select_weapons( weapon_slot.type_, weapon_slot.size )
		For Local wi% = 0 Until weapon_list.length
			Local wep_id$ = weapon_list[wi]
			Local wep_stats:TMap = TMap( ed.stock_weapon_stats.ValueForKey( wep_id ))
			If wep_stats
				Local wep_name$ = String( wep_stats.ValueForKey( "name" ))
				Local wep_op_str$ = String( wep_stats.ValueForKey( "OPs" ))
				If wep_name And wep_op_str
					weapon_list[wi] = RSet(wep_op_str,3)+"  "+wep_name
				EndIf
			Endif
		Next
		weapon_list_widget = TextWidget.Create( weapon_list )
		cursor_widget = TextWidget.Create( weapon_list[..] )
		For Local i% = 0 Until cursor_widget.lines.length
			If i <> ed.select_weapon_i
				cursor_widget.lines[i] = ""
			Else 'is current
				'do nothing
			EndIf
		Next
	EndIf
	If ed.group_field_i = -1
		''screen position of coordinate to be potentially added
		'Local x% = sprite.sx + img_x*sprite.scale 
		'Local y% = sprite.sy + img_y*sprite.scale
		'draw pointers
		Local weaponSlot:TStarfarerShipWeapon, nearest% = false
		Local wx%, wy%
		Local x%, y%, w%, h%
		'FIRST PASS: draw text boxes but make "really faint" if zoomed out too far
		For Local i% = 0 Until data.ship.weaponSlots.Length
			If data.ship.weaponSlots[i].is_launch_bay()
				Continue 'skip these
			EndIf
			weaponSlot = data.ship.weaponSlots[i]
			wx = sprite.sx + (weaponSlot.locations[0] + data.ship.center[1])*sprite.Scale
			wy = sprite.sy + (-weaponSlot.locations[1] + data.ship.center[0])*sprite.Scale
			If ni = i
				nearest = True
			Else
				nearest = False
			EndIf
			If Not nearest And ed.weapon_lock_i <> -1 Then Continue ' do not draw other weapons when selecting a weapon
			'TODO: handle weapon slots with multiple locations (launch-bays)
			SetRotation( 0 )
			SetScale( 1, 1 )
			SetAlpha( 1 )
			'draw_dot( wx, wy, nearest )
			If Not nearest
				SetAlpha( Min( 0.5, 0.5*(sprite.scale/3.0) ))
			EndIf
			draw_weapon_slot_info( ed,data,sprite, weaponSlot )
			If Not weapon_list_widget 'the select-a-weapon list will be drawn instead if it's non-null
				draw_assigned_weapon_info( ed,data,sprite, weaponSlot )
			EndIf
		Next
		'SECOND PASS: draw slot mount icons
		For Local i% = 0 Until data.ship.weaponSlots.Length
			If data.ship.weaponSlots[i].is_launch_bay()
				Continue 'skip these
			EndIf
			weaponSlot = data.ship.weaponSlots[i]
			wx = sprite.sx + (weaponSlot.locations[0] + data.ship.center[1])*sprite.Scale
			wy = sprite.sy + (-weaponSlot.locations[1] + data.ship.center[0])*sprite.Scale
			If ni = i
				nearest = True
			Else
				nearest = False
			EndIf
			If Not nearest And ed.weapon_lock_i <> -1 Then Continue ' do not draw other weapons when selecting a weapon
			'TODO: handle weapon slots with multiple locations (launch-bays)
			SetRotation( 0 )
			SetScale( 1, 1 )
			SetAlpha( 1 )
			'draw_dot( wx, wy, nearest )
			If Not nearest
				SetAlpha( 0.5 )
			EndIf
			draw_weapon_mount( wx, wy, weaponSlot.angle, weaponSlot.arc, nearest, 8, 16, 24 )
		Next
		SetAlpha( 1 )
		If ni <> -1
			weaponSlot = data.ship.weaponSlots[ni]
			wx = sprite.sx + (weaponSlot.locations[0] + data.ship.center[1])*sprite.Scale
			wy = sprite.sy + (-weaponSlot.locations[1] + data.ship.center[0])*sprite.Scale
			Local weapon_id$
			For Local group:TStarfarerVariantWeaponGroup = EachIn data.variant.weaponGroups
				For Local ship_weapon_slot_id$ = EachIn group.weapons.Keys()
					If ship_weapon_slot_id = weaponSlot.id
						weapon_id$ = String( group.weapons.ValueForKey( ship_weapon_slot_id ))
						Exit
					EndIf
				Next
			Next
			If weapon_id
				'non-empty indicator
				'draw_arc( wx, wy, 20, 0,360, 4*360, false )
			EndIf
			draw_weapon_slot_info( ed,data,sprite, weaponSlot )
			If Not weapon_list_widget 'the select-a-weapon list will be drawn instead if it's non-null
				draw_assigned_weapon_info( ed,data,sprite, weaponSlot )
			EndIf
			draw_weapon_mount( wx, wy, weaponSlot.angle, weaponSlot.arc, True, 8, 16, 24 )
			Rem
			'info
			Local wep_info:TextWidget = TextWidget.Create( ..
				weaponSlot.size+"~n"+..
				weaponSlot.type_+"~n"+..
				weaponSlot.mount )
			x = wx + 30
			y = wy - wep_info.h/2 - 10
			w = wep_info.w + 20
			h = wep_info.h + 20
			SetColor( 0,0,0 )
			SetAlpha( 0.40 )
			DrawRect( x,y, w,h )
			SetAlpha( 1 )
			SetColor( 0, 0, 0 )
			DrawRectLines( x-1, y-1, w+2, h+2 )
			DrawRectLines( x+1, y+1, w-2, h-2 )
			SetColor( 255, 255, 255 )
			DrawRectLines( x,y, w,h )
			draw_string( wep_info, wx + 40,wy,,, 0,0.5 )
			EndRem
			
			If weapon_list_widget
				'select new weapon
				SetColor( 0,0,0 )
				SetRotation( 0 )
				SetScale( 1, 1 )
				SetAlpha( 1 )
				SetImageFont( FONT )
				'draw box around text area
				'if applicable:
				'  draw lines connecting box to target weapon or engine
				'  draw actual weapon or engine preview
				x = wx - weapon_list_widget.w - 20 - 30 'W_MID/2 - weapon_list_widget.w/2 - 10
				y = wy - weapon_list_widget.h/2 - 10 'H_MID/2 - weapon_list_widget.h/2 - 10
				w = weapon_list_widget.w + 20
				h = weapon_list_widget.h + 20
				SetColor( 0,0,0 )
				SetAlpha( 0.40 )
				DrawRect( x,y, w,h )
				SetAlpha( 1 )
				SetColor( 0, 0, 0 )
				DrawRectLines( x-1, y-1, w+2, h+2 )
				DrawRectLines( x+1, y+1, w-2, h-2 )
				SetColor( 255, 255, 255 )
				DrawRectLines( x,y, w,h )
				'draw options
				draw_string( weapon_list_widget, (wx - 40),wy,,, 1.0,0.5 )
				SetColor( 0,0,0 )
				SetAlpha( 1 )
				'draw cursor
				draw_string( cursor_widget, (wx - 40),wy, get_cursor_color(),$000000, 1.0,0.5 )
				SetAlpha( 1 )

			ElseIf ed.variant_hullMod_i <> -1
				'show hullmods list and cursor
				Local hullMods_lines$[] = New String[hullMods_count]
				Local hullMods_c$[] = New String[hullMods_count]
				Local i% = 0
				For Local hullMod:TMap = EachIn ed.stock_hullmod_stats.Values()
					Local hullmod_id$ = String( hullMod.ValueForKey("id"))
					Local display_str$ = String( hullMod.ValueForKey("name") )
					Local hullmod_op% = get_hullmod_csv_ordnance_points( ed, data, hullmod_id )
					display_str = RSet( String.FromInt( hullmod_op ), 3 )+"  "+display_str
					If data.has_hullmod( hullmod_id )
						display_str = Chr(9679)+" "+display_str 'BLACK CIRCLE
					Else
						display_str = "  "+display_str
					EndIf
					hullMods_lines[i] = display_str
					If i = ed.variant_hullMod_i
						hullMods_c[i] = display_str
					EndIf
					i :+ 1
				Next
				Local hullMods_widget:TextWidget = TextWidget.create( hullMods_lines )
				Local hullMods_cursor:TextWidget = TextWidget.create( hullMods_c )
				hullMods_cursor.w = hullMods_widget.w
				draw_container( W_MID, H_MID, hullMods_widget.w + 20, hullMods_widget.h + 20, 0.5,0.5,,, 0.75 )
				draw_string( hullMods_widget, W_MID,H_MID,,, 0.5,0.5 )
				draw_string( hullMods_cursor, W_MID,H_MID, get_cursor_color(),, 0.5,0.5 )
			
			Else
				Rem
				'show currently selected weapon, no overriding mode is present
				Local current_weapon_str$
				If weapon_id
					current_weapon_str = weapon_id + "~n"
					Local wep_stats:TMap = TMap( ed.stock_weapon_stats.ValueForKey( weapon_id ))
					If wep_stats
						Local wep_name$ = String( wep_stats.ValueForKey( "name" ))
						If wep_name
							current_weapon_str = wep_name + "~n"
						EndIf
					Endif
					Local op_cost% = get_weapon_csv_ordnance_points( ed, data, weapon_id )
					current_weapon_str :+ op_cost +" OP"
				Else
					current_weapon_str :+ "empty"
				EndIf
				Local current_weapon_widget:TextWidget = TextWidget.Create( current_weapon_str )
				draw_container( wx - 30, wy, current_weapon_widget.w + 20, current_weapon_widget.h + 20, 1.0,0.5 )
				draw_string( current_weapon_widget, wx - 40, wy,,, 1.0,0.5 )
				EndRem
			EndIf
		EndIf
	Else 'ed.group_field_i <> -1
		Local wep_names$ = "~n~n"
		Local skip_lines% = 2
		Local group:TStarfarerVariantWeaponGroup
		'Local wep_g$ = "1 2 3 4 5~n"
		Local wep_g_a$ = "", wep_g_i$ = ""
		For Local g% = 0 Until MAX_WEAPON_GROUPS
			If g < data.variant.weaponGroups.length And data.variant.weaponGroups[g].autofire.value
				wep_g_a :+ "a "
			Else
				wep_g_a :+ "  "
			EndIf
			wep_g_i :+ (g+1)+" "
		Next
		Local wep_g$ = wep_g_a+"~n"+wep_g_i+"~n"
		Local line_i% = 0
		For Local g% = 0 Until data.variant.weaponGroups.length
			group = data.variant.weaponGroups[g]
			For Local slot_id$ = EachIn group.weapons.Keys()
				If line_i = ed.group_field_i
					'draw weapon under consideration
					For weapon_slot = EachIn data.ship.weaponSlots
						If weapon_slot.id = slot_id
							Local wx% = sprite.sx + (weapon_slot.locations[0] + data.ship.center[1])*sprite.Scale
							Local wy% = sprite.sy + (-weapon_slot.locations[1] + data.ship.center[0])*sprite.Scale
							'draw_dot( wx, wy, True )
							'draw_arc( wx, wy, 20, 0,360, 4*360, false )
							draw_weapon_slot_info( ed,data,sprite, weapon_slot )
							draw_assigned_weapon_info( ed,data,sprite, weapon_slot )
							draw_weapon_mount( wx, wy, weapon_slot.angle, weapon_slot.arc, TRUE, 8, 16, 24 )
							Exit
						EndIf
					Next
				EndIf
				'add its name and group to the text edit widget
				Local wep_id$ = String( group.weapons.ValueForKey( slot_id ))
				Local weapon_stats:TMap = TMap( ed.stock_weapon_stats.ValueForKey( wep_id ))
				If weapon_stats
					Local weapon_name$ = String( weapon_stats.ValueForKey("name"))
					If weapon_name
						wep_names :+ weapon_name
					Else
						wep_names :+ wep_id
					EndIf
				Else
					wep_names :+ wep_id
				EndIf
				wep_names :+ "  ~n"
				If g > 0 Then wep_g :+ RSet("",2*g)
				wep_g :+ Chr(9679)+"~n"
				line_i :+ 1
			Next
		Next
		Local wep_names_tw:TextWidget = TextWidget.Create( wep_names )
		Local wep_g_tw:TextWidget = TextWidget.Create( wep_g )
		draw_container( W_MID - wep_names_tw.w - 10,H_MID, wep_names_tw.w + wep_g_tw.w + 20,wep_names_tw.h + 20, 0.0,0.5 )
		draw_string( wep_names_tw, W_MID,H_MID,,, 1.0,0.5 )
		draw_string( wep_g_tw,     W_MID,H_MID,,, 0.0,0.5 )
		Local cursor_tw:TextWidget = TextWidget.Create( wep_names )
		For Local i% = skip_lines Until cursor_tw.lines.length
			If (i - skip_lines) <> ed.group_field_i
				cursor_tw.lines[i] = ""
			EndIf
		Next
		draw_string( cursor_tw, W_MID,H_MID, get_cursor_color(),$000000, 1.0,0.5 )
	EndIf
	SetAlpha( 1 )
End Function


Function get_ship_csv_ordnance_points%( ed:TEditor, data:TData )
	Local ship_stats:TMap = data.csv_row
	Local value$ = String( ship_stats.ValueForKey( "ordnance points" ))
	If Not value Then Return 0 'csv row found, but did not contain column
	Return value.ToInt()
EndFunction

Function calc_variant_used_ordnance_points%( ed:TEditor, data:TData )
	Local op% = 0
	'flux vents, flux capacitors, weapons, hullmods
	op :+ data.variant.fluxVents
	op :+ data.variant.fluxCapacitors
	For Local group:TStarfarerVariantWeaponGroup = EachIn data.variant.weaponGroups
		For Local ship_weapon_slot_id$ = EachIn group.weapons.Keys()
			Local weapon_id$ = String( group.weapons.ValueForKey( ship_weapon_slot_id ))
			If weapon_id
				Local weapon_op% = get_weapon_csv_ordnance_points( ed, data, weapon_id )
				op :+ weapon_op
			End If
		Next
	Next
	For Local hullMod_id$ = EachIn data.variant.hullMods
		Local hullMod_op% = get_hullmod_csv_ordnance_points( ed, data, hullMod_id )
		op :+ hullMod_op
	Next
	Return op
EndFunction

Function get_weapon_csv_ordnance_points%( ed:TEditor, data:TData, weapon_id$ )
	Local weapon_stats:TMap = TMap( ed.stock_weapon_stats.ValueForKey( weapon_id ))
	If Not weapon_stats Then Return 0 'ID not found in csv data
	Local value$ = String( weapon_stats.ValueForKey( "OPs" ))
	If Not value Then Return 0 'csv row found, but did not contain column
	Return value.ToInt()
EndFunction

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


Function draw_weapon_slot_info( ed:TEditor, data:TData, sprite:TSprite, weaponSlot:TStarfarerShipWeapon )
	'prep and compose string data
	Local wx% = sprite.sx + (weaponSlot.locations[0] + data.ship.center[1])*sprite.Scale
	Local wy% = sprite.sy + (-weaponSlot.locations[1] + data.ship.center[0])*sprite.Scale
	Local wep_info:TextWidget = TextWidget.Create( ..
		weaponSlot.size+"~n"+..
		weaponSlot.type_+"~n"+..
		weaponSlot.mount )
	'draw textbox
	draw_container( wx + 30,wy, wep_info.w + 20,wep_info.h + 20, 0.0,0.5 )
	draw_string( wep_info, wx + 40,wy,,, 0.0,0.5 )
EndFunction

Function draw_assigned_weapon_info( ed:TEditor, data:TData, sprite:TSprite, weaponSlot:TStarfarerShipWeapon )
	'prep and compose string data
	Local wx% = sprite.sx + (weaponSlot.locations[0] + data.ship.center[1])*sprite.Scale
	Local wy% = sprite.sy + (-weaponSlot.locations[1] + data.ship.center[0])*sprite.Scale
	Local weapon_id$ = data.find_assigned_slot_weapon( weaponSlot.id )
	Local current_weapon_str$ = ""
	If weapon_id
		Local wep_stats:TMap = TMap( ed.stock_weapon_stats.ValueForKey( weapon_id ))
		If wep_stats
			Local wep_name$ = String( wep_stats.ValueForKey( "name" ))
			If wep_name
				current_weapon_str :+ wep_name + "~n"
			Else
				current_weapon_str :+ weapon_id + "~n"
			EndIf
			Local op_cost$ = String( wep_stats.ValueForKey( "OPs" ))
			If op_cost
				current_weapon_str :+ op_cost + " OP"
			Else
				current_weapon_str :+ "? OP"
			EndIf
		Endif
	Else
		current_weapon_str :+ "empty"
	EndIf
	'draw textbox
	Local current_weapon_widget:TextWidget = TextWidget.Create( current_weapon_str )
	draw_container( wx - 30, wy, current_weapon_widget.w + 20, current_weapon_widget.h + 20, 1.0,0.5 )
	draw_string( current_weapon_widget, wx - 40, wy,,, 1.0,0.5 )
EndFunction

