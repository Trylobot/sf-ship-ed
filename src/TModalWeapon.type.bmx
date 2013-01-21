
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
	'internal state
	Field img_x#,img_y# ' mouse position on image
	Field spr_w#,spr_h#
	Field weapon_display_mode$ ' turret, hardpoint
	Field offset_lock_idx%
	Field do_draw_barrels%
	Field do_draw_glow%
	'animated images
	Field turret_img_seq:TImage[]
	Field hardpoint_img_seq:TImage[]
	Field img_seq_i%
	Field img_seq_i_ts%
	'housekeeping
	Field sprite_img_buffer:TImage

	Method Activate( ed:TEditor, data:TData, sprite:TSprite )
		ed.program_mode = "weapon"
		ed.mode = "offsets"
		weapon_display_mode = "turret"
		'save the current sprite img to be restored later
		sprite_img_buffer = sprite.img
		data.update_weapon()
		offset_lock_idx = -1
		do_draw_glow = false
		do_draw_barrels = false
		load_weapon_images( data, sprite )
	EndMethod

	Method Deactivate( ed:TEditor, data:TData, sprite:TSprite )
		sprite.img = sprite_img_buffer
	EndMethod

	Method Update( ed:TEditor, data:TData, sprite:TSprite )
		'EVERY FRAME
		'multi-frame weapon framecounter advance
		If  data.weapon.numFrames > 1 ..
		And (millisecs() - img_seq_i_ts) > Int(Double(1000)/data.weapon.frameRate)
			img_seq_i :+ 1
			If img_seq_i >= data.weapon.numFrames Then img_seq_i = 0
			img_seq_i_ts = millisecs()
		EndIf
		'MODE CHANGE
		If KeyHit( KEY_O )
			ed.mode = "offsets"
		EndIf
		If KeyHit( KEY_I )
			ed.mode = "images"
		EndIf
		If KeyHit( KEY_H )
			If weapon_display_mode = "turret" Then weapon_display_mode = "hardpoint" Else weapon_display_mode = "turret"
			update_sprite_img( data, sprite )
		EndIf
		'IMAGES
		If KeyHit( KEY_A ) And ed.mode = "images"
			try_load_sprite( ed, data, sprite, weapon_display_mode, "main" )
			load_weapon_images( data, sprite )
		EndIf
		If KeyHit( KEY_G ) And ed.mode = "images"
			try_load_sprite( ed, data, sprite, weapon_display_mode, "gun" )
			load_weapon_images( data, sprite )
		EndIf
		If KeyHit( KEY_U ) And ed.mode = "images"
			try_load_sprite( ed, data, sprite, weapon_display_mode, "under" )
			load_weapon_images( data, sprite )
		EndIf
		If KeyHit( KEY_L ) And ed.mode = "images"
			try_load_sprite( ed, data, sprite, weapon_display_mode, "glow" )
			load_weapon_images( data, sprite )
		EndIf
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
		Select weapon_display_mode
			Case "turret"
				If data.weapon.numFrames <= 1
					draw_weapon( turret_img,                turretUnder_img, turretGun_img, turretGlow_img, data.weapon.turretOffsets, sprite )
				Else ' data.weapon.numFrames > 1
					draw_weapon( turret_img_seq[img_seq_i], turretUnder_img, turretGun_img, turretGlow_img, data.weapon.turretOffsets, sprite )
				EndIf
			Case "hardpoint"
				If data.weapon.numFrames <= 1
					draw_weapon( hardpoint_img,                hardpointUnder_img, hardpointGun_img, hardpointGlow_img, data.weapon.hardpointOffsets, sprite )
				Else ' data.weapon.numFrames > 1
					draw_weapon( hardpoint_img_seq[img_seq_i], hardpointUnder_img, hardpointGun_img, hardpointGlow_img, data.weapon.hardpointOffsets, sprite )
				EndIf
		EndSelect
		'DRAW MODE-SPECIFIC THINGS
		Select ed.mode
			Case "offsets"
				draw_barrel_offsets( data, sprite )
			Case "images"
		EndSelect
	EndMethod

	Method Save( ed:TEditor, data:TData, sprite:TSprite )
		Local path$ = RequestFile( "SAVE Weapon Data", "wpn", True, APP.weapon_dir + data.weapon.id+".weapon" )
		FlushKeys()
		If path
			APP.weapon_dir = ExtractDir( path )+"/"
			APP.save()
			SaveString( data.json_str_weapon, path )
		End If
	EndMethod

	Method Load( ed:TEditor, data:TData, sprite:TSprite )
		Local path$ = RequestFile( "LOAD Weapon Data", "wpn", False, APP.weapon_dir )
		FlushKeys()
		If FileType( path ) <> FILETYPE_FILE Then Return
		APP.weapon_dir = ExtractDir( path )+"/"
		APP.save()
		Local json_str_weapon$ = LoadString( path )
		data.decode_weapon( json_str_weapon )
		data.update_weapon()
		do_draw_barrels = (data.weapon.visualRecoil <> 0)
		load_weapon_images( data, sprite )
	EndMethod


	'this is for the sake of global maths that reference the sprite img for their calcs
	Method update_sprite_img( data:TData, sprite:TSprite )
		Select weapon_display_mode
			Case "turret"
				If data.weapon.numFrames <= 1
					sprite.img = turret_img
				Else ' data.weapon.numFrames > 1
					sprite.img = turret_img_seq[0]
				EndIf
			Case "hardpoint"
				If data.weapon.numFrames <= 1
					sprite.img = hardpoint_img
				Else ' data.weapon.numFrames > 1
					sprite.img = hardpoint_img_seq[0]
				EndIf
		EndSelect
		If sprite.img
			spr_w = sprite.img.width
			spr_h = sprite.img.height
		Else
			spr_w = 0
			spr_h = 0
		EndIf
	EndMethod

	Method update_offsets( ed:TEditor, data:TData, sprite:TSprite )
		sprite.get_img_xy( MouseX(), MouseY(), img_x, img_y )
		If MouseHit( 1 ) And SHIFT
			'add
			data.append_weapon_offset( img_x,img_y, spr_w,spr_h, False )
			If ed.bounds_symmetrical
				data.append_weapon_offset( img_x,img_y, spr_w,spr_h, True )
			EndIf
			data.update_weapon()
		End If
		If Not SHIFT
			'drag
			If MouseDown( 1 )
				If Not ed.mouse_1 'starting drag
					ed.drag_nearest_i = data.find_nearest_weapon_offset( img_x,img_y, spr_w,spr_h, weapon_display_mode )
					ed.drag_mirrored = ed.bounds_symmetrical
					If( ed.drag_mirrored )
						ed.drag_counterpart_i = data.find_symmetrical_weapon_offset_counterpart( ed.drag_nearest_i, weapon_display_mode )
					End If
				Else 'mouse_down_1 'continuing drag
					data.modify_weapon_offset( ed.drag_nearest_i, img_x,img_y, spr_w,spr_h, weapon_display_mode, False )
					If ed.drag_mirrored
						data.modify_weapon_offset( ed.drag_counterpart_i, img_x,img_y, spr_w,spr_h, weapon_display_mode, True )
					End If
				End If
				ed.mouse_1 = True
				data.update_weapon()
			Else 'Not MouseDown( 1 )
				ed.mouse_1 = False
				ed.drag_nearest_i = -1
				ed.drag_counterpart_i = -1
			End If
		End If
		If CONTROL
			'angle
			If MouseDown( 1 )
				If Not ed.mouse_1 'starting operation
					offset_lock_idx = data.find_nearest_weapon_offset( img_x,img_y, spr_w,spr_h, weapon_display_mode )
				EndIf
				data.set_weapon_offset_angle( offset_lock_idx, img_x,img_y, spr_w,spr_h, weapon_display_mode, ed.drag_mirrored )
				data.update_weapon()
			EndIf
		End If
		If KeyHit( KEY_BACKSPACE )
			'remove
			data.remove_nearest_weapon_offset( img_x,img_y, spr_w,spr_h, weapon_display_mode )
			data.update_weapon()
		End If
	EndMethod

	Method try_load_sprite( ed:TEditor, data:TData, sprite:TSprite, weapon_display_mode$, sprite_name$ )
		Local image_path$ = RequestFile( "LOAD Weapon Image", "png", False, APP.images_dir )
		FlushKeys()
		If FILETYPE_FILE = FileType( image_path )
			image_path = image_path.replace( "\", "/" )
			Local scan$ = image_path
			While scan.length > "graphics".length
				scan = ExtractDir( scan )
				If scan.EndsWith( "graphics" )
					Local to_remove$ = ExtractDir( scan )+"/"
					image_path = image_path.Replace( to_remove, "" )
					If image_path.StartsWith( "graphics" )
						Select weapon_display_mode
							Case "turret"
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
							Case "hardpoint"
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
		EndIf
	EndMethod

	Method draw_weapon( main_img:TImage, under_img:TImage, gun_img:TImage, glow_img:TImage, gun_offsets#[], sprite:TSprite )
		SetRotation( 90 )
		SetScale( sprite.scale, sprite.scale )
		SetAlpha( 1 )
		SetColor( 255, 255, 255 )
		'calc. coords
		Local x# = W_MID + sprite.pan_x + sprite.zpan_x
		Local y# = H_MID + sprite.pan_y + sprite.zpan_y
		'hardpoint center point is the bottom of the turret image
		If weapon_display_mode = "hardpoint" And sprite.img
			x :+ float(sprite.img.height) / 2.0
		EndIf
		'draw
		If under_img Then DrawImage( under_img, x, y )
		If main_img Then DrawImage( main_img, x, y )
		If do_draw_barrels And gun_img Then DrawImage( gun_img, x, y )
		If do_draw_glow And glow_img Then DrawImage( glow_img, x, y )
	EndMethod

	Method draw_barrel_offsets( data:TData, sprite:TSprite )
		Local offsetsArray#[]
		If weapon_display_mode = "turret"
			offsetsArray = data.weapon.turretOffsets
		ElseIf weapon_display_mode = "hardpoint"
			offsetsArray = data.weapon.hardpointOffsets
		Else
			Return
		EndIf
		SetImageFont( DATA_FONT )
		Local x#, y#
		For Local i% = 0 Until offsetsArray.length Step 2
			x = W_MID + sprite.pan_x+sprite.zpan_x + sprite.scale*offsetsArray[i+0]
			y = H_MID + sprite.pan_y+sprite.zpan_y + sprite.scale*offsetsArray[i+1]
			If i <> ed.drag_nearest_i
				SetAlpha( 0.50 )
				draw_pointer( x, y, 0, false, 8, 16, $FFFFFF, $000000 )
			Else
				SetAlpha( 0.80 )
				draw_pointer( x, y, 0, false, 10, 20, $FFFFFF, $000000 )
			EndIf
			SetAlpha( 1 )
			draw_string( ""+((i/2)+1), x,y )
		Next
		SetImageFont( FONT )
		SetAlpha( 1 )
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
		img_seq_i = 0
		img_seq_i_ts = millisecs()
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
