
Type TModalSetEngineSlots Extends TSubroutine
	Field left_click%
	Field img_x#, img_y#
	Field x%, y%
	Field xr%, yr%
	Field ni%
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
		ed.engine_lock_i = - 1
		ni = - 1
	EndMethod

	Method Update( ed:TEditor, data:TData, sprite:TSprite )
		If Not data.ship.center Then Return
		'get input
		Select EventID()
		Case EVENT_MOUSEDOWN, EVENT_MOUSEUP, EVENT_MOUSEMOVE
			sprite.get_img_xy( MouseX, MouseY, img_x, img_y )
			'locate nearest entity
			ni = data.find_nearest_engine( img_x, img_y )
			If ed.engine_lock_i <> - 1 Then ni = ed.engine_lock_i
			'process input
			Select ModKeyAndMouseKey
			Case 16 '(MODIFIER_LMOUSE)
				'set angle
				Select EventID()
				Case EVENT_MOUSEDOWN
					ed.engine_lock_i = ni
					data.set_engine_angle( ed.engine_lock_i, img_x, img_y, ed.bounds_symmetrical )
				Case EVENT_MOUSEMOVE
					data.set_engine_angle( ed.engine_lock_i, img_x, img_y, ed.bounds_symmetrical )
				Case EVENT_MOUSEUP
					ed.engine_lock_i = - 1
					data.update()
				EndSelect
			Case 17 '(MODIFIER_SHIFT|MODIFIER_LMOUSE)
				'add new
				If EventID() = EVENT_MOUSEDOWN	
					' copy nearest
					If ni <> - 1 Then source_engine = data.ship.engineSlots[ni] Else source_engine = New TStarfarerShipEngine
					'add new engine slot
					data.add_engine( img_x, img_y, source_engine )
					If ( ed.bounds_symmetrical ) Then data.add_engine( img_x, img_y, source_engine, True )
					data.update()				
				EndIf
			Case 18 '(MODIFIER_CONTROL|MODIFIER_LMOUSE)
				'set location
				Select EventID()
				Case EVENT_MOUSEDOWN
					ed.engine_lock_i = ni
					data.set_engine_location( ed.engine_lock_i, img_x, img_y, ed.bounds_symmetrical )
				Case EVENT_MOUSEMOVE
					data.set_engine_location( ed.engine_lock_i, img_x, img_y, ed.bounds_symmetrical )
				Case EVENT_MOUSEUP
					ed.engine_lock_i = - 1
					data.update()
				EndSelect
			Case 20 '(MODIFIER_ALT|MODIFIER_LMOUSE)
				'set size
				Select EventID()
				Case EVENT_MOUSEDOWN
					ed.engine_lock_i = ni
					data.set_engine_size( ed.engine_lock_i, img_x, img_y, ed.bounds_symmetrical )
				Case EVENT_MOUSEMOVE
					data.set_engine_size( ed.engine_lock_i, img_x, img_y, ed.bounds_symmetrical )
				Case EVENT_MOUSEUP
					ed.engine_lock_i = - 1
					data.update()
				EndSelect
			Case 38 '(MODIFIER_CONTROL|MODIFIER_ALT|MODIFIER_RMOUSE)
				'dragging everything
				If data.ship.engineSlots.length
					Select EventID()
					Case EVENT_MOUSEDOWN
						'drag start
						ed.last_img_x = img_x
						ed.last_img_y = img_y
					Case EVENT_MOUSEMOVE
						'dragging
						For Local i% = 0 Until data.ship.engineSlots.length
							data.ship.engineSlots[i].location[0] :+ img_x - ed.last_img_x
							data.ship.engineSlots[i].location[1] :- img_y - ed.last_img_y
						Next
						ed.last_img_x = img_x
						ed.last_img_y = img_y
					Case EVENT_MOUSEUP
						data.update()
					EndSelect
				EndIf
			End Select
		Case EVENT_GADGETACTION, EVENT_MENUACTION
			Select EventSource()
			Case functionMenu[MENU_FUNCTION_REMOVE]
				data.remove_engine( ni, ed.bounds_symmetrical )
				data.update()
			EndSelect
		EndSelect
	EndMethod

	Method Draw( ed:TEditor, data:TData, sprite:TSprite ) 
		If Not data.ship.center Then Return
		'get input
		sprite.get_img_xy( MouseX, MouseY, img_x, img_y )
		'screen position of coordinate to be potentially added
		x = sprite.sx + img_x * sprite.scale
		y = sprite.sy + img_y * sprite.scale
		ni = data.find_nearest_engine( img_x, img_y )
		If ed.engine_lock_i <> - 1 Then ni = ed.engine_lock_i
		'draw pointers
		SetRotation( 0 )
		SetScale( 1, 1 )
		SetAlpha( 1 )
		If data.ship.engineSlots
			For Local i% = 0 Until data.ship.engineSlots.length
				engine = data.ship.engineSlots[i]	
				Local wx# = sprite.sx + (engine.location[0] + data.ship.center[1]) * sprite.scale
				Local wy# = sprite.sy + ( - engine.location[1] + data.ship.center[0]) * sprite.scale
				draw_engine( wx, wy, engine.length, engine.width, engine.angle, sprite.scale, (i = ni), getEngineColor(engine, ed) )	
			Next
		EndIf 
		'ghost preview
		If ModKeyAndMouseKey = 1
			SetAlpha(0.5)
			If ni <> - 1 Then engine = data.ship.engineSlots[ni] Else engine = New TStarfarerShipEngine	
			length = engine.length
			width = engine.width
			angle = engine.angle
			draw_engine( x, y, length, width, angle, sprite.scale, False , getEngineColor(engine, ed) )
			If ed.bounds_symmetrical 'reflected twin
				wyr = img_y - data.ship.center[0] 'simulating TData math
				angle = -angle
				xr = x
				yr = sprite.sy + ( - wyr + data.ship.center[0]) * sprite.scale
				draw_engine( xr, yr, length, width, angle, sprite.scale, False, getEngineColor(engine, ed) )
			EndIf
			SetAlpha(1)
		EndIf
		'mouse crosshairs
		draw_crosshairs( x, y, 16 )
		'mouse text output
		img_x :- data.ship.center[1]
		img_y :- data.ship.center[0]
		
		If ni <> - 1 Then engine = data.ship.engineSlots[ni]
		Select ModKeyAndMouseKey
		Case 0, 16
			If engine Then mouse_str :+ json.FormatDouble(engine.angle, 2) + Chr($00B0) + "~n"
		Case 1, 17
			mouse_str :+ coord_string( img_x, - img_y ) + "~n"
		Case 2, 18
			If engine Then 	mouse_str :+ coord_string( engine.location[0], engine.location[1] ) + "~n"..
			Else mouse_str :+ coord_string( img_x, - img_y ) + "~n"
		Case 4, 20
			If engine Then mouse_str :+ json.FormatDouble(engine.width, 1) + "x" + json.FormatDouble(engine.length, 1) + "~n"
		End Select
	EndMethod

	Method Load( ed:TEditor, data:TData, sprite:TSprite )
	EndMethod
	
	Method Save( ed:TEditor, data:TData, sprite:TSprite )
	EndMethod

EndType
Function getEngineColor%[]( engine:TStarfarerShipEngine, ed:TEditor )
	If engine.styleSpec Then Return engine.styleSpec.engineColor
	Local styleID$ = engine.style
	If styleID = "CUSTOM" Then styleID = engine.styleId
	Local Value:Object = ed.stock_engine_styles.ValueForKey( styleID )
	If Value Then Return (TStarfarerCustomEngineStyleSpec (Value) ).engineColor..
	Else Return [255, 255, 255, 255]
	
End Function

