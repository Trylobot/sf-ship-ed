
Const ICON_KB% = 10
Const ICON_SHIFT_KB% = 11
Const ICON_CTRL_KB% = 12
Const ICON_CTRL_ALT_KB% = 13
Const ICON_MS_LEFT% = 20
Const ICON_MS_RIGHT% = 21
Const ICON_MS_MIDDLE% = 22
Const ICON_SHIFT_CLICK% = 30
Const ICON_CTRL_CLICK% = 31
Const ICON_ALT_CLICK% = 32
Const ICON_SPACEBAR% = 33
Const ICON_CTRL_ALT_RIGHT_CLICK% = 34

Global HELP_WIDGETS:TList
Global HELP_LINE_HEIGHT%
Global CONTEXT_HELP:TMap

Global mouse_str$

Function load_help()
	LocalizeString("{{}}")
	HELP_WIDGETS = CreateList()
	HELP_LINE_HEIGHT = APP.font_size + Int((Float(APP.font_size)/7.0))
	'///////////////////////////////////////////// ( key, description, icon, enable, space_after, program modes, sub-modes )
	HELP_WIDGETS.AddLast( TKeyboardHelpWidget.Create( "1", LocalizeString("{{h_pmode_1}}"), ICON_KB, True, 0 ) )
	HELP_WIDGETS.AddLast( TKeyboardHelpWidget.Create( "2", LocalizeString("{{h_pmode_2}}"), ICON_KB, True, 0 ) )
	HELP_WIDGETS.AddLast( TKeyboardHelpWidget.Create( "3", LocalizeString("{{h_pmode_3}}"), ICON_KB, True, 0 ))
	HELP_WIDGETS.AddLast( TKeyboardHelpWidget.Create( "4", LocalizeString("{{h_pmode_4}}"), ICON_KB, True, 0 ))
	HELP_WIDGETS.AddLast( TKeyboardHelpWidget.Create( "5", LocalizeString("{{h_pmode_5}}"), ICON_KB, True, 0 ) )
	HELP_WIDGETS.AddLast( TKeyboardHelpWidget.Create( "6", LocalizeString("{{h_pmode_6}}"), ICON_KB, True, 0 ))
	HELP_WIDGETS.AddLast( TKeyboardHelpWidget.Create( "7",LocalizeString("{{h_pmode_7}}"), ICON_KB, True, 0 ))
	HELP_WIDGETS.AddLast( TKeyboardHelpWidget.Create( "8",LocalizeString("{{h_pmode_8}}"), ICON_KB, False, 1 ))
	'////////////
	HELP_WIDGETS.AddLast( TKeyboardHelpWidget.Create( "", LocalizeString("{{h_mouse_pan}}"), ICON_MS_RIGHT, True, 0 ))
	HELP_WIDGETS.AddLast( TKeyboardHelpWidget.Create( "", LocalizeString("{{h_mouse_zoom}}"), ICON_MS_MIDDLE, True, 1 ))
	'/////////////////////////////////////////////'
	HELP_WIDGETS.AddLast( TKeyboardHelpWidget.Create( "~~",LocalizeString("{{h_option_toggleVanilla}}"), ICON_KB, True, 0 ))
	HELP_WIDGETS.AddLast( TKeyboardHelpWidget.Create( "M", LocalizeString("{{h_file_loadMod}}"), ICON_KB, True, 0 ))
	HELP_WIDGETS.AddLast( TKeyboardHelpWidget.Create( "I", LocalizeString("{{h_file_ship_loadImage}}"), ICON_KB, True, 0, "ship" ))
	HELP_WIDGETS.AddLast( TKeyboardHelpWidget.Create( "D", LocalizeString("{{h_file_ship_loadData}}"), ICON_KB, True, 0, "ship" ))
	HELP_WIDGETS.AddLast( TKeyboardHelpWidget.Create( "V", LocalizeString("{{h_file_ship_saveData}}"), ICON_KB, True, 0, "ship" ) )
	HELP_WIDGETS.AddLast( TKeyboardHelpWidget.Create( "N", LocalizeString("{{h_file_newData}}"), ICON_CTRL_ALT_KB, True, 1, "ship" ) )
	'//////////// 
	HELP_WIDGETS.AddLast( TKeyboardHelpWidget.Create( "D", LocalizeString("{{h_file_variant_loadData}}"), ICON_KB, True, 0, "variant" ) )
	HELP_WIDGETS.AddLast( TKeyboardHelpWidget.Create( "V", LocalizeString("{{h_file_variant_saveData}}"), ICON_KB, True, 0, "variant" ) )
	HELP_WIDGETS.AddLast( TKeyboardHelpWidget.Create( "N", LocalizeString("{{h_file_newData}}"), ICON_CTRL_ALT_KB, True, 1, "variant" ) )
	'//////////// 
	HELP_WIDGETS.AddLast( TKeyboardHelpWidget.Create( "D", LocalizeString("{{h_file_skin_loadData}}"), ICON_KB, True, 0, "skin" ) )
	HELP_WIDGETS.AddLast( TKeyboardHelpWidget.Create( "V", LocalizeString("{{h_file_skin_saveData}}"), ICON_KB, True, 0, "skin" ) )
	HELP_WIDGETS.AddLast( TKeyboardHelpWidget.Create( "N", LocalizeString("{{h_file_newData}}"), ICON_CTRL_ALT_KB, True, 1, "skin" ) )
	'//////////// 
	HELP_WIDGETS.AddLast( TKeyboardHelpWidget.Create( "D", LocalizeString("{{h_file_csv_loadData}}"), ICON_KB, True, 0, "csv" ))
	HELP_WIDGETS.AddLast( TKeyboardHelpWidget.Create( "V", LocalizeString("{{h_file_csv_saveData}}"), ICON_KB, True, 1, "csv" ))
	'//////////// 
	HELP_WIDGETS.AddLast( TKeyboardHelpWidget.Create( "D", LocalizeString("{{h_file_wingcsv_loadData}}"), ICON_KB, True, 0, "csv_wing" ))
	HELP_WIDGETS.AddLast( TKeyboardHelpWidget.Create( "V", LocalizeString("{{h_file_wingcsv_saveData}}"), ICON_KB, True, 1, "csv_wing" ))
	'/////////////////////////////////////////////'
	HELP_WIDGETS.AddLast( TKeyboardHelpWidget.Create( "C", LocalizeString("{{h_mode_ship_center}}"), ICON_KB, True, 0, "ship" ) )
	HELP_WIDGETS.AddLast( TKeyboardHelpWidget.Create( "S", LocalizeString("{{h_mode_ship_shieldCenter}}"), ICON_KB, True, 0, "ship" ))
	HELP_WIDGETS.AddLast( TKeyboardHelpWidget.Create( "B", LocalizeString("{{h_mode_ship_bounds}}"), ICON_KB, True, 0, "ship" ))
	HELP_WIDGETS.AddLast( TKeyboardHelpWidget.Create( "W", LocalizeString("{{h_mode_ship_weaponSlots}}"), ICON_KB, True, 0, "ship" ) )
	HELP_WIDGETS.AddLast( TKeyboardHelpWidget.Create( "U", LocalizeString("{{h_mode_ship_builtInWeapons}}"), ICON_KB, True, 0, "ship" ) )
	HELP_WIDGETS.AddLast( TKeyboardHelpWidget.Create( "R", LocalizeString("{{h_mode_ship_decorateWeapons}}"), ICON_KB, True, 0, "ship") )	
	HELP_WIDGETS.AddLast( TKeyboardHelpWidget.Create( "H", LocalizeString("{{h_mode_ship_builtInHullmods}}"), ICON_KB, True, 0, "ship" ))
	HELP_WIDGETS.AddLast( TKeyboardHelpWidget.Create( "E", LocalizeString("{{h_mode_ship_engineSlots}}"), ICON_KB, True, 0, "ship" ) )
	HELP_WIDGETS.AddLast( TKeyboardHelpWidget.Create( "L", LocalizeString("{{h_mode_ship_launchBays}}"), ICON_KB, True, 0, "ship" ))
	HELP_WIDGETS.AddLast( TKeyboardHelpWidget.Create( "T", LocalizeString("{{h_mode_ship_shipDetails}}"), ICON_KB, True, 0, "ship" ) )
	HELP_WIDGETS.AddLast( TKeyboardHelpWidget.Create( "P", LocalizeString("{{h_mode_ship_preview}}"), ICON_KB, True, 0, "ship" ) )
	HELP_WIDGETS.AddLast( TKeyboardHelpWidget.Create( "Q", LocalizeString("{{h_function_show_more}}"), ICON_KB, True, 1, "ship" ) )
	'////////////
	HELP_WIDGETS.AddLast( TKeyboardHelpWidget.Create( "", LocalizeString("{{h_function_ship_center_setCenter}}"), ICON_MS_LEFT, True, 0, "ship", "center" ) )
	HELP_WIDGETS.AddLast( TKeyboardHelpWidget.Create( "", LocalizeString("{{h_function_ship_center_setRadius}}"), ICON_CTRL_CLICK, True, 1, "ship", "center" ) )
	'//////////// 
	HELP_WIDGETS.AddLast( TKeyboardHelpWidget.Create( "", LocalizeString("{{h_function_ship_shieldCenter_setCenter}}"), ICON_MS_LEFT, True, 0, "ship", "shield_center" ) )
	HELP_WIDGETS.AddLast( TKeyboardHelpWidget.Create( "", LocalizeString("{{h_function_ship_shieldCenter_setRadius}}"), ICON_CTRL_CLICK, True, 1, "ship", "shield_center" ) )
	'////////////
	HELP_WIDGETS.AddLast( TKeyboardHelpWidget.Create( "", LocalizeString("{{h_function_ship_bounds_add}}"), ICON_SHIFT_CLICK, True, 0, "ship", "bounds" ) )
	HELP_WIDGETS.AddLast( TKeyboardHelpWidget.Create( "", LocalizeString("{{h_function_ship_bounds_insert}}"), ICON_CTRL_CLICK, True, 0, "ship", "bounds" ))
	HELP_WIDGETS.AddLast( TKeyboardHelpWidget.Create( "", LocalizeString("{{h_function_ship_bounds_drag}}"), ICON_MS_LEFT, True, 0, "ship", "bounds" ) )
	HELP_WIDGETS.AddLast( TKeyboardHelpWidget.Create( "", LocalizeString("{{h_function_ship_bounds_dragAll}}"), ICON_CTRL_ALT_RIGHT_CLICK, True, 0, "ship", "bounds" ) )
	HELP_WIDGETS.AddLast( TKeyboardHelpWidget.Create( Chr($2190), LocalizeString("{{h_function_ship_bounds_remove}}"), ICON_KB, True, 0, "ship", "bounds" ))
	HELP_WIDGETS.AddLast( TKeyboardHelpWidget.Create( "", LocalizeString("{{h_global_mirrored}}"), ICON_SPACEBAR, True, 1, "ship", "bounds" ) )
	'////////////
	HELP_WIDGETS.AddLast( TKeyboardHelpWidget.Create( "", LocalizeString("{{h_function_weaponSlots_add}}"), ICON_SHIFT_CLICK, True, 0, "ship", "weapon_slots" ))
	HELP_WIDGETS.AddLast( TKeyboardHelpWidget.Create( "", LocalizeString("{{h_function_weaponSlots_drag}}"), ICON_CTRL_CLICK, True, 0, "ship", "weapon_slots" ) )
	HELP_WIDGETS.AddLast( TKeyboardHelpWidget.Create( "", LocalizeString("{{h_function_weaponSlots_dragAll}}"), ICON_CTRL_ALT_RIGHT_CLICK, True, 0, "ship", "weapon_slots" ) )
	HELP_WIDGETS.AddLast( TKeyboardHelpWidget.Create( "", LocalizeString("{{h_function_weaponSlots_setAngle}}"), ICON_MS_LEFT, True, 0, "ship", "weapon_slots" ) )
	HELP_WIDGETS.AddLast( TKeyboardHelpWidget.Create( "", LocalizeString("{{h_function_weaponSlots_setFacing}}"), ICON_ALT_CLICK, True, 0, "ship", "weapon_slots" ) )
	HELP_WIDGETS.AddLast( TKeyboardHelpWidget.Create( Chr($2190), LocalizeString("{{h_function_weaponSlots_remove}}"), ICON_KB, True, 0, "ship", "weapon_slots" ) )
	HELP_WIDGETS.AddLast( TKeyboardHelpWidget.Create( "", LocalizeString("{{h_global_mirrored}}"), ICON_SPACEBAR, True, 0, "ship", "weapon_slots" ) )
	HELP_WIDGETS.AddLast( TKeyboardHelpWidget.Create( Chr($2190) + Chr($2192), LocalizeString("{{h_animation_frame}}"), 0, True, 0, "ship", "weapon_slots" ) )
	HELP_WIDGETS.AddLast( TKeyboardHelpWidget.Create( Chr($2191) + Chr($2193), LocalizeString("{{h_animation_playStop}}"), 0, True, 1, "ship", "weapon_slots" ) )
	'////////////
	HELP_WIDGETS.AddLast( TKeyboardHelpWidget.Create( "", LocalizeString("{{h_function_builtInWeapons_assign}}"), ICON_MS_LEFT, True, 0, "ship", "built_in_weapons" ) )
	HELP_WIDGETS.AddLast( TKeyboardHelpWidget.Create( Chr($2190), LocalizeString("{{h_function_builtInWeapons_remove}}"), ICON_KB, True, 0, "ship", "built_in_weapons" ) )
	HELP_WIDGETS.AddLast( TKeyboardHelpWidget.Create( Chr($2190) + Chr($2192), LocalizeString("{{h_animation_frame}}"), 0, True, 0, "ship", "built_in_weapons" ) )
	HELP_WIDGETS.AddLast( TKeyboardHelpWidget.Create( Chr($2191) + Chr($2193), LocalizeString("{{h_animation_playStop}}"), 0, True, 1, "ship", "built_in_weapons" ) )
	'////////////
	HELP_WIDGETS.AddLast( TKeyboardHelpWidget.Create( "", LocalizeString("{{h_function_engineSlots_add}}"), ICON_SHIFT_CLICK, True, 0, "ship", "engine_slots" ))
	HELP_WIDGETS.AddLast( TKeyboardHelpWidget.Create( "", LocalizeString("{{h_function_engineSlots_drag}}"), ICON_CTRL_CLICK, True, 0, "ship", "engine_slots" ) )
	HELP_WIDGETS.AddLast( TKeyboardHelpWidget.Create( "", LocalizeString("{{h_function_engineSlots_dragAll}}"), ICON_CTRL_ALT_RIGHT_CLICK, True, 0, "ship", "engine_slots" ))
	HELP_WIDGETS.AddLast( TKeyboardHelpWidget.Create( "", LocalizeString("{{h_function_engineSlots_setFacing}}"), ICON_MS_LEFT, True, 0, "ship", "engine_slots" ))
	HELP_WIDGETS.AddLast( TKeyboardHelpWidget.Create( "", LocalizeString("{{h_function_engineSlots_setSize}}"), ICON_ALT_CLICK, True, 0, "ship", "engine_slots" ))
	HELP_WIDGETS.AddLast( TKeyboardHelpWidget.Create( Chr($2190), LocalizeString("{{h_function_engineSlots_remove}}"), ICON_KB, True, 0, "ship", "engine_slots" ))
	HELP_WIDGETS.AddLast( TKeyboardHelpWidget.Create( "", LocalizeString("{{h_global_mirrored}}"), ICON_SPACEBAR, True, 1, "ship", "engine_slots" ))
	'////////////
	HELP_WIDGETS.AddLast( TKeyboardHelpWidget.Create( "", LocalizeString("{{h_function_launchBays_addPort}}"), ICON_SHIFT_CLICK, True, 0, "ship", "launch_bays" ) )
	HELP_WIDGETS.AddLast( TKeyboardHelpWidget.Create( "", LocalizeString("{{h_function_launchBays_addBay}}"), ICON_CTRL_CLICK, True, 0, "ship", "launch_bays" ) )	
	HELP_WIDGETS.AddLast( TKeyboardHelpWidget.Create( "", LocalizeString("{{h_function_launchBays_drag}}"), ICON_MS_LEFT, True, 0, "ship", "launch_bays" ))
	HELP_WIDGETS.AddLast( TKeyboardHelpWidget.Create( "", LocalizeString("{{h_function_launchBays_dragAll}}"), ICON_CTRL_ALT_RIGHT_CLICK, True, 0, "ship", "launch_bays" ))
	HELP_WIDGETS.AddLast( TKeyboardHelpWidget.Create( Chr($2190), LocalizeString("{{h_function_launchBays_remove}}"), ICON_KB, True, 1, "ship", "launch_bays" ))
	'////////////
	HELP_WIDGETS.AddLast( TKeyboardHelpWidget.Create( "", LocalizeString("{{h_function_variant_assignWeapon}}"), ICON_MS_LEFT, True, 0, "variant" ))
	HELP_WIDGETS.AddLast( TKeyboardHelpWidget.Create( "G", LocalizeString("{{h_function_variant_weaponGroups}}"), ICON_KB, True, 0, "variant" ) )
	HELP_WIDGETS.AddLast( TKeyboardHelpWidget.Create( "A", LocalizeString("{{h_function_variant_autofire}}"), ICON_KB, True, 0, "variant" ) )
	HELP_WIDGETS.AddLast( TKeyboardHelpWidget.Create( "F", LocalizeString("{{h_function_variant_addVents}}"), ICON_KB, True, 0, "variant" ) )
	HELP_WIDGETS.AddLast( TKeyboardHelpWidget.Create( "F", LocalizeString("{{h_function_variant_removeVents}}"), ICON_CTRL_KB, True, 0, "variant" ) )
	HELP_WIDGETS.AddLast( TKeyboardHelpWidget.Create( "C", LocalizeString("{{h_function_variant_addCap}}"), ICON_KB, True, 0, "variant" ))
	HELP_WIDGETS.AddLast( TKeyboardHelpWidget.Create( "C", LocalizeString("{{h_function_variant_removeCap}}"), ICON_CTRL_KB, True, 0, "variant" ) )	
	HELP_WIDGETS.AddLast( TKeyboardHelpWidget.Create( "H", LocalizeString("{{h_function_variant_hullmods}}"), ICON_KB, True, 0, "variant" ) )
	HELP_WIDGETS.AddLast( TKeyboardHelpWidget.Create( "T", LocalizeString("{{h_function_variant_details}}"), ICON_KB, True, 0, "variant" ) )
	HELP_WIDGETS.AddLast( TKeyboardHelpWidget.Create( Chr($2190), LocalizeString("{{h_function_variant_remove}}"), ICON_KB, True, 0, "variant" ))
	HELP_WIDGETS.AddLast( TKeyboardHelpWidget.Create( "/", LocalizeString("{{h_function_variant_removeAll}}"), ICON_KB, True, 0, "variant" ) )
	HELP_WIDGETS.AddLast( TKeyboardHelpWidget.Create( "Q", LocalizeString("{{h_function_show_more}}"), ICON_KB, True, 1, "variant" ) )
	HELP_WIDGETS.AddLast( TKeyboardHelpWidget.Create( Chr($2190) + Chr($2192), LocalizeString("{{h_animation_frame}}"), 0, True, 0, "variant" ) )
	HELP_WIDGETS.AddLast( TKeyboardHelpWidget.Create( Chr($2191) + Chr($2193), LocalizeString("{{h_animation_playStop}}"), 0, True, 1, "variant" ) )
	'////////////
	HELP_WIDGETS.AddLast( TKeyboardHelpWidget.Create( "T", LocalizeString("{{h_function_csvEdit}}"), ICON_KB, True, 1, "csv" ) )
	'////////////
	HELP_WIDGETS.AddLast( TKeyboardHelpWidget.Create( "T", LocalizeString("{{h_function_csvEdit}}"), ICON_KB, True, 1, "csv_wing" ))
	'/////////////////////////////////////////////'
	HELP_WIDGETS.AddLast( TKeyboardHelpWidget.Create( "D", LocalizeString("{{h_file_weapon_load}}"), ICON_KB, True, 0, "weapon" ))
	HELP_WIDGETS.AddLast( TKeyboardHelpWidget.Create( "V", LocalizeString("{{h_file_weapon_save}}"), ICON_KB, True, 0, "weapon" ))
	HELP_WIDGETS.AddLast( TKeyboardHelpWidget.Create( "N", LocalizeString("{{h_file_weapon_new}}"), ICON_CTRL_ALT_KB, True, 1, "weapon" ))
	'////////////
	HELP_WIDGETS.AddLast( TKeyboardHelpWidget.Create( "O", LocalizeString("{{h_function_weapon_offset}}"), ICON_KB, True, 0, "weapon" ) )
	HELP_WIDGETS.AddLast( TKeyboardHelpWidget.Create( "T", LocalizeString("{{h_function_weapon_details}}"), ICON_KB, True, 0, "weapon" ) )
	HELP_WIDGETS.AddLast( TKeyboardHelpWidget.Create( "H", LocalizeString("{{h_function_weapon_weaponMode}}"), ICON_KB, True, 0, "weapon" ) )
	HELP_WIDGETS.AddLast( TKeyboardHelpWidget.Create( "W", LocalizeString("{{h_function_weapon_glow}}"), ICON_KB, True, 1, "weapon" ) )	
	'////////////
	HELP_WIDGETS.AddLast( TKeyboardHelpWidget.Create( "", LocalizeString("{{h_function_weapon_offset_add}}"), ICON_SHIFT_CLICK, True, 0, "weapon", "offsets" ) )
	HELP_WIDGETS.AddLast( TKeyboardHelpWidget.Create( "", LocalizeString("{{h_function_weapon_offset_drag}}"), ICON_MS_LEFT, True, 0, "weapon", "offsets" ) )
	HELP_WIDGETS.AddLast( TKeyboardHelpWidget.Create( "", LocalizeString("{{h_function_weapon_offset_setFacing}}"), ICON_CTRL_CLICK, True, 0, "weapon", "offsets" ))
	HELP_WIDGETS.AddLast( TKeyboardHelpWidget.Create( Chr($2190), LocalizeString("{{h_function_weapon_offset_remove}}"), ICON_KB, True, 0, "weapon", "offsets" ) )
	HELP_WIDGETS.AddLast( TKeyboardHelpWidget.Create( "", LocalizeString("{{h_global_mirrored}}"), ICON_SPACEBAR, True, 1, "weapon", "offsets" ) )
	'////////////
	HELP_WIDGETS.AddLast( TKeyboardHelpWidget.Create( "U", LocalizeString("{{h_file_weapon_loadImage_under}}"), ICON_KB, True, 0, "weapon" ))
	HELP_WIDGETS.AddLast( TKeyboardHelpWidget.Create( "G", LocalizeString("{{h_file_weapon_loadImage_gun}}"), ICON_KB, True, 0, "weapon" ))
	HELP_WIDGETS.AddLast( TKeyboardHelpWidget.Create( "A", LocalizeString("{{h_file_weapon_loadImage_main}}"), ICON_KB, True, 0, "weapon" ))
	HELP_WIDGETS.AddLast( TKeyboardHelpWidget.Create( "L", LocalizeString("{{h_file_weapon_loadImage_glow}}"), ICON_KB, True, 1, "weapon" ) )
	'/////////////////////////////////////////////'
	HELP_WIDGETS.AddLast( TKeyboardHelpWidget.Create( "F1", LocalizeString("{{h_global_help}}"), 0, True, 0 ) )
	HELP_WIDGETS.AddLast( TKeyboardHelpWidget.Create( "F2", LocalizeString("{{h_global_json}}"), 0, True, 0 ) )
	HELP_WIDGETS.AddLast( TKeyboardHelpWidget.Create( "F3", LocalizeString("{{h_global_guides}}"), 0, True, 0 ))
	HELP_WIDGETS.AddLast( TKeyboardHelpWidget.Create( "F5", LocalizeString("{{h_global_weaponDrawer}}"), 0, True, 1 ))
	'////////////
	HELP_WIDGETS.AddLast( TKeyboardHelpWidget.Create( "F6", LocalizeString("{{h_global_animations_play}}"), 0, True, 0 ) )
	HELP_WIDGETS.AddLast( TKeyboardHelpWidget.Create( "F7", LocalizeString("{{h_global_animations_stop}}"), 0, True, 0 ) )
	HELP_WIDGETS.AddLast( TKeyboardHelpWidget.Create( "F8", LocalizeString("{{h_global_animations_reset}}"), 0, True, 0 ) )	
	'/////////////////////////////////////////////'

	'none, center, bounds, collision_radius, engine_slots, shield_center, shield_radius, weapon_slots, preview_all
	CONTEXT_HELP = CreateMap()
	CONTEXT_HELP.Insert( "ship.string_data", "~n" + LocalizeString("{{h_global_esc}}") )

	'anything can append to this and it will be shown each frame
	mouse_str = ""

