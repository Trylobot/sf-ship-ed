
Type TModalSetSkin Extends TSubroutine
	
	
	
	Method Activate( ed:TEditor, data:TData, sprite:TSprite )
		ed.program_mode = "skin"
		ed.last_mode = "normal"
		ed.mode = "normal" ' normal mode: basically preview mode, just show the sprite
		ed.weapon_lock_i = - 1
		ed.variant_hullMod_i = - 1
		ed.group_field_i = - 1
    RadioMenuArray( MENU_MODE_SKIN, modeMenu )
    rebuildFunctionMenu(MENU_MODE_SKIN)
		DebugLogFile(" Activate Skin Editor")
	EndMethod

	Method Update( ed:TEditor, data:TData, sprite:TSprite )
	End Method

	Method Draw( ed:TEditor, data:TData, sprite:TSprite ) 
	EndMethod

	Method Save( ed:TEditor, data:TData, sprite:TSprite )
	EndMethod

	Method Load( ed:TEditor, data:TData, sprite:TSprite )
	EndMethod

EndType
