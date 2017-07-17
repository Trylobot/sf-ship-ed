
Type TModalPreviewAll Extends TSubroutine
	Field i%
	Field cx%,cy% 
	Field csx%,csy%
	Field x%,y%
	Field r#,rs#
	Field xy%[] ' all bounds coordinates
	Field Lxy%[] ' launch bay coordinates
	Field weapon:TStarfarerShipWeapon
	Field engine:TStarfarerShipEngine
	
	Method Activate( ed:TEditor, data:TData, sprite:TSprite )
		ed.last_mode = ed.mode
		ed.mode = "preview_all"
		ed.field_i = 0
		DebugLogFile(" Activate Preview All")
	EndMethod

	Method Update( ed:TEditor, data:TData, sprite:TSprite )
'		Select EventID()
'		Case EVENT_MOUSEDOWN, EVENT_MOUSEUP, EVENT_MOUSEMOVE
'			Select ModKeyAndMouseKey
'			Case 16 '(MODIFIER_LMOUSE)
'				Select EventID()
'				Case EVENT_MOUSEDOWN
'				Case EVENT_MOUSEMOVE
'				Case EVENT_MOUSEUP
'				EndSelect
'			Case 17 '(MODIFIER_SHIFT|MODIFIER_LMOUSE)
'				If EventID() = EVENT_MOUSEDOWN				
'				EndIf
'			Case 18 '(MODIFIER_CONTROL|MODIFIER_LMOUSE)
'			Case 20 '(MODIFIER_ALT|MODIFIER_LMOUSE)
'			Case 38 '(MODIFIER_CONTROL|MODIFIER_ALT|MODIFIER_RMOUSE)
'			EndSelect
'		Case EVENT_GADGETACTION, EVENT_MENUACTION
'			Select EventSource()
'			EndSelect
'		EndSelect
	EndMethod

	Method Draw( ed:TEditor, data:TData, sprite:TSprite )
		If data.ship.center
			cx = sprite.sx + data.ship.center[1] * sprite.scale
			cy = sprite.sy + data.ship.center[0]*sprite.scale
			csx = sprite.sx + data.ship.center[1]*sprite.Scale + data.ship.shieldCenter[0]*sprite.Scale
			csy = sprite.sy + data.ship.center[0]*sprite.Scale - data.ship.shieldCenter[1]*sprite.Scale
			SetRotation( 0 )
			SetScale( 1, 1 )
			SetAlpha( 0.15 )
			SetColor( 240, 230, 140)
			'draw current collision radius centered at existing center
			draw_collision_circle( data, sprite, False, False )
			SetColor( 175, 215, 230 )
			'draw current shield radius centered at existing center
			draw_shield_circle( data, sprite, False, False )
			SetAlpha( 1 )
			'draw shield crosshair centered at existing shield center
			draw_shield_center_point( data, sprite, False )
			'draw collision crosshair centered at existing center
			draw_collision_center_point( data, sprite, False )
			'draw bounds
			If data.ship.bounds
				update_bounds_coords( data, sprite )
				'bg's of lines and dots
				SetRotation( 0 )
				SetScale( 1, 1 )
				SetColor( 0, 0, 0 )
				SetAlpha( 0.35 )
				SetLineWidth( 4 )
				For i = 0 Until xy.length Step 2
					DrawOval( xy[i] - 5, xy[i + 1] - 5, 10, 10 )
					If i > 0
						DrawLine( xy[i], xy[i+1], xy[i-2], xy[i-1] )
					End If
				Next
				DrawLine( xy[xy.length - 2], xy[xy.length - 1], xy[0], xy[1] )
				'fg's of lines and dots
				SetColor( 255, 255, 255 )
				SetLineWidth( 2 )
				For i = 0 Until xy.length Step 2
					DrawOval( xy[i]-4, xy[i+1]-4, 8, 8 )
					If i > 0 
						DrawLine( xy[i], xy[i+1], xy[i-2], xy[i-1] )
					End If
				Next
				DrawLine( xy[xy.length-2], xy[xy.length-1], xy[0], xy[1] )
			End If
			SetAlpha( 1 )
			'draw weapon slots
			If data.ship.weaponSlots
				For weapon = EachIn data.ship.weaponSlots
					x = cx + sprite.scale*weapon.locations[0]
					y = cy - sprite.scale*weapon.locations[1]
					If Not weapon.is_launch_bay()
						'WEAPON
						SetAlpha( 0.1 )
						draw_arc( x, y, 8, 0, 360, 360, False )
						SetAlpha( 1 )
						draw_string( TEXT_W, x, y,,, 0.5, 0.5 )
					Else
						'LAUNCH BAY
						Lxy = New Int[weapon.locations.length]
						For i = 0 Until weapon.locations.length Step 2
							Lxy[i]   = sprite.sx + ( weapon.locations[i]   + data.ship.center[1])*sprite.Scale
							Lxy[i+1] = sprite.sy + (-weapon.locations[i+1] + data.ship.center[0])*sprite.scale
						Next
						SetRotation( 0 )
						SetScale( 1, 1 )
						SetColor( 0, 0, 0 )
						SetAlpha( 1.0 )
						For i = 0 Until Lxy.length Step 2
							draw_string( TEXT_L, Lxy[i],Lxy[i+1],,, 0.5,0.5 )
						Next
					EndIf
				Next
			End If
			'draw engine slots
			SetRotation( 0 )
			SetScale( 1, 1 )
			SetAlpha( 1 )
			If data.ship.engineSlots
				For Local i% = 0 Until data.ship.engineSlots.length
					engine = data.ship.engineSlots[i]	
					Local wx# = sprite.sx + (engine.location[0] + data.ship.center[1]) * sprite.scale
					Local wy# = sprite.sy + ( - engine.location[1] + data.ship.center[0]) * sprite.scale
					draw_engine( wx, wy, engine.length, engine.width, engine.angle, sprite.scale, False, ed.get_engine_color( engine ), False )	
				Next
			EndIf 
			SetAlpha( 0.75 )
			SetRotation( 0 )
			SetScale( 1, 1 )
			Rem
			'draw existing shield center
			draw_crosshairs( csx, csy, 6, True )
			draw_string( coord_string( data.ship.shieldCenter[0], data.ship.shieldCenter[1] ), csx + 5, csy + 5 )
			'draw existing collision center
			draw_crosshairs( cx, cy, 8, False )
			draw_string( coord_string( data.ship.center[0], data.ship.center[1] ), cx+5, cy+5 )
			endrem
		End If
	EndMethod

	Method Save( ed:TEditor, data:TData, sprite:TSprite )
	EndMethod

	Method Load( ed:TEditor, data:TData, sprite:TSprite )
	EndMethod

	Method update_bounds_coords( data:TData, sprite:TSprite )
		If data.ship And data.ship.bounds
			xy = New Int[data.ship.bounds.length]
			For i = 0 Until data.ship.bounds.length Step 2
				xy[i] = sprite.sx + (data.ship.bounds[i] + data.ship.center[1])*sprite.scale
				xy[i+1] = sprite.sy + (-data.ship.bounds[i+1] + data.ship.center[0])*sprite.scale
			Next
		EndIf
	EndMethod

EndType

