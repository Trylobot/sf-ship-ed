Rem


STARSECTOR Modding Kit 2.8.0
	Former Starfarer ship data editor
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
Import Maxgui.MaxGUI
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

Include "src/functions_misc.bmx"
Include "src/drawing_misc.bmx"
'Include "src/instaquit.bmx"
Include "src/TextWidget.type.bmx"
Include "src/TKeyboardHelpWidget.type.bmx"
Include "src/TStarfarerShip.type.bmx"
Include "src/TStarfarerSkin.type.bmx"
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
Include "src/TSubroutine.type.bmx"
Include "src/TGenericCSVSubroutine.type.bmx"
Include "src/TModalPreviewAll.type.bmx"
Include "src/TModalSetShipCenter.type.bmx"
Include "src/TModalSetBounds.type.bmx"
Include "src/TModalSetShieldCenter.type.bmx"
Include "src/TModalSetWeaponSlots.type.bmx"
Include "src/TModalSetBuiltInWeapons.type.bmx"
Include "src/TModalSetBuiltInHullMods.type.bmx"
Include "src/TModalSetEngineSlots.type.bmx"
Include "src/TModalSetStringData.type.bmx"
Include "src/TModalLaunchBays.type.bmx"
Include "src/TModalSetVariant.type.bmx"
Include "src/TModalSetShipCSV.type.bmx"
Include "src/TModalSetWingCSV.type.bmx"
Include "src/TModalWeapon.type.bmx"
Include "src/Application.type.bmx"
Include "src/help.bmx"
Include "src/multiselect_values.bmx"
Include "src/TWeaponDrawer.bmx"
Include "src/TTextCoder.bmx"
Include "src/WeaponDataCSVFieldTemplate.bmx"
Include "src/TModalSetWeaponCSV.type.bmx"
Include "src/TModalShowMore.bmx"

Const MODE_SHIP_EDIT% = 1

