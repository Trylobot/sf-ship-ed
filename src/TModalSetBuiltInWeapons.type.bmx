
Type TModalSetBuiltInWeapons Extends TSubroutine
'	Field fluxMods_max%
'	Field hullMods_count%
	Field left_click%
	Field img_x#,img_y#
	Field wx%,wy%
	Field x%,y%
	Field w%,h%
	Field ni%
	Field wi%
	Field modified%
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
	'For decorative edit mode
	Field decorative_mode%

	Method Activate( ed:TEditor, data:TData, sprite:TSprite )
		ed.last_mode = ed.mode
		ed.mode = "built_in_weapons"
		ed.weapon_lock_i = -1
		ed.field_i = 0
		decorative_mode = EventSource() = functionMenuSub[MENU_MODE_SHIP][MENU_SUBFUNCTION_SHIP_DECORATIVE]
		ni = - 1
		DebugLogFile(" Activate Build-in/Deco Weapon Editor")
		SS.reset()
	EndMethod

	Method Update( ed:TEditor, data:TData, sprite:TSprite )
		If Not data.ship.center Then Return
'		fluxMods_max = ed.get_max_fluxMods( data.ship.hullSize )
'		hullMods_count = count_keys( ed.stock_hullmod_stats )
		'get input
		Select EventID()
		Case EVENT_MOUSEDOWN, EVENT_MOUSEUP, EVENT_MOUSEMOVE
			If ed.weapon_lock_i <> - 1 Then Return 'not lock on any weapon yet
			sprite.get_img_xy( MouseX, MouseY, img_x, img_y )
			If decorative_mode Then ni = data.find_nearest_decorative_weapon_slot( img_x, img_y )..
			Else ni = data.find_nearest_builtin_weapon_slot( img_x, img_y )
			If ni <> - 1 Then weapon_slot = data.ship.weaponSlots[ni] Else Return	
			If EventID() = EVENT_MOUSEDOWN And ModKeyAndMouseKey = MODIFIER_LMOUSE 'left mouse click, no mod keys
				ed.weapon_lock_i = ni
				'try to find currently assigned weapon and select it in the list
				weapon_list = ed.select_weapons( weapon_slot.type_, weapon_slot.size )
				Local found% = False
				For existing_weapon_slot_id = EachIn data.ship.builtInWeapons.Keys()
					If weapon_slot.id = existing_weapon_slot_id
						existing_weapon_id = String( data.ship.builtInWeapons.ValueForKey( existing_weapon_slot_id ))
						For Local i% = 0 Until weapon_list.length
							If weapon_list[i] = existing_weapon_id
								ed.select_weapon_i = i
								found = True
								data.hold_snapshot(True)
								SS.reset()
								
								Exit
							EndIf
						Next
						If found Then Exit
					EndIf
				Next
			EndIf
		Case EVENT_GADGETACTION, EVENT_MENUACTION
			Select EventSource()
			Case functionMenu[4] 'remove weapon from slot
				If ni <> - 1
					weapon_slot = data.ship.weaponSlots[ni]
					data.unassign_builtin_weapon_from_slot( weapon_slot.id )
					data.hold_snapshot(True)
					data.update()
					data.update_variant_enforce_hull_compatibility( ed )
					data.update_variant()
					data.hold_snapshot(False)
				Else If ed.weapon_lock_i <> - 1
					weapon_slot = data.ship.weaponSlots[ed.weapon_lock_i]
					data.unassign_builtin_weapon_from_slot( weapon_slot.id )
					data.hold_snapshot(True)
					data.update()
					data.update_variant_enforce_hull_compatibility( ed )
					data.update_variant()
					data.hold_snapshot(False)
					ed.weapon_lock_i = - 1
				End If
			Case functionMenu[MENU_FUNCTION_EXIT]
				If ed.weapon_lock_i <> - 1
					ed.weapon_lock_i = - 1
					data.hold_snapshot(False)
				EndIf
			EndSelect
		Case EVENT_KEYDOWN, EVENT_KEYREPEAT
			If ed.weapon_lock_i = - 1 Then Return
				modified = False
				'load valid weapons list for the slot
				weapon_slot = data.ship.weaponSlots[ed.weapon_lock_i]
				weapon_list = ed.select_weapons( weapon_slot.type_, weapon_slot.size )
				'bounds enforce (extra check)
				ed.select_weapon_i = Max(0, Min(ed.select_weapon_i, weapon_list.length - 1) )
				'process input
				Select EventData()
				Case KEY_ENTER
					data.hold_snapshot(True)
					data.update()
					data.update_variant_enforce_hull_compatibility( ed )
					data.update_variant()
					data.hold_snapshot(False)
					ed.weapon_lock_i = - 1
					SS.reset()
'				Case KEY_BACKSPACE
'					data.hold_snapshot(True)
'					data.unassign_builtin_weapon_from_slot( weapon_slot.id )
'					ed.weapon_lock_i = - 1
'					data.update()
'					data.update_variant_enforce_hull_compatibility( ed )
'					data.update_variant()
'					data.hold_snapshot(False)	
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
				EndSelect
				If modified
					'bounds enforce (extra check)
					ed.select_weapon_i = Max(0, Min(ed.select_weapon_i, weapon_list.length - 1) )
					'reassign weapon
					data.unassign_builtin_weapon_from_slot( weapon_slot.id )
					data.assign_builtin_weapon_to_slot( weapon_slot.id, weapon_list[ed.select_weapon_i] )
				EndIf
		End Select
	End Method

	Method Draw( ed:TEditor, data:TData, sprite:TSprite ) 
		If Not data.ship.center Then Return

		'prepare to show list of weapons
		If ed.weapon_lock_i <> -1
			weapon_slot = data.ship.weaponSlots[ed.weapon_lock_i]
			weapon_list = ed.select_weapons( weapon_slot.type_, weapon_slot.size )
			For wi = 0 Until weapon_list.length
				wep_id = weapon_list[wi]
				wep_stats = TMap( ed.stock_weapon_stats.ValueForKey( wep_id ) )
				'DebugStop
				If wep_stats					
					wep_name = String( wep_stats.ValueForKey( "name" ) )
					'DebugLog(wep_name)
					wep_op_str = String( wep_stats.ValueForKey( "OPs" ) )
					'DebugLog(wep_op_str)
					If wep_name
						weapon_list[wi] = RSet(wep_op_str, 3) + "  " + wep_name
						'DebugLog (weapon_list[wi])
					EndIf
				EndIf
			Next
			weapon_list_widget = TextWidget.Create( weapon_list )
