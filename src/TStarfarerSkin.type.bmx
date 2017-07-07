Type TStarfarerSkin
	Field baseHullId$
	Field skinHullId$
	Field hullName$
	Field spriteName$
	Field descriptionId$
	Field descriptionPrefix$
	Field fleetPoints%
	Field ordnancePoints%
	Field systemId$
	Field baseValue%
	Field baseValueMult#
	Field removeHints$[]
	Field addHints$[]
	Field removeBuiltInMods$[] ' hullmod ids
	Field builtInMods$[] ' hullmod ids
	Field removeWeaponSlots$[] ' weapon slot id's
	Field weaponSlotChanges:TMap'<String,TStarfarerShipWeapon>  weapon slot id --> TStarfarerShipWeapon
	Field removeBuiltInWeapons$[] ' weapon slot id's
	Field builtInWeapons:TMap'<String,String>  weapon slot id --> weapon id
	Field removeEngineSlots%[] ' engine slot indices (no id's)
	Field engineSlotChanges:TMap'<String,TStarfarerShipEngine>  engine slot index --> TStarfarerShipEngine
	
	Method New()
		baseHullId = "base_hull"
		skinHullId = "base_hull_skin"
		hullName = "Hull Skin"
		spriteName = "graphics/ships/skins/new_skin.png"
		descriptionId = "base_hull"
		descriptionPrefix = ""
		baseValue = 0
		baseValueMult = 1
		systemId = ""
		removeHints = New String[0]
		addHints = New String[0]
		removeBuiltInMods = New String[0]
		builtInMods = New String[0]
		removeWeaponSlots = New String[0]
		weaponSlotChanges = CreateMap()
		removeBuiltInWeapons = New String[0]
		builtInWeapons = CreateMap()
		removeEngineSlots = New Int[0]
		engineSlotChanges = CreateMap()
	End Method

End Type

