'-----------------------

Function modal_update_set_collision_radius( ed:TEditor, data:TData, sprite:TSprite )
	If Not data.ship.center Then Return
	If MouseHit( 1 )
		'get input
		Local img_x#, img_y#
		sprite.get_img_xy( MouseX, MouseY, img_x, img_y )
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


