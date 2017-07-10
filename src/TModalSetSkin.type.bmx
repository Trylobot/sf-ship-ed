
Type TModalSetSkin Extends TSubroutine
	
	'------------------------------------
	'shared
	Field CURSOR_STR$ = ">>"
	Field SHOW_MORE_cached%
	Field ship_hullSize_cached$

	'------------------------------------
	'mode: "changeremove_weaponslots"


	'------------------------------------
	'mode: "addremove_builtin_weapons"


	'------------------------------------
	'mode: "changeremove_engines"


	'------------------------------------
	'mode: "addremove_hullmods"
	Field hullmod_chooser:TableWidget
	Field selected_hullmod_id$
	Field hullmod_chooser_text:TextWidget

	'------------------------------------
	'mode: "addremove_hints"


	
	'--------------------------------------------
	Method Activate( ed:TEditor, data:TData, sprite:TSprite )
		' global editor state
		ed.program_mode = "skin"
		ed.last_mode = "none"
		ed.mode = "none" ' none mode: basically preview mode, just draw some basics
		ed.weapon_lock_i = -1
		ed.group_field_i = -1
		ed.edit_strings_weapon_i = -1
		ed.edit_strings_engine_i = -1
		ed.skin_hullMod_i = -1
		' set sprite
		sprite.img = Null
    autoload_skin_image( ed, data, sprite )
    If Not sprite.img
    	Local skin:TStarfarerSkin = ed.get_default_skin( data.ship.hullId )
    	If skin
    		data.skin = skin
    		data.update_skin( True )
    		autoload_skin_image( ed, data, sprite )
    	EndIf
    EndIf
    ' menus
    RadioMenuArray( MENU_MODE_SKIN, modeMenu )
    rebuildFunctionMenu( MENU_MODE_SKIN )
		' info verbosity [0=min|1=lots|2=all]
		SHOW_MORE_cached = SHOW_MORE
		ship_hullSize_cached = data.ship.hullSize
    ' debug
		DebugLogFile(" ed.program_mode=~q"+ed.program_mode+"~q; ed.mode=~q"+ed.mode+"~q")
	EndMethod

	Method SetEditorMode( ed:TEditor, data:TData, sprite:TSprite, new_mode$ )
		Select new_mode

			Case "addremove_hullmods"
				ed.last_mode = ed.mode
				ed.mode = new_mode
				ed.skin_hullMod_i = 0
				initialize_hullmod_chooser( ed, data )
				SS.reset()
				DebugLogFile(" ed.program_mode=~q"+ed.program_mode+"~q; ed.mode=~q"+ed.mode+"~q")

		EndSelect
	EndMethod

	Method Update( ed:TEditor, data:TData, sprite:TSprite )
		'
		process_input_default( ed, data )
		' check for external data changes which can affect this mode's UI
		If SHOW_MORE_cached <> SHOW_MORE ..
		Or ship_hullSize_cached <> data.ship.hullSize
			' update cache
			SHOW_MORE_cached = SHOW_MORE
			ship_hullSize_cached = data.ship.hullSize
			'
			initialize_hullmod_chooser( ed, data )
			' ...
		EndIf
		'-----
		Select ed.mode
			
			Case "changeremove_weaponslots"
				process_input_changeremove_weaponslots( ed, data )
			
			Case "addremove_builtin_weapons"
				process_input_addremove_builtin_weapons( ed, data )
			
			Case "changeremove_engines"
				process_input_changeremove_engines( ed, data )
			
			Case "addremove_hullmods"
				process_input_addremove_hullmods( ed, data )
				update_hullmod_chooser( ed, data )
		
			Case "addremove_hints"
				process_input_addremove_hints( ed, data )

		EndSelect
	End Method

	Method Draw( ed:TEditor, data:TData, sprite:TSprite ) 
		draw_hud( ed, data )
		Select ed.mode
			
			Case "changeremove_weaponslots"
				'draw_weaponslots( ed, data )
			
			Case "addremove_builtin_weapons"
				'draw_weapons_chooser( ed, data )
			
			Case "changeremove_engines"
				'draw_engines( ed, data )
			
			Case "addremove_hullmods"
				draw_hullmods_chooser( ed, data )
			
			Case "addremove_hints"
				'draw_hints_chooser( ed, data )

		EndSelect
		SetAlpha( 1 )
	EndMethod

	Method Save( ed:TEditor, data:TData, sprite:TSprite )
	EndMethod

	Method Load( ed:TEditor, data:TData, sprite:TSprite )
	EndMethod

	'/////////////////////////////////////

	Method initialize_hullmod_chooser( ed:TEditor, data:TData )
		Local rows% =    1 + ed.stock_hullmod_count
		Local columns% = 1 + 1 + 1 + 1     ' cursor, status, ops (contextual), name
		If SHOW_MORE = 1 Or SHOW_MORE = 2
			columns :+ 1 ' description
		EndIf
		hullmod_chooser = New TableWidget
		hullmod_chooser.resize(rows, columns)
		hullmod_chooser.justify_col(2, JUSTIFY_RIGHT) ' ops
		'---------------------------------------------------------
		' setup header row
		Local r% = 0
		Local c% = 1 + 1 + 0 ' skip: cursor, status
		hullmod_chooser.set_cell(r,c, "OPs"); c :+ 1
		hullmod_chooser.set_cell(r,c, "Name"); c :+ 1
		If SHOW_MORE = 1 Or SHOW_MORE = 2
			hullmod_chooser.set_cell(r,c, "Description"); c :+ 1
		EndIf
		'---------------------------------------------------------
		' create list of known data to choose from
		ed.sort_hullmods_by_ordnance_points()
		Local i% = 0
		For Local hullmod_id$ = EachIn ed.stock_hullmod_ids_sorted
			Local hullmod:TMap = TMap( ed.stock_hullmod_stats.ValueForKey( hullmod_id ))
			' table pointer
			r = 1 + i     ' skip: header
			c = 1 + 1 + 0 ' skip: cursor, status
			'---------------------------------------------------------
			' data cells
			Local op_cost$ = String( data.get_hullmod_csv_ordnance_points( hullmod_id ))
			hullmod_chooser.set_cell(r,c, op_cost); c :+ 1
			Local hullmod_name$ = String( hullmod.ValueForKey("name"))
			hullmod_chooser.set_cell(r,c, hullmod_name); c :+ 1
			' additional data (toggle-able with Q)
			If SHOW_MORE = 1
				Local hullmod_desc$ = LSet(String( hullmod.ValueForKey("short")), 65)
				hullmod_chooser.set_cell(r,c, hullmod_desc); c :+ 1
			ElseIf SHOW_MORE = 2
				Local hullmod_desc$ = LSet(String( hullmod.ValueForKey("desc")), 130)
				hullmod_chooser.set_cell(r,c, hullmod_desc); c :+ 1
			EndIf
			i :+ 1
		Next
		'
		update_hullmod_chooser( ed, data )
	EndMethod

	Method update_hullmod_chooser( ed:TEditor, data:TData )
		' render table into text widget with precalculated dimensions in screen pixels
		'
		' assume: the chooser table is already the correct number of cells
		'   and, that all the data fields contain static data
		' update only: cursor row, status (columns: 0, 1)
		Local i% = 0
		For Local hullmod_id$ = EachIn ed.stock_hullmod_ids_sorted
			Local hullmod:TMap = TMap( ed.stock_hullmod_stats.ValueForKey( hullmod_id ))
			' table pointer
			Local r% = 1 + i ' skip: header
			Local c% = 0
			'---------------------------------------------------------
			' retain ID of selected hullmod
			Local cursor$ = ""
			If i = ed.skin_hullMod_i
				selected_hullmod_id = hullmod_id
				cursor = CURSOR_STR
			EndIf
			hullmod_chooser.set_cell(r,c, cursor); c :+ 1
			'---------------------------------------------------------
			' show status of each hullmod as it relates to this skin (and, its "base hull" (ship))
			Local hullmod_status$ = "   "
			If data.has_builtin_hullmod( hullmod_id )  Then hullmod_status = " b "
			If data.skin_adds_hullmod( hullmod_id )    Then hullmod_status = "[+]"
			If data.skin_removes_hullmod( hullmod_id ) Then hullmod_status = "---"
			hullmod_chooser.set_cell(r,c, hullmod_status); c :+ 1
			i :+ 1
		Next
		' cache for rendering
		hullmod_chooser_text = hullmod_chooser.to_TextWidget()
	EndMethod

	Method process_input_default( ed:TEditor, data:TData )
		Select EventID()
			Case EVENT_GADGETACTION, EVENT_MENUACTION
				Select EventSource()
					Case functionMenu[MENU_FUNCTION_EXIT] 'exit
						sub_set_skin.SetEditorMode( ed, data, sprite, "none" )
					Case functionMenuSub[MENU_MODE_SKIN][MENU_SUBFUNCTION_SKIN_CHANGEREMOVE_WEAPONSLOTS]
						sub_set_skin.SetEditorMode( ed, data, sprite, "changeremove_weaponslots" )
					Case functionMenuSub[MENU_MODE_SKIN][MENU_SUBFUNCTION_SKIN_ADDREMOVE_BUILTIN_WEAPONS]
						sub_set_skin.SetEditorMode( ed, data, sprite, "addremove_builtin_weapons" )
					Case functionMenuSub[MENU_MODE_SKIN][MENU_SUBFUNCTION_SKIN_CHANGEREMOVE_ENGINES]
						sub_set_skin.SetEditorMode( ed, data, sprite, "changeremove_engines" )
					Case functionMenuSub[MENU_MODE_SKIN][MENU_SUBFUNCTION_SKIN_ADDREMOVE_BUILTIN_HULLMODS]
						sub_set_skin.SetEditorMode( ed, data, sprite, "addremove_hullmods" )
					Case functionMenuSub[MENU_MODE_SKIN][MENU_SUBFUNCTION_SKIN_ADDREMOVE_HINTS]
						sub_set_skin.SetEditorMode( ed, data, sprite, "addremove_hints" )
					Case functionMenuSub[MENU_MODE_SKIN][MENU_SUBFUNCTION_SKIN_MORE]
						cycle_show_more()
				EndSelect
		EndSelect
	EndMethod

	Method process_input_changeremove_weaponslots( ed:TEditor, data:TData )
		
	EndMethod

	Method process_input_addremove_builtin_weapons( ed:TEditor, data:TData )
		
	EndMethod

	Method process_input_changeremove_engines( ed:TEditor, data:TData )
		
	EndMethod

	Method process_input_addremove_hullmods( ed:TEditor, data:TData )
		Select EventID()
			Case EVENT_KEYDOWN, EVENT_KEYREPEAT	
				Select EventData()
					Case KEY_ENTER
						'(attempt to) toggle selected hullmod being included in this skin
						'  if NOT on the base hull: toggle its inclusion in skin.builtInMods
						'  if on the base hull: toggle its inclusion in skin.removeBuiltInMods
						If data.has_builtin_hullmod( selected_hullmod_id )
							data.toggle_skin_removeBuiltInMods_hullmod( selected_hullmod_id )
						Else 'Not data.has_builtin_hullmod
							data.toggle_skin_builtin_hullmod( selected_hullmod_id )
						EndIf
						data.update_skin()
						SS.reset()
					Case KEY_DOWN
						ed.skin_hullMod_i :+ 1
					Case KEY_UP
						ed.skin_hullMod_i :- 1
					Case KEY_PAGEDOWN 
						ed.skin_hullMod_i :+ 5
					Case KEY_PAGEUP
						ed.skin_hullMod_i :- 5
				EndSelect
			Case EVENT_GADGETACTION, EVENT_MENUACTION
				Select EventSource()
					Case functionMenu[MENU_FUNCTION_EXIT]
						ed.skin_hullMod_i = - 1
				EndSelect
		End Select
		'bounds enforce (wrap top/bottom)
		If ed.skin_hullMod_i > (ed.stock_hullmod_count - 1)
			ed.skin_hullMod_i = 0
		ElseIf ed.skin_hullMod_i < 0
			ed.skin_hullMod_i = (ed.stock_hullmod_count - 1)
		EndIf
	EndMethod

	Method process_input_addremove_hints( ed:TEditor, data:TData )
		
	EndMethod


	Method draw_hud( ed:TEditor, data:TData )
	EndMethod

	Method draw_hullmods_chooser( ed:TEditor, data:TData )
		Local x# = W_MID
		Local y# = SS.ScrollTo(H_MID - LINE_HEIGHT*(ed.skin_hullMod_i + 0.5))
		Local ox# = 0.5
		Local oy# = 0.0
		If hullmod_chooser_text <> Null
			hullmod_chooser_text.draw( x,y, ox,oy )
		EndIf
	EndMethod



