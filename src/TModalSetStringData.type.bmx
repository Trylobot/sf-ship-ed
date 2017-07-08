
Type TModalSetStringData Extends TSubroutine
	
	Field i%, j%, val$
	Field enum_set:TMap

	Field target:Object
	Field console_cursor_i%
	Field modified%

	Field line_i%
	Field line_enum_i%
	Field labels:TextWidget
	Field values:TextWidget
	'Field cursor:TextWidget

	Field DATATYPE_STRING% = 0 'string types are entered free-form and then converted to/from JSON
	Field DATATYPE_ENUM%   = 1 'enum types are restricted to a discrete set of values and use arrow keys to select
	Field data_types%[]
	Field enum_defs$[][]

	Field MODE_SHIP%               = 0
	Field MODE_SHIP_WEAPON%        = 1
	Field MODE_SHIP_ENGINE%        = 2
	Field MODE_VARIANT%            = 3
	Field MODE_WEAPON%             = 4
	Field MODE_SKIN%               = 5
	Field MODE_SKIN_WEAPON_CHANGE% = 6
	Field MODE_SHIP_ENGINE_CHANGE% = 7
	Field subroutine_mode%

	Field customBeamTexTmp:TArray

	Method Activate( ed:TEditor, data:TData, sprite:TSprite )
		ed.last_mode = ed.mode
		ed.mode = "string_data"
		ed.edit_strings_weapon_i = - 1
		ed.edit_strings_engine_i = - 1
		FlushEvent()
		If sprite 'context-sensitive editing
			Local img_x#, img_y#
			sprite.get_img_xy( MouseX, MouseY, img_x, img_y )
			If ed.last_mode = "weapon_slots"
				ed.edit_strings_weapon_i = data.find_nearest_weapon_slot( img_x, img_y )
			ElseIf ed.last_mode = "engine_slots"
				ed.edit_strings_engine_i = data.find_nearest_engine( img_x, img_y )
			EndIf
		EndIf
		'set the subroutine module state
		line_i = 0
		line_enum_i = 0
		modified = False
		DebugLogFile(" Activate String Data Editor")
		If ed.program_mode = "ship"
			If ed.edit_strings_weapon_i <> - 1
				subroutine_mode = MODE_SHIP_WEAPON
				target = data.ship.weaponSlots[ed.edit_strings_weapon_i]				
				DebugLogFile(" Editing Weaopn Slot " + ed.edit_strings_weapon_i + " " + (TStarfarerShipWeapon (target) ).id)
			ElseIf ed.edit_strings_engine_i <> - 1
				subroutine_mode = MODE_SHIP_ENGINE
				target = data.ship.engineSlots[ed.edit_strings_engine_i]
				DebugLogFile(" Editing Engine Slot " + ed.edit_strings_engine_i)				
			Else
				subroutine_mode = MODE_SHIP
				target = data.ship
				DebugLogFile(" Editing Ship " + data.ship.hullId)					
			EndIf
		Else If ed.program_mode = "skin"
			If ed.edit_strings_weapon_i <> - 1
				subroutine_mode = MODE_SKIN_WEAPON_CHANGE
				'target = data.skin.weaponSlotChanges.ValueForKey(ed.edit_strings_weapon_i)
				'DebugLogFile(" Editing Weaopn Slot " + ed.edit_strings_weapon_i + " " + (TStarfarerShipWeapon (target) ).id)
			ElseIf ed.edit_strings_engine_i <> - 1
				subroutine_mode = MODE_SHIP_ENGINE_CHANGE
				'target = data.ship.engineSlotChanges.ValueForKey(ed.edit_strings_engine_i)
				'DebugLogFile(" Editing Engine Slot " + ed.edit_strings_engine_i + " " + edit_strings_engine_i)
			Else
				subroutine_mode = MODE_SKIN
				target = data.skin
				DebugLogFile(" Editing Ship " + data.skin.skinHullId + "("+data.skin.baseHullId+")")
			EndIf
		Else If ed.program_mode = "variant"
			subroutine_mode = MODE_VARIANT
			target = data.variant
			DebugLogFile(" Editing Variant " + data.variant.variantId)
		Else If ed.program_mode = "weapon"
			subroutine_mode = MODE_WEAPON
			target = data.weapon
			DebugLogFile(" Editing Weapon " + data.weapon.id)
		EndIf
		'load data from appropriate source
		Load( ed, data, sprite )
		If data_types[line_i] = DATATYPE_STRING
			values.lines[line_i] = CONSOLE.Update( values.lines[line_i],, console_cursor_i, modified )
		EndIf
		data.hold_snapshot(True)
	EndMethod

	Method Update( ed:TEditor, data:TData, sprite:TSprite )
		Select EventID()
			Case EVENT_KEYDOWN, EVENT_KEYREPEAT
				Select EventData()
					Case KEY_DOWN, KEY_TAB, KEY_ENTER
						line_i = Min( line_i + 1, labels.lines.length - 1 )
						'update_cursor( data, True )
						reset_cursor_color_period()
					Case KEY_UP
						line_i = Max( line_i - 1, 0 )
						'update_cursor( data, True )
						reset_cursor_color_period()
				EndSelect
				Select data_types[line_i]
					Case DATATYPE_STRING
						modified = False
						values.lines[line_i] = CONSOLE.Update( values.lines[line_i],, console_cursor_i, modified )
						'update_cursor( data )
						If modified
							Save( ed, data, sprite )
							values.update_size()				
						EndIf
					Case DATATYPE_ENUM
						modified = False
						If EventData() = KEY_RIGHT
							For i = 0 Until enum_defs[line_i].Length
								If enum_defs[line_i][i] = values.lines[line_i]
									If (i + 1) < enum_defs[line_i].length
										modified = True
										values.lines[line_i] = enum_defs[line_i][i + 1]
										line_enum_i = i + 1
										Exit
									EndIf
								EndIf
							Next
						EndIf
						If EventData() = KEY_LEFT
							For i = 0 Until enum_defs[line_i].Length
								If enum_defs[line_i][i] = values.lines[line_i]
									If (i - 1) >= 0
										modified = True
										values.lines[line_i] = enum_defs[line_i][i - 1]
										line_enum_i = i - 1
										Exit
									EndIf
								EndIf
							Next
						EndIf
						If modified
							'update_cursor( data )
							Save( ed, data, sprite )
							reset_cursor_color_period()
							'///////////////////////
							'Custom Engines check
							If subroutine_mode = MODE_SHIP_ENGINE ..
							And labels.lines[line_i] = "ship.engine.style"
								If TStarfarerShipEngine(target).style <> "CUSTOM"
									TStarfarerShipEngine(target).styleId = ""
									TStarfarerShipEngine(target).styleSpec = Null
								Else ' style is custom
									TStarfarerShipEngine(target).styleId = ed.get_default_multiselect_value( "ship.engine.styleId" )
									If TStarfarerShipEngine(target).styleId <> ""
										TStarfarerShipEngine(target).styleSpec = Null
									Else ' style id is blank/null (not specified)
										TStarfarerShipEngine(target).styleSpec = New TStarfarerCustomEngineStyleSpec
									EndIf
								EndIf
								Load( ed,data,sprite ) 're-create string-editing window
								'Save( ed,data,sprite )
							ElseIf subroutine_mode = MODE_SHIP_ENGINE ..
							And TStarfarerShipEngine(target).style = "CUSTOM" ..
							And labels.lines[line_i] = "ship.engine.styleId"
								If TStarfarerShipEngine(target).styleId <> ""
									TStarfarerShipEngine(target).styleSpec = Null
								Else ' style id is blank/null (not specified)
									TStarfarerShipEngine(target).styleSpec = New TStarfarerCustomEngineStyleSpec
								EndIf
								Load( ed, data, sprite ) 're-create string-editing window
								'Save( ed, data, sprite )
							Else If subroutine_mode = MODE_WEAPON
								Load( ed, data, sprite ) 're-create string-editing window
								'Save( ed, data, sprite )
							EndIf
							''///////////////////////
							''Built-In Weapons check
							'If subroutine_mode = MODE_SHIP_WEAPON ..
							'And labels.lines[line_i] = "ship.builtInWeapons.id"
							'	If TStarfarerShipWeapon(target).type_ = "BUILT_IN"
							'		data.ship.builtInWeapons.Insert( TStarfarerShipWeapon(target).id, ed.get_default_multiselect_value( "ship.builtInWeapons.id" ))
							'	Else ' not built in
							'		data.ship.builtInWeapons.Remove( TStarfarerShipWeapon(target).id )
							'	EndIf
							'	Load( ed,data,sprite ) 're-create string-editing window
							'	Save( ed,data,sprite )
							'EndIf
							'///////////////////////
						EndIf
				EndSelect
			Case EVENT_GADGETACTION, EVENT_MENUACTION
				Select EventSource()
					Case functionMenu[MENU_FUNCTION_EXIT]
						ed.mode = ed.last_mode
						Return
				EndSelect
		End Select
	EndMethod

	Rem
	Method update_cursor( data:TData, reset_console_cursor_i% = False )
		If values
			cursor = TextWidget.Create( values )
			For i = 0 Until cursor.lines.length
				If i <> line_i
					cursor.lines[i] = ""
				Else 'i == line_i
					Select data_types[line_i]
						Case DATATYPE_STRING
							If reset_console_cursor_i Then console_cursor_i = cursor.lines[i].Length
							cursor.lines[i] = "  " + RSet( "", console_cursor_i ) + "|" 'vertical line
						Case DATATYPE_ENUM
							cursor.lines[i] = "<-" + RSet( "", cursor.lines[i].Length ) + "->" 'left/right arrows
					EndSelect
				EndIf
			Next
		Else
			cursor = Null
		EndIf
	EndMethod
	EndRem

	Method Draw( ed:TEditor, data:TData, sprite:TSprite )
		
		draw_container( (W_MID - (10 + labels.w + 10) ), H_MID, (10 + labels.w + 10) + (10 + values.w + 10), (10 + labels.h + 10), 0.0, 0.5 )
		draw_string( labels, (W_MID - 10), H_MID,,, 1.0, 0.5 )
		draw_string( values, (W_MID + 10), H_MID,,, 0.0, 0.5 )
		
		'draw_string( cursor, (W_MID + 10) - TextWidth("  "), H_MID, get_cursor_color(), $000000, 0.0, 0.5 )
		'testing
		'draw cursor
		Select data_types[line_i]
		Case DATATYPE_STRING
			draw_string( "_", (W_MID + 10) + TextWidth(values.lines[line_i][..console_cursor_i]), H_MID - (values.h / 2.0) + (line_i + 0.5) * LINE_HEIGHT, get_cursor_color(), $000000, 0.0, 0.5 )
		Case DATATYPE_ENUM
			draw_string( "<-", (W_MID + 10) - TextWidth("<-"), H_MID - (values.h / 2.0) + (line_i + 0.5) * LINE_HEIGHT, get_cursor_color(), $000000, 0.0, 0.5 )	
			draw_string( "->", (W_MID + 10) + TextWidth(values.lines[line_i]), H_MID - (values.h / 2.0) + (line_i + 0.5) * LINE_HEIGHT, get_cursor_color(), $000000, 0.0, 0.5 )
		End Select
		
		
	EndMethod

	Method Save( ed:TEditor, data:TData, sprite:TSprite )
		Select subroutine_mode
			'////////////////////////////////////////
			Case MODE_SHIP
				i = 0
				'TStarfarerShip(target).hullId = values.lines[i]; i:+1
				If line_i = i Then data.set_hullId( TStarfarerShip(target).hullId, values.lines[i] )
				i:+ 1
				TStarfarerShip(target).hullName = values.lines[i]; i:+1
				TStarfarerShip(target).hullSize = values.lines[i]; i:+1
				TStarfarerShip(target).style = values.lines[i]; i:+ 1
				TStarfarerShip(target).spriteName = values.lines[i]; i:+ 1
				TStarfarerShip(target).coversColor = values.lines[i]; i:+ 1
				data.update()
				data.take_snapshot(3)
			'//////////////////////////////////////
			Case MODE_SHIP_ENGINE
				i = 0
				TStarfarerShipEngine(target).style = values.lines[i]; i:+1
				'conditional chunk 1
				If values.lines.length >= i + 1 And TStarfarerShipEngine(target).style = "CUSTOM"
					TStarfarerShipEngine(target).styleId = values.lines[i]; i:+ 1
				EndIf
				'conditional chunk 2
				If values.lines.length >= i + 7 And TStarfarerShipEngine(target).styleSpec <> Null
					TStarfarerShipEngine(target).styleSpec.type_ = values.lines[i]; i:+ 1
					json.error_level = 0
					TStarfarerShipEngine(target).styleSpec.engineColor = Int[]( json.parse( values.lines[i], "Int[]" )); i:+1
					TStarfarerShipEngine(target).styleSpec.contrailColor = Int[]( json.parse( values.lines[i], "Int[]" )); i:+1
					json.error_level = 1
					TStarfarerShipEngine(target).styleSpec.contrailParticleSizeMult = values.lines[i].ToDouble(); i:+1
					TStarfarerShipEngine(target).styleSpec.contrailParticleDuration = values.lines[i].ToDouble(); i:+1
					TStarfarerShipEngine(target).styleSpec.contrailMaxSpeedMult = values.lines[i].ToDouble(); i:+1
					TStarfarerShipEngine(target).styleSpec.contrailAngularVelocityMult = values.lines[i].ToDouble(); i:+1
				EndIf
				data.update()
			'///////////////////////////////////////
			Case MODE_SHIP_WEAPON 
				i = 0
				TStarfarerShipWeapon(target).id = values.lines[i]; i:+1
				TStarfarerShipWeapon(target).mount = values.lines[i]; i:+1
				TStarfarerShipWeapon(target).size = values.lines[i]; i:+1
				TStarfarerShipWeapon(target).type_ = values.lines[i]; i:+1
				TStarfarerShipWeapon(target).angle = values.lines[i].ToDouble(); i:+ 1
				TStarfarerShipWeapon(target).arc = values.lines[i].ToDouble(); i:+ 1
				TStarfarerShipWeapon(target).locations[0] = values.lines[i].ToDouble(); i:+ 1
				TStarfarerShipWeapon(target).locations[1] = values.lines[i].ToDouble(); i:+1
				'If values.lines.length >= i + 1 And TStarfarerShipWeapon(target).type_ = "BUILT_IN"
				'	data.ship.builtInWeapons.Insert( TStarfarerShipWeapon(target).id, values.lines[i] ); i:+1
				'EndIf
				data.update()
				data.update_variant_enforce_hull_compatibility( ed )
				data.update_variant()
			'//////////////////////////////////////
			Case MODE_VARIANT 
				i = 0
				If line_i = i Then data.set_hullId( TStarfarerVariant(target).hullId, values.lines[i] )
				i:+1
				If line_i = i Then data.set_variantId( TStarfarerVariant(target).variantId, values.lines[i] )
				i:+1
				TStarfarerVariant(target).displayName = values.lines[i]; i:+1
				TStarfarerVariant(target).goalVariant = stringToBoolean(values.lines[i]); i:+1
				TStarfarerVariant(target).quality = values.lines[i].ToDouble(); i:+1
				'variable-length chunk 1
				For j = 0 Until TStarfarerVariant(target).weaponGroups.length
					TStarfarerVariant(target).weaponGroups[j].mode = values.lines[i]; i:+1
				Next
				data.update_variant()
			'//////////////////////////////////////
			Case MODE_WEAPON
				i = 0
				TStarfarerWeapon(target).id = values.lines[i]; i:+ 1
				Local specClass$ = TStarfarerWeapon(target).specClass
				TStarfarerWeapon(target).specClass = values.lines[i]; i:+ 1
				TStarfarerWeapon(target).size = values.lines[i]; i:+ 1
				TStarfarerWeapon(target).type_ = values.lines[i]; i:+ 1
				TStarfarerWeapon(target).fireSoundOne = values.lines[i]; i:+ 1
				TStarfarerWeapon(target).fireSoundTwo = values.lines[i]; i:+ 1
				TStarfarerWeapon(target).everyFrameEffect = values.lines[i]; i:+ 1				
			Select specClass
			Case "projectile"
				TStarfarerWeapon(target).projectileSpecId = values.lines[i]; i:+ 1
				TStarfarerWeapon(target).interruptibleBurst = stringToBoolean(values.lines[i]); i:+ 1
				TStarfarerWeapon(target).autocharge = stringToBoolean(values.lines[i]); i:+ 1
				TStarfarerWeapon(target).requiresFullCharge = stringToBoolean(values.lines[i]); i:+ 1
				TStarfarerWeapon(target).visualRecoil = values.lines[i].ToDouble(); i:+ 1
				TStarfarerWeapon(target).barrelMode = values.lines[i]; i:+ 1
				Local animationType$ = TStarfarerWeapon(target).animationType
				TStarfarerWeapon(target).animationType = values.lines[i]; i:+ 1
				Select animationType
				Case "GLOW"
					TStarfarerWeapon(target).glowColor = stringToFloatArray( values.lines[i]); i:+ 1
				Case "GLOW_AND_FLASH"
					TStarfarerWeapon(target).glowColor = stringToFloatArray(values.lines[i]); i:+ 1
					TStarfarerWeapon(target).muzzleFlashSpec.length = values.lines[i].ToDouble(); i:+ 1
					TStarfarerWeapon(target).muzzleFlashSpec.spread = values.lines[i].ToDouble(); i:+ 1
					TStarfarerWeapon(target).muzzleFlashSpec.particleSizeMin = values.lines[i].ToDouble(); i:+ 1
					TStarfarerWeapon(target).muzzleFlashSpec.particleSizeRange = values.lines[i].ToDouble(); i:+ 1
					TStarfarerWeapon(target).muzzleFlashSpec.particleDuration = values.lines[i].ToDouble(); i:+ 1
					TStarfarerWeapon(target).muzzleFlashSpec.particleCount = values.lines[i].ToInt(); i:+ 1
					TStarfarerWeapon(target).muzzleFlashSpec.particleColor = stringToFloatArray(values.lines[i]); i:+ 1
				Case "MUZZLE_FLASH"
					TStarfarerWeapon(target).muzzleFlashSpec.length = values.lines[i].ToDouble(); i:+ 1
					TStarfarerWeapon(target).muzzleFlashSpec.spread = values.lines[i].ToDouble(); i:+ 1
					TStarfarerWeapon(target).muzzleFlashSpec.particleSizeMin = values.lines[i].ToDouble(); i:+ 1
					TStarfarerWeapon(target).muzzleFlashSpec.particleSizeRange = values.lines[i].ToDouble(); i:+ 1
					TStarfarerWeapon(target).muzzleFlashSpec.particleDuration = values.lines[i].ToDouble(); i:+ 1
					TStarfarerWeapon(target).muzzleFlashSpec.particleCount = values.lines[i].ToInt(); i:+ 1
					TStarfarerWeapon(target).muzzleFlashSpec.particleColor = stringToFloatArray(values.lines[i]); i:+ 1				
				Case "SMOKE"
					TStarfarerWeapon(target).smokeSpec.particleSizeMin = values.lines[i].ToDouble(); i:+ 1	
					TStarfarerWeapon(target).smokeSpec.particleSizeRange = values.lines[i].ToDouble(); i:+ 1
					TStarfarerWeapon(target).smokeSpec.cloudParticleCount = values.lines[i].ToInt(); i:+ 1
					TStarfarerWeapon(target).smokeSpec.cloudDuration = values.lines[i].ToDouble(); i:+ 1
					TStarfarerWeapon(target).smokeSpec.cloudRadius = values.lines[i].ToDouble(); i:+ 1
					TStarfarerWeapon(target).smokeSpec.blowbackParticleCount = values.lines[i].ToInt(); i:+ 1
					TStarfarerWeapon(target).smokeSpec.blowbackDuration = values.lines[i].ToDouble(); i:+ 1
					TStarfarerWeapon(target).smokeSpec.blowbackLength = values.lines[i].ToDouble(); i:+ 1
					TStarfarerWeapon(target).smokeSpec.blowbackSpread = values.lines[i].ToDouble(); i:+ 1
					TStarfarerWeapon(target).smokeSpec.particleColor = stringToFloatArray(values.lines[i]); i:+ 1				
				Case "NONE"
				EndSelect
			Case "beam"
				TStarfarerWeapon(target).beamEffect = values.lines[i]; i:+ 1
				TStarfarerWeapon(target).beamFireOnlyOnFullCharge = stringToBoolean(values.lines[i]); i:+ 1
				TStarfarerWeapon(target).convergeOnPoint = stringToBoolean(values.lines[i]); i:+ 1
				TStarfarerWeapon(target).fringeColor = stringToFloatArray(values.lines[i]); i:+ 1
				TStarfarerWeapon(target).coreColor = stringToFloatArray(values.lines[i]); i:+ 1
				TStarfarerWeapon(target).darkCore = stringToBoolean( values.lines[i]); i:+ 1
				TStarfarerWeapon(target).glowColor = stringToFloatArray(values.lines[i]); i:+ 1
				TStarfarerWeapon(target).width = values.lines[i].ToDouble(); i:+ 1
				TStarfarerWeapon(target).textureScrollSpeed = values.lines[i].ToDouble(); i:+ 1
				TStarfarerWeapon(target).pixelsPerTexel = values.lines[i].ToDouble(); i:+ 1
