'-----------------------

Function draw_string( source:Object, x%, y%, fg%=$FFFFFF, bg%=$000000, origin_x#=0.0, origin_y#=0.0, line_height_override%=-1, draw_bg%=True, s#=1.0 )
	Local LH% = LINE_HEIGHT
	If line_height_override > -1
		LH = line_height_override
	End If
	Local lines$[]
	Local widget:TextWidget
	Local text$ = String(source)
	If Not text
		widget = TextWidget(source) 'assume widget passed
		If widget
			lines = widget.lines
		Else 'assume string array passed
			lines = String[](source)
		End If
	Else
		lines = text.Split("~n")
	End If
	If origin_x <> 0.0 Or origin_y <> 0.0
		If Not widget
			widget = TextWidget.Create( text )
		End If
		x :- origin_x*Float( s*widget.w )
		y :- origin_y*Float( s*widget.h )
	End If
	Local x_cur% = x
	Local y_cur% = y
	SetRotation( 0 )
	SetScale( s, s )
	Local a# = GetAlpha()
	If draw_bg
		SetColor( (bg & $FF0000) Shr 16, (bg & $00FF00) Shr 8, (bg & $0000FF) Shr 0 )
		SetAlpha( 0.5*a )
		For Local line$ = EachIn lines
			'outline and block shadow effects
			DrawText( line, x_cur - 1, y_cur - 1 ); DrawText( line, x_cur    , y_cur - 1 ); DrawText( line, x_cur + 1, y_cur - 1 )
			DrawText( line, x_cur - 1, y_cur     );                                         DrawText( line, x_cur + 1, y_cur     )
			DrawText( line, x_cur - 1, y_cur + 1 ); DrawText( line, x_cur    , y_cur + 1 ); DrawText( line, x_cur + 1, y_cur + 1 )
			DrawText( line, x_cur + 2, y_cur + 2 )
			y_cur :+ s*LH
		Next
		x_cur = x
		y_cur = y
	End If
	SetColor( (fg & $FF0000) Shr 16, (fg & $00FF00) Shr 8, (fg & $0000FF) Shr 0 )
	SetAlpha( a )
	For Local line$ = EachIn lines
		'foreground
		DrawText( line, x_cur, y_cur )
		y_cur :+ s*LH
	Next
	SetScale( 1, 1 )
End Function

Function draw_container( x%, y%, w%, h%, ox#=0.0, oy#=0.0, fg%=$FFFFFF, bg%=$000000, bg_fill_alpha#=0.5, s#=1.0 )
	x :- ox*Float( s*w )
	y :- oy*Float( s*h )
	SetRotation( 0 )
	SetScale( 1, 1 )
	SetColor((bg&$FF0000) Shr 16,(bg&$FF00) Shr 8,(bg&$FF))
	Local a# = GetAlpha()
	SetAlpha( a*bg_fill_alpha )
	DrawRect( x,y, s*w,s*h )
	SetAlpha( a*1 )
	DrawRectLines( x-1,y-1, s*w+2,s*h+2 )
	DrawRectLines( x+1,y+1, s*w-2,s*h-2 )
	SetColor((fg&$FF0000) Shr 16,(fg&$FF00) Shr 8,(fg&$FF))
	DrawRectLines( x,y, s*w,s*h )
	SetAlpha( a )
EndFunction

Function DrawRectLines( x%, y%, w%, h%, L%=1 )
	DrawRect( x, y, w, L ) 'top horiz
	DrawRect( x+w-L, y, L, h ) 'right vert
	DrawRect( x, y+h-L, w, L ) 'bottom horiz
	DrawRect( x, y, L, h ) 'left vert
End Function

Function draw_crosshairs( x%, y%, r%, diagonal% = False )
	Local a# = GetAlpha()
	SetColor( 0, 0, 0 )
	SetLineWidth( 3 )
	SetAlpha( 0.8*a )
	If Not diagonal
		DrawRect( x-1, y-r-1, 3, 2*r+2 )
		DrawRect( x-r-1, y-1, 2*r+2, 3 )
	Else
		DrawLine( x-r-1, y-r-1, x+r+1, y+r+1 )
		DrawLine( x-r-1, y+r+1, x+r+1, y-r-1 )
	End If
	SetColor( 255, 255, 255 )
	SetLineWidth( 1 )
	SetAlpha( a )
	If Not diagonal
		DrawLine( x, y-r, x, y+r )
		DrawLine( x-r, y, x+r, y )
	Else
		DrawLine( x-r, y-r, x+r, y+r )
		DrawLine( x-r, y+r, x+r, y-r )
	End If
End Function

Function draw_arc( x%, y%, r%, a1#, a2#, c%, pie%=true )
	c = Max(1, c)
	Local segments#[] = New Float[2*c]
	Local a#
	For Local i% = 0 Until 2*c Step 2
		a = a1 + ((i/2)*(a2 - a1))/c
		segments[i] = x + r*cos(a)
		segments[i+1] = y - r*sin(a)
	Next
	'draw bg
	SetColor( 0,0,0 )
	SetLineWidth( 4 )
	For Local i% = 0 Until 2*c-2 Step 2
		DrawLine( segments[i], segments[i+1], segments[i+2], segments[i+3] )
	Next
	If pie
		DrawLine( segments[0], segments[1], x, y )
		DrawLine( segments[2*c-2], segments[2*c-1], x, y )
	End if
	'draw fg
	SetColor( 255,255,255 )
	SetLineWidth( 2 )
	For Local i% = 0 Until 2*c-2 Step 2
		DrawLine( segments[i], segments[i+1], segments[i+2], segments[i+3] )
	Next
	If pie
		DrawLine( segments[0], segments[1], x, y )
		DrawLine( segments[2*c-2], segments[2*c-1], x, y )
	End if
End Function

Function draw_dot( x%, y%, em%=False )
	Local outer_r% = 5
	Local inner_r% = 4
	If em
		outer_r = 10
		inner_r = 8
	End If
	SetAlpha( 1 )
	SetColor( 0, 0, 0 )
	DrawOval( x-outer_r, y-outer_r, 2*outer_r, 2*outer_r )
	SetColor( 255, 255, 255 )
	DrawOval( x-inner_r, y-inner_r, 2*inner_r, 2*inner_r )
End Function

Function draw_bar_graph( x#,y#, w#,h#, ox#=0.0,oy#=0.0, values#[], em_i%=-1, non_em_a#=0.5, bar_fg%=$FFFFFF )
	Local a# = GetAlpha()
	x :- ox*w
	y :- oy*h
	'container for display
	draw_container( x-10,y-10, w+20,h+20 )
	'determine max value
	Local max_val#
	For Local i% = 0 Until values.length
		If i = 0 Then max_val = values[0] Else max_val = Max( values[i], max_val )
	Next
	Local wi#, hi#, xi#, yi#
	wi = w/values.length
	'tickmark and label: max
	draw_line( x-11,y, x-11 - 10,y )
	draw_string( json.FormatDouble(values[values.length-1],4), x-11 - 10 - 3,y,,, 1.0,0.5 )
	'tickmark and label: min
	draw_line( x-11,y+h, x-11 - 10,y+h )
	draw_string( json.FormatDouble(0.0,4), x-11 - 10 - 3,y+h,,, 1.0,0.5 )
	'emphasis through a horizontal line at top of emphasized bar, and tickmark with label
	If em_i >= 0 And em_i < values.length
		'line
		yi = y + h - h*values[em_i]/max_val
		draw_line( x-9,yi, x+w+9,yi )
		'tickmark and label
		draw_line( x-11,yi, x-11 - 5,yi )
		draw_string( json.FormatDouble(values[em_i],4), x-11 - 5 - 3,yi,,, 1.0,0.5 )
	EndIf
	set_color( bar_fg )
	For Local i% = 0 Until values.length
		If values[i] = 0.0 Then Continue
		hi = h*values[i]/max_val
		xi = x + i*wi
		yi = y + h - hi
		'emphasis through contrast of bar
		If i = em_i Then SetAlpha( a*1 ) Else SetAlpha( a*non_em_a )
		'/////// draw bar ///////////
		DrawRect( xi,yi, wi,hi )
		'///////////////////////////
		'vertical divider
		SetAlpha( a*0.1 )
		DrawLine( xi,yi, xi,yi+hi )
	Next
	SetAlpha( a )
Endfunction

Function draw_line( x1#,y1#, x2#,y2#, bg%=True, fg%=True )
	If bg
		SetColor( 0,0,0 )
		SetLineWidth( 3 )
		DrawLine( x1,y1, x2,y2, False )
	EndIf
	If fg	
		SetColor( 255,255,255 )
		SetLineWidth( 1 )
		DrawLine( x1,y1, x2,y2, False )
	EndIf
EndFunction

Function draw_pointer( x%, y%, rot#, em%=False, r%=12, l%=24, fg%=$FFFFFF,bg%=$000000 )
	Local a# = GetAlpha()
	SetColor((fg&$FF0000) Shr 16,(fg&$FF00) Shr 8,(fg&$FF))
	SetAlpha( a*1.00 )
	SetRotation( 0 )
	SetScale( 1, 1 )
	'draw dot & line
	SetColor((bg&$FF0000) Shr 16,(bg&$FF00) Shr 8,(bg&$FF))
	DrawOval( x-r, y-r, 2*r, 2*r )
	SetLineWidth( 4 )
	DrawLine( x, y, x + (l + 1)*cos(rot), y - (l + 1)*sin(rot) )
	SetColor((fg&$FF0000) Shr 16,(fg&$FF00) Shr 8,(fg&$FF))
	DrawOval( x-(r-2), y-(r-2), 2*(r-2), 2*(r-2) )
	SetLineWidth( 2 )
	DrawLine( x, y, x + l*cos(rot), y - l*sin(rot) )
	SetColor((bg&$FF0000) Shr 16,(bg&$FF00) Shr 8,(bg&$FF))
	DrawOval( x-(r-4), y-(r-4), 2*(r-4), 2*(r-4) )
	'draw emphasis
	If em
		SetColor((fg&$FF0000) Shr 16,(fg&$FF00) Shr 8,(fg&$FF))
		DrawOval( x-(r-3), y-(r-3), 2*(r-3), 2*(r-3) )
	EndIf
	'cleanup
	SetLineWidth( 1 )
	SetAlpha( a )
EndFunction

Function draw_weapon_mount( x%, y%, rot#, arc#, em%=False, r%=12, l%=24, ra%=36, fg%=$FFFFFF,bg%=$000000 )
	Local a# = GetAlpha()
	'draw arc
	SetColor((fg&$FF0000) Shr 16,(fg&$FF00) Shr 8,(fg&$FF))
	SetAlpha( a*0.20 )
	DrawOval( x - ra, y - ra, 2*ra, 2*ra )
	SetAlpha( a*1.00 )
	draw_arc( x, y, ra, rot+(arc/2), rot-(arc/2), arc/2 ) '1 segment per 2 degrees, assuming ra=36
	'draw dot and pointer
	SetColor((bg&$FF0000) Shr 16,(bg&$FF00) Shr 8,(bg&$FF))
	DrawOval( x-r, y-r, 2*r, 2*r )
	SetLineWidth( 4 )
	DrawLine( x, y, x + (l + 1)*cos(rot), y - (l + 1)*sin(rot) )
	SetColor((fg&$FF0000) Shr 16,(fg&$FF00) Shr 8,(fg&$FF))
	DrawOval( x-(r-2), y-(r-2), 2*(r-2), 2*(r-2) )
	SetLineWidth( 2 )
	DrawLine( x, y, x + l*cos(rot), y - l*sin(rot) )
	SetColor((bg&$FF0000) Shr 16,(bg&$FF00) Shr 8,(bg&$FF))
	DrawOval( x-(r-4), y-(r-4), 2*(r-4), 2*(r-4) )
	'draw emphasis
	If em
		SetColor((fg&$FF0000) Shr 16,(fg&$FF00) Shr 8,(fg&$FF))
		DrawOval( x-(r-3), y-(r-3), 2*(r-3), 2*(r-3) )
	EndIf
	'cleanup
	SetLineWidth( 1 )
	SetAlpha( a )
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

Function draw_weapon_slot_info( ed:TEditor, data:TData, sprite:TSprite, weaponSlot:TStarfarerShipWeapon )
	'prep and compose string data
	Local wx% = sprite.sx + (weaponSlot.locations[0] + data.ship.center[1])*sprite.Scale
	Local wy% = sprite.sy + (-weaponSlot.locations[1] + data.ship.center[0])*sprite.Scale
	Local wep_info:TextWidget = TextWidget.Create( ..
		weaponSlot.size+"~n"+..
		weaponSlot.type_+"~n"+..
		weaponSlot.mount )
	'set colors
	Local fg_color% = $FFFFFF
	Local bg_color% = $000000
	If weaponSlot.is_builtin()
		fg_color = $BFBFBF
		bg_color = $3F3F3F
	EndIf
	'draw textbox
	draw_container( wx + 30,wy, wep_info.w + 20,wep_info.h + 20, 0.0,0.5, fg_color,bg_color )
	draw_string( wep_info, wx + 40,wy, fg_color,bg_color, 0.0,0.5 )
EndFunction

Function draw_assigned_weapon_info( ed:TEditor, data:TData, sprite:TSprite, weaponSlot:TStarfarerShipWeapon )
	'prep and compose string data
	Local wx% = sprite.sx + (weaponSlot.locations[0] + data.ship.center[1])*sprite.Scale
	Local wy% = sprite.sy + (-weaponSlot.locations[1] + data.ship.center[0])*sprite.Scale
	Local weapon_id$ = data.find_assigned_slot_weapon( weaponSlot.id )
	Local current_weapon_str$ = ""
	If weapon_id
		Local wep_stats:TMap = TMap( ed.stock_weapon_stats.ValueForKey( weapon_id ))
		If wep_stats
			Local wep_name$ = String( wep_stats.ValueForKey( "name" ))
			If wep_name
				current_weapon_str :+ wep_name
			Else
				current_weapon_str :+ weapon_id
			EndIf
			If Not weaponSlot.is_builtin()
				current_weapon_str :+ "~n"
				Local op_cost$ = String( wep_stats.ValueForKey( "OPs" ))
				If op_cost
					current_weapon_str :+ op_cost + " OP"
				Else
					current_weapon_str :+ "? OP"
				EndIf
			EndIf
		Endif
	Else
		current_weapon_str :+ "empty"
	EndIf
	'set colors
	Local fg_color% = $FFFFFF
	Local bg_color% = $000000
	If weaponSlot.is_builtin()
		fg_color = $BFBFBF
		bg_color = $3F3F3F
	EndIf
	'draw textbox
	Local current_weapon_widget:TextWidget = TextWidget.Create( current_weapon_str )
	draw_container( wx - 30, wy, current_weapon_widget.w + 20, current_weapon_widget.h + 20, 1.0,0.5, fg_color,bg_color )
	draw_string( current_weapon_widget, wx - 40, wy, fg_color,bg_color, 1.0,0.5 )
EndFunction

Function draw_variant_weapon_mount( wx%, wy%, weaponSlot:TStarfarerShipWeapon )
	'set colors
	Local fg_color% = $FFFFFF
	Local bg_color% = $000000
	If weaponSlot.is_builtin()
		fg_color = $BFBFBF
		bg_color = $3F3F3F
	EndIf
	'draw icon
	draw_weapon_mount( wx, wy, weaponSlot.angle, weaponSlot.arc, TRUE, 8, 16, 24, fg_color,bg_color )
EndFunction

Function draw_builtin_weapon_slot_info( ed:TEditor, data:TData, sprite:TSprite, weaponSlot:TStarfarerShipWeapon )
	'prep and compose string data
	Local wx% = sprite.sx + (weaponSlot.locations[0] + data.ship.center[1])*sprite.Scale
	Local wy% = sprite.sy + (-weaponSlot.locations[1] + data.ship.center[0])*sprite.Scale
	Local wep_info:TextWidget = TextWidget.Create( ..
		weaponSlot.size+"~n"+..
		weaponSlot.type_+"~n"+..
		weaponSlot.mount )
	'set colors
	Local fg_color% = $FFFFFF
	Local bg_color% = $000000
	'draw textbox
	draw_container( wx + 30,wy, wep_info.w + 20,wep_info.h + 20, 0.0,0.5, fg_color,bg_color )
	draw_string( wep_info, wx + 40,wy, fg_color,bg_color, 0.0,0.5 )
EndFunction

Function draw_builtin_assigned_weapon_info( ed:TEditor, data:TData, sprite:TSprite, weaponSlot:TStarfarerShipWeapon )
	'prep and compose string data
	Local wx% = sprite.sx + (weaponSlot.locations[0] + data.ship.center[1])*sprite.Scale
	Local wy% = sprite.sy + (-weaponSlot.locations[1] + data.ship.center[0])*sprite.Scale
	Local weapon_id$ = String( data.ship.builtInWeapons.ValueForKey( weaponSlot.id )) 'data.find_assigned_slot_weapon( weaponSlot.id )
	Local current_weapon_str$ = ""
	If weapon_id
		Local wep_stats:TMap = TMap( ed.stock_weapon_stats.ValueForKey( weapon_id ))
		If wep_stats
			Local wep_name$ = String( wep_stats.ValueForKey( "name" ))
			If wep_name
				current_weapon_str :+ wep_name
			Else
				current_weapon_str :+ weapon_id
			EndIf
		Endif
	Else
		current_weapon_str :+ "empty"
	EndIf
	'set colors
	Local fg_color% = $FFFFFF
	Local bg_color% = $000000
	'draw textbox
	Local current_weapon_widget:TextWidget = TextWidget.Create( current_weapon_str )
	draw_container( wx - 30, wy, current_weapon_widget.w + 20, current_weapon_widget.h + 20, 1.0,0.5, fg_color,bg_color )
	draw_string( current_weapon_widget, wx - 40, wy, fg_color,bg_color, 1.0,0.5 )
EndFunction

Function draw_builtin_weapon_mount( wx%, wy%, weaponSlot:TStarfarerShipWeapon )
	Local fg_color% = $FFFFFF
	Local bg_color% = $000000
	'draw icon
	draw_weapon_mount( wx, wy, weaponSlot.angle, weaponSlot.arc, TRUE, 8, 16, 24, fg_color,bg_color )
EndFunction

'------------

Global cursor_color_ts% = 0

Function get_cursor_color%( invert%=FALSE )
	Local val% = 196.0 + 196.0*cos(0.90*Float(millisecs()-cursor_color_ts))
	If val < 0 Then val = 0 ElseIf val > 255 Then val = 255
	If invert
		val = 255 - val
	EndIf
	Return (val|(val Shl 8)|(val Shl 16))
EndFunction

Function reset_cursor_color_period%()
	cursor_color_ts = millisecs() - 200 'has the effect of making cos(...) come out to -1, reducing val to 0
EndFunction

Function get_rand_color%()
	Return Rnd()*Float($FFFFFF)
EndFunction

Function set_color( c% )
	SetColor( (c&$FF0000) Shr 16,(c&$FF00) Shr 8,(c&$FF) )
EndFunction
