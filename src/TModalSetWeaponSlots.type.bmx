
Type TModalSetWeaponSlots Extends TSubroutine
	Field i%
	Field img_x#,img_y#
	Field x%,y%
	Field wx%, wy%
	Field angle#
	Field arc#
	Field wyr#
	Field xr%,yr%
	Field ni%
	Field LB_i%
	Field left_click%
	Field nearest%
	Field source_weapon:TStarfarerShipWeapon
	Field weapon:TStarfarerShipWeapon

	Method Activate( ed:TEditor, data:TData, sprite:TSprite )
		ed.last_mode = ed.mode
		ed.mode = "weapon_slots"
		ed.field_i = 0
		ed.weapon_lock_i = -1
		DebugLogFile(" Activate Weapon Slots Editor")		
	EndMethod

	Method Update( ed:TEditor, data:TData, sprite:TSprite )
		If Not data.ship.center Then Return
		'get input
		Select EventID()
		Case EVENT_MOUSEDOWN, EVENT_MOUSEUP, EVENT_MOUSEMOVE
			sprite.get_img_xy( MouseX, MouseY, img_x, img_y )
			'locate nearest entity
			ni = data.find_nearest_weapon_slot( img_x, img_y )
			Select ModKeyAndMouseKey
			Case 16 '(MODIFIER_LMOUSE)
				'set angle
				Select EventID()
				Case EVENT_MOUSEDOWN
					ed.weapon_lock_i = ni
					data.set_weapon_slot_direction( ed.weapon_lock_i, img_x, img_y, ed.bounds_symmetrical )
				Case EVENT_MOUSEMOVE
					data.set_weapon_slot_direction( ed.weapon_lock_i, img_x, img_y, ed.bounds_symmetrical )
				Case EVENT_MOUSEUP
					ed.weapon_lock_i = - 1
					data.update()
				EndSelect
			Case 17 '(MODIFIER_SHIFT|MODIFIER_LMOUSE)
				'add new
				If EventID() = EVENT_MOUSEDOWN	
					' copy nearest
					If ni <> - 1 Then source_weapon = data.ship.weaponSlots[ni] Else source_weapon = New TStarfarerShipWeapon
					'add new engine slot
					data.add_weapon_slot( img_x, img_y, source_weapon )
					If ( ed.bounds_symmetrical ) Then data.add_weapon_slot( img_x, img_y, source_weapon, True )
					data.hold_snapshot(True)
					data.update()
					data.update_variant_enforce_hull_compatibility( ed )
					data.update_variant()	
					data.hold_snapshot(False)					
				EndIf
			Case 18 '(MODIFIER_CONTROL|MODIFIER_LMOUSE)
				'set location
				Select EventID()
				Case EVENT_MOUSEDOWN
					ed.weapon_lock_i = ni
					data.set_weapon_slot_location( ed.weapon_lock_i, img_x, img_y, ed.bounds_symmetrical )
				Case EVENT_MOUSEMOVE
					data.set_weapon_slot_location( ed.weapon_lock_i, img_x, img_y, ed.bounds_symmetrical )
				Case EVENT_MOUSEUP
					ed.weapon_lock_i = - 1
					data.update()
				EndSelect
			Case 20 '(MODIFIER_ALT|MODIFIER_LMOUSE)
				'set size
				Select EventID()
				Case EVENT_MOUSEDOWN
					ed.weapon_lock_i  = ni
					data.set_weapon_slot_angular_range( ed.weapon_lock_i, img_x, img_y, ed.bounds_symmetrical )
				Case EVENT_MOUSEMOVE
					data.set_weapon_slot_angular_range( ed.weapon_lock_i, img_x, img_y, ed.bounds_symmetrical )
				Case EVENT_MOUSEUP
					ed.weapon_lock_i  = - 1
					data.update()
				EndSelect
			Case 38 '(MODIFIER_CONTROL|MODIFIER_ALT|MODIFIER_RMOUSE)
				'dragging everything
				If data.ship.engineSlots.length
					Select EventID()
					Case EVENT_MOUSEDOWN
						'drag start
						ed.last_img_x = img_x
						ed.last_img_y = img_y
					Case EVENT_MOUSEMOVE
						'dragging
						For Local i% = 0 Until data.ship.weaponSlots.length
							weapon = data.ship.weaponSlots[i]
							If Not weapon.is_launch_bay()
								weapon.locations[0] :+ img_x - ed.last_img_x
								weapon.locations[1] :- img_y - ed.last_img_y
							EndIf
						Next
						ed.last_img_x = img_x
						ed.last_img_y = img_y
					Case EVENT_MOUSEUP
						data.update()
					EndSelect
				EndIf
			End Select
		Case EVENT_GADGETACTION, EVENT_MENUACTION
			Select EventSource()
			Case functionMenu[4]
				data.hold_snapshot(True)
				data.remove_weapon_slot( ni, ed.bounds_symmetrical )
				data.update()
				data.update_variant_enforce_hull_compatibility( ed )
				data.update_variant()
				data.hold_snapshot(False)
			EndSelect
		EndSelect
	EndMethod

	Method Draw( ed:TEditor, data:TData, sprite:TSprite ) 
		If Not data.ship.center Then Return
		'get input
		sprite.get_img_xy( MouseX, MouseY, img_x, img_y )
		'screen position of coordinate to be potentially added
		x = sprite.sx + img_x * sprite.scale
		y = sprite.sy + img_y * sprite.scale
		'locate nearest entity
		ni = data.find_nearest_weapon_slot( img_x, img_y )
		If ed.weapon_lock_i <> - 1 Then ni = ed.weapon_lock_i
		'draw pointers
		SetRotation( 0 )
		SetScale( 1, 1 )
		SetAlpha( 1 )
		For Local i% = 0 Until data.ship.weaponSlots.Length
			If data.ship.weaponSlots[i].is_launch_bay()
				Continue 'skip these
			EndIf
			weapon = data.ship.weaponSlots[i]
			wx = sprite.sx + (weapon.locations[0] + data.ship.center[1]) * sprite.scale
			wy = sprite.sy + ( - weapon.locations[1] + data.ship.center[0]) * sprite.scale
			draw_weapon_mount( wx, wy, weapon.angle, weapon.arc, i = ni )
		Next
		SetRotation( 0 )
		SetScale( 1, 1 )
		SetAlpha( 1 )
		'ghost preview
		If ModKeyAndMouseKey = 1
			SetAlpha( 0.4 )
			angle = 0
			arc = 0
			If ni <> -1
				weapon = data.ship.weaponSlots[ni]
				angle = weapon.angle
				arc = weapon.arc
			EndIf
			draw_weapon_mount( x, y, angle, arc, FALSE )
			If ed.bounds_symmetrical 'reflected twin
				wyr = img_y - data.ship.center[0] 'simulating TData math
				angle = -angle
				xr = x
				yr = sprite.sy + (-wyr + data.ship.center[0])*sprite.scale
				draw_weapon_mount( xr, yr, angle, arc, FALSE )
			EndIf
			SetAlpha( 1 )
		EndIf
		'mouse crosshairs
		draw_crosshairs( x, y, 16 )
		'mouse text output
		img_x :- data.ship.center[1]
		img_y :- data.ship.center[0]
		If ni <> - 1 And data.ship.weaponSlots Then weapon = data.ship.weaponSlots[ni]
		If ModKeyAndMouseKey = 1 Or ModKeyAndMouseKey = 17
			mouse_str :+ coord_string( img_x, -img_y )+"~n"
		ElseIf ModKeyAndMouseKey = 2 Or ModKeyAndMouseKey = 18
			If weapon
				mouse_str :+ coord_string( weapon.locations[0], weapon.locations[1] ) + "~n"
			Else
				mouse_str :+ coord_string( img_x, - img_y ) + "~n"
			EndIf
		ElseIf ModKeyAndMouseKey = 4 Or ModKeyAndMouseKey = 20
			If weapon
				mouse_str :+ json.FormatDouble(weapon.arc,2)+Chr($00B0)+" (arc)~n"
			EndIf
		Else If ModKeyAndMouseKey = 0 Or ModKeyAndMouseKey = 16
			If weapon
				mouse_str :+ coord_string( weapon.locations[0], weapon.locations[1] ) + "~n" + json.FormatDouble(weapon.angle, 2) + Chr($00B0) + "~n"
			EndIf
		EndIf
		SetAlpha( 1 )
	EndMethod

	Method Load( ed:TEditor, data:TData, sprite:TSprite )
	EndMethod
	
	Method Save( ed:TEditor, data:TData, sprite:TSprite )
	EndMethod

EndType