'				Print values.lines[i]
'				DebugStop
				If values.lines[i] = "CUSTOM"
					If values.lines.length - 1 = i + 3
						TStarfarerWeapon(target).textureType = json.parse([values.lines[i + 1], values.lines[i + 2]].ToString() ); i:+ 3
					Else
						If Not customBeamTexTmp
							customBeamTexTmp = New TArray
							Local s:TString = TString.CreateFormString("graphics/fx/beamfringe.png")
							customBeamTexTmp.elements.AddFirst(s.copy() )
							s.value = "graphics/fx/beamcore.png"
							customBeamTexTmp.elements.AddLast(s.copy() )
							TStarfarerWeapon(target).textureType = customBeamTexTmp.Copy()
						Else
							TStarfarerWeapon(target).textureType = customBeamTexTmp.Copy()
						EndIf
						
					EndIf
				Else
					TStarfarerWeapon(target).textureType = TEmun.CreateFormString(values.lines[i]) ; i:+ 1
				EndIf
			EndSelect
				data.update_weapon()
		EndSelect
	EndMethod

	Method Load( ed:TEditor, data:TData, sprite:TSprite )
		json.formatted = False
		'setup edit box and initialize with values
		Select subroutine_mode
		'////////////////////////////////////////
		Case MODE_SHIP
			labels = TextWidget.Create( ..
				"ship.hullId" +"~n"+..
				"ship.hullName" +"~n"+..
				"ship.hullSize" +"~n"+..
				"ship.style" +"~n"+..
				"ship.spriteName" +"~n"+..
				"ship.coversColor" )
			values = TextWidget.Create( ..
				TStarfarerShip(target).hullId +"~n"+..
				TStarfarerShip(target).hullName +"~n"+..
				TStarfarerShip(target).hullSize +"~n"+..
				TStarfarerShip(target).style +"~n"+..
				TStarfarerShip(target).spriteName +"~n"+..
				TStarfarerShip(target).coversColor)
		'//////////////////////////////////////
		Case MODE_SHIP_ENGINE
			labels = TextWidget.Create( ..
				"ship.engine.style" )
			values = TextWidget.Create( ..
				TStarfarerShipEngine(target).style )
			If TStarfarerShipEngine(target).style = "CUSTOM"
				labels.append( TextWidget.Create( ..
					"ship.engine.styleId" ))
				values.append( TextWidget.Create( ..
					TStarfarerShipEngine(target).styleId ))
			EndIf
			If TStarfarerShipEngine(target).styleSpec <> Null
				labels.append( TextWidget.Create( ..
					"ship.engine.styleSpec.type" +"~n"+..
					"ship.engine.styleSpec.engineColor" +"~n"+..
					"ship.engine.styleSpec.contrailColor" +"~n"+..
					"ship.engine.styleSpec.contrailParticleSizeMult" +"~n"+..
					"ship.engine.styleSpec.contrailParticleDuration" +"~n"+..
					"ship.engine.styleSpec.contrailMaxSpeedMult" +"~n"+..
					"ship.engine.styleSpec.contrailAngularVelocityMult" ))
				values.append( TextWidget.Create( ..
					TStarfarerShipEngine(target).styleSpec.type_ + "~n" + ..
					json.stringify( TStarfarerShipEngine(target).styleSpec.engineColor ) + "~n" + ..
					json.stringify( TStarfarerShipEngine(target).styleSpec.contrailColor ) + "~n" + ..
					json.FormatDouble( TStarfarerShipEngine(target).styleSpec.contrailParticleSizeMult, 3 ) + "~n" + ..
					json.FormatDouble( TStarfarerShipEngine(target).styleSpec.contrailParticleDuration, 3 ) +"~n"+..
					json.FormatDouble( TStarfarerShipEngine(target).styleSpec.contrailMaxSpeedMult, 3 ) +"~n"+..
					json.FormatDouble( TStarfarerShipEngine(target).styleSpec.contrailAngularVelocityMult, 3 ) ) )
			EndIf
		'///////////////////////////////////////
		Case MODE_SHIP_WEAPON 
			labels = TextWidget.Create( ..
				"ship.weapon.id" +"~n"+..
				"ship.weapon.mount" +"~n"+..
				"ship.weapon.size" +"~n"+..
				"ship.weapon.type" +"~n"+..
				"ship.weapon.angle" +"~n"+..
				"ship.weapon.arc"+"~n"+..
				"ship.weapon.x"	+"~n"+..
				"ship.weapon.y"	)
			values = TextWidget.Create( ..
				TStarfarerShipWeapon(target).id +"~n"+..
				TStarfarerShipWeapon(target).mount +"~n"+..
				TStarfarerShipWeapon(target).size +"~n"+..
				TStarfarerShipWeapon(target).type_ +"~n"+..
				json.FormatDouble( TStarfarerShipWeapon(target).angle, 3 ) + "~n" + ..
				json.FormatDouble( TStarfarerShipWeapon(target).arc, 3 ) + "~n" + ..
				json.FormatDouble(TStarfarerShipWeapon(target).locations[0], 2 ) + "~n" + ..
				json.FormatDouble(TStarfarerShipWeapon(target).locations[1], 2 ) )
		'//////////////////////////////////////
		Case MODE_VARIANT 
			labels = TextWidget.Create( ..
				"variant.hullId" +"~n"+..
				"variant.variantId" +"~n"+..
				"variant.displayName" +"~n"+..
				"variant.goalVariant" +"~n"+..
				"variant.quality" )
			values = TextWidget.Create( ..
				TStarfarerVariant(target).hullId +"~n"+..
				TStarfarerVariant(target).variantId +"~n"+..
				TStarfarerVariant(target).displayName +"~n"+..
				booleanToString( TStarfarerVariant(target).goalVariant ) +"~n"+..
				json.FormatDouble( TStarfarerVariant(target).quality, 3 ))
			For i = 0 Until TStarfarerVariant(target).weaponGroups.length
				labels.append( TextWidget.Create( ..
					"variant.weaponGroup.mode" ))
				values.append( TextWidget.Create( ..
					TStarfarerVariant(target).weaponGroups[i].mode ))
			Next
		'//////////////////////////////////////
		Case MODE_WEAPON
			labels = TextWidget.Create( ..
				"weapon.id" + "~n" + ..
				"weapon.specClass" + "~n" + ..
				"weapon.size" + "~n" + ..
				"weapon.type" + "~n" + ..
				"weapon.fireSoundOne" + "~n" + ..
				"weapon.fireSoundTwo" + "~n" + ..
				"weapon.everyFrameEffect") 						
			values = TextWidget.Create( ..
				TStarfarerWeapon(target).id + "~n" + ..
				TStarfarerWeapon(target).specClass + "~n" + ..
				TStarfarerWeapon(target).size + "~n" + ..
				TStarfarerWeapon(target).type_ + "~n" + ..
				TStarfarerWeapon(target).fireSoundOne + "~n" + ..
				TStarfarerWeapon(target).fireSoundTwo + "~n" + ..
				TStarfarerWeapon(target).everyFrameEffect)
			Select TStarfarerWeapon(target).specClass
			Case "projectile"
				labels.append( TextWidget.Create( ..
					"weapon.projectileSpecId" + "~n" + ..					
					"weapon.interruptibleBurst" + "~n" + ..
					"weapon.autocharge" + "~n" + ..
					"weapon.requiresFullCharge" + "~n" + ..
					"weapon.visualRecoil" + "~n" + ..
					"weapon.barrelMode" + "~n" + ..
					"weapon.animationType") )
				values.append( TextWidget.Create( ..
					TStarfarerWeapon(target).projectileSpecId + "~n" + ..
					booleanToString (TStarfarerWeapon(target).interruptibleBurst) + "~n" + ..
					booleanToString (TStarfarerWeapon(target).autocharge ) + "~n" + ..
					booleanToString (TStarfarerWeapon(target).requiresFullCharge) + "~n" + ..
					json.FormatDouble(TStarfarerWeapon(target).visualRecoil, 2) + "~n" + ..
					TStarfarerWeapon(target).barrelMode + "~n" + ..
					TStarfarerWeapon(target).animationType ) )
				Select TStarfarerWeapon(target).animationType
				Case "GLOW"
					labels.append( TextWidget.Create( ..
						"weapon.glowColor") )
					values.append( TextWidget.Create( ..
						floatArrayToString( TStarfarerWeapon(target).glowColor, 0 ) ) )
				Case "GLOW_AND_FLASH"
					labels.append( TextWidget.Create( ..
						"weapon.glowColor" + "~n" + ..
						"weapon.muzzleFlashSpec.length" + "~n" + ..
						"weapon.muzzleFlashSpec.spread" + "~n" + ..
						"weapon.muzzleFlashSpec.particleSizeMin" + "~n" + ..
						"weapon.muzzleFlashSpec.particleSizeRange" + "~n" + ..
						"weapon.muzzleFlashSpec.particleDuration" + "~n" + ..
						"weapon.muzzleFlashSpec.particleCount" + "~n" + ..
						"weapon.muzzleFlashSpec.particleColor" ) )
						If Not TStarfarerWeapon(target).muzzleFlashSpec Then TStarfarerWeapon(target).muzzleFlashSpec = New TStarfarerWeaponMuzzleFlashSpec
					values.append( TextWidget.Create( ..
						floatArrayToString( TStarfarerWeapon(target).glowColor, 0 ) + "~n" + ..
						json.FormatDouble(TStarfarerWeapon(target).muzzleFlashSpec.length, 2) + "~n" + ..
						json.FormatDouble(TStarfarerWeapon(target).muzzleFlashSpec.spread, 2) + "~n" + ..
						json.FormatDouble(TStarfarerWeapon(target).muzzleFlashSpec.particleSizeMin, 1) + "~n" + ..
						json.FormatDouble(TStarfarerWeapon(target).muzzleFlashSpec.particleSizeRange, 1) + "~n" + ..
						json.FormatDouble(TStarfarerWeapon(target).muzzleFlashSpec.particleDuration, 2) + "~n" + ..
						json.FormatDouble(TStarfarerWeapon(target).muzzleFlashSpec.particleCount, 0) + "~n" + ..
						floatArrayToString (TStarfarerWeapon(target).muzzleFlashSpec.particleColor, 0) ) )				
				Case "MUZZLE_FLASH"
					labels.append( TextWidget.Create( ..
						"weapon.muzzleFlashSpec.length" + "~n" + ..
						"weapon.muzzleFlashSpec.spread" + "~n" + ..
						"weapon.muzzleFlashSpec.particleSizeMin" + "~n" + ..
						"weapon.muzzleFlashSpec.particleSizeRange" + "~n" + ..
						"weapon.muzzleFlashSpec.particleDuration" + "~n" + ..
						"weapon.muzzleFlashSpec.particleCount" + "~n" + ..
						"weapon.muzzleFlashSpec.particleColor") )
						If Not TStarfarerWeapon(target).muzzleFlashSpec Then TStarfarerWeapon(target).muzzleFlashSpec = New TStarfarerWeaponMuzzleFlashSpec
					values.append( TextWidget.Create( ..
						json.FormatDouble(TStarfarerWeapon(target).muzzleFlashSpec.length, 2) + "~n" + ..
						json.FormatDouble(TStarfarerWeapon(target).muzzleFlashSpec.spread, 2) + "~n" + ..
						json.FormatDouble(TStarfarerWeapon(target).muzzleFlashSpec.particleSizeMin, 1) + "~n" + ..
						json.FormatDouble(TStarfarerWeapon(target).muzzleFlashSpec.particleSizeRange, 1) + "~n" + ..
						json.FormatDouble(TStarfarerWeapon(target).muzzleFlashSpec.particleDuration, 2) + "~n" + ..
						json.FormatDouble(TStarfarerWeapon(target).muzzleFlashSpec.particleCount, 0) + "~n" + ..
						floatArrayToString (TStarfarerWeapon(target).muzzleFlashSpec.particleColor, 0) ) )					
				Case "SMOKE"
					labels.append( TextWidget.Create( ..				
						"weapon.smokeSpec.particleSizeMin" + "~n" + ..
						"weapon.smokeSpec.particleSizeRange" + "~n" + ..
						"weapon.smokeSpec.cloudParticleCount" + "~n" + ..
						"weapon.smokeSpec.cloudDuration" + "~n" + ..
						"weapon.smokeSpec.cloudRadius" + "~n" + ..
						"weapon.smokeSpec.blowbackParticleCount" + "~n" + ..
						"weapon.smokeSpec.blowbackDuration" + "~n" + ..
						"weapon.smokeSpec.blowbackLength" + "~n" + ..
						"weapon.smokeSpec.blowbackSpread" + "~n" + ..					
						"weapon.smokeSpec.particleColor") )
						If Not TStarfarerWeapon(target).smokeSpec Then TStarfarerWeapon(target).smokeSpec = New TStarfarerWeaponSmokeSpec
					values.append( TextWidget.Create( ..
						json.FormatDouble(TStarfarerWeapon(target).smokeSpec.particleSizeMin , 1) + "~n" + ..
						json.FormatDouble(TStarfarerWeapon(target).smokeSpec.particleSizeRange, 1) + "~n" + ..
						json.FormatDouble(TStarfarerWeapon(target).smokeSpec.cloudParticleCount, 0) + "~n" + ..
						json.FormatDouble(TStarfarerWeapon(target).smokeSpec.cloudDuration , 2) + "~n" + ..
						json.FormatDouble(TStarfarerWeapon(target).smokeSpec.cloudRadius , 2) + "~n" + ..
						json.FormatDouble(TStarfarerWeapon(target).smokeSpec.blowbackParticleCount, 0) + "~n" + ..
						json.FormatDouble(TStarfarerWeapon(target).smokeSpec.blowbackDuration, 2) + "~n" + ..
						json.FormatDouble(TStarfarerWeapon(target).smokeSpec.blowbackLength , 2) + "~n" + ..
						json.FormatDouble(TStarfarerWeapon(target).smokeSpec.blowbackSpread, 2) + "~n" + ..
						floatArrayToString (TStarfarerWeapon(target).smokeSpec.particleColor, 0) ) )					
				Case "NONE"
				EndSelect
			Case "beam"
				labels.append( TextWidget.Create( ..
					"weapon.beamEffect" + "~n" + ..
					"weapon.beamFireOnlyOnFullCharge" + "~n" + ..
					"weapon.convergeOnPoint" + "~n" + ..
					"weapon.fringeColor" + "~n" + ..
					"weapon.coreColor" + "~n" + ..					
					"weapon.darkCore" + "~n" + ..
					"weapon.glowColor" + "~n" + ..
					"weapon.width" + "~n" + ..
					"weapon.textureScrollSpeed" + "~n" + ..
					"weapon.pixelsPerTexel" + "~n" + ..
					"weapon.textureType") )
				values.append( TextWidget.Create( ..
					TStarfarerWeapon(target).beamEffect + "~n" + ..
					booleanToString (TStarfarerWeapon(target).beamFireOnlyOnFullCharge) + "~n" + ..
					booleanToString (TStarfarerWeapon(target).convergeOnPoint ) + "~n" + ..
					floatArrayToString(TStarfarerWeapon(target).fringeColor, 0) + "~n" + ..
					floatArrayToString(TStarfarerWeapon(target).coreColor, 0) + "~n" + ..
					booleanToString (TStarfarerWeapon(target).darkCore ) + "~n" + ..					
					floatArrayToString(TStarfarerWeapon(target).glowColor, 0) + "~n" + ..
					json.FormatDouble(TStarfarerWeapon(target).width, 2) + "~n" + ..
					json.FormatDouble(TStarfarerWeapon(target).textureScrollSpeed, 2) + "~n" + ..
					json.FormatDouble(TStarfarerWeapon(target).pixelsPerTexel , 2) ) )
				Local ttid:TTypeId = TTypeId.ForObject(TStarfarerWeapon(target).textureType)
