Rem

Starfarer ship data editor
by Trylobot

EndRem

SuperStrict
Framework BRL.GLMax2D
Import BRL.RamStream
Import BRL.PNGLoader
Import BRL.JPGLoader
Import BRL.FreeTypeFont
Import "src/rjson.bmx"
Import "src/console.bmx"
?Win32
Import "assets/sf_icon.o"
?
Incbin "release/sf-ship-ed-settings.json" 'for defaults
Incbin "assets/bg.jpg"
Incbin "assets/kb_key.png"
Incbin "assets/kb_key_wide.png"
Incbin "assets/kb_key_space.png"
Incbin "assets/ms_left.png"
Incbin "assets/ms_mid.png"
Incbin "assets/ms_right.png"
Incbin "assets/consola.ttf"
Incbin "assets/ico_dim.png"
Incbin "assets/ico_pos.png"
Incbin "assets/ico_ang.png"
Incbin "assets/ico_zoom.png"
Incbin "assets/ico_mirr.png"
Incbin "assets/ico_exit.png"

Include "src/functions_misc.bmx"
Include "src/drawing_misc.bmx"
Include "src/TMessageQueueAnim3D.type.bmx"
Include "src/instaquit.bmx"
Include "src/TextWidget.type.bmx"
Include "src/TKeyboardHelpWidget.type.bmx"
Include "src/TStarfarerShip.type.bmx"
Include "src/TStarfarerShipWeapon.type.bmx"
Include "src/TStarfarerCustomEngineStyleSpec.type.bmx"
Include "src/TStarfarerShipEngine.type.bmx"
Include "src/TStarfarerVariant.type.bmx"
Include "src/TStarfarerVariantWeaponGroup.type.bmx"
Include "src/TStarfarerWeapon.type.bmx"
Include "src/TStarfarerWeaponMuzzleFlashSpec.type.bmx"
Include "src/TStarfarerWeaponSmokeSpec.type.bmx"
Include "src/ShipDataCSVFieldTemplate.bmx"
Include "src/WingDataCSVFieldTemplate.bmx"
Include "src/TCSVLoader.type.bmx"
Include "src/TData.type.bmx"
Include "src/TSprite.type.bmx"
Include "src/TEditor.type.bmx"
Include "src/modal_set_center.bmx"
Include "src/modal_set_collision_radius.bmx"
Include "src/modal_set_shield_center.bmx"
Include "src/modal_set_shield_radius.bmx"
Include "src/TSubroutine.type.bmx"
Include "src/TGenericCSVSubroutine.type.bmx"
Include "src/TModalPreviewAll.type.bmx"
Include "src/TModalSetBounds.type.bmx"
Include "src/TModalSetWeaponSlots.type.bmx"
Include "src/TModalSetBuiltInWeapons.type.bmx"
Include "src/TModalSetEngineSlots.type.bmx"
Include "src/TModalSetStringData.type.bmx"
Include "src/TModalLaunchBays.type.bmx"
Include "src/TModalSetVariant.type.bmx"
Include "src/TModalSetShipCSV.type.bmx"
Include "src/TModalSetWingCSV.type.bmx"
Include "src/Application.type.bmx"
Include "src/help.bmx"
Include "src/multiselect_values.bmx"

'/////////////////////////////////////////////
Global DEBUG_LOG_FILE:TStream = WriteStream( "sf-ship-ed.log" )
SetGraphicsDriver GLMax2DDriver()
AppTitle = "Trylobot's STARFARER ship editor"

Global APP:Application = Application.Load()

Global W_MAX# = APP.width, W_MID# = W_MAX/2.0
Global H_MAX# = APP.height,  H_MID# = H_MAX/2.0
Global FONT:TImageFont = Null
Global DATA_FONT:TImageFont = Null
Global LINE_HEIGHT% = APP.font_size + 1
Global DATA_LINE_HEIGHT% = APP.data_font_size

Global ZOOM_LEVELS#[] = [ 0.25, 0.5, 0.75, 1.0, 1.25, 1.5, 2.0, 2.5, 3.0, 3.5, 4.0, 4.5, 5.0, 6.0, 7.0, 8.0, 9.0, 10.0, 15.0, 20.0, 30.0, 40.0, 50.0, 100.0, 200.0 ]
Const ZOOM_SNAP# = 0.001
Const ZOOM_UPDATE_FACTOR# = 0.175 'per frame

'////////////////////////////////////////////////

Const MAX_VARIANT_WEAPON_GROUPS% = 5 
Const ENGINE_MANEUVERING_JETS_CONTRAIL_SIZE% = 128 'hack: makes a custom engine style into a "maneuvering jet"

'////////////////////////////////////////////////

Graphics( W_MAX, H_MAX )

SetClsColor( 0, 0, 0 )
AutoMidHandle( True )
SetBlend( ALPHABLEND )

FONT = LoadImageFont( "incbin::assets/consola.ttf", APP.font_size, SMOOTHFONT )
DATA_FONT = LoadImageFont( "incbin::assets/consola.ttf", APP.data_font_size, SMOOTHFONT )
SetImageFont( FONT )

'display loading message
Cls
draw_string( "Loadin' ...", W_MID, H_MID,,, 0.5, 0.5 )
Flip( 1 )

'////////////////////////////////////////////////
'json
json.error_level = 1
json.formatted = True
json.empty_container_as_null = False
json.precision = 6
'TStarfarerShipWeapon
json.add_transform( "parse_ship",     "$weaponSlots:array/:object/$type:string", json.XJ_RENAME, "type_" )
json.add_transform( "stringify_ship", "$weaponSlots:array/:object/$type_:string", json.XJ_RENAME, "type"  )
json.add_transform( "stringify_ship", "$weaponSlots:array/:object/$position:array", json.XJ_DELETE,, predicate_omit_position )
json.add_transform( "stringify_ship", "$builtInWeapons:object", json.XJ_DELETE,, predicate_omit_builtInWeapons )
'TStarfarerCustomEngineStyleSpec
json.add_transform( "parse_ship",     "$engineSlots:array/:object/$styleSpec:object/$type:string", json.XJ_RENAME, "type_" )
json.add_transform( "stringify_ship", "$engineSlots:array/:object/$styleSpec:object/$type_:string", json.XJ_RENAME, "type"  )
json.add_transform( "stringify_ship", "$engineSlots:array/:object/$styleSpec:object", json.XJ_DELETE,, predicate_omit_styleSpec )
json.add_transform( "stringify_ship", "$engineSlots:array/:object/$styleId:string", json.XJ_DELETE,, predicate_omit_styleId )
'TStarfarerWeapon
json.add_transform( "parse_weapon",     "$type:string", json.XJ_RENAME, "type_" )
json.add_transform( "stringify_weapon", "$type_:string", json.XJ_RENAME, "type"  )

'////////////////////////////////////////////////

Local ed:TEditor = New TEditor
ed.show_help = True

Local sprite:TSprite = New TSprite
sprite.scale = ZOOM_LEVELS[ed.selected_zoom_level]
ed.target_sprite_scale = sprite.scale

Local data:TData = New TData
data.update()
data.update_variant()

'////////////////////////////////////////////////

load_help()

'////////////////////////////////////////////////

'modifier keys
Global SHIFT% = False
Global CONTROL% = False
Global ALT% = False


Global TEXT_W:TextWidget = TextWidget.Create( "W" )
Global TEXT_E:TextWidget = TextWidget.Create( "E" )
Global TEXT_L:TextWidget = TextWidget.Create( "L" )

'////////////////////////////////////////////////

load_ui( ed )

'////////////////////////////////////////////////

load_known_multiselect_values( ed )
'go load the rest of it if able
For Local j% = 0 Until STARFARER_CORE_DIR.length
	If 0 <> FileType( APP.starfarer_base_dir+STARFARER_CORE_DIR[j] )
		DebugLogFile( " Loading STARFARER-CORE Data (Vanilla)" )
		load_stock_data( ed, data, APP.starfarer_base_dir+STARFARER_CORE_DIR[j]+"/", TRUE )
		Exit
	EndIf
Next
If APP.mod_dirs And APP.mod_dirs.length > 0
	For Local mod_dir$ = EachIn APP.mod_dirs
		DebugLogFile " Loading MOD Data: "+mod_dir
		load_stock_data( ed, data, mod_dir )
	Next
EndIf
Rem 'for initial data mining
For Local set$ = EachIn ed.multiselect_values.Keys()
	For Local val$ = EachIn TMap(ed.multiselect_values.ValueForKey(set)).Keys()
		DebugLogFile( "~q"+set+"~q, ~q"+val+"~q")
	Next
Next
End
EndRem

'////////////////////////////////////////////////

Global sub_preview_all:TModalPreviewAll = New TModalPreviewAll
Global sub_set_bounds:TModalSetBounds = New TModalSetBounds
Global sub_set_weapon_slots:TModalSetWeaponSlots = New TModalSetWeaponSlots
Global sub_set_built_in_weapons:TModalSetBuiltInWeapons = New TModalSetBuiltInWeapons
Global sub_set_engine_slots:TModalSetEngineSlots = New TModalSetEngineSlots
Global sub_string_data:TModalSetStringData = New TModalSetStringData
Global sub_launchbays:TModalLaunchBays = New TModalLaunchBays
Global sub_set_variant:TModalSetVariant = New TModalSetVariant
Global sub_ship_csv:TModalSetShipCSV = New TModalSetShipCSV
Global sub_wing_csv:TModalSetWingCSV = New TModalSetWingCSV

'//////////////////////////////////////////////////////////////////////////////
'//////////////////////////////////////////////////////////////////////////////
'///////   MAIN   /////////////////////////////////////////////////////////////
'//////////////////////////////////////////////////////////////////////////////
'//////////////////////////////////////////////////////////////////////////////

Repeat
	'display string for mouse (usually context-help)
	mouse_str = ""
	'modifier key states, used globally
	SHIFT = (KeyDown( KEY_LSHIFT ) Or KeyDown( KEY_RSHIFT ))
	CONTROL = (KeyDown( KEY_LCONTROL ) Or KeyDown( KEY_RCONTROL ))
	ALT = (KeyDown( KEY_LALT ) Or KeyDown( KEY_RALT ))
	
	'update
	If ed.mode = "string_data"
		sub_string_data.Update( ed, data, sprite )
	ElseIf ed.program_mode = "csv" And sub_ship_csv.csv_row_values
		sub_ship_csv.Update( ed, data, sprite )
	ElseIf ed.program_mode = "csv_wing" And sub_wing_csv.csv_row_values
		sub_wing_csv.Update( ed, data, sprite )
	Else
		'these functions conflict with string editing
		check_mode( ed, data, sprite )
		check_open_ship_image( ed, data, sprite )
		check_new_ship_data( ed, data, sprite )
		check_open_ship_data( ed, data, sprite )
		check_save_ship_data( ed, data, sprite )
		check_load_mod( ed, data )
		escape_key_update()
	EndIf
	update_zoom( ed, data, sprite, True )
	update_flags( ed )
	update_pan( ed, sprite )
	sprite.update()
	Select ed.program_mode
		Case "ship"
			Select ed.mode
				Case "center"
					modal_update_set_center( ed, data, sprite )
				Case "bounds"
					sub_set_bounds.Update( ed, data, sprite )
				Case "collision_radius"
					modal_update_set_collision_radius( ed, data, sprite )
				Case "shield_center"
					modal_update_set_shield_center( ed, data, sprite )
				Case "shield_radius"
					modal_update_set_shield_radius( ed, data, sprite )
				Case "weapon_slots"
					sub_set_weapon_slots.Update( ed, data, sprite )
				Case "built_in_weapons"
					sub_set_built_in_weapons.Update( ed, data, sprite )
				Case "engine_slots"
					sub_set_engine_slots.Update( ed, data, sprite )
				Case "launch_bays"
					sub_launchbays.Update( ed, data, sprite )
				Case "string_data"
					'performed above, instead of any other keyboard updates
				Case "preview_all"
					sub_preview_all.Update( ed, data, sprite )
			End Select
		
		Case "variant"
			Select ed.mode
				Case "normal"
					sub_set_variant.Update( ed, data, sprite )
				Case "string_data"
					'performed above, instead of any other keyboard updates
			EndSelect
		
		Case "csv"
			sub_ship_csv.Update( ed, data, sprite )

		Case "csv_wing"
			sub_wing_csv.Update( ed, data, sprite )

	End Select

	'draw
	draw_bg( ed )
	draw_ship( ed, sprite )
	Select ed.program_mode
		Case "ship"
			Select ed.mode
				Case "center"
					modal_draw_set_center( data, sprite )
				Case "bounds"
					sub_set_bounds.Draw( ed, data, sprite )
				Case "collision_radius"
					modal_draw_set_collision_radius( data, sprite )
				Case "shield_center"
					modal_draw_set_shield_center( data, sprite )
				Case "shield_radius"
					modal_draw_set_shield_radius( data, sprite )
				Case "weapon_slots"
					sub_set_weapon_slots.Draw( ed, data, sprite )
				Case "built_in_weapons"
					sub_set_built_in_weapons.Draw( ed, data, sprite )
				Case "engine_slots"
					sub_set_engine_slots.Draw( ed, data, sprite )
				Case "launch_bays"
					sub_launchbays.Draw( ed, data, sprite )
				Case "string_data"
					'performed below, after nearly every other mode
				Case "preview_all"
					sub_preview_all.Draw( ed, data, sprite )
			End Select
		
		Case "variant"
			Select ed.mode
				Case "normal"
					sub_set_variant.Draw( ed, data, sprite )
				Case "string_data"
					'performed below, after nearly every other mode
			EndSelect
		
		Case "csv"
			sub_ship_csv.Draw( ed, data, sprite )

		Case "csv_wing"
			sub_wing_csv.Draw( ed, data, sprite )
			
	End Select
	draw_help( ed )
	draw_data( ed, data )
	draw_status( ed, data, sprite )
	draw_mouse_str()
	draw_debug( ed, sprite )

	If ed.mode = "string_data"
		sub_string_data.Draw( ed, data, sprite )
	End If

	draw_instaquit_progress( W_MAX, H_MAX ) 
	
	Flip( 1 )

Until AppTerminate() Or FLAG_instaquit_plz
If DEBUG_LOG_FILE
	CloseStream( DEBUG_LOG_FILE )
EndIf
End

'////////////////////////////////////////////////

Function check_mode( ed:TEditor, data:TData, sprite:TSprite )
	If KeyHit( KEY_1 )
		'if coming from variant editing, go right into weapons mode editing
		If ed.program_mode = "variant"
			ed.mode = "weapon_slots"
		Else
			ed.mode = "preview_all"
		EndIf
		ed.last_mode = "preview_all"
		ed.program_mode = "ship"
		ed.weapon_lock_i = -1
		ed.field_i = 0
	EndIf
	If KeyHit( KEY_2 )
		sub_set_variant.Activate( ed, data, sprite )
	EndIf
	If KeyHit( KEY_3 )
		ed.program_mode = "csv"
		sub_ship_csv.Activate( ed, data, sprite )
	EndIf
	If KeyHit( KEY_4 )
		ed.program_mode = "csv_wing"
		sub_wing_csv.Activate( ed, data, sprite )
	EndIf

	If KeyHit( KEY_SPACE )
		ed.bounds_symmetrical = Not ed.bounds_symmetrical
	EndIf

	If ed.program_mode = "ship"
		'If not selecting a weapon for a built-in slot, check ESCAPE key
		If Not( ed.mode = "built_in_weapons" And ed.weapon_lock_i <> -1 ) ..
		And (KeyHit( KEY_ESCAPE ) Or KeyHit( KEY_HOME ))
			ed.last_mode = ed.mode
			ed.mode = "none"
			ed.field_i = 0
		EndIf
		If KeyHit( KEY_C )
			ed.last_mode = ed.mode
			ed.mode = "center"
			ed.field_i = 0
		EndIf
		If KeyHit( KEY_B )
			sub_set_bounds.Activate( ed, data, sprite )
		EndIf
		If KeyHit( KEY_E )
			sub_set_engine_slots.Activate( ed, data, sprite )
		EndIf
		If KeyHit( KEY_S )
			ed.last_mode = ed.mode
			ed.mode = "shield_center"
			ed.field_i = 0
		EndIf
		If KeyHit( KEY_W )
			sub_set_weapon_slots.Activate( ed, data, sprite )
		EndIf
		If KeyHit( KEY_U )
			sub_set_built_in_weapons.Activate( ed, data, sprite )
		EndIf
		If KeyHit( KEY_L )
			sub_launchbays.Activate( ed, data, sprite )
		EndIf
		If KeyHit( KEY_P )
			sub_preview_all.Activate( ed, data, sprite )
		End If

	ElseIf ed.program_mode = "variant"
		If KeyHit( KEY_SLASH )
			load_variant_data( ed, data, sprite, TRUE )
		EndIf
	EndIf

	'STRING data editor, context-sensitive (has sub-object target)
	'TODO: move this to TSubroutines
	If ed.program_mode = "ship" ..
	Or ed.program_mode = "variant"
		If KeyHit( KEY_T )
			ed.last_mode = ed.mode
			ed.mode = "string_data"
			FlushKeys()
			ed.edit_strings_weapon_i = -1
			ed.edit_strings_engine_i = -1
			If sprite
				Local img_x#, img_y#
				sprite.get_img_xy( MouseX(), MouseY(), img_x, img_y )
				'context-sensitive editing
				If ed.last_mode = "weapon_slots"
					ed.edit_strings_weapon_i = data.find_nearest_weapon_slot( img_x, img_y )
				ElseIf ed.last_mode = "engine_slots"
					ed.edit_strings_engine_i = data.find_nearest_engine( img_x, img_y )
				EndIf
			EndIf
			sub_string_data.Activate( ed, data, sprite )
		EndIf
	EndIf
End Function

'-----------------------

Function update_flags( ed:TEditor )
	If KeyHit( KEY_F1 ) Then ed.show_help = Not ed.show_help
	If KeyHit( KEY_F2 ) Then ed.show_data = Not ed.show_data
	If KeyHit( KEY_F3 ) Then ed.show_debug = Not ed.show_debug
End Function

Function update_zoom( ed:TEditor, data:TData, sprite:TSprite, ignore_kb%=False )
	Local z_delta% = 0
	If MouseZ() <> ed.mouse_z
		z_delta = MouseZ() - ed.mouse_z
		ed.mouse_z = MouseZ()
	Else
		If Not ignore_kb
			If KeyHit( KEY_MINUS ) Then z_delta :- 1
			If KeyHit( KEY_NUMSUBTRACT ) Then z_delta :- 1
			If KeyHit( KEY_EQUALS ) Then z_delta :+ 1
			If KeyHit( KEY_NUMADD ) Then z_delta :+ 1
		EndIf
	EndIf
	If z_delta <> 0
		Local img_x#, img_y#
		sprite.get_img_xy( MouseX(), MouseY(), img_x, img_y )
		'modify zoom
		If z_delta > 0 'ZOOMING IN
			ed.selected_zoom_level :+ 1
			If ed.selected_zoom_level >= ZOOM_LEVELS.length
				ed.selected_zoom_level = ZOOM_LEVELS.length - 1
			End If
		Else 'z_delta < 0  'ZOOMING OUT
			ed.selected_zoom_level :- 1
			If ed.selected_zoom_level < 0
				ed.selected_zoom_level = 0
			End If
		End If
		'sprite.scale = ZOOM_LEVELS[ed.selected_zoom_level]
		ed.target_sprite_scale = ZOOM_LEVELS[ed.selected_zoom_level]
		'''zoom to cursor (FAILED ATTEMPT #7 : CLOSER THAN EVER)
		'If data.ship And data.ship.center
		'	Local ship_c_x%, ship_c_y%
		'	sprite.xform_ship_c_to_scr( data.ship.center, ship_c_x, ship_c_y )
		'	'''sprite.zpan_x :+ MouseX() - ship_c_x
		'	'''sprite.zpan_y :+ MouseY() - ship_c_y
		'	ed.target_zpan_x :- MouseX() - ship_c_x
		'	ed.target_zpan_y :- MouseY() - ship_c_y
		'EndIf
	End If
	If Abs(ed.target_sprite_scale - sprite.scale) < ZOOM_SNAP
		sprite.scale = ed.target_sprite_scale
		'sprite.zpan_x = ed.target_zpan_x
		'sprite.zpan_y = ed.target_zpan_y
	Else
		sprite.scale :+ ZOOM_UPDATE_FACTOR*(ed.target_sprite_scale - sprite.scale)
		'sprite.zpan_x :+ ZOOM_UPDATE_FACTOR*(ed.target_zpan_x - sprite.zpan_x)
		'sprite.zpan_y :+ ZOOM_UPDATE_FACTOR*(ed.target_zpan_y - sprite.zpan_y)
	EndIf
	''trap sprite in viewable area
	'If sprite.sx + sprite.sw < 0
	'	sprite.zpan_x :- (sprite.sx + sprite.sw)
	'EndIf
End Function

Function update_pan( ed:TEditor, sprite:TSprite )
	If CONTROL And ALT ..
		Then Return
	If ed.mouse_2 'dragging
		sprite.pan_x = ed.pan_start_x + (MouseX() - ed.pan_start_mouse_x)
		sprite.pan_y = ed.pan_start_y + (MouseY() - ed.pan_start_mouse_y)
	End If
	If MouseDown( 2 )
		If Not ed.mouse_2 'drag start
			ed.pan_start_x = sprite.pan_x
			ed.pan_start_y = sprite.pan_y
			ed.pan_start_mouse_x = MouseX()
			ed.pan_start_mouse_y = MouseY()
		End If
		ed.mouse_2 = True
	Else
		ed.mouse_2 = False
	End If
End Function

'-----------------------

Function draw_bg( ed:TEditor )
	If ed.bg_image
		SetRotation( 0 )
		SetScale( ed.bg_scale, ed.bg_scale )
		SetAlpha( 1 )
		SetColor( 255, 255, 255 )
		DrawImage( ed.bg_image, W_MID, H_MID )
	Else
		Cls()
	End If
End Function

Function draw_ship( ed:TEditor, sprite:TSprite )
	If ed.program_mode = "csv_wing" ..
	And sub_wing_csv.hide_main_ship
		Return
	EndIf
	'///
	If sprite.img
		SetRotation( 90 )
		SetScale( sprite.scale, sprite.scale )
		SetAlpha( 1 )
		SetColor( 255, 255, 255 )
		If ed.mode = "weapon_slots" ..
		Or ed.mode = "built_in_weapons" ..
		Or ed.mode = "launch_bays" ..
		Or ed.mode = "string_data" ..
		Or ed.program_mode = "variant" ..
		Or ed.program_mode = "csv" ..
		Or ed.program_mode = "csv_wing"
			SetColor( 127, 127, 127 )
		EndIf
		DrawImage( sprite.img, W_MID + sprite.pan_x + sprite.zpan_x, H_MID + sprite.pan_y + sprite.zpan_y )
	End If
End Function

Function draw_help( ed:TEditor )
	If ed.show_help
		Local help_str$
		help_str = ""
		For Local help:TKeyboardHelpWidget = EachIn HELP_WIDGETS
			If  help.program_mode And help.program_mode <> ed.program_mode ..
			Or  help.sub_mode     And help.sub_mode <> ed.mode Then Continue
			help_str :+ LSet( help.key, 4 ) + help.desc + "~n"
			If help.margin_bottom Then help_str :+ "~n"
		Next
		Local HELP_TEXT:TextWidget = TextWidget.Create( help_str, HELP_LINE_HEIGHT )
		'-------------------------
		SetRotation( 0 )
		SetScale( 1, 1 )
		SetAlpha( 1 )
		'text
		draw_string( HELP_TEXT, W_MAX, H_MID,,, 1.0, 0.5, HELP_LINE_HEIGHT )
		'icons
		Local x% = W_MAX - HELP_TEXT.w
		Local y% = H_MID - 0.5*Float(HELP_TEXT.h)
		For Local help:TKeyboardHelpWidget = EachIn HELP_WIDGETS
			If  help.program_mode And help.program_mode <> ed.program_mode ..
			Or  help.sub_mode     And help.sub_mode <> ed.mode Then Continue
			If help.show_key_as_icon
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
						DrawImage( ed.kb_key_wide_image, x-18-18-4 - 4, y - 3 )
						SetImageFont( DATA_FONT )
						draw_string( "SHIFT", x-18-18-4,y - 1, $000000,bg_color,,,, True )
						SetImageFont( FONT )
					Case ICON_CTRL_CLICK
						DrawImage( ed.mouse_left_image, x - 4, y - 3 )
						DrawImage( ed.kb_key_wide_image, x-18-18-4 - 4, y - 3 )
						SetImageFont( DATA_FONT )
						draw_string( "CTRL", x-18-18-4,y - 1, $000000,bg_color,,,, True )
						SetImageFont( FONT )
					Case ICON_ALT_CLICK
						DrawImage( ed.mouse_left_image, x - 4, y - 3 )
						DrawImage( ed.kb_key_wide_image, x-18-18-4 - 4, y - 3 )
						SetImageFont( DATA_FONT )
						draw_string( "ALT", x-18-18-4,y - 1, $000000,bg_color,,,, True )
						SetImageFont( FONT )
					Case ICON_SPACEBAR
						DrawImage( ed.kb_key_space_image, x-18 - 4, y - 3 )
					Case ICON_CTRL_ALT_RIGHT_CLICK
						DrawImage( ed.mouse_right_image, x - 4, y - 3 )
						DrawImage( ed.kb_key_wide_image, x-30-30-4 - 4, y - 3 )
						DrawImage( ed.kb_key_wide_image, x-18-18-4 - 4, y - 3 )
						SetImageFont( DATA_FONT )
						draw_string( "CTRL", x-30-30-4,y - 1, $000000,bg_color,,,, True )
						draw_string( "ALT",  x-18-18-4,y - 1, $000000,bg_color,,,, True )
						SetImageFont( FONT )
					Case ICON_CTRL_ALT_KB
						DrawImage( ed.kb_key_image, x - 4, y - 3 )
						DrawImage( ed.kb_key_wide_image, x-30-30-4 - 4, y - 3 )
						DrawImage( ed.kb_key_wide_image, x-18-18-4 - 4, y - 3 )
						SetImageFont( DATA_FONT )
						draw_string( "CTRL", x-30-30-4,y - 1, $000000,bg_color,,,, True )
						draw_string( "ALT",  x-18-18-4,y - 1, $000000,bg_color,,,, True )
						SetImageFont( FONT )
				EndSelect
				draw_string( help.key, x+1,     y - 1, $000000,bg_color,,,, True )
				draw_string( help.key, x+1 + 1, y - 1, $000000,bg_color,,,, False )
			End If
			y :+ HELP_LINE_HEIGHT
			If help.margin_bottom
				y :+ HELP_LINE_HEIGHT
			End If
		Next
		'contextually specific help
		If CONTEXT_HELP.Contains( ed.program_mode+"."+ed.mode )
			mouse_str :+ String( CONTEXT_HELP.ValueForKey( ed.program_mode+"."+ed.mode )) + "~n"
		End If
	End If
End Function

Function draw_data( ed:TEditor, data:TData )
	If ed.show_data
		Local view:TList
		If ed.program_mode = "ship"
			view = data.json_view
		ElseIf ed.program_mode = "variant"
			view = data.json_view_variant
		Else
			Return
		EndIf
		SetRotation( 0 )
		SetScale( 1, 1 )
		SetImageFont( DATA_FONT )
		Local x% = 0
		Local y% = 0
		If view
			For Local widget:TextWidget = EachIn view
				'bg
				SetAlpha( 0.50 )
				SetColor( 0, 0, 0 )
				DrawRect( x, y, widget.w, widget.h )
				'text
				SetAlpha( 1 )
				draw_string( widget, x, y,,,,, DATA_LINE_HEIGHT, False )
				x :+ widget.w
			Next
		EndIf
		SetImageFont( FONT )
	End If
End Function

Function draw_debug( ed:TEditor, sprite:TSprite )
	If ed.show_debug And sprite
		Local img_x#, img_y#
		sprite.get_img_xy( MouseX(), MouseY(), img_x, img_y, False )
		Local col% = Int(img_x)
		Local row% = Int(img_y)
		'draw row, col indicators
		SetRotation( 0 )
		SetScale( 1, 1 )
		SetColor( 255, 255, 255 )
		If col >= 0 And col < sprite.img.height And row >= 0 And row < sprite.img.width
			SetAlpha( 0.25 )
			If col > 0 Then DrawRect( sprite.sx, sprite.sy + Float(row)*sprite.scale, Float(col)*sprite.scale, sprite.scale )
			If col < sprite.img.height - 1 Then DrawRect( sprite.sx + Float(col + 1)*sprite.scale, sprite.sy + Float(row)*sprite.scale, Float(sprite.img.height - 1 - col)*sprite.scale, sprite.scale )
			If row > 0 Then DrawRect( sprite.sx + Float(col)*sprite.scale, sprite.sy, sprite.scale, Float(row)*sprite.scale )
			If row < sprite.img.width - 1 Then DrawRect( sprite.sx + Float(col)*sprite.scale, sprite.sy + Float(row + 1)*sprite.scale, sprite.scale, Float(sprite.img.width - 1 - row)*sprite.scale )
			SetAlpha( 1 )
			SetColor( 0, 0, 0 )
			DrawRectLines( sprite.sx - 2 + Float(col)*sprite.scale, sprite.sy - 2 + Float(row)*sprite.scale, sprite.scale + 4, sprite.scale + 4, 3 )
			SetColor( 255, 255, 255 )
			DrawRectLines( sprite.sx - 1 + Float(col)*sprite.scale, sprite.sy - 1 + Float(row)*sprite.scale, sprite.scale + 2, sprite.scale + 2, 1 )
		End If
		'draw bounding rectangle
		SetColor( 0, 0, 0 )
		DrawRectLines( sprite.sx-1, sprite.sy-1, sprite.sw+2, sprite.sh+2, 3 )
		SetColor( 255, 255, 255 )
		DrawRectLines( sprite.sx, sprite.sy, sprite.sw, sprite.sh )
	End If
End Function

Function draw_mouse_str()
	draw_string( mouse_str, MouseX() + 13, MouseY() + 3 )
End Function

Function draw_status( ed:TEditor, data:TData, sprite:TSprite )
	If Not sprite.img Then Return
	'prepare information
	SetColor( 255, 255, 255 )
	SetScale( 1, 1 )
	SetRotation( 0 )
	SetAlpha( 1 )
	Local img_x#, img_y#
	sprite.get_img_xy( MouseX(), MouseY(), img_x, img_y )
	Local ang_relevant% = False
	Local ico_w% = 18
	Local ico_h% = 18
	Local w$ = ""+sprite.img.width
	Local h$ = ""+sprite.img.height
	Local x$ = json.FormatDouble( img_x - data.ship.center[1], 1 )
	Local y$ = json.FormatDouble( -( img_y - data.ship.center[0] ), 1 )
	Local a$ = json.FormatDouble( 0, 1 )
	Local z$ = Int(100.0*sprite.scale)
	Local m% = ed.bounds_symmetrical
	If  ed.program_mode = "ship" ..
	And ed.mode = "weapon_slots" 
		Local ni% = data.find_nearest_weapon_slot( img_x, img_y )
		If ed.weapon_lock_i <> -1 Then ni = ed.weapon_lock_i
		If ni <> -1
			Local weapon:TStarfarerShipWeapon = data.ship.weaponSlots[ni]
			ang_relevant = True
			a = json.FormatDouble( calc_angle( weapon.locations[0], weapon.locations[1], img_x - data.ship.center[1], -( img_y - data.ship.center[0] )), 1 )
		EndIf
	ElseIf ed.program_mode = "ship" ..
	And    ed.mode = "engine_slots" 
		Local ni% = data.find_nearest_engine( img_x, img_y )
		If ed.engine_lock_i <> -1 Then ni = ed.engine_lock_i
		If ni <> -1
			Local engine:TStarfarerShipEngine = data.ship.engineSlots[ni]
			ang_relevant = True
			a = json.FormatDouble( calc_angle( engine.location[0], engine.location[1], img_x - data.ship.center[1], -( img_y - data.ship.center[0] )), 1 )
		EndIf
	EndIf
	'  From Right to Left along bottom:
	Local dim_w:TextWidget =  TextWidget.Create( w+" x "+h )
	Local pos_w:TextWidget =  TextWidget.Create( x+","+y)
	Local ang_w:TextWidget =  TextWidget.Create( a+Chr($00B0)) 'degree symbol
	Local zoom_w:TextWidget = TextWidget.Create( z+"%" )
	Local mirr_w:TextWidget
	If m
		mirr_w =                TextWidget.Create( "Mirror" )
	Else
		mirr_w =                TextWidget.Create( "Normal" )
	EndIf
	'dimensions
	DrawImage( ed.ico_dim,  Int(0.0*Float(W_MAX)/5.0)+20,        H_MAX - ico_h - 4 )
	draw_string( dim_w,     Int(0.0*Float(W_MAX)/5.0)+20+ico_w+4,H_MAX - LINE_HEIGHT - 4 )
	'position 
	DrawImage( ed.ico_pos,  Int(1.2*Float(W_MAX)/5.0)+20,        H_MAX - ico_h - 4 )
	draw_string( pos_w,     Int(1.2*Float(W_MAX)/5.0)+20+ico_w+4,H_MAX - LINE_HEIGHT - 4 )
	'angle 
	If ang_relevant Then SetAlpha( 1.00 ) Else SetAlpha( 0.333 )
	DrawImage( ed.ico_ang,  Int(2.4*Float(W_MAX)/5.0)+20,        H_MAX - ico_h - 4 )
	draw_string( ang_w,     Int(2.4*Float(W_MAX)/5.0)+20+ico_w+4,H_MAX - LINE_HEIGHT - 4 )
	SetAlpha( 1 )
	'zoom
	DrawImage( ed.ico_zoom, Int(3.3*Float(W_MAX)/5.0)+20,        H_MAX - ico_h - 4 )
	draw_string( zoom_w,    Int(3.3*Float(W_MAX)/5.0)+20+ico_w+4,H_MAX - LINE_HEIGHT - 4 )
	'mirrored
	If m Then SetAlpha( 1.00 ) Else SetAlpha( 0.333 )
	DrawImage( ed.ico_mirr, Int(4.2*Float(W_MAX)/5.0)+20,        H_MAX - ico_h - 4 )
	draw_string( mirr_w,    Int(4.2*Float(W_MAX)/5.0)+20+ico_w+4,H_MAX - LINE_HEIGHT - 4 )
	SetAlpha( 1 )
	'if not showing the json data (which would be obscured):
	If Not ed.show_data
		'  From Left to Right along top:
		Local title_w:TextWidget
		Select ed.program_mode
			Case "ship"
				title_w = TextWidget.Create( data.ship.hullId + ".ship" )
			Case "variant"
				title_w = TextWidget.Create( data.variant.variantId + ".variant" )
			Case "csv"
				If data.csv_row
					title_w = TextWidget.Create( "ship_data.csv : " + String( data.csv_row.ValueForKey( "id" )))
				Else
					title_w = TextWidget.Create( "ship_data.csv" )
				EndIf
			Case "csv_wing"
				If data.csv_row
					title_w = TextWidget.Create( "wing_data.csv : " + String( data.csv_row_wing.ValueForKey( "id" )))
				Else
					title_w = TextWidget.Create( "wing_data.csv" )
				EndIf
		EndSelect
		draw_string( title_w, 4,4 )
	EndIf
Endfunction

'-----------------------

Function check_open_ship_image( ed:TEditor, data:TData, sprite:TSprite )
	If KeyHit( KEY_I )
		load_ship_image( ed, data, sprite )
	End If
End Function

Function check_load_mod( ed:TEditor, data:TData )
	If KeyHit( KEY_M )
		load_mod( ed, data )
	EndIF
EndFunction

Function check_new_ship_data( ed:TEditor, data:TData, sprite:TSprite )
	If KeyHit( KEY_N ) And CONTROL And ALT
		load_ship_data( ed, data, sprite, True )
	End If
End Function

Function check_open_ship_data( ed:TEditor, data:TData, sprite:TSprite )
	If KeyHit( KEY_D )
		Select ed.program_mode
			Case "ship"
				load_ship_data( ed, data, sprite )
			Case "variant"
				load_variant_data( ed, data, sprite )
			Case "csv"
				sub_ship_csv.Load( ed, data, sprite )
			Case "csv_wing"
				sub_wing_csv.Load( ed, data, sprite )
		EndSelect
	End If
End Function

Function check_save_ship_data( ed:TEditor, data:TData, sprite:TSprite )
	If KeyHit( KEY_V )
		Select ed.program_mode
			Case "ship"
				Local data_path$ = RequestFile( "SAVE Ship Data", "ship", True, APP.data_dir+data.ship.hullID+".ship" )
				FlushKeys()
				If data_path
					APP.data_dir = ExtractDir( data_path )+"/"
					APP.save()
					SaveString( data.json_str, data_path )
				End If
			Case "variant"
				Local variant_path$ = RequestFile( "SAVE Variant Data", "variant", True, APP.variant_dir+data.variant.variantID+".variant" )
				FlushKeys()
				If variant_path
					APP.variant_dir = ExtractDir( variant_path )+"/"
					APP.save()
					SaveString( data.json_str_variant, variant_path )
				End If
			Case "csv"	
				sub_ship_csv.Save( ed, data, sprite )
			Case "csv_wing"	
				sub_wing_csv.Save( ed, data, sprite )
		EndSelect
	End If
End Function


'-----------------------

Function load_ui( ed:TEditor )
	AutoMidHandle( true )
	ed.bg_image = LoadImage( "incbin::assets/bg.jpg", FILTEREDIMAGE|MIPMAPPEDIMAGE )
	ed.bg_scale = Max( W_MAX/Float(ed.bg_image.width), H_MAX/Float(ed.bg_image.height) )
	AutoMidHandle( false )
	ed.kb_key_image = LoadImage( "incbin::assets/kb_key.png", 0 )
	ed.kb_key_wide_image = LoadImage( "incbin::assets/kb_key_wide.png", 0 )
	ed.kb_key_space_image = LoadImage( "incbin::assets/kb_key_space.png", 0 )
	ed.mouse_left_image = LoadImage( "incbin::assets/ms_left.png", 0 )
	ed.mouse_right_image = LoadImage( "incbin::assets/ms_right.png", 0 )
	ed.mouse_middle_image = LoadImage( "incbin::assets/ms_mid.png", 0 )
	ed.ico_dim = LoadImage( "incbin::assets/ico_dim.png", 0 )
	ed.ico_pos = LoadImage( "incbin::assets/ico_pos.png", 0 )
	ed.ico_ang = LoadImage( "incbin::assets/ico_ang.png", 0 )
	ed.ico_zoom = LoadImage( "incbin::assets/ico_zoom.png", 0 )
	ed.ico_mirr = LoadImage( "incbin::assets/ico_mirr.png", 0 )
	ed.ico_exit = LoadImage( "incbin::assets/ico_exit.png", 0 )
	AutoMidHandle( true )
End Function

'data_dir$ should be either "starfarer-core/" or "mods/{ModDirectory}/"
Function load_stock_data( ed:TEditor, data:TData, data_dir$, vanilla%=FALSE )
	Local stock_ships_dir$ =    data_dir+"data/hulls/"
	Local stock_variants_dir$ = data_dir+"data/variants/"
	Local stock_variants_fighters_dir$ = data_dir+"data/variants/fighters/"
	Local stock_variants_drones_dir$ = data_dir+"data/variants/drones/"
	Local stock_weapons_dir$ =  data_dir+"data/weapons/"
	Local stock_hullmods_dir$ = data_dir+"data/hullmods/"
	Local stock_config_dir$ =   data_dir+"data/config/"
	'/////
	Local stock_ships_files$[] = LoadDir( stock_ships_dir )
	For Local stock_ship_file$ = EachIn stock_ships_files
		If ExtractExt( stock_ship_file ) <> "ship" Then Continue
		ed.load_stock_ship( stock_ships_dir, stock_ship_file )
	Next
	Local stock_variants_files$[] = LoadDir( stock_variants_dir )
	For Local stock_variant_file$ = EachIn stock_variants_files
		If ExtractExt( stock_variant_file ) <> "variant" Then Continue
		ed.load_stock_variant( stock_variants_dir, stock_variant_file )
	Next
	Local stock_variants_fighters_files$[] = LoadDir( stock_variants_fighters_dir )
	For Local stock_variant_file$ = EachIn stock_variants_fighters_files
		If ExtractExt( stock_variant_file ) <> "variant" Then Continue
		ed.load_stock_variant( stock_variants_fighters_dir, stock_variant_file )
	Next
	Local stock_variants_drones_files$[] = LoadDir( stock_variants_drones_dir )
	For Local stock_variant_file$ = EachIn stock_variants_drones_files
		If ExtractExt( stock_variant_file ) <> "variant" Then Continue
		ed.load_stock_variant( stock_variants_drones_dir, stock_variant_file )
	Next
	Local stock_weapons_files$[] = LoadDir( stock_weapons_dir )
	For Local stock_weapon_file$ = EachIn stock_weapons_files
		If ExtractExt( stock_weapon_file ) <> "wpn" Then Continue
		ed.load_stock_weapon( stock_weapons_dir, stock_weapon_file )
	Next
	Local stock_engine_styles_files$[] = LoadDir( stock_config_dir )
	For Local stock_engine_styles_file$ = EachIn stock_engine_styles_files
		If ExtractExt( stock_engine_styles_file ) <> "json" ..
		Or StripAll( stock_engine_styles_file ) <> "engine_styles" Then Continue
		ed.load_stock_engine_styles( stock_config_dir, stock_engine_styles_file )
	Next
	'/////
	If FileType( stock_ships_dir+"ship_data.csv" ) = FILETYPE_FILE
		ed.load_stock_ship_stats( stock_ships_dir, "ship_data.csv", vanilla )
	EndIf
	If FileType( stock_ships_dir+"wing_data.csv" ) = FILETYPE_FILE
		ed.load_stock_wing_stats( stock_ships_dir, "wing_data.csv", vanilla )
	EndIf
	If FileType( stock_weapons_dir+"weapon_data.csv" ) = FILETYPE_FILE
		ed.load_stock_weapon_stats( stock_weapons_dir, "weapon_data.csv", vanilla )
	EndIf
	If FileType( stock_hullmods_dir+"hull_mods.csv" ) = FILETYPE_FILE
		ed.load_stock_hullmod_stats( stock_hullmods_dir, "hull_mods.csv", vanilla )
	EndIf
End Function

Function load_ship_image( ed:TEditor, data:TData, sprite:TSprite )
	Local image_path$ = RequestFile( "LOAD Ship Image", "png", False, APP.images_dir )
	FlushKeys()
	If FILETYPE_FILE = FileType( image_path )
		APP.images_dir = ExtractDir( image_path )+"/"
		APP.save()
		load_ship_image__driver( ed, data, sprite, image_path )
		'image has been explicitly requested and successfully loaded
		'update data path if possible
		'examples:
		'C:\Dev\BlitzMax\starfarer_ship_editor\ms_right.png
		'C:\Games\Starfarer\mods\sc2\graphics\sc2\ships\sc2_earthling_cruiser.png
		image_path = image_path.Replace( "\", "/" ) 'just in case!
		Local scan$ = image_path
		While scan.length > "graphics".length 'to cover C:/ and /
			scan = ExtractDir( scan )'C:/Games/Starfarer/mods/sc2/graphics/sc2/ships
			If scan.EndsWith( "graphics" )'C:/Games/Starfarer/mods/sc2/graphics
				Local to_remove$ = ExtractDir( scan )+"/"'C:/Games/Starfarer/mods/sc2/
					image_path = image_path.Replace( to_remove, "" )'graphics/sc2/ships/sc2_earthling_cruiser.png
					If image_path.StartsWith( "graphics" ) 'just in case!
						data.ship.spriteName = image_path
						data.update()
					EndIf
				Exit
			EndIf
		EndWhile
	EndIf
End Function

Function load_ship_image__driver( ed:TEditor, data:TData, sprite:TSprite, image_path$ )
	sprite.img = LoadImage( image_path, 0 )
	'image has been loaded; update ship data to match it
	If sprite.img
		sprite.scale = ZOOM_LEVELS[ed.selected_zoom_level]
		data.ship.width = sprite.img.width
		data.ship.height = sprite.img.height
		If data.ship.center[1] = 0 And data.ship.center[0] = 0 'only change if not previously set
			data.set_center( data.ship.Height/2.0, data.ship.width/2.0 )
		End If
		data.update()
	End If
EndFunction

Function load_ship_data( ed:TEditor, data:TData, sprite:TSprite, use_new%=False )
	'SHIP data
	If Not use_new
		'user picks a file to load
		Local data_path$ = RequestFile( "LOAD Ship Data", "ship", False, APP.data_dir )
		FlushKeys()
		If FileType( data_path ) <> FILETYPE_FILE Then Return
		APP.data_dir = ExtractDir( data_path )+"/"
		APP.save()
		Local ship_data_json$ = LoadString( data_path )
		data.decode( ship_data_json )
		data.update()
		'CSV/STATS data
		'update csv row data that (hopefully) references the above hull
		data.csv_row = ed.get_ship_stats( data.ship.hullId )
		'VARIANT data
		'if the currently loaded variant doesn't reference the loaded hull, load one that does if possible
		If Not ed.verify_variant_association( data.ship.hullId, data.variant.variantId )
			data.variant = ed.get_default_variant( data.ship.hullId )
		EndIf
		data.update_variant_enforce_hull_compatibility( ed )
		data.update_variant()
		'FIGHTER WING CSV/STATS data'
		'if the current wing data doesn't reference the loaded variant, load one that does if possible
		If Not ed.verify_wing_data_association( data.variant.variantId, String(data.csv_row_wing.ValueForKey("id")))
			data.csv_row_wing = ed.get_default_wing( data.variant.variantId )
		EndIf
		'IMAGE (implied)
		'try to load the associated image, if one can be found
		autoload_ship_image( ed, data, sprite )
	Else ' use_new
		'all data is reset to fresh
		data.Clear()
		data.update()
		data.update_variant()
	EndIf
End Function

Function autoload_ship_image( ed:TEditor, data:TData, sprite:TSprite )
	Local found% = False
	'search mod directories
	For Local i% = 0 Until APP.mod_dirs.length
		Local img_path$ = APP.mod_dirs[i]+data.ship.spriteName
		If FILETYPE_FILE = FileType( img_path )
			load_ship_image__driver( ed, data, sprite, img_path )
			found = True
			Exit
		EndIf
	Next
	'search vanilla directories
	If Not found
		For Local j% = 0 Until STARFARER_CORE_DIR.length
			Local img_path$ = APP.starfarer_base_dir+STARFARER_CORE_DIR[j]+"/"+data.ship.spriteName
			If FILETYPE_FILE = FileType( img_path )
				load_ship_image__driver( ed, data, sprite, img_path )
				found = True
				Exit
			EndIf
		Next
	EndIf
EndFunction

Function load_variant_data( ed:TEditor, data:TData, sprite:TSprite, use_new%=False )
	'VARIANT data
	If Not use_new
		Local variant_path$ = RequestFile( "LOAD Variant Data", "variant", False, APP.variant_dir )
		FlushKeys()
		If FileType( variant_path ) <> FILETYPE_FILE Then Return
		APP.variant_dir = ExtractDir( variant_path )+"/"
		APP.save()
		data.decode_variant( LoadString( variant_path ))
		data.update_variant_enforce_hull_compatibility( ed )
		data.update_variant()
	Else
		data.variant = New TStarfarerVariant
		data.variant.hullId = data.ship.hullId
		data.variant.variantId = data.ship.hullId+"_variant"
		data.update_variant_enforce_hull_compatibility( ed )
		data.update_variant()
	EndIf
	'FIGHTER WING CSV/STATS data'
	'if the current wing data doesn't reference the loaded variant, load one that does if possible
	If Not ed.verify_wing_data_association( data.variant.variantId, String(data.csv_row_wing.ValueForKey("id")))
		data.csv_row_wing = ed.get_default_wing( data.variant.variantId )
	EndIf
End Function

Function load_mod( ed:TEditor, data:TData )
	Local mod_dir$ = RequestDir( "LOAD Mod Directory", APP.starfarer_base_dir )
	FlushKeys()
	If FileType( mod_dir ) = FILETYPE_DIR
		mod_dir :+ "/"
		DebugLogFile " Loading MOD Data: "+mod_dir
		load_stock_data( ed, data, mod_dir )
		'add to autoloader
		APP.mod_dirs = APP.mod_dirs[..APP.mod_dirs.length+1]
		APP.mod_dirs[APP.mod_dirs.length-1] = mod_dir
		APP.Save()
	EndIf
EndFunction

Function DebugLogFile( msg$ )
	DebugLog( msg )
	If DEBUG_LOG_FILE
		WriteLine( DEBUG_LOG_FILE, millisecs()+msg )
	EndIf	
EndFunction