'			cursor_widget = TextWidget.Create( weapon_list[..] )
'			For Local i% = 0 Until cursor_widget.lines.length
'				If i <> ed.select_weapon_i
'					cursor_widget.lines[i] = ""
'				Else 'is current
'					'do nothing
'				EndIf
'			Next
		EndIf
		
		'screen position of coordinate to be potentially added
		nearest = False
		
		'FIRST PASS: draw text boxes but make "really faint" if zoomed out too far
		For Local i% = 0 Until data.ship.weaponSlots.Length
			'For decorative edit mode
			If Not decorative_mode% 'built-in mode
				If Not data.ship.weaponSlots[i].is_builtin()
					Continue 'skip non-built-in slots
				EndIf
			Else 'decorative mode
				If Not data.ship.weaponSlots[i].is_decorative()
					Continue 'skip non-decorative slots
				End If
			End If
			nearest = (i = ni)
			If Not nearest And ed.weapon_lock_i <> -1
				Continue ' do not draw other weapons when selecting a weapon
			EndIf
			weapon_slot = data.ship.weaponSlots[i]
			wx = sprite.sx + ( weapon_slot.locations[0] + data.ship.center[1])*sprite.Scale
			wy = sprite.sy + (-weapon_slot.locations[1] + data.ship.center[0])*sprite.Scale
			SetRotation( 0 )
			SetScale( 1, 1 )
			SetAlpha( 0.8 )
			If Not nearest
				SetAlpha( Min( 0.4, 0.5*(sprite.scale/3.0) ))
			EndIf
			draw_builtin_weapon_slot_info( ed,data,sprite, weapon_slot )
			If ed.weapon_lock_i = -1 'the select-a-weapon list will be drawn instead if it's non-null
				draw_builtin_assigned_weapon_info( ed, data, sprite, weapon_slot )
			EndIf
		Next
		
		'SECOND PASS: draw slot mount icons
		For Local i% = 0 Until data.ship.weaponSlots.Length
			'For decorative edit mode
			If Not decorative_mode% 'built-in mode
				If Not data.ship.weaponSlots[i].is_builtin()
					Continue 'skip non-built-in slots
				EndIf
			Else 'decorative mode
				If Not data.ship.weaponSlots[i].is_decorative()
					Continue 'skip non-decorative slots
				End If
			End If
			nearest = (i = ni)
			If Not nearest And ed.weapon_lock_i <> -1
				Continue ' do not draw other weapons when selecting a weapon
			EndIf
			weapon_slot = data.ship.weaponSlots[i]
			wx = sprite.sx + ( weapon_slot.locations[0] + data.ship.center[1])*sprite.Scale
			wy = sprite.sy + (-weapon_slot.locations[1] + data.ship.center[0])*sprite.Scale
			SetRotation( 0 )
			SetScale( 1, 1 )
			SetAlpha( 0.8 )
			If Not nearest
				SetAlpha( 0.4 )
			EndIf
			draw_builtin_weapon_mount( wx, wy, weapon_slot )
		Next
		SetAlpha( 1 )
		
		If ni <> - 1
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
			
			If ed.weapon_lock_i <> - 1
				'select new weapon
				SetColor( 0,0,0 )
				SetRotation( 0 )
				SetScale( 1, 1 )
				SetAlpha( 0.8 )
				SetImageFont( FONT )
				'draw box around text area
				'if applicable:
				'  draw lines connecting box to target weapon or engine
				'  draw actual weapon or engine preview
				x = wx - weapon_list_widget.w - 20 - 30 - TextWidth("=> ")
				y = wy - 10 - ( (SS.ScrollTo( ed.select_weapon_i) + 0.5) * LINE_HEIGHT)
				w = weapon_list_widget.w + 20 + TextWidth("=> ")
				h = weapon_list_widget.h + 20
				SetColor( 0,0,0 )
				SetAlpha( 0.40 )
				DrawRect( x, y, w, h )
				SetAlpha( 0.9 )
				SetColor( 0, 0, 0 )
				DrawRectLines( x - 1, y - 1, w + 2, h + 2 )
				DrawRectLines( x + 1, y + 1, w - 2, h - 2 )
				SetColor( 255, 255, 255 )
				DrawRectLines( x, y, w, h )
				'draw options
				draw_string( weapon_list_widget, (wx - 40), y + 10 + weapon_list_widget.h / 2,,, 1.0, 0.5 )
				SetColor( 0, 0, 0 )
				SetAlpha( 0.8 )
				'draw cursor
				draw_string( "=> ", (wx - 40) - (weapon_list_widget.w ), wy , get_cursor_color(),, 1.0, 0.5 )
				SetColor( 255, 255, 255 )
				SetAlpha( 0.2 )	
				DrawRect( x, wy - LINE_HEIGHT / 2 , w, LINE_HEIGHT )												
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

