Type TStarfarerVariant
	Field displayName$
	Field hullId$
	Field variantId$
	Field fluxVents%
	Field fluxCapacitors%
	Field hullMods$[]
	Field weaponGroups:TStarfarerVariantWeaponGroup[]
	Field goalVariant%
	Field quality#
	Field permaMods$[]
	Field wings$[]
	
	Method New()
		displayName = "New Variant"
		hullId = "new_hull"
		variantId = "new_hull_variant"
		fluxVents = 0
		fluxCapacitors = 0
		hullMods = New String[0]
		weaponGroups = New TStarfarerVariantWeaponGroup[0]
		goalVariant = 1
		quality = 0
		permaMods = New String[0]
		wings = New String[0]
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
	
	Method Clone:TStarfarerVariant ()
		Local c:TStarfarerVariant = New TStarfarerVariant
		c.displayName = displayName + " Copy"
		c.hullId = hullId
		c.variantId = variantId + "_copy"
		c.fluxVents = fluxVents
		c.fluxCapacitors = fluxCapacitors
		c.hullMods = hullMods
		c.weaponGroups = new TStarfarerVariantWeaponGroup[weaponGroups.length] ' deep clone
		For Local i% = 0 Until weaponGroups.length
			c.weaponGroups[i] = weaponGroups[i].clone()
		Next
		c.goalVariant = goalVariant
		c.quality = quality
		c.permaMods = permaMods[..]
		c.wings = wings[..]
		Return c
	End Method

	Method CoerceTypes()
		For Local weaponGroup:TStarfarerVariantWeaponGroup = EachIn weaponGroups
			Fix_Map_TStrings( weaponGroup.weapons )
		Next
	EndMethod
	
	
End Type

