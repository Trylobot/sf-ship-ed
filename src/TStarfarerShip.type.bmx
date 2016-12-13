Type TStarfarerShip
	Field bounds#[]
	Field center#[]
	Field collisionRadius#
	Field engineSlots:TStarfarerShipEngine[]
	Field height#
	Field width#
	Field hullId$
	Field hullName$
	Field hullSize$
	Field shieldCenter#[]
	Field shieldRadius#
	Field spriteName$
	Field style$
	Field viewOffset#
	Field weaponSlots:TStarfarerShipWeapon[]
	Field builtInWeapons:TMap'<String,String>  weapon slot id --> weapon id
	Field builtInMods$[]
	Field coversColor$

	
	Method New()
		bounds = New Float[0]
		center = [ 0.0, 0.0 ]
		shieldCenter = [ 0.0, 0.0 ]
		engineSlots = New TStarfarerShipEngine[0]
		weaponSlots = New TStarfarerShipWeapon[0]
		hullId = "new_hull"
		hullName = "New Hull"
		hullSize = "FRIGATE"
		spriteName = "graphics/ships/new_hull.png"
		style = "LOW_TECH"
		builtInWeapons = CreateMap()
		builtInMods = New String[0]
	End Method
	
	Method Clone:TStarfarerShip(dst:TStarfarerShip = Null)
		If Not dst Then dst = New TStarfarerShip
		MemMove(Byte Ptr (dst), Byte Ptr (Self), SizeOf(Self) )
		Return dst
	End Method
End Type


