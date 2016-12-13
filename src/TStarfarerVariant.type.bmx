Type TStarfarerVariant
	Field displayName$
	Field hullId$
	Field variantId$
	Field fluxVents%
	Field fluxCapacitors%
	Field hullMods$[]
	Field weaponGroups:TStarfarerVariantWeaponGroup[]
	Field quality#
	
	Method New()
		displayName = "New Variant"
		hullId = "new_hull"
		variantId = "new_hull_variant"
		fluxVents = 0
		fluxCapacitors = 0
		hullMods = New String[0]
		weaponGroups = New TStarfarerVariantWeaponGroup[0]
	EndMethod

	Method getAllWeapons:TMap () ' <String,String>  weapon slot id --> weapon id
		Local weaponMap:TMap = CreateMap ()
		For Local weaponGroup:TStarfarerVariantWeaponGroup = EachIn weaponGroups
			For Local key$ = EachIn MapKeys(weaponGroup.weapons)
				MapInsert (weaponMap, key, MapValueForKey(weaponGroup.weapons, key))
			Next
		Next
		Return weaponMap 
	EndMethod
End Type

