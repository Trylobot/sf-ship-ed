
Type TStarfarerShipWeapon
	Field angle#
	Field arc#
	Field id$
	Field locations#[]
	Field position#[]
	Field mount$	
	Field size$
	Field type_$
	
	'derived field
	Method is_launch_bay%()
		Return (type_ = "LAUNCH_BAY" Or (locations.length > 2))
	EndMethod
	'derived field
	Method is_builtin%()
		Return (type_ = "BUILT_IN")
	EndMethod
	'derived field
	Method is_system%()
		Return (type_ = "SYSTEM")
	EndMethod
	'derived field
	Method is_decorative%()
		Return (type_ = "DECORATIVE")
	EndMethod
	'derived field
	Method is_visible_to_variant%()
		Return Not is_launch_bay() ..
		  And  Not is_system() ..
		  And  Not is_decorative()
	EndMethod
	'derived field
	Method is_station_module%()
		Return (type_ = "STATION_MODULE" )
	End Method
	'derived field
	Method is_builtin_or_decorative%()
		Select type_
			Case "BUILT_IN", "DECORATIVE"
				Return True
		EndSelect
		Return False
	EndMethod
	
	Method New()
		angle = 0.0
		arc = 0.0
		id = "WS 001"
		locations = [ 0.0, 0.0 ]
		position = Null
		mount = "TURRET"
		size = "MEDIUM"
		type_ = "ENERGY"
	End Method

	Method Clone:TStarfarerShipWeapon()
		Local copy:TStarfarerShipWeapon = New TStarfarerShipWeapon
		copy.angle = angle
		copy.arc = arc
		copy.id = id
		copy.locations = locations[..]
		copy.mount = mount
		copy.size = size
		copy.type_ = type_
		Return copy
	End Method
End Type


Function predicate_omit_position%( val:TValue, root:TValue )
	Return (TNull(val) <> Null Or TArray(val).elements.IsEmpty())
EndFunction

Function remove_TStarfarerShipWeapon:TStarfarerShipWeapon[]( arr:TStarfarerShipWeapon[], w:TStarfarerShipWeapon )
	Local i%
	For i = 0 Until arr.length
		If w = arr[i] Then Exit
	Next
	If i = arr.length Then Return arr 'nothing to remove
	
	If i >= 0 And i < arr.Length
		If arr.Length = 1
			Return Null
		Else
			For i = i Until arr.Length-1
				arr[i] = arr[i+1]
			Next
			Return arr[..arr.length-1]
		End If
	Else
		Return arr
	End If
End Function

