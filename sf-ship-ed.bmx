Rem

STARSECTOR Ship&Weapon Editor
Created by Trylobot
Updated by Deathfly

EndRem

SuperStrict
'Framework BRL.GLMax2D
Import BRL.GLMax2D
Import BRL.RamStream
Import BRL.PNGLoader
Import BRL.JPGLoader
Import BRL.FreeTypeFont
Import BRL.event
Import BRL.eventqueue
Import maxgui.MaxGUI
Import maxgui.drivers
Import maxgui.win32maxguiex
Import maxgui.localization

Import "src/rjson.bmx"
Import "src/console.bmx"
?Win32
Import "assets/sf_icon.o"
?
Incbin "release/sf-ship-ed-settings.json" 'for defaults
Incbin "assets/bg.png"
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
Incbin "assets/engineflame32.png"
Incbin "assets/engineflamecore32.png"
Incbin "release/ENG.ini"

Const FLOAT_MAX# = 10e38:Float

Include "src/config_json_transforms.bmx"
Include "src/functions_misc.bmx"
Include "src/drawing_misc.bmx"
Include "src/instaquit.bmx"
Include "src/menu.bmx"
Include "src/TextWidget.type.bmx"
Include "src/TableWidget.type.bmx"
Include "src/TStarfarerShip.type.bmx"
Include "src/TStarfarerSkin.type.bmx"
Include "src/TStarfarerShipWeapon.type.bmx"
Include "src/TStarfarerShipWeaponChange.type.bmx" 'thin extension for skins
Include "src/TStarfarerCustomEngineStyleSpec.type.bmx"
Include "src/TStarfarerShipEngine.type.bmx"
Include "src/TStarfarerShipEngineChange.type.bmx" 'thin extension for skins
Include "src/TStarfarerVariant.type.bmx"
Include "src/TStarfarerVariantWeaponGroup.type.bmx"
Include "src/TStarfarerWeapon.type.bmx"
Include "src/TStarfarerWeaponMuzzleFlashSpec.type.bmx"
Include "src/TStarfarerWeaponSmokeSpec.type.bmx"
Include "src/TCSVLoader.type.bmx"
Include "src/ShipDataCSVFieldTemplate.bmx"
Include "src/WingDataCSVFieldTemplate.bmx"
Include "src/WeaponDataCSVFieldTemplate.bmx"
Include "src/TModalSetWeaponCSV.type.bmx"
Include "src/TData.type.bmx"
Include "src/TSprite.type.bmx"
Include "src/TEditor.type.bmx"
Include "src/TSubroutine.type.bmx"
Include "src/TGenericCSVSubroutine.type.bmx"
Include "src/TModalSetShip.type.bmx"
Include "src/TModalSetShipCenter.type.bmx"
Include "src/TModalSetShieldCenter.type.bmx"
Include "src/TModalSetBounds.type.bmx"
Include "src/TModalSetWeaponSlots.type.bmx"
Include "src/TModalSetBuiltInWeapons.type.bmx"
Include "src/TModalSetBuiltInHullMods.type.bmx"
Include "src/TModalSetBuiltInWings.type.bmx"
Include "src/TModalSetEngineSlots.type.bmx"
Include "src/TModalSetLaunchBays.type.bmx"
Include "src/TModalSetStringData.type.bmx"
Include "src/TModalPreviewAll.type.bmx"
Include "src/TModalSetVariant.type.bmx"
Include "src/TModalSetVariantWings.type.bmx"
Include "src/TModalSetSkin.type.bmx"
Include "src/TModalSetShipCSV.type.bmx"
Include "src/TModalSetWingCSV.type.bmx"
Include "src/TModalSetWeapon.type.bmx"
Include "src/Application.type.bmx"
Include "src/help.bmx"
Include "src/multiselect_values.bmx"
Include "src/TTextCoder.bmx"
Include "src/TWeaponDrawer.bmx"
Include "src/TWingrenderer.bmx"

'/////////////////////////////////////////////
'MARK init APP var
Global DEBUG_LOG_FILE:TStream = WriteStream( "sf-ship-ed.log" )
Global LOC:TMaxGuiLanguage
SetGraphicsDriver GLMax2DDriver()
AppTitle = "STARSECTOR Ship&Weapon Editor"
Global APP:Application = Application.Load()
Global Apprunning% = True
Global W_MAX# = APP.window_size[0], W_MID# = W_MAX / 2.0
Global H_MAX# = APP.window_size[1], H_MID# = H_MAX / 2.0
Global FONT:TImageFont = Null
Global DATA_FONT:TImageFont = Null
Global LINE_HEIGHT% = APP.font_size + 1
Global DATA_LINE_HEIGHT% = APP.data_font_size
Global CODE_MODE% = 1' LATIN1

Global SHOW_MORE% = 0
Function cycle_show_more()
  SHOW_MORE :+ 1; If SHOW_MORE > 2 Then SHOW_MORE = 0
EndFunction

Global DO_ROUND% = 1

Global ZOOM_LEVELS#[] = [ 0.25, 0.5, 0.75, 1.0, 1.25, 1.5, 2.0, 2.5, 3.0, 3.5, 4.0, 4.5, 5.0, 6.0, 7.0, 8.0, 9.0, 10.0, 15.0, 20.0, 30.0, 40.0, 50.0, 100.0, 200.0 ]
Const ZOOM_SNAP# = 0.025
Const ZOOM_UPDATE_FACTOR# = 0.25 'per frame

'////////////////////////////////////////////////

Const MAX_VARIANT_WEAPON_GROUPS% = 5
Const ENGINE_MANEUVERING_JETS_CONTRAIL_SIZE% = 128 'hack: makes a custom engine style into a "maneuvering jet"

'////////////////////////////////////////////////
'MARK init main windows
Global MainWindow:TGadget = CreateWindow("{{wt_main}}", 200, 0, W_MAX, H_MAX, Null, WINDOW_TITLEBAR | WINDOW_MENU | WINDOW_RESIZABLE | WINDOW_ACCEPTFILES )
Global CSVEditor:TGadget = Null
H_MAX = MainWindow.ClientHeight()
H_MID = H_MAX / 2
W_MAX = MainWindow.ClientWidth()
W_MID = W_MAX / 2
Global Canvas:TGadget = CreateCanvas(0, 0, GadgetWidth( Desktop() ), GadgetHeight( Desktop() ), MainWindow)
Canvas.SetArea(0, 0, W_MAX, H_MAX )
Global graphic:TGraphics = CanvasGraphics (Canvas)
SetGraphics(graphic)
SetClsColor( 0, 0, 0 )
AutoMidHandle( True )
SetBlend( ALPHABLEND )

'FONT = LoadImageFont( "incbin::assets/consola.ttf", APP.font_size, SMOOTHFONT )
'DATA_FONT = LoadImageFont( "incbin::assets/consola.ttf", APP.data_font_size, SMOOTHFONT )
'SetImageFont( FONT )
'////////////////////////////////////////////////
'MARK UTF-8 and Font support testing
If APP.UTF8_support
  CODE_MODE = 2
EndIf

If APP.custom_FONT.length > 0
  FONT = LoadImageFont( APP.custom_FONT, APP.font_size, SMOOTHFONT )
  DATA_FONT = LoadImageFont( APP.custom_FONT, APP.data_font_size, SMOOTHFONT )
  SetImageFont( FONT )
Else
  FONT = LoadImageFont( "incbin::assets/consola.ttf", APP.font_size, SMOOTHFONT )
  DATA_FONT = LoadImageFont( "incbin::assets/consola.ttf", APP.data_font_size, SMOOTHFONT )
  SetImageFont( FONT )
EndIf
'////////////////////////////////////////////////

'MARK display loading message
Cls
draw_string( "Loadin' ...", W_MID, H_MID,,, 0.5, 0.5 )
Flip( 1 )

'////////////////////////////////////////////////
'MARK json
config_json_transforms()

'////////////////////////////////////////////////
'MARK Local var init

Global ed:TEditor = New TEditor
ed.show_help = True

Global sprite:TSprite = New TSprite
sprite.scale = ZOOM_LEVELS[ed.selected_zoom_level]
ed.target_sprite_scale = sprite.scale

Global data:TData = New TData

'MARK init UI
init_gui_menus()
rebuildFunctionMenu(MENU_MODE_SHIP) 'default mode: ship

'MARK init help
load_help()

'////////////////////////////////////////////////

'modifier keys
Global ModKeyAndMouseKey:Byte = False
Global SHIFT:Byte = False
Global CONTROL:Byte = False
Global ALT:Byte = False
Global quote:String = Chr(34)
'Mouse Local
Global MouseX% = 0
Global MouseY% = 0
Global MouseZ% = 0
Global z_delta% = 0
Global MouseDown% [4]
Global MouseClick% = 0
Local mouseInRange% = 0

Global TEXT_W:TextWidget = TextWidget.Create( "W" )
Global TEXT_E:TextWidget = TextWidget.Create( "E" )
Global TEXT_L:TextWidget = TextWidget.Create( "L" )

'////////////////////////////////////////////////
'init ui and data set
load_ui( ed )

load_starfarer_data( ed, data )

'////////////////////////////////////////////////
'MARK init modals
Global sub_set_ship:TModalSetShip = New TModalSetShip
Global sub_set_ship_center:TModalSetShipCenter = New TModalSetShipCenter
Global sub_set_bounds:TModalSetBounds = New TModalSetBounds
Global sub_set_shield_center:TModalSetShieldCenter = New TModalSetShieldCenter
Global sub_set_weapon_slots:TModalSetWeaponSlots = New TModalSetWeaponSlots
Global sub_set_built_in_weapons:TModalSetBuiltInWeapons = New TModalSetBuiltInWeapons
Global sub_set_built_in_hullmods:TModalSetBuiltInHullMods = New TModalSetBuiltInHullMods
Global sub_set_built_in_wings:TModalSetBuiltInWings = New TModalSetBuiltInWings
Global sub_set_engine_slots:TModalSetEngineSlots = New TModalSetEngineSlots
Global sub_string_data:TModalSetStringData = New TModalSetStringData
Global sub_set_launchbays:TModalSetLaunchBays = New TModalSetLaunchBays
Global sub_preview_all:TModalPreviewAll = New TModalPreviewAll
Global sub_set_variant:TModalSetVariant = New TModalSetVariant
Global sub_set_variant_wings:TModalSetVariantWings = New TModalSetVariantWings
Global sub_set_skin:TModalSetSkin = New TModalSetSkin
Global sub_ship_csv:TModalSetShipCSV = New TModalSetShipCSV
Global sub_wing_csv:TModalSetWingCSV = New TModalSetWingCSV
Global sub_set_weapon:TModalSetWeapon = New TModalSetWeapon
Global sub_weapon_csv:TModalSetWeaponCSV = New TModalSetWeaponCSV
Global SS:TSmoothScroll = New TSmoothScroll

'////////////////////////////////////////////////
'MARK init FPS limiter
Global Lmt_FPS% = APP.fps_limit
If Not Lmt_FPS Then Lmt_FPS = DesktopHertz()
If Not Lmt_FPS Or Lmt_FPS < 1 Then Lmt_FPS = 60
Global Timer:TTimer = CreateTimer(Lmt_FPS)
'////////////////////////////////////////////////
'MARK init weapon drawer
Global WD:TWeaponDrawer = New TWeaponDrawer

'MARK inti wing renderer
Global WR:TWingRenderer = New TWingRenderer

'MARK Enable Polled Input for test
'EnablePolledInput(Canvas)

data.changed = False
MainWindow.Activate(1)
MainWindow.SetSensitivity(SENSITIZE_ALL)
updata_weapondrawermenu(ed)
'//////////////////////////////////////////////////////////////////////////////
'//////////////////////////////////////////////////////////////////////////////
'/////// MARK MAIN LOOP  //////////////////////////////////////////////////////
'//////////////////////////////////////////////////////////////////////////////
'//////////////////////////////////////////////////////////////////////////////

Repeat
  'MARK Events
  'TODO adding Events
  WaitEvent()
  'instaquit
  escape_key_update()

  'If EventID() <> EVENT_GADGETPAINT And EventID() <> EVENT_TIMERTICK Then Print CurrentEvent.ToString()
  If Not Apprunning And EventID() <> EVENT_APPRESUME Then Continue
  '
  Select EventID()
    
    Case EVENT_APPSUSPEND, EVENT_APPRESUME
      'freeze after lose focus
      Apprunning = (EventID() = EVENT_APPRESUME)
      If Apprunning
        ModKeyAndMouseKey = 0
      Else
        SetBlend(ALPHABLEND)
        SetColor(0, 0, 0)
        SetAlpha(0.8)
        DrawRect(0, 0, W_MAX, H_MAX)
        SetBlend(ALPHABLEND)
        Flip(1)
      EndIf
    
    Case EVENT_KEYDOWN, EVENT_KEYUP, EVENT_KEYREPEAT
      If EventID() = EVENT_KEYDOWN Or EventID() = EVENT_KEYUP
        Select EventData()
          Case KEY_LSHIFT, KEY_RSHIFT
            If (SHIFT = (EventData() Or 1) ) = (EventID() = EVENT_KEYUP) Then SHIFT :~ EventData()
            If SHIFT Then ModKeyAndMouseKey :| MODIFIER_SHIFT Else ModKeyAndMouseKey :& ( 255 - MODIFIER_SHIFT)
          Case KEY_LCONTROL, KEY_RCONTROL
            If (CONTROL = (EventData() Or 1) ) = (EventID() = EVENT_KEYUP) Then CONTROL :~ EventData()
            If CONTROL Then ModKeyAndMouseKey :| MODIFIER_CONTROL Else ModKeyAndMouseKey :& ( 255 - MODIFIER_CONTROL)
          Case KEY_LALT, KEY_RALT
            If (ALT = (EventData() Or 1) ) = (EventID() = EVENT_KEYUP) Then ALT :~ EventData()
            If ALT Then ModKeyAndMouseKey :| MODIFIER_ALT Else ModKeyAndMouseKey :& ( 255 - MODIFIER_ALT)
        End Select
        'fake a EVENT_MOUSEMOVE to
        EmitEvent(CreateEvent(EVENT_MOUSEMOVE, Canvas, 0, 0, MouseX, MouseY) )
      EndIf
      'pass key event down when we are in string edit mode
        If check_sub_routines( ed, data, sprite) Then Continue

    Case EVENT_GADGETACTION , EVENT_MENUACTION
      'DebugLog (EventSource().ToString() )
      If EventSource() = optionMenu[MENU_OPTION_ABOUT]
        Notify("STARSECTOR Ship&Weapon Editor~nCreated by Trylobot~nUpdated by Deathfly~n~n" + LocalizeString("{{msg_localisation_credits}}") )
      EndIf
      check_zoom_and_pan( ed, data, sprite )
      If check_undo( ed, data, sprite ) Then Continue
      'skip most hotkeys when we are in string edit mode or so.
      If (ed.mode = "string_data" ..
      Or (ed.program_mode = "csv"        And (sub_ship_csv.loaded_csv_id_list   Or sub_ship_csv.csv_row_values) )..
      Or (ed.program_mode = "csv_wing"   And (sub_wing_csv.loaded_csv_id_list   Or sub_wing_csv.csv_row_values) ) ..
      Or (ed.program_mode = "csv_weapon" And (sub_weapon_csv.loaded_csv_id_list Or sub_weapon_csv.csv_row_values) ) )
        If check_sub_routines( ed, data, sprite) Then Continue
      Else
        If check_file_menu( ed, data, sprite ) Then Continue
        If check_mode_menu( ed, data, sprite ) Then Continue
        If check_option_menu( ed, data ) Then Continue
        If check_function_menu( ed, data, sprite ) Then Continue
        check_weapondrawer(ed, data, sprite)
        If check_sub_routines( ed, data, sprite) Then Continue      
      EndIf

    ' Case EVENT_MOUSEENTER, EVENT_MOUSELEAVE
    '   mouseInRange = (EventID() = EVENT_MOUSEENTER)
    '   If Not mouseInRange
    '   ModKeyAndMouseKey = 0
    '   EndIf
    
    Case EVENT_MOUSEDOWN, EVENT_MOUSEMOVE, EVENT_MOUSEUP
      MouseClick = 0
      'If mouseInRange
        MouseX = EventX()
        MouseY = EventY()
      'EndIf
      If EventID() = EVENT_MOUSEDOWN
        MouseDown[EventData()] = 1
        MouseClick = EventData()
        ModKeyAndMouseKey :| 8 Shl EventData()
      EndIf
      'pass mouse event down
      check_zoom_and_pan( ed, data, sprite )
      check_sub_routines( ed, data, sprite)   
      If EventID() = EVENT_MOUSEUP
        MouseDown[EventData()] = 0
        ModKeyAndMouseKey :& 255 - (8 Shl EventData() )
      EndIf 
    
    Case EVENT_MOUSEWHEEL
      MouseZ :+ EventData()
      check_zoom_and_pan( ed, data, sprite )
    
    Case EVENT_WINDOWACCEPT

    Case EVENT_WINDOWSIZE
      If EventSource() = MainWindow
        H_MAX = MainWindow.ClientHeight()
        H_MID = H_MAX / 2
        W_MAX = MainWindow.ClientWidth()
        W_MID = W_MAX / 2
        Canvas.SetArea( 0, 0, W_MAX, H_MAX)
        SetGraphics( CanvasGraphics(Canvas) )
        SetClsColor( 0, 0, 0 )
        AutoMidHandle( True )
        SetBlend( ALPHABLEND )
        ed.bg_scale = Max( W_MAX / Float(ed.bg_image.width), H_MAX / Float(ed.bg_image.height) )  
      EndIf
    
    Case EVENT_TIMERTICK
      RedrawGadget(Canvas)
    
    Case EVENT_GADGETPAINT
      If EventSource() = Canvas
        Cls
        'display string for mouse (usually context-help)
        mouse_str = ""    

        'update
        update_zoom( ed, data, sprite )
        updatUndo( data )
        sprite.update()
        update_menu()    

        'draw
        draw_bg( ed )
        draw_sprite( ed, sprite )
        draw_weapons( ed, data, sprite, WD )
        
        Select ed.program_mode

          Case "ship"
            Select ed.mode
              Case "none"
                sub_set_ship.Draw( ed, data, sprite )
              Case "center"
                sub_set_ship_center.Draw( ed, data, sprite )
              Case "bounds"
                sub_set_bounds.Draw( ed, data, sprite )
              Case "shield_center"
                sub_set_shield_center.Draw( ed, data, sprite )
              Case "weapon_slots"
                sub_set_weapon_slots.Draw( ed, data, sprite )
              Case "built_in_weapons"
                sub_set_built_in_weapons.Draw( ed, data, sprite )
              Case "built_in_hullmods"
                sub_set_built_in_hullmods.Draw( ed, data, sprite )
              Case "built_in_wings"
                sub_set_built_in_wings.Draw( ed, data, sprite )
              Case "engine_slots"
                sub_set_engine_slots.Draw( ed, data, sprite )
              Case "launch_bays"
                sub_set_launchbays.Draw( ed, data, sprite )
              Case "preview_all"
                sub_preview_all.Draw( ed, data, sprite )
              'Case "string_data"
                'performed below
            End Select      
          
          Case "variant"
            Select ed.mode
              Case "normal"
                sub_set_variant.Draw( ed, data, sprite )
              Case "variant_wings"
                sub_set_variant_wings.Draw( ed, data, sprite )
              'Case "string_data"
                'performed below
            EndSelect

          Case "skin"
            If ed.mode <> "string_data"
              sub_set_skin.Draw( ed, data, sprite )
            EndIf
            'string_data
            '  performed below          
          
          Case "csv"
            sub_ship_csv.Draw( ed, data, sprite )

          Case "csv_wing"
            sub_wing_csv.Draw( ed, data, sprite )

          Case "weapon"
            sub_set_weapon.Draw( ed, data, sprite ) 
          
          Case "csv_weapon"
            sub_weapon_csv.Draw( ed, data, sprite ) 

        End Select

        draw_help( ed )
        draw_data( ed, data )
        draw_status( ed, data, sprite )
        draw_mouse_str()
        draw_debug( ed, data, sprite )

        If ed.mode = "string_data"
          sub_string_data.Draw( ed, data, sprite )
        End If

        'instaquit
        draw_instaquit_progress( W_MAX, H_MAX )
        
        Flip( 1 )

      EndIf

    Case EVENT_APPTERMINATE, EVENT_WINDOWCLOSE
      end_program( data )
    
  EndSelect
Until AppTerminate()

'//////////////////////////////////////////////////////////////////////////////
'//////////////////////////////////////////////////////////////////////////////
'/////// MARK MAIN LOOP END   /////////////////////////////////////////////////
'//////////////////////////////////////////////////////////////////////////////
'//////////////////////////////////////////////////////////////////////////////

Function end_program( data:TData )
  If data.changed
    If Confirm( LocalizeString("{{msg_unsaved_exit}}") ) Then End
  Else
    End
  EndIf
EndFunction



If DEBUG_LOG_FILE
  CloseStream( DEBUG_LOG_FILE )
EndIf
End

'////////////////////////////////////////////////
'MARK Function set

Function check_sub_routines% ( ed:TEditor, data:TData, sprite:TSprite )
  Local hit% = True
  
  Select ed.program_mode
   
    Case "ship"
      Select ed.mode
        Case "none"
          sub_set_ship.Update( ed, data, sprite )
        Case "center"
          sub_set_ship_center.Update( ed, data, sprite )
        Case "bounds"
          sub_set_bounds.Update( ed, data, sprite )
        Case "shield_center"
          sub_set_shield_center.Update( ed, data, sprite )
        Case "weapon_slots"
          sub_set_weapon_slots.Update( ed, data, sprite )
        Case "built_in_weapons"
          sub_set_built_in_weapons.Update( ed, data, sprite )
        Case "built_in_hullmods"
          sub_set_built_in_hullmods.Update( ed, data, sprite )
        Case "built_in_wings"
          sub_set_built_in_wings.Update( ed, data, sprite )
        Case "engine_slots"
          sub_set_engine_slots.Update( ed, data, sprite )
        Case "launch_bays"
          sub_set_launchbays.Update( ed, data, sprite )
        Case "string_data"
          sub_string_data.Update( ed, data, sprite )
        Case "preview_all"
          sub_preview_all.Update( ed, data, sprite )
      End Select    
    
    Case "variant"
      Select ed.mode
        Case "normal"
          sub_set_variant.Update( ed, data, sprite )
        Case "variant_wings"
          sub_set_variant_wings.Update( ed, data, sprite )
        Case "string_data"
          sub_string_data.Update( ed, data, sprite )
      EndSelect   
    
    Case "skin"
      If ed.mode <> "string_data"
        sub_set_skin.Update( ed, data, sprite )
      Else
        sub_string_data.Update( ed, data, sprite )
      EndIf
    
    Case "csv"
      sub_ship_csv.Update( ed, data, sprite )
    
    Case "csv_wing"
      sub_wing_csv.Update( ed, data, sprite )
    
    Case "weapon"
      Select ed.mode
        Case "string_data"
          sub_string_data.Update( ed, data, sprite )
        Default
          sub_set_weapon.Update( ed, data, sprite )     
      EndSelect
    
    Case "csv_weapon"
      sub_weapon_csv.Update( ed, data, sprite )
    
    Default
      hit = False

  End Select
  Return hit
End Function

'MARK GAlist check
'-----------------------
' Return true if the input EventSource(Object) hit the checkes, so we can skip the rest
Function check_file_menu%(ed:TEditor, data:TData, sprite:TSprite)
  Local hit% = True
  Select EventSource()
    
    Case fileMenu[MENU_FILE_NEW] 'new file
      If data.changed
        If Not Confirm(LocalizeString("{{msg_unsaved_open_new}}") ) Then Return hit
      EndIf
      WD.restAllAnimes()
      
      Select ed.program_mode
        
        Case "ship", "csv", "csv_wing"
          data.ship = New TStarfarerShip
          data.variant = New TStarfarerVariant
          data.csv_row = ship_data_csv_field_template.Copy()
          data.csv_row_wing = wing_data_csv_field_template.Copy() 
          sprite.img = Null
          data.update()
          data.update_variant()
          data.changed = False
          data.snapshots_undo:TList = CreateList()
          data.snapshots_redo:TList = CreateList()
        
        Case "variant"
          data.variant = New TStarfarerVariant
          data.variant.hullId = data.ship.hullId
          data.variant.displayName = "New"
          data.variant.variantId = data.ship.hullId + "_new"
          data.update()
          data.update_variant()
          data.changed = False
          data.snapshots_undo:TList = CreateList()
          data.snapshots_redo:TList = CreateList()
        
        Case "skin"
          data.ship = New TStarfarerShip
          data.variant = New TStarfarerVariant
          data.skin = New TStarfarerSkin
          sprite.img = Null
          data.update()
          data.update_variant()
          data.update_skin()
          data.changed = False
          data.snapshots_undo:TList = CreateList()
          data.snapshots_redo:TList = CreateList()
        
        Case "weapon", "csv_weapon"
          data.weapon = New TStarfarerWeapon
          data.csv_row_weapon = weapon_data_csv_field_template.Copy()
          sprite.img = Null
          data.update_weapon()
          data.changed = False
          data.snapshots_undo:TList = CreateList()
          data.snapshots_redo:TList = CreateList()

      EndSelect
    
    Case fileMenu[MENU_FILE_LOAD_MOD] 'load mod
      load_mod( ed, data )
    
    Case fileMenu[MENU_FILE_LOAD_DATA] 'load data
      If data.changed
        If Not Confirm(LocalizeString("{{msg_unsaved_open_new}}") ) Then Return hit
      EndIf
      data.snapshot_inited = False
      Select ed.program_mode
      Case "ship"
        load_ship_data( ed, data, sprite )
      Case "variant"
        load_variant_data( ed, data, sprite )
      Case "skin"
        load_skin_data( ed, data, sprite )
      Case "csv"
        sub_ship_csv.Load( ed, data, sprite )
      Case "csv_wing"
        sub_wing_csv.Load( ed, data, sprite )
      Case "weapon"
        sub_set_weapon.Load( ed, data, sprite )
      Case "csv_weapon"
        sub_weapon_csv.Load( ed, data, sprite )
      EndSelect
      data.take_initshot()
      data.changed = False
    
    Case fileMenu[MENU_FILE_LOAD_IMAGE] 'load image
      Select ed.program_mode
        Case "ship", "variant", "csv", "csv_wing"
          load_ship_image( ed, data, sprite )
        Case "skin"
          load_skin_image( ed, data, sprite )
      EndSelect
    
    Case fileMenu[MENU_FILE_SAVE] 'save data
      
      Select ed.program_mode
        
        Case "ship"
          Local data_path$ = RequestFile( LocalizeString( "{{wt_save_ship}}"), "ship", True, APP.data_dir + data.ship.hullId + ".ship" )
          FlushKeys()
          If data_path
            APP.data_dir = ExtractDir( data_path ) + "/"
            APP.Save()
            'SaveString( data.json_str, data_path )
            SaveTextAs(data.json_str, data_path, CODE_MODE)
            data.changed = False
          End If
        
        Case "variant"
          Local variant_path$ = RequestFile( LocalizeString("{{wt_save_variant}}"), "variant", True, APP.variant_dir + data.variant.variantId + ".variant" )
          FlushKeys()
          If variant_path
            APP.variant_dir = ExtractDir( variant_path ) + "/"
            APP.Save()
            'SaveString( data.json_str_variant, variant_path )
            SaveTextAs(data.json_str_variant, variant_path, CODE_MODE)
            data.changed = False
          End If
        
        Case "skin"
          Local skin_path$ = RequestFile( LocalizeString("{{wt_save_skin}}"), "skin", True, APP.skin_dir + data.skin.skinHullId + ".skin" )
          FlushKeys()
          If skin_path
            APP.skin_dir = ExtractDir( skin_path ) + "/"
            APP.Save()
            'SaveString( data.json_str_variant, variant_path )
            SaveTextAs(data.json_str_skin, skin_path, CODE_MODE)
            data.changed = False
          End If
        
        Case "csv"  
          sub_ship_csv.Save( ed, data, sprite )
        
        Case "csv_wing" 
          sub_wing_csv.Save( ed, data, sprite )
        
        Case "weapon"
          sub_set_weapon.Save( ed, data, sprite )
        
        Case "csv_weapon"
          sub_weapon_csv.Save( ed, data, sprite )
      EndSelect
    
    Case fileMenu[MENU_FILE_EXIT] 'exit
      end_program( data )
    
    Default
      hit = False

  End Select
  Return hit
End Function
'-----------------------

' if the input EventSource(Object) "hits," it is consumed and nothing that would normally follow gets to process it
'   sort of like {Event}.preventDefault() in Javascript
Function check_mode_menu%( ed:TEditor, data:TData, sprite:TSprite )
  Local hit% = True
  Select EventSource()
    
    Case modeMenu[MENU_MODE_SHIP] 'm_mode_ship
      sub_set_ship.Activate( ed, data, sprite )
   
    Case modeMenu[MENU_MODE_VARIANT] 'm_mode_variant
      sub_set_variant.Activate( ed, data, sprite )
    
    Case modeMenu[MENU_MODE_SKIN] 'm_mode_skin
      sub_set_skin.Activate( ed, data, sprite )
    
    Case modeMenu[MENU_MODE_SHIPSTATS] 'm_mode_ship_stats
      sub_ship_csv.Activate( ed, data, sprite )
    
    Case modeMenu[MENU_MODE_WING] 'm_mode_wing
      sub_wing_csv.Activate( ed, data, sprite )
    
    Case modeMenu[MENU_MODE_WEAPON] 'm_mode_weapon
      sub_set_weapon.Activate( ed, data, sprite )
    
    Case modeMenu[MENU_MODE_WEAPONSTATS] 'm_mode_weapon_stats
      sub_weapon_csv.Activate( ed, data, sprite )
    
    ' Case modeMenu[MENU_MODE_PROJECTILE] 'm_mode_projectile
    '   sub_projectile.Activate( ed, data, sprite )

    Default
      hit = False
  End Select
  updata_weapondrawermenu(ed) 
  Return hit
End Function


Function check_option_menu%(ed:TEditor, data:TData)
  Local hit% = True
  Select EventSource()
    Case optionMenu[MENU_OPTION_HELP]
      ed.show_help = Not ed.show_help
    Case optionMenu[MENU_OPTION_JSON]
      ed.show_data = Not ed.show_data
    Case optionMenu[MENU_OPTION_GUIDES]
      ed.show_debug = Not ed.show_debug
      If ed.show_debug Then SetPointer(POINTER_CROSS) Else SetPointer(POINTER_DEFAULT)
    Case optionMenu[MENU_OPTION_MIRROR]
      ed.bounds_symmetrical = Not ed.bounds_symmetrical
    Case optionMenu[MENU_OPTION_VANILLA]
      APP.hide_vanilla_data = Not APP.hide_vanilla_data
      load_starfarer_data( ed, data )
    Default
      hit = False
  End Select
  Return hit
End Function

Function check_undo%(ed:TEditor, data:TData, sprite:TSprite)
  Local hit% = True
  Select EventSource()
    Case functionMenu[MENU_FUNCTION_UNDO]
      undo(ed, data, sprite, False)
    Case functionMenu[MENU_FUNCTION_REDO]
      undo(ed, data, sprite, True)
    Default
      hit = False
  End Select
  Return hit
End Function

Function check_weapondrawer%(ed:TEditor, data:TData, sprite:TSprite)
  WD.check(ed, data)  
End Function

Function updata_weapondrawermenu(ed:TEditor)
  Local flag# = (ed.mode <> "string" ..
          And ( (ed.program_mode = "ship" And ( ed.mode = "built_in_weapons" Or ed.mode = "weapon_slots") ) ..
            Or (ed.program_mode = "variant" And ed.variant_hullMod_i = - 1 And ed.group_field_i = - 1)..
            Or (ed.program_mode = "weapon") ) )           
  If MenuEnabled(animateMenu[MENU_ANIMATE]) <> flag
    For Local i# = 0 Until animateMenu.length
      animateMenu[i].SetEnabled(flag)
    Next
    mainMenuNeedUpdate = True
  EndIf
End Function

Function updatUndo(data:TData)
  If (data.snapshots_undo.IsEmpty() And Not data.changed) = MenuEnabled(functionMenu[MENU_FUNCTION_UNDO])
    functionMenu[MENU_FUNCTION_UNDO].setenabled(Not (data.snapshots_undo.IsEmpty() And Not data.changed) )
    mainMenuNeedUpdate = True
  EndIf
  If (data.snapshots_redo.IsEmpty() ) = MenuEnabled(functionMenu[MENU_FUNCTION_REDO])
    functionMenu[MENU_FUNCTION_REDO].setenabled(Not data.snapshots_redo.IsEmpty() )
    mainMenuNeedUpdate = True
  EndIf

End Function


Function check_function_menu% ( ed:TEditor, data:TData, sprite:TSprite )
  Local hit% = True
  Select ed.program_mode
    
    Case "ship"
      Select EventSource()
        Case functionMenu[MENU_FUNCTION_EXIT] 'exit
          ed.last_mode = ed.mode
          ed.mode = "none"
          ed.field_i = 0
        Case functionMenuSub[MENU_MODE_SHIP][MENU_SUBFUNCTION_SHIP_CENTER] 'mass center
          sub_set_ship_center.Activate( ed, data, sprite )
        Case functionMenuSub[MENU_MODE_SHIP][MENU_SUBFUNCTION_SHIP_SHIELD] 'shield center
          sub_set_shield_center.Activate( ed, data, sprite )
        Case functionMenuSub[MENU_MODE_SHIP][MENU_SUBFUNCTION_SHIP_BOUNDS] 'bounds
          sub_set_bounds.Activate( ed, data, sprite )
        Case functionMenuSub[MENU_MODE_SHIP][MENU_SUBFUNCTION_SHIP_WEAPONSLOTS] 'weapon slots
          sub_set_weapon_slots.Activate( ed, data, sprite )
        Case functionMenuSub[MENU_MODE_SHIP][MENU_SUBFUNCTION_SHIP_BUILTINWEAPONS], functionMenuSub[MENU_MODE_SHIP][MENU_SUBFUNCTION_SHIP_DECORATIVE] 'built-in or decorative weapon mode, check it in Activate later
          sub_set_built_in_weapons.Activate( ed, data, sprite )
        Case functionMenuSub[MENU_MODE_SHIP][MENU_SUBFUNCTION_SHIP_BUILTINHULLMODS] 'built-in hullmods
          sub_set_built_in_hullmods.Activate( ed, data, sprite )
        Case functionMenuSub[MENU_MODE_SHIP][MENU_SUBFUNCTION_SHIP_BUILTINWINGS] 'built-in wings
          sub_set_built_in_wings.Activate( ed, data, sprite )
        Case functionMenuSub[MENU_MODE_SHIP][MENU_SUBFUNCTION_SHIP_ENGINE] 'engine slots
          sub_set_engine_slots.Activate( ed, data, sprite )
        Case functionMenuSub[MENU_MODE_SHIP][MENU_SUBFUNCTION_SHIP_LAUNCHBAYS] 'launch bays
          sub_set_launchbays.Activate( ed, data, sprite )
        Case functionMenuSub[MENU_MODE_SHIP][MENU_SUBFUNCTION_SHIP_PREVIEW] 'preview
          sub_preview_all.Activate( ed, data, sprite )
        Case functionMenuSub[MENU_MODE_SHIP][MENU_SUBFUNCTION_SHIP_MORE] 'show more
          cycle_show_more()
        Case functionMenu[MENU_FUNCTION_DETAILS] 'string edit
          sub_string_data.Activate( ed, data, sprite )
        Default
          hit = False
      EndSelect
    
    Case "variant"
      Select EventSource()
        Case functionMenuSub[MENU_MODE_VARIANT][MENU_SUBFUNCTION_VARIANT_WINGS] 'variant wings
          sub_set_variant_wings.Activate( ed, data, sprite )
        Case functionMenuSub[MENU_MODE_VARIANT][MENU_SUBFUNCTION_VARIANT_STRIPALL]
          load_variant_data( ed, data, sprite, True ) 'strip all  
        Case functionMenu[MENU_FUNCTION_DETAILS]
          sub_string_data.Activate( ed, data, sprite ) 'string edit
        Case functionMenuSub[MENU_MODE_VARIANT][MENU_SUBFUNCTION_VARIANT_MORE] 'show more
          cycle_show_more()
        Default
          hit = False
      EndSelect

    Case "skin"
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
        Case functionMenu[MENU_FUNCTION_DETAILS]
          sub_string_data.Activate( ed, data, sprite ) ' string edit
        Default
          hit = False
      EndSelect
    
    Case "weapon"
      Select EventSource()
        Case functionMenu[MENU_FUNCTION_DETAILS]
          sub_string_data.Activate( ed, data, sprite ) 'string edit
        Default
          hit = False
      EndSelect

    Default
      hit = False

  EndSelect
  updata_weapondrawermenu(ed)

  Return hit
EndFunction

'-----------------------

Function update_menu()
  If mainMenuNeedUpdate
    UpdateWindowMenu(MainWindow)
    mainMenuNeedUpdate = False
  EndIf
End Function

Function check_zoom_and_pan(ed:TEditor, data:TData, sprite:TSprite)
    Select EventID()
      Case EVENT_MOUSEDOWN, EVENT_MOUSEUP, EVENT_MOUSEMOVE
        Select ModKeyAndMouseKey
        Case 32 '(MODIFIER_RMOUSE)
        'pan CONTROL
          Select EventID()
          Case EVENT_MOUSEDOWN
            ed.pan_start_x = sprite.pan_x
            ed.pan_start_y = sprite.pan_y
            ed.pan_start_mouse_x = MouseX
            ed.pan_start_mouse_y = MouseY
          Case EVENT_MOUSEMOVE
            sprite.pan_x = ed.pan_start_x + (MouseX - ed.pan_start_mouse_x)
            sprite.pan_y = ed.pan_start_y + (MouseY - ed.pan_start_mouse_y)
          EndSelect
        EndSelect
      Case EVENT_MOUSEWHEEL
        'zoom CONTROL, by MOUSEWHEEL
        If MouseZ <> ed.mouse_z
          z_delta = MouseZ - ed.mouse_z
          ed.mouse_z = MouseZ
        EndIf
      Case EVENT_GADGETACTION, EVENT_MENUACTION
        Select EventSource()
        'zoom CONTROL, by key
          Case functionMenu[MENU_FUNCTION_ZOOMIN]
            z_delta :+ 1
          Case functionMenu[MENU_FUNCTION_ZOOMOUT]
            z_delta :- 1
        EndSelect
    EndSelect
End Function

Function update_zoom( ed:TEditor, data:TData, sprite:TSprite )
  If z_delta <> 0
    Local img_x#, img_y#
    sprite.get_img_xy( MouseX, MouseY, img_x, img_y )
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
    ' Local ship_c_x%, ship_c_y%
    ' sprite.xform_ship_c_to_scr( data.ship.center, ship_c_x, ship_c_y )
    ' '''sprite.zpan_x :+ MouseX - ship_c_x
    ' '''sprite.zpan_y :+ MouseY - ship_c_y
    ' ed.target_zpan_x :- MouseX - ship_c_x
    ' ed.target_zpan_y :- MouseY - ship_c_y
    'EndIf
    z_delta = 0
  End If
  If Abs(ed.target_sprite_scale - sprite.scale) < ZOOM_SNAP
    sprite.scale = ed.target_sprite_scale
    'sprite.zpan_x = ed.target_zpan_x
    'sprite.zpan_y = ed.target_zpan_y
  Else
    sprite.scale :+ ZOOM_UPDATE_FACTOR * (ed.target_sprite_scale - sprite.scale)
    'sprite.zpan_x :+ ZOOM_UPDATE_FACTOR*(ed.target_zpan_x - sprite.zpan_x)
    'sprite.zpan_y :+ ZOOM_UPDATE_FACTOR*(ed.target_zpan_y - sprite.zpan_y)
  EndIf
  ''trap sprite in viewable area
  'If sprite.sx + sprite.sw < 0
  ' sprite.zpan_x :- (sprite.sx + sprite.sw)
  'EndIf
End Function

'-----------------------
'drawers

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

Function draw_sprite( ed:TEditor, sprite:TSprite )
  If ed.program_mode = "weapon"
    Return
  EndIf
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
    If ed.program_mode = "variant" ..
    Or ed.program_mode = "csv" ..
    Or ed.program_mode = "csv_wing" ..
    Or ed.program_mode = "csv_weapon" ..
    Or ed.mode = "weapon_slots" ..
    Or ed.mode = "built_in_weapons" ..
    Or ed.mode = "built_in_hullmods" ..
    Or ed.mode = "built_in_wings" ..
    Or ed.mode = "launch_bays" ..
    Or ed.mode = "string_data"
      SetColor( 127, 127, 127 )
    EndIf
    DrawImage( sprite.img, W_MID + sprite.pan_x + sprite.zpan_x, H_MID + sprite.pan_y + sprite.zpan_y )
  End If
End Function

Function draw_data( ed:TEditor, data:TData )
  If ed.show_data
    Local view:TList
    If ed.program_mode = "ship"
      view = data.json_view
    ElseIf ed.program_mode = "skin"
      view = data.json_view_skin
    ElseIf ed.program_mode = "variant"
      view = data.json_view_variant
    ElseIf ed.program_mode = "weapon"
      view = data.json_view_weapon
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

Function draw_debug( ed:TEditor, data:TData, sprite:TSprite )
  If ed.show_debug And sprite
    Select ed.program_mode
      Case "weapon", "csv_weapon"
        draw_crosshairs(sprite.asx + sub_set_weapon.xOffset * sprite.scale, sprite.asy, 6, True)
    End Select
    If Not sprite.img Then Return
    Local img_x#, img_y#
    sprite.get_img_xy( MouseX, MouseY, img_x, img_y, False )
    Local col# = RoundFloat(img_x - 0.5, 1)
    Local row# = RoundFloat(img_y - 0.5, 1)
    'draw row, col indicators
    SetRotation( 0 )
    SetScale( 1, 1 )
    SetColor( 255, 255, 255 )
    If col >= 0 And col < sprite.img.height And row >= 0 And row < sprite.img.width
      SetAlpha( 0.25 )
      If col > 0 Then DrawRect( sprite.sx, sprite.sy + Float(row) * sprite.scale, Float(col) * sprite.scale, sprite.scale )
      If col < sprite.img.height - 1 Then DrawRect( sprite.sx + Float(col + 1) * sprite.scale, sprite.sy + Float(row) * sprite.scale, Float(sprite.img.height - 1 - col) * sprite.scale, sprite.scale )
      If row > 0 Then DrawRect( sprite.sx + Float(col)*sprite.scale, sprite.sy, sprite.scale, Float(row)*sprite.scale )
      If row < sprite.img.width - 1 Then DrawRect( sprite.sx + Float(col) * sprite.scale, sprite.sy + Float(row + 1) * sprite.scale, sprite.scale, Float(sprite.img.width - 1 - row) * sprite.scale )
      SetAlpha( 1 )
      SetColor( 0, 0, 0 )
      DrawRectLines( sprite.sx - 2 + Float(col) * sprite.scale, sprite.sy - 2 + Float(row) * sprite.scale, sprite.scale + 4, sprite.scale + 4, 3 )
      SetColor( 255, 255, 255 )
      DrawRectLines( sprite.sx - 1 + Float(col) * sprite.scale, sprite.sy - 1 + Float(row) * sprite.scale, sprite.scale + 2, sprite.scale + 2, 1 )
    End If
    'draw bounding rectangle
    SetAlpha( 1 )
    SetColor( 0, 0, 0 )
    DrawRectLines( sprite.sx - 1, sprite.sy - 1, sprite.sw + 2, sprite.sh + 2, 3 )
    SetColor( 255, 255, 255 )
    DrawRectLines( sprite.sx, sprite.sy, sprite.sw, sprite.sh )
  End If
End Function

Function draw_mouse_str()
  draw_string( mouse_str, MouseX + 13, MouseY + 3 )
End Function

Function draw_status( ed:TEditor, data:TData, sprite:TSprite )
  'prepare information
  SetColor( 255, 255, 255 )
  SetScale( 1, 1 )
  SetRotation( 0 )
  SetAlpha( 1 )
  Local img_x#, img_y#
  Local ang_relevant% = False
  Local ico_w% = 18
  Local ico_h% = 18
  Local w$, h$, x$, y$
  
  If ed.program_mode <> "weapon"
    If Not sprite.img Then Return
    sprite.get_img_xy( MouseX, MouseY, img_x, img_y )
    w = "" + sprite.img.width
    h = "" + sprite.img.height
    x = json.FormatDouble( img_x - data.ship.center[1], 1 )
    y = json.FormatDouble( - ( img_y - data.ship.center[0] ), 1 )
  Else 'ed.program_mode == "weapon"
    sprite.get_xy( MouseX, MouseY, img_x, img_y )
    If sprite.img Then w = "" + sprite.img.width Else w = "N/A"
    If sprite.img Then h = "" + sprite.img.height Else h = "N/A"
    x = json.FormatDouble( img_x - sub_set_weapon.xOffset , 1 )
    y = json.FormatDouble( - img_y , 1 )
  EndIf
  
  Local a$ = json.FormatDouble( 0, 1 )
  Local z$ = Int(100.0 * sprite.scale)
  Local m% = ed.bounds_symmetrical
  
  If ed.program_mode = "ship" ..
  And ed.mode = "weapon_slots" 
    Local ni% = data.find_nearest_weapon_slot( img_x, img_y )
    If ed.weapon_lock_i <> -1 Then ni = ed.weapon_lock_i
    If ni <> -1
      Local weapon:TStarfarerShipWeapon = data.ship.weaponSlots[ni]
      ang_relevant = True
      a = json.FormatDouble( calc_angle( weapon.locations[0], weapon.locations[1], img_x - data.ship.center[1], - ( img_y - data.ship.center[0] ) ), 1 )
    EndIf
  
  ElseIf ed.program_mode = "ship" ..
  And    ed.mode = "engine_slots" 
    Local ni% = data.find_nearest_engine( img_x, img_y )
    If ed.engine_lock_i <> - 1 Then ni = ed.engine_lock_i
    If ni <> -1
      Local engine:TStarfarerShipEngine = data.ship.engineSlots[ni]
      ang_relevant = True
      a = json.FormatDouble( calc_angle( engine.location[0], engine.location[1], img_x - data.ship.center[1], - ( img_y - data.ship.center[0] ) ), 1 )
    EndIf
  
  ElseIf ed.program_mode = "weapon" ..
  And ed.mode = "offsets"
    Local offsets#[]
    Select sub_set_weapon.weapon_display_mode
      Case "TURRET"
        offsets = data.weapon.turretOffsets
      Case "HARDPOINT"
        offsets = data.weapon.hardpointOffsets
    EndSelect
    If Not offsets
      a = "0.0"
    Else
      ang_relevant = True 
      Local slot_i% = data.find_nearest_weapon_offset(x.ToFloat(), y.ToFloat(), sub_set_weapon.weapon_display_mode)
      a = json.FormatDouble( calc_angle( offsets[slot_i], offsets[slot_i + 1], x.ToFloat(), - y.ToFloat() ), 1 )
    EndIf
  EndIf
  '  From Right to Left along bottom:
  Local dim_w:TextWidget = TextWidget.Create( w + " x " + h )
  Local pos_w:TextWidget = TextWidget.Create( x + "," + y)
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
  draw_string( pos_w, Int(1.2 * Float(W_MAX) / 5.0) + 20 + ico_w + 4, H_MAX - LINE_HEIGHT - 4 )
  'angle 
  If ang_relevant Then SetAlpha( 1.00 ) Else SetAlpha( 0.333 )
  DrawImage( ed.ico_ang,  Int(2.4*Float(W_MAX)/5.0)+20,        H_MAX - ico_h - 4 )
  draw_string( ang_w, Int(2.4 * Float(W_MAX) / 5.0) + 20 + ico_w + 4, H_MAX - LINE_HEIGHT - 4 )
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
      Case "skin"
        title_w = TextWidget.Create( data.skin.skinHullId + ".skin" )
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
      Case "weapon"
        title_w = TextWidget.Create( data.weapon.id + ".wpn" )
      Case "csv_weapon"
        If data.csv_row
          title_w = TextWidget.Create( "weapon_data.csv : " + String( data.csv_row_weapon.ValueForKey( "id" )))
        Else
          title_w = TextWidget.Create ( "weapon_data.csv" )
        EndIf
          
    EndSelect
    draw_string( title_w, 4, 4 )
  EndIf
EndFunction


Function load_ui( ed:TEditor )
  AutoMidHandle( True )
  'try to load custom_bg_image
  If Not App.custom_bg_image.length = 0
    ed.bg_image = LoadImage(App.custom_bg_image, FILTEREDIMAGE|MIPMAPPEDIMAGE)
    Else    
    ed.bg_image = LoadImage( "incbin::assets/bg.png", FILTEREDIMAGE | MIPMAPPEDIMAGE )
  EndIf
  ed.bg_scale = Max( W_MAX / Float(ed.bg_image.width), H_MAX / Float(ed.bg_image.height) )
  AutoMidHandle( False )
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
  ed.engineflame = LoadImage( "incbin::assets/engineflame32.png", FILTEREDIMAGE | MIPMAPPEDIMAGE )
  ed.engineflamecore = LoadImage( "incbin::assets/engineflamecore32.png", FILTEREDIMAGE | MIPMAPPEDIMAGE )  
  AutoMidHandle( True )
End Function

Function load_starfarer_data( ed:TEditor, data:TData )
  ed.initialize_stock_data_containers()
  load_known_multiselect_values( ed )
  If Not APP.hide_vanilla_data
    For Local j% = 0 Until STARFARER_CORE_DIR.length
      If 0 <> FileType( APP.starsector_base_dir+STARFARER_CORE_DIR[j] )
        DebugLogFile( " Loading STARFARER-CORE Data (Vanilla)" )
        load_stock_data( ed, data, APP.starsector_base_dir + STARFARER_CORE_DIR[j] + "/", True )
        Exit
      EndIf
    Next
  EndIf
  If APP.mod_dirs And APP.mod_dirs.length > 0
    For Local mod_dir$ = EachIn APP.mod_dirs
      DebugLogFile " Loading MOD Data: "+mod_dir
      load_stock_data( ed, data, mod_dir )
    Next
  EndIf
  
  'nuke the weapon drawer for a force reflash
' WD = New TWeaponDrawer
' GCCollect()
  Rem 'for initial data mining
  For Local set$ = EachIn ed.multiselect_values.Keys()
    For Local val$ = EachIn TMap(ed.multiselect_values.ValueForKey(set)).Keys()
      DebugLogFile( "~q"+set+"~q, ~q"+val+"~q")
    Next
  Next
  End
  EndRem
EndFunction

'data_dir$ should be either "starfarer-core/" or "mods/{ModDirectory}/"
Function load_stock_data( ed:TEditor, data:TData, data_dir$, vanilla% = False )

  Local stock_ships_dir$ =    data_dir+"data/hulls/"
  Local stock_variants_dir$ = data_dir+"data/variants/"
  Local stock_variants_fighters_dir$ = data_dir+"data/variants/fighters/"
  Local stock_variants_drones_dir$ = data_dir+"data/variants/drones/"
  Local stock_skins_dir$ =    data_dir+"data/hulls/skins/"
  Local stock_weapons_dir$ =  data_dir+"data/weapons/"
  Local stock_hullmods_dir$ = data_dir + "data/hullmods/"
  Local stock_config_dir$ = data_dir + "data/config/"
  '/////
  Local stock_ships_files$[] = LoadDir( stock_ships_dir )
  SetPointer(POINTER_WAIT)
  For Local stock_ship_file$ = EachIn stock_ships_files
    If ExtractExt( stock_ship_file ) <> "ship" Then Continue
    ed.load_stock_ship( stock_ships_dir, stock_ship_file )
  Next

  'modified for load all files in sub dir -D
  Local dirs$[]
  dirs = dirs + [stock_variants_dir]
  Local done% = False
  While Not done
	Local subdirs$[]
	Local files$[]
	For Local dir$ = EachIn dirs
		dirs = dirs[1..]
		files = LoadDir( dir)
		For Local file$ = EachIn files
'			Print file
'			Print dir + file
'			Print FileType( dir + file )
			If FileType( dir + file ) = FILETYPE_DIR Then subdirs :+ [(dir + file + "/")]
			If ExtractExt( file ) = "variant" Then ed.load_stock_variant( dir, file )
		Next
	Next
	If Not subdirs.length Then done = True Else dirs :+ subdirs
  Wend
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
  Local stock_skins_files$[] = LoadDir( stock_skins_dir )
  For Local stock_skin_file$ = EachIn stock_skins_files
    If ExtractExt( stock_skin_file ) <> "skin" Then Continue
    ed.load_stock_skin( stock_skins_dir, stock_skin_file )
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
  FlushEvent()
  SetPointer(POINTER_DEFAULT)   
End Function

Function resource_search$( relative_path$ )
  Local i%, path$
  'search known mod directories first
  For i = 0 Until APP.mod_dirs.length
    path = APP.mod_dirs[i] + relative_path
    If FILETYPE_FILE = FileType( path )
      Return path
    EndIf
  Next
  'fall back to searching vanilla data
  For i = 0 Until STARFARER_CORE_DIR.length
    path = APP.starsector_base_dir + STARFARER_CORE_DIR[i]+"/" + relative_path
    If FILETYPE_FILE = FileType( path )
      Return path
    EndIf
  Next
  Return Null
EndFunction

Function load_mod( ed:TEditor, data:TData )
  Local mod_dir$ = RequestDir( LocalizeString("{{wt_load_mod}}"), APP.starsector_base_dir )
  If FileType( mod_dir ) = FILETYPE_DIR
    mod_dir :+ "/"
    DebugLogFile " Loading MOD Data: " + mod_dir
    load_stock_data( ed, data, mod_dir )
    'add to autoloader
    APP.mod_dirs = APP.mod_dirs[..APP.mod_dirs.length + 1]
    APP.mod_dirs[APP.mod_dirs.length - 1] = mod_dir
    APP.Save()
  EndIf
  FlushEvent()
EndFunction

Function DebugLogFile( msg$ )
  Try
    WriteLine( DEBUG_LOG_FILE, CurrentDate() + " " + CurrentTime() + " :" + msg )
    DebugLog( msg )
  Catch ex$
  EndTry
EndFunction

Function RadioMenuArray ( i%, MenuArray:TGadget[])
  For Local j% = 0 Until MenuArray.Length
    If j = i Then   CheckMenu(MenuArray[j]) Else UncheckMenu(MenuArray[j])    
  Next
  mainMenuNeedUpdate = True
EndFunction

Function undo(ed:TEditor, data:TData, sprite:TSprite, redo% = False)
  Local snap:Tsnapshot
  'get and replace the sanpshot
  If Not redo 'undo   
    If Not data.snapshots_undo.IsEmpty()
      data.snapshots_redo.AddFirst(data.snapshot_curr)
      data.snapshot_curr = Tsnapshot (data.snapshots_undo.RemoveFirst() )
      snap = data.snapshot_curr
    Else If data.changed 'got init
      data.snapshots_redo.AddFirst(data.snapshot_curr)
      snap = data.snapshot_init
      data.snapshot_curr = Null
      data.changed = False
    EndIf 
  Else 'redo
    If Not data.snapshots_redo.IsEmpty()
      If data.snapshot_curr
        data.snapshots_undo.AddFirst(data.snapshot_curr)
      Else
        data.changed = True
      EndIf
      data.snapshot_curr = Tsnapshot (data.snapshots_redo.RemoveFirst() )
      snap = data.snapshot_curr
    EndIf
  EndIf
  'apply the change
  If Not snap Then Return
  data.snapshot_undoing = True
  If snap.json_str
    data.json_str = snap.json_str
    data.decode( data.json_str )
    data.json_view = data.columnize_text( data.json_str )
  EndIf
  If snap.json_str_variant
    data.json_str_variant = snap.json_str_variant
    data.decode_variant(data.json_str_variant)
  EndIf
  If snap.json_str_skin
    data.json_str_skin = snap.json_str_skin
    data.decode_skin(data.json_str_skin)
  EndIf
  If snap.csv_row
    data.csv_row = CopyMap(snap.csv_row)
  EndIf
  If snap.csv_row_wing
    data.csv_row_wing = CopyMap(snap.csv_row_wing)
  EndIf
  If snap.json_str_weapon
    data.json_str_weapon = snap.json_str_weapon
    data.decode_weapon(data.json_str_weapon)
  EndIf
  ed.program_mode = snap.program_mode
  ed.mode = snap.mode
  ed.last_mode = snap.last_mode
  data.snapshot_undoing = False
End Function

' specialized sorting functions requiring context that has to be global due to language limitations
  ' makes the same assumption as TData::get_hullmod_csv_ordnance_points 
Function compare_hullmod_ids%( h0:Object, h1:Object )
  Local ops0% = Int( data.get_hullmod_csv_ordnance_points( String(h0) ))
  Local ops1% = Int( data.get_hullmod_csv_ordnance_points( String(h1) ))
  Return (ops1 - ops0)
EndFunction


'Clean out the eventQueue, then return how many events we nuked
Function FlushEvent%()
  Local i% = 0
  While PollEvent()
    PollEvent()
    i:+ 1
  Wend
  Return i
End Function