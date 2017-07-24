Type TWeaponDrawer		
		
	Field show_weapon% = 1
	Field buffed_img:TMap 'String (img_path) --> TImage
	Field buffed_img_seq:TMap ' String (img_0_path) --> TImage[]
	Field animes:TMap 'String  (weaponSlotId) --> TAnime
	Field playingAnime% = 0
	Field _needCheckPlaying% = False
	Field weaponEditorAnime:TAnime
	Field renderQueue:TList 'TWeaponRenderData
	
	Method New()
		buffed_img = CreateMap()
		buffed_img_seq = CreateMap()
		animes = CreateMap()	
		renderQueue = CreateList()
	End Method
	
	' do not support module on module yet
	Method queue_module_weapons(renderQueue:TList Var, weapon_slot:TStarfarerShipWeapon, variantID$, data:TData, sprite:TSprite)
		Local variant_tem:TStarfarerVariant = TStarfarerVariant( ed.stock_variants.ValueForKey( variantID ) )
		If Not variant_tem Then Return
		Local hullID_tem$ = variant_tem.hullId
		Local skin_tem:TStarfarerSkin = TStarfarerSkin(ed.stock_skins.ValueForKey( hullID_tem ) )
		If skin_tem Then hullID_tem = skin_tem.baseHullId
		Local ship_tem:TStarfarerShip = TStarfarerShip(ed.stock_ships.ValueForKey(hullID_tem) )
		If Not ship_tem Then Return
		Local x# = weapon_slot.locations[0]
		Local y# = weapon_slot.locations[1]
		Local facing# = weapon_slot.angle
		Local variantRenderData:TWeaponRenderData = New TWeaponRenderData
		variantRenderData.inti_for_module(weapon_slot, variant_tem)
		variantRenderData.set_facing_and_offset(x, y, facing)
		renderQueue.AddLast(variantRenderData)
		Local weapons:TMap = variant_tem.getAllWeapons()
			For Local i% = 0 Until ship_tem.weaponSlots.length
				Local weaponslot:TStarfarerShipWeapon = ship_tem.weaponSlots[i]
				'well, I did the null check later so don't needs in these part...i hope
				Local weaponID$
				weaponID = String(weapons.ValueForKey(weaponslot.id) ) 'load from weapon groups frist
				If Not weaponID Then weaponID = String(ship_tem.builtInWeapons.ValueForKey(weaponslot.id) ) 'then, try the built-in list
				Local weapon:TStarfarerWeapon = TStarfarerWeapon (ed.stock_weapons.ValueForKey(weaponID) ) ' could be null but it's ok
				If weapon
					Local renderData:TWeaponRenderData = New TWeaponRenderData
					renderData.init(weaponslot, weapon)
					renderData.set_facing_and_offset(x, y, facing)
					renderData.set_is_station_module_weapon()
					renderQueue.AddLast(renderData)
				EndIf
			Next
	End Method
	
	Method draw_all_weapons( mode$, data:TData, sprite:TSprite )
		Select mode
			
			Case "ship", "skin"
				For Local i% = 0 Until data.ship.weaponSlots.length
					Local weaponslot:TStarfarerShipWeapon
					If mode = "ship"
						weaponslot = data.ship.weaponSlots[i]
					ElseIf mode = "skin"
						weaponslot = data.get_merged_skin_weaponslot(i)
					EndIf
					If weaponslot.is_builtin() Or weaponslot.is_decorative()
						Local weaponID$
						If mode = "ship"
							weaponID = String(data.ship.builtInWeapons.ValueForKey(weaponslot.id) )
						ElseIf mode = "skin"
							weaponID = data.get_skin_equipped_builtin_weapon_id(weaponslot.id)
						EndIf
						Local weapon:TStarfarerWeapon = TStarfarerWeapon (ed.stock_weapons.ValueForKey(weaponID) )
						If weapon
							Local renderData:TWeaponRenderData = New TWeaponRenderData
							renderData.init(weaponslot, weapon)
							renderQueue.AddLast(renderData)	
						EndIf
					EndIf
				Next
			
			Case "variant"
				Local weapons:TMap = data.variant.getAllWeapons()
				For Local i% = 0 Until data.ship.weaponSlots.length
					Local weaponslot:TStarfarerShipWeapon = data.ship.weaponSlots[i]
					'well, I did the null check later so don't needs in these part...i hope
					Local weaponID$
					weaponID = String(weapons.ValueForKey(weaponslot.id) ) 'load from weapon groups frist
					If Not weaponID Then weaponID = String(data.ship.builtInWeapons.ValueForKey(weaponslot.id) ) 'then, try the built-in list
					If weaponID
						If weaponslot.type_ <> "STATION_MODULE"
							Local weapon:TStarfarerWeapon = TStarfarerWeapon (ed.stock_weapons.ValueForKey(weaponID) ) ' could be null but it's ok
							If weapon
								Local renderData:TWeaponRenderData = New TWeaponRenderData
								renderData.init(weaponslot, weapon)
								renderQueue.AddLast(renderData)	
							EndIf
						Else
							queue_module_weapons(renderQueue, weaponslot, weaponID, data, sprite)
						EndIf
					EndIf
				Next
			
		EndSelect
		renderQueue.Sort()
		For Local d:TWeaponRenderData = EachIn renderQueue
			If d.weapon
				draw_weaponInSlot(d.weaponSlot, d.weapon, data, sprite, d.x_offset, d.y_offset, d.facing)
			Else If d.variant
				draw_variantInSlot(d.weaponSlot, d.variant, data, sprite, d.x_offset, d.y_offset)
			EndIf			
		Next
		renderQueue.Clear()
	End Method
	
	Method update(ed:TEditor, data:TData)
		If _needCheckPlaying Then playingAnime = 0
		If ed.program_mode = "weapon"
			If weaponEditorAnime Then weaponEditorAnime.update()
			If _needCheckPlaying Then playingAnime = 1
		Else
			Local weapons:TMap = data.variant.getAllWeapons()
			For Local anime:TAnime = EachIn MapValues( animes )
				If anime.weaponSlot_i > data.ship.weaponSlots.length - 1 Or data.ship.weaponSlots[anime.weaponSlot_i].id <> anime.weaponSlot_id 'slot removed
					MapRemove(animes, anime.weaponSlot_id)
				Else
					Local inSlotWeapon_id$
					If data.ship.builtInWeapons.ValueForKey(anime.weaponSlot_id)
						inSlotWeapon_id = String(data.ship.builtInWeapons.ValueForKey(anime.weaponSlot_id) )
					Else If ed.program_mode = "variant" And weapons.ValueForKey( anime.weaponSlot_id )
						inSlotWeapon_id = String( weapons.ValueForKey(anime.weaponSlot_id) )
					Else
						MapRemove(animes, anime.weaponSlot_id) ' weapon removed
					EndIf
					If inSlotWeapon_id
						If anime.weapon_id <> inSlotWeapon_id 'weapon changed
							MapRemove(animes, anime.weaponSlot_id)
						Else
							anime.update()
							If _needCheckPlaying And anime.isPlaying Then playingAnime :+ 1
						End If
					EndIf
				End If
			Next
		EndIf
		_needCheckPlaying = False
	End Method
	
	'key hooks
	Method check(ed:TEditor, data:TData)
		'Global setting keys that needs always work
		Select EventID()
		Case EVENT_GADGETACTION, EVENT_MENUACTION
			Select EventSource()
			Case optionMenu[MENU_OPTION_WEAPONDRAWER]
				switchDraw()
			Case optionMenu[MENU_OPTION_PLAYANIMATE]
				setAllAnimes( True, ed, data )
				_needCheckPlaying = True
			Case optionMenu[MENU_OPTION_STOPANIMATE]
				setAllAnimes( False, ed, data )
				playingAnime = 0
			Case optionMenu[MENU_OPTION_RESETANIMATE]
				restAllAnimes()
				playingAnime = 0			
			EndSelect
		EndSelect
		'individual animate control should only work in some modes
		Select ed.program_mode
			Case "ship"
				Select ed.mode
				Case "weapon_slots"
				animeControl(sub_set_weapon_slots.ni, ed, data)
				Case "built_in_weapons"
				animeControl(sub_set_built_in_weapons.ni, ed, data)
				End Select
			Case "variant"
				animeControl(sub_set_variant.ni, ed, data)
			Case "weapon"
				If ed.mode <> "string_data" Then animeControl(0, ed, data)
		EndSelect			
	End Method
	

	Method animeControl(weaponSlot_i%, ed:TEditor, data:TData)
		Select EventID()
		Case EVENT_GADGETACTION, EVENT_MENUACTION
			Local anime:TAnime
			If ed.program_mode = "weapon"
				If Not weaponEditorAnime Then initAnime( 0, ed, data )
				anime = weaponEditorAnime
			Else
				anime = getAnimeForSlot_i(weaponSlot_i, ed, data)
			EndIf
			If anime
				Select EventSource()
				Case animateMenu[MENU_ANIMATE_PLAY] ' = CreateMenu("{{m_function_Animate_play}}", 461, animateMenu[0], KEY_UP )
					_needCheckPlaying = True
					anime.isPlaying = True
				Case animateMenu[MENU_ANIMATE_STOP] ' = CreateMenu("{{m_function_Animate_stop}}", 462, animateMenu[0], KEY_DOWN )
					_needCheckPlaying = True
					anime.isPlaying = False
				Case animateMenu[MENU_ANIMATE_NEXT] ' = CreateMenu("{{m_function_Animate_next}}", 463, animateMenu[0], KEY_LEFT )
					anime.Backward()
				Case animateMenu[MENU_ANIMATE_BACK] ' = CreateMenu("{{m_function_Animate_back}}", 464, animateMenu[0], KEY_RIGHT )	
					anime.Forward()
				EndSelect			
			EndIf			
		EndSelect
	End Method
	
	
	Method setAllAnimes( play%,  ed:TEditor, data:TData)
		Select ed.program_mode
			Case "ship"
			For Local i% = 0 Until data.ship.weaponSlots.length 
				Local weaponSlotId$ = data.ship.weaponSlots[i].id
				If MapValueForKey(animes, weaponSlotId) 
					Local anime:TAnime = TAnime (MapValueForKey(animes, weaponSlotId) )
					anime.isPlaying = play
					' for the 0 fps things
					If anime.interval = - 1
						If play 
							anime.Forward()
						Else 
							anime.Backward()
						End If
					End If
				Else 
					Local anime:TAnime = initAnime( i, ed, data )
					If anime 
						anime.isPlaying = play
						' for the 0 fps things
						If anime.interval = - 1
							If play 
								anime.Forward()
							Else 
								anime.Backward()
							End If
						End If
					End If
				End If
			Next 
			Case "variant"
			For Local i% = 0 Until data.ship.weaponSlots.length 
				Local weaponSlotId$ = data.ship.weaponSlots[i].id
				If MapValueForKey(animes, weaponSlotId) 
					Local anime:TAnime = TAnime (MapValueForKey(animes, weaponSlotId) )
					anime.isPlaying = play
					' for the 0 fps things
					If anime.interval = - 1
						If play 
							anime.Forward()
						Else 
							anime.Backward()
						End If
					End If
				Else 
					Local anime:TAnime = initAnime( i, ed, data )
					If anime 
						anime.isPlaying = play
						' for the 0 fps things
						If anime.interval = -1
							If play 
								anime.Forward()
							Else 
								anime.Backward()
							End If
						End If
					End If
				End If
			Next
			Case "weapon"
				If Not weaponEditorAnime Then initAnime( 0, ed, data )
				If Not weaponEditorAnime Then Return
				weaponEditorAnime.isPlaying = play
				' for the 0 fps things
				If weaponEditorAnime.interval = - 1
					If play 
						weaponEditorAnime.Forward()
					Else 
						weaponEditorAnime.Backward()
					End If
				End If
		EndSelect
	End Method 	
	
	Method restAllAnimes()
		'JUST NUKE THEM!
		If animes Then ClearMap ( animes )
		weaponEditorAnime = Null
	End Method
	
	Method getAnimeForSlot_i:TAnime (weaponSlot_i%, ed:TEditor, data:TData)
		If weaponSlot_i = -1 Then Return Null
		If weaponSlot_i > data.ship.weaponSlots.length - 1 Then Return Null 'This should not happen but just in case
		Local weaponSlotId$ = data.ship.weaponSlots[weaponSlot_i].id
		If MapValueForKey(animes, weaponSlotId) 'good, it is in map
			Return TAnime (MapValueForKey(animes, weaponSlotId) )
		Else ' opps, no in map so let's return a new one, if any.
			Return initAnime:TAnime (weaponSlot_i, ed, data)
		End If
	End Method
	
	Method initAnime:TAnime (weaponSlot_i%, ed:TEditor, data:TData)
		If weaponSlot_i = - 1 Then Return Null
		Select ed.program_mode
			Case "ship"
				Local weaponSlot:TStarfarerShipWeapon = data.ship.weaponSlots[weaponSlot_i]
				If MapValueForKey(data.ship.builtInWeapons, weaponSlot.id)
					Local weaponID$ = String (MapValueForKey(data.ship.builtInWeapons, weaponSlot.id))
					Local weapon:TStarfarerWeapon = TStarfarerWeapon (ed.stock_weapons.ValueForKey(weaponID))
					If weapon.numFrames <= 1 Then Return Null
					Local anime:TAnime = New TAnime
					anime.init( weaponSlot_i, weaponSlot, weaponID, weapon )
					MapInsert ( animes, weaponSlot.id, anime)
					Return anime
				End If 
			Case "variant"
				Local weaponSlot:TStarfarerShipWeapon = data.ship.weaponSlots[weaponSlot_i]
				Local weaponID$
				If MapValueForKey(data.ship.builtInWeapons, weaponSlot.id)
					weaponID = String (MapValueForKey(data.ship.builtInWeapons, weaponSlot.id) )	
				Else If MapValueForKey(data.variant.getAllweapons(), weaponSlot.id)
					weaponID = String (MapValueForKey(data.variant.getAllweapons(), weaponSlot.id))	
				Else					
					Return Null
				EndIf
				If Not weaponID Then Return Null
				Local weapon:TStarfarerWeapon = TStarfarerWeapon (ed.stock_weapons.ValueForKey(weaponID) )	
				If Not weapon Then Return null
				If weapon.numFrames <= 1 Then Return Null
				Local anime:TAnime = New TAnime
				anime.init( weaponSlot_i, weaponSlot, weaponID, weapon )
				MapInsert ( animes, weaponSlot.id, anime)
				Return anime
			Case "weapon"
				If data.weapon.numFrames <= 1 Then Return Null
				weaponEditorAnime = New TAnime
				weaponEditorAnime.init( 0, sub_set_weapon.ws, data.weapon.id, data.weapon )
				Return weaponEditorAnime
		EndSelect
	End Method 
	
	Method switchDraw()
		If show_weapon < 2 
			show_weapon :+ 1
		Else show_weapon = 0
		EndIf
	End Method
	
	Method getSpriteSeqBySpac:TImage[] (weapon:TStarfarerWeapon, weapon_mount$)
		If weapon_mount = Null Or weapon_mount.length = 0 Or weapon_mount = "HIDDEN" Then Return Null
		If Not weapon Then Return Null
		Local img_0_path$ = Null
		If weapon_mount = "HARDPOINT" Then img_0_path = resource_search( weapon.hardpointSprite )
		If weapon_mount = "TURRET" Then img_0_path = resource_search( weapon.turretSprite )
		If img_0_path			
			If MapValueForKey(buffed_img_seq, img_0_path) Return TImage[] (MapValueForKey(buffed_img_seq, img_0_path) )
		EndIf 
		Local zero_pad_length% = 2
		Local num_idx% = img_0_path.FindLast( zero_pad(0,zero_pad_length) )
		If num_idx = -1 Then Return Null
		Local img_path_prefix$ = img_0_path[..num_idx]
		Local extension$ = ExtractExt( img_0_path )
		Local count% =  weapon.numFrames 
		Local img_seq:TImage[] = New TImage[ count ]
		Local img_seq_path$
		For Local i% = 0 Until count
			img_seq_path = img_path_prefix + zero_pad(i, zero_pad_length) + "." + extension
			img_seq[i] = LoadImage( img_seq_path, 0 )
		Next
		MapInsert( buffed_img_seq, img_0_path, img_seq )
		Return img_seq
	End Method
	
	Method getSpriteByPath:TImage (img_path$)
		If img_path.length = 0 Then Return Null 
		Local img:TImage = Null
		If Not buffed_img Then buffed_img = CreateMap()
		If MapValueForKey(buffed_img, img_path) Return TImage (MapValueForKey(buffed_img, img_path))
		img = LoadImage( img_path, 0 )
		If img 
			MapInsert(buffed_img, img_path, img )
			Return img
		EndIf
	End Method
	
	Method draw_variantInSlot( weaponSlot:TStarfarerShipWeapon, variant_to_render:TStarfarerVariant, data:TData, sprite:TSprite, x_offset# = 0, y_offset# = 0 , angle_offset# = 0)
		If weaponSlot.mount = "HIDDEN" Then Return
		If Not variant_to_render Then Return
		If Not weaponSlot Then Return
		Local rotation# = 90 - weaponSlot.angle - angle_offset
		While rotation > 360
			rotation :- 360
		Wend
		While rotation < 0
			rotation :+ 360
		Wend
		SetRotation( rotation )
		SetScale( sprite.scale, sprite.scale )
		'draw		
		Local img_path$
		Local hullID$ = variant_to_render.hullId		
		Local hull:TStarfarerShip = TStarfarerShip(ed.stock_ships.ValueForKey(hullID) )				
		If hull
			img_path = resource_search(hull.spriteName)				
		Else
			Local skin:TStarfarerSkin = TStarfarerSkin(ed.stock_skins.ValueForKey(hullID) )
			If skin
				img_path = resource_search(skin.spriteName)
				hull = TStarfarerShip(ed.stock_ships.ValueForKey(skin.baseHullId) )	
			EndIf
		EndIf
		Local variantIMG:TImage
		If img_path Then variantIMG = getSpriteByPath(img_path)
		If variantIMG And hull
			'calculate the center point offset
			Local x# = (variantIMG.width * 0.5) - hull.center[0]
			Local y# = (variantIMG.height * 0.5) - hull.center[1]
			rotate_vector2f(y, x, rotation)
			'calc. coords
			x = sprite.sx + (data.ship.center[1] + weaponSlot.locations[0] + x ) * sprite.scale
			y = sprite.sy + (data.ship.center[0] - weaponSlot.locations[1] - y ) * sprite.scale
			DrawImage(variantIMG, x, y)	
		EndIf
	End Method
	
	Method draw_weaponInSlot( weaponSlot:TStarfarerShipWeapon, weapon:TStarfarerWeapon, data:TData, sprite:TSprite, x_offset# = 0, y_offset# = 0 , angle_offset# = 0)
		If weaponSlot.mount = "HIDDEN" Then Return
		If Not weapon Then Return
		If Not weaponSlot Then Return
		Local rotation# = 90 - weaponSlot.angle - angle_offset
		While rotation > 360
			rotation :- 360
		Wend
		While rotation < 0
			rotation :+ 360
		Wend
		If MapValueForKey(animes, weaponSlot.id)
			Local anime:TAnime = TAnime ( MapValueForKey(animes, weaponSlot.id) )
			draw_weaponBySpec(weapon, weaponSlot.mount, weaponSlot.locations, rotation, data, sprite, anime.currFrame, x_offset, y_offset, angle_offset)
		Else If ed.program_mode = "weapon"
			If weaponEditorAnime Then draw_weaponBySpec(weapon, weaponSlot.mount, weaponSlot.locations, rotation, data, sprite, weaponEditorAnime.currFrame, x_offset, y_offset, angle_offset )..
			Else draw_weaponBySpec(weapon, weaponSlot.mount, weaponSlot.locations, rotation, data, sprite, - 1, x_offset, y_offset, angle_offset)
		Else draw_weaponBySpec(weapon, weaponSlot.mount, weaponSlot.locations, rotation, data, sprite, - 1, x_offset, y_offset, angle_offset)
		End If
	End Method
	
	Method draw_weaponBySpec( weapon:TStarfarerWeapon, weapon_mount$, weapon_loc#[], rotation#, data:TData, sprite:TSprite, frame_to_draw% = - 1, x_offset# = 0, y_offset# = 0, angle_offset# = 0)
		'init var
		Local main_img:TImage = Null
		Local under_img:TImage = Null
		Local gun_img:TImage = Null
		Local img_path$ = Null
		'grab img
		'Non-anime mode
		If frame_to_draw = - 1
			If weapon_mount = "HARDPOINT"
				If weapon.hardpointSprite
					img_path = resource_search( weapon.hardpointSprite )
					If img_path Then main_img = getSpriteByPath(img_path)
				EndIf
				If weapon.hardpointGunSprite
					img_path = resource_search( weapon.hardpointGunSprite )
					If img_path Then gun_img = getSpriteByPath(img_path)
				EndIf
				If weapon.hardpointUnderSprite
					img_path = resource_search( weapon.hardpointUnderSprite )
					If img_path Then under_img = getSpriteByPath(img_path)
				EndIf
			Else If weapon_mount = "TURRET" 
				If weapon.turretSprite
					img_path = resource_search( weapon.turretSprite )
					If img_path Then main_img = getSpriteByPath(img_path)
				EndIf
				If weapon.turretGunSprite
					img_path = resource_search( weapon.turretGunSprite )
					If img_path Then gun_img = getSpriteByPath(img_path)
				EndIf
				If weapon.turretUnderSprite
					img_path = resource_search( weapon.turretUnderSprite )
					If img_path Then under_img = getSpriteByPath(img_path)
				EndIf
			Else 
				Return
			EndIf
		Else
			Local img_seq:TImage[] = getSpriteSeqBySpac(weapon, weapon_mount)
			main_img = img_seq[ frame_to_draw ]			
		EndIf		
		'check if we have thing to draw with for sure
		If Not main_img And Not under_img And Not gun_img Then Return
		'calculate the hardpoint offset
		Local x# = weapon_loc[0]
		Local y# = weapon_loc[1]
		rotate_vector2f(x, y, angle_offset)
		If ed.program_mode <> "weapon" And weapon_mount = "HARDPOINT"
			If main_img
				Local c# = ImageHeight(main_img) * 0.25
				x :+ c * Sin(rotation)
				y :+ c * Cos(rotation)
			'juse in case if there are not hardpointSprit but have something others
			Else If under_img
				Local c# = ImageHeight(under_img) * 0.25
				x :+ c * Sin(rotation)
				y :+ c * Cos(rotation)
			Else If gun_img
				Local c# = ImageHeight(gun_img) * 0.25
				x :+ c * Sin(rotation)
				y :+ c * Cos(rotation)
			EndIf 
		EndIf	
		'OK let's draw
		x:+ x_offset
		y:+ y_offset
		draw_weaponByImg(main_img, under_img, gun_img, [x, y], rotation, weapon.check_render_barrel_below(), data, sprite)
	EndMethod
	
		
	Method draw_weaponByImg( main_img:TImage, under_img:TImage, gun_img:TImage, weapon_loc#[], rotation#, RENDER_BARREL_BELOW% = False, data:TData, sprite:TSprite )
		SetRotation( rotation )
		SetScale( sprite.scale, sprite.scale )
		'calc. coords
		Local	x# = 0
		Local	y# = 0
		If ed.program_mode <> "weapon"				
			If data.ship.center
				x = sprite.sx + (data.ship.center[1] + weapon_loc[0] ) * sprite.scale
				y = sprite.sy + (data.ship.center[0] - weapon_loc[1] ) * sprite.scale
			EndIf
		Else
'			x = sprite.sx + sprite.sw / 2 + weapon_loc[0] * sprite.scale
'			y = sprite.sy + sprite.sh / 2 - weapon_loc[1] * sprite.scale
			x = sprite.asx + weapon_loc[0] * sprite.scale
			y = sprite.asy
		EndIf
		'draw
		If under_img Then DrawImage( under_img, x, y )
		If main_img	
			If gun_img And RENDER_BARREL_BELOW 
				DrawImage( gun_img, x, y )
			Else
				DrawImage( main_img, x, y )
			EndIf
		EndIf
		If gun_img 
			If main_img And RENDER_BARREL_BELOW 
				DrawImage( main_img, x, y )
			Else
				DrawImage( gun_img, x, y )
			EndIf
		EndIf
	EndMethod
End Type

Type TAnime
	Field weaponSlot_i%
	Field weaponSlot_id$
	Field weaponSlot:TStarfarerShipWeapon
	Field weapon_id$
	Field isPlaying% = False
	Field weapon:TStarfarerWeapon
	Field currFrame% = 0
	Field numFrames%
	Field frameRate#
	Field interval%
	Field timeStamp% 
	
	Method init ( weaponSlot_i_in%, weaponSlot_in:TStarfarerShipWeapon, weapon_id_in$, weapon_in:TStarfarerWeapon )
		weaponSlot_i = weaponSlot_i_in
		weaponSlot_id = weaponSlot_in.id
		weaponSlot = weaponSlot_in
		weapon_id = weapon_id_in
		weapon = weapon_in
		numFrames = weapon.numFrames
		frameRate = weapon.frameRate
		currFrame = 0
		If frameRate <= 0 
			interval = -1
		Else interval = 1000/frameRate
		End If
		timeStamp = MilliSecs()
	End Method

	Method update()
		If isPlaying Then playing()
	End Method
	
		
	Method Forward(frames% = 1)
		If frames Then currFrame = (currFrame + frames) Mod numFrames
	End Method
	
	Method Backward(frames% = 1)
		If frames Then currFrame = (currFrame - frames) Mod numFrames
		If currFrame < 0 Then currFrame :+ numFrames
	End Method	
	
	Method playing()
		If interval <> - 1
			Local i% = (MilliSecs() - timeStamp) / interval
			If i
				Forward(i)			
				timeStamp = MilliSecs() - ( (MilliSecs() - timeStamp) Mod interval)
			EndIf
		End If
	End Method
	
	Method playingReverse()
		If interval <> - 1
			Local i% = (MilliSecs() - timeStamp) / interval
			If i
				Backward(i)			
				timeStamp = MilliSecs() - ((MilliSecs() - timeStamp) Mod interval)
			EndIf
		End If
	End Method
	
End Type

Type TWeaponRenderData
	Field weaponSlot:TStarfarerShipWeapon
	Field weapon:TStarfarerWeapon
	Field renderOrder# = 0
	Field x_offset# = 0
	Field y_offset# = 0
	Field facing# = 0
	Field variant:TStarfarerVariant
	
	Method init (ws:TStarfarerShipWeapon, w:TStarfarerWeapon)
		weaponSlot = ws
		weapon = w
		Local offset_weight# = Abs weaponSlot.locations[0] / 100000 + Abs weaponSlot.locations[1] / 10000
			renderOrder :- offset_weight
		If Not weapon.renderBelowAllWeapons
			renderOrder = weapon.draw_order() * 2
			If weapon.type_ = "MISSILE" And (weapon.renderHints.elements.Contains("RENDER_LOADED_MISSILES") Or weapon.renderHints.elements.Contains("RENDER_LOADED_MISSILES_UNLESS_HIDDEN") ) Then renderOrder = renderOrder - 1
			If Not weaponSlot.mount = "HARDPOINT" Then renderOrder = renderOrder + 20
		EndIf
	End Method

	Method inti_for_module(ws:TStarfarerShipWeapon, v:TStarfarerVariant)
		weaponSlot = ws
		variant = v
		Local offset_weight# = Abs weaponSlot.locations[0] / 100000 + Abs weaponSlot.locations[1] / 10000
		renderOrder :- offset_weight
		'hope this is right
		renderOrder :- 20
	End Method

	Method set_facing_and_offset(x#, y#, facing_arc#)
		x_offset = x
		y_offset = y
		facing = facing_arc	
	End Method

	Method set_is_station_module_weapon()
		renderOrder :+ 100
	End Method
	
	Method Compare:Int(d:Object)
		Local rd:TWeaponRenderData = TWeaponRenderData(d)
		If rd Then
			If renderOrder < rd.renderOrder Then
				Return -1
			ElseIf renderOrder > rd.renderOrder Then
				Return 1
			Else
				Return 0
			EndIf
		Else
			Return 0
		EndIf
	EndMethod
End Type

Function rotate_vector2f( x# Var, y# Var, rotate_angle#)
	If rotate_angle = 0 Then Return
	Local c# = Cos(rotate_angle)
	Local s# = Sin(rotate_angle)
	Local x_tem# = x
	Local y_tem# = y
	x = x_tem * c - y_tem * s
	y = x_tem * s + y_tem * c
End Function

Function draw_weapons( ed:TEditor, data:TData, sprite:TSprite, wd:TWeaponDrawer )
  wd.update( ed, data )
  If wd.show_weapon = 0 Then Return
  SetColor( 255, 255, 255 )
  If wd.show_weapon = 1 Then SetAlpha( 1 )
  If wd.show_weapon = 2 Then SetAlpha( 0.5 )
  Select ed.program_mode
    Case "ship", "variant", "skin"
      wd.draw_all_weapons(ed.program_mode, data, sprite)
  EndSelect
  SetAlpha( 1 )
End Function
