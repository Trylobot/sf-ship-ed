
Type TModalSetBounds Extends TSubroutine
	Field img_x#, img_y# ' mouse position on image
	Field x%,y%
	Field xr%, yr%
	Field xy#[] ' all bounds coordinates
	Field ni% ' index of nearest bounds point
	Field si% ' if applicable, symmetrical counterpart of bounds[ni]
	Field nsi% ' index of nearest bounds segment start point
	Field nsri% '  if applicable, symmetrical counterpart of [nsi]
	
	Method Activate( ed:TEditor, data:TData, sprite:TSprite )
		ed.last_mode = ed.mode
		ed.mode = "bounds"
		ed.field_i = 0
		DebugLogFile(" Activate Bounds Editor")
	EndMethod
	
	Method Update( ed:TEditor, data:TData, sprite:TSprite )
		If Not data.ship.center Then Return
		sprite.get_img_xy( MouseX, MouseY, img_x, img_y )
		Select EventID()
		Case EVENT_MOUSEDOWN, EVENT_MOUSEMOVE, EVENT_MOUSEUP
			Select ModKeyAndMouseKey
			Case 16 '(MODIFIER_LMOUSE) drag nearest
				Select EventID()
				Case EVENT_MOUSEDOWN 'starting drag
					ed.drag_nearest_i = data.find_nearest_bound( img_x, img_y )
					ed.drag_mirrored = ed.bounds_symmetrical
					If( ed.drag_mirrored )
						ed.drag_counterpart_i = data.find_symmetrical_counterpart( ed.drag_nearest_i )
					End If
				Case EVENT_MOUSEMOVE 'continuing drag
					data.modify_bound( ed.drag_nearest_i, img_x, img_y, False )
					If ed.drag_mirrored
						data.modify_bound( ed.drag_counterpart_i, img_x, img_y, True )
					End If
				Case EVENT_MOUSEUP 'finishing drag
					data.update()
				EndSelect
			Case 17 '(MODIFIER_CONTROL|MODIFIER_LMOUSE) add new
				If EventID() = EVENT_MOUSEDOWN
					data.append_bound( img_x, img_y, False )
					If ed.bounds_symmetrical Then data.prepend_bound( img_x, img_y, True )
					data.update()
				EndIf
			Case 18 '(MODIFIER_SHIFT|MODIFIER_LMOUSE) insert new
				If EventID() = EVENT_MOUSEDOWN
					data.insert_bound( img_x, img_y, ed.bounds_symmetrical )
