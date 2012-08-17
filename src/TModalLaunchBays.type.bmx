
Type TModalLaunchBays Extends TSubroutine
	
	Global dragging% 'whether a drag is in progress
	Global n_LB:TStarfarerShipWeapon 'nearest launch bay location's weapon object
	Global n_LB_i% 'index of launch bay in data
	Global n_LB_loc_i% 'nearest launch bay's location offset in the weapon object's location array
	Global n_LB_x%, n_LB_y%
	Global n_dist# 'distance to current nearest to compare against others
	Global img_x#, img_y# 'location of mouse cursor on image, relative to rotated image's top left
	Global mx%, my% 'screen position of coordinate to be potentially added
	Global weapon:TStarfarerShipWeapon
	Global LB_i% 'index of current weapon/launchbay
	Global i% 'index of current location in current weapon/launchbay
	Global L_dist# 'distance to selected launch bay
	Global Lx%, Ly% 'screen position of selected launch bay port
	Global selected_launch_bay_index%
	Global launch_bay_count%

	Function Activate( ed:TEditor, data:TData, sprite:TSprite ) 'mode is now active and has control
		ed.last_mode = ed.mode
		ed.mode = "launch_bays"
		ed.field_i = 0

		dragging = false
		n_LB = null
		n_LB_loc_i = -1
	EndFunction

	Function Update( ed:TEditor, data:TData, sprite:TSprite )
		If Not data.ship.center Then Return
		sprite.get_img_xy( MouseX(), MouseY(), img_x, img_y )
		mx = sprite.sx + img_x*sprite.scale 
		my = sprite.sy + img_y*sprite.scale

		'determine nearest if not already dragging one
		If Not dragging
			n_LB = null
			n_LB_loc_i = -1
			If data.ship.weaponSlots
				For LB_i = 0 until data.ship.weaponSlots.length
					weapon = data.ship.weaponSlots[LB_i]
					If weapon.is_launch_bay()
						For i = 0 Until weapon.locations.length Step 2
							Lx = sprite.sx + ( weapon.locations[i+0] + data.ship.center[1])*sprite.Scale
							Ly = sprite.sy + (-weapon.locations[i+1] + data.ship.center[0])*sprite.Scale
							L_dist = calc_distance( mx, my, Lx, Ly )
							If L_dist < n_dist Or n_LB_loc_i = -1
								n_LB = weapon;
								n_LB_i = LB_i
								n_LB_loc_i = i
								n_LB_x = Lx
								n_LB_y = Ly
								n_dist = L_dist
							EndIf
						Next
					EndIf
				Next
			EndIf
		EndIf
		'update
		launch_bay_count = data.launch_bay_count()
		If Not ed.mouse_1
			If MouseDown( MOUSE_LEFT ) 'mouse up --> mouse down
				If SHIFT
					data.add_launch_bay_port( img_x,img_y, selected_launch_bay_index, ed.bounds_symmetrical )
					data.update()
					launch_bay_count = data.launch_bay_count()
					If selected_launch_bay_index = -1 Or selected_launch_bay_index >= launch_bay_count
						selected_launch_bay_index = launch_bay_count - 1
					EndIf
				Else If CONTROL
				Else If ALT
				Else 'no modifiers
					dragging = true
				EndIf
				ed.mouse_1 = true
			EndIf
		Else 'ed.mouse_1
			If Not MouseDown( MOUSE_LEFT ) 'mouse down --> mouse up
				dragging = false
				n_LB = null
				n_LB_loc_i = -1
				ed.mouse_1 = false
			EndIf
		EndIf
		If CONTROL And ALT
			If ed.mouse_2 'dragging
				If data.ship.weaponSlots
					For LB_i = 0 until data.ship.weaponSlots.length
						weapon = data.ship.weaponSlots[LB_i]
						If weapon.is_launch_bay()
							For i = 0 Until weapon.locations.length Step 2
								weapon.locations[i]   :+ img_x - ed.last_img_x
								weapon.locations[i+1] :- img_y - ed.last_img_y
							Next
							data.update()
						EndIf
					Next
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
		If MouseHit( MOUSE_RIGHT )
			'right click
			selected_launch_bay_index :+ 1
		EndIf
		If KeyHit( KEY_BACKSPACE ) And Not dragging
			data.remove_launch_bay_port( n_LB_i,n_LB_loc_i, ed.bounds_symmetrical )
			data.update()
		EndIf
		If dragging And n_LB <> null
			data.set_launch_bay_port_location( n_LB_i,n_LB_loc_i, img_x,img_y, ed.bounds_symmetrical )
			data.update()
		EndIf
		If selected_launch_bay_index < 0 Or selected_launch_bay_index >= launch_bay_count
			selected_launch_bay_index = -1
		EndIf
		mouse_str = ""
		weapon = data.get_launch_bay_by_contextual_index( selected_launch_bay_index )
		If weapon
			mouse_str :+ "Launch Bay ["+weapon.id+"]"
		Else
			mouse_str :+ "Add New Launch Bay"
		EndIf
	EndFunction

	Function Draw( ed:TEditor, data:TData, sprite:TSprite )
		'draw lasso to nearest
		'(if not dragging and there is at least one existing launch bay port)
		If Not dragging And n_LB <> null
			setrotation( 0 )
			setscale( 1, 1 )
			setcolor( 0,0,0 )
			setlinewidth( 4 )
			setalpha( 0.3 )
			drawoval( n_LB_x-12, n_LB_y-12, 24, 24 )
			setalpha( 0.4 )
			drawline( mx, my, n_LB_x, n_LB_y )
			setcolor( 255, 255, 255 )
			setlinewidth( 2 )
			setalpha( 0.3 )
			drawoval( n_LB_x-10, n_LB_y-10, 20, 20 )
			setalpha( 0.4 )
			drawline( mx, my, n_LB_x, n_LB_y )
		EndIf
		'draw all launch bay ports
		SetImageFont( DATA_FONT )
		Local L_i% = 1
		If data.ship.weaponSlots
			For Local weapon:TStarfarerShipWeapon = EachIn data.ship.weaponSlots
				If weapon.is_launch_bay()
					Local Lxy%[weapon.locations.length]
					For Local i% = 0 Until weapon.locations.length Step 2
						Lxy[i] = sprite.sx + (weapon.locations[i] + data.ship.center[1])*sprite.Scale
						Lxy[i+1] = sprite.sy + (-weapon.locations[i+1] + data.ship.center[0])*sprite.scale
					Next
					SetRotation( 0 )
					SetScale( 1, 1 )
					SetColor( 255, 255, 255 )
					SetAlpha( 1.0 )
					Local ox% = ed.ico_exit.width / 2
					Local oy% = ed.ico_exit.height / 2
					For Local i% = 0 Until Lxy.length Step 2
						DrawImage( ed.ico_exit, Lxy[i]-ox, Lxy[i+1]-oy )
						draw_string( ""+L_i, Lxy[i]+ox, Lxy[i+1]+oy,,, 0.0,0.5 )
					Next
					L_i :+ 1
				EndIf
			Next
		End If
		SetImageFont( FONT )
	EndFunction

EndType

