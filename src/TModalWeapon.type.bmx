
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
	'animated images
	Field turret_img_seq:TImage[]
	Field hardpoint_img_seq:TImage[]
	Field img_seq_i%


	Method Activate( ed:TEditor, data:TData, sprite:TSprite )
		data.update_weapon()
		load_weapon_images( data )
	EndMethod

	Method Update( ed:TEditor, data:TData, sprite:TSprite )
	EndMethod

	Method Draw( ed:TEditor, data:TData, sprite:TSprite )
		'DrawImage( sprite.img, W_MID + sprite.pan_x + sprite.zpan_x, H_MID + sprite.pan_y + sprite.zpan_y )
	EndMethod

	Method Save( ed:TEditor, data:TData, sprite:TSprite )
	EndMethod

	Method Load( ed:TEditor, data:TData, sprite:TSprite )
	EndMethod

	Method load_weapon_images( data:TData )
		Local img_path$ = Null
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
				turret_img_seq = New TImage[ data.weapon.numFrames ]
				img_path = resource_search( data.weapon.turretSprite )
				If img_path Then turret_img_seq[0] = LoadImage( img_path, 0 )
				'load rest of sequence
			EndIf
			If data.weapon.hardpointSprite
				hardpoint_img_seq = New TImage[ data.weapon.numFrames ]
				img_path = resource_search( data.weapon.hardpointSprite )
				If img_path Then hardpoint_img_seq[0] = LoadImage( img_path, 0 )
				'load rest of sequence
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
	EndMethod

EndType