'					If ed.bounds_symmetrical
'						data.insert_bound( img_x, img_y, True )
'					End If
					data.update()
				EndIf
			Case 38 '(MODIFIER_CONTROL|MODIFIER_ALT|MODIFIER_RMOUSE) drag all
				Select EventID()
				Case EVENT_MOUSEDOWN 'drag start
					ed.last_img_x = img_x
					ed.last_img_y = img_y
				Case EVENT_MOUSEMOVE 'dragging
					For Local i% = 0 Until data.ship.bounds.length Step 2
					data.ship.bounds[i]   :+ img_x - ed.last_img_x
					data.ship.bounds[i+1] :- img_y - ed.last_img_y
					Next
					ed.last_img_x = img_x
					ed.last_img_y = img_y
				Case EVENT_MOUSEUP 'drag end
					data.update()
				End Select
			End Select
		Case EVENT_GADGETACTION, EVENT_MENUACTION
			Select EventSource()
			Case functionMenu[MENU_FUNCTION_REMOVE] 'm_function_remove remove nearest
				data.remove_nearest_bound( img_x, img_y, ed.bounds_symmetrical )
				data.update()
			EndSelect
		End Select	
	EndMethod
	
	Method Draw( ed:TEditor, data:TData, sprite:TSprite )
		If Not data.ship.center Then Return
		sprite.get_img_xy( MouseX, MouseY, img_x, img_y )
		'screen position of coordinate to be potentially added
		x = sprite.sx + img_x * sprite.scale
		y = sprite.sy + img_y * sprite.scale
		xr = x
		yr = sprite.sy - (img_y - 2 * data.ship.center[0]) * sprite.scale	
		SetRotation( 0 )
		SetScale( 1, 1 )
		SetAlpha( 1 )
		If data.ship.bounds
			'update bounds coords to draw
			update_bounds_coords( data, sprite )
			'draw existent bounds
			For Local i% = 0 Until xy.length * 2 Step 2
				Local j% = i / xy.length
				Local k% = i Mod xy.length
				If Not j
					'draw bg's of lines and dots
					SetColor( 0, 0, 0 )
					SetLineWidth( 4 )
				Else
					'draw fg's of lines and dots
					SetColor( 255, 255, 255 )
					SetLineWidth( 2 )
				EndIf
				DrawOval( xy[k] - 5, xy[k + 1] - 5, 10, 10 )
				If (ModKeyAndMouseKey & MODIFIER_SHIFT) And ( k = xy.length - 2) Then Continue
				DrawLine( xy[k], xy[k + 1], xy[(k + 2) Mod xy.length], xy[(k + 3) Mod xy.length] )
			Next
			ni = si = nsi = nsri - 1
			'find something
			Select ModKeyAndMouseKey
			Case 0, 16 'not modkey down, draw nearest bound indicator
				ni = data.find_nearest_bound( img_x, img_y )
				SetAlpha( 0.40 )
				DrawOval( xy[ni] - 10, xy[ni + 1] - 10, 20, 20 )
				mouse_str:+ coord_string(data.ship.bounds[ni], data.ship.bounds[ni + 1])
				If ed.bounds_symmetrical Then si = data.find_symmetrical_counterpart( ni )
				If si <> - 1 Then DrawOval( xy[si] - 10, xy[si + 1] - 10, 20, 20 )
				SetAlpha( 1 )
			Case 1, 17
				SetAlpha( 0.40 )
				If ed.bounds_symmetrical
					DrawOval( x-5, y-5, 10, 10 )
					DrawOval( xr-5, yr-5, 10, 10 )
					DrawLine( xy[xy.length-2], xy[xy.length-1], x, y )
					DrawLine( x, y, xr, yr )
					DrawLine( xr, yr, xy[0], xy[1] )
				Else
					DrawOval( x-5, y-5, 10, 10 )
					DrawLine( xy[xy.length-2], xy[xy.length-1], x, y )
					DrawLine( x, y, xy[0], xy[1] )
				End If
				SetAlpha( 1 )
				mouse_str:+ coord_string(img_x - data.ship.center[1], - img_y + data.ship.center[0])
			Case 2, 18
				SetAlpha( 0.4 )
				nsi = data.find_nearest_bound_segment_1st_i(img_x, img_y, False )				
				If ed.bounds_symmetrical
					nsri = data.find_nearest_bound_segment_1st_i(img_x, img_y, True )				
					If nsi = nsri
					DrawLine( xy[nsi], xy[(nsi + 1) Mod xy.length], x, y )		
					DrawLine( xr, yr, xy[(nsri + 2) Mod xy.length], xy[(nsri + 3) Mod xy.length] )
					DrawLine( x, y, xr, yr)					
					DrawOval( x - 5, y - 5, 10, 10 )					
					DrawOval( xr - 5, yr - 5, 10, 10 )
					Else
					DrawLine( xy[nsi], xy[(nsi + 1) Mod xy.length], x, y )
					DrawLine( x, y, xy[(nsi + 2) Mod xy.length], xy[(nsi + 3) Mod xy.length] )					
					DrawLine( xy[nsri], xy[(nsri + 1) Mod xy.length], xr, yr )
					DrawLine( xr, yr, xy[(nsri + 2) Mod xy.length], xy[(nsri + 3) Mod xy.length] )
					DrawOval( x - 5, y - 5, 10, 10 )
					DrawOval( xr - 5, yr - 5, 10, 10 )
					EndIf	
				Else
					DrawLine( xy[nsi], xy[(nsi + 1) Mod xy.length], x, y )
					DrawLine( x, y, xy[(nsi + 2) Mod xy.length], xy[(nsi + 3) Mod xy.length] )
					DrawOval( x - 5, y - 5, 10, 10 )
				End If
				SetAlpha( 1 )
				mouse_str:+ coord_string(img_x - data.ship.center[1], - img_y + data.ship.center[0])
			End Select
			'update mouse string
			If ni = - 1 Then mouse_str:+ coord_string(img_x - data.ship.center[1], - img_y + data.ship.center[0])
		Else 'no existent bounds, report the mouse coord
			mouse_str:+ coord_string(img_x - data.ship.center[1], - img_y + data.ship.center[0])
			Select ModKeyAndMouseKey
			Case 1, 17, 2, 18
				SetAlpha( 0.4 )	
				DrawOval( x - 5, y - 5, 10, 10 )	
				If ed.bounds_symmetrical
					DrawLine( x, y, xr, yr)								
					DrawOval( xr - 5, yr - 5, 10, 10 )
				EndIf
				SetAlpha( 1 )
			End Select
		EndIf
		'mouse crosshairs
		draw_crosshairs( x, y, 16 )
		SetAlpha( 1 )
	EndMethod
	
	Method Load( ed:TEditor, data:TData, sprite:TSprite )
	EndMethod
	
	Method Save( ed:TEditor, data:TData, sprite:TSprite )
	EndMethod

	Method update_bounds_coords( data:TData, sprite:TSprite )
		If data.ship And data.ship.bounds
			xy = data.ship.bounds[..]
			For Local i% = 0 Until data.ship.bounds.length Step 2
				xy[i] = sprite.sx + (data.ship.bounds[i] + data.ship.center[1]) * sprite.scale
				xy[i+1] = sprite.sy + (-data.ship.bounds[i+1] + data.ship.center[0])*sprite.scale
			Next
		EndIf
	EndMethod
EndType
