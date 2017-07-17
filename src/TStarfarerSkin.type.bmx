Type TStarfarerSkin
	Field baseHullId$
	Field skinHullId$
	Field hullName$
	Field restoreToBaseHull%
	Field hullDesignation$
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
	Field weaponSlotChanges:TMap'<String,TStarfarerShipWeaponChange>  weapon slot id --> TStarfarerShipWeapon
	Field removeBuiltInWeapons$[] ' weapon slot id's
	Field builtInWeapons:TMap'<String,String>  weapon slot id --> weapon id
	Field removeEngineSlots%[] ' engine slot indices (no id's)
	Field engineSlotChanges:TMap'<String,TStarfarerShipEngineChange>  engine slot index (as string) --> TStarfarerShipEngine
	Field coversColor$
	
	Method New()
		baseHullId = "base_hull"
		skinHullId = "base_hull_skin"
		hullName = "Hull Skin"
		restoreToBaseHull = False
		hullDesignation = "FRIGATE"
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
		coversColor = ""
	End Method

	Method Clone:TStarfarerSkin(dst:TStarfarerSkin = Null)
		If Not dst Then dst = New TStarfarerSkin
		MemMove(Byte Ptr (dst), Byte Ptr (Self), SizeOf(Self) )
		Return dst
	End Method

	' primitive, manual type hinting (ugh)
	Method CoerceTypes()
		Fix_Map_Arbitrary( weaponSlotChanges, "TStarfarerShipWeaponChange", "parse_skin_weapon" )
		Fix_Map_TStrings( builtInWeapons )
		Fix_Map_Arbitrary( engineSlotChanges, "TStarfarerShipEngineChange" )
	EndMethod

End Type

