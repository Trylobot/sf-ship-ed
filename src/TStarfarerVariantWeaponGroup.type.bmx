Type TStarfarerVariantWeaponGroup
	Field autofire:TBoolean
	Field mode$
	Field weapons:TMap'<String,String>  weapon slot id --> weapon id
	
	Method New()
		autofire = New TBoolean; autofire.value = false
		mode = "LINKED"
		weapons = CreateMap()
	End Method
End Type