EndFunction


Function draw_help( ed:TEditor )
	If ed.show_help
		Local help_str$
		help_str = ""
		For Local help:TKeyboardHelpWidget = EachIn HELP_WIDGETS
			If help.program_mode And help.program_mode <> ed.program_mode ..
			Or help.sub_mode And help.sub_mode <> ed.mode Then Continue
			help_str :+ LSet( help.key, 4 ) + help.desc + "~n"
			If help.margin_bottom Then help_str :+ "~n"
		Next
		Local HELP_TEXT:TextWidget = TextWidget.Create( help_str, HELP_LINE_HEIGHT )
		'-------------------------
		'a UI scale add-on
		Local scale# = 1
		If app.scale_help_UI 
			If app.scale_help_UI_scale_level > 0 
				scale = app.scale_help_UI_scale_level
			Else
				scale# = H_MAX / 700
			End If 
		End If 
		SetRotation( 0 )
		SetScale( scale,scale )
		SetAlpha( 1 )
		'text
		draw_string( HELP_TEXT, W_MAX - 7, 10,,, 1.0, 0, HELP_LINE_HEIGHT, False, scale )
		'draw_string( HELP_TEXT, W_MAX, H_MID,,, 1.0, 0.5, HELP_LINE_HEIGHT )
		'icons
		SetScale( scale,scale )		
		Local x% = W_MAX - 7 - HELP_TEXT.w * scale
		'Local y% = H_MID - 0.5*Float(HELP_TEXT.h) * scale 
		Local y% = 10
		For Local help:TKeyboardHelpWidget = EachIn HELP_WIDGETS
			If help.program_mode And help.program_mode <> ed.program_mode ..
			Or help.sub_mode And help.sub_mode <> ed.mode Then Continue
			If help.show_key_as_icon
			SetScale( scale, scale )	
				Local bg_color%
				If help.enabled
					SetColor( 255, 255, 255 )
					bg_color = $FFFFFF
				Else
					SetColor( 64, 64, 64 )
					bg_color = $404040
				End If
				Select help.show_key_as_icon
					Case ICON_KB
						DrawImage( ed.kb_key_image, x - 4, y - 3 )
					Case ICON_MS_LEFT
						DrawImage( ed.mouse_left_image, x - 4, y - 3 )
					Case ICON_MS_RIGHT
						DrawImage( ed.mouse_right_image, x - 4, y - 3 )
					Case ICON_MS_MIDDLE
						DrawImage( ed.mouse_middle_image, x - 4, y - 3 )
					Case ICON_SHIFT_CLICK
						DrawImage( ed.mouse_left_image, x - 4, y - 3 )
						DrawImage( ed.kb_key_wide_image, x - 18 - 18 * scale - 4 - 4, y - 3 )
						SetImageFont( DATA_FONT )
						draw_string( "SHIFT", x-18-18*scale -4,y - 1, $000000,bg_color,,,, True, scale )
						SetImageFont( FONT )
					Case ICON_CTRL_CLICK
						DrawImage( ed.mouse_left_image, x - 4, y - 3 )
						DrawImage( ed.kb_key_wide_image, x-18-18*scale -4 - 4, y - 3 )
						SetImageFont( DATA_FONT )
						draw_string( "CTRL", x-18-18*scale -4,y - 1, $000000,bg_color,,,, True, scale )
						SetImageFont( FONT )
					Case ICON_ALT_CLICK
						DrawImage( ed.mouse_left_image, x - 4, y - 3 )
						DrawImage( ed.kb_key_wide_image, x-18-18*scale -4 - 4, y - 3 )
						SetImageFont( DATA_FONT )
						draw_string( "ALT", x-18-18*scale -4,y - 1, $000000,bg_color,,,, True, scale )
						SetImageFont( FONT )
					Case ICON_SPACEBAR
						DrawImage( ed.kb_key_space_image, x-18 - 4, y - 3 )
					Case ICON_CTRL_ALT_RIGHT_CLICK
						DrawImage( ed.mouse_right_image, x - 4, y - 3 )
						DrawImage( ed.kb_key_wide_image, x-30-30*scale -4 - 4, y - 3 )
						DrawImage( ed.kb_key_wide_image, x-18-18*scale -4 - 4, y - 3 )
						SetImageFont( DATA_FONT )
						draw_string( "CTRL", x-30-30*scale -4,y - 1, $000000,bg_color,,,, True, scale )
						draw_string( "ALT", x-18-18*scale -4,y - 1, $000000,bg_color,,,, True, scale )
						SetImageFont( FONT )
					Case ICON_SHIFT_KB
						DrawImage( ed.kb_key_image, x - 4, y - 3 )
						DrawImage( ed.kb_key_wide_image, x - 18 - 18 * scale - 4 - 4, y - 3 )
						SetImageFont( DATA_FONT )
						draw_string( "SHIFT", x-18-18*scale -4,y - 1, $000000,bg_color,,,, True, scale )
						SetImageFont( FONT )
					Case ICON_CTRL_KB
						DrawImage( ed.kb_key_image, x - 4, y - 3 )
						DrawImage( ed.kb_key_wide_image, x - 18 - 18 * scale - 4 - 4, y - 3 )
						SetImageFont( DATA_FONT )
						draw_string( "CTRL", x - 18 - 18 * scale - 4, y - 1, $000000, bg_color,,,, True, scale )
						SetImageFont( FONT )
					Case ICON_CTRL_ALT_KB
						DrawImage( ed.kb_key_image, x - 4, y - 3 )
						DrawImage( ed.kb_key_wide_image, x-30-30*scale -4 - 4, y - 3 )
						DrawImage( ed.kb_key_wide_image, x-18-18*scale -4 - 4, y - 3 )
						SetImageFont( DATA_FONT )
						draw_string( "CTRL", x-30-30*scale -4,y - 1, $000000,bg_color,,,, True, scale )
						draw_string( "ALT", x-18-18*scale -4,y - 1, $000000,bg_color,,,, True, scale )
						SetImageFont( FONT )
				EndSelect
				draw_string( help.key, x+1, y - 1, $000000,bg_color,,,, True, scale )
				draw_string( help.key, x+1 + 1, y - 1, $000000,bg_color,,,, False, scale )
			End If
			y :+ HELP_LINE_HEIGHT * scale 
			If help.margin_bottom
				y :+ HELP_LINE_HEIGHT * scale 
			End If
		Next
		'contextually specific help
		If CONTEXT_HELP.Contains( ed.program_mode+"."+ed.mode )
			mouse_str :+ String( CONTEXT_HELP.ValueForKey( ed.program_mode+"."+ed.mode )) + "~n"
		End If
		SetScale( 1,1 )
	End If
End Function

