'-----------------------

Function modal_update_set_weapon_slots( ed:TEditor, data:TData, sprite:TSprite )
	If Not data.ship.center Then Return
	'get input
	Local left_click% = MouseHit( 1 )
	Local img_x#, img_y#
	sprite.get_img_xy( MouseX(), MouseY(), img_x, img_y )
	'locate nearest entity
	Local ni% = data.find_nearest_weapon_slot( img_x, img_y )
	'process input
	If left_click And SHIFT 'add new weapon slot
		'copy nearest
		Local source_weapon:TStarfarerShipWeapon
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
				For Local LB_i% = 0 until data.ship.weaponSlots.length
					Local weapon:TStarfarerShipWeapon = data.ship.weaponSlots[LB_i]
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
End Function

Function modal_draw_set_weapon_slots( ed:TEditor, data:TData, sprite:TSprite ) 
	If Not data.ship.center Then Return
	'get input
	Local img_x#, img_y#
	sprite.get_img_xy( MouseX(), MouseY(), img_x, img_y )
	'locate nearest entity
	Local ni% = data.find_nearest_weapon_slot( img_x, img_y )
	If ed.weapon_lock_i <> -1
		ni = ed.weapon_lock_i
	End If
	'screen position of coordinate to be potentially added
	Local x% = sprite.sx + img_x*sprite.scale 
	Local y% = sprite.sy + img_y*sprite.scale
	'draw pointers
	Local weapon:TStarfarerShipWeapon, nearest% = false
	For Local i% = 0 Until data.ship.weaponSlots.Length
		If data.ship.weaponSlots[i].is_launch_bay()
			Continue 'skip these
		EndIf
		weapon = data.ship.weaponSlots[i]
		If ni = i
			nearest = True
		Else
			nearest = False
		EndIf
		Local wx% = sprite.sx + (weapon.locations[0] + data.ship.center[1])*sprite.Scale
		Local wy% = sprite.sy + (-weapon.locations[1] + data.ship.center[0])*sprite.Scale
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
		Local angle# = 0
		Local arc# = 0
		If ni <> -1
			weapon = data.ship.weaponSlots[ni]
			angle = weapon.angle
			arc = weapon.arc
		EndIf
		draw_weapon_mount( x, y, angle, arc, FALSE )
		If ed.bounds_symmetrical 'reflected twin
			Local wyr# = img_y - data.ship.center[0] 'simulating TData math
			angle = -angle
			Local xr% = x
			Local yr% = sprite.sy + (-wyr + data.ship.center[0])*sprite.scale
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
			mouse_str :+ FormatDouble(weapon.arc,2,FALSE)+Chr($00B0)+" (arc)~n"
		EndIf
	Else
		If weapon
			mouse_str :+ FormatDouble(weapon.angle,2,FALSE)+Chr($00B0)+"~n"
		EndIf
	EndIf
	SetAlpha( 1 )
End Function

Function draw_weapon_mount( x%, y%, rot#, arc#, em%=False, r%=12, l%=24, ra%=36 )
	Local a# = GetAlpha()
	'draw arc
	SetColor( 255, 255, 255 )
	SetAlpha( a*0.20 )
	DrawOval( x - ra, y - ra, 2*ra, 2*ra )
	SetAlpha( a*1.00 )
	draw_arc( x, y, ra, rot+(arc/2), rot-(arc/2), arc/2 ) '1 segment per 2 degrees, assuming ra=36
	'draw dot and pointer
	SetColor( 0, 0, 0 )
	DrawOval( x-r, y-r, 2*r, 2*r )
	SetLineWidth( 4 )
	DrawLine( x, y, x + (l + 1)*cos(rot), y - (l + 1)*sin(rot) )
	SetColor( 255, 255, 255 )
	DrawOval( x-(r-2), y-(r-2), 2*(r-2), 2*(r-2) )
	SetLineWidth( 2 )
	DrawLine( x, y, x + l*cos(rot), y - l*sin(rot) )
	SetColor( 0, 0, 0 )
	DrawOval( x-(r-4), y-(r-4), 2*(r-4), 2*(r-4) )
	'draw emphasis
	If em
		SetColor( 255, 255, 255 )
		DrawOval( x-(r-3), y-(r-3), 2*(r-3), 2*(r-3) )
	EndIf
	'cleanup
	SetLineWidth( 1 )
	SetAlpha( a )
End Function

