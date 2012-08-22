
Type TModalSetBuiltInWeapons Extends TSubroutine
EndType

Function modal_update_set_built_in_weapons( ed:TEditor, data:TData, sprite:TSprite )
	If Not data.ship.center Then Return
	Local fluxMods_max% = ed.get_max_fluxMods( data.ship.hullSize )
	Local hullMods_count% = count_keys( ed.stock_hullmod_stats )
	'get input
	Local left_click% = MouseHit( 1 )
	Local img_x#, img_y#
	sprite.get_img_xy( MouseX(), MouseY(), img_x, img_y )
	'locate nearest entity
	Local ni% = data.find_nearest_builtin_weapon_slot( img_x, img_y )
	
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
			data.unassign_builtin_weapon_from_slot( weapon_slot.id )
			data.assign_builtin_weapon_to_slot( weapon_slot.id, weapon_list[ed.select_weapon_i] )
			data.update()
			data.update_variant()
			ed.weapon_lock_i = -1
		EndIf
		If KeyHit( KEY_ESCAPE )
			ed.weapon_lock_i = -1
		EndIf
		If KeyHIT( KEY_BACKSPACE )
			data.unassign_builtin_weapon_from_slot( weapon_slot.id )
			data.update()
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
			data.unassign_builtin_weapon_from_slot( weapon_slot.id )
			data.assign_builtin_weapon_to_slot( weapon_slot.id, weapon_list[ed.select_weapon_i] )
			data.update()
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
				For Local existing_weapon_slot_id$ = EachIn data.ship.builtInWeapons.Keys()
					If weapon_slot.id = existing_weapon_slot_id
						Local existing_weapon_id$ = String( data.ship.builtInWeapons.ValueForKey( existing_weapon_slot_id ))
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
			EndIf
			If KeyHIT( KEY_BACKSPACE )
				data.unassign_builtin_weapon_from_slot( weapon_slot.id )
				data.update()
				data.update_variant()
			EndIf
		EndIf
	EndIf
End Function

Function modal_draw_set_built_in_weapons( ed:TEditor, data:TData, sprite:TSprite ) 
	If Not data.ship.center Then Return
	'get input
	Local img_x#, img_y#
	sprite.get_img_xy( MouseX(), MouseY(), img_x, img_y )
	'locate nearest entity
	Local ni% = data.find_nearest_builtin_weapon_slot( img_x, img_y )
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
				If wep_name
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
	''screen position of coordinate to be potentially added
	'draw pointers
	Local weaponSlot:TStarfarerShipWeapon, nearest% = false
	Local wx%, wy%
	Local x%, y%, w%, h%
	'FIRST PASS: draw text boxes but make "really faint" if zoomed out too far
	For Local i% = 0 Until data.ship.weaponSlots.Length
		If Not data.ship.weaponSlots[i].is_builtin()
			Continue 'skip non-built-in slots
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
		If Not nearest
			SetAlpha( Min( 0.5, 0.5*(sprite.scale/3.0) ))
		EndIf
		draw_builtin_weapon_slot_info( ed,data,sprite, weaponSlot )
		If Not weapon_list_widget 'the select-a-weapon list will be drawn instead if it's non-null
			draw_builtin_assigned_weapon_info( ed,data,sprite, weaponSlot )
		EndIf
	Next
	'SECOND PASS: draw slot mount icons
	For Local i% = 0 Until data.ship.weaponSlots.Length
		If Not data.ship.weaponSlots[i].is_builtin()
			Continue 'skip non-built-in slots
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
		If Not nearest
			SetAlpha( 0.5 )
		EndIf
		draw_builtin_weapon_mount( wx, wy, weaponSlot )
	Next
	SetAlpha( 1 )
	If ni <> -1
		weaponSlot = data.ship.weaponSlots[ni]
		wx = sprite.sx + (weaponSlot.locations[0] + data.ship.center[1])*sprite.Scale
		wy = sprite.sy + (-weaponSlot.locations[1] + data.ship.center[0])*sprite.Scale
		Local weapon_id$
		For Local ship_weapon_slot_id$ = EachIn data.ship.builtInWeapons.Keys()
			If ship_weapon_slot_id = weaponSlot.id
				weapon_id$ = String( data.ship.builtInWeapons.ValueForKey( ship_weapon_slot_id ))
				Exit
			EndIf
		Next
		draw_builtin_weapon_slot_info( ed,data,sprite, weaponSlot )
		If Not weapon_list_widget 'the select-a-weapon list will be drawn instead if it's non-null
			draw_builtin_assigned_weapon_info( ed,data,sprite, weaponSlot )
		EndIf
		draw_builtin_weapon_mount( wx, wy, weaponSlot )
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
		EndIf
	EndIf
	SetAlpha( 1 )
End Function

Function draw_builtin_weapon_slot_info( ed:TEditor, data:TData, sprite:TSprite, weaponSlot:TStarfarerShipWeapon )
	'prep and compose string data
	Local wx% = sprite.sx + (weaponSlot.locations[0] + data.ship.center[1])*sprite.Scale
	Local wy% = sprite.sy + (-weaponSlot.locations[1] + data.ship.center[0])*sprite.Scale
	Local wep_info:TextWidget = TextWidget.Create( ..
		weaponSlot.size+"~n"+..
		weaponSlot.type_+"~n"+..
		weaponSlot.mount )
	'set colors
	Local fg_color% = $FFFFFF
	Local bg_color% = $000000
	'draw textbox
	draw_container( wx + 30,wy, wep_info.w + 20,wep_info.h + 20, 0.0,0.5, fg_color,bg_color )
	draw_string( wep_info, wx + 40,wy, fg_color,bg_color, 0.0,0.5 )
EndFunction

Function draw_builtin_assigned_weapon_info( ed:TEditor, data:TData, sprite:TSprite, weaponSlot:TStarfarerShipWeapon )
	'prep and compose string data
	Local wx% = sprite.sx + (weaponSlot.locations[0] + data.ship.center[1])*sprite.Scale
	Local wy% = sprite.sy + (-weaponSlot.locations[1] + data.ship.center[0])*sprite.Scale
	Local weapon_id$ = String( data.ship.builtInWeapons.ValueForKey( weaponSlot.id )) 'data.find_assigned_slot_weapon( weaponSlot.id )
	Local current_weapon_str$ = ""
	If weapon_id
		Local wep_stats:TMap = TMap( ed.stock_weapon_stats.ValueForKey( weapon_id ))
		If wep_stats
			Local wep_name$ = String( wep_stats.ValueForKey( "name" ))
			If wep_name
				current_weapon_str :+ wep_name
			Else
				current_weapon_str :+ weapon_id
			EndIf
		Endif
	Else
		current_weapon_str :+ "empty"
	EndIf
	'set colors
	Local fg_color% = $FFFFFF
	Local bg_color% = $000000
	'draw textbox
	Local current_weapon_widget:TextWidget = TextWidget.Create( current_weapon_str )
	draw_container( wx - 30, wy, current_weapon_widget.w + 20, current_weapon_widget.h + 20, 1.0,0.5, fg_color,bg_color )
	draw_string( current_weapon_widget, wx - 40, wy, fg_color,bg_color, 1.0,0.5 )
EndFunction

Function draw_builtin_weapon_mount( wx%, wy%, weaponSlot:TStarfarerShipWeapon )
	Local fg_color% = $FFFFFF
	Local bg_color% = $000000
	'draw icon
	draw_weapon_mount( wx, wy, weaponSlot.angle, weaponSlot.arc, TRUE, 8, 16, 24, fg_color,bg_color )
EndFunction

