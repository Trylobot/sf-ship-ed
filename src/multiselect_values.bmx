Function load_known_multiselect_values( ed:TEditor )
	'string values previously found
	ed.load_multiselect_value( "ship.engine.style", "HIGH_TECH" )
	ed.load_multiselect_value( "ship.engine.style", "LOW_TECH" )
	ed.load_multiselect_value( "ship.engine.style", "LOW_TECH_FIGHTER" )
	ed.load_multiselect_value( "ship.engine.style", "MIDLINE" )
	ed.load_multiselect_value( "ship.engine.style", "CUSTOM" )
	
	ed.load_multiselect_value( "ship.engine.styleId", "" )
	ed.load_multiselect_value( "ship.engine.styleId", "HIGH_TECH" )
	ed.load_multiselect_value( "ship.engine.styleId", "LOW_TECH" )
	ed.load_multiselect_value( "ship.engine.styleId", "MIDLINE" )
	ed.load_multiselect_value( "ship.engine.styleId", "midlineFlare" )
	
	ed.load_multiselect_value( "ship.engine.styleSpec.type", "SMOKE" )
	ed.load_multiselect_value( "ship.engine.styleSpec.type", "GLOW" )
	
	ed.load_multiselect_value( "ship.hullSize", "CAPITAL_SHIP" )
	ed.load_multiselect_value( "ship.hullSize", "CRUISER" )
	ed.load_multiselect_value( "ship.hullSize", "DESTROYER" )
	ed.load_multiselect_value( "ship.hullSize", "FIGHTER" )
	ed.load_multiselect_value( "ship.hullSize", "FRIGATE" )
	
	ed.load_multiselect_value( "ship.style", "HIGH_TECH" )
	ed.load_multiselect_value( "ship.style", "LOW_TECH" )
	ed.load_multiselect_value( "ship.style", "MIDLINE" )
	
	ed.load_multiselect_value( "ship.weapon.mount", "HARDPOINT" )
	ed.load_multiselect_value( "ship.weapon.mount", "HIDDEN" )
	ed.load_multiselect_value( "ship.weapon.mount", "TURRET" )
	
	ed.load_multiselect_value( "ship.weapon.size", "LARGE" )
	ed.load_multiselect_value( "ship.weapon.size", "MEDIUM" )
	ed.load_multiselect_value( "ship.weapon.size", "SMALL" )
	
	ed.load_multiselect_value( "ship.weapon.type", "BALLISTIC" )
	ed.load_multiselect_value( "ship.weapon.type", "ENERGY" )
	ed.load_multiselect_value( "ship.weapon.type", "LAUNCH_BAY" )
	ed.load_multiselect_value( "ship.weapon.type", "MISSILE" )
	ed.load_multiselect_value( "ship.weapon.type", "UNIVERSAL" )
	ed.load_multiselect_value( "ship.weapon.type", "BUILT_IN" )
	ed.load_multiselect_value( "ship.weapon.type", "SYSTEM" )
	ed.load_multiselect_value( "ship.weapon.type", "DECORATIVE" )
	ed.load_multiselect_value( "ship.weapon.type", "HYBRID" )
	ed.load_multiselect_value( "ship.weapon.type", "SYNERGY" )
	ed.load_multiselect_value( "ship.weapon.type", "COMPOSITE" )
	ed.load_multiselect_value( "ship.weapon.type", "STATION_MODULE" )
	
	ed.load_multiselect_value( "variant.weaponGroup.mode", "ALTERNATING" )
	ed.load_multiselect_value( "variant.weaponGroup.mode", "LINKED" )
	
	ed.load_multiselect_value( "ship_csv.shield type", "NONE" )
	ed.load_multiselect_value( "ship_csv.shield type", "OMNI" )
	ed.load_multiselect_value( "ship_csv.shield type", "FRONT" )
	ed.load_multiselect_value( "ship_csv.shield type", "PHASE" )
	
	ed.load_multiselect_value( "ship_csv.defense id", "" )
	ed.load_multiselect_value( "ship_csv.defense id", "phasecloak" )
	
	ed.load_multiselect_value( "wing_csv.formation", "V" )
	ed.load_multiselect_value( "wing_csv.formation", "CLAW" )
	ed.load_multiselect_value( "wing_csv.formation", "BOX" )
	ed.load_multiselect_value( "wing_csv.formation", "" )
	
	ed.load_multiselect_value( "wing_csv.role", "FIGHTER" )
	ed.load_multiselect_value( "wing_csv.role", "ASSAULT" )
	ed.load_multiselect_value( "wing_csv.role", "INTERCEPTOR" )
	ed.load_multiselect_value( "wing_csv.role", "BOMBER" )
	ed.load_multiselect_value( "wing_csv.role", "SUPPORT" )
	'ed.load_multiselect_value( "wing_csv.role", "" )
	
	ed.load_multiselect_value( "weapon.animationType", "GLOW" )
	ed.load_multiselect_value( "weapon.animationType", "GLOW_AND_FLASH" )
	ed.load_multiselect_value( "weapon.animationType", "MUZZLE_FLASH" )
	ed.load_multiselect_value( "weapon.animationType", "NONE" )
	ed.load_multiselect_value( "weapon.animationType", "SMOKE" )	
	'ed.load_multiselect_value( "weapon.animationType", "" )
	
	ed.load_multiselect_value( "weapon.barrelMode", "ALTERNATING" )
	ed.load_multiselect_value( "weapon.barrelMode", "ALTERNATING_BURST" )
	ed.load_multiselect_value( "weapon.barrelMode", "LINKED" )	
	'ed.load_multiselect_value( "weapon.barrelMode", "" )
	
	ed.load_multiselect_value( "weapon.size", "LARGE" )
	ed.load_multiselect_value( "weapon.size", "MEDIUM" )
	ed.load_multiselect_value( "weapon.size", "SMALL" )
	
	ed.load_multiselect_value( "weapon.specClass", "beam" )
	ed.load_multiselect_value( "weapon.specClass", "projectile" )
	
	ed.load_multiselect_value( "weapon.type", "BALLISTIC" )
	ed.load_multiselect_value( "weapon.type", "ENERGY" )
	ed.load_multiselect_value( "weapon.type", "MISSILE" )
	ed.load_multiselect_value( "weapon.type", "SYSTEM" )
	ed.load_multiselect_value( "weapon.type", "DECORATIVE" )
	
	ed.load_multiselect_value( "weapon.interruptibleBurst", "False" )	
	ed.load_multiselect_value( "weapon.interruptibleBurst", "True" )
	
	ed.load_multiselect_value( "weapon.autocharge", "False" )	
	ed.load_multiselect_value( "weapon.autocharge", "True" )
	
	ed.load_multiselect_value( "weapon.requiresFullCharge", "False" )	
	ed.load_multiselect_value( "weapon.requiresFullCharge", "True" )	
	
	ed.load_multiselect_value( "weapon.beamFireOnlyOnFullCharge", "False" )	
	ed.load_multiselect_value( "weapon.beamFireOnlyOnFullCharge", "True" )
	
	ed.load_multiselect_value( "weapon.convergeOnPoint", "False" )	
	ed.load_multiselect_value( "weapon.convergeOnPoint", "True" )
	
	ed.load_multiselect_value( "weapon.darkCore", "False" )	
	ed.load_multiselect_value( "weapon.darkCore", "True" )

	ed.load_multiselect_value( "weapon.textureType", "CUSTOM" )
	ed.load_multiselect_value( "weapon.textureType", "SMOOTH" )
	ed.load_multiselect_value( "weapon.textureType", "MEDIUM" )
	ed.load_multiselect_value( "weapon.textureType", "ROUGH" )
	ed.load_multiselect_value( "weapon.textureType", "CHUNKY" )
	ed.load_multiselect_value( "weapon.textureType", "ROUGH2" )
	ed.load_multiselect_value( "weapon.textureType", "WEAVE" )
	ed.load_multiselect_value( "weapon.textureType", "LASER" )
EndFunction
