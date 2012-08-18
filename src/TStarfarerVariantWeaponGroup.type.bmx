Type TStarfarerVariantWeaponGroup
	Field autofire:TBoolean
	Field mode$
	Field weapons:TMap
	
	Method New()
		autofire = New TBoolean; autofire.value = false
		mode = "LINKED"
		weapons = CreateMap()
	End Method
End Type

