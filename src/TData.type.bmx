'-----------------------

Type TData
	
	Field ship:TStarfarerShip
	Field json_str$
	Field json_view:TList'<TextWidget>

	Field variant:TStarfarerVariant
	Field json_str_variant$
	Field json_view_variant:TList'<TextWidget>

	Field csv_row:TMap'<String,String>  'column name --> value

	Field encode_settings:TJSONEncodeSettings
	Field decode_settings:TJSONDecodeSettings
	
	'requires subsequent call to update()
	Method New()
		ship = New TStarfarerShip
		variant = New TStarfarerVariant
		csv_row = ship_data_csv_field_template.Copy()

		encode_settings = New TJSONEncodeSettings
		decode_settings = New TJSONDecodeSettings
	End Method
	
	'requires subsequent call to update()
	Method decode( input_json_str$ )
		ship = TStarfarerShip( JSON.decode( input_json_str, decode_settings, TTypeId.ForName("TStarfarerShip")))
	End Method
	
	'requires subsequent call to update_variant()
	Method decode_variant( input_json_str$ )
		variant = TStarfarerVariant( JSON.decode( input_json_str, decode_settings, TTypeId.ForName("TStarfarerVariant")))
	End Method
	
	Method update()
		'encode ship object as json data
		json_str = JSON.Encode( ship, encode_settings )
		json_view = columnize_text( json_str )
	End Method
	
	Method update_variant()
		'encode ship object as json data
		json_str_variant = JSON.Encode( variant, encode_settings )
		json_view_variant = columnize_text( json_str_variant )
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
	Method add_weapon_slot( img_x#, img_y#, existing:TStarfarerShipWeapon, reflect_over_y_axis%=false )
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
		if Not reflect_over_y_axis
			weapon.locations[1] = -( img_y - ship.center[0] )
		Else
			weapon.locations[1] = img_y - ship.center[0]
			weapon.angle = -weapon.angle
		end if
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
	Method set_weapon_slot_location( slot_i%, img_x#, img_y#, update_symmetrical_counterpart_if_any%=false )
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
	Method set_weapon_slot_direction( slot_i%, img_x#, img_y#, update_symmetrical_counterpart_if_any%=false )
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
	Method set_weapon_slot_angular_range( slot_i%, img_x#, img_y#, update_symmetrical_counterpart_if_any%=false )
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
	Method add_engine( img_x#, img_y#, existing:TStarfarerShipEngine, reflect_over_y_axis%=false )
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
		if not reflect_over_y_axis
			engine.location[1] = -( img_y - ship.center[0] )
		Else
			engine.location[1] = img_y - ship.center[0]
			engine.angle = -engine.angle
		end if
		ship.engineSlots[ship.engineSlots.Length-1] = engine
	End Method
	
	'requires subsequent call to update()
	Method set_engine_location( slot_i%, img_x#, img_y#, update_symmetrical_counterpart_if_any%=FALSE )
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
	Method set_engine_angle( slot_i%, img_x#, img_y#, update_symmetrical_counterpart_if_any%=FALSE )
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
	Method set_engine_size( slot_i%, img_x#, img_y#, update_symmetrical_counterpart_if_any%=FALSE )
		If Not ship.engineSlots Or Not ship.center Then Return
		img_x = img_x - ship.center[1]
		img_y = -( img_y - ship.center[0] )
		Local engine:TStarfarerShipEngine = ship.engineSlots[slot_i]
		Local cp_engine:TStarfarerShipEngine = find_symmetrical_engine_counterpart( engine )
		'mouse relative to engine
		Local mouse#[] = New float[2]
		mouse[0] = img_x - engine.location[0]
		mouse[1] = img_y - engine.location[1]
		'get length via norm facing the direction of the engine
		Local norm#[] = New Float[2]
		norm[0] = cos( engine.angle )
		norm[1] = sin( engine.angle )
		engine.length = Max( 0, norm[0]*mouse[0] + norm[1]*mouse[1] )
		'get width via norm facing perpendicular to the previous
		norm[0] = cos( engine.angle + 90 )
		norm[1] = sin( engine.angle + 90 )
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
	Method set_launch_bay_port_location( slot_i%, loc_i%, img_x#, img_y#, update_symmetrical_counterpart_if_any%=false )
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
	Method add_launch_bay_port( img_x#, img_y#, selected_launch_bay_index%, reflect_over_y_axis%=false )
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
	EndMEthod

	'requires subsequent call to update()
	Method remove_launch_bay_port( slot_i%, loc_i%, update_symmetrical_counterpart_if_any%=false )
		If Not ship.weaponSlots Or Not ship.center Then Return
		Local launch_bay:TStarfarerShipWeapon = ship.weaponSlots[slot_i]
		launch_bay.locations = remove_pair( launch_bay.locations, loc_i )
		If launch_bay.locations.length = 0
			ship.weaponSlots = remove_TStarfarerShipWeapon( ship.weaponSlots, launch_bay )
		EndIf
	EndMethod

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
					For Local g% = L until variant.weaponGroups.length
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
		If not ship Or not ship.weaponslots or ship.weaponslots.length = 0 Then return false
		For Local weapon_slot:TStarfarerShipWeapon = EachIn ship.weaponSlots
			if weapon_slot.id = id_str Then return true
		Next
		return false
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
		For Local i% = 0 until ship.weaponSlots.length
			Local weapon:TStarfarerShipWeapon = ship.weaponSlots[i]
			If weapon.is_launch_bay()
				If c_i = LB_i Then Return weapon
				c_i :+ 1
			EndIf
		Next
		Return Null
	EndMethod

	Method launch_bay_count%()
		If Not ship.weaponSlots Then return 0
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
			If  ship.bounds[si] = x ..
			And ship.bounds[si+1] = -y
				Return si
			End If
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

