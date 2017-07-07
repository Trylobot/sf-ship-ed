
Type TModalWeapon Extends TSubroutine
	'images
	Field turret_img:TImage
	Field turretUnder_img:TImage
	Field turretGun_img:TImage
	Field turretGlow_img:TImage
	Field hardpoint_img:TImage
	Field hardpointUnder_img:TImage
	Field hardpointGun_img:TImage
	Field hardpointGlow_img:TImage
	'I feel lazy so just fake a weapon slot and call in the weapon drawer.
	Field ws:TStarfarerShipWeapon
	Field xOffset#
	Field ni%
	Field si%
	Field x#, y#
	'internal state
	Field img_x#,img_y# ' mouse position on image
	Field spr_w#, spr_h#
	Field weapon_display_mode$ ' turret, hardpoint
	'Field offset_lock_idx%
	'Field do_draw_barrels%
	Field do_draw_glow%
	'animated images
	Field turret_img_seq:TImage[]
	Field hardpoint_img_seq:TImage[]
'	Field img_seq_i%
'	Field img_seq_i_ts%
	'housekeeping
	'Field sprite_img_buffer:TImage

	Method Activate( ed:TEditor, data:TData, sprite:TSprite )
		ed.program_mode = "weapon"
		ed.mode = "offsets"
		ed.drag_mirrored = false
		weapon_display_mode = "TURRET"
		'data.update_weapon()
		'offset_lock_idx = - 1
		ed.drag_nearest_i = - 1
		do_draw_glow = true
		'do_draw_barrels = False
		load_weapon_images( data, sprite )
		ws = New TStarfarerShipWeapon
		ws.locations = [0.0 , 0.0]
		ws.mount = "TURRET"
		WD.weaponEditorAnime = Null
		ni = si = - 1
		DebugLogFile(" Activate Weapon Editor")
	EndMethod

	Method Update( ed:TEditor, data:TData, sprite:TSprite )
		'MODE CHANGE
		'get input
		Select EventID()
		Case EVENT_GADGETACTION, EVENT_MENUACTION
			Select EventSource()
			Case functionMenuSub[MENU_MODE_WEAPON][MENU_SUBFUNCTION_WEAPON_WEAPON_OFFSETS] 'offset mode Toggle
				If ed.mode = "offsets" Then ed.mode = "images" Else ed.mode = "offsets"
			Case functionMenuSub[MENU_MODE_WEAPON][MENU_SUBFUNCTION_WEAPON_WEAPON_DISPLAYMODE] 'TURRET/HARDPOINT Toggle
				If weapon_display_mode = "TURRET" Then weapon_display_mode = "HARDPOINT" Else weapon_display_mode = "TURRET"
				ws.mount = weapon_display_mode
				WD.weaponEditorAnime = Null
				update_sprite_img( data, sprite )
			'IMAGES
			Case functionMenuSub[MENU_MODE_WEAPON][MENU_SUBFUNCTION_WEAPON_WPIMG_MAIN]
				try_load_sprite( ed, data, sprite, weapon_display_mode, "main" )
				load_weapon_images( data, sprite )
			Case functionMenuSub[MENU_MODE_WEAPON][MENU_SUBFUNCTION_WEAPON_WPIMG_BARREL]
				try_load_sprite( ed, data, sprite, weapon_display_mode, "gun" )
				load_weapon_images( data, sprite )	
			Case functionMenuSub[MENU_MODE_WEAPON][MENU_SUBFUNCTION_WEAPON_WPIMG_UNDER]
				try_load_sprite( ed, data, sprite, weapon_display_mode, "under" )
				load_weapon_images( data, sprite )
			Case functionMenuSub[MENU_MODE_WEAPON][MENU_SUBFUNCTION_WEAPON_WPIMG_GLOW]
				try_load_sprite( ed, data, sprite, weapon_display_mode, "glow" )
				load_weapon_images( data, sprite )
			Case functionMenuSub[MENU_MODE_WEAPON][MENU_SUBFUNCTION_WEAPON_WEAPON_GLOWTOGGLE]
				do_draw_glow = Not do_draw_glow
			EndSelect
		EndSelect
		'MODE-SPECIFIC UPDATE CALL
		Select ed.mode
			Case "offsets"
				update_offsets( ed, data, sprite )
			Case "images"
		EndSelect
		'need a way to toggle glow
		' preview projectile firing?
		' play sound?
		'need a way to adjust recoil
		'need a way to add/remove barrels + offsets
		'need a button to FIRE!
		'  use weapon.visualRecoil to determine distance
		'  use barrelMode to determine which barrels to fire from; track barrel sequence
		'  use weapon data CSV, if possible, to determine a reasonable reload speed (complicated)
		'  create a Projectile object and launch it (complicated as fuck)
	EndMethod

	Method Draw( ed:TEditor, data:TData, sprite:TSprite )
		
		'DRAW SPRITES
		If sprite.wpimg <> Null And weapon_display_mode = "HARDPOINT" Then xOffset = sprite.wpimg.height * - 0.25 Else xOffset = 0
		If WD.show_weapon <> 0
			If WD.show_weapon = 1 Then SetAlpha( 1 )
			If WD.show_weapon = 2 Then SetAlpha( 0.5 )
			WD.draw_weaponInSlot(ws, data.weapon, data, sprite)
			SetAlpha( 1 )
		EndIf
		'DRAW GLOW
		If do_draw_glow And (data.weapon.turretGlowSprite.length > 0 Or data.weapon.hardpointGlowSprite.length > 0)
			If data.weapon.glowColor
				SetColor(data.weapon.glowColor[0], data.weapon.glowColor[1], data.weapon.glowColor[2])
				SetAlpha(data.weapon.glowColor[3] / 1275.0)
			Else
				SetColor(255, 255, 255)
				SetAlpha(0.2)
			EndIf
			SetBlend(ALPHABLEND)
			For Local i# = 0 Until 15
				Local x# = 0
				Local y# = 0
				If i < 12
					x = Rand( - 10, 10) / 10.0
					y = Rand( - 10, 10) / 10.0
				Else
					x = Rand( - 10, 10) / 20.0
					y = Rand( - 10, 10) / 20.0
					SetBlend(LIGHTBLEND)
					SetColor(255, 255, 255)
					If data.weapon.glowColor
						SetAlpha(data.weapon.glowColor[3] / 1020.0)
					Else
						SetAlpha(0.25)
					EndIf
				EndIf
				Select weapon_display_mode
				Case "TURRET"
					If turretGlow_img Then DrawImage(turretGlow_img, W_MID + sprite.pan_x + x * sprite.scale, H_MID + sprite.pan_y + y * sprite.scale)
				Case "HARDPOINT"
					If hardpointGlow_img Then DrawImage(hardpointGlow_img, W_MID + sprite.pan_x + x * sprite.scale, H_MID + sprite.pan_y + y * sprite.scale)
				End Select
			Next			
			SetBlend(ALPHABLEND)
			SetColor(255, 255, 255)
			SetAlpha(1)
		EndIf	
		'DRAW MODE-SPECIFIC THINGS
		Select ed.mode
			Case "offsets"
				draw_barrel_offsets( ed, data, sprite )
			Case "images"
		EndSelect
		draw_hud(ed, data)
	EndMethod

	Method Save( ed:TEditor, data:TData, sprite:TSprite )
		Local path$ = RequestFile( LocalizeString("{{wt_save_weapon}}"), "wpn", True, APP.weapon_dir + data.weapon.id )
		If path
			APP.weapon_dir = ExtractDir( path )+"/"
			APP.Save()
			'SaveString(data.json_str_weapon, path)
			SaveTextAs( data.json_str_weapon, path, CODE_MODE )
		End If
		FlushEvent()
	EndMethod

	Method Load( ed:TEditor, data:TData, sprite:TSprite )
		Local path$ = RequestFile( LocalizeString("{{wt_load_weapon}}"), "wpn", False, APP.weapon_dir )
		If FileType( path ) <> FILETYPE_FILE Then Return
		APP.weapon_dir = ExtractDir( path ) + "/"
		APP.Save()
		Local json_str_weapon$ = LoadTextAs( path, CODE_MODE )
		data.decode_weapon( json_str_weapon )
		data.update_weapon()
		'do_draw_barrels = (data.weapon.visualRecoil <> 0)
		WD.weaponEditorAnime = Null
		load_weapon_images( data, sprite )
	EndMethod

	'this is for the sake of global maths that reference the sprite img for their calcs
	Method update_sprite_img( data:TData, sprite:TSprite )
		Select weapon_display_mode
			Case "TURRET"
				If data.weapon.numFrames <= 1
					sprite.wpimg = turret_img
				Else ' data.weapon.numFrames > 1
					sprite.wpimg = turret_img_seq[0]
				EndIf
			Case "HARDPOINT"
				If data.weapon.numFrames <= 1
					sprite.wpimg = hardpoint_img
				Else ' data.weapon.numFrames > 1
					sprite.wpimg = hardpoint_img_seq[0]
				EndIf
		EndSelect
		If sprite.wpimg
			spr_w = sprite.wpimg.width
			spr_h = sprite.wpimg.height
		Else
			spr_w = 0
			spr_h = 0
		EndIf
	EndMethod

	Method update_offsets( ed:TEditor, data:TData, sprite:TSprite )
		If Not sprite.wpimg Then Return
		sprite.get_xy( MouseX, MouseY, img_x, img_y, False)
		x = RoundFloat( img_x - xOffset, DO_ROUND)
		y = RoundFloat( - img_y, DO_ROUND )
		ni = data.find_nearest_weapon_offset( x, y, weapon_display_mode )
		Select EventID()
		Case EVENT_MOUSEDOWN, EVENT_MOUSEUP, EVENT_MOUSEMOVE
			Select ModKeyAndMouseKey
			Case 16 '(MODIFIER_LMOUSE)
				Select EventID()				
				Case EVENT_MOUSEDOWN
					'drag nearset
					ed.drag_nearest_i = ni
					If ed.drag_nearest_i = - 1 Then Return
					ed.drag_mirrored = ed.bounds_symmetrical
					If ed.drag_mirrored Then ed.drag_counterpart_i = data.find_symmetrical_weapon_offset_counterpart( ed.drag_nearest_i, weapon_display_mode )
					data.modify_weapon_offset( ed.drag_nearest_i, x, y, spr_w, spr_h, weapon_display_mode, False )
					If ed.drag_counterpart_i <> - 1 Then data.modify_weapon_offset( ed.drag_counterpart_i, x, y, spr_w, spr_h, weapon_display_mode, True )
				Case EVENT_MOUSEMOVE
					data.modify_weapon_offset( ed.drag_nearest_i, x, y, spr_w, spr_h, weapon_display_mode, False )
					If ed.drag_mirrored And ed.drag_counterpart_i <> - 1 Then data.modify_weapon_offset( ed.drag_counterpart_i, x, y, spr_w, spr_h, weapon_display_mode, True )
				Case EVENT_MOUSEUP
					data.update_weapon()
					ed.drag_nearest_i = - 1
					ed.drag_counterpart_i = -1
				EndSelect
			Case 17 '(MODIFIER_SHIFT|MODIFIER_LMOUSE)
				If EventID() = EVENT_MOUSEDOWN	
					'add new						
					data.append_weapon_offset( x, y, weapon_display_mode, False )
					Local predicted_y# = - y
					If ed.bounds_symmetrical And predicted_y <> 0
						data.append_weapon_offset( x, predicted_y, weapon_display_mode, True )
					EndIf
					data.update_weapon()
				EndIf
			Case 18 '(MODIFIER_CONTROL|MODIFIER_LMOUSE)
				'set angle
				Select EventID()
				Case EVENT_MOUSEDOWN
					ed.drag_nearest_i = ni
					ed.drag_mirrored = ed.bounds_symmetrical
					If ed.drag_nearest_i <> - 1 Then data.set_weapon_offset_angle( ed.drag_nearest_i, x, y, weapon_display_mode, ed.drag_mirrored )
				Case EVENT_MOUSEMOVE
					If ed.drag_nearest_i <> - 1 Then data.set_weapon_offset_angle( ed.drag_nearest_i, x, y, weapon_display_mode, ed.drag_mirrored )
				Case EVENT_MOUSEUP
					data.update_weapon()
					ed.drag_nearest_i = ni
				EndSelect
			EndSelect
		Case EVENT_GADGETACTION, EVENT_MENUACTION
			Select EventSource()
			Case functionMenu[4]
				'remove
				data.remove_nearest_weapon_offset( x, y, weapon_display_mode )
				data.update_weapon()
			EndSelect
		EndSelect		
	EndMethod

	Method try_load_sprite( ed:TEditor, data:TData, sprite:TSprite, weapon_display_mode$, sprite_name$ )
		Local image_path$ = RequestFile( LocalizeString("{{wt_load_image_weapon}}"), "png", False, APP.weapon_images_dir )
		If image_path.length = 0 Then Return
		If FILETYPE_FILE = FileType( image_path )
			APP.weapon_images_dir = ExtractDir( image_path )+"/"
			APP.Save()
			image_path = image_path.Replace( "\", "/" )
			Local scan$ = image_path
			While scan.length > "graphics".length
				scan = ExtractDir( scan )
				If scan.EndsWith( "graphics" )
					Local to_remove$ = ExtractDir( scan )+"/"
					image_path = image_path.Replace( to_remove, "" )
					If image_path.StartsWith( "graphics" )
						Select weapon_display_mode
							Case "TURRET"
								Select sprite_name
									Case "main"
										data.weapon.turretSprite = image_path
									Case "gun"
										data.weapon.turretGunSprite = image_path
									Case "under"
										data.weapon.turretUnderSprite = image_path
									Case "glow"
										data.weapon.turretGlowSprite = image_path
								EndSelect
							Case "HARDPOINT"
								Select sprite_name
									Case "main"
										data.weapon.hardpointSprite = image_path
									Case "gun"
										data.weapon.hardpointGunSprite = image_path
									Case "under"
										data.weapon.hardpointUnderSprite = image_path
									Case "glow"
										data.weapon.hardpointGlowSprite = image_path
								EndSelect
						EndSelect
						data.update_weapon()
					EndIf
					Exit
				EndIf
			EndWhile
		Else
			Select weapon_display_mode
				Case "TURRET"
					Select sprite_name
						Case "main"
							data.weapon.turretSprite = Null
						Case "gun"
							data.weapon.turretGunSprite = Null
						Case "under"
							data.weapon.turretUnderSprite = Null
						Case "glow"
							data.weapon.turretGlowSprite = Null
					EndSelect
				Case "HARDPOINT"
					Select sprite_name
						Case "main"
							data.weapon.hardpointSprite = Null
						Case "gun"
							data.weapon.hardpointGunSprite = Null
						Case "under"
							data.weapon.hardpointUnderSprite = Null
						Case "glow"
							data.weapon.hardpointGlowSprite = Null
					EndSelect
			EndSelect
		EndIf
	EndMethod

'	Method draw_weapon( main_img:TImage, under_img:TImage, gun_img:TImage, glow_img:TImage, gun_offsets#[], sprite:TSprite )
'		SetRotation( 90 )
'		SetScale( sprite.scale, sprite.scale )
'		SetAlpha( 1 )
'		SetColor( 255, 255, 255 )
'		'calc. coords
'		Local x# = W_MID + sprite.pan_x + sprite.zpan_x
'		Local y# = H_MID + sprite.pan_y + sprite.zpan_y
'		'hardpoint center point is at 1/4 of then buttom
'		If weapon_display_mode = "HARDPOINT" And sprite.img
'			x :+ Float(sprite.img.height) * 0.75
'		EndIf
'		'draw
'		If under_img Then DrawImage( under_img, x, y )
'		If main_img Then DrawImage( main_img, x, y )
'		If do_draw_barrels And gun_img Then DrawImage( gun_img, x, y )
'		If do_draw_glow And glow_img Then DrawImage( glow_img, x, y )
'	EndMethod

	Method draw_barrel_offsets( ed:TEditor, data:TData, sprite:TSprite )
		If ed.drag_nearest_i <> - 1
			ni = ed.drag_nearest_i
		Else
			sprite.get_xy( MouseX, MouseY, img_x, img_y, False)
			x = RoundFloat( img_x - xOffset, DO_ROUND)
			y = RoundFloat( - img_y, DO_ROUND )
			ni = data.find_nearest_weapon_offset( x, y, weapon_display_mode )
		EndIf
		If ed.bounds_symmetrical Or ed.drag_mirrored
			si = data.find_symmetrical_weapon_offset_counterpart(ni, weapon_display_mode)
		Else
			si = - 1
		EndIf
		Local offsetsArray#[], angleOffsets#[]
		If weapon_display_mode = "TURRET"
			offsetsArray = data.weapon.turretOffsets
			angleOffsets = data.weapon.turretAngleOffsets
		ElseIf weapon_display_mode = "HARDPOINT"
			offsetsArray = data.weapon.hardpointOffsets
			angleOffsets = data.weapon.hardpointAngleOffsets
		Else
			Return
		EndIf
		If Not offsetsArray Then Return
		If Not angleOffsets Then Return
		SetImageFont( DATA_FONT )
		Local ox#, oy#, r#
		For Local i% = 0 Until offsetsArray.length Step 2
			ox = W_MID + sprite.pan_x + sprite.zpan_x + sprite.scale * (offsetsArray[i + 0] + xOffset)
			oy = H_MID + sprite.pan_y + sprite.zpan_y + sprite.scale * - offsetsArray[i + 1]
			r = angleOffsets[i / 2]
			If i <> ni And i <> si
				SetAlpha( 0.50 )
				draw_pointer( ox, oy, r, False, 8, 16, $FFFFFF, $000000 )
			Else
				SetAlpha( 0.80 )
				draw_pointer( ox, oy, r, False, 10, 20, $FFFFFF, $000000 )
			EndIf
			SetAlpha( 1 )
			draw_string( "" + ( (i / 2) + 1), ox, oy,,, 0.5, 0.25 )
		Next
		SetImageFont( FONT )
		SetAlpha( 1 )
		mouse_str = ""
		If ni <> - 1
			If ModKeyAndMouseKey = 1 Or ModKeyAndMouseKey = 17
				mouse_str :+ coord_string( x, y ) + "~n"
			ElseIf ModKeyAndMouseKey = 2 Or ModKeyAndMouseKey = 18
				mouse_str :+ json.FormatDouble(angleOffsets[ni / 2], 1) + Chr($00B0) + " (arc)~n"			
			Else If ModKeyAndMouseKey = 0 Or ModKeyAndMouseKey = 16
				mouse_str :+ coord_string( offsetsArray[ni], offsetsArray[ni + 1] ) + "~n" + json.FormatDouble(angleOffsets[ni / 2], 1) + Chr($00B0) + " (arc)~n"
			EndIf
		EndIf	
	EndMethod
	
	Method draw_hud( ed:TEditor, data:TData )
		Local op_str$ = LocalizeString("{{ui_function_weapon_opstr}}") + weapon_display_mode
		Local op_widget:TextWidget = TextWidget.Create( op_str )
		draw_container( 7, LINE_HEIGHT * 2, op_widget.w + 20, op_widget.h + 20, 0.0, 0.0 )
		draw_string( op_widget, 7 +10, LINE_HEIGHT * 2 + 10, $FFFFFF, 0.0, 0.0 )
	EndMethod

	Method load_weapon_images( data:TData, sprite:TSprite )
		'clear out stale data
		turret_img = Null
		turretUnder_img = Null
		turretGun_img = Null
		turretGlow_img = Null
		hardpoint_img = Null
		hardpointUnder_img = Null
		hardpointGun_img = Null
		hardpointGlow_img = Null
		turret_img_seq = Null
		hardpoint_img_seq = Null
'		img_seq_i = 0
'		img_seq_i_ts = millisecs()
		Local img_path$ = Null
		'load new imgs
		If data.weapon.numFrames <= 1
			'Single-frame turret/hardpoint
			If data.weapon.turretSprite
				img_path = resource_search( data.weapon.turretSprite )
				If img_path Then turret_img = LoadImage( img_path, 0 )
			EndIf
			If data.weapon.hardpointSprite
				img_path = resource_search( data.weapon.hardpointSprite )
				If img_path Then hardpoint_img = LoadImage( img_path, 0 )
			EndIf
		Else 'data.weapon.numFrames > 1
			'Multi-frame turret/hardpoint
			If data.weapon.turretSprite
				img_path = resource_search( data.weapon.turretSprite )
				If img_path Then turret_img_seq = load_image_sequence( img_path, data.weapon.numFrames )
			EndIf
			If data.weapon.hardpointSprite
				img_path = resource_search( data.weapon.hardpointSprite )
				If img_path Then hardpoint_img_seq = load_image_sequence( img_path, data.weapon.numFrames )
			EndIf
		EndIf
		'Supporting images
		If data.weapon.turretUnderSprite
			img_path = resource_search( data.weapon.turretUnderSprite )
			If img_path Then turretUnder_img = LoadImage( img_path, 0 )
		EndIf
		If data.weapon.turretGunSprite
			img_path = resource_search( data.weapon.turretGunSprite )
			If img_path Then turretGun_img = LoadImage( img_path, 0 )
		EndIf
		If data.weapon.turretGlowSprite
			img_path = resource_search( data.weapon.turretGlowSprite )
			If img_path Then turretGlow_img = LoadImage( img_path, 0 )
		EndIf
		If data.weapon.hardpointUnderSprite
			img_path = resource_search( data.weapon.hardpointUnderSprite )
			If img_path Then hardpointUnder_img = LoadImage( img_path, 0 )
		EndIf
		If data.weapon.hardpointGunSprite
			img_path = resource_search( data.weapon.hardpointGunSprite )
			If img_path Then hardpointGun_img = LoadImage( img_path, 0 )
		EndIf
		If data.weapon.hardpointGlowSprite
			img_path = resource_search( data.weapon.hardpointGlowSprite )
			If img_path Then hardpointGlow_img = LoadImage( img_path, 0 )
		EndIf
		'Update active sprite
		update_sprite_img( data, sprite )
	EndMethod

	Method load_image_sequence:TImage[]( img_0_path$, count% )
		If img_0_path = Null Then Return Null
		Local zero_pad_length% = 2
		Local num_idx% = img_0_path.FindLast( zero_pad(0,zero_pad_length) )
		If num_idx = -1 Then Return Null
		Local img_path_prefix$ = img_0_path[..num_idx]
		Local extension$ = ExtractExt( img_0_path )
		Local img_seq:TImage[] = New TImage[ count ]
		Local img_seq_path$
		For Local i% = 0 Until count
			img_seq_path = img_path_prefix+zero_pad(i,zero_pad_length)+"."+extension
			img_seq[i] = LoadImage( img_seq_path, 0 )
		Next
		Return img_seq
	EndMethod

EndType
