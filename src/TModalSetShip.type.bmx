Type TModalSetShip Extends TSubroutine

  Method Activate( ed:TEditor, data:TData, sprite:TSprite )
    ed.program_mode = "ship"
    ed.mode = "none"
    ed.last_mode = "none"
    ed.weapon_lock_i = - 1
    ed.field_i = 0
    autoload_ship_image( ed, data, sprite )
    RadioMenuArray( MENU_MODE_SHIP, modeMenu )
    rebuildFunctionMenu( MENU_MODE_SHIP )
    DebugLogFile(" Activate Ship Editor")
  EndMethod

  Method Update( ed:TEditor, data:TData, sprite:TSprite )
  EndMethod

  Method Draw( ed:TEditor, data:TData, sprite:TSprite ) 
  EndMethod

  Method Load( ed:TEditor, data:TData, sprite:TSprite )
  EndMethod
  
  Method Save( ed:TEditor, data:TData, sprite:TSprite )
  EndMethod

EndType
