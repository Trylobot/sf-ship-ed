'-----------------------

Function modal_update_set_center( ed:TEditor, data:TData, sprite:TSprite )
	If MouseHit( 1 )
		'get input
		Local img_x#, img_y#
		sprite.get_img_xy( MouseX(), MouseY(), img_x, img_y )
		data.set_center( img_x, img_y )
		data.update()
		'next mode
		ed.mode = "collision_radius"
	End If
End Function

Function modal_draw_set_center( data:TData, sprite:TSprite )
	SetRotation( 0 )
	SetScale( 1, 1 )
	SetAlpha( 0.10 )
	SetColor( 255, 255, 255)
	'draw current shield radius as it exists
	draw_shield_circle( data, sprite, FALSE, FALSE )
	'draw current collision radius centered on cursor
	draw_collision_circle( data, sprite, TRUE, FALSE )
	SetAlpha( 1 )
	'draw shield crosshair
	draw_shield_center_point( data, sprite, FALSE )
	'draw collision crosshair centered on cursor
	draw_collision_center_point( data, sprite, TRUE )
End Function

Function draw_collision_center_point( data:TData, sprite:TSprite, position_at_cursor%=False )
	If data.ship.center
		Local img_x#, img_y#
		sprite.get_img_xy( MouseX(), MouseY(), img_x, img_y )
		Local cx%, cy%
		If Not position_at_cursor
			'use existing position to draw crosshair
			cx = sprite.sx + data.ship.center[1]*sprite.scale
			cy = sprite.sy + data.ship.center[0]*sprite.scale
		Else
			'draw at cursor instead
			cx = sprite.sx + img_x*sprite.scale
			cy = sprite.sy + img_y*sprite.scale
		EndIf
		draw_crosshairs( cx, cy, 8 )
		If Not position_at_cursor
			draw_string( coord_string( data.ship.center[0], data.ship.center[1] ), cx+5, cy+5 )
		Else
			draw_string( coord_string( img_y, img_x ), cx+5, cy+5 )
		EndIf
	EndIf
EndFunction