'/////////////////////////////////////////////
'MARK init APP var
Global DEBUG_LOG_FILE:TStream = WriteStream( "sf-ship-ed.log" )
Global LOC:TMaxGuiLanguage
SetGraphicsDriver GLMax2DDriver()
AppTitle = "STARSECTOR Ship&Weapon Editor"
Global APP:Application = Application.Load()
Global Appruning% = True
Global W_MAX# = APP.window_size[0], W_MID# = W_MAX / 2.0
Global H_MAX# = APP.window_size[1], H_MID# = H_MAX / 2.0
Global FONT:TImageFont = Null
Global DATA_FONT:TImageFont = Null
Global LINE_HEIGHT% = APP.font_size + 1
Global DATA_LINE_HEIGHT% = APP.data_font_size
Global CODE_MODE% = 1' LATIN1
Global SHOW_MORE% = 0

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
json.error_level = 1
json.ext_logging_fn = DebugLogFile
json.formatted = True
json.formatted_array = True
json.empty_container_as_null = False
json.precision = 6
'Application
json.add_transform( "stringify_settings", "$hide_vanilla_data", json.XJ_CONVERT, "boolean" )
'TStarfarerShipWeapon
json.add_transform( "parse_ship", "$weaponSlots:array/:object/$type:string", json.XJ_RENAME, "type_" )
json.add_transform( "stringify_ship", "$weaponSlots:array/:object/$type_:string", json.XJ_RENAME, "type" )
json.add_transform( "stringify_ship", "$weaponSlots:array/:object/$position:array", json.XJ_DELETE,, predicate_omit_position )
json.add_transform( "stringify_ship", "$builtInWeapons:object", json.XJ_DELETE,, predicate_omit_if_empty_object )
json.add_transform( "stringify_ship", "$builtInMods:array", json.XJ_DELETE,, predicate_omit_if_empty_array )
json.add_transform( "stringify_ship", "$coversColor:string", json.XJ_DELETE,, predicate_omit_if_empty_string )
'TStarfarerVariant
json.add_transform( "stringify_variant", "$goalVariant", json.XJ_CONVERT, "boolean" )
'TStarfarerCustomEngineStyleSpec
json.add_transform( "parse_ship", "$engineSlots:array/:object/$styleSpec:object/$type:string", json.XJ_RENAME, "type_" )
json.add_transform( "stringify_ship", "$engineSlots:array/:object/$styleSpec:object/$type_:string", json.XJ_RENAME, "type" )
json.add_transform( "stringify_ship", "$engineSlots:array/:object/$styleSpec:object", json.XJ_DELETE,, predicate_omit_styleSpec )
json.add_transform( "stringify_ship", "$engineSlots:array/:object/$styleId:string", json.XJ_DELETE,, predicate_omit_styleId )
'TStarfarerCustomEngineStyleSpec
json.add_transform( "parse_CustomEngineStyle", "$engineSlots:array/:object/$styleSpec:object/$type:string", json.XJ_RENAME, "type_" )
'TStarfarerWeapon
json.add_transform( "parse_weapon", "$type:string", json.XJ_RENAME, "type_" )
json.add_transform( "stringify_weapon", "$type_:string", json.XJ_RENAME, "type" )
'TStarfarerWeapon for the booleans!
json.add_transform( "stringify_weapon", "$animateWhileFiring", json.XJ_CONVERT, "boolean" )
json.add_transform( "stringify_weapon", "$alwaysAnimate", json.XJ_CONVERT, "boolean" )
json.add_transform( "stringify_weapon", "$renderBelowAllWeapons", json.XJ_CONVERT, "boolean" )
json.add_transform( "stringify_weapon", "$showDamageWhenDecorative", json.XJ_CONVERT, "boolean" )
json.add_transform( "stringify_weapon", "$separateRecoilForLinkedBarrels", json.XJ_CONVERT, "boolean" )
json.add_transform( "stringify_weapon", "$interruptibleBurst", json.XJ_CONVERT, "boolean" )
json.add_transform( "stringify_weapon", "$autocharge", json.XJ_CONVERT, "boolean" )
json.add_transform( "stringify_weapon", "$requiresFullCharge", json.XJ_CONVERT, "boolean" )
json.add_transform( "stringify_weapon", "$beamFireOnlyOnFullCharge", json.XJ_CONVERT, "boolean" )
json.add_transform( "stringify_weapon", "$convergeOnPoint", json.XJ_CONVERT, "boolean" )
json.add_transform( "stringify_weapon", "$darkCore", json.XJ_CONVERT, "boolean" )
'TStarfarerWeapon specClass <> beam
json.add_transform( "stringify_weapon", "$fringeColor", json.XJ_DELETE,, predicate_omit_if_not_specClass_beam )
json.add_transform( "stringify_weapon", "$coreColor", json.XJ_DELETE,, predicate_omit_if_not_specClass_beam )
json.add_transform( "stringify_weapon", "$beamEffect:string", json.XJ_DELETE,, predicate_omit_if_not_specClass_beam )
json.add_transform( "stringify_weapon", "$beamFireOnlyOnFullCharge", json.XJ_DELETE,, predicate_omit_if_not_specClass_beam )
json.add_transform( "stringify_weapon", "$convergeOnPoint", json.XJ_DELETE,, predicate_omit_if_not_specClass_beam )
json.add_transform( "stringify_weapon", "$width:number", json.XJ_DELETE,, predicate_omit_if_not_specClass_beam )
json.add_transform( "stringify_weapon", "$textureScrollSpeed:number", json.XJ_DELETE,, predicate_omit_if_not_specClass_beam )
json.add_transform( "stringify_weapon", "$pixelsPerTexel:number", json.XJ_DELETE,, predicate_omit_if_not_specClass_beam )
json.add_transform( "stringify_weapon", "$hitGlowRadius:number", json.XJ_DELETE,, predicate_omit_if_not_specClass_beam )
json.add_transform( "stringify_weapon", "$darkCore", json.XJ_DELETE,, predicate_omit_if_not_specClass_beam )
json.add_transform( "stringify_weapon", "$collisionClass:string", json.XJ_DELETE,, predicate_omit_if_not_specClass_beam )
json.add_transform( "stringify_weapon", "$collisionClassByFighter:string", json.XJ_DELETE,, predicate_omit_if_not_specClass_beam )
json.add_transform( "stringify_weapon", "$pierceSet:array", json.XJ_DELETE,, predicate_omit_if_not_specClass_beam )
'TStarfarerWeapon specClass <> projectile
json.add_transform( "stringify_weapon", "$projectileSpecId:string", json.XJ_DELETE,, predicate_omit_if_not_specClass_projectile )
json.add_transform( "stringify_weapon", "$barrelMode:string", json.XJ_DELETE,, predicate_omit_if_not_specClass_projectile )
json.add_transform( "stringify_weapon", "$animationType:string", json.XJ_DELETE,, predicate_omit_if_not_specClass_projectile )
json.add_transform( "stringify_weapon", "$visualRecoil", json.XJ_DELETE,, predicate_omit_if_not_specClass_projectile )
json.add_transform( "stringify_weapon", "$separateRecoilForLinkedBarrels", json.XJ_DELETE,, predicate_omit_if_not_specClass_projectile )
json.add_transform( "stringify_weapon", "$interruptibleBurst", json.XJ_DELETE,, predicate_omit_if_not_specClass_projectile )
json.add_transform( "stringify_weapon", "$autocharge", json.XJ_DELETE,, predicate_omit_if_not_specClass_projectile )
json.add_transform( "stringify_weapon", "$requiresFullCharge", json.XJ_DELETE,, predicate_omit_if_not_specClass_projectile )
json.add_transform( "stringify_weapon", "$muzzleFlashSpec:object", json.XJ_DELETE,, predicate_omit_if_not_specClass_projectile )
json.add_transform( "stringify_weapon", "$smokeSpec:object", json.XJ_DELETE,, predicate_omit_if_not_specClass_projectile )
'TStarfarerWeapon can be removed if it is default
' string with default = ""
json.add_transform( "stringify_weapon", "$turretUnderSprite:string", json.XJ_DELETE,, predicate_omit_if_empty_string )
json.add_transform( "stringify_weapon", "$turretGunSprite:string", json.XJ_DELETE,, predicate_omit_if_empty_string )
json.add_transform( "stringify_weapon", "$turretGlowSprite:string", json.XJ_DELETE,, predicate_omit_if_empty_string )
json.add_transform( "stringify_weapon", "$hardpointUnderSprite:string", json.XJ_DELETE,, predicate_omit_if_empty_string )
json.add_transform( "stringify_weapon", "$hardpointGunSprite:string", json.XJ_DELETE,, predicate_omit_if_empty_string )
json.add_transform( "stringify_weapon", "$hardpointGlowSprite:string", json.XJ_DELETE,, predicate_omit_if_empty_string )
json.add_transform( "stringify_weapon", "$everyFrameEffect:string", json.XJ_DELETE,, predicate_omit_if_empty_string )
json.add_transform( "stringify_weapon", "$beamEffect:string", json.XJ_DELETE,, predicate_omit_if_empty_string )
json.add_transform( "stringify_weapon", "$fireSoundOne:string", json.XJ_DELETE,, predicate_omit_if_empty_string )
json.add_transform( "stringify_weapon", "$fireSoundTwo:string", json.XJ_DELETE,, predicate_omit_if_empty_string )
' number
json.add_transform( "stringify_weapon", "$numFrames:number", json.XJ_DELETE,, predicate_omit_if_single_frame )
json.add_transform( "stringify_weapon", "$frameRate:number", json.XJ_DELETE,, predicate_omit_if_single_frame )
json.add_transform( "stringify_weapon", "$visualRecoil:number", json.XJ_DELETE,, predicate_omit_if_equals_zero)
json.add_transform( "stringify_weapon", "$displayArcRadius:number", json.XJ_DELETE,, predicate_omit_if_equals_zero)
' array
json.add_transform( "stringify_weapon", "$pierceSet:array", json.XJ_DELETE,, predicate_omit_if_empty_array )
json.add_transform( "stringify_weapon", "$renderHints:array", json.XJ_DELETE,, predicate_omit_if_empty_array )
' object
json.add_transform( "stringify_weapon", "$muzzleFlashSpec:object", json.XJ_DELETE,, predicate_omit_if_no_muzzle_flash )
json.add_transform( "stringify_weapon", "$smokeSpec:object", json.XJ_DELETE,, predicate_omit_if_no_smoke )
json.add_transform( "stringify_weapon", "$glowColor", json.XJ_DELETE,, predicate_omit_if_no_glow )
' booleans
json.add_transform( "stringify_weapon", "$convergeOnPoint", json.XJ_DELETE,, predicate_omit_if_boolean_equals_FALSE)
json.add_transform( "stringify_weapon", "$darkCore", json.XJ_DELETE,, predicate_omit_if_boolean_equals_FALSE )
json.add_transform( "stringify_weapon", "$separateRecoilForLinkedBarrels", json.XJ_DELETE,, predicate_omit_if_boolean_equals_FALSE )
json.add_transform( "stringify_weapon", "$interruptibleBurst", json.XJ_DELETE,, predicate_omit_if_boolean_equals_FALSE )
json.add_transform( "stringify_weapon", "$autocharge", json.XJ_DELETE,, predicate_omit_if_boolean_equals_FALSE )
json.add_transform( "stringify_weapon", "$renderBelowAllWeapons", json.XJ_DELETE,, predicate_omit_if_boolean_equals_FALSE )
json.add_transform( "stringify_weapon", "$beamFireOnlyOnFullCharge", json.XJ_DELETE,, predicate_omit_if_boolean_equals_FALSE )
json.add_transform( "stringify_weapon", "$showDamageWhenDecorative", json.XJ_DELETE,, predicate_omit_if_boolean_equals_FALSE )
json.add_transform( "stringify_weapon", "$requiresFullCharge", json.XJ_DELETE,, predicate_omit_if_boolean_equals_TRUE )
json.add_transform( "stringify_weapon", "$animateWhileFiring", json.XJ_DELETE,, predicate_omit_if_boolean_equals_TRUE )
json.add_transform( "stringify_weapon", "$alwaysAnimate", json.XJ_DELETE,, predicate_omit_if_boolean_equals_TRUE )
' unknow things
json.add_transform( "stringify_weapon", "$specialWeaponGlowWidth:number", json.XJ_DELETE,, predicate_omit_if_equals_zero )
json.add_transform( "stringify_weapon", "$specialWeaponGlowHeight:number", json.XJ_DELETE,, predicate_omit_if_equals_zero )

