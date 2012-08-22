
Type TModalSetEngineSlots Extends TSubroutine
	Field i%
	Field left_click%
	Field img_x#,img_y#
	Field x%,y%
	Field wx%,wy%
	Field xr%,yr%
	Field ni%
	Field nearest%
	Field length#
	Field width#
	Field angle#
	Field wyr#
	Field source_engine:TStarfarerShipEngine
	Field engine:TStarfarerShipEngine

	Method Activate( ed:TEditor, data:TData, sprite:TSprite )
		ed.last_mode = ed.mode
		ed.mode = "engine_slots"
		ed.field_i = 0
	EndMethod

	Method Update( ed:TEditor, data:TData, sprite:TSprite )
		If Not data.ship.center Then Return
		'get input
		left_click = MouseHit( 1 )
		sprite.get_img_xy( MouseX(), MouseY(), img_x, img_y )
		'locate nearest entity
		ni = data.find_nearest_engine( img_x, img_y )
		'process input
		If left_click And SHIFT
			'copy nearest
			If ni <> -1
				source_engine = data.ship.engineSlots[ni]
			End If
			'add new engine slot
			data.add_engine( img_x, img_y, source_engine )
			if( ed.bounds_symmetrical )
				data.add_engine( img_x, img_y, source_engine, true )
			endif
			data.update()
		End If
		'mouse locks and methods
		If MouseDown( 1 )
			If Not ed.mouse_1
				ed.engine_lock_i = ni
			End If
			If SHIFT
				'nothing
			Else If CONTROL
				data.set_engine_location( ed.engine_lock_i, img_x, img_y, ed.bounds_symmetrical )
				data.update()
			Else If ALT
				data.set_engine_size( ed.engine_lock_i, img_x, img_y, ed.bounds_symmetrical )
				data.update()
			Else 'no modifiers
				data.set_engine_angle( ed.engine_lock_i, img_x, img_y, ed.bounds_symmetrical )
				data.update()
			End If
			ed.mouse_1 = true
		Else
			ed.engine_lock_i = -1
			ed.mouse_1 = false
		End If
		If CONTROL And ALT
			If ed.mouse_2 'dragging
				For i = 0 Until data.ship.engineSlots.length
					data.ship.engineSlots[i].location[0] :+ img_x - ed.last_img_x
					data.ship.engineSlots[i].location[1] :- img_y - ed.last_img_y
				Next
				data.update()
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
		If KeyHit( KEY_BACKSPACE )
			data.remove_engine( ni, ed.bounds_symmetrical )
			data.update()
		End If
	EndMethod

	Method Draw( ed:TEditor, data:TData, sprite:TSprite ) 
		If Not data.ship.center Then Return
		'get input
		sprite.get_img_xy( MouseX(), MouseY(), img_x, img_y )
		'locate nearest entity
		ni = data.find_nearest_engine( img_x, img_y )
		If ed.engine_lock_i <> -1
			ni = ed.engine_lock_i
		End If
		'screen position of coordinate to be potentially added
		x = sprite.sx + img_x*sprite.scale 
		y = sprite.sy + img_y*sprite.scale
		'draw pointers
		nearest = false
		For i = 0 Until data.ship.engineSlots.Length
			engine = data.ship.engineSlots[i]
			If ni = i
				nearest = True
			Else
				nearest = False
			EndIf
			wx = sprite.sx + (engine.location[0] + data.ship.center[1])*sprite.Scale
			wy = sprite.sy + (-engine.location[1] + data.ship.center[0])*sprite.Scale
			SetRotation( 0 )
			SetScale( 1, 1 )
			SetAlpha( 1 )
			draw_engine( wx, wy, engine.length, engine.width, engine.angle, sprite.scale, nearest )
		Next
		SetRotation( 0 )
		SetScale( 1, 1 )
		SetAlpha( 1 )
		'ghost preview
		If SHIFT And Not CONTROL And Not ALT
			SetAlpha( 0.4 )
			length = 30
			width = 10
			angle = 180
			If ni <> -1
				engine = data.ship.engineSlots[ni]
				length = engine.length
				width = engine.width
				angle = engine.angle
			EndIf
			draw_engine( x, y, length, width, angle, sprite.scale, FALSE )
			If ed.bounds_symmetrical 'reflected twin
				wyr = img_y - data.ship.center[0] 'simulating TData math
				angle = -angle
				xr = x
				yr = sprite.sy + (-wyr + data.ship.center[0])*sprite.scale
				draw_engine( xr, yr, length, width, angle, sprite.scale, FALSE )
			EndIf
			SetAlpha( 1 )
		EndIf
		'mouse crosshairs
		draw_crosshairs( x, y, 16 )
		'mouse text output
		img_x :- data.ship.center[1]
		img_y :- data.ship.center[0]
		If ni <> -1
			engine = data.ship.engineSlots[ni]
		End If
		If SHIFT
			mouse_str :+ coord_string( img_x, -img_y )+"~n"
		ElseIf CONTROL
			If engine
				mouse_str :+ coord_string( engine.location[0], engine.location[1] )+"~n"
			Else
				mouse_str :+ coord_string( img_x, -img_y )+"~n"
			EndIf
		ElseIf ALT
			If engine
				mouse_str :+ json.FormatDouble(engine.width,1)+"x"+json.FormatDouble(engine.length,1)+"~n"
			EndIf
		Else
			If engine
				mouse_str :+ json.FormatDouble(engine.angle,2)+Chr($00B0)+"~n"
			EndIf
		EndIf
		SetAlpha( 1 )
	EndMethod

	Method Load( ed:TEditor, data:TData, sprite:TSprite )
	EndMethod
	
	Method Save( ed:TEditor, data:TData, sprite:TSprite )
	EndMethod

EndType

