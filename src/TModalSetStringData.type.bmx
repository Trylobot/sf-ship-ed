
Type TModalSetStringData Extends TSubroutine
	
	Field i%, j%, val$
	Field enum_set:TMap

	Field target:Object
	Field modified%

	Field line_i%
	Field line_enum_i%
	Field labels:TextWidget
	Field values:TextWidget
	Field cursor:TextWidget

	Field DATATYPE_STRING% = 0 'string types are entered free-form and then converted to/from JSON
	Field DATATYPE_ENUM%   = 1 'enum types are restricted to a discrete set of values and use arrow keys to select
	Field data_types%[]
	Field enum_defs$[][]

	Field MODE_SHIP%    = 0
	Field MODE_SHIP_WEAPON%  = 1
	Field MODE_SHIP_ENGINE%  = 2
	Field MODE_VARIANT% = 3
	Field MODE_WEAPON% = 4
	Field subroutine_mode%

	Method Activate( ed:TEditor, data:TData, sprite:TSprite )
		'set the subroutine module state
		FlushKeys()
		line_i = 0
		line_enum_i = 0
		modified = false
		If ed.program_mode = "ship"
			If ed.edit_strings_weapon_i <> -1
				subroutine_mode = MODE_SHIP_WEAPON
				target = data.ship.weaponSlots[ed.edit_strings_weapon_i]
			ElseIf ed.edit_strings_engine_i <> -1
				subroutine_mode = MODE_SHIP_ENGINE
				target = data.ship.engineSlots[ed.edit_strings_engine_i]
			Else
				subroutine_mode = MODE_SHIP
				target = data.ship
			EndIf
		Else If ed.program_mode = "variant"
			subroutine_mode = MODE_VARIANT
			target = data.variant
		Else If ed.program_mode = "weapon"
			subroutine_mode = MODE_WEAPON
			target = data.weapon
		EndIf
		'load data from appropriate source
		Load( ed,data,sprite )
	EndMethod

	Method Update( ed:TEditor, data:TData, sprite:TSprite )
		'back out (old way)
		If (KeyHit( KEY_ESCAPE ) Or KeyHit( KEY_HOME ))
			ed.mode = ed.last_mode
			Return
		End If
		'keyboard controls
		If KeyHit( KEY_DOWN ) Or KeyHIT( KEY_TAB ) Or KeyHit( KEY_ENTER )
			FlushKeys()
			line_i = Min( line_i + 1, labels.lines.length - 1 )
			update_cursor( data )
			reset_cursor_color_period()
		EndIf
		If KEYHIT( KEY_UP )
			FlushKeys()
			line_i = Max( line_i - 1, 0 )
			update_cursor( data )
			reset_cursor_color_period()
		EndIf
		Select data_types[line_i]
			Case DATATYPE_STRING
				modified = False
				values.lines[line_i] = CONSOLE.Update( values.lines[line_i],, modified )
				If modified
					Save( ed,data,sprite )
					values.update_size()
					update_cursor( data )
				EndIf
			Case DATATYPE_ENUM
				modified = False
				If KeyHit( KEY_RIGHT )
					For i = 0 Until enum_defs[line_i].length
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
				If KeyHit( KEY_LEFT )
					For i = 0 Until enum_defs[line_i].length
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
					update_cursor( data )
					Save( ed,data,sprite )
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
						Save( ed,data,sprite )
					ElseIf subroutine_mode = MODE_SHIP_ENGINE ..
					And TStarfarerShipEngine(target).style = "CUSTOM" ..
					And labels.lines[line_i] = "ship.engine.styleId"
						If TStarfarerShipEngine(target).styleId <> ""
							TStarfarerShipEngine(target).styleSpec = Null
						Else ' style id is blank/null (not specified)
							TStarfarerShipEngine(target).styleSpec = New TStarfarerCustomEngineStyleSpec
						EndIf
						Load( ed,data,sprite ) 're-create string-editing window
						Save( ed,data,sprite )
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
	EndMethod

	Method update_cursor( data:TData )
		If values
			cursor = TextWidget.Create( values )
			For i = 0 Until cursor.lines.length
				If i <> line_i
					cursor.lines[i] = ""
				Else 'i == line_i
					Select data_types[line_i]
						Case DATATYPE_STRING
							cursor.lines[i] = " " + RSet( "", cursor.lines[i].length ) + Chr($2502) 'vertical line
						Case DATATYPE_ENUM
							cursor.lines[i] = Chr($25C2) + RSet( "", cursor.lines[i].length ) + Chr($25B8) 'left/right arrows
					EndSelect
				EndIf
			Next
		Else
			cursor = NULL
		EndIf
	EndMethod

	Method Draw( ed:TEditor, data:TData, sprite:TSprite )
		draw_container( (W_MID-(10+labels.w+10)),H_MID, (10+labels.w+10)+(10+values.w+10),(10+labels.h+10), 0.0,0.5 )
		draw_string( labels, (W_MID-10),H_MID,,, 1.0,0.5 )
		draw_string( values, (W_MID+10),H_MID,,, 0.0,0.5 )
		draw_string( cursor, (W_MID+10)-TextWidth(" "),H_MID, get_cursor_color(),$000000, 0.0,0.5 )
	EndMethod

	Method Save( ed:TEditor, data:TData, sprite:TSprite )
		Select subroutine_mode
			'////////////////////////////////////////
			Case MODE_SHIP
				i = 0
				'TStarfarerShip(target).hullId = values.lines[i]; i:+1
				If line_i = i Then data.set_hullId( TStarfarerShip(target).hullId, values.lines[i] )
				i:+1
				TStarfarerShip(target).hullName = values.lines[i]; i:+1
				TStarfarerShip(target).hullSize = values.lines[i]; i:+1
				TStarfarerShip(target).style = values.lines[i]; i:+1
				TStarfarerShip(target).spriteName = values.lines[i]; i:+1
				data.update()
			'//////////////////////////////////////
			Case MODE_SHIP_ENGINE
				i = 0
				TStarfarerShipEngine(target).style = values.lines[i]; i:+1
				'conditional chunk 1
				If values.lines.length >= i + 1 And TStarfarerShipEngine(target).style = "CUSTOM"
					TStarfarerShipEngine(target).styleId = values.lines[i]; i:+1
				EndIf
				'conditional chunk 2
				If values.lines.length >= i + 7 And TStarfarerShipEngine(target).styleSpec <> Null
					TStarfarerShipEngine(target).styleSpec.type_ = values.lines[i]; i:+1
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
				TStarfarerShipWeapon(target).angle = values.lines[i].ToDouble(); i:+1
				TStarfarerShipWeapon(target).arc = values.lines[i].ToDouble(); i:+1
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
				'variable-length chunk 1
				For j = 0 Until TStarfarerVariant(target).weaponGroups.length
					TStarfarerVariant(target).weaponGroups[j].mode = values.lines[i]; i:+1
				Next
				data.update_variant()
			'//////////////////////////////////////
			Case MODE_WEAPON
				i = 0
				TStarfarerWeapon(target).id = values.lines[i]; i:+1
				TStarfarerWeapon(target).size = values.lines[i]; i:+1
				TStarfarerWeapon(target).type_ = values.lines[i]; i:+1
				TStarfarerWeapon(target).specClass = values.lines[i]; i:+1
				TStarfarerWeapon(target).barrelMode = values.lines[i]; i:+1
				TStarfarerWeapon(target).animationType = values.lines[i]; i:+1
				data.update_weapon()
		EndSelect
	EndMethod

	Method Load( ed:TEditor, data:TData, sprite:TSprite )
		json.formatted = false
		'setup edit box and initialize with values
		Select subroutine_mode
			'////////////////////////////////////////
			Case MODE_SHIP 
				labels = TextWidget.Create( ..
					"ship.hullId" +"~n"+..
					"ship.hullName" +"~n"+..
					"ship.hullSize" +"~n"+..
					"ship.style" +"~n"+..
					"ship.spriteName" )
				values = TextWidget.Create( ..
					TStarfarerShip(target).hullId +"~n"+..
					TStarfarerShip(target).hullName +"~n"+..
					TStarfarerShip(target).hullSize +"~n"+..
					TStarfarerShip(target).style +"~n"+..
					TStarfarerShip(target).spriteName )
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
				If TStarfarerShipEngine(target).styleSpec <> NULL
					labels.append( TextWidget.Create( ..
						"ship.engine.styleSpec.type" +"~n"+..
						"ship.engine.styleSpec.engineColor" +"~n"+..
						"ship.engine.styleSpec.contrailColor" +"~n"+..
						"ship.engine.styleSpec.contrailParticleSizeMult" +"~n"+..
						"ship.engine.styleSpec.contrailParticleDuration" +"~n"+..
						"ship.engine.styleSpec.contrailMaxSpeedMult" +"~n"+..
						"ship.engine.styleSpec.contrailAngularVelocityMult" ))
					values.append( TextWidget.Create( ..
						TStarfarerShipEngine(target).styleSpec.type_ +"~n"+..
						json.stringify( TStarfarerShipEngine(target).styleSpec.engineColor ) +"~n"+..
						json.stringify( TStarfarerShipEngine(target).styleSpec.contrailColor ) +"~n"+..
						json.FormatDouble( TStarfarerShipEngine(target).styleSpec.contrailParticleSizeMult, 3 ) +"~n"+..
						json.FormatDouble( TStarfarerShipEngine(target).styleSpec.contrailParticleDuration, 3 ) +"~n"+..
						json.FormatDouble( TStarfarerShipEngine(target).styleSpec.contrailMaxSpeedMult, 3 ) +"~n"+..
						json.FormatDouble( TStarfarerShipEngine(target).styleSpec.contrailAngularVelocityMult, 3 ) ))
				EndIf
			'///////////////////////////////////////
			Case MODE_SHIP_WEAPON 
				labels = TextWidget.Create( ..
					"ship.weapon.id" +"~n"+..
					"ship.weapon.mount" +"~n"+..
					"ship.weapon.size" +"~n"+..
					"ship.weapon.type" +"~n"+..
					"ship.weapon.angle" +"~n"+..
					"ship.weapon.arc" )
				values = TextWidget.Create( ..
					TStarfarerShipWeapon(target).id +"~n"+..
					TStarfarerShipWeapon(target).mount +"~n"+..
					TStarfarerShipWeapon(target).size +"~n"+..
					TStarfarerShipWeapon(target).type_ +"~n"+..
					json.FormatDouble( TStarfarerShipWeapon(target).angle, 6 ) +"~n"+..
					json.FormatDouble( TStarfarerShipWeapon(target).arc, 6 ) )
			'//////////////////////////////////////
			Case MODE_VARIANT 
				labels = TextWidget.Create( ..
					"variant.hullId" +"~n"+..
					"variant.variantId" +"~n"+..
					"variant.displayName" )
				values = TextWidget.Create( ..
					TStarfarerVariant(target).hullId +"~n"+..
					TStarfarerVariant(target).variantId +"~n"+..
					TStarfarerVariant(target).displayName )
				For i = 0 Until TStarfarerVariant(target).weaponGroups.length
					labels.append( TextWidget.Create( ..
						"variant.weaponGroup.mode" ))
					values.append( TextWidget.Create( ..
						TStarfarerVariant(target).weaponGroups[i].mode ))
				Next
			'//////////////////////////////////////
			Case MODE_WEAPON
				labels = TextWidget.Create( ..
					"weapon.id" +"~n"+..
					"weapon.size" +"~n"+..
					"weapon.type" +"~n"+..
					"weapon.specClass" +"~n"+..
					"weapon.barrelMode" +"~n"+..
					"weapon.animationType" )
				values = TextWidget.Create( ..
					TStarfarerWeapon(target).id +"~n"+..
					TStarfarerWeapon(target).size +"~n"+..
					TStarfarerWeapon(target).type_ +"~n"+..
					TStarfarerWeapon(target).specClass +"~n"+..
					TStarfarerWeapon(target).barrelMode +"~n"+..
					TStarfarerWeapon(target).animationType )
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
					If Not enum_defs[i] Then enum_defs[i] = new String[1] ..
					Else enum_defs[i] = enum_defs[i][..enum_defs[i].length+1]
					enum_defs[i][enum_defs[i].length-1] = val
					If val = values.lines[i]
						line_enum_i = i
					End If
				Next
			EndIf
		Next
		update_cursor( data )
		json.formatted = true
	EndMethod

EndType