'////////////////////////////////////////////////
'MARK Local var init

Global ed:TEditor = New TEditor
ed.show_help = True

Local sprite:TSprite = New TSprite
sprite.scale = ZOOM_LEVELS[ed.selected_zoom_level]
ed.target_sprite_scale = sprite.scale

Local data:TData = New TData
data.update()
data.update_variant()
data.update_weapon()



'////////////////////////////////////////////////
'MARK init help
load_help()
'MARK init UI
'TODO init UI
'file menu
Global fileMenu:TGadget[7]
fileMenu[0] = CreateMenu("{{m_file}}", 0, WindowMenu(MainWindow) )
fileMenu[1] = CreateMenu("{{m_file_new}}", 201, fileMenu[0], KEY_N, MODIFIER_CONTROL | MODIFIER_ALT)
CreateMenu"", 0, filemenu[0]
fileMenu[2] = CreateMenu("{{m_file_loadmod}}", 202, fileMenu[0], KEY_M)
fileMenu[3] = CreateMenu("{{m_file_loaddata}}", 203, fileMenu[0], KEY_D)
fileMenu[4] = CreateMenu("{{m_file_loadimg}}", 204, fileMenu[0], KEY_I)
CreateMenu"", 0, fileMenu[0]
fileMenu[5] = CreateMenu("{{m_file_save}}", 205, fileMenu[0], KEY_V)
CreateMenu"", 0, fileMenu[0]
fileMenu[6] = CreateMenu("{{m_file_exit}}", 206, fileMenu[0], KEY_F4, MODIFIER_ALT)
'mode menu
Global modeMenu:TGadget[7]
modemenu[0] = CreateMenu("{{m_mode}}", 0, WindowMenu(MainWindow) )
modemenu[1] = CreateMenu("{{m_mode_ship}}", 301, modemenu[0] , KEY_1)
modeMenu[2] = CreateMenu("{{m_mode_variant}}", 302, modeMenu[0] , KEY_2)
modeMenu[3] = CreateMenu("{{m_mode_shipstate}}", 303, modeMenu[0] , KEY_3)
modeMenu[4] = CreateMenu("{{m_mode_wing}}", 304, modeMenu[0] , KEY_4)
modeMenu[5] = CreateMenu("{{m_mode_weapon}}", 305, modeMenu[0] , KEY_5)
modeMenu[6] = CreateMenu("{{m_mode_weaponstate}}", 306, modeMenu[0] , KEY_6)
CheckMenu(modeMenu[1])
Rem

function menu
this is a little too complex
[0]root; [1]undo Ctrl+Z; [2]redo Ctrl+Y; [3]details T; [4]remove BACKSPACE; [5]exit ESCAPE[]
EndRem
Global functionMenu:TGadget[9]
functionMenu[0] = CreateMenu("{{m_function}}", 0, WindowMenu(MainWindow) )
functionMenu[1] = CreateMenu("{{m_function_undo}}", 401, functionMenu[0], KEY_Z, MODIFIER_CONTROL )
DisableMenu(functionMenu[1])
functionMenu[2] = CreateMenu("{{m_function_redo}}", 402, functionMenu[0], KEY_Y, MODIFIER_CONTROL )
DisableMenu(functionMenu[2])
CreateMenu"", 0, functionMenu[0]
functionMenu[3] = CreateMenu("{{m_function_details}}", 403, functionMenu[0], KEY_T )
functionMenu[4] = CreateMenu("{{m_function_remove}}", 404, functionMenu[0], KEY_BACKSPACE )
'Exit
functionMenu[5] = CreateMenu("{{m_function_exit}}", 405, functionMenu[0], KEY_ESCAPE )
functionMenu[6] = CreateMenu("{{m_function_zoom}}", 406, functionMenu[0] )
functionMenu[7] = CreateMenu("{{m_function_zoomin}}", 407, functionMenu[6], KEY_EQUALS, MODIFIER_CONTROL )
functionMenu[8] = CreateMenu("{{m_function_zoomout}}", 408, functionMenu[6], KEY_MINUS, MODIFIER_CONTROL )
CreateMenu"", 0, functionMenu[0]

'animateMene, dock on the end of functionMenu for now.
Global animateMenu:TGadget[5]
animateMenu[0] = CreateMenu("{{m_function_Animate}}", 460, functionMenu[0] )
animateMenu[1] = CreateMenu("{{m_function_Animate_play}}", 461, animateMenu[0], KEY_UP )
animateMenu[2] = CreateMenu("{{m_function_Animate_stop}}", 462, animateMenu[0], KEY_DOWN )
animateMenu[3] = CreateMenu("{{m_function_Animate_next}}", 463, animateMenu[0], KEY_LEFT )
animateMenu[4] = CreateMenu("{{m_function_Animate_back}}", 464, animateMenu[0], KEY_RIGHT )
'Sub Functions's that got switch
Global functionMenuSub:TGadget[][] = New TGadget[][5]
rebuildFunctionMenu(0)
'optionMenu
Global optionMenu:TGadget[12]
optionMenu[0] = CreateMenu("{{m_option}}", 0, WindowMenu(MainWindow) )
optionMenu[9] = CreateMenu("{{m_option_mirror}}", 501, optionMenu[0], KEY_SPACE )
optionMenu[10] = CreateMenu("{{m_option_vanilla}}", 501, optionMenu[0], KEY_TILDE )
CreateMenu"", 0, optionMenu[0]
optionMenu[1] = CreateMenu("{{m_option_help}}", 501, optionMenu[0], KEY_F1 )
optionMenu[2] = CreateMenu("{{m_option_json}}", 502, optionMenu[0], KEY_F2 )
optionMenu[3] = CreateMenu("{{m_option_guides}}", 503, optionMenu[0], KEY_F3 )
CreateMenu"", 0, optionMenu[0]
optionMenu[4] = CreateMenu("{{m_option_weapondrawer}}", 504, optionMenu[0], KEY_F5 )
optionMenu[5] = CreateMenu("{{m_option_playAnimate}}", 505, optionMenu[0], KEY_F6 )
optionMenu[6] = CreateMenu("{{m_option_stopAnimate}}", 506, optionMenu[0], KEY_F7 )
optionMenu[7] = CreateMenu("{{m_option_resetAnimate}}", 507, optionMenu[0], KEY_F8 )
CreateMenu"", 0, optionMenu[0]
'optionMenu[8] = CreateMenu("{{m_option_settings}}", 508, optionMenu[0] )
optionMenu[11] = CreateMenu("{{m_option_about}}", 510, optionMenu[0])
UpdateWindowMenu(MainWindow)
Global mainMenuNeedUpdate% = False

