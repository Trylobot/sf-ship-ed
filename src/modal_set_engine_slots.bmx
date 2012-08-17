'-----------------------

Function modal_update_set_engine_slots( ed:TEditor, data:TData, sprite:TSprite )
	If Not data.ship.center Then Return
	'get input
	Local left_click% = MouseHit( 1 )
	Local img_x#, img_y#
	sprite.get_img_xy( MouseX(), MouseY(), img_x, img_y )
	'locate nearest entity
	Local ni% = data.find_nearest_engine( img_x, img_y )
	'process input
	If left_click And SHIFT
		'copy nearest
		Local source_engine:TStarfarerShipEngine
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
			For Local i% = 0 Until data.ship.engineSlots.length
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
End Function

Function modal_draw_set_engine_slots( ed:TEditor, data:TData, sprite:TSprite ) 
	If Not data.ship.center Then Return
	'get input
	Local img_x#, img_y#
	sprite.get_img_xy( MouseX(), MouseY(), img_x, img_y )
	'locate nearest entity
	Local ni% = data.find_nearest_engine( img_x, img_y )
	If ed.engine_lock_i <> -1
		ni = ed.engine_lock_i
	End If
	'screen position of coordinate to be potentially added
	Local x% = sprite.sx + img_x*sprite.scale 
	Local y% = sprite.sy + img_y*sprite.scale
	'draw pointers
	Local engine:TStarfarerShipEngine, nearest% = false
	For Local i% = 0 Until data.ship.engineSlots.Length
		engine = data.ship.engineSlots[i]
		If ni = i
			nearest = True
		Else
			nearest = False
		EndIf
		Local wx% = sprite.sx + (engine.location[0] + data.ship.center[1])*sprite.Scale
		Local wy% = sprite.sy + (-engine.location[1] + data.ship.center[0])*sprite.Scale
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
		Local length# = 30
		Local width# = 10
		Local angle# = 180
		If ni <> -1
			engine = data.ship.engineSlots[ni]
			length = engine.length
			width = engine.width
			angle = engine.angle
		EndIf
		draw_engine( x, y, length, width, angle, sprite.scale, FALSE )
		If ed.bounds_symmetrical 'reflected twin
			Local wyr# = img_y - data.ship.center[0] 'simulating TData math
			angle = -angle
			Local xr% = x
			Local yr% = sprite.sy + (-wyr + data.ship.center[0])*sprite.scale
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
			mouse_str :+ FormatDouble(engine.width,1,FALSE)+"x"+FormatDouble(engine.length,1,FALSE)+"~n"
		EndIf
	Else
		If engine
			mouse_str :+ FormatDouble(engine.angle,2,FALSE)+Chr($00B0)+"~n"
		EndIf
	EndIf
	SetAlpha( 1 )
End Function

Function draw_engine( x%, y%, w%, l%, rot#, z#, em%=False )
	Local a# = GetAlpha()
	Local outer_r% = 5
	Local inner_r% = 4
	If em
		outer_r = 10
		inner_r = 8
	End If
	'draw sizing rect
	SetRotation( -rot )
	SetScale( z, z )
	SetColor( 255, 255, 255 )
	If em
		SetAlpha( a*0.25 )
	Else
		SetAlpha( a*0.18 )
	EndIf
	DrawRect( x + z*(l/2)*cos(rot+90), y - z*(l/2)*sin(rot+90), w, l )
	SetRotation( 0 )
	SetScale( 1, 1 )
	SetAlpha( a*1 )
	'draw bg
	SetColor( 0, 0, 0 )
	DrawOval( x-outer_r, y-outer_r, 2*outer_r, 2*outer_r )
	'draw fg
	SetColor( 255, 255, 255 )
	DrawOval( x-inner_r, y-inner_r, 2*inner_r, 2*inner_r )
	'reset
	SetLineWidth( 1 )
	SetAlpha( a )
End Function

