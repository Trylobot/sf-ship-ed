Type TStarfarerSkin
	Field baseHullId$
	Field skinHullId$
	Field hullName$
	Field descriptionId$
	Field descriptionPrefix$
	Field fleetPoints%
	Field ordnancePoints%
	Field systemId$
	Field baseValueMult#
	Field removeHints$[]
	Field addHints$[]
	Field spriteName$
	Field removeWeaponSlots$[]' weapon slot id's
	Field removeEngineSlots%[]' engine slot indices (no id's)
	Field removeBuiltInMods$[]' hullmod ids
	Field removeBuiltInWeapons$[]' weapon slot id's
	Field builtInMods$[]' hullmod ids
	Field builtInWeapons:TMap'<String,String>  weapon slot id --> weapon id
	Field weaponSlotChanges:TMap'<String,TStarfarerShipWeapon>  weapon slot id --> TStarfarerShipWeapon
	
	Method New()
		baseHullId = "base_hull"
		skinHullId = "skin_hull"
		hullName = "Skin Hull"
		descriptionId = "base_hull"
		descriptionPrefix = ""
		baseValueMult = 1
		systemId = ""
		spriteName = "graphics/ships/new_hull.png"
		removeHints = New String[0]
		addHints = New String[0]
		removeWeaponSlots = New String[0]
		removeEngineSlots = New Int[0]
		removeBuiltInMods = New String[0]
		removeBuiltInWeapons = New String[0]
		builtInMods = New String[0]
		builtInWeapons = CreateMap()
		weaponSlotChanges = CreateMap()
	End Method

End Type

