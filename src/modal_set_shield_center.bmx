'-----------------------

Function modal_update_set_shield_center( ed:TEditor, data:TData, sprite:TSprite )
	If MouseHit( 1 )
		'get input
		Local img_x#, img_y#
		sprite.get_img_xy( MouseX(), MouseY(), img_x, img_y )
		data.set_shield_center( img_x, img_y )
		data.update()
		'next mode
		ed.mode = "shield_radius"
	End If
End Function

Function modal_draw_set_shield_center( data:TData, sprite:TSprite )
	SetRotation( 0 )
	SetScale( 1, 1 )
	SetAlpha( 0.10 )
	SetColor( 255, 255, 255)
	'draw current shield radius, centered at cursor
	draw_shield_circle( data, sprite, TRUE, FALSE )
	'draw current collision radius centered at existing center
	draw_collision_circle( data, sprite, FALSE, FALSE )
	SetAlpha( 1 )
	'draw shield crosshair centered at cursor
	draw_shield_center_point( data, sprite, TRUE )
	'draw collision crosshair centered at existing center
	draw_collision_center_point( data, sprite, FALSE )
End Function

Function draw_shield_center_point( data:TData, sprite:TSprite, position_at_cursor%=False )
	If data.ship.center And data.ship.shieldCenter
		Local img_x#, img_y#
		sprite.get_img_xy( MouseX(), MouseY(), img_x, img_y )
		Local csx%, csy%
		If Not position_at_cursor
			'use existing position to draw crosshair
			csx = sprite.sx + data.ship.center[1]*sprite.Scale + data.ship.shieldCenter[0]*sprite.Scale
			csy = sprite.sy + data.ship.center[0]*sprite.Scale - data.ship.shieldCenter[1]*sprite.Scale
		Else
			'draw at cursor instead
			csx = sprite.sx + img_x*sprite.scale
			csy = sprite.sy + img_y*sprite.scale
		EndIf
		draw_crosshairs( csx, csy, 6, TRUE )
		If Not position_at_cursor
			draw_string( coord_string( data.ship.shieldCenter[0], data.ship.shieldCenter[1] ), csx+5, csy+5 )
		Else
			draw_string( coord_string( img_x - data.ship.center[1], -(img_y + data.ship.center[0]) ), csx+5, csy+5 )
		EndIf
	EndIf
EndFunction