'Local testWindow:TGadget = CreateWindow("test", 0, 0, 400, 400, Null)
'Local MyText:TGadget = CreateTextArea(0, 0, 380, 360, testWindow)

'Global toolWindow:TGadget = CreateWindow("Mode, Tool, etc.", 0, 0, 200, 600, mainWindow, WINDOW_TITLEBAR | WINDOW_TOOL)
'Global TBtn_file:TGadget[4]
'	TBtn_file[0] = CreateButton("New Data", 10, 10, 90, 20, toolWindow, BUTTON_PUSH)
'	TBtn_file[1] = CreateButton("Save Data", 100, 10, 90, 20, toolWindow, BUTTON_PUSH)
'	TBtn_file[2] = CreateButton("Load Data", 10, 30, 90, 20, toolWindow, BUTTON_PUSH)
'	TBtn_file[3] = CreateButton("Load Img", 100, 30, 90, 20, toolWindow, BUTTON_PUSH)
'Global toolWindowCruY% = 30
'toolWindowCruY :+ 20
'Global modePanel:TGadget = CreatePanel(15, toolWindowCruY, 170, 150, toolWindow, PANEL_GROUP, "Mode Select")
'Global TBtn_mode:TGadget[5]
'	TBtn_mode[0] = CreateButton("Ship Edit Mode", 0, 10, ClientWidth(modePanel) - 10 , 20, modePanel, BUTTON_RADIO)
'	TBtn_mode[1] = CreateButton("Variant Edit Mode", 0, 30, ClientWidth(modePanel) - 10 , 20, modePanel, BUTTON_RADIO)
'	TBtn_mode[2] = CreateButton("CSV Edit Mode", 0, 50, ClientWidth(modePanel) - 10 , 20, modePanel, BUTTON_RADIO)
'	TBtn_mode[3] = CreateButton("Wing CSV Edit Mode", 0, 70, ClientWidth(modePanel) - 10 , 20, modePanel, BUTTON_RADIO)
'	TBtn_mode[4] = CreateButton("Weapon Edit Mode", 0, 90, ClientWidth(modePanel) - 10 , 20, modePanel, BUTTON_RADIO)
'	TBtn_mode[5] = CreateButton("Weapon CSV Edit Mode", 0, 110, ClientWidth(modePanel) - 10 , 20, modePanel, BUTTON_RADIO)
'SetButtonState( TBtn_mode[0], 1 )

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
Global sub_preview_all:TModalPreviewAll = New TModalPreviewAll
Global sub_set_ship_center:TModalSetShipCenter = New TModalSetShipCenter
Global sub_set_bounds:TModalSetBounds = New TModalSetBounds
Global sub_set_shield_center:TModalSetShieldCenter = New TModalSetShieldCenter
Global sub_set_weapon_slots:TModalSetWeaponSlots = New TModalSetWeaponSlots
Global sub_set_built_in_weapons:TModalSetBuiltInWeapons = New TModalSetBuiltInWeapons
Global sub_set_built_in_hullmods:TModalSetBuiltInHullMods = New TModalSetBuiltInHullMods
Global sub_set_engine_slots:TModalSetEngineSlots = New TModalSetEngineSlots
Global sub_string_data:TModalSetStringData = New TModalSetStringData
Global sub_launchbays:TModalLaunchBays = New TModalLaunchBays
Global sub_set_variant:TModalSetVariant = New TModalSetVariant
Global sub_ship_csv:TModalSetShipCSV = New TModalSetShipCSV
Global sub_wing_csv:TModalSetWingCSV = New TModalSetWingCSV
Global sub_weapon:TModalWeapon = New TModalWeapon
Global sub_weapon_csv:TModalSetWeaponCSV = New TModalSetWeaponCSV
Global sub_show_more:TModalShowMore = New TModalShowMore

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
	'TODO addting Events
	WaitEvent()
	'If EventID() <> EVENT_GADGETPAINT And EventID() <> EVENT_TIMERTICK Then Print CurrentEvent.ToString()
	If Not Appruning And EventID() <> EVENT_APPRESUME Then Continue
	Select EventID()
	Case EVENT_APPSUSPEND, EVENT_APPRESUME
		'freeze after lose focus
		Appruning = (EventID() = EVENT_APPRESUME)
		If Appruning
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
		'pass key event down when we are in string edit mode or so
			If check_sub_routines( ed, data, sprite) Then Continue
	Case EVENT_GADGETACTION , EVENT_MENUACTION
		'DebugLog (EventSource().ToString() )

		If EventSource() = optionMenu[11] Then Notify("STARSECTOR Ship&Weapon Editor ~nv2.8.0~n(Former Trylobot's ship editor) ~n ~nCreated by Trylobot ~nUpdated by Deathfly ~n~n" + LocalizeString("{{msg_localisation_credits}}") )

		check_zoom_and_pan( ed, data, sprite )
		If check_undo( ed, data, sprite ) Then Continue
		'skip most hotkeys when we are in string edit mode or so.
		If (ed.mode = "string_data" ..
		Or (ed.program_mode = "csv" And (sub_ship_csv.loaded_csv_id_list Or sub_ship_csv.csv_row_values) )..
		Or (ed.program_mode = "csv_wing" And (sub_wing_csv.loaded_csv_id_list Or sub_wing_csv.csv_row_values) ) ..
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
'	Case EVENT_MOUSEENTER, EVENT_MOUSELEAVE
'		mouseInRange = (EventID() = EVENT_MOUSEENTER)
'		If Not mouseInRange
'		ModKeyAndMouseKey = 0
'		EndIf
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
	Case EVENT_WINDOWCLOSE
		If EventSource() = MainWindow
			If data.changed
				If Confirm(LocalizeString("{{msg_unsaved_exit}}") ) Then End
			Else End			
			EndIf		
		EndIf
	Case EVENT_TIMERTICK
		RedrawGadget(Canvas)
	Case EVENT_GADGETPAINT
	
	
	If EventSource() = Canvas
		Cls
		'display string for mouse (usually context-help)
		mouse_str = ""		
		'update
		update_zoom(ed, data, sprite)
		updatUndo(data)
		sprite.update()
		update_menu ()		
'		Select ed.program_mode		
'		Case "csv"
'			sub_ship_csv.Update( ed, data, sprite )
'		Case "csv_wing"
'			sub_wing_csv.Update( ed, data, sprite )
'		Case "weapon"
'			sub_weapon.Update( ed, data, sprite )
'		Case "csv_weapon"
'			sub_weapon_csv.Update( ed, data, sprite )
'		End Select
		'update end

		'draw
		draw_bg( ed )
		draw_ship( ed, sprite )
		draw_weapons(ed, data, sprite, WD)			
		Select ed.program_mode			
			Case "ship"
				Select ed.mode
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
				Case "engine_slots"
					sub_set_engine_slots.Draw( ed, data, sprite )
				Case "launch_bays"
					sub_launchbays.Draw( ed, data, sprite )
				'Case "string_data"
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

			Case "weapon"
				sub_weapon.Draw( ed, data, sprite )	
			
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

		'draw_instaquit_progress( W_MAX, H_MAX )
		
		Flip( 1 )
		'darw end
	EndIf
	EndSelect
Until AppTerminate()


'//////////////////////////////////////////////////////////////////////////////
'//////////////////////////////////////////////////////////////////////////////
'/////// MARK MAIN LOOP END   /////////////////////////////////////////////////
'//////////////////////////////////////////////////////////////////////////////
'//////////////////////////////////////////////////////////////////////////////


If DEBUG_LOG_FILE
	CloseStream( DEBUG_LOG_FILE )
EndIf
End

'////////////////////////////////////////////////
'MARK Function set
'MARK GAlist check
'-----------------------
' Return true if the input EventSource(Object) hit the checkes, so we can skip the rest
Function check_file_menu%(ed:TEditor, data:TData, sprite:TSprite)
	Local hit% = True
	Select EventSource()
	Case fileMenu[1] 'new file
		If data.changed
			If Not Confirm(LocalizeString("{{msg_unsaved_open_new}}") ) Then Return	hit
		EndIf
		WD.restAllAnimes()
		Select ed.program_mode
		Case "ship" , "csv", "csv_wing"
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
		Case "weapon", "csv_weapon"
			data.weapon = New TStarfarerWeapon
			data.csv_row_weapon = weapon_data_csv_field_template.Copy()
			sprite.wpimg = Null
			data.update_weapon()
			data.changed = False
			data.snapshots_undo:TList = CreateList()
			data.snapshots_redo:TList = CreateList()
		EndSelect
	Case fileMenu[2] 'load mod
		load_mod( ed, data )
	Case fileMenu[3] 'load data
		If data.changed
			If Not Confirm(LocalizeString("{{msg_unsaved_open_new}}") ) Then Return	hit
		EndIf
		data.snapshot_inited = False
		Select ed.program_mode
		Case "ship"
			load_ship_data( ed, data, sprite )
		Case "variant"
			load_variant_data( ed, data, sprite )
		Case "csv"
			sub_ship_csv.Load( ed, data, sprite )
		Case "csv_wing"
			sub_wing_csv.Load( ed, data, sprite )
		Case "weapon"
			sub_weapon.Load( ed, data, sprite )
		Case "csv_weapon"
			sub_weapon_csv.Load( ed, data, sprite )
		EndSelect
		data.take_initshot()
		data.changed = False
	Case fileMenu[4] 'load image
		Select ed.program_mode
			Case "ship", "variant", "csv", "csv_wing"
			load_ship_image( ed, data, sprite )
		EndSelect
	Case fileMenu[5] 'save data
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
		Case "csv"	
			sub_ship_csv.Save( ed, data, sprite )
		Case "csv_wing"	
			sub_wing_csv.Save( ed, data, sprite )
		Case "weapon"
			sub_weapon.Save( ed, data, sprite )
		Case "csv_weapon"
			sub_weapon_csv.Save( ed, data, sprite )
		EndSelect
	Case fileMenu[6] 'exit
		EmitEvent(CreateEvent(EVENT_WINDOWCLOSE, MainWindow) )
	Default
		hit = False
	End Select
	Return hit
End Function
'-----------------------

' Return true if the input EventSource(Object) hit the checkes, so we can skip the rest
Function check_mode_menu%(ed:TEditor, data:TData, sprite:TSprite)
	Local hit% = True
	Select EventSource()
	Case modeMenu[1] 'm_mode_ship
		If ed.program_mode = "ship" Then Return True
		'if coming from variant editing, go right into weapons mode editing
		If ed.program_mode = "variant" Then ed.mode = "weapon_slots" Else ed.mode = "none"
		ed.last_mode = "none"
		ed.program_mode = "ship"
		ed.weapon_lock_i = - 1
		ed.field_i = 0
		RadioMenuArray( 1, modeMenu )
		rebuildFunctionMenu(0)
	Case modeMenu[2] 'm_mode_variant
		If ed.program_mode = "variant" Then Return True
		sub_set_variant.Activate( ed, data, sprite )
		RadioMenuArray( 2, modeMenu )
		rebuildFunctionMenu(1)
	Case modeMenu[3] 'm_mode_ship_state
		If ed.program_mode = "csv" Then Return True
		sub_ship_csv.Activate( ed, data, sprite )
		RadioMenuArray( 3, modeMenu )
		rebuildFunctionMenu(2)
	Case modeMenu[4] 'm_mode_wing
		If ed.program_mode = "csv_wing" Then Return True
		sub_wing_csv.Activate( ed, data, sprite )
		RadioMenuArray( 4, modeMenu )
		rebuildFunctionMenu(3)
	Case modeMenu[5] 'm_mode_weapon
		If ed.program_mode = "weapon" Then Return True
		sub_weapon.Activate( ed, data, sprite )
		RadioMenuArray( 5, modeMenu )
		rebuildFunctionMenu(4)
	Case modeMenu[6] 'm_mode_weapon_state
		If ed.program_mode = "csv_weapon" Then Return True
		sub_weapon_csv.Activate( ed, data, sprite )
		RadioMenuArray( 6, modeMenu )
		rebuildFunctionMenu(5)
	Default
		hit = False
	End Select
	updata_weapondrawermenu(ed)	
	Return hit
End Function


Function check_option_menu%(ed:TEditor, data:TData)
	Local hit% = True
	Select EventSource()
	Case optionMenu[1]
		ed.show_help = Not ed.show_help
	Case optionMenu[2]
		ed.show_data = Not ed.show_data
	Case optionMenu[3]
		ed.show_debug = Not ed.show_debug
		If ed.show_debug Then SetPointer(POINTER_CROSS) Else SetPointer(POINTER_DEFAULT)
	Case optionMenu[10]
		APP.hide_vanilla_data = Not APP.hide_vanilla_data
		load_starfarer_data( ed, data )
	Case optionMenu[9]
		ed.bounds_symmetrical = Not ed.bounds_symmetrical
	Default
		hit = False
	End Select
	Return hit
End Function

Function check_undo%(ed:TEditor, data:TData, sprite:TSprite)

	Local hit% = True
	Select EventSource()
	Case functionMenu[1]
	
	DebugStop
		undo(ed, data, sprite, False)
	Case functionMenu[2]
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
					And	( (ed.program_mode = "ship" And ( ed.mode = "built_in_weapons" Or ed.mode = "weapon_slots") ) ..
						Or (ed.program_mode = "variant" And ed.variant_hullMod_i = - 1 And ed.group_field_i = - 1)..
						Or (ed.program_mode = "weapon") ) )						
	If MenuEnabled(animateMenu[0]) <> flag
		For Local i# = 0 Until animateMenu.length
			animateMenu[i].SetEnabled(flag)
		Next
		mainMenuNeedUpdate = True
	EndIf
