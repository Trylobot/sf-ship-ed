'-----------------------

Function modal_update_set_shield_radius( ed:TEditor, data:TData, sprite:TSprite )
	If Not data.ship.shieldCenter Then Return
	If MouseHit( 1 )
		'get input
		Local img_x#, img_y#
		sprite.get_img_xy( MouseX, MouseY, img_x, img_y )
		data.ship.shieldRadius = calc_distance( data.ship.center[1] + data.ship.shieldCenter[0], data.ship.center[0] - data.ship.shieldCenter[1], img_x, img_y )
		data.update()
		'next mode
		ed.mode = "preview_all"
	End If
End Function

Function modal_draw_set_shield_radius( data:TData, sprite:TSprite ) 
	SetRotation( 0 )
	SetScale( 1, 1 )
	SetAlpha( 0.10 )
	SetColor( 255, 255, 255)
	'draw current shield radius sized by cursor
	draw_shield_circle( data, sprite, FALSE, TRUE )
	'draw current collision radius centered at existing center
	draw_collision_circle( data, sprite, FALSE, FALSE )
	SetAlpha( 1 )
	'draw shield crosshair centered at existing shield center
	draw_shield_center_point( data, sprite, FALSE )
	'draw collision crosshair centered at existing center
	draw_collision_center_point( data, sprite, FALSE )
End Function

Function draw_shield_circle( data:TData, sprite:TSprite, position_at_cursor%=False, use_distance_to_cursor%=False )
	If data.ship.center And data.ship.shieldCenter
		Local img_x#, img_y#
		sprite.get_img_xy( MouseX, MouseY, img_x, img_y )
		Local csx%, csy%
		Local r#, rs#
		If Not position_at_cursor
			'use existing position to draw crosshair
			csx = sprite.sx + data.ship.center[1]*sprite.Scale + data.ship.shieldCenter[0]*sprite.Scale
			csy = sprite.sy + data.ship.center[0]*sprite.Scale - data.ship.shieldCenter[1]*sprite.Scale
		Else
			'draw at cursor instead
			csx = sprite.sx + img_x*sprite.scale
			csy = sprite.sy + img_y*sprite.scale
		EndIf
		If Not use_distance_to_cursor
			'use existing radius to draw circle
			r = data.ship.shieldRadius
		Else
			'use distance from existing center to cursor as radius instead
			r = calc_distance( data.ship.center[1] + data.ship.shieldCenter[0], data.ship.center[0] - data.ship.shieldCenter[1], img_x, img_y )
		EndIf
		rs = r*sprite.scale
		DrawOval( csx - rs, csy - rs, 2*rs, 2*rs )
	EndIf
EndFunction


