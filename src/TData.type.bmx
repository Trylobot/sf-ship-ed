'-----------------------

Type TData
	
	Field ship:TStarfarerShip
	Field json_str$
	Field json_view:TList'<TextWidget>

	Field variant:TStarfarerVariant
	Field json_str_variant$
	Field json_view_variant:TList'<TextWidget>

	Field csv_row:TMap'<String,String>  'column name --> value
	Field csv_row_wing:TMap'<String,String>  'column name --> value

	Field weapon:TStarfarerWeapon
	Field json_str_weapon$
	Field json_view_weapon:TList'<TextWidget>

	Method New()
		Clear()
	End Method

	'requires subsequent call to update()
	'requires subsequent call to update_variant()
	'requires subsequent call to update_weapon()
	Method Clear()
		ship = New TStarfarerShip
		variant = New TStarfarerVariant
		csv_row = ship_data_csv_field_template.Copy()
		csv_row_wing = wing_data_csv_field_template.Copy()
		weapon = New TStarfarerWeapon
	EndMethod
	
	'requires subsequent call to update()
	Method decode( input_json_str$ )
		ship = TStarfarerShip( json.parse( input_json_str, "TStarfarerShip", "parse_ship" ))
		enforce_ship_internal_consistency()
	End Method
	
	Method update()
		json.formatted = True
		'encode ship object as json data
		json_str = json.stringify( ship, "stringify_ship" )
		json_view = columnize_text( json_str )
	End Method

	'requires subsequent call to update()
	Method enforce_ship_internal_consistency()
		'TEMPORARY fix for not properly initializing this data
		Fix_Map_TStrings( ship.builtInWeapons )
		'Ensure built-in weapons data is internally consistent
		For Local weapon_slot_id$ = EachIn ship.builtInWeapons.Keys()
			'to do
		Next
		For Local weapon_slot:TStarfarerShipWeapon = EachIn ship.weaponSlots
			If weapon_slot.type_ <> "BUILT_IN" ..
			And weapon_slot.type_ <> "DECORATIVE"
				ship.builtInWeapons.Remove( weapon_slot.id )
			EndIf
		Next
		'Ensure engine data is internally consistent
		For Local engine:TStarfarerShipEngine = EachIn ship.engineSlots
			If engine.style <> "CUSTOM"
				engine.styleId = Null
				engine.styleSpec = Null
			ElseIf engine.styleId <> Null
				engine.styleSpec = Null
			EndIf
		Next
	EndMethod

	'requires subsequent call to update_variant()
	Method decode_variant( input_json_str$ )
		variant = TStarfarerVariant( json.parse( input_json_str, "TStarfarerVariant" ))
		enforce_variant_internal_consistency()
	End Method
	
	Method update_variant()
		json.formatted = True
		'encode ship object as json data
		json_str_variant = json.stringify( variant, "stringify_variant" )
		json_view_variant = columnize_text( json_str_variant )
	End Method

	'requires subsequent call to update_variant()
	Method enforce_variant_internal_consistency()
		'TEMPORARY fix for not properly initializing this data
		For Local weaponGroup:TStarfarerVariantWeaponGroup = EachIn variant.weaponGroups
			Fix_Map_TStrings( weaponGroup.weapons )
		Next
	EndMethod

	'requires subsequent call to update_variant()
	Method update_variant_enforce_hull_compatibility( ed:TEditor )
		'Enforce max variant weapon groups count
		If variant.weaponGroups And variant.weaponGroups.Length > MAX_VARIANT_WEAPON_GROUPS
			variant.weaponGroups = variant.weaponGroups[..MAX_VARIANT_WEAPON_GROUPS]
		EndIf
		'Visit every weapon slot defined in the hull
		For Local weapon_slot:TStarfarerShipWeapon = EachIn ship.weaponSlots
			If weapon_slot.is_builtin()
				'Ensure that any BUILT_IN slots are set to match in the VARIANT
				Local weapon_id$ = String( ship.builtInWeapons.ValueForKey( weapon_slot.id ))
				If weapon_id <> Null
					assign_weapon_to_slot( weapon_slot.id, weapon_id )
				Else 'weapon_id == Null
					unassign_weapon_from_slot( weapon_slot.id )
				EndIf
			ElseIf Not weapon_slot.is_visible_to_variant()
				'Ensure that any SYSTEM and LAUNCH_BAY slots are not referenced at all
				unassign_weapon_from_slot( weapon_slot.id )
			EndIf
		Next
		'Visit every weapon referenced in the variant
		For Local group:TStarfarerVariantWeaponGroup = EachIn variant.weaponGroups
			For Local weapon_slot_id$ = EachIn group.weapons.Keys()
				'Ensure that the weapon slot is defined in the hull
				'And that the slot actually supports the currently assigned weapon
				If weapon_slot_id_exists( weapon_slot_id )
					Local weapon_slot:TStarfarerShipWeapon = find_weapon_slot_by_id( weapon_slot_id )
					Local valid_weapons$[] = ed.select_weapons( weapon_slot.type_, weapon_slot.size )
					Local weapon_id$ = String( group.weapons.ValueForKey( weapon_slot_id ))
					If Not in_str_array( weapon_id, valid_weapons ) 
						'Not valid
						unassign_weapon_from_slot( weapon_slot_id )	
					EndIf
				Else 
					'Not found
					unassign_weapon_from_slot( weapon_slot_id )
				EndIf
			Next
		Next
	EndMethod

	Method decode_weapon( input_json_str$ )
		weapon = TStarfarerWeapon( json.parse( input_json_str, "TStarfarerWeapon", "parse_weapon" ))
	EndMethod

	Method update_weapon()
		json.formatted = True
		json_str_weapon = json.stringify( weapon, "stringify_weapon" )
		json_view_weapon = columnize_text( json_str_weapon )
	EndMethod

	Method set_hullId( old_hullId$, hullId$ )
		'SHIP
		ship.hullId = hullId
		update()
		'VARIANT
		variant.hullId = hullId
		variant.variantId = hullId+"_variant"
		update_variant()
		'SHIP CSV
		csv_row.Insert( "id", ship.hullId )
		'WING CSV
		csv_row_wing.Insert( "variant", variant.variantId )
		csv_row_wing.Insert( "id", variant.variantId+"_wing" )
	EndMethod

	Method set_variantId( old_variantId$, variantId$ )
		'VARIANT
		variant.variantId = variantId
		update_variant()
		'WING CSV
		csv_row_wing.Insert( "variant", variant.variantId )
		csv_row_wing.Insert( "id", variant.variantId+"_wing" )
	EndMethod
	
	'/////// 

	'must be used when csv data is re-initialized by a file load process
	Method set_csv_data( data_row:TMap, which$ )
		Select which
			Case "ship_data.csv"
				csv_row = data_row
			Case "wing_data.csv"
				csv_row_wing = data_row
		EndSelect
	End Method


	'requires subsequent call to update()
	Method set_center( img_x#, img_y# )
		ship.center = New Float[2]
		ship.center[0] = img_y
		ship.center[1] = img_x
	End Method
	
	'requires subsequent call to update()
	Method set_shield_center( img_x#, img_y# )
		ship.shieldCenter = New Float[2]
		ship.shieldCenter[0] = img_x - ship.center[1]
		ship.shieldCenter[1] = -(img_y - ship.center[0])
	End Method
	
	'requires subsequent call to update()
	Method append_bound( img_x#, img_y#, reflect_over_y_axis% = False )
		If ship.center
			If Not ship.bounds
				ship.bounds = New Float[2]
			Else
				ship.bounds = ship.bounds[..ship.bounds.length+2]
			End If
			ship.bounds[ship.bounds.length-2] = img_x - ship.center[1]
			If Not reflect_over_y_axis
				ship.bounds[ship.bounds.length-1] = -( img_y - ship.center[0] )
			Else 'reflect
				ship.bounds[ship.bounds.length-1] = img_y - ship.center[0]
			End If
		End If
	End Method
	
	'requires subsequent call to update()
	Method prepend_bound( img_x#, img_y#, reflect_over_y_axis% = False )
		If ship.center
			If Not ship.bounds
				ship.bounds = New Float[2]
			Else
				ship.bounds = ship.bounds[..ship.bounds.length+2]
				For Local i% = ship.bounds.length - 1 To 2 Step -1
					ship.bounds[i] = ship.bounds[i - 2]
				Next
			End If
			ship.bounds[0] = img_x - ship.center[1]
			If Not reflect_over_y_axis
				ship.bounds[1] = -( img_y - ship.center[0] )
			Else 'reflect
				ship.bounds[1] = img_y - ship.center[0]
			End If
		End If
	End Method
	
	'requires subsequent call to update()
	Method remove_nearest_bound( img_x#, img_y#, remove_symmetrical_counterpart_if_any% = False )
		If ship.bounds And ship.center
			If remove_symmetrical_counterpart_if_any
				'delete the nearest and its symmetrical counterpart, if any
				Local nearest_i% = find_nearest_bound( img_x, img_y )
				Local counterpart_i% = find_symmetrical_counterpart( nearest_i )
				If counterpart_i = -1 'not found
					ship.bounds = remove_pair( ship.bounds, nearest_i )
				Else
					'delete in correct order to preserve indices
					If nearest_i > counterpart_i
						ship.bounds = remove_pair( ship.bounds, nearest_i )
						ship.bounds = remove_pair( ship.bounds, counterpart_i )
					Else If counterpart_i > nearest_i
						ship.bounds = remove_pair( ship.bounds, counterpart_i )
						ship.bounds = remove_pair( ship.bounds, nearest_i )
					Else
						ship.bounds = remove_pair( ship.bounds, nearest_i )
					End If
				End If
			Else
				'just delete the nearest
				Local nearest_i% = find_nearest_bound( img_x, img_y )
				ship.bounds = remove_pair( ship.bounds, nearest_i )
			End If
		End If
	End Method
	
	'requires subsequent call to update()
	Method modify_bound( i%, img_x#, img_y#, reflect_over_y_axis% = False )
		If ship.bounds And ship.center And i >= 0 And i < ship.bounds.Length - 1
			ship.bounds[i] = img_x - ship.center[1]
			If Not reflect_over_y_axis
				ship.bounds[i+1] = -( img_y - ship.center[0] )
			Else
				ship.bounds[i+1] = img_y - ship.center[0]
			End If
		End If
	End Method


	'requires subsequent call to update()
	'this function is not yet ready for prime-time
	Method insert_bound( img_x#,img_y#, reflect_over_y_axis% = False )
		If ship.bounds And ship.center
			If ship.bounds.Length < 6 'there must be at least 3 points (a triangle) for this to make sense
				append_bound( img_x, img_y, reflect_over_y_axis )
				Return
			EndIf
			Local x# = img_x - ship.center[1]
			Local y# = -( img_y - ship.center[0] )
			If reflect_over_y_axis Then y :* -1
			Local dist#, s1x#,s1y#, s2x#,s2y#
			Local nearest_i% = -1
			Local nearest_i_dist# = 0
			For Local i% = 0 Until ship.bounds.Length Step 2
				s1x = ship.bounds[i]
				s1y = ship.bounds[i+1]
				If i+2 < ship.bounds.Length
					s2x = ship.bounds[i+2]
					s2y = ship.bounds[i+3]
				Else 'wrap around to first point
					s2x = ship.bounds[0]
					s2y = ship.bounds[1]
				EndIf
				dist = calc_dist_from_point_to_segment( x,y, s1x,s1y, s2x,s2y )
				If nearest_i = -1 Or dist < nearest_i_dist
					nearest_i = i
					nearest_i_dist = dist
				Else
				EndIf
			Next
			If nearest_i = 0 'prepend; b0 -> b1
				prepend_bound( img_x, img_y, reflect_over_y_axis )
			ElseIf nearest_i = ship.bounds.Length-2 'append; bN -> b0
				append_bound( img_x, img_y, reflect_over_y_axis )
			Else 'insert middle; bV -> bW
				ship.bounds = ship.bounds[..ship.bounds.Length+2]
				For Local i% = ship.bounds.Length-2 Until nearest_i Step -2
					ship.bounds[i]   = ship.bounds[i-2]
					ship.bounds[i+1] = ship.bounds[i-1]
				Next
				ship.bounds[nearest_i]   = x
				ship.bounds[nearest_i+1] = y
			EndIf
		EndIf
	EndMethod

	'requires subsequent call to update_weapon()
	Method append_weapon_offset( img_x#,img_y#, spr_w#,spr_h#, reflect_over_y_axis% = False )
		If Not weapon Then Return
		Local L%, x#,y#
		If weapon.turretOffsets Then L = weapon.turretOffsets.Length Else L = 0
		weapon.turretOffsets = weapon.turretOffsets[..L+2]
		x = img_x - (spr_w/2.0)
		y = img_y - (spr_h/2.0)
		If reflect_over_y_axis Then y :* -1
		weapon.turretOffsets[weapon.turretOffsets.Length-2] = x
		weapon.turretOffsets[weapon.turretOffsets.Length-1] = y
		If weapon.turretAngleOffsets Then L = weapon.turretAngleOffsets.Length Else L = 0
		weapon.turretAngleOffsets = weapon.turretAngleOffsets[..L+1]
		weapon.turretAngleOffsets[weapon.turretAngleOffsets.Length-1] = 0
		If weapon.hardpointOffsets Then L = weapon.hardpointOffsets.Length Else L = 0
		weapon.hardpointOffsets = weapon.hardpointOffsets[..L+2]
		x = img_x - (spr_w/2.0)
		y = img_y - (spr_h)
		If reflect_over_y_axis Then y :* -1
		weapon.hardpointOffsets[weapon.hardpointOffsets.Length-2] = x
		weapon.hardpointOffsets[weapon.hardpointOffsets.Length-1] = y
		If weapon.hardpointAngleOffsets Then L = weapon.hardpointAngleOffsets.Length Else L = 0
		weapon.hardpointAngleOffsets = weapon.hardpointAngleOffsets[..L+1]
		weapon.hardpointAngleOffsets[weapon.hardpointAngleOffsets.Length-1] = 0
	EndMethod

	'requires subsequent call to update_weapon()	
	Method modify_weapon_offset( i%, img_x#,img_y#, spr_w#,spr_h#, weapon_display_mode$, reflect_over_y_axis%=False )
		If Not weapon Then Return
		Local offsets#[]
		Local x#,y#
		Select weapon_display_mode
			Case "turret"
				offsets = weapon.turretOffsets
				If Not offsets Or i < 0 Or i > offsets.Length-2 Then Return
				x = img_x - (spr_w / 2.0)
				y = img_y - (spr_h / 2.0)
				If reflect_over_y_axis Then y :* -1
			Case "hardpoint"
				offsets = weapon.hardpointOffsets
				If Not offsets Or i < 0 Or i > offsets.Length-2 Then Return
				x = img_x - (spr_w / 2.0)
				y = img_y - (spr_h)
				If reflect_over_y_axis Then y :* -1
		EndSelect
		If Not offsets Then Return
		offsets[i] =   x
		offsets[i+1] = y
	EndMethod

	Method remove_nearest_weapon_offset( img_x#,img_y#, spr_w#,spr_h#, weapon_display_mode$ )
		Local nearest_i% = find_nearest_weapon_offset( img_x,img_y, spr_w,spr_h, weapon_display_mode )
		If nearest_i <> -1
			weapon.turretOffsets = remove_pair( weapon.turretOffsets, nearest_i )
			weapon.turretAngleOffsets = remove_at( weapon.turretAngleOffsets, nearest_i/2 )
			weapon.hardpointOffsets = remove_pair( weapon.hardpointOffsets, nearest_i )
			weapon.hardpointAngleOffsets = remove_at( weapon.hardpointAngleOffsets, nearest_i/2 )
		EndIf
	EndMethod

	'requires subsequent call to update()
	Method add_weapon_slot( img_x#, img_y#, existing:TStarfarerShipWeapon, reflect_over_y_axis%=False )
		If Not ship.weaponSlots
			ship.weaponSlots = New TStarfarerShipWeapon[1]
		Else
			ship.weaponSlots = ship.weaponSlots[..ship.weaponSlots.Length+1]
		End If
		Local weapon:TStarfarerShipWeapon
		If Not existing
			weapon = New TStarfarerShipWeapon
		Else
			weapon = existing.Clone()
		EndIf
		weapon.locations[0] = img_x - ship.center[1]
		If Not reflect_over_y_axis
			weapon.locations[1] = -( img_y - ship.center[0] )
		Else
			weapon.locations[1] = img_y - ship.center[0]
			weapon.angle = -weapon.angle
		End If
		Local wsi% = 1
		Local wsi_str$ = zero_pad( wsi, 4 )
		weapon.id = "WS"+wsi_str
		While weapon_slot_id_exists( weapon.id )
			wsi :+ 1
			wsi_str = zero_pad( wsi, 4 )
			weapon.id = "WS"+wsi_str
		EndWhile
		ship.weaponSlots[ship.weaponSlots.Length-1] = weapon
	End Method

	'requires subsequent call to update()
	Method set_weapon_slot_location( slot_i%, img_x#, img_y#, update_symmetrical_counterpart_if_any%=False )
		If Not ship.weaponSlots Or Not ship.center Then Return
		img_x = img_x - ship.center[1]
		img_y = -( img_y - ship.center[0] )
		Local weapon:TStarfarerShipWeapon = ship.weaponSlots[slot_i]
		Local cp_weapon:TStarfarerShipWeapon = find_symmetrical_weapon_counterpart( weapon )
		weapon.locations[0] = img_x
		weapon.locations[1] = img_y
		If update_symmetrical_counterpart_if_any And cp_weapon
			cp_weapon.locations[0] = img_x
			cp_weapon.locations[1] = -img_y
		EndIf
	End Method
	
	'requires subsequent call to update()
	Method set_weapon_slot_direction( slot_i%, img_x#, img_y#, update_symmetrical_counterpart_if_any%=False )
		If Not ship.weaponSlots Or Not ship.center Then Return
		img_x = img_x - ship.center[1]
		img_y = -( img_y - ship.center[0] )
		Local weapon:TStarfarerShipWeapon = ship.weaponSlots[slot_i]
		Local cp_weapon:TStarfarerShipWeapon = find_symmetrical_weapon_counterpart( weapon )
		weapon.angle = calc_angle( weapon.locations[0], weapon.locations[1], img_x, img_y )
		If update_symmetrical_counterpart_if_any And cp_weapon
			cp_weapon.angle = -weapon.angle
		EndIf
	End Method

	'requires subsequent call to update()
	Method set_weapon_slot_angular_range( slot_i%, img_x#, img_y#, update_symmetrical_counterpart_if_any%=False )
		If Not ship.weaponSlots Or Not ship.center Then Return
		img_x = img_x - ship.center[1]
		img_y = -( img_y - ship.center[0] )
		Local weapon:TStarfarerShipWeapon = ship.weaponSlots[slot_i]
		Local cp_weapon:TStarfarerShipWeapon = find_symmetrical_weapon_counterpart( weapon )
		Local raw_angle# = calc_angle( weapon.locations[0], weapon.locations[1], img_x, img_y )
		weapon.arc = Abs( 2*ang_wrap( raw_angle - weapon.angle ))
		If weapon.arc < 0 Then weapon.arc = 0
		If weapon.arc > 360 Then weapon.arc = 360
		If update_symmetrical_counterpart_if_any And cp_weapon
			cp_weapon.arc = weapon.arc
		EndIf
	End Method

	'requires subsequent call to update()
	'     AND subsequent call to update_variant()
	Method remove_weapon_slot( slot_i%, remove_symmetrical_counterpart_if_any%=False )
		If Not ship.weaponSlots Then Return
		Local weapon:TStarfarerShipWeapon = ship.weaponSlots[slot_i]
		Local cp_weapon:TStarfarerShipWeapon = find_symmetrical_weapon_counterpart( weapon )
		ship.weaponSlots = remove_TStarfarerShipWeapon( ship.weaponSlots, weapon )
		unassign_weapon_from_slot( weapon.id )
		If remove_symmetrical_counterpart_if_any And cp_weapon
			ship.weaponSlots = remove_TStarfarerShipWeapon( ship.weaponSlots, cp_weapon )
			unassign_weapon_from_slot( cp_weapon.id )
		EndIf
	End Method

	'requires subsequent call to update()
	Method add_engine( img_x#, img_y#, existing:TStarfarerShipEngine, reflect_over_y_axis%=False )
		If Not ship.engineSlots
			ship.engineSlots = New TStarfarerShipEngine[1]
		Else
			ship.engineSlots = ship.engineSlots[..ship.engineSlots.Length+1] 
		End If
		Local engine:TStarfarerShipEngine
		If existing
			engine = existing.Clone()
		Else
			engine = New TStarfarerShipEngine
		EndIf
		engine.location[0] = img_x - ship.center[1]
		If Not reflect_over_y_axis
			engine.location[1] = -( img_y - ship.center[0] )
		Else
			engine.location[1] = img_y - ship.center[0]
			engine.angle = -engine.angle
		End If
		ship.engineSlots[ship.engineSlots.Length-1] = engine
	End Method
	
	'requires subsequent call to update()
	Method set_engine_location( slot_i%, img_x#, img_y#, update_symmetrical_counterpart_if_any%=False )
		If Not ship.engineSlots Or Not ship.center Then Return
		img_x = img_x - ship.center[1]
		img_y = -( img_y - ship.center[0] )
		Local engine:TStarfarerShipEngine = ship.engineSlots[slot_i]
		Local cp_engine:TStarfarerShipEngine = find_symmetrical_engine_counterpart( engine )
		engine.location[0] = img_x
		engine.location[1] = img_y
		If update_symmetrical_counterpart_if_any And cp_engine
			cp_engine.location[0] = img_x
			cp_engine.location[1] = -img_y
		EndIf
	End Method

	'requires subsequent call to update()
	Method set_engine_angle( slot_i%, img_x#, img_y#, update_symmetrical_counterpart_if_any%=False )
		If Not ship.engineSlots Or Not ship.center Then Return
		img_x = img_x - ship.center[1]
		img_y = -( img_y - ship.center[0] )
		Local engine:TStarfarerShipEngine = ship.engineSlots[slot_i]
		Local cp_engine:TStarfarerShipEngine = find_symmetrical_engine_counterpart( engine )
		engine.angle = calc_angle( engine.location[0], engine.location[1], img_x, img_y )
		If update_symmetrical_counterpart_if_any And cp_engine
			cp_engine.angle = -engine.angle
		EndIf
	End Method

	'requires subsequent call to update()
	Method set_engine_size( slot_i%, img_x#, img_y#, update_symmetrical_counterpart_if_any%=False )
		If Not ship.engineSlots Or Not ship.center Then Return
		img_x = img_x - ship.center[1]
		img_y = -( img_y - ship.center[0] )
		Local engine:TStarfarerShipEngine = ship.engineSlots[slot_i]
		Local cp_engine:TStarfarerShipEngine = find_symmetrical_engine_counterpart( engine )
		'mouse relative to engine
		Local mouse#[] = New Float[2]
		mouse[0] = img_x - engine.location[0]
		mouse[1] = img_y - engine.location[1]
		'get length via norm facing the direction of the engine
		Local norm#[] = New Float[2]
		norm[0] = Cos( engine.angle )
		norm[1] = Sin( engine.angle )
		engine.length = Max( 0, norm[0]*mouse[0] + norm[1]*mouse[1] )
		'get width via norm facing perpendicular to the previous
		norm[0] = Cos( engine.angle + 90 )
		norm[1] = Sin( engine.angle + 90 )
		engine.width = Abs( 2*(norm[0]*mouse[0] + norm[1]*mouse[1]) )
		engine.contrailSize = engine.width
		If update_symmetrical_counterpart_if_any And cp_engine
			cp_engine.length = engine.length
			cp_engine.width = engine.width
			cp_engine.contrailSize = engine.contrailSize
		EndIf
	End Method

	'requires subsequent call to update()
	Method remove_engine( slot_i% , remove_symmetrical_counterpart_if_any%=False )
		If Not ship.engineSlots Then Return
		Local engine:TStarfarerShipEngine = ship.engineSlots[slot_i]
		Local cp_engine:TStarfarerShipEngine = find_symmetrical_engine_counterpart( engine )
		ship.engineSlots = remove_TStarfarerShipEngine( ship.engineSlots, engine )
		If remove_symmetrical_counterpart_if_any And cp_engine
			ship.engineSlots = remove_TStarfarerShipEngine( ship.engineSlots, cp_engine )
		EndIf
	End Method

	'requires subsequent call to update()
	Method set_launch_bay_port_location( slot_i%, loc_i%, img_x#, img_y#, update_symmetrical_counterpart_if_any%=False )
		If Not ship.weaponSlots Or Not ship.center Then Return
		img_x = img_x - ship.center[1]
		img_y = -( img_y - ship.center[0] )
		Local launch_bay:TStarfarerShipWeapon = ship.weaponSlots[slot_i]
		'Local cp_launch_bay:TStarfarerShipWeapon = find_symmetrical_weapon_counterpart( launch_bay )
		launch_bay.locations[loc_i+0] = img_x
		launch_bay.locations[loc_i+1] = img_y
		'If update_symmetrical_counterpart_if_any And cp_launch_bay
		'	cp_launch_bay.locations[0] = img_x
		'	cp_launch_bay.locations[1] = -img_y
		'EndIf
	End Method

	'requires subsequent call to update()
	Method add_launch_bay_port( img_x#, img_y#, selected_launch_bay_index%, reflect_over_y_axis%=False )
		If Not ship.center Then Return
		img_x = img_x - ship.center[1]
		img_y = -( img_y - ship.center[0] )
		'find launch bay
		Local launch_bay:TStarfarerShipWeapon = get_launch_bay_by_contextual_index( selected_launch_bay_index )
		If launch_bay
			'add space for a new port in the bay
			launch_bay.locations = launch_bay.locations[..launch_bay.locations.length+2]
		Else
			'add new launch bay (weapon)
			launch_bay = New TStarfarerShipWeapon
			launch_bay.type_ = "LAUNCH_BAY"
      launch_bay.mount = "HIDDEN"
      launch_bay.size = "LARGE"
      launch_bay.angle = 0
      launch_bay.arc = 360
			'name the launch bay
			Local wsi% = 1
			launch_bay.id = "LB "+wsi
			While weapon_slot_id_exists( launch_bay.id )
				wsi :+ 1
				launch_bay.id = "LB "+wsi
			EndWhile
			'register it
			If Not ship.weaponSlots
				ship.weaponSlots = [ launch_bay ]
			Else
				ship.weaponSlots = ship.weaponSlots[..ship.weaponSlots.Length+1]
				ship.weaponSlots[ship.weaponSlots.Length-1] = launch_bay
			EndIf
		EndIf
		'set the requested location as a port of the launch bay
		launch_bay.locations[launch_bay.locations.length-2] = img_x
		launch_bay.locations[launch_bay.locations.length-1] = img_y
	EndMethod

	'requires subsequent call to update()
	Method remove_launch_bay_port( slot_i%, loc_i%, update_symmetrical_counterpart_if_any%=False )
		If Not ship.weaponSlots Or Not ship.center Then Return
		Local launch_bay:TStarfarerShipWeapon = ship.weaponSlots[slot_i]
		launch_bay.locations = remove_pair( launch_bay.locations, loc_i )
		If launch_bay.locations.length = 0
			ship.weaponSlots = remove_TStarfarerShipWeapon( ship.weaponSlots, launch_bay )
		EndIf
	EndMethod

	'requires subsequent call to update()
	Method set_weapon_offset_angle( slot_i%, img_x#,img_y#, spr_w#,spr_h#, weapon_display_mode$, update_symmetrical_counterpart_if_any%=False )
		If Not weapon Then Return
		Local offsets#[], angleOffsets#[]
		Local x#, y#
		Select weapon_display_mode
			Case "turret"
				offsets = weapon.turretOffsets
				angleOffsets = weapon.turretAngleOffsets
				x = img_x - (spr_w / 2.0)
				y = img_y - (spr_h / 2.0)
			Case "hardpoint"
				offsets = weapon.hardpointOffsets
				angleOffsets = weapon.hardpointAngleOffsets
				x = img_x - (spr_w / 2.0)
				y = img_y - (spr_h)
		EndSelect
		Local new_ang# = calc_angle( offsets[slot_i],offsets[slot_i+1], x,y )
		angleOffsets[slot_i/2] = new_ang
		If update_symmetrical_counterpart_if_any
			Local slot_i_cp% = find_symmetrical_weapon_offset_counterpart( slot_i, weapon_display_mode )
			angleOffsets[slot_i_cp/2] = -new_ang
		EndIf
	End Method

	'////////////
	
	'requires subsequent call to update_variant()
	Method assign_weapon_to_slot( ship_weapon_slot_id$, weapon_id$, group_i%=0 )
		Local found% = False
		If variant.weaponGroups
			'if a slot assignment already exists, update it
			For Local group:TStarfarerVariantWeaponGroup = EachIn variant.weaponGroups
				For Local existing_ship_weapon_slot_id$ = EachIn group.weapons.Keys()
					If ship_weapon_slot_id = existing_ship_weapon_slot_id
						group.weapons.Insert( ship_weapon_slot_id, weapon_id )
						found = True
						Exit
					EndIf
				Next
				If found Then Exit
			Next
		EndIf
		'otherwise, insert it to group_i
		If Not found
			If group_i >= variant.weaponGroups.length
				Local group:TStarfarerVariantWeaponGroup = New TStarfarerVariantWeaponGroup
				group.weapons.Insert( ship_weapon_slot_id, weapon_id )
				If variant.weaponGroups.length = 0
					variant.weaponGroups = New TStarfarerVariantWeaponGroup[1]
					variant.weaponGroups[0] = group
				Else 'variant.weaponGroups.length > 0
					Local L% = variant.weaponGroups.length
					variant.weaponGroups = variant.weaponGroups[..(group_i + 1)]
					For Local g% = L Until variant.weaponGroups.length
						variant.weaponGroups[g] = New TStarfarerVariantWeaponGroup
					Next
					variant.weaponGroups[group_i] = group
				EndIf
			Else 'group_i < variant.weaponGroups.length
				Local group:TStarfarerVariantWeaponGroup = variant.weaponGroups[group_i]
				group.weapons.Insert( ship_weapon_slot_id, weapon_id )
			EndIf
		EndIf
	EndMethod
	
	'requires subsequent call to update_variant()
	Method unassign_weapon_from_slot( ship_weapon_slot_id$ )
		'remove a slot assignment
		For Local group:TStarfarerVariantWeaponGroup = EachIn variant.weaponGroups
			For Local existing_ship_weapon_slot_id$ = EachIn group.weapons.Keys()
				If ship_weapon_slot_id = existing_ship_weapon_slot_id
					group.weapons.Remove( ship_weapon_slot_id )
					'TODO: if the group is empty, remove it (??)
				EndIf
			Next
		Next
	EndMethod

	'requires subsequent call to update()
	'AND a subsequent call to update_variant() !!!
	Method assign_builtin_weapon_to_slot( ship_weapon_slot_id$, weapon_id$ )
		ship.builtInWeapons.Insert( ship_weapon_slot_id, weapon_id )
		assign_weapon_to_slot( ship_weapon_slot_id, weapon_id )
	EndMethod

	'requires subsequent call to update()
	'AND a subsequent call to update_variant() !!!
	Method unassign_builtin_weapon_from_slot( ship_weapon_slot_id$ )
		ship.builtInWeapons.Remove( ship_weapon_slot_id )
		unassign_weapon_from_slot( ship_weapon_slot_id )
	EndMethod

	'requires subsequent call to update_variant()
	Method toggle_weapon_group_autofire( group_i% )
		If group_i >= variant.weaponGroups.length Then Return
		Local group:TStarfarerVariantWeaponGroup = variant.weaponGroups[group_i]
		If group
			group.autofire.value = Not group.autofire.value
		EndIf
	EndMethod

	'requires subsequent call to update_variant()
	Method modify_fluxVents( maximum%, decrement%=False )
		If Not decrement
			variant.fluxVents :+ 1
			If variant.fluxVents > maximum Then variant.fluxVents = maximum
		Else
			variant.fluxVents :- 1
			If variant.fluxVents < 0 Then variant.fluxVents = 0
		EndIf
	EndMethod

	'requires subsequent call to update_variant()
	Method modify_fluxCapacitors( maximum%, decrement%=False )
		If Not decrement
			variant.fluxCapacitors :+ 1
			If variant.fluxCapacitors > maximum Then variant.fluxCapacitors = maximum
		Else
			variant.fluxCapacitors :- 1
			If variant.fluxCapacitors < 0 Then variant.fluxCapacitors = 0
		EndIf
	EndMethod

	'requires subsequent call to update_variant()
	Method add_hullmod( hullmod_id$ )
		If variant.hullMods.length > 0
			For Local existing_hullmod_id$ = EachIn variant.hullMods
				If existing_hullmod_id = hullmod_id
					Return 'done
				EndIf
			Next
			variant.hullMods = variant.hullMods[..variant.hullMods.length+1]
			variant.hullMods[variant.hullMods.length-1] = hullmod_id
		Else
			variant.hullMods = New String[1]
			variant.hullMods[0] = hullmod_id
		EndIf
	EndMethod

	'requires subsequent call to update_variant()
	Method remove_hullmod( hullmod_id$ )
		If variant.hullMods.length > 0
			For Local i% = 0 Until variant.hullMods.length
				If variant.hullMods[i] = hullmod_id
					'Found. Remove.
					For i = i Until variant.hullMods.Length-1
						variant.hullMods[i] = variant.hullMods[i+1]
					Next
					variant.hullMods = variant.hullMods[..variant.hullMods.length-1]
				EndIf
			Next
		Else
			Return 'done
		EndIf
	EndMethod

	'requires subsequent call to update_variant()
	Method toggle_hullmod( hullmod_id$ )
		If variant.hullMods.length > 0
			Local found% = False
			For Local i% = 0 Until variant.hullMods.length
				If variant.hullMods[i] = hullmod_id
					'Found, Remove
					found = True
					For i = i Until variant.hullMods.Length-1
						variant.hullMods[i] = variant.hullMods[i+1]
					Next
					variant.hullMods = variant.hullMods[..variant.hullMods.length-1]
				EndIf
			Next
			If Not found
				'Non-Empty but Not Found, Add
				variant.hullMods = variant.hullMods[..variant.hullMods.length+1]
				variant.hullMods[variant.hullMods.length-1] = hullmod_id
			EndIf
		Else
			'Empty, Add
			variant.hullMods = New String[1]
			variant.hullMods[0] = hullmod_id
		EndIf
	EndMethod

	'requires subsequent call to update()
	Method toggle_builtin_hullmod( hullmod_id$ )
		If ship.builtInMods.length > 0
			Local found% = False
			For Local i% = 0 Until ship.builtInMods.length
				If ship.builtInMods[i] = hullmod_id
					'Found, Remove
					found = True
					For i = i Until ship.builtInMods.Length-1
						ship.builtInMods[i] = ship.builtInMods[i+1]
					Next
					ship.builtInMods = ship.builtInMods[..ship.builtInMods.length-1]
				EndIf
			Next
			If Not found
				'Non-Empty but Not Found, Add
				ship.builtInMods = ship.builtInMods[..ship.builtInMods.length+1]
				ship.builtInMods[ship.builtInMods.length-1] = hullmod_id
			EndIf
		Else
			'Empty, Add
			ship.builtInMods = New String[1]
			ship.builtInMods[0] = hullmod_id
		EndIf
	EndMethod

	'////////////////

	Method find_assigned_slot_parent_group:TStarfarerVariantWeaponGroup( ship_weapon_slot_id$ )
		For Local group:TStarfarerVariantWeaponGroup = EachIn variant.weaponGroups
			For Local assigned_slot_id$ = EachIn group.weapons.Keys()
				If assigned_slot_id = ship_weapon_slot_id
					Return group
				EndIf
			Next
		Next
		Return Null
	EndMethod

	Method find_assigned_slot_parent_group_index%( ship_weapon_slot_id$ )
		For Local i% = 0 Until variant.weaponGroups.length
			Local group:TStarfarerVariantWeaponGroup = variant.weaponGroups[i]
			If group
				For Local assigned_slot_id$ = EachIn group.weapons.Keys()
					If assigned_slot_id = ship_weapon_slot_id
						Return i
					EndIf
				Next
			EndIf
		Next
		Return -1
	EndMethod

	Method find_assigned_slot_weapon$( ship_weapon_slot_id$ )
		For Local group:TStarfarerVariantWeaponGroup = EachIn variant.weaponGroups
			For Local assigned_slot_id$ = EachIn group.weapons.Keys()
				If assigned_slot_id = ship_weapon_slot_id
					Return String( group.weapons.ValueForKey( ship_weapon_slot_id ))
				EndIf
			Next
		Next
		Return Null
	EndMethod

	Method weapon_slot_id_exists%( id_str$ )
		If Not ship Or Not ship.weaponslots Or ship.weaponslots.length = 0 Then Return False
		For Local weapon_slot:TStarfarerShipWeapon = EachIn ship.weaponSlots
			If weapon_slot.id = id_str Then Return True
		Next
		Return False
	EndMethod

	Method find_weapon_slot_by_id:TStarfarerShipWeapon( id_str$ )
		If Not ship Or Not ship.weaponSlots Or ship.weaponSlots.length = 0 Then Return Null
		For Local weapon_slot:TStarfarerShipWeapon = EachIn ship.weaponSlots
			If weapon_slot.id = id_str Then Return weapon_slot
		Next
		Return Null
	EndMethod

	Method find_nearest_bound%( img_x#, img_y# )
		If Not ship.bounds Or Not ship.center Then Return -1
		img_x = img_x - ship.center[1]
		img_y = -( img_y - ship.center[0] )
		Local nearest_i% = -1
		Local nearest_dist# = -1
		Local dist#
		For Local i% = 0 Until ship.bounds.length-1 Step 2
			dist = calc_distance( img_x, img_y, ship.bounds[i], ship.bounds[i+1] )
			If nearest_i = -1 Or dist < nearest_dist
				nearest_dist = dist
				nearest_i = i
			End If
		Next
		Return nearest_i
	End Method

	Method find_nearest_weapon_offset%( img_x#,img_y#, spr_w#,spr_h#, weapon_display_mode$ )
		If Not weapon Then Return -1
		Local offsets#[]
		Select weapon_display_mode
			Case "turret"
				offsets = weapon.turretOffsets
				img_x = img_x - (spr_w / 2.0)
				img_y = img_y - (spr_h / 2.0)
			Case "hardpoint"
				offsets = weapon.hardpointOffsets
				img_x = img_x - (spr_w / 2.0)
				img_y = img_y - (spr_h)
		EndSelect
		If Not offsets Then Return -1
		Local nearest_i% = -1
		Local nearest_dist# = -1
		Local dist#
		For Local i% = 0 Until offsets.length Step 2
			dist = calc_distance( img_x,img_y, offsets[i],offsets[i+1] )
			If nearest_i = -1 Or dist < nearest_dist
				nearest_dist = dist
				nearest_i = i
			End If
		Next
		Return nearest_i
	End Method

	'excludes only launch bays; intended to be used while defining
	'weapon slots in SHIP mode.
	Method find_nearest_weapon_slot%( img_x#, img_y# )
		If Not ship.weaponSlots Or Not ship.center Then Return -1
		img_x = img_x - ship.center[1]
		img_y = -( img_y - ship.center[0] )
		Local nearest_i% = -1
		Local nearest_dist# = -1
		Local dist#
		For Local i% = 0 Until ship.weaponSlots.length
			If ship.weaponSlots[i].is_launch_bay()
				Continue 'skip these
			EndIf
			dist = calc_distance( img_x, img_y, ship.weaponSlots[i].locations[0], ship.weaponSlots[i].locations[1] )
			If nearest_i = -1 Or dist < nearest_dist
				nearest_dist = dist
				nearest_i = i
			End If
		Next
		Return nearest_i
	End Method
	
	'excludes built-in weapon slots because this method is intended
	'to work properly in VARIANT mode;
	Method find_nearest_variant_weapon_slot%( img_x#, img_y# )
		If Not ship.weaponSlots Or Not ship.center Then Return -1
		img_x = img_x - ship.center[1]
		img_y = -( img_y - ship.center[0] )
		Local nearest_i% = -1
		Local nearest_dist# = -1
		Local dist#
		For Local i% = 0 Until ship.weaponSlots.length
			If Not ship.weaponSlots[i].is_visible_to_variant()
				Continue 'skip these
			EndIf
			dist = calc_distance( img_x, img_y, ship.weaponSlots[i].locations[0], ship.weaponSlots[i].locations[1] )
			If nearest_i = -1 Or dist < nearest_dist
				nearest_dist = dist
				nearest_i = i
			End If
		Next
		Return nearest_i
	End Method
	
	'this method is intended to work exclusively while editing BUILT-IN weapon slots
	'so it exludes non-built-in and launch bay weapon slots;
	Method find_nearest_builtin_weapon_slot%( img_x#, img_y# )
		If Not ship.weaponSlots Or Not ship.center Then Return -1
		img_x = img_x - ship.center[1]
		img_y = -( img_y - ship.center[0] )
		Local nearest_i% = -1
		Local nearest_dist# = -1
		Local dist#
		For Local i% = 0 Until ship.weaponSlots.length
			If Not ship.weaponSlots[i].is_builtin()
				Continue 'skip these
			EndIf
			dist = calc_distance( img_x, img_y, ship.weaponSlots[i].locations[0], ship.weaponSlots[i].locations[1] )
			If nearest_i = -1 Or dist < nearest_dist
				nearest_dist = dist
				nearest_i = i
			End If
		Next
		Return nearest_i
	End Method
	
	Method find_nearest_engine%( img_x#, img_y# )
		If Not ship.engineSlots Or Not ship.center Then Return -1
		img_x = img_x - ship.center[1]
		img_y = -( img_y - ship.center[0] )
		Local nearest_i% = -1
		Local nearest_dist# = -1
		Local dist#
		For Local i% = 0 Until ship.engineSlots.length
			dist = calc_distance( img_x, img_y, ship.engineSlots[i].location[0], ship.engineSlots[i].location[1] )
			If nearest_i = -1 Or dist < nearest_dist
				nearest_dist = dist
				nearest_i = i
			End If
		Next
		Return nearest_i
	End Method
	
	Method get_launch_bay_by_contextual_index:TStarfarerShipWeapon( LB_i% )
		If Not ship.weaponSlots Then Return Null
		Local c_i% = 0
		For Local i% = 0 Until ship.weaponSlots.length
			Local weapon:TStarfarerShipWeapon = ship.weaponSlots[i]
			If weapon.is_launch_bay()
				If c_i = LB_i Then Return weapon
				c_i :+ 1
			EndIf
		Next
		Return Null
	EndMethod

	Method launch_bay_count%()
		If Not ship.weaponSlots Then Return 0
		Local count% = 0
		For Local weapon:TStarfarerShipWeapon = EachIn ship.weaponSlots
			If weapon.is_launch_bay() Then count :+ 1
		Next
		Return count
	EndMethod

	Method find_symmetrical_counterpart%( i% )
		If Not ship.bounds Or i Mod 2 <> 0 Or i < 0 Or i > ship.bounds.length-2 Then Return -1
		Local x# = ship.bounds[i]
		Local y# = ship.bounds[i+1]
		For Local si% = 0 Until ship.bounds.length Step 2
			If  ship.bounds[si]   = x ..
			And ship.bounds[si+1] = -y
				Return si
			End If
		Next
		Return -1
	End Method

	Method find_symmetrical_weapon_offset_counterpart%( i%, weapon_display_mode$ )
		Local offsets#[]
		If weapon_display_mode = "turret"
			offsets = weapon.turretOffsets
		Else If weapon_display_mode = "hardpoint"
			offsets = weapon.hardpointOffsets
		EndIf
		Local x# = offsets[i]
		Local y# = offsets[i+1]
		If Not offsets Or i Mod 2 <> 0 Or i < 0 Or i > offsets.length-2 Then Return -1
		For Local si% = 0 Until offsets.length Step 2
			If  offsets[si]   = x  ..
			And offsets[si+1] = -y ..
			And i <> si
				Return si
			EndIf
		Next
		Return -1
	End Method

	Method find_symmetrical_weapon_counterpart:TStarfarerShipWeapon( weapon:TStarfarerShipWeapon )
		Local cp_weapon:TStarfarerShipWeapon
		For Local si% = 0 Until ship.weaponSlots.length
			cp_weapon = ship.weaponSlots[si]
			If  cp_weapon <> weapon ..
			And cp_weapon.locations[0] = weapon.locations[0] ..
			And cp_weapon.locations[1] = -weapon.locations[1] ..
			And cp_weapon.angle = -weapon.angle ..
			And cp_weapon.arc = weapon.arc
				Return cp_weapon
			End If
		Next
		Return Null
	End Method

	Method find_symmetrical_engine_counterpart:TStarfarerShipEngine( engine:TStarfarerShipEngine )
		Local cp_engine:TStarfarerShipEngine
		For Local si% = 0 Until ship.engineSlots.length
			cp_engine = ship.engineSlots[si]
			If  cp_engine <> engine ..
			And cp_engine.location[0] = engine.location[0] ..
			And cp_engine.location[1] = -engine.location[1] ..
			And cp_engine.angle = -engine.angle ..
			And cp_engine.length = engine.length ..
			And cp_engine.width = engine.width
				Return cp_engine
			End If
		Next
		Return Null
	End Method

	Method has_hullmod%( hullmod_id$ )
		If variant.hullMods.length > 0
			Local found% = False
			For Local i% = 0 Until variant.hullMods.length
				If variant.hullMods[i] = hullmod_id
					Return True
				EndIf
			Next
			Return False
		Else
			Return False
		EndIf
	EndMethod

	Method has_builtin_hullmod%( hullmod_id$ )
		If ship.builtInMods.length > 0
			Local found% = False
			For Local i% = 0 Until ship.builtInMods.length
				If ship.builtInMods[i] = hullmod_id
					Return True
				EndIf
			Next
			Return False
		Else
			Return False
		EndIf
	EndMethod

	Method columnize_text:TList( text$ )
		'break the data into viewport-sized column-chunks for condensed
		Local columns:TList = CreateList()
		Local lines$[] = text.Split("~n")
		Local lines_per_col% = H_MAX / DATA_LINE_HEIGHT - 2 'factor in status bar height at bottom, bout 2 lines or so
		Local cols% = Ceil( Float(lines.length) / Float(lines_per_col) )
		SetImageFont( DATA_FONT ) 'TextWidget uses TextWidth() to determine size, which uses current TImageFont
		For Local c% = 0 Until cols
			Local widget:TextWidget = TextWidget.Create( lines[c*lines_per_col..(c + 1)*lines_per_col] )
			columns.AddLast( widget )
		Next
		SetImageFont( FONT )
		Return columns
	EndMethod

End Type

