
Type TModalLaunchBays Extends TSubroutine
	
	Field n_LB:TStarfarerShipWeapon 'nearest launch bay location's weapon object
	Field n_LB_i% 'index of launch bay in data
	Field n_LB_loc_i% 'nearest launch bay's location offset in the weapon object's location array
	Field n_LB_x%, n_LB_y%
	Field n_dist# 'distance to current nearest to compare against others
	Field img_x#, img_y# 'location of mouse cursor on image, relative to rotated image's top left
	Field weapon:TStarfarerShipWeapon
	'Field LB_i% 'index of current weapon/launchbay
	Field L_dist# 'distance to selected launch bay
	Field Lx%, Ly% 'screen position of selected launch bay port
	Field selected_launch_bay_index%
	Field launch_bay_count%

	Method Activate( ed:TEditor, data:TData, sprite:TSprite ) 'mode is now active and has control
		ed.last_mode = ed.mode
		ed.mode = "launch_bays"
		ed.field_i = 0
		n_LB = Null
		n_LB_loc_i = - 1
		selected_launch_bay_index = - 1
		sprite.get_img_xy( MouseX, MouseY, img_x, img_y )
		_find_nearest_launch_bay(img_x, img_y, data, sprite, n_LB, n_LB_i, n_LB_loc_i, n_LB_x, n_LB_y, selected_launch_bay_index)
		DebugLogFile(" Activate Launch Bay Editor")
	EndMethod

	Method Update( ed:TEditor, data:TData, sprite:TSprite )
		If Not data.ship.center Then Return		
		sprite.get_img_xy( MouseX, MouseY, img_x, img_y )
		If (ModKeyAndMouseKey & 1) = 0 Then _find_nearest_launch_bay(img_x, img_y, data, sprite, n_LB, n_LB_i, n_LB_loc_i, n_LB_x, n_LB_y, selected_launch_bay_index)
		'get input		
		Select EventID()
		Case EVENT_MOUSEDOWN, EVENT_MOUSEMOVE, EVENT_MOUSEUP
			'prepare some data
			Select ModKeyAndMouseKey
			Case 16 '(MODIFIER_LMOUSE)
				'daragging nearest launch port
				If n_LB_loc_i <> - 1
					data.set_launch_bay_port_location( n_LB_i, n_LB_loc_i, img_x, img_y, ed.bounds_symmetrical )
					If EventData() = EVENT_MOUSEUP Then data.update()
				endif
			Case 17 '(MODIFIER_SHIFT|MODIFIER_LMOUSE)
				'Add new launch port to the nearest bay
				If EventID() = EVENT_MOUSEDOWN ' only add one when click
					data.add_launch_bay_port( img_x, img_y, selected_launch_bay_index, ed.bounds_symmetrical )
					data.update()
				EndIf
			Case 18 '(MODIFIER_CONTROL|MODIFIER_LMOUSE)
				'Add new launch bay
				If EventID() = EVENT_MOUSEDOWN ' only add one when click
					data.add_launch_bay_port( img_x, img_y, - 1, ed.bounds_symmetrical )
					data.update()
				EndIf
			Case 38 '(MODIFIER_CONTROL|MODIFIER_ALT|MODIFIER_RMOUSE)
				'dragging everything
				If n_LB_loc_i <> - 1
					Select EventID()					
					Case EVENT_MOUSEDOWN ' only run onec when click
						ed.last_img_x = img_x
						ed.last_img_y = img_y
					Case EVENT_MOUSEMOVE
						If data.ship.weaponSlots
							For Local LB_i% = 0 Until data.ship.weaponSlots.length
								weapon = data.ship.weaponSlots[LB_i]
								If weapon.is_launch_bay()
									For Local i% = 0 Until weapon.locations.length Step 2
										weapon.locations[i] :+ img_x - ed.last_img_x
										weapon.locations[i+1] :- img_y - ed.last_img_y
									Next
								EndIf
							Next
						EndIf
					Case EVENT_MOUSEUP
						data.update()
					EndSelect
				EndIf
				ed.last_img_x = img_x
				ed.last_img_y = img_y
			End Select
		Case EVENT_GADGETACTION, EVENT_MENUACTION
			Select EventSource()
			Case functionMenu[4]
					data.remove_launch_bay_port( n_LB_i, n_LB_loc_i, ed.bounds_symmetrical )
					data.update()
			EndSelect
		EndSelect
	EndMethod

	Method Draw( ed:TEditor, data:TData, sprite:TSprite )
		'draw lasso to nearest
		'(if not dragging and there is at least one existing launch bay port)
		If n_LB And Not (ModKeyAndMouseKey = 16 Or ModKeyAndMouseKey = 38)
			Local x# = sprite.sx + img_x * sprite.scale
			Local y# = sprite.sy + img_y * sprite.scale
			Local LBx# = sprite.sx + n_LB_x * sprite.scale
			Local LBy# = sprite.sy + n_LB_y * sprite.scale			
			setrotation( 0 )
			setscale( 1, 1 )
			setcolor( 0,0,0 )
			SetLineWidth( 4 )
			SetAlpha( 0.3 )
			DrawOval( LBx - 12, LBy - 12, 24, 24 )
			setalpha( 0.4 )
			DrawLine( x, y, LBx, LBy )
			SetColor( 255, 255, 255 )
			setlinewidth( 2 )
			setalpha( 0.3 )
			DrawOval( LBx - 10, LBy - 10, 20, 20 )
			SetAlpha( 0.4 )
			DrawLine( x, y, LBx, LBy )
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
						DrawImage( ed.ico_exit, Lxy[i] - ox, Lxy[i + 1] - oy )
						draw_string( "" + L_i, Lxy[i] + ox, Lxy[i + 1] + oy,,, 0.0, 0.5 )
					Next
					L_i :+ 1
				EndIf
			Next
		End If
		SetImageFont( FONT )
		weapon = data.get_launch_bay_by_contextual_index( selected_launch_bay_index )
		mouse_str = ""
		If ModKeyAndMouseKey & MODIFIER_SHIFT 'Shift down
			If weapon Then 	mouse_str :+ LocalizeString("{{mouse_str_launchbay_addnewport}}") + "[" + weapon.id + "]" Else mouse_str :+ LocalizeString("{{mouse_str_launchbay_addnewbay}}")
		Else If ModKeyAndMouseKey & MODIFIER_CONTROL ' Crtl down
			mouse_str :+ LocalizeString("{{mouse_str_launchbay_addnewbay}}")
		Else
			If weapon Then mouse_str :+ LocalizeString("{{mouse_str_launchbay_idle}}") + "[" + weapon.id + "]"
		EndIf
	EndMethod

	Method Load( ed:TEditor, data:TData, sprite:TSprite )
	EndMethod
	
	Method Save( ed:TEditor, data:TData, sprite:TSprite )
	EndMethod

	Method _find_nearest_launch_bay (img_x#, img_y#, data:TData, sprite:TSprite, n_LB:TStarfarerShipWeapon Var, n_LB_i% Var, n_LB_loc_i% Var, n_LB_x% Var, n_LB_y% Var, selected_launch_bay_index% Var)
		n_LB = Null
		n_LB_loc_i = - 1
		Local n_dist#
		If data.ship.weaponSlots
			Local launch_bay_index% = - 1
			For Local i% = 0 Until data.ship.weaponSlots.length
				weapon = data.ship.weaponSlots[i]
				If weapon.is_launch_bay()
					launch_bay_index :+ 1
					For Local j% = 0 Until weapon.locations.length Step 2
						Local Lx# = weapon.locations[j + 0] + data.ship.center[1]
						Local LY# = - weapon.locations[j + 1] + data.ship.center[0]
'						y = sprite.sy + img_y * sprite.scale
						L_dist = calc_distance( img_x, img_y, Lx, LY )
						If L_dist < n_dist Or n_LB_loc_i = - 1
							n_LB = weapon;
							n_LB_i = i
							n_LB_loc_i = j
							n_LB_x = Lx
							n_LB_y = LY
							n_dist = L_dist
							selected_launch_bay_index = launch_bay_index
						EndIf
					Next
				EndIf
			Next
		EndIf
	End Method	
EndType

