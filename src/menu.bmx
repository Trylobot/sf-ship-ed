'////////////////////////////////////////////////
'function menu
'  this is a little too complex. 

'You're right, it is. Try assigning symbolic names to these magical fucking numbers, for starters.
' - T

Global mainMenuNeedUpdate% = False

Local s% = 0
Global MENU_FILE% = s; s:+1
Global MENU_FILE_NEW% = s; s:+1
Global MENU_FILE_LOAD_MOD% = s; s:+1
Global MENU_FILE_LOAD_DATA% = s; s:+1
Global MENU_FILE_LOAD_IMAGE% = s; s:+1
Global MENU_FILE_SAVE% = s; s:+1
Global MENU_FILE_EXIT% = s; s:+1
Global fileMenu:TGadget[s];
s = 0
Global MENU_MODE% = s; s:+1
Global MENU_MODE_SHIP% = s; s:+1
Global MENU_MODE_VARIANT% = s; s:+1
Global MENU_MODE_SKIN% = s; s:+1
Global MENU_MODE_SHIPSTATS% = s; s:+1
Global MENU_MODE_WING% = s; s:+1
Global MENU_MODE_WEAPON% = s; s:+1
Global MENU_MODE_WEAPONSTATS% = s; s:+1
'Global MENU_MODE_PROJECTILE% = s; s:+1
Global modeMenu:TGadget[s]
s = 0
Global MENU_FUNCTION% = s; s:+1
Global MENU_FUNCTION_UNDO% = s; s:+1
Global MENU_FUNCTION_REDO% = s; s:+1
Global MENU_FUNCTION_DETAILS% = s; s:+1
Global MENU_FUNCTION_REMOVE% = s; s:+1
Global MENU_FUNCTION_EXIT% = s; s:+1
Global MENU_FUNCTION_ZOOM% = s; s:+1
Global MENU_FUNCTION_ZOOMIN% = s; s:+1
Global MENU_FUNCTION_ZOOMOUT% = s; s:+1
Global functionMenu:TGadget[s]
s = 0
Global MENU_ANIMATE% = s; s:+1
Global MENU_ANIMATE_PLAY% = s; s:+1
Global MENU_ANIMATE_STOP% = s; s:+1
Global MENU_ANIMATE_NEXT% = s; s:+1
Global MENU_ANIMATE_BACK% = s; s:+1
Global animateMenu:TGadget[s]
s = 0
Global MENU_OPTION% = s; s:+1
Global MENU_OPTION_HELP% = s; s:+1
Global MENU_OPTION_JSON% = s; s:+1
Global MENU_OPTION_GUIDES% = s; s:+1
Global MENU_OPTION_WEAPONDRAWER% = s; s:+1
Global MENU_OPTION_PLAYANIMATE% = s; s:+1
Global MENU_OPTION_STOPANIMATE% = s; s:+1
Global MENU_OPTION_RESETANIMATE% = s; s:+1
Global MENU_OPTION_SETTINGS% = s; s:+1
Global MENU_OPTION_MIRROR% = s; s:+1
Global MENU_OPTION_VANILLA% = s; s:+1
Global MENU_OPTION_ABOUT% = s; s:+1
Global optionMenu:TGadget[s]

