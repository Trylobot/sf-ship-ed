
Type TModalSetWeaponSlots Extends TSubroutine
	Field i%
	Field img_x#,img_y#
	Field x%,y%
	Field wx%,wy%
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
	EndMethod

	Method Update( ed:TEditor, data:TData, sprite:TSprite )
		If Not data.ship.center Then Return
		'get input
		left_click = MouseHit( 1 )
		sprite.get_img_xy( MouseX(), MouseY(), img_x, img_y )
		'locate nearest entity
		ni = data.find_nearest_weapon_slot( img_x, img_y )
		'process input
		If left_click And SHIFT 'add new weapon slot
			'copy nearest
			If ni <> -1
				source_weapon = data.ship.weaponSlots[ni]
			End If
			'TODO: handle weapon slots with multiple locations
			data.add_weapon_slot( img_x, img_y, source_weapon )
			if( ed.bounds_symmetrical )
				data.add_weapon_slot( img_x, img_y, source_weapon, TRUE )
			endif
			data.Update()
		End If
		'mouse locks and methods
		If MouseDown( 1 )
			If Not ed.mouse_1
				ed.weapon_lock_i = ni
			End If
			If SHIFT
				'nothin, already does add new
			Else If CONTROL
				data.set_weapon_slot_location( ed.weapon_lock_i, img_x, img_y, ed.bounds_symmetrical )
				data.update()
			Else If ALT
				data.set_weapon_slot_angular_range( ed.weapon_lock_i, img_x, img_y, ed.bounds_symmetrical )
				data.update()
			Else 'no modifiers
				data.set_weapon_slot_direction( ed.weapon_lock_i, img_x, img_y, ed.bounds_symmetrical )
				data.update()
			End If
			ed.mouse_1 = true
		Else
			ed.weapon_lock_i = -1
			ed.mouse_1 = false
		End If
		If CONTROL And ALT
			If ed.mouse_2 'dragging
				If data.ship.weaponSlots
					For LB_i = 0 until data.ship.weaponSlots.length
						weapon = data.ship.weaponSlots[LB_i]
						If Not weapon.is_launch_bay()
							weapon.locations[0] :+ img_x - ed.last_img_x
							weapon.locations[1] :- img_y - ed.last_img_y
						EndIf
					Next
					data.update()
				EndIf
				ed.last_img_x = img_x
				ed.last_img_y = img_y
			End If
			If MouseDown( 2 )
				If Not ed.mouse_2 'drag start
					ed.last_img_x = img_x
					ed.last_img_y = img_y
				End If
				ed.mouse_2 = True
			Else
				ed.mouse_2 = False
			End If
		End If
		If KeyHit( KEY_BACKSPACE )
			data.remove_weapon_slot( ni, ed.bounds_symmetrical )
			data.update()
			data.update_variant()
		End If
	EndMethod

	Method Draw( ed:TEditor, data:TData, sprite:TSprite ) 
		If Not data.ship.center Then Return
		'get input
		sprite.get_img_xy( MouseX(), MouseY(), img_x, img_y )
		'locate nearest entity
		ni = data.find_nearest_weapon_slot( img_x, img_y )
		If ed.weapon_lock_i <> -1
			ni = ed.weapon_lock_i
		End If
		'screen position of coordinate to be potentially added
		x = sprite.sx + img_x*sprite.scale 
		y = sprite.sy + img_y*sprite.scale
		'draw pointers
		nearest = false
		For i = 0 Until data.ship.weaponSlots.Length
			If data.ship.weaponSlots[i].is_launch_bay()
				Continue 'skip these
			EndIf
			weapon = data.ship.weaponSlots[i]
			If ni = i
				nearest = True
			Else
				nearest = False
			EndIf
			wx = sprite.sx + (weapon.locations[0] + data.ship.center[1])*sprite.Scale
			wy = sprite.sy + (-weapon.locations[1] + data.ship.center[0])*sprite.Scale
			SetRotation( 0 )
			SetScale( 1, 1 )
			SetAlpha( 1 )
			draw_weapon_mount( wx, wy, weapon.angle, weapon.arc, nearest )
		Next
		SetRotation( 0 )
		SetScale( 1, 1 )
		SetAlpha( 1 )
		'ghost preview
		If SHIFT And Not CONTROL And Not ALT
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
		If ni <> -1
			weapon = data.ship.weaponSlots[ni]
		EndIf
		If SHIFT
			mouse_str :+ coord_string( img_x, -img_y )+"~n"
		ElseIf CONTROL
			If weapon
				mouse_str :+ coord_string( weapon.locations[0], weapon.locations[1] )+"~n"
			Else
				mouse_str :+ coord_string( img_x, -img_y )+"~n"
			EndIf
		ElseIf ALT
			If weapon
				mouse_str :+ json.FormatDouble(weapon.arc,2)+Chr($00B0)+" (arc)~n"
			EndIf
		Else
			If weapon
				mouse_str :+ json.FormatDouble(weapon.angle,2)+Chr($00B0)+"~n"
			EndIf
		EndIf
		SetAlpha( 1 )
	EndMethod

	Method Load( ed:TEditor, data:TData, sprite:TSprite )
	EndMethod
	
	Method Save( ed:TEditor, data:TData, sprite:TSprite )
	EndMethod

EndType

