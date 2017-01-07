Type TStarfarerVariantWeaponGroup
	Field autofire:TBoolean
	Field mode$
	Field weapons:TMap'<String,String>  weapon slot id --> weapon id
	
	Method New()
		autofire = New TBoolean; autofire.value = false
		mode = "LINKED"
		weapons = CreateMap()
	End Method
	
	Method clone:TStarfarerVariantWeaponGroup()
		Local c:TStarfarerVariantWeaponGroup = New TStarfarerVariantWeaponGroup
		c.autofire = autofire
		c.mode = mode
		c.weapons = weapons.Copy()
		Return c
	End Method	
	
End Type

