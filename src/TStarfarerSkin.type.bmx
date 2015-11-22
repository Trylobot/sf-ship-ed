Type TStarfarerSkin
	Field baseHullId$
	Field skinHullId$
	Field hullName$
	Field descriptionId$
	Field descriptionPrefix$
	Field ordnancePoints%
	Field baseValueMult#
	Field spriteName$
	Field removeWeaponSlots$[]' weapon slot id's
	Field removeEngineSlots%[]' engine slot indices (no id's)
	Field removeBuiltInMods$[]' hullmod ids
	Field removeBuiltInWeapons$[]' weapon slot id's
	Field builtInMods$[]' hullmod ids
	Field builtInWeapons:TMap'<String,String>  weapon slot id --> weapon id
	
	Method New()
		baseHullId = "base_hull"
		skinHullId = "skin_hull"
		hullName = "Skin Hull"
		descriptionId = "base_hull"
		descriptionPrefix = ""
		ordnancePoints = 0
		baseValueMult = 1
		spriteName = "graphics/ships/new_hull.png"
		removeWeaponSlots = New String[0]
		removeEngineSlots = New Int[0]
		removeBuiltInMods = New String[0]
		removeBuiltInWeapons = New String[0]
		builtInMods = New String[0]
		builtInWeapons = CreateMap()
	End Method

End Type

