'-----------------------

Function modal_update_set_collision_radius( ed:TEditor, data:TData, sprite:TSprite )
	If Not data.ship.center Then Return
	If MouseHit( 1 )
		'get input
		Local img_x#, img_y#
		sprite.get_img_xy( MouseX(), MouseY(), img_x, img_y )
		data.ship.collisionRadius = calc_distance( data.ship.center[1], data.ship.center[0], img_x, img_y )
		data.update()
		'next mode
		ed.mode = "preview_all"
	End If
End Function

Function modal_draw_set_collision_radius( data:TData, sprite:TSprite ) 
	SetRotation( 0 )
	SetScale( 1, 1 )
	SetAlpha( 0.10 )
	SetColor( 255, 255, 255)
	'draw current shield radius
	draw_shield_circle( data, sprite, FALSE, FALSE )
	'draw current collision radius sized to cursor distance from existing center
	draw_collision_circle( data, sprite, FALSE, TRUE )
	SetAlpha( 1 )
	'draw shield crosshair
	draw_shield_center_point( data, sprite, FALSE )
	'draw collision crosshair at existing center
	draw_collision_center_point( data, sprite, FALSE )
End Function

Function draw_collision_circle( data:TData, sprite:TSprite, position_at_cursor%=False, use_distance_to_cursor%=False )
	If data.ship.center
		Local img_x#, img_y#
		sprite.get_img_xy( MouseX(), MouseY(), img_x, img_y )
		Local cx%, cy%
		Local r#, rs#
		If Not position_at_cursor
			'use existing position to draw crosshair
			cx = sprite.sx + data.ship.center[1]*sprite.scale
			cy = sprite.sy + data.ship.center[0]*sprite.scale
		Else
			'draw at cursor instead
			cx = sprite.sx + img_x*sprite.scale
			cy = sprite.sy + img_y*sprite.scale
		EndIf
		If Not use_distance_to_cursor
			'use existing radius to draw circle
			r = data.ship.collisionRadius
		Else
			'use distance from existing center to cursor as radius instead
			r = calc_distance( data.ship.center[1], data.ship.center[0], img_x, img_y )
		EndIf
		rs = r*sprite.scale
		DrawOval( cx - rs, cy - rs, 2*rs, 2*rs )
	EndIf
EndFunction