s = 0
Global MENU_SUBFUNCTION_SHIP_CENTER% = s; s:+1
Global MENU_SUBFUNCTION_SHIP_SHIELD% = s; s:+1
Global MENU_SUBFUNCTION_SHIP_BOUNDS% = s; s:+1
Global MENU_SUBFUNCTION_SHIP_WEAPONSLOTS% = s; s:+1
Global MENU_SUBFUNCTION_SHIP_BUILTINWEAPONS% = s; s:+1
Global MENU_SUBFUNCTION_SHIP_DECORATIVE% = s; s:+1
Global MENU_SUBFUNCTION_SHIP_BUILTINHULLMODS% = s; s:+1
Global MENU_SUBFUNCTION_SHIP_BUILTINWINGS% = s; s:+1
Global MENU_SUBFUNCTION_SHIP_ENGINE% = s; s:+1
Global MENU_SUBFUNCTION_SHIP_LAUNCHBAYS% = s; s:+1
Global MENU_SUBFUNCTION_SHIP_PREVIEW% = s; s:+1
Global MENU_SUBFUNCTION_SHIP_MORE% = s; s:+1
Global MENUSIZE_MENU_SUBFUNCTION_SHIP_____% = s
s = 0
Global MENU_SUBFUNCTION_VARIANT_WEAPONGROUPS% = s; s:+1
Global MENU_SUBFUNCTION_VARIANT_WINGS% = s; s:+1
Global MENU_SUBFUNCTION_VARIANT_VENT% = s; s:+1
Global MENU_SUBFUNCTION_VARIANT_VENT_ADD% = s; s:+1
Global MENU_SUBFUNCTION_VARIANT_VENT_REMOVE% = s; s:+1
Global MENU_SUBFUNCTION_VARIANT_CAP% = s; s:+1
Global MENU_SUBFUNCTION_VARIANT_CAP_ADD% = s; s:+1
Global MENU_SUBFUNCTION_VARIANT_CAP_REMOVE% = s; s:+1
Global MENU_SUBFUNCTION_VARIANT_HULLMOD% = s; s:+1
Global MENU_SUBFUNCTION_VARIANT_STRIPALL% = s; s:+1
Global MENU_SUBFUNCTION_VARIANT_MORE% = s; s:+1
Global MENUSIZE_MENU_SUBFUNCTION_VARIANT_____% = s
s = 0
Global MENU_SUBFUNCTION_SKIN_CHANGEREMOVE_WEAPONSLOTS% = s; s:+1
Global MENU_SUBFUNCTION_SKIN_ADDREMOVE_BUILTIN_WEAPONS% = s; s:+1
Global MENU_SUBFUNCTION_SKIN_CHANGEREMOVE_ENGINES% = s; s:+1
Global MENU_SUBFUNCTION_SKIN_ADDREMOVE_BUILTIN_HULLMODS% = s; s:+1
Global MENU_SUBFUNCTION_SKIN_ADDREMOVE_HINTS% = s; s:+1
Global MENU_SUBFUNCTION_SKIN_MORE% = s; s:+1
Global MENUSIZE_MENU_SUBFUNCTION_SKIN_____% = s
s = 0
Global MENU_SUBFUNCTION_WEAPON_WEAPON_OFFSETS% = s; s:+1
Global MENU_SUBFUNCTION_WEAPON_WEAPON_DISPLAYMODE% = s; s:+1
Global MENU_SUBFUNCTION_WEAPON_WPIMG_MAIN% = s; s:+1
Global MENU_SUBFUNCTION_WEAPON_WPIMG_BARREL% = s; s:+1
Global MENU_SUBFUNCTION_WEAPON_WPIMG_UNDER% = s; s:+1
Global MENU_SUBFUNCTION_WEAPON_WPIMG_GLOW% = s; s:+1
Global MENU_SUBFUNCTION_WEAPON_WEAPON_GLOWTOGGLE% = s; s:+1
Global MENUSIZE_MENU_SUBFUNCTION_WEAPON_____% = s
s = 0

Global functionMenuSub:TGadget[][] = New TGadget[][modeMenu.length]