End Function

Function updatUndo(data:TData)
	If (data.snapshots_undo.IsEmpty() And Not data.changed) = MenuEnabled(functionMenu[1])
		functionMenu[1].setenabled(Not (data.snapshots_undo.IsEmpty() And Not data.changed) )
		mainMenuNeedUpdate = True

	EndIf
	If (data.snapshots_redo.IsEmpty() ) = MenuEnabled(functionMenu[2])
		functionMenu[2].setenabled(Not data.snapshots_redo.IsEmpty() )
		mainMenuNeedUpdate = True
	EndIf

End Function


Function check_function_menu% ( ed:TEditor, data:TData, sprite:TSprite )
	Local hit% = True
	Select ed.program_mode
	Case "ship"
		Select EventSource()
		Case functionMenu[5] 'exit
			ed.last_mode = ed.mode
			ed.mode = "none"
			ed.field_i = 0	
		Case functionMenuSub[0][0] 'mass center
			sub_set_ship_center.Activate( ed, data, sprite )
		Case functionMenuSub[0][1] 'shield center
			sub_set_shield_center.Activate( ed, data, sprite )
		Case functionMenuSub[0][2] 'bounds
			sub_set_bounds.Activate( ed, data, sprite )
		Case functionMenuSub[0][3] 'weapon slots
			sub_set_weapon_slots.Activate( ed, data, sprite )
		Case functionMenuSub[0][4], functionMenuSub[0][5] 'built-in or decorate weapon mode, check it in Activate later
			sub_set_built_in_weapons.Activate( ed, data, sprite )
		Case functionMenuSub[0][6] 'built in hullmods
			sub_set_built_in_hullmods.Activate( ed, data, sprite )
		Case functionMenuSub[0][7] 'engine slots
			sub_set_engine_slots.Activate( ed, data, sprite )
		Case functionMenuSub[0][8] 'launch bays
			sub_launchbays.Activate( ed, data, sprite )
		Case functionMenuSub[0][9] 'preview
			sub_preview_all.Activate( ed, data, sprite )
		Case functionMenuSub[0][10] 'show more
			sub_show_more.Activate( ed, data, sprite )
		Case functionMenu[3] 'string edit
			sub_string_data.Activate( ed, data, sprite )
		Default
			hit = False
		EndSelect
	Case "variant"
		Select EventSource()
		Case functionMenuSub[1][8]
			load_variant_data( ed, data, sprite, True ) 'strip all	
		Case functionMenu[3]
			sub_string_data.Activate( ed, data, sprite ) 'string edit
		Case functionMenuSub[1][9] 'show more
			sub_show_more.Activate( ed, data, sprite )
		Default
			hit = False
		EndSelect
	Case "weapon"
		Select EventSource()
		Case functionMenu[3]
			sub_string_data.Activate( ed, data, sprite ) 'string edit
		Default
			hit = False
		EndSelect
	Default
		hit = False
	End Select
	updata_weapondrawermenu(ed)
	Return hit
End Function

Function check_sub_routines% ( ed:TEditor, data:TData, sprite:TSprite )
	Local hit% = True
	Select ed.program_mode
	Case "ship"
		Select ed.mode
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
		Case "engine_slots"
			sub_set_engine_slots.Update( ed, data, sprite )
		Case "launch_bays"
			sub_launchbays.Update( ed, data, sprite )
		Case "string_data"
			sub_string_data.Update( ed, data, sprite )
		Case "preview_all"
			sub_preview_all.Update( ed, data, sprite )
		End Select		
	Case "variant"
		Select ed.mode
		Case "normal"
			sub_set_variant.Update( ed, data, sprite )
		Case "string_data"
			sub_string_data.Update( ed, data, sprite )
		EndSelect		
	Case "csv"
		sub_ship_csv.Update( ed, data, sprite )
	Case "csv_wing"
		sub_wing_csv.Update( ed, data, sprite )
	Case "weapon"
		Select ed.mode
		Case "string_data"
			sub_string_data.Update( ed, data, sprite )
		Default
			sub_weapon.Update( ed, data, sprite )			
		EndSelect
	Case "csv_weapon"
		sub_weapon_csv.Update( ed, data, sprite )
	Default
		hit = False
	End Select
	Return hit
End Function

'Function check_mode( ed:TEditor, data:TData, sprite:TSprite )
'	If ed.program_mode = "ship"
'		'If not selecting a weapon for a built-in slot, check ESCAPE key
'		If Not( ed.mode = "built_in_weapons" And ed.weapon_lock_i <> - 1 ) ..
'		.. 'And Not(ed.mode = "built_in_hullmods" AND ed.builtIn_hullmod_i <> -1 ) ..
'		And (KeyHit( KEY_ESCAPE ) Or KeyHit( KEY_HOME ) )
'			ed.last_mode = ed.mode
'			ed.mode = "none"
'			ed.field_i = 0
'		EndIf
'		If KeyHit( KEY_B )
'			sub_set_bounds.Activate( ed, data, sprite )
'		EndIf
'		If KeyHit( KEY_E )
'			sub_set_engine_slots.Activate( ed, data, sprite )
'		EndIf
'		If KeyHit( KEY_W )
'			sub_set_weapon_slots.Activate( ed, data, sprite )
'		EndIf
'		If KeyHit( KEY_U )
'			sub_set_built_in_weapons.Activate( ed, data, sprite )
'		EndIf
'		If KeyHit( KEY_H )
'			sub_set_built_in_hullmods.Activate( ed, data, sprite )
'		EndIf
'		If KeyHit( KEY_L )
'			sub_launchbays.Activate( ed, data, sprite )
'		EndIf
'		If KeyHit( KEY_P )
'			sub_preview_all.Activate( ed, data, sprite )
'		End If
'		
'	ElseIf ed.program_mode = "variant"
'		If KeyHit( KEY_SLASH )
'			load_variant_data( ed, data, sprite, True )
'		EndIf
'	EndIf
'
'	'STRING data editor, context-sensitive (has sub-object target)
'	'TODO: move this to TSubroutines
'	If ed.program_mode = "ship" ..
'	Or ed.program_mode = "variant" ..
'	Or ed.program_mode = "weapon"
'		If KeyHit( KEY_T )
'			ed.last_mode = ed.mode
'			ed.mode = "string_data"
'			FlushKeys()
'			ed.edit_strings_weapon_i = -1
'			ed.edit_strings_engine_i = -1
'			If sprite 'context-sensitive editing
'				Local img_x#, img_y#
'				sprite.get_img_xy( MouseX, MouseY, img_x, img_y )
'				If ed.last_mode = "weapon_slots"
'					ed.edit_strings_weapon_i = data.find_nearest_weapon_slot( img_x, img_y )
'				ElseIf ed.last_mode = "engine_slots"
'					ed.edit_strings_engine_i = data.find_nearest_engine( img_x, img_y )
'				EndIf
'			EndIf
'			sub_string_data.Activate( ed, data, sprite )
'		EndIf
'	EndIf
'End Function

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
				Case functionMenu[7] ' = CreateMenu("{{m_function_zoomin}}", 407, functionMenu[6], KEY_EQUALS, MODIFIER_CONTROL )
					z_delta :+ 1
				Case functionMenu[8] ' = CreateMenu("{{m_function_zoomout}}", 408, functionMenu[6], KEY_MINUS, MODIFIER_CONTROL )
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
		'	Local ship_c_x%, ship_c_y%
		'	sprite.xform_ship_c_to_scr( data.ship.center, ship_c_x, ship_c_y )
		'	'''sprite.zpan_x :+ MouseX - ship_c_x
		'	'''sprite.zpan_y :+ MouseY - ship_c_y
		'	ed.target_zpan_x :- MouseX - ship_c_x
		'	ed.target_zpan_y :- MouseY - ship_c_y
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
	'	sprite.zpan_x :- (sprite.sx + sprite.sw)
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

