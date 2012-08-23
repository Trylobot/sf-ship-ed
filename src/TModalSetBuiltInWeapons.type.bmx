
Type TModalSetBuiltInWeapons Extends TSubroutine
	Field i%
	Field fluxMods_max%
	Field hullMods_count%
	Field left_click%
	Field img_x#,img_y#
	Field wx%,wy%
	Field x%,y%
	Field w%,h%
	Field ni%
	Field wi%
	Field modified%
	Field found%
	Field nearest%
	Field wep_id$
	Field wep_stats:TMap
	Field wep_name$
	Field wep_op_str$
	Field existing_weapon_slot_id$
	Field existing_weapon_id$
	Field weapon_id$
	Field ship_weapon_slot_id$
	Field weapon_list$[]
	Field weapon_slot:TStarfarerShipWeapon
	Field weapon_list_widget:TextWidget
	Field cursor_widget:TextWidget


	Method Activate( ed:TEditor, data:TData, sprite:TSprite )
		ed.last_mode = ed.mode
		ed.mode = "built_in_weapons"
		ed.weapon_lock_i = -1
		ed.field_i = 0
	EndMethod

	Method Draw( ed:TEditor, data:TData, sprite:TSprite )
		If Not data.ship.center Then Return
		fluxMods_max = ed.get_max_fluxMods( data.ship.hullSize )
		hullMods_count = count_keys( ed.stock_hullmod_stats )
		'get input
		left_click = MouseHit( 1 )
		sprite.get_img_xy( MouseX(), MouseY(), img_x, img_y )
		'locate nearest entity
		ni = data.find_nearest_builtin_weapon_slot( img_x, img_y )
		'choose weapon for previously selected slot
		If ed.weapon_lock_i <> -1
			'load valid weapons list for the slot
			weapon_slot = data.ship.weaponSlots[ed.weapon_lock_i]
			weapon_list = ed.select_weapons( weapon_slot.type_, weapon_slot.size )
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
			modified = False
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
				weapon_slot = data.ship.weaponSlots[ni]
				'select weapon slot to assign weapon to
				If left_click
					ed.weapon_lock_i = ni
					'try to find currently assigned weapon and select it in the list
					weapon_list = ed.select_weapons( weapon_slot.type_, weapon_slot.size )
					found = false
					For existing_weapon_slot_id = EachIn data.ship.builtInWeapons.Keys()
						If weapon_slot.id = existing_weapon_slot_id
							existing_weapon_id = String( data.ship.builtInWeapons.ValueForKey( existing_weapon_slot_id ))
							For i = 0 Until weapon_list.length
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
	End Method

	Method Update( ed:TEditor, data:TData, sprite:TSprite ) 
		If Not data.ship.center Then Return
		'get input
		sprite.get_img_xy( MouseX(), MouseY(), img_x, img_y )
		'locate nearest entity
		ni = data.find_nearest_builtin_weapon_slot( img_x, img_y )
		If ed.weapon_lock_i <> -1
			ni = ed.weapon_lock_i
		End If
		'prepare to show list of weapons
		If ed.weapon_lock_i <> -1
			weapon_slot = data.ship.weaponSlots[ed.weapon_lock_i]
			weapon_list = ed.select_weapons( weapon_slot.type_, weapon_slot.size )
			For wi = 0 Until weapon_list.length
				wep_id = weapon_list[wi]
				wep_stats = TMap( ed.stock_weapon_stats.ValueForKey( wep_id ))
				If wep_stats
					wep_name = String( wep_stats.ValueForKey( "name" ))
					wep_op_str = String( wep_stats.ValueForKey( "OPs" ))
					If wep_name
						weapon_list[wi] = RSet(wep_op_str,3)+"  "+wep_name
					EndIf
				Endif
			Next
			weapon_list_widget = TextWidget.Create( weapon_list )
			cursor_widget = TextWidget.Create( weapon_list[..] )
			For i = 0 Until cursor_widget.lines.length
				If i <> ed.select_weapon_i
					cursor_widget.lines[i] = ""
				Else 'is current
					'do nothing
				EndIf
			Next
		EndIf
		''screen position of coordinate to be potentially added
		'draw pointers
		nearest = false
		'FIRST PASS: draw text boxes but make "really faint" if zoomed out too far
		For i = 0 Until data.ship.weaponSlots.Length
			If Not data.ship.weaponSlots[i].is_builtin()
				Continue 'skip non-built-in slots
			EndIf
			weapon_slot = data.ship.weaponSlots[i]
			wx = sprite.sx + (weapon_slot.locations[0] + data.ship.center[1])*sprite.Scale
			wy = sprite.sy + (-weapon_slot.locations[1] + data.ship.center[0])*sprite.Scale
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
			draw_builtin_weapon_slot_info( ed,data,sprite, weapon_slot )
			If Not weapon_list_widget 'the select-a-weapon list will be drawn instead if it's non-null
				draw_builtin_assigned_weapon_info( ed,data,sprite, weapon_slot )
			EndIf
		Next
		'SECOND PASS: draw slot mount icons
		For i = 0 Until data.ship.weaponSlots.Length
			If Not data.ship.weaponSlots[i].is_builtin()
				Continue 'skip non-built-in slots
			EndIf
			weapon_slot = data.ship.weaponSlots[i]
			wx = sprite.sx + (weapon_slot.locations[0] + data.ship.center[1])*sprite.Scale
			wy = sprite.sy + (-weapon_slot.locations[1] + data.ship.center[0])*sprite.Scale
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
			draw_builtin_weapon_mount( wx, wy, weapon_slot )
		Next
		SetAlpha( 1 )
		If ni <> -1
			weapon_slot = data.ship.weaponSlots[ni]
			wx = sprite.sx + (weapon_slot.locations[0] + data.ship.center[1])*sprite.Scale
			wy = sprite.sy + (-weapon_slot.locations[1] + data.ship.center[0])*sprite.Scale
			For ship_weapon_slot_id = EachIn data.ship.builtInWeapons.Keys()
				If ship_weapon_slot_id = weapon_slot.id
					weapon_id = String( data.ship.builtInWeapons.ValueForKey( ship_weapon_slot_id ))
					Exit
				EndIf
			Next
			draw_builtin_weapon_slot_info( ed,data,sprite, weapon_slot )
			If Not weapon_list_widget 'the select-a-weapon list will be drawn instead if it's non-null
				draw_builtin_assigned_weapon_info( ed,data,sprite, weapon_slot )
			EndIf
			draw_builtin_weapon_mount( wx, wy, weapon_slot )
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
	End Method

	Method Save( ed:TEditor, data:TData, sprite:TSprite )
	EndMethod

	Method Load( ed:TEditor, data:TData, sprite:TSprite )
	EndMethod

EndType

