'-----------------------

Type TEditor
	'modal flags
	Field program_mode$
	Field mode$
	Field last_mode$
	Field show_help%
	Field show_data%
	Field show_debug%
	Field bounds_symmetrical%
	Field field_i%
	Field target_sprite_scale#
	Field select_weapon_i%
	Field edit_strings_weapon_i%
	Field edit_strings_engine_i%
	Field variant_hullMod_i%
	Field group_field_i%
	'mouse states
	Field mouse_1%
	Field drag_mirrored%
	Field drag_nearest_i%
	Field drag_counterpart_i%
	Field mouse_2%
	Field pan_start_x#
	Field pan_start_y#
	Field pan_start_mouse_x#
	Field pan_start_mouse_y#
	Field last_img_x#
	Field last_img_y#
	Field mouse_z%
	Field selected_zoom_level%
	Field weapon_lock_i%
	Field engine_lock_i%
	'images
	Field bg_image:TImage
	Field bg_scale#
	Field kb_key_image:TImage
	Field kb_key_wide_image:TImage
	Field kb_key_space_image:TImage
	Field mouse_left_image:TImage
	Field mouse_right_image:TImage
	Field mouse_middle_image:TImage
	Field ico_dim:TImage
	Field ico_pos:TImage
	Field ico_ang:TImage
	Field ico_zoom:TImage
	Field ico_mirr:TImage
	Field ico_exit:TImage
	'stock data
	Field stock_ships:TMap 'String (hullId) --> TStarfarerShip
	Field stock_variants:TMap 'String (variantId) --> TStarfarerVariant
	Field stock_weapons:TMap 'String(id) --> TStarfarerWeapon
	Field stock_ship_stats:TMap 'String (id:hullId) --> TMap (csv stats keys --> values)
	Field stock_wing_stats:TMap 'String (id) --> TMap (csv stats keys --> values)
	Field stock_weapon_stats:TMap 'String (id) --> TMap (csv stats keys --> values)
	Field stock_hullmod_stats:TMap 'String (id) --> TMap (csv stats keys --> values)
	Field stock_ship_stats_field_order:TList'<String> 'column names
	Field multiselect_values:TMap 'String (field) --> TMap (set of valid values)

	Method New()
		program_mode = "ship"
		mode = "preview_all"
		mouse_z = MouseZ()
		bounds_symmetrical = True
		edit_strings_weapon_i = -1
		edit_strings_engine_i = -1
		selected_zoom_level = 3 '=1.0
		'object data
		stock_ships = CreateMap()
		stock_variants = CreateMap()
		stock_weapons = CreateMap()
		'csv data
		stock_ship_stats = CreateMap()
		stock_wing_stats = CreateMap()
		stock_weapon_stats = CreateMap()
		stock_hullmod_stats = CreateMap()
		'csv field order
		stock_ship_stats_field_order = ship_data_csv_field_order_template.Copy()
		'scraped enum values
		multiselect_values = CreateMap()
	End Method

	Method load_stock_ship:TStarfarerShip( dir$, file$, settings:TJSONDecodeSettings )
		Try
			Local input_json_str$ = LoadString( dir+file )
			Local ship:TStarfarerShip = TStarfarerShip( JSON.decode( input_json_str, settings, TTypeId.ForName("TStarfarerShip")))
			stock_ships.Insert( ship.hullId, ship )
			load_multiselect_value( "ship.hullSize", ship.hullSize )
			load_multiselect_value( "ship.style", ship.style )
			For Local weapon:TStarfarerShipWeapon = EachIn ship.weaponSlots
				load_multiselect_value( "ship.weapon.mount", weapon.mount )
				load_multiselect_value( "ship.weapon.size", weapon.size )
				load_multiselect_value( "ship.weapon.type", weapon.type_ )
			Next
			For Local engine:TStarfarerShipEngine = EachIn ship.engineSlots
				load_multiselect_value( "ship.engine.style", engine.style )
				If engine.styleSpec <> Null
					load_multiselect_value( "ship.engine.styleSpec.type", engine.styleSpec.type_ )
				EndIf
			Next
			DebugLogFile " LOADED "+file
			Return ship
		Catch ex$ 'ignore parsing errors and continue
			DebugLogFile " Error: "+file+" "+ex
			Return Null
		EndTry
	End Method

	Method load_stock_variant:TStarfarerVariant( dir$, file$, settings:TJSONDecodeSettings )
		Try
			Local input_json_str$ = LoadString( dir+file )
			Local variant:TStarfarerVariant = TStarfarerVariant( JSON.decode( input_json_str, settings, TTypeId.ForName("TStarfarerVariant")))
			stock_variants.Insert( variant.variantId, variant )
			For Local weapongroup:TStarfarerVariantWeaponGroup = EachIn variant.weaponGroups
				load_multiselect_value( "variant.weaponGroup.mode", weapongroup.mode )
			Next
			DebugLogFile " LOADED "+file
			Return variant
		Catch ex$ 'ignore parsing errors and continue
			DebugLogFile " Error: "+file+" "+ex
			Return Null
		EndTry
	End Method

	Method load_stock_weapon:TStarfarerWeapon( dir$, file$, settings:TJSONDecodeSettings )
		Try
			Local input_json_str$ = LoadString( dir+file )
			Local weapon:TStarfarerWeapon = TStarfarerWeapon( JSON.decode( input_json_str, settings, TTypeId.ForName("TStarfarerWeapon")))
			stock_weapons.Insert( weapon.id, weapon )
			load_multiselect_value( "weapon.specClass", weapon.specClass )
			load_multiselect_value( "weapon.type", weapon.type_ )
			load_multiselect_value( "weapon.size", weapon.size )
			load_multiselect_value( "weapon.barrelMode", weapon.barrelMode )
			load_multiselect_value( "weapon.animationType", weapon.animationType )
			DebugLogFile " LOADED "+file
			Return weapon
		Catch ex$ 'ignore parsing errors and continue
			DebugLogFile " Error: "+file+" "+ex
			Return Null
		EndTry
	End Method

	Method load_stock_ship_stats( dir$, file$, save_field_order%=FALSE )
		Try
			If save_field_order
				stock_ship_stats_field_order = CreateList()
				TCSVLoader.Load( dir+file, "id", stock_ship_stats, stock_ship_stats_field_order )
			Else
				TCSVLoader.Load( dir+file, "id", stock_ship_stats )
			EndIf
			'scan all rows for multiselect values
			For Local row:TMap = EachIn stock_ship_stats
				load_multiselect_value( "ship_csv.shield type", String(stock_ship_stats.ValueForKey( "shield type" )))
			Next
			DebugLogFile " LOADED "+file
		Catch ex$ 'ignore parsing errors and continue
			DebugLogFile " Error: "+file+" "+ex
		EndTry
	End Method

	Method load_stock_wing_stats( dir$, file$ )
		Try
			TCSVLoader.Load( dir+file, "id", stock_wing_stats )
			DebugLogFile " LOADED "+file
		Catch ex$ 'ignore parsing errors and continue
			DebugLogFile " Error: "+file+" "+ex
		EndTry
	End Method

	Method load_stock_weapon_stats( dir$, file$ )
		Try
			TCSVLoader.Load( dir+file, "id", stock_weapon_stats )
			DebugLogFile " LOADED "+file
		Catch ex$ 'ignore parsing errors and continue
			DebugLogFile " Error: "+file+" "+ex
		EndTry
	End Method

	Method load_stock_hullmod_stats( dir$, file$ )
		Try
			TCSVLoader.Load( dir+file, "id", stock_hullmod_stats )
			DebugLogFile " LOADED "+file
		Catch ex$ 'ignore parsing errors and continue
			DebugLogFile " Error: "+file+" "+ex
		EndTry
	End Method

	'//////////////

	Method select_weapons$[]( slot_type$, slot_size$ )
		Local matches$[] = New String[0]
		For Local weapon_id$ = Eachin stock_weapons.Keys()
			Local weapon:TStarfarerWeapon = TStarfarerWeapon( stock_weapons.ValueForKey( weapon_id ))
			Local size_diff% = (weapon_size_value( slot_size ) - weapon_size_value( weapon.size ))
			'slot type match and same size or bigger by one step
			'or universal type with same size
			If ( slot_type = "UNIVERSAL" And size_diff = 0 ) ..
			Or ( slot_type = weapon.type_ And size_diff >= 0 And size_diff <= 1 )
				matches = matches[..(matches.length + 1)]
				matches[matches.length - 1] = weapon.id
			Endif
		Next
		Return matches
	EndMethod

	Function weapon_size_value%( size$ )
		Select size
			Case "SMALL"
				Return 1
			Case "MEDIUM"
				Return 2
			Case "LARGE"
				Return 3
			Default
				Return 0 'invalid/unknown
		EndSelect
	EndFunction

	Method load_multiselect_value( name$, value$ )
		If name And name <> "" And value And value <> ""
			If Not multiselect_values Then multiselect_values = CreateMap()
			Local set:TMap = TMap( multiselect_values.ValueForKey( name ))
			If Not set
				set = CreateMap()
				multiselect_values.Insert( name, set )
			EndIf
			If Not set.Contains( value )
				DebugLogFile( " Enum  "+value+"  ("+name+")" )
				set.Insert( value, value )
			EndIf
		EndIf
	End Method

	Method get_multiselect_values:TMap( name$ )
		Local set:TMap = TMap( multiselect_values.ValueForKey( name ))
		Return set
	End Method

	Method get_max_fluxMods%( hullSize$ )
		'hardcoded: 10/20/30/50
		Select hullSize
			Case "FRIGATE"
				Return 10
			Case "DESTROYER"
				Return 20
			Case "CRUISER"
				Return 30
			Case "CAPITAL_SHIP"
				Return 50
			Default
				Return 0 'Error
		EndSelect
	EndMethod

End Type