Function draw_ship( ed:TEditor, sprite:TSprite )
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
		If ed.mode = "weapon_slots" ..
		Or ed.mode = "built_in_weapons" ..
		Or ed.mode = "built_in_hullmods" ..
		Or ed.mode = "launch_bays" ..
		Or ed.mode = "string_data" ..
		Or ed.program_mode = "variant" ..
		Or ed.program_mode = "csv" ..
		Or ed.program_mode = "csv_wing" ..
		Or ed.program_mode = "csv_weapon"
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
		Local reference:TImage
		Select ed.program_mode
		Case "ship", "variant", "csv", "csv_wing"
			reference = sprite.img
		Case "weapon", "csv_weapon"
			reference = sprite.wpimg
			draw_crosshairs(sprite.asx + sub_weapon.xOffset * sprite.scale, sprite.asy, 6, True)
		End Select
		If Not reference Then Return
		Local img_x#, img_y#
		sprite.get_img_xy( MouseX, MouseY, img_x, img_y, False )
		Local col# = RoundFloat(img_x - 0.5, 1)
		Local row# = RoundFloat(img_y - 0.5, 1)
		'draw row, col indicators
		SetRotation( 0 )
		SetScale( 1, 1 )
		SetColor( 255, 255, 255 )
		If col >= 0 And col < reference.height And row >= 0 And row < reference.width
			SetAlpha( 0.25 )
			If col > 0 Then DrawRect( sprite.sx, sprite.sy + Float(row) * sprite.scale, Float(col) * sprite.scale, sprite.scale )
			If col < reference.height - 1 Then DrawRect( sprite.sx + Float(col + 1) * sprite.scale, sprite.sy + Float(row) * sprite.scale, Float(reference.height - 1 - col) * sprite.scale, sprite.scale )
			If row > 0 Then DrawRect( sprite.sx + Float(col)*sprite.scale, sprite.sy, sprite.scale, Float(row)*sprite.scale )
			If row < reference.width - 1 Then DrawRect( sprite.sx + Float(col) * sprite.scale, sprite.sy + Float(row + 1) * sprite.scale, sprite.scale, Float(reference.width - 1 - row) * sprite.scale )
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
	Else
		sprite.get_xy( MouseX, MouseY, img_x, img_y )
		If sprite.wpimg Then w = "" + sprite.wpimg.width Else w = "N/a"
		If sprite.wpimg Then h = "" + sprite.wpimg.height Else h = "N/a"
		x = json.FormatDouble( img_x - sub_weapon.xOffset , 1 )
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
		Select sub_weapon.weapon_display_mode
			Case "TURRET"
				offsets = data.weapon.turretOffsets
			Case "HARDPOINT"
				offsets = data.weapon.hardpointOffsets
		EndSelect
		If Not offsets
			a = "0.0"
		Else
			ang_relevant = True	
			Local slot_i% = data.find_nearest_weapon_offset(x.ToFloat(), y.ToFloat(), sub_weapon.weapon_display_mode)
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

Function draw_weapons( ed:TEditor, data:TData, sprite:TSprite, wd:TWeaponDrawer )

	wd.update( ed, data )	
	If wd.show_weapon = 0 Then Return
	SetColor( 255, 255, 255 )
	If wd.show_weapon = 1 Then SetAlpha( 1 )
	If wd.show_weapon = 2 Then SetAlpha( 0.5 )
	Select ed.program_mode
		Case "ship"
			For Local i% = 0 Until data.ship.weaponSlots.length * 6
				Local j% = i Mod data.ship.weaponSlots.length
				Local k% = i / data.ship.weaponSlots.length
				Local weaponslot:TStarfarerShipWeapon = data.ship.weaponSlots[j]
				If weaponslot.is_builtin() Or weaponslot.is_decorative()
					Local weaponID$ = String(data.ship.builtInWeapons.ValueForKey(weaponslot.id) )
					Local weapon:TStarfarerWeapon = TStarfarerWeapon (ed.stock_weapons.ValueForKey(weaponID) )
					If weapon And weapon.draw_order() + weaponslot.draw_order() = k Then wd.draw_weaponInSlot(weaponslot, weapon, data, sprite)
				EndIf
			Next		
		Case "variant"
			Local weapons:TMap = data.variant.getAllWeapons()
			For Local i% = 0 Until data.ship.weaponSlots.length * 6
				Local j% = i Mod data.ship.weaponSlots.length
				Local k% = i / data.ship.weaponSlots.length
				Local weaponslot:TStarfarerShipWeapon = data.ship.weaponSlots[j]
				'well, I did the null check later so don't needs in these part...i hope
				Local weaponID$
				If data.ship.builtInWeapons.ValueForKey(weaponslot.id)
					weaponID = String(data.ship.builtInWeapons.ValueForKey(weaponslot.id))
				Else 
					weaponID  = String(weapons.ValueForKey(weaponslot.id)) ' could be null but it's ok
				End If
				Local weapon:TStarfarerWeapon = TStarfarerWeapon (ed.stock_weapons.ValueForKey(weaponID)) ' could be null but it's ok
				If weapon And weapon.draw_order() + weaponslot.draw_order() = k Then wd.draw_weaponInSlot(weaponslot, weapon, data, sprite)
			Next		
	EndSelect
	SetAlpha( 1 )
End Function

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
'	WD = New TWeaponDrawer
'	GCCollect()
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
	FlushEvent()
	SetPointer(POINTER_DEFAULT)		
