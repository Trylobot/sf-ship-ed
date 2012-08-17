
Type TStarfarerShipWeapon
	Field angle#
	Field arc#
	Field id$
	Field locations#[]
	Field mount$
	Field size$
	Field type_$
	'derived data
	Method is_launch_bay%()
		Return (type_ = "LAUNCH_BAY" Or (locations.length > 2))
	EndMethod
	'ctor
	Method New()
		angle = 0.0
		arc = 0.0
		id = "WS 001"
		locations = [ 0.0, 0.0 ]
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
		return copy
	End Method
End Type

'BLITZMAX: Y U NO TEMPLATES
Function remove_TStarfarerShipWeapon:TStarfarerShipWeapon[]( arr:TStarfarerShipWeapon[], w:TStarfarerShipWeapon )
	Local i%
	For i = 0 Until arr.length
		If w = arr[i] Then Exit
	Next
	If i = arr.length Then return arr 'nothing to remove
	
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

