Type TModalSetShieldCenter Extends TSubroutine
	
	Method Activate( ed:TEditor, data:TData, sprite:TSprite )
		ed.last_mode = ed.mode
		ed.mode = "shield_center"
		ed.field_i = 0
		DebugLogFile(" Activate Shield Editor")
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
						If Not data.ship.center And Not data.ship.shieldCenter Then Return
						'set shield radius
						Local img_x#, img_y#
						sprite.get_img_xy( MouseX, MouseY, img_x, img_y )
						data.ship.shieldRadius = calc_distance( data.ship.center[1] + data.ship.shieldCenter[0], data.ship.center[0] - data.ship.shieldCenter[1], img_x, img_y )
						data.update()
					Else
						'set shield center
						Local img_x#, img_y#
						sprite.get_img_xy( MouseX, MouseY, img_x, img_y )
						data.set_shield_center( img_x, img_y )
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
			'draw current collision radius centered at existing center
			draw_collision_circle( data, sprite, False, False )
			SetColor( 175, 215, 230 )
			'draw current shield radius centered at existing center
			draw_shield_circle( data, sprite, False, False )
			'draw current shield radius sized by cursor
			draw_shield_circle( data, sprite, False, True )
			SetAlpha( 1 )
			'draw shield crosshair centered at existing shield center
			draw_shield_center_point( data, sprite, False )
			'draw collision crosshair centered at existing center
			draw_collision_center_point( data, sprite, False )
		Else	
			If Not data.ship.center Then Return
			SetRotation( 0 )
			SetScale( 1, 1 )
			SetAlpha( 0.15 )
			SetColor( 240, 230, 140)
			'draw current collision radius centered at existing center
			draw_collision_circle( data, sprite, False, False )
			SetColor( 175, 215, 230 )
			'draw current shield radius centered at existing center
			draw_shield_circle( data, sprite, False, False )
			'draw current shield radius, centered at cursor
			draw_shield_circle( data, sprite, True, False )
			SetAlpha( 1 )
			'draw shield crosshair centered at existing shield center
			draw_shield_center_point( data, sprite, False )
			'draw shield crosshair centered at cursor
			draw_shield_center_point( data, sprite, True )			
			'draw collision crosshair centered at existing center
			draw_collision_center_point( data, sprite, False )
		EndIf
	EndMethod
	
	Method Load( ed:TEditor, data:TData, sprite:TSprite )
	EndMethod
	
	Method Save( ed:TEditor, data:TData, sprite:TSprite )
	EndMethod
	
EndType
