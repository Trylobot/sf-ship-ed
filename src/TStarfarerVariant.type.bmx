Type TStarfarerVariant
	Field displayName$
	Field goalVariant%
	Field hullId$
	Field variantId$
	Field fluxVents%
	Field fluxCapacitors%
	Field hullMods$[]
	Field permaMods$[]
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
	
	Method clone:TStarfarerVariant ()
		Local c:TStarfarerVariant = New TStarfarerVariant
		c.displayName = displayName + " Copy"
		c.goalVariant = goalVariant
		c.hullId = hullId
		c.variantId = variantId + "_copy"
		c.fluxVents = fluxVents
		c.fluxCapacitors = fluxCapacitors
		c.hullMods = hullMods
		c.permaMods = permaMods
		c.weaponGroups = weaponGroups[..]
		Return c
	End Method
	
End Type

