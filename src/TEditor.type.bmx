'-----------------------

Type TEditor
	'modal flags
	Field program_mode$
	Field mode$
	Field hide_ship%
	Field last_mode$
	Field show_help%
	Field show_data%
	Field show_debug%
	Field bounds_symmetrical%
	Field field_i%
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
	Field target_zpan_x#
	Field target_zpan_y#
	Field last_img_x#
	Field last_img_y#
	Field mouse_z%
	Field selected_zoom_level%
	Field target_sprite_scale#
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
	Field stock_hull_variants_assoc:TMap 'String (TList) --> List of variant_id's asssociated with the hullid
	Field stock_weapons:TMap 'String(id) --> TStarfarerWeapon
	Field stock_engine_styles:TMap'<String,TStarfarerCustomEngineStyleSpec>  'CUSTOM Engine styleId --> engine data object
	Field stock_ship_stats:TMap 'String (id:hullId) --> TMap (csv stats keys --> values)
	Field stock_wing_stats:TMap 'String (id) --> TMap (csv stats keys --> values)
	Field stock_variant_wing_stats_assoc:TMap 'String (TList) --> List of wing_id's associated with the variantId
	Field stock_weapon_stats:TMap 'String (id) --> TMap (csv stats keys --> values)
	Field stock_hullmod_stats:TMap 'String (id) --> TMap (csv stats keys --> values)
	Field stock_ship_stats_field_order:TList'<String> 'column names
	Field stock_wing_stats_field_order:TList'<String> 'column names
	Field multiselect_values:TMap 'String (field) --> TMap (set of valid values)

	Method New()
		program_mode = "ship"
		mode = "preview_all"
		mouse_z = MouseZ()
		bounds_symmetrical = True
		edit_strings_weapon_i = -1
		edit_strings_engine_i = -1
		selected_zoom_level = 3 '=1.0
		initialize_stock_data_containers()
	End Method

	Method initialize_stock_data_containers()
		'object data
		stock_ships = CreateMap()
		stock_variants = CreateMap()
		stock_hull_variants_assoc = CreateMap()
		stock_weapons = CreateMap()
		stock_engine_styles = CreateMap()
		stock_engine_styles.Insert( "", "" ) 'NULL engine style means "use the included styleSpec data"
		'csv data
		stock_ship_stats = CreateMap()
		stock_wing_stats = CreateMap()
		stock_variant_wing_stats_assoc = CreateMap()
		stock_weapon_stats = CreateMap()
		stock_hullmod_stats = CreateMap()
		'csv field order
		stock_ship_stats_field_order = ship_data_csv_field_order_template.Copy()
		stock_wing_stats_field_order = wing_data_csv_field_order_template.Copy()
		'scraped enum values
		multiselect_values = CreateMap()
	EndMethod

	Method load_stock_ship:TStarfarerShip( dir$, file$ )
		Try
			Local input_json_str$ = LoadString( dir+file )
			Local ship:TStarfarerShip = TStarfarerShip( json.parse( input_json_str, "TStarfarerShip", "parse_ship" ))
			Fix_Map_TStrings( ship.builtInWeapons ) 'TEMPORARY
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

	Method load_stock_variant:TStarfarerVariant( dir$, file$ )
		Try
			Local input_json_str$ = LoadString( dir+file )
			Local variant:TStarfarerVariant = TStarfarerVariant( json.parse( input_json_str, "TStarfarerVariant" ))
			For Local weaponGroup:TStarfarerVariantWeaponGroup = EachIn variant.weaponGroups
				Fix_Map_TStrings( weaponGroup.weapons ) 'TEMPORARY
			Next
			'save variant data
			stock_variants.Insert( variant.variantId, variant )
			'save association to hull that it references
			Local assoc:TList = TList( stock_hull_variants_assoc.ValueForKey( variant.hullId ))
			If Not assoc
				assoc = CreateList()
				stock_hull_variants_assoc.Insert( variant.hullId, assoc )
			EndIf
			assoc.AddLast( variant.variantId )
			'scan for multiselect values
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

	Method get_default_variant:TStarfarerVariant( hullId$ )
		Local assoc:TList = TList( stock_hull_variants_assoc.ValueForKey( hullId ))
		Local variant:TStarfarerVariant
		If assoc And Not assoc.IsEmpty()
			variant = TStarfarerVariant( stock_variants.ValueForKey( assoc.First() ))
		Else
			variant = New TStarfarerVariant
			variant.hullId = hullId
			variant.variantId = hullId+"_variant"
		EndIf
		Return variant
	EndMethod

	Method verify_variant_association%( hullId$, variantId$ )
		Local assoc:TList = TList( stock_hull_variants_assoc.ValueForKey( hullId ))
		Return (assoc And assoc.Contains( variantId ))
	EndMethod

	Method load_stock_weapon:TStarfarerWeapon( dir$, file$ )
		Try
			Local input_json_str$ = LoadString( dir+file )
			Local weapon:TStarfarerWeapon = TStarfarerWeapon( json.parse( input_json_str, "TStarfarerWeapon", "parse_weapon" ))
			stock_weapons.Insert( weapon.id, weapon )
			'load_multiselect_value( "ship.builtInWeapons.id", weapon.id )
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

	Method load_stock_engine_styles( dir$, file$ )
		Try
			Local input_json_str$ = LoadString( dir+file )
			Local engine_styles:TMap = TMap( json.parse( input_json_str, "TMap" ))
			For Local styleId$ = EachIn engine_styles.Keys()
				load_multiselect_value( "ship.engine.styleId", styleId )
			Next
		Catch ex$ 'ignore parsing errors and continue
			DebugLogFile " Error: "+file+" "+ex
		EndTry
	EndMethod

	Method load_stock_ship_stats( dir$, file$, save_field_order%=False )
		Try
			If save_field_order
				stock_ship_stats_field_order = CreateList()
				TCSVLoader.Load( dir+file, "id", stock_ship_stats, stock_ship_stats_field_order )
			Else
				TCSVLoader.Load( dir+file, "id", stock_ship_stats )
			EndIf
			Local row:TMap
			For Local id$ = EachIn stock_ship_stats.Keys()
				'scan all rows for multiselect values
				row = TMap( stock_ship_stats.ValueForKey( id ))
				load_multiselect_value( "ship_csv.shield type", String( row.ValueForKey( "shield type" )))
			Next
			DebugLogFile " LOADED "+file
		Catch ex$ 'ignore parsing errors and continue
			DebugLogFile " Error: "+file+" "+ex
		EndTry
	End Method

	Method get_ship_stats:TMap( hullId$ )
		If stock_ship_stats.Contains( hullId )
			Return TMap( stock_ship_stats.ValueForKey( hullId ))
		Else
			Return ship_data_csv_field_template.Copy()
		EndIf
	EndMethod

	Method load_stock_wing_stats( dir$, file$, save_field_order%=False )
		Try
			If save_field_order
				stock_wing_stats_field_order = CreateList()
				TCSVLoader.Load( dir+file, "id", stock_wing_stats, stock_wing_stats_field_order )
			Else
				TCSVLoader.Load( dir+file, "id", stock_wing_stats )
			EndIf
			Local row:TMap
			For Local id$ = EachIn stock_wing_stats.Keys()
				'scan all rows for multiselect values and save association to variant
				row = TMap( stock_wing_stats.ValueForKey( id ))
				load_multiselect_value( "wing_csv.formation", String( row.ValueForKey( "formation" )))
				load_multiselect_value( "wing_csv.role",      String( row.ValueForKey( "role" )))
				'save association to variant that it references
				Local assoc:TList = TList( stock_variant_wing_stats_assoc.ValueForKey( row.ValueForKey( "variant" )))
				If Not assoc
					assoc = CreateList()
					stock_variant_wing_stats_assoc.Insert( row.ValueForKey( "variant" ), assoc )
				EndIf
				assoc.AddLast( row.ValueForKey( "id" )) 'wing id
			Next
			DebugLogFile " LOADED "+file
		Catch ex$ 'ignore parsing errors and continue
			DebugLogFile " Error: "+file+" "+ex
		EndTry
	End Method

	Method get_default_wing:TMap( variantId$ )
		Local assoc:TList = TList( stock_variant_wing_stats_assoc.ValueForKey( variantId ))
		Local wing:TMap
		If assoc And Not assoc.IsEmpty()
			wing = TMap( stock_wing_stats.ValueForKey( assoc.First() ))
		Else
			wing = wing_data_csv_field_template.Copy()
			wing.Insert( "variant", variantId+"_wing" )
		EndIf
		Return wing
	EndMethod

	Method verify_wing_data_association%( variantId$, wing_id$ )
		Local assoc:TList = TList( stock_variant_wing_stats_assoc.ValueForKey( variantId ))
		Return (assoc And assoc.Contains( wing_id ))
	EndMethod

	Method load_stock_weapon_stats( dir$, file$, save_field_order%=False )
		Try
			If save_field_order
				'stock_weapon_stats_field_order = CreateList()
				TCSVLoader.Load( dir+file, "id", stock_weapon_stats )', stock_weapon_stats_field_order )
			Else
				TCSVLoader.Load( dir+file, "id", stock_weapon_stats )
			EndIf
			DebugLogFile " LOADED "+file
		Catch ex$ 'ignore parsing errors and continue
			DebugLogFile " Error: "+file+" "+ex
		EndTry
	End Method

	Method load_stock_hullmod_stats( dir$, file$, save_field_order%=False )
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
		For Local weapon_id$ = EachIn stock_weapons.Keys()
			Local weapon:TStarfarerWeapon = TStarfarerWeapon( stock_weapons.ValueForKey( weapon_id ))
			Local size_diff% = (weapon_size_value( slot_size ) - weapon_size_value( weapon.size ))
			'slot type match and same size or bigger by one step
			'or universal/built-in type with same size
			'or decorative weapons for decorative slots
			If slot_type <> "DECORATIVE"
				If ( slot_type = "UNIVERSAL" And size_diff = 0 ) ..
				Or ( slot_type = "BUILT_IN" And size_diff = 0 ) ..
				Or ( slot_type = weapon.type_ And size_diff >= 0 And size_diff <= 1 )
					matches = matches[..(matches.length + 1)]
					matches[matches.length - 1] = weapon.id
				EndIf
			Else
				If  ( slot_type = "DECORATIVE" And size_diff = 0 ) ..
				And ( weapon.type_ = "DECORATIVE" )
					matches = matches[..(matches.length + 1)]
					matches[matches.length - 1] = weapon.id
				EndIf
			EndIf
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
		If name And name <> ""
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

	Method get_default_multiselect_value$( name$ )
		Local set:TMap = TMap( multiselect_values.ValueForKey( name ))
		For Local key$ = EachIn set.Keys()
			If key <> "" Then Return key
		Next
		Return ""
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

