Type TModalSetShipCenter Extends TSubroutine
	
	Method Activate( ed:TEditor, data:TData, sprite:TSprite )
		ed.last_mode = ed.mode
		ed.mode = "center"
		ed.field_i = 0
		DebugLogFile(" Activate Ship Center Editor")
	EndMethod
	
	Method Deactivate( ed:TEditor, data:TData, sprite:TSprite )
	EndMethod
	
	Method Update( ed:TEditor, data:TData, sprite:TSprite )
		'get input
		Select EventID()
		Case EVENT_MOUSEDOWN, EVENT_MOUSEUP, EVENT_MOUSEMOVE
			Select EventID()
			Case EVENT_MOUSEDOWN
				Select EventData()
				Case MOUSE_LEFT
					If CONTROL
					'set collision radius
						If Not data.ship.center Then Return
						Local img_x#, img_y#
						sprite.get_img_xy( MouseX, MouseY, img_x, img_y )
						data.ship.collisionRadius = calc_distance( data.ship.center[1], data.ship.center[0], img_x, img_y )
						data.update()
					Else
					'set mass center
						Local img_x#, img_y#						
						sprite.get_img_xy( MouseX, MouseY, img_x, img_y )
						Local x#, y#
						'seems like we may have some other things needs to move
						If data.ship.center
							x = data.ship.center[1] - img_x
							y = data.ship.center[0] - img_y
							If data.ship.shieldCenter
								data.ship.shieldCenter[0]:+ x
								data.ship.shieldCenter[1]:- y
							EndIf
							If data.ship.bounds
								For Local i% = 0 Until data.ship.bounds.length Step 2
								data.ship.bounds[i]   :+ x
								data.ship.bounds[i + 1] :- y
								Next
							EndIf
							If data.ship.engineSlots
								For Local i% = 0 Until data.ship.engineSlots.length
								data.ship.engineSlots[i].location[0] :+ x
								data.ship.engineSlots[i].location[1] :- y
								Next
							EndIf
							If data.ship.weaponSlots
								For Local i% = 0 Until data.ship.weaponSlots.length
									For Local j% = 0 Until data.ship.weaponSlots[i].locations.length Step 2
										data.ship.weaponSlots[i].locations[j] :+ x
										data.ship.weaponSlots[i].locations[j + 1] :- y
									Next
								Next
							EndIf
						EndIf
						data.set_center( img_x, img_y )
						data.update()
					EndIf
				End Select
			EndSelect
		Case EVENT_GADGETACTION, EVENT_MENUACTION
		Default
		End Select
	EndMethod
	
	Method Draw( ed:TEditor, data:TData, sprite:TSprite )
		If CONTROL
			SetRotation( 0 )
			SetScale( 1, 1 )
			SetAlpha( 0.15 )
			SetColor( 240, 230, 140)
			'draw collision radius
			draw_collision_circle( data, sprite, False, False )			
			'draw current collision radius sized to cursor distance from existing center
			draw_collision_circle( data, sprite, False, True )
			SetAlpha( 1 )
			'draw collision crosshair at existing center
			draw_collision_center_point( data, sprite, False )
		Else	
			If Not data.ship.center Then Return		
			SetRotation( 0 )
			SetScale( 1, 1 )
			SetAlpha( 0.15 )
			SetColor( 240,230,140)			
			'draw collision radius
			draw_collision_circle( data, sprite, False, False )	
			'draw current collision radius centered on cursor
			draw_collision_circle( data, sprite, True, False )
			SetAlpha( 1 )
			'draw collision crosshair at existing center
			draw_collision_center_point( data, sprite, False )
			'draw collision crosshair centered on cursor
			draw_collision_center_point( data, sprite, True )
		EndIf
	EndMethod
	
	Method Load( ed:TEditor, data:TData, sprite:TSprite )
	EndMethod
	
	Method Save( ed:TEditor, data:TData, sprite:TSprite )
	EndMethod
	
EndType