'				Print ttid.Name().ToString()
				Select ttid.Name()
				Case "TEmun"
					values.append( (TextWidget.Create( TStarfarerWeapon(target).textureType.ToString() ) ) )
				Case "TArray"
					labels.append( TextWidget.Create( ..
					"weapon.textureType.customFringeTexture" + "~n" + ..
					"weapon.textureType.customCoreTexture") )
'					customBeamTexTmp = String[](json.parse(TStarfarerWeapon(target).textureType.ToString(), "String[]") )
'					customBeamTexTmp[0] = ( TArray(TStarfarerWeapon(target).textureType).elements.toarray() )[0].ToString()
'					customBeamTexTmp[1] = ( TArray(TStarfarerWeapon(target).textureType).elements.toarray() )[1].ToString()	
					customBeamTexTmp = 	TArray(TArray(TStarfarerWeapon(target).textureType).Copy() )
					Local customFringeTexture$ = customBeamTexTmp.elements.ToArray()[0].ToString()
					Local customCoreTexture$ = customBeamTexTmp.elements.ToArray()[1].ToString()
					values.append( TextWidget.Create( "CUSTOM" + "~n" + ..
					customFringeTexture + "~n" + ..
					customCoreTexture) )
				EndSelect
			EndSelect
		EndSelect
		labels.update_size()
		values.update_size()
		''add all weapons to the known enums
		'For val = EachIn ed.stock_weapon_stats.Keys()
		'	ed.load_multiselect_value( "ship.builtInWeapons.id", val )
		'Next
		'search for known enums
		data_types = New Int[labels.lines.length] 'DATATYPE_STRING
		enum_defs = New String[][labels.lines.length]
		For i = 0 Until labels.lines.length
			enum_set = ed.get_multiselect_values( labels.lines[i] )
			If enum_set
				data_types[i] = DATATYPE_ENUM
				For val = EachIn enum_set.Keys()
					If Not enum_defs[i] Then enum_defs[i] = New String[1] ..
					Else enum_defs[i] = enum_defs[i][..enum_defs[i].length+1]
					enum_defs[i][enum_defs[i].length-1] = val
					If val = values.lines[i]
						line_enum_i = i
					End If
				Next
			EndIf
		Next
		'update_cursor( data )
		json.formatted = True
	EndMethod
EndType

Function floatArrayToString:String (input:Float[], precision:Int = 6)
	Local output$
	For Local i% = 0 Until input.length
		If i > 0 Then output :+ ","
		Local d! = input[i]
		output :+ json.FormatDouble( d , precision)
	Next
	Return output
End Function

Function stringToFloatArray:Float[] (input$)
	Local tmp$[] = input.Split(",")
	Local output#[]
	For Local i% = 0 Until tmp.length
		output = output[..] + [tmp[i].ToFloat( )]
	Next
	Return output
End Function

Function intArrayToString:String (input:Int[])
	Local output$
	For Local i% = 0 Until input.length
		If i > 0 Then output :+ ","
		output :+ input[i]
	Next
	Return output
End Function

Function stringToIntArray:Int[] (input$)
	Local tmp$[] = input.Split(",")
	Local output%[]
	For Local i% = 0 Until tmp.length
		output = output[..] + [tmp[i].ToInt( )]
	Next
	Return output
End Function

Function booleanToString:String (input%)
	If input = False Then Return "False" Else Return "True"
End Function

Function stringToBoolean:Int (input$)
	If input.ToLower() = "false" Then Return False Else Return True
	
End Function