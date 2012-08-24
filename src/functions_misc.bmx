
Function coord_string$( x!, y! )
	Return "("+json.FormatDouble(x,1)+","+json.FormatDouble(y,1)+")"
EndFunction

Function nearest_half#( x# )
	Return Floor((x*2.0) + 0.5)/2.0
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


