
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


Function load_ship_image( ed:TEditor, data:TData, sprite:TSprite, image_path$ = Null )
  image_path$ = RequestFile( LocalizeString("{{wt_load_image_ship}}"), "png", False, APP.images_dir )
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
  FlushEvent()
End Function

Function autoload_ship_image( ed:TEditor, data:TData, sprite:TSprite )
  Local img_path$ = resource_search( data.ship.spriteName )
  If img_path <> Null
    load_ship_image__driver( ed, data, sprite, img_path )
  EndIf
EndFunction

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

Function load_ship_data( ed:TEditor, data:TData, sprite:TSprite, use_new% = False, data_path$ = Null )
  'SHIP data
  If Not use_new
    'user picks a file to load
    data_path$ = RequestFile( LocalizeString("{{wt_load_ship}}"), "ship", False, APP.data_dir )
    If FileType( data_path ) <> FILETYPE_FILE Then Return
    APP.data_dir = ExtractDir( data_path )+"/"
    APP.save()
    Local ship_data_json$ = LoadTextAs( data_path, CODE_MODE )
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
    'add a weapon drawer support. we'd better reset(remove) all anime we are playing or there is a chance to result a out of bound error
    WD.restAllAnimes()
    FlushEvent()
  Else ' use_new
    'all data is reset to fresh
    WD.restAllAnimes()
    data.Clear()
    sprite.img = Null
    data.update()
    data.update_variant()
  EndIf
End Function

