'-----------------------

Function modal_update_set_center( ed:TEditor, data:TData, sprite:TSprite )
	If MouseHit( 1 )
		'get input
		Local img_x#, img_y#
		sprite.get_img_xy( MouseX, MouseY, img_x, img_y )
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