Function init_gui_menus()
  'file menu
  fileMenu[MENU_FILE] = CreateMenu("{{m_file}}", 0, WindowMenu(MainWindow) )
  fileMenu[MENU_FILE_NEW] = CreateMenu("{{m_file_new}}", 201, fileMenu[MENU_FILE], KEY_N, MODIFIER_CONTROL | MODIFIER_ALT)
  CreateMenu"", 0, filemenu[MENU_FILE]
  fileMenu[MENU_FILE_LOAD_MOD] = CreateMenu("{{m_file_loadmod}}", 202, fileMenu[MENU_FILE], KEY_M)
  fileMenu[MENU_FILE_LOAD_DATA] = CreateMenu("{{m_file_loaddata}}", 203, fileMenu[MENU_FILE], KEY_D)
  fileMenu[MENU_FILE_LOAD_IMAGE] = CreateMenu("{{m_file_loadimg}}", 204, fileMenu[MENU_FILE], KEY_I)
  CreateMenu"", 0, fileMenu[MENU_FILE]
  fileMenu[MENU_FILE_SAVE] = CreateMenu("{{m_file_save}}", 205, fileMenu[MENU_FILE], KEY_V)
  CreateMenu"", 0, fileMenu[MENU_FILE]
  fileMenu[MENU_FILE_EXIT] = CreateMenu("{{m_file_exit}}", 206, fileMenu[MENU_FILE], KEY_F4, MODIFIER_ALT)
  'mode menu
  modemenu[MENU_MODE] = CreateMenu("{{m_mode}}", 0, WindowMenu(MainWindow) )
  modemenu[MENU_MODE_SHIP] = CreateMenu("{{m_mode_ship}}", 301, modemenu[MENU_MODE] , KEY_1)
  modeMenu[MENU_MODE_VARIANT] = CreateMenu("{{m_mode_variant}}", 302, modemenu[MENU_MODE] , KEY_2)
  modeMenu[MENU_MODE_SKIN] = CreateMenu("{{m_mode_skin}}", 303, modemenu[MENU_MODE] , KEY_3)
  modeMenu[MENU_MODE_SHIPSTATS] = CreateMenu("{{m_mode_shipstate}}", 303, modemenu[MENU_MODE] , KEY_4)
  modeMenu[MENU_MODE_WING] = CreateMenu("{{m_mode_wing}}", 304, modemenu[MENU_MODE] , KEY_5)
  modeMenu[MENU_MODE_WEAPON] = CreateMenu("{{m_mode_weapon}}", 305, modemenu[MENU_MODE] , KEY_6)
  modeMenu[MENU_MODE_WEAPONSTATS] = CreateMenu("{{m_mode_weaponstate}}", 306, modemenu[MENU_MODE] , KEY_7)
  CheckMenu(modemenu[MENU_MODE_SHIP])
  '[0]root; [1]undo Ctrl+Z; [2]redo Ctrl+Y; [3]details T; [4]remove BACKSPACE; [5]exit ESCAPE[]
  functionMenu[MENU_FUNCTION] = CreateMenu("{{m_function}}", 0, WindowMenu(MainWindow) )
  functionMenu[MENU_FUNCTION_UNDO] = CreateMenu("{{m_function_undo}}", 401, functionMenu[MENU_FUNCTION], KEY_Z, MODIFIER_CONTROL )
  DisableMenu(functionMenu[MENU_FUNCTION_UNDO])
  functionMenu[MENU_FUNCTION_REDO] = CreateMenu("{{m_function_redo}}", 402, functionMenu[MENU_FUNCTION], KEY_Y, MODIFIER_CONTROL )
  DisableMenu(functionMenu[MENU_FUNCTION_REDO])
  CreateMenu"", 0, functionMenu[MENU_FUNCTION]
  functionMenu[MENU_FUNCTION_DETAILS] = CreateMenu("{{m_function_details}}", 403, functionMenu[MENU_FUNCTION], KEY_T )
  functionMenu[MENU_FUNCTION_REMOVE] = CreateMenu("{{m_function_remove}}", 404, functionMenu[MENU_FUNCTION], KEY_BACKSPACE )
  'Exit
  functionMenu[MENU_FUNCTION_EXIT] = CreateMenu("{{m_function_exit}}", 405, functionMenu[MENU_FUNCTION], KEY_ESCAPE )
  functionMenu[MENU_FUNCTION_ZOOM] = CreateMenu("{{m_function_zoom}}", 406, functionMenu[MENU_FUNCTION] )
  functionMenu[MENU_FUNCTION_ZOOMIN] = CreateMenu("{{m_function_zoomin}}", 407, functionMenu[MENU_FUNCTION_ZOOM], KEY_EQUALS, MODIFIER_CONTROL )
  functionMenu[MENU_FUNCTION_ZOOMOUT] = CreateMenu("{{m_function_zoomout}}", 408, functionMenu[MENU_FUNCTION_ZOOM], KEY_MINUS, MODIFIER_CONTROL )
  CreateMenu"", 0, functionMenu[MENU_FUNCTION]
  'animateMene, dock on the end of functionMenu for now.
  animateMenu[MENU_ANIMATE] = CreateMenu("{{m_function_Animate}}", 460, functionMenu[MENU_FUNCTION] )
  animateMenu[MENU_ANIMATE_PLAY] = CreateMenu("{{m_function_Animate_play}}", 461, animateMenu[MENU_ANIMATE], KEY_UP )
  animateMenu[MENU_ANIMATE_STOP] = CreateMenu("{{m_function_Animate_stop}}", 462, animateMenu[MENU_ANIMATE], KEY_DOWN )
  animateMenu[MENU_ANIMATE_NEXT] = CreateMenu("{{m_function_Animate_next}}", 463, animateMenu[MENU_ANIMATE], KEY_LEFT )
  animateMenu[MENU_ANIMATE_BACK] = CreateMenu("{{m_function_Animate_back}}", 464, animateMenu[MENU_ANIMATE], KEY_RIGHT )
  'Sub Functions's that got switch
  'optionMenu
  optionMenu[MENU_OPTION] = CreateMenu("{{m_option}}", 0, WindowMenu(MainWindow) )
  CreateMenu"", 0, optionMenu[MENU_OPTION]
  optionMenu[MENU_OPTION_HELP] = CreateMenu("{{m_option_help}}", 501, optionMenu[MENU_OPTION], KEY_F1 )
  optionMenu[MENU_OPTION_JSON] = CreateMenu("{{m_option_json}}", 502, optionMenu[MENU_OPTION], KEY_F2 )
  optionMenu[MENU_OPTION_GUIDES] = CreateMenu("{{m_option_guides}}", 503, optionMenu[MENU_OPTION], KEY_F3 )
  CreateMenu"", 0, optionMenu[MENU_OPTION]
  optionMenu[MENU_OPTION_WEAPONDRAWER] = CreateMenu("{{m_option_weapondrawer}}", 504, optionMenu[MENU_OPTION], KEY_F5 )
  optionMenu[MENU_OPTION_PLAYANIMATE] = CreateMenu("{{m_option_playAnimate}}", 505, optionMenu[MENU_OPTION], KEY_F6 )
  optionMenu[MENU_OPTION_STOPANIMATE] = CreateMenu("{{m_option_stopAnimate}}", 506, optionMenu[MENU_OPTION], KEY_F7 )
  optionMenu[MENU_OPTION_RESETANIMATE] = CreateMenu("{{m_option_resetAnimate}}", 507, optionMenu[MENU_OPTION], KEY_F8 )
  CreateMenu"", 0, optionMenu[MENU_OPTION]
  'optionMenu[MENU_OPTION_SETTINGS] = CreateMenu("{{m_option_settings}}", 508, optionMenu[MENU_OPTION] )
  optionMenu[MENU_OPTION_MIRROR] = CreateMenu("{{m_option_mirror}}", 501, optionMenu[MENU_OPTION], KEY_SPACE )
  optionMenu[MENU_OPTION_VANILLA] = CreateMenu("{{m_option_vanilla}}", 501, optionMenu[MENU_OPTION], KEY_TILDE )
  optionMenu[MENU_OPTION_ABOUT] = CreateMenu("{{m_option_about}}", 510, optionMenu[MENU_OPTION])

  UpdateWindowMenu(MainWindow)

  'Local testWindow:TGadget = CreateWindow("test", 0, 0, 400, 400, Null)
  'Local MyText:TGadget = CreateTextArea(0, 0, 380, 360, testWindow)
  'Global toolWindow:TGadget = CreateWindow("Mode, Tool, etc.", 0, 0, 200, 600, mainWindow, WINDOW_TITLEBAR | WINDOW_TOOL)
  'Global TBtn_file:TGadget[4]
  ' TBtn_file[0] = CreateButton("New Data", 10, 10, 90, 20, toolWindow, BUTTON_PUSH)
  ' TBtn_file[1] = CreateButton("Save Data", 100, 10, 90, 20, toolWindow, BUTTON_PUSH)
  ' TBtn_file[2] = CreateButton("Load Data", 10, 30, 90, 20, toolWindow, BUTTON_PUSH)
  ' TBtn_file[3] = CreateButton("Load Img", 100, 30, 90, 20, toolWindow, BUTTON_PUSH)
  'Global toolWindowCruY% = 30
  'toolWindowCruY :+ 20
  'Global modePanel:TGadget = CreatePanel(15, toolWindowCruY, 170, 150, toolWindow, PANEL_GROUP, "Mode Select")
  'Global TBtn_mode:TGadget[5]
  ' TBtn_mode[0] = CreateButton("Ship Edit Mode", 0, 10, ClientWidth(modePanel) - 10 , 20, modePanel, BUTTON_RADIO)
  ' TBtn_mode[1] = CreateButton("Variant Edit Mode", 0, 30, ClientWidth(modePanel) - 10 , 20, modePanel, BUTTON_RADIO)
  ' TBtn_mode[2] = CreateButton("CSV Edit Mode", 0, 50, ClientWidth(modePanel) - 10 , 20, modePanel, BUTTON_RADIO)
  ' TBtn_mode[3] = CreateButton("Wing CSV Edit Mode", 0, 70, ClientWidth(modePanel) - 10 , 20, modePanel, BUTTON_RADIO)
  ' TBtn_mode[4] = CreateButton("Weapon Edit Mode", 0, 90, ClientWidth(modePanel) - 10 , 20, modePanel, BUTTON_RADIO)
  ' TBtn_mode[5] = CreateButton("Weapon CSV Edit Mode", 0, 110, ClientWidth(modePanel) - 10 , 20, modePanel, BUTTON_RADIO)
  'SetButtonState( TBtn_mode[0], 1 )
