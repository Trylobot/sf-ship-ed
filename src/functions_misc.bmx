
Function find_rect_verts( x_o#, y_o#, r_w#, r_h#, s#, p_x#, p_y#, zp_x#, zp_y#, ix# Var, iy# Var, iw# Var, ih# Var )
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
	Return Floor( (x * 2.0) + 0.5) / 2.0
EndFunction

Rem
round a Float 
mode 0 = do not round
mode 1 = round to nearest_half
moud 2 = round to nearest whole number
EndRem
Function RoundFloat#( x#, mode% = 0)
	Select mode
	Case 0
		Return x
	Case 1
		Return Floor( (x * 2.0) + 0.5) / 2.0
	Case 2
		Return Floor (x) + (x Mod 1 >= 0.5)
	End Select

EndFunction

Function coord_string$( x!, y! )
	Return "("+json.FormatDouble(x,1)+","+json.FormatDouble(y,1)+")"
EndFunction


Function remove_pair#[]( arr#[], i% )
	If i >= 0 And i < arr.Length-1
		If arr.Length = 2 Then Return Null Else Return arr[..i] + arr[i + 2..]
	Else
		Return arr
	End If
EndFunction

Function remove_at#[]( arr#[], i% )
	If i >= 0 And i < arr.Length
		If arr.Length = 1 Then Return Null Else Return arr[..i] + arr[i + 1..]
	Else
		Return arr
	End If
EndFunction

Function calc_distance#( x1#, y1#, x2#, y2# )
	Local diff_x#, diff_y#
	diff_x = x2 - x1
	diff_y = y2 - y1
	Return RoundFloat(Sqr( diff_x * diff_x + diff_y * diff_y ), DO_ROUND)
EndFunction

Function calc_angle#( x1#, y1#, x2#, y2# )
	Local diff_x#, diff_y#
	diff_x = x2 - x1
	diff_y = y2 - y1
	Return RoundFloat( ATan2( diff_y, diff_x ), DO_ROUND)
EndFunction

Function calc_dist_from_point_to_segment#( px#, py#, s1x#, s1y#, s2x#, s2y# )
	s2x :- s1x
	s2y :- s1y
	px :- s1x
	py :- s1y
	Local dotprod# = px * s2x + py * s2y
	Local projlenSq#
	If dotprod <= 0.0
		projlenSq = 0.0
	Else
		px = s2x - px
		py = s2y - py
		dotprod = px * s2x + py * s2y
		If dotprod <= 0.0
			projlenSq = 0.0
		Else
		projlenSq = dotprod * dotprod / (s2x * s2x + s2y * s2y)
		EndIf
	EndIf
	Local lenSq# = px * px + py * py - projlenSq
	If lenSq < 0 Then lenSq = 0
	Return Sqr(lenSq)
'	Local s_len# = calc_distance( s1x, s1y, s2x, s2y )
'	If s_len = 0 Then Return calc_distance( px, py, s1x, s1y )
'	Local t# = ( (px - s1x) * (s2x - s1x) + (py - s1y) * (s2y - s1y) ) / s_len
'	If t < 0
'		Return calc_distance( px, py, s1x, s1y )
'	Else If t > 0
'		Return calc_distance( px, py, s2x, s2y )
'	Else
'		Return calc_distance( px,py, (s1x + t*(s2x - s1x)),(s1y + t*(s2y - s1y)) )
'	EndIf
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
	If Not map Then Return 0
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

Function in_int_array%( val%, arr%[] )
	If Not arr Then Return False
	For Local i% = 0 Until arr.Length
		If arr[i] = val Then Return True
	Next
	Return False
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
		For Local key:Object = EachIn map.Keys()
			Local val:TString = TString( map.ValueForKey( key ))
			If val
				map.Insert( key, val.value )
			EndIf
		Next
	EndIf
EndFunction

' semi-reflective version of Fix_Map_TStrings
'   intended for use with intermediate JSON data, to get it the rest of the way there
' does not modify keys
Function Fix_Map_Arbitrary( map:TMap, target_type$, transforms_set$=Null )
	If map And Not map.IsEmpty()
		Local destination_type_id:TTypeId = TTypeId.ForName( target_type )
		If destination_type_id
			'DebugLog("  "+destination_type_id.Name())
			For Local key:Object = EachIn map.Keys()
				' TODO: self: fucking implement this in rjson for fucks sake, it's getting ridiculous
				Local intermediate_object:TValue = TValue( map.ValueForKey( key ))
				'DebugLog("    "+String(key)+":"+TTypeId.ForObject(intermediate_object).Name())
				If transforms_set
					json.execute_transforms( transforms_set, intermediate_object )
				EndIf
				Local destination_object:Object = json.initialize_object( intermediate_object, destination_type_id )
				'DebugLog("      --> "+String(key)+":"+TTypeId.ForObject(destination_object).Name())
				map.Insert( key, destination_object )
			Next
		EndIf
	EndIf
EndFunction

Function CurveValue:Float(Current:Float, Destination:Float, Curve:Int)
	Current = Current + ( (Destination - Current) /Curve)
	Return Current
End Function