EndType


Function load_skin_image( ed:TEditor, data:TData, sprite:TSprite, image_path$ = Null )
  image_path$ = RequestFile( LocalizeString("{{wt_load_image_skin}}"), "png", False, APP.skin_images_dir )
  If FILETYPE_FILE = FileType( image_path )
    APP.skin_images_dir = ExtractDir( image_path )+"/"
    APP.save()
    load_skin_image__driver( ed, data, sprite, image_path )
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
            data.skin.spriteName = image_path
            data.update_skin()
          EndIf
        Exit
      EndIf
    EndWhile
  EndIf
  FlushEvent()
End Function

Function autoload_skin_image( ed:TEditor, data:TData, sprite:TSprite )
  Local img_path$ = resource_search( data.skin.spriteName )
  If img_path <> Null
    load_skin_image__driver( ed, data, sprite, img_path )
  EndIf
EndFunction

Function load_skin_image__driver( ed:TEditor, data:TData, sprite:TSprite, image_path$ )
  sprite.img = LoadImage( image_path, 0 )
  If sprite.img
  	'image has been loaded
  	'  skins assume the same dimensions & center of mass as the base hull(ship)
    sprite.scale = ZOOM_LEVELS[ed.selected_zoom_level]
  End If
EndFunction


Function load_skin_data( ed:TEditor, data:TData, sprite:TSprite, use_new% = False, data_path$ = Null )
  'SKIN data
  If Not use_new
    Local skin_path$ = RequestFile( LocalizeString("{{wt_load_skin}}"), "skin", False, APP.skin_dir )
    FlushKeys()
    If FileType( skin_path ) <> FILETYPE_FILE Then Return
    APP.skin_dir = ExtractDir( skin_path ) + "/"
    APP.save()
    data.decode_skin( LoadTextAs( skin_path, CODE_MODE ) )
    'load ship by skin's baseHullId, needed for skin mode hud and other sensible things
    Local baseHull:TStarfarerShip = TStarfarerShip( ed.stock_ships.ValueForKey( data.skin.baseHullId ))
    If baseHull <> Null
    	data.ship = baseHull
    	data.update()
    EndIf
    'load skin's sprite
    autoload_skin_image( ed, data, sprite )
    
    Rem

    TODO: Variants of Skins
    	
    	variant data will probably need to know whether it is:
      - a variant of a "normal" *.ship file (TStarfarerShip)
      - or a variant of a "skin" *.skin file (TStarfarerSkin -> TStarfarerShip)
      
      SOLUTION 1: perhaps we could create a "virtual" TStarfarerShip that mirrors what we would get
        if we in theory loaded the skin into the game?
        something to look into anyway, possibly will need to for v3.0.0 anyhow
        - we could "automatically" create these "ghost ships"
          for all skin files, and flag them as skins so we know not to save them
          that way variants don't even have to know the difference
      
      SOLUTION 2: create a new TStarfarerSkinVariant "meta" type
      	its only purpose would be to manage the interactions
	      	  between a ship, its skin, and a variant on top of that skin
	      	  (variants normally assume they point at "real" ships)
        it could have the following fields:
					Field baseHull:TStarfarerShip ' regular file, stand-alone
					Field hullSkin:TStarfarerSkin ' regular file, references baseHull
					Field mergedHull:TStarfarerShip ' points to and merges <baseHull,hullSkin>, creating a (temporary) "ghost ship"
					Field mergedHullVariant:TStarfarerVariant ' points to mergedHull

    ' code transplanted from  load_ship_data(...)
    'VARIANT data
    'if the currently loaded variant doesn't reference the loaded hull, load one that does if possible
    If Not ed.verify_variant_association( data.ship.hullId, data.variant.variantId )
      data.variant = ed.get_default_variant( data.ship.hullId )
    EndIf
    data.update_variant_enforce_hull_compatibility( ed )
    data.update_variant()

    EndRem
  Else
    data.skin = New TStarfarerSkin
    data.skin.baseHullId = data.ship.hullId
    data.skin.skinHullId = data.ship.hullId+"_skin"
    data.skin.hullName = data.ship.hullName+" Skin"
    data.skin.spriteName = data.ship.spriteName
  EndIf
  data.update_skin()
End Function
