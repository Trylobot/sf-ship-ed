Type TStarfarerVariantWeaponGroup
	Field autofire:TJSONBoolean
	Field mode$
	Field weapons:TMap
	
	Method New()
		autofire = TJSONBoolean.Create( false )
		mode = "LINKED"
		weapons = CreateMap()
	End Method
End Type