End Function

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

Function autoload_ship_image( ed:TEditor, data:TData, sprite:TSprite )
	Local img_path$ = resource_search( data.ship.spriteName )
	If img_path <> Null
		load_ship_image__driver( ed, data, sprite, img_path )
	EndIf
EndFunction

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

Function load_variant_data( ed:TEditor, data:TData, sprite:TSprite, use_new% = False, data_path$ = Null )
	'VARIANT data
	If Not use_new
		Local variant_path$ = RequestFile( LocalizeString("{{wt_load_variant}}"), "variant", False, APP.variant_dir )
		FlushKeys()
		If FileType( variant_path ) <> FILETYPE_FILE Then Return
		APP.variant_dir = ExtractDir( variant_path ) + "/"
		APP.save()
		data.decode_variant( LoadTextAs( variant_path, CODE_MODE ) )
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
		
	Catch ex$
	EndTry
EndFunction



Function RadioMenuArray ( i%, MenuArray:TGadget[])
	For Local j% = 0 Until MenuArray.Length
		If j = i Then 	CheckMenu(MenuArray[j])	Else UncheckMenu(MenuArray[j])		
	Next
	mainMenuNeedUpdate = True
EndFunction

Rem
'hind and disable menu in a hacky way
Function MenuSetHidden(menu:TGadget, hidden%, parent:TGadget = Null)
	If hidden
		menu.SetEnabled(False)
		menu.parent = Null
	Else
		menu.SetEnabled(True)
		menu.parent = parent
	EndIf
	mainMenuNeedUpdate = True
End Function

'hind and disable menus array in a hacky way.
Function MenusArraySetHidden(menusArray:TGadget[], hidden%, parent:TGadget = Null)
	For Local i% = 0 Until menusArray.Length
		MenuSetHidden(menusArray[i], hidden, parent)
	Next
EndFunction

'hind and disable other menus arrays while enable the selected one 
Function RadioMenuArrayArray ( i%, MenuArrayArray:TGadget[][], parent:TGadget = Null)
	For Local j% = 0 Until MenuArrayArray.Length
		If j = i Then MenusArraySetHidden(MenuArrayArray[j], False, parent) Else MenusArraySetHidden(MenuArrayArray[j], True, parent)
	Next
EndFunction
EndRem

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

'Clean out the eventQueue, then return how many events we nuked
Function FlushEvent%()
	Local i% = 0
	While PollEvent()
		PollEvent()
		i:+ 1
	Wend
	Return i
End Function


Function rebuildFunctionMenu(index%)
	'nuke them first
	For Local i:TGadget[] = EachIn functionMenuSub
		For Local j:TGadget = EachIn i
			FreeGadget(j)
		Next
	Next
	'then rebuile it
	Select Index
	Case 0
		'mode 1 Functions
		functionMenuSub[0] = New TGadget[11]
		functionMenuSub[0][0] = CreateMenu("{{m_function_center}}", 410, functionMenu[0], KEY_C )
		functionMenuSub[0][1] = CreateMenu("{{m_function_shield}}", 411, functionMenu[0], KEY_S )
		functionMenuSub[0][2] = CreateMenu("{{m_function_bounds}}", 412, functionMenu[0], KEY_B )
		functionMenuSub[0][3] = CreateMenu("{{m_function_weaponSlots}}", 413, functionMenu[0], KEY_W )
		functionMenuSub[0][4] = CreateMenu("{{m_function_builtInWeapons}}", 414, functionMenu[0], KEY_U )
		functionMenuSub[0][5] = CreateMenu("{{m_function_decorate}}", 415, functionMenu[0], KEY_R )
		functionMenuSub[0][6] = CreateMenu("{{m_function_builtInHullmods}}", 416, functionMenu[0], KEY_H )
		functionMenuSub[0][7] = CreateMenu("{{m_function_engine}}", 417, functionMenu[0], KEY_E )
		functionMenuSub[0][8] = CreateMenu("{{m_function_launchBays}}", 418, functionMenu[0], KEY_L )
		functionMenuSub[0][9] = CreateMenu("{{m_function_preview}}", 419, functionMenu[0], KEY_P )
		functionMenuSub[0][10] = CreateMenu("{{m_function_more}}", 420, functionMenu[0], KEY_Q )
	Case 1
		'mode 2 Functions
		functionMenuSub[1] = New TGadget[10]
		functionMenuSub[1][0] = CreateMenu("{{m_function_WeaponGroups}}", 420, functionMenu[0], KEY_G )
		functionMenuSub[1][1] = CreateMenu("{{m_function_vent}}", 421, functionMenu[0] )
		functionMenuSub[1][2] = CreateMenu("{{m_function_vent_add}}", 4210, functionMenuSub[1][1], KEY_F )	
		functionMenuSub[1][3] = CreateMenu("{{m_function_vent_remove}}", 4211, functionMenuSub[1][1], KEY_F, MODIFIER_CONTROL)		
		functionMenuSub[1][4] = CreateMenu("{{m_function_cap}}", 422, functionMenu[0])
		functionMenuSub[1][5] = CreateMenu("{{m_function_cap_add}}", 4220, functionMenuSub[1][4], KEY_C)
		functionMenuSub[1][6] = CreateMenu("{{m_function_cap_remove}}", 4221, functionMenuSub[1][4], KEY_C, MODIFIER_CONTROL)		
		functionMenuSub[1][7] = CreateMenu("{{m_function_hullmod}}", 423, functionMenu[0], KEY_H )
		functionMenuSub[1][8] = CreateMenu("{{m_function_stripAll}}", 424, functionMenu[0], KEY_SLASH )
		functionMenuSub[1][9] = CreateMenu("{{m_function_more}}", 420, functionMenu[0], KEY_Q )
	'mode 3 Functions skip
	'mode 4 Functions skip
	'mode 5 Functions
	Case 4
		functionMenuSub[4] = New TGadget[8]
		functionMenuSub[4][0] = CreateMenu("{{m_function_weapon_offsets}}", 450, functionMenu[0], KEY_O )
		functionMenuSub[4][1] = CreateMenu("{{m_function_weapon_displaymode}}", 451, functionMenu[0], KEY_H )
		functionMenuSub[4][2] = CreateMenu("{{m_function_wpimg_main}}", 452, fileMenu[4], KEY_A )	
		functionMenuSub[4][3] = CreateMenu("{{m_function_wpimg_barrel}}", 453, fileMenu[4], KEY_G)		
		functionMenuSub[4][4] = CreateMenu("{{m_function_wpimg_under}}", 454, fileMenu[4], KEY_U)
		functionMenuSub[4][5] = CreateMenu("{{m_function_wpimg_glow}}", 455, fileMenu[4], KEY_L)
		functionMenuSub[4][6] = CreateMenu("{{m_function_weapon_glowtoggle}}", 455, functionMenu[0], KEY_W)			
	End Select
End Function
