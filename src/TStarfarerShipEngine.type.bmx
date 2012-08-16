'-----------------------

Type TStarfarerShipEngine
	Field angle#
	Field contrailSize#
	Field length#
	Field location#[]
	Field style$
	Field styleSpec:TStarfarerCustomEngineStyleSpec
	Field width#
	
	Method New()
		angle = 180.0
		contrailSize = 30.0
		length = 30.0
		location = [ 0.0, 0.0 ]
		style = "LOW_TECH"
		width = 10.0
	End Method

	Method Clone:TStarfarerShipEngine()
		Local copy:TStarfarerShipEngine = New TStarfarerShipEngine
		copy.angle = angle
		copy.contrailSize = contrailSize
		copy.length = length
		copy.location = location[..]
		copy.style = style
		If styleSpec
			copy.styleSpec = styleSpec.Clone()
		EndIf
		copy.width = width
		return copy
	End Method
End Type


'BLITZMAX: Y U NO TEMPLATES
Function remove_TStarfarerShipEngine:TStarfarerShipEngine[]( arr:TStarfarerShipEngine[], e:TStarfarerShipEngine )
	Local i%
	For i = 0 Until arr.length
		If e = arr[i] Then Exit
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


Function TStarfarerShipEngine_ToJSON$( source_object:Object, settings:TJSONEncodeSettings, override_type:TTypeId, indent% )
	If source_object = Null Then Return ""
	Local instance_settings:TJSONEncodeSettings = settings.Clone()
	Local this_type:TTypeId = TTypeId.ForName( "TStarfarerShipEngine" )
	Local styleSpec_field:TField = this_type.FindField( "styleSpec" )
	If TStarfarerShipEngine(source_object).styleSpec = Null
		instance_settings.IgnoreField( this_type, styleSpec_field )
	EndIf
	Return JSON._EncodeObject( source_object, instance_settings, this_type, indent )
EndFunction


