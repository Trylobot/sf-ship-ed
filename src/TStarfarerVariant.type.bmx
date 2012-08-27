Type TStarfarerVariant
	Field displayName$
	Field hullId$
	Field variantId$
	Field fluxVents%
	Field fluxCapacitors%
	Field hullMods$[]
	Field weaponGroups:TStarfarerVariantWeaponGroup[]
	
	Method New()
		displayName = "New Variant"
		hullId = "new_hull_id"
		variantId = "new_hull_variant_id"
		fluxVents = 0
		fluxCapacitors = 0
		hullMods = New String[0]
		weaponGroups = New TStarfarerVariantWeaponGroup[0]
	EndMethod

End Type

