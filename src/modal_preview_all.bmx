'-----------------------

Function modal_draw_preview_all( ed:TEditor, data:TData, sprite:TSprite )
	'draw center
	If data.ship.center
		SetRotation( 0 )
		SetScale( 1, 1 )
		SetColor( 255, 255, 255 )
		SetAlpha( 0.75 )
		Local cx% = sprite.sx + data.ship.center[1]*sprite.scale
		Local cy% = sprite.sy + data.ship.center[0]*sprite.scale
		Local csx% = sprite.sx + data.ship.center[1]*sprite.Scale + data.ship.shieldCenter[0]*sprite.Scale
		Local csy% = sprite.sy + data.ship.center[0]*sprite.Scale - data.ship.shieldCenter[1]*sprite.Scale
		Local r#, rs#
		'draw current collision radius
		SetAlpha( 0.10 )
		If data.ship.collisionRadius > 0.0
			r = data.ship.collisionRadius
			rs = r*sprite.scale
			DrawOval( cx - rs, cy - rs, 2*rs, 2*rs )
		End If
		'draw current shield radius
		SetAlpha( 0.10 )
		If data.ship.shieldRadius > 0.0
			r = data.ship.shieldRadius
			rs = r*sprite.scale
			DrawOval( csx - rs, csy - rs, 2*rs, 2*rs )
		End If
		're-draw ship for contrast
		draw_ship( ed, sprite )
		'draw bounds
		If data.ship.bounds
			Local xy%[data.ship.bounds.length]
			For Local i% = 0 Until data.ship.bounds.length Step 2
				xy[i] = sprite.sx + (data.ship.bounds[i] + data.ship.center[1])*sprite.Scale
				xy[i+1] = sprite.sy + (-data.ship.bounds[i+1] + data.ship.center[0])*sprite.scale
			Next
			'bg's of lines and dots
			SetRotation( 0 )
			SetScale( 1, 1 )
			SetColor( 0, 0, 0 )
			SetAlpha( 0.35 )
			SetLineWidth( 4 )
			For Local i% = 0 Until xy.length Step 2
				DrawOval( xy[i]-5, xy[i+1]-5, 10, 10 )
				If i > 0 
					DrawLine( xy[i], xy[i+1], xy[i-2], xy[i-1] )
				End If
			Next
			DrawLine( xy[xy.length-2], xy[xy.length-1], xy[0], xy[1] )
			'fg's of lines and dots
			SetColor( 255, 255, 255 )
			SetLineWidth( 2 )
			For Local i% = 0 Until xy.length Step 2
				DrawOval( xy[i]-4, xy[i+1]-4, 8, 8 )
				If i > 0 
					DrawLine( xy[i], xy[i+1], xy[i-2], xy[i-1] )
				End If
			Next
			DrawLine( xy[xy.length-2], xy[xy.length-1], xy[0], xy[1] )
		End If
		SetAlpha( 1 )
		'draw weapon slots
		Local x%, y%
		If data.ship.weaponSlots
			For Local weapon:TStarfarerShipWeapon = EachIn data.ship.weaponSlots
				x = cx + sprite.scale*weapon.locations[0]
				y = cy - sprite.scale*weapon.locations[1]
				If Not weapon.is_launch_bay()
					SetAlpha( 0.1 )
					draw_arc( x,y, 8, 0,360,4*360,false )
					SetAlpha( 1 )
					draw_string( TEXT_W, x,y,,, 0.5,0.5 )
				Else
					'LAUNCH BAY
					Local Lxy%[weapon.locations.length]
					For Local i% = 0 Until weapon.locations.length Step 2
						Lxy[i] = sprite.sx + (weapon.locations[i] + data.ship.center[1])*sprite.Scale
						Lxy[i+1] = sprite.sy + (-weapon.locations[i+1] + data.ship.center[0])*sprite.scale
					Next
					SetRotation( 0 )
					SetScale( 1, 1 )
					SetColor( 0, 0, 0 )
					SetAlpha( 1.0 )
					For Local i% = 0 Until Lxy.length Step 2
						draw_string( TEXT_L, Lxy[i],Lxy[i+1],,, 0.5,0.5 )
					Next
				EndIf
			Next
		End If
		'draw engine slots
		If data.ship.engineSlots
			For Local engine:TStarfarerShipEngine = EachIn data.ship.engineSlots
				x = cx + sprite.scale*engine.location[0]
				y = cy - sprite.scale*engine.location[1]
				draw_string( TEXT_E, x,y,,, 0.5,0.5 )
			Next
		End If
		SetAlpha( 0.75 )
		SetRotation( 0 )
		SetScale( 1, 1 )
		'draw existing shield center
		draw_crosshairs( csx, csy, 6, True )
		draw_string( coord_string( data.ship.shieldCenter[0], data.ship.shieldCenter[1] ), csx+5, csy+5 )
		'draw existing collision center
		draw_crosshairs( cx, cy, 8, False )
		draw_string( coord_string( data.ship.center[0], data.ship.center[1] ), cx+5, cy+5 )
	End If
	
End Function

