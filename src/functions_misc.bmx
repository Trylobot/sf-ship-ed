
Function find_rect_verts( x_o#, y_o#, r_w#, r_h#, s#, p_x#, p_y#, zp_x#, zp_y#, ix# var, iy# var, iw# var, ih# var )
	ix = x_o - 0.5*s*r_w + p_x + zp_x
	iy = y_o - 0.5*s*r_h + p_y + zp_y
	iw = s*r_w
	ih = s*r_h
EndFunction

Function map_xy( x_in#, y_in#, x_out# Var, y_out# Var, translate_x#, translate_y#, scale#, round_to_half% = True )
	x_out = (x_in - translate_x) / scale
	y_out = (y_in - translate_y) / scale
	If round_to_half
		x_out = nearest_half( x_out )
		y_out = nearest_half( y_out )
	End If
EndFunction

Function nearest_half#( x# )
	Return Floor((x*2.0) + 0.5)/2.0
EndFunction

Function coord_string$( x!, y! )
	Return "("+json.FormatDouble(x,1)+","+json.FormatDouble(y,1)+")"
EndFunction


Function remove_pair#[]( arr#[], i% )
	If i >= 0 And i < arr.Length-1
		If arr.Length = 2
			Return Null
		Else
			For i = i Until arr.Length-2 Step 2
				arr[i] = arr[i+2]
				arr[i+1] = arr[i+3]
			Next
			Return arr[..arr.length-2]
		End If
	Else
		Return arr
	End If
EndFunction

Function remove_at#[]( arr#[], i% )
	If i >= 0 And i < arr.Length
		If arr.Length = 1
			Return Null
		Else
			For i = i Until arr.Length
				arr[i] = arr[i+1]
			Next
			Return arr[..arr.length-1]
		End If
	Else
		Return arr
	End If
EndFunction

Function calc_distance#( x1#, y1#, x2#, y2# )
	Local diff_x#, diff_y#
	diff_x = x2 - x1
	diff_y = y2 - y1
	Return Sqr( diff_x*diff_x + diff_y*diff_y )
EndFunction

Function calc_angle#( x1#, y1#, x2#, y2# )
	Local diff_x#, diff_y#
	diff_x = x2 - x1
	diff_y = y2 - y1
	Return ATan2( diff_y, diff_x )
EndFunction

Function calc_dist_from_point_to_segment#( px#,py#, s1x#,s1y#, s2x#,s2y# )
	Local s_len# = calc_distance( s1x,s1y, s2x,s2y )
	If s_len = 0 Then Return calc_distance( px,py, s1x,s1y )
	Local t# = ((px - s1x)*(s2x - s1x) + (py - s1y)*(s2y - s1y)) / s_len
	If t < 0 
		Return calc_distance( px,py, s1x,s1y )
	Else If t > 0
		Return calc_distance( px,py, s2x,s2y )
	Else
		Return calc_distance( px,py, (s1x + t*(s2x - s1x)),(s1y + t*(s2y - s1y)) )
	EndIf
EndFunction

Function ang_wrap#( a# ) 'forces the angle into the range [-180,180]
	If a < -180
		Local mult% = Abs( (a-180) / 360 )
		a :+ mult * 360
	Else If a > 180
		Local mult% = Abs( (a+180) / 360 )
		a :- mult * 360
	End If
	Return a
EndFunction

Function cartesian_to_polar( x#, y#, r# Var, a# Var )
	r = Sqr( x*x + y*y )
	a = ATan2( y, x )
EndFunction

Function polar_to_cartesian( r#, a#, x# Var, y# Var )
	x = r*Cos( a )
	y = r*Sin( a )
EndFunction

Function count_keys%( map:TMap )
	If not map Then return 0
	Local count% = 0
	For Local k$ = EachIn map.Keys()
		count :+ 1
	Next
	Return count
EndFunction

Function zero_pad$( num%, length% )
	Local str$ = ""
	str :+ num
	While str.length < length
		str = "0" + str
	EndWhile
	Return str
EndFunction

Function in_str_array%( val$, arr$[] )
	If Not arr Then Return False
	For Local i% = 0 Until arr.Length
		If arr[i] = val Then Return True
	Next
	Return False
EndFunction


'Temporary Fix to address not being able to override types with transforms
' That functionality should also address forcing null arrays to [] and null objects to {}
Function Fix_Map_TStrings( map:TMap )
	If map And Not map.IsEmpty()
		For Local key$ = EachIn map.Keys()
			Local val:TString = TString( map.ValueForKey( key ))
			If val
				map.Insert( key, val.value )
			EndIf
		Next
	EndIf
EndFunction


