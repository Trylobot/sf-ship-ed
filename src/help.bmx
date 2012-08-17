Global HELP_WIDGETS:TList
Global HELP_LINE_HEIGHT%
Global ICON_KB%
Global ICON_MS_LEFT%
Global ICON_MS_RIGHT%
Global ICON_MS_MIDDLE%
Global ICON_SHIFT_CLICK%
Global ICON_CTRL_CLICK%
Global ICON_ALT_CLICK%
Global ICON_SPACEBAR%
Global ICON_CTRL_ALT_RIGHT_CLICK%
Global CONTEXT_HELP:TMap
Global mouse_str$

Function load_help()

	HELP_WIDGETS = CreateList()
	HELP_LINE_HEIGHT = APP.font_size + Int((Float(APP.font_size)/7.0))
	ICON_KB = 10
	ICON_MS_LEFT = 20
	ICON_MS_RIGHT = 21
	ICON_MS_MIDDLE = 22
	ICON_SHIFT_CLICK = 30
	ICON_CTRL_CLICK = 31
	ICON_ALT_CLICK = 32
	ICON_SPACEBAR = 33
	ICON_CTRL_ALT_RIGHT_CLICK = 34
	'/////////////////////////////////////////////  ( key, description,             icon,    enable, margin, program modes, sub-modes )
	HELP_WIDGETS.AddLast( TKeyboardHelpWidget.Create( "1", "*.ship Mode          ", ICON_KB, True,   0 ))
	HELP_WIDGETS.AddLast( TKeyboardHelpWidget.Create( "2", "*.variant Mode       ", ICON_KB, True,   0 ))
	HELP_WIDGETS.AddLast( TKeyboardHelpWidget.Create( "3", "*.csv Mode           ", ICON_KB, True,   1 ))
	'////////////
	HELP_WIDGETS.AddLast( TKeyboardHelpWidget.Create( "", "Pan View", ICON_MS_RIGHT, True, 0 ))
	HELP_WIDGETS.AddLast( TKeyboardHelpWidget.Create( "", "Zoom +/-", ICON_MS_MIDDLE, True, 1 ))
	'/////////////////////////////////////////////'
	HELP_WIDGETS.AddLast( TKeyboardHelpWidget.Create( "M", "Load Custom Mod Data", ICON_KB, True, 0 ))
	HELP_WIDGETS.AddLast( TKeyboardHelpWidget.Create( "I", "Load Image", ICON_KB, True, 0, "ship" ))
	HELP_WIDGETS.AddLast( TKeyboardHelpWidget.Create( "D", "Open *.ship", ICON_KB, True, 0, "ship" ))
	HELP_WIDGETS.AddLast( TKeyboardHelpWidget.Create( "V", "Save *.ship", ICON_KB, True, 1, "ship" ))
	'////////////
	'HELP_WIDGETS.AddLast( TKeyboardHelpWidget.Create( "X", "Choose Existing", ICON_KB, True, 0, "variant" ))
	HELP_WIDGETS.AddLast( TKeyboardHelpWidget.Create( "D", "Open *.variant", ICON_KB, True, 0, "variant" ))
	HELP_WIDGETS.AddLast( TKeyboardHelpWidget.Create( "V", "Save *.variant", ICON_KB, True, 1, "variant" ))
	'////////////
	HELP_WIDGETS.AddLast( TKeyboardHelpWidget.Create( "D", "Open Row of *.csv", ICON_KB, True, 0, "csv" ))
	HELP_WIDGETS.AddLast( TKeyboardHelpWidget.Create( "V", "Save Row to *.csv", ICON_KB, True, 1, "csv" ))
	'/////////////////////////////////////////////'
	HELP_WIDGETS.AddLast( TKeyboardHelpWidget.Create( "C", "Center of Mass", ICON_KB, True, 0, "ship" ))
	HELP_WIDGETS.AddLast( TKeyboardHelpWidget.Create( "S", "Shield Emitter", ICON_KB, True, 0, "ship" ))
	HELP_WIDGETS.AddLast( TKeyboardHelpWidget.Create( "B", "Bounds Polygon", ICON_KB, True, 0, "ship" ))
	HELP_WIDGETS.AddLast( TKeyboardHelpWidget.Create( "W", "Weapon Slots", ICON_KB, True, 0, "ship" ))
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
	HELP_WIDGETS.AddLast( TKeyboardHelpWidget.Create( "F", "Flux Vents", ICON_KB, True, 0, "variant" ))
	HELP_WIDGETS.AddLast( TKeyboardHelpWidget.Create( "C", "Flux Capacitors", ICON_KB, True, 0, "variant" ))
	HELP_WIDGETS.AddLast( TKeyboardHelpWidget.Create( "H", "Hull Modifications", ICON_KB, True, 0, "variant" ))
	HELP_WIDGETS.AddLast( TKeyboardHelpWidget.Create( "T", "Variant Details", ICON_KB, True, 0, "variant" ))
	HELP_WIDGETS.AddLast( TKeyboardHelpWidget.Create( Chr($2190),  "Strip Weapon", ICON_KB, True, 0, "variant" ))
	HELP_WIDGETS.AddLast( TKeyboardHelpWidget.Create( "/", "Strip All", ICON_KB, True, 1, "variant" ))
	'////////////
	HELP_WIDGETS.AddLast( TKeyboardHelpWidget.Create( "T", "Edit CSV Data", ICON_KB, True, 1, "csv" ))
	'/////////////////////////////////////////////'
	HELP_WIDGETS.AddLast( TKeyboardHelpWidget.Create( "F1", "Toggle This Help", 0, True, 0 ))
	HELP_WIDGETS.AddLast( TKeyboardHelpWidget.Create( "F2", "Toggle Raw Data", 0, True, 0 ))
	HELP_WIDGETS.AddLast( TKeyboardHelpWidget.Create( "F3", "Toggle Guides", 0, True, 0 ))
	HELP_WIDGETS.AddLast( TKeyboardHelpWidget.Create( "Esc", "Quit (Hold)", 0, True, 1 ))
	'/////////////////////////////////////////////'

	'none, center, bounds, collision_radius, engine_slots, shield_center, shield_radius, weapon_slots, preview_all
	CONTEXT_HELP = CreateMap()
	CONTEXT_HELP.Insert( "ship.string_data", "~n"+..
		"Esc   back to previous" )


	'anything can append to this and it will be shown each frame
	mouse_str = ""

EndFunction