EndFunction

Function rebuildFunctionMenu(index%)
  For Local i:TGadget[] = EachIn functionMenuSub
    For Local j:TGadget = EachIn i
      FreeGadget(j)
    Next
  Next
  'rebuild it
  Select Index
    Case MENU_MODE_SHIP
      functionMenuSub[MENU_MODE_SHIP] = New TGadget[MENUSIZE_MENU_SUBFUNCTION_SHIP_____]
      functionMenuSub[MENU_MODE_SHIP][MENU_SUBFUNCTION_SHIP_CENTER] = CreateMenu("{{m_function_center}}", 410, functionMenu[MENU_FUNCTION], KEY_C )
      functionMenuSub[MENU_MODE_SHIP][MENU_SUBFUNCTION_SHIP_SHIELD] = CreateMenu("{{m_function_shield}}", 411, functionMenu[MENU_FUNCTION], KEY_S )
      functionMenuSub[MENU_MODE_SHIP][MENU_SUBFUNCTION_SHIP_BOUNDS] = CreateMenu("{{m_function_bounds}}", 412, functionMenu[MENU_FUNCTION], KEY_B )
      functionMenuSub[MENU_MODE_SHIP][MENU_SUBFUNCTION_SHIP_WEAPONSLOTS] = CreateMenu("{{m_function_weaponSlots}}", 413, functionMenu[MENU_FUNCTION], KEY_W )
      functionMenuSub[MENU_MODE_SHIP][MENU_SUBFUNCTION_SHIP_BUILTINWEAPONS] = CreateMenu("{{m_function_builtInWeapons}}", 414, functionMenu[MENU_FUNCTION], KEY_U )
      functionMenuSub[MENU_MODE_SHIP][MENU_SUBFUNCTION_SHIP_DECORATIVE] = CreateMenu("{{m_function_decorate}}", 415, functionMenu[MENU_FUNCTION], KEY_R )
      functionMenuSub[MENU_MODE_SHIP][MENU_SUBFUNCTION_SHIP_BUILTINHULLMODS] = CreateMenu("{{m_function_builtInHullmods}}", 416, functionMenu[MENU_FUNCTION], KEY_H )
      functionMenuSub[MENU_MODE_SHIP][MENU_SUBFUNCTION_SHIP_BUILTINWINGS] = CreateMenu("{{m_function_builtInWings}}", 421, functionMenu[MENU_FUNCTION], KEY_N )
      functionMenuSub[MENU_MODE_SHIP][MENU_SUBFUNCTION_SHIP_ENGINE] = CreateMenu("{{m_function_engine}}", 417, functionMenu[MENU_FUNCTION], KEY_E )
      functionMenuSub[MENU_MODE_SHIP][MENU_SUBFUNCTION_SHIP_LAUNCHBAYS] = CreateMenu("{{m_function_launchBays}}", 418, functionMenu[MENU_FUNCTION], KEY_L )
      functionMenuSub[MENU_MODE_SHIP][MENU_SUBFUNCTION_SHIP_PREVIEW] = CreateMenu("{{m_function_preview}}", 419, functionMenu[MENU_FUNCTION], KEY_P )
      functionMenuSub[MENU_MODE_SHIP][MENU_SUBFUNCTION_SHIP_MORE] = CreateMenu("{{m_function_more}}", 420, functionMenu[MENU_FUNCTION], KEY_Q )
    Case MENU_MODE_VARIANT
      functionMenuSub[MENU_MODE_VARIANT] = New TGadget[MENUSIZE_MENU_SUBFUNCTION_VARIANT_____]
      functionMenuSub[MENU_MODE_VARIANT][MENU_SUBFUNCTION_VARIANT_WEAPONGROUPS] = CreateMenu("{{m_function_WeaponGroups}}", 450, functionMenu[MENU_FUNCTION], KEY_G )
      functionMenuSub[MENU_MODE_VARIANT][MENU_SUBFUNCTION_VARIANT_WINGS] = CreateMenu("{{m_function_wings}}", 456, functionMenu[MENU_FUNCTION], KEY_N )
      functionMenuSub[MENU_MODE_VARIANT][MENU_SUBFUNCTION_VARIANT_VENT] = CreateMenu("{{m_function_vent}}", 451, functionMenu[MENU_FUNCTION] )
      functionMenuSub[MENU_MODE_VARIANT][MENU_SUBFUNCTION_VARIANT_VENT_ADD] = CreateMenu("{{m_function_vent_add}}", 4518, functionMenuSub[MENU_MODE_VARIANT][MENU_SUBFUNCTION_VARIANT_VENT], KEY_F )  
      functionMenuSub[MENU_MODE_VARIANT][MENU_SUBFUNCTION_VARIANT_VENT_REMOVE] = CreateMenu("{{m_function_vent_remove}}", 4512, functionMenuSub[MENU_MODE_VARIANT][MENU_SUBFUNCTION_VARIANT_VENT], KEY_F, MODIFIER_CONTROL)
      functionMenuSub[MENU_MODE_VARIANT][MENU_SUBFUNCTION_VARIANT_CAP] = CreateMenu("{{m_function_cap}}", 452, functionMenu[MENU_FUNCTION])
      functionMenuSub[MENU_MODE_VARIANT][MENU_SUBFUNCTION_VARIANT_CAP_ADD] = CreateMenu("{{m_function_cap_add}}", 4528, functionMenuSub[MENU_MODE_VARIANT][MENU_SUBFUNCTION_VARIANT_CAP], KEY_C)
      functionMenuSub[MENU_MODE_VARIANT][MENU_SUBFUNCTION_VARIANT_CAP_REMOVE] = CreateMenu("{{m_function_cap_remove}}", 4522, functionMenuSub[MENU_MODE_VARIANT][MENU_SUBFUNCTION_VARIANT_CAP], KEY_C, MODIFIER_CONTROL)   
      functionMenuSub[MENU_MODE_VARIANT][MENU_SUBFUNCTION_VARIANT_HULLMOD] = CreateMenu("{{m_function_hullmod}}", 453, functionMenu[MENU_FUNCTION], KEY_H )
      functionMenuSub[MENU_MODE_VARIANT][MENU_SUBFUNCTION_VARIANT_STRIPALL] = CreateMenu("{{m_function_stripAll}}", 454, functionMenu[MENU_FUNCTION], KEY_SLASH )
      functionMenuSub[MENU_MODE_VARIANT][MENU_SUBFUNCTION_VARIANT_MORE] = CreateMenu("{{m_function_more}}", 455, functionMenu[MENU_FUNCTION], KEY_Q )
    Case MENU_MODE_SKIN
      functionMenuSub[MENU_MODE_SKIN] = New TGadget[MENUSIZE_MENU_SUBFUNCTION_SKIN_____]
      functionMenuSub[MENU_MODE_SKIN][MENU_SUBFUNCTION_SKIN_CHANGEREMOVE_WEAPONSLOTS] = CreateMenu("{{m_function_skin_changeremove_weaponslots}}", 600, functionMenu[MENU_FUNCTION], KEY_W )
      functionMenuSub[MENU_MODE_SKIN][MENU_SUBFUNCTION_SKIN_ADDREMOVE_BUILTIN_WEAPONS] = CreateMenu("{{m_function_skin_addremove_builtin_weapons}}", 601, functionMenu[MENU_FUNCTION], KEY_B )
      functionMenuSub[MENU_MODE_SKIN][MENU_SUBFUNCTION_SKIN_CHANGEREMOVE_ENGINES] = CreateMenu("{{m_function_skin_changeremove_engines}}", 602, functionMenu[MENU_FUNCTION], KEY_E )
      functionMenuSub[MENU_MODE_SKIN][MENU_SUBFUNCTION_SKIN_ADDREMOVE_BUILTIN_HULLMODS] = CreateMenu("{{m_function_skin_addremove_builtin_hullmods}}", 603, functionMenu[MENU_FUNCTION], KEY_H )
      functionMenuSub[MENU_MODE_SKIN][MENU_SUBFUNCTION_SKIN_ADDREMOVE_HINTS] = CreateMenu("{{m_function_skin_addremove_hints}}", 604, functionMenu[MENU_FUNCTION], KEY_A )
      functionMenuSub[MENU_MODE_SKIN][MENU_SUBFUNCTION_SKIN_MORE] = CreateMenu("{{m_function_skin_show_more}}", 605, functionMenu[MENU_FUNCTION], KEY_Q )
    Case MENU_MODE_WEAPON
      functionMenuSub[MENU_MODE_WEAPON] = New TGadget[MENUSIZE_MENU_SUBFUNCTION_WEAPON_____]
      functionMenuSub[MENU_MODE_WEAPON][MENU_SUBFUNCTION_WEAPON_WEAPON_OFFSETS] = CreateMenu("{{m_function_weapon_offsets}}", 500, functionMenu[MENU_FUNCTION], KEY_O )
      functionMenuSub[MENU_MODE_WEAPON][MENU_SUBFUNCTION_WEAPON_WEAPON_DISPLAYMODE] = CreateMenu("{{m_function_weapon_displaymode}}", 501, functionMenu[MENU_FUNCTION], KEY_H )
      functionMenuSub[MENU_MODE_WEAPON][MENU_SUBFUNCTION_WEAPON_WPIMG_MAIN] = CreateMenu("{{m_function_wpimg_main}}", 502, fileMenu[MENU_FILE_LOAD_IMAGE], KEY_A ) 
      functionMenuSub[MENU_MODE_WEAPON][MENU_SUBFUNCTION_WEAPON_WPIMG_BARREL] = CreateMenu("{{m_function_wpimg_barrel}}", 503, fileMenu[MENU_FILE_LOAD_IMAGE], KEY_G)    
      functionMenuSub[MENU_MODE_WEAPON][MENU_SUBFUNCTION_WEAPON_WPIMG_UNDER] = CreateMenu("{{m_function_wpimg_under}}", 504, fileMenu[MENU_FILE_LOAD_IMAGE], KEY_U)
      functionMenuSub[MENU_MODE_WEAPON][MENU_SUBFUNCTION_WEAPON_WPIMG_GLOW] = CreateMenu("{{m_function_wpimg_glow}}", 505, fileMenu[MENU_FILE_LOAD_IMAGE], KEY_L)
      functionMenuSub[MENU_MODE_WEAPON][MENU_SUBFUNCTION_WEAPON_WEAPON_GLOWTOGGLE] = CreateMenu("{{m_function_weapon_glowtoggle}}", 506, functionMenu[MENU_FUNCTION], KEY_W)     
  End Select
EndFunction

