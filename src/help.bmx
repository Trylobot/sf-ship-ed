
Const ICON_KB% = 10
Const ICON_SHIFT_KB% = 11
Const ICON_CTRL_ALT_KB% = 12
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

	HELP_WIDGETS = CreateList()
	HELP_LINE_HEIGHT = APP.font_size + Int((Float(APP.font_size)/7.0))
	'/////////////////////////////////////////////  ( key, description,         icon,    enable, space_after, program modes, sub-modes )
	HELP_WIDGETS.AddLast( TKeyboardHelpWidget.Create( "1", "Hull Mode         ", ICON_KB, True,   0 ))
	HELP_WIDGETS.AddLast( TKeyboardHelpWidget.Create( "2", "Variant Mode      ", ICON_KB, True,   0 ))
	HELP_WIDGETS.AddLast( TKeyboardHelpWidget.Create( "3", "Ship Stats Mode   ", ICON_KB, True,   0 ))
	HELP_WIDGETS.AddLast( TKeyboardHelpWidget.Create( "4", "Fighter Wing Mode ", ICON_KB, True,   0 ))
	HELP_WIDGETS.AddLast( TKeyboardHelpWidget.Create( "5", "Weapon Mode       ", ICON_KB, True,   0 ))
	HELP_WIDGETS.AddLast( TKeyboardHelpWidget.Create( "6", "Weapon Stats Mode ", ICON_KB, False,  0 ))
	HELP_WIDGETS.AddLast( TKeyboardHelpWidget.Create( "7", "Projectile Mode   ", ICON_KB, False,  1 ))
	'////////////
	HELP_WIDGETS.AddLast( TKeyboardHelpWidget.Create( "", "Pan View", ICON_MS_RIGHT, True, 0 ))
	HELP_WIDGETS.AddLast( TKeyboardHelpWidget.Create( "", "Zoom +/-", ICON_MS_MIDDLE, True, 1 ))
	'/////////////////////////////////////////////'
	HELP_WIDGETS.AddLast( TKeyboardHelpWidget.Create( "~~", "Toggle Vanilla Data", ICON_KB, True, 0 ))
	HELP_WIDGETS.AddLast( TKeyboardHelpWidget.Create( "M", "Load Custom Mod Data", ICON_KB, True, 0 ))
	HELP_WIDGETS.AddLast( TKeyboardHelpWidget.Create( "I", "Load Image", ICON_KB, True, 0, "ship" ))
	HELP_WIDGETS.AddLast( TKeyboardHelpWidget.Create( "D", "Open *.ship", ICON_KB, True, 0, "ship" ))
	HELP_WIDGETS.AddLast( TKeyboardHelpWidget.Create( "V", "Save *.ship", ICON_KB, True, 0, "ship" ))
	HELP_WIDGETS.AddLast( TKeyboardHelpWidget.Create( "N", "Clear Data", ICON_CTRL_ALT_KB, True, 1, "ship" ))
	'////////////
	'HELP_WIDGETS.AddLast( TKeyboardHelpWidget.Create( "X", "Choose Existing", ICON_KB, True, 0, "variant" ))
	HELP_WIDGETS.AddLast( TKeyboardHelpWidget.Create( "D", "Open *.variant", ICON_KB, True, 0, "variant" ))
	HELP_WIDGETS.AddLast( TKeyboardHelpWidget.Create( "V", "Save *.variant", ICON_KB, True, 1, "variant" ))
	'////////////
	HELP_WIDGETS.AddLast( TKeyboardHelpWidget.Create( "D", "Open Row of *.csv", ICON_KB, True, 0, "csv" ))
	HELP_WIDGETS.AddLast( TKeyboardHelpWidget.Create( "V", "Save Row to *.csv", ICON_KB, True, 1, "csv" ))
	'////////////
	HELP_WIDGETS.AddLast( TKeyboardHelpWidget.Create( "D", "Open Row of *.csv", ICON_KB, True, 0, "csv_wing" ))
	HELP_WIDGETS.AddLast( TKeyboardHelpWidget.Create( "V", "Save Row to *.csv", ICON_KB, True, 1, "csv_wing" ))
	'/////////////////////////////////////////////'
	HELP_WIDGETS.AddLast( TKeyboardHelpWidget.Create( "C", "Center of Mass", ICON_KB, True, 0, "ship" ))
	HELP_WIDGETS.AddLast( TKeyboardHelpWidget.Create( "S", "Shield Emitter", ICON_KB, True, 0, "ship" ))
	HELP_WIDGETS.AddLast( TKeyboardHelpWidget.Create( "B", "Bounds Polygon", ICON_KB, True, 0, "ship" ))
	HELP_WIDGETS.AddLast( TKeyboardHelpWidget.Create( "W", "Weapon Slots", ICON_KB, True, 0, "ship" ))
	HELP_WIDGETS.AddLast( TKeyboardHelpWidget.Create( "U", "Built-In Weapons", ICON_KB, True, 0, "ship" ))
	HELP_WIDGETS.AddLast( TKeyboardHelpWidget.Create( "H", "Built-In Hullmods", ICON_KB, True, 0, "ship" ))
	HELP_WIDGETS.AddLast( TKeyboardHelpWidget.Create( "E", "Engine Slots", ICON_KB, True, 0, "ship" ))
	HELP_WIDGETS.AddLast( TKeyboardHelpWidget.Create( "L", "Launch Bays", ICON_KB, True, 0, "ship" ))
	HELP_WIDGETS.AddLast( TKeyboardHelpWidget.Create( "T", "Ship Details", ICON_KB, True, 0, "ship" ))
	HELP_WIDGETS.AddLast( TKeyboardHelpWidget.Create( "P", "Preview", ICON_KB, True, 1, "ship" ))
	'////////////
	HELP_WIDGETS.AddLast( TKeyboardHelpWidget.Create( "",  "Set Center Point", ICON_MS_LEFT, True, 1, "ship", "center" ))
	'////////////
	HELP_WIDGETS.AddLast( TKeyboardHelpWidget.Create( "",  "Set Collision Radius", ICON_MS_LEFT, True, 1, "ship", "collision_radius" ))
	'////////////
	HELP_WIDGETS.AddLast( TKeyboardHelpWidget.Create( "",  "Set Shield Center", ICON_MS_LEFT, True, 1, "ship", "shield_center" ))
	'////////////
	HELP_WIDGETS.AddLast( TKeyboardHelpWidget.Create( "",  "Set Shield Radius", ICON_MS_LEFT, True, 1, "ship", "shield_radius" ))
	'////////////
	HELP_WIDGETS.AddLast( TKeyboardHelpWidget.Create( "",  "Add Vertex", ICON_SHIFT_CLICK, True, 0, "ship", "bounds" ))
	HELP_WIDGETS.AddLast( TKeyboardHelpWidget.Create( "",  "Drag Nearest", ICON_MS_LEFT, True, 0, "ship", "bounds" ))
	HELP_WIDGETS.AddLast( TKeyboardHelpWidget.Create( "",  "Drag All", ICON_CTRL_ALT_RIGHT_CLICK, True, 0, "ship", "bounds" ))
	HELP_WIDGETS.AddLast( TKeyboardHelpWidget.Create( Chr($2190),  "Remove Nearest", ICON_KB, True, 0, "ship", "bounds" ))
	HELP_WIDGETS.AddLast( TKeyboardHelpWidget.Create( "",  "Toggle Mirrored", ICON_SPACEBAR, True, 1, "ship", "bounds" ))
	'////////////
	HELP_WIDGETS.AddLast( TKeyboardHelpWidget.Create( "",  "Add New Weapon Slot", ICON_SHIFT_CLICK, True, 0, "ship", "weapon_slots" ))
	HELP_WIDGETS.AddLast( TKeyboardHelpWidget.Create( "",  "Drag Nearest", ICON_CTRL_CLICK, True, 0, "ship", "weapon_slots" ))
	HELP_WIDGETS.AddLast( TKeyboardHelpWidget.Create( "",  "Drag All", ICON_CTRL_ALT_RIGHT_CLICK, True, 0, "ship", "weapon_slots" ))
	HELP_WIDGETS.AddLast( TKeyboardHelpWidget.Create( "",  "Set Facing Angle", ICON_MS_LEFT, True, 0, "ship", "weapon_slots" ))
	HELP_WIDGETS.AddLast( TKeyboardHelpWidget.Create( "",  "Set Aiming Arc", ICON_ALT_CLICK, True, 0, "ship", "weapon_slots" ))
	HELP_WIDGETS.AddLast( TKeyboardHelpWidget.Create( Chr($2190),  "Remove Nearest", ICON_KB, True, 0, "ship", "weapon_slots" ))
	HELP_WIDGETS.AddLast( TKeyboardHelpWidget.Create( "",  "Toggle Mirrored", ICON_SPACEBAR, True, 1, "ship", "weapon_slots" ))
	'////////////
	HELP_WIDGETS.AddLast( TKeyboardHelpWidget.Create( "",  "Assign Weapon", ICON_MS_LEFT, True, 0, "ship", "built_in_weapons" ))
	HELP_WIDGETS.AddLast( TKeyboardHelpWidget.Create( Chr($2190),  "Strip Weapon", ICON_KB, True, 1, "ship", "built_in_weapons" ))
'////////////
	HELP_WIDGETS.AddLast( TKeyboardHelpWidget.Create( "",  "Add New Engine", ICON_SHIFT_CLICK, True, 0, "ship", "engine_slots" ))
	HELP_WIDGETS.AddLast( TKeyboardHelpWidget.Create( "",  "Drag Nearest", ICON_CTRL_CLICK, True, 0, "ship", "engine_slots" ))
	HELP_WIDGETS.AddLast( TKeyboardHelpWidget.Create( "",  "Drag All", ICON_CTRL_ALT_RIGHT_CLICK, True, 0, "ship", "engine_slots" ))
	HELP_WIDGETS.AddLast( TKeyboardHelpWidget.Create( "",  "Set Direction", ICON_MS_LEFT, True, 0, "ship", "engine_slots" ))
	HELP_WIDGETS.AddLast( TKeyboardHelpWidget.Create( "",  "Set Size", ICON_ALT_CLICK, True, 0, "ship", "engine_slots" ))
	HELP_WIDGETS.AddLast( TKeyboardHelpWidget.Create( Chr($2190),  "Remove Nearest", ICON_KB, True, 0, "ship", "engine_slots" ))
	HELP_WIDGETS.AddLast( TKeyboardHelpWidget.Create( "",  "Toggle Mirrored", ICON_SPACEBAR, True, 1, "ship", "engine_slots" ))
	'////////////
	HELP_WIDGETS.AddLast( TKeyboardHelpWidget.Create( "",  "Add Launch Port", ICON_SHIFT_CLICK, True, 0, "ship", "launch_bays" ))
	HELP_WIDGETS.AddLast( TKeyboardHelpWidget.Create( "",  "Drag Nearest", ICON_MS_LEFT, True, 0, "ship", "launch_bays" ))
	HELP_WIDGETS.AddLast( TKeyboardHelpWidget.Create( "",  "Drag All", ICON_CTRL_ALT_RIGHT_CLICK, True, 0, "ship", "launch_bays" ))
	HELP_WIDGETS.AddLast( TKeyboardHelpWidget.Create( "",  "Cycle Launch Bays", ICON_MS_RIGHT, True, 0, "ship", "launch_bays" ))
	HELP_WIDGETS.AddLast( TKeyboardHelpWidget.Create( Chr($2190),  "Remove Nearest", ICON_KB, True, 1, "ship", "launch_bays" ))
	'////////////
	HELP_WIDGETS.AddLast( TKeyboardHelpWidget.Create( "",  "Assign Weapon", ICON_MS_LEFT, True, 0, "variant" ))
	HELP_WIDGETS.AddLast( TKeyboardHelpWidget.Create( "G", "Weapon Groups", ICON_KB, True, 0, "variant" ))
	HELP_WIDGETS.AddLast( TKeyboardHelpWidget.Create( "F", "Flux Vents", ICON_SHIFT_KB, True, 0, "variant" ))
	HELP_WIDGETS.AddLast( TKeyboardHelpWidget.Create( "C", "Flux Capacitors", ICON_SHIFT_KB, True, 0, "variant" ))
	HELP_WIDGETS.AddLast( TKeyboardHelpWidget.Create( "H", "Hull Modifications", ICON_KB, True, 0, "variant" ))
	HELP_WIDGETS.AddLast( TKeyboardHelpWidget.Create( "T", "Variant Details", ICON_KB, True, 0, "variant" ))
	HELP_WIDGETS.AddLast( TKeyboardHelpWidget.Create( Chr($2190),  "Strip Weapon", ICON_KB, True, 0, "variant" ))
	HELP_WIDGETS.AddLast( TKeyboardHelpWidget.Create( "/", "Strip All", ICON_KB, True, 1, "variant" ))
	'////////////
	HELP_WIDGETS.AddLast( TKeyboardHelpWidget.Create( "T", "Edit CSV Data", ICON_KB, True, 1, "csv" ))
	'////////////
	HELP_WIDGETS.AddLast( TKeyboardHelpWidget.Create( "T", "Edit CSV Data", ICON_KB, True, 1, "csv_wing" ))
	'/////////////////////////////////////////////'
	HELP_WIDGETS.AddLast( TKeyboardHelpWidget.Create( "D", "Open *.wpn", ICON_KB, True, 0, "weapon" ))
	HELP_WIDGETS.AddLast( TKeyboardHelpWidget.Create( "V", "Save *.wpn", ICON_KB, True, 0, "weapon" ))
	HELP_WIDGETS.AddLast( TKeyboardHelpWidget.Create( "N", "Clear Data", ICON_CTRL_ALT_KB, True, 1, "weapon" ))
	'////////////
	HELP_WIDGETS.AddLast( TKeyboardHelpWidget.Create( "O", "Offsets", ICON_KB, True, 0, "weapon" ))
	HELP_WIDGETS.AddLast( TKeyboardHelpWidget.Create( "I", "Images", ICON_KB, True, 0, "weapon" ))
	HELP_WIDGETS.AddLast( TKeyboardHelpWidget.Create( "T", "Weapon Details", ICON_KB, True, 0, "weapon" ))
	HELP_WIDGETS.AddLast( TKeyboardHelpWidget.Create( "H", "Turret/Hardpoint", ICON_KB, True, 1, "weapon" ))
	'////////////
	HELP_WIDGETS.AddLast( TKeyboardHelpWidget.Create( "",  "Add Offset", ICON_SHIFT_CLICK, True, 0, "weapon", "offsets" ))
	HELP_WIDGETS.AddLast( TKeyboardHelpWidget.Create( "",  "Drag Nearest", ICON_MS_LEFT, True, 0, "weapon", "offsets" ))
	HELP_WIDGETS.AddLast( TKeyboardHelpWidget.Create( "",  "Set Facing Angle", ICON_CTRL_CLICK, True, 0, "weapon", "offsets" ))
	HELP_WIDGETS.AddLast( TKeyboardHelpWidget.Create( Chr($2190),  "Remove Nearest", ICON_KB, True, 0, "weapon", "offsets" ))
	HELP_WIDGETS.AddLast( TKeyboardHelpWidget.Create( "",  "Toggle Mirrored", ICON_SPACEBAR, True, 1, "weapon", "offsets" ))
	'////////////
	HELP_WIDGETS.AddLast( TKeyboardHelpWidget.Create( "U",  "Set Under", ICON_KB, True, 0, "weapon", "images" ))
	HELP_WIDGETS.AddLast( TKeyboardHelpWidget.Create( "G",  "Set Gun", ICON_KB, True, 0, "weapon", "images" ))
	HELP_WIDGETS.AddLast( TKeyboardHelpWidget.Create( "A",  "Set Main", ICON_KB, True, 0, "weapon", "images" ))
	HELP_WIDGETS.AddLast( TKeyboardHelpWidget.Create( "L",  "Set Glow", ICON_KB, True, 1, "weapon", "images" ))
	'/////////////////////////////////////////////'
	HELP_WIDGETS.AddLast( TKeyboardHelpWidget.Create( "F1", "Toggle This Help", 0, True, 0 ))
	HELP_WIDGETS.AddLast( TKeyboardHelpWidget.Create( "F2", "Toggle Raw Data", 0, True, 0 ))
	HELP_WIDGETS.AddLast( TKeyboardHelpWidget.Create( "F3", "Toggle Guides", 0, True, 0 ))
	HELP_WIDGETS.AddLast( TKeyboardHelpWidget.Create( "ESC","Quit (Hold)", 0, True, 1 ))
	'/////////////////////////////////////////////'

	'none, center, bounds, collision_radius, engine_slots, shield_center, shield_radius, weapon_slots, preview_all
	CONTEXT_HELP = CreateMap()
	CONTEXT_HELP.Insert( "ship.string_data", "~n"+..
		"Esc   back to previous" )

	'anything can append to this and it will be shown each frame
	mouse_str = ""

EndFunction


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
					Case ICON_SHIFT_KB
						DrawImage( ed.kb_key_image, x - 4, y - 3 )
						DrawImage( ed.kb_key_wide_image, x-18-18-4 - 4, y - 3 )
						SetImageFont( DATA_FONT )
						draw_string( "SHIFT", x-18-18-4,y - 1, $000000,bg_color,,,, True )
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

