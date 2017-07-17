Type TStarfarerWeapon

' there are only two type of weapon for now.
' specClass = projectile Or specClass = beam

	'essential to both
	Field id$ = "new_weapon"
	Field specClass$ = "projectile"
	Field type_$ = "ENERGY"
	Field size$ = "SMALL"
	Field turretSprite$ = ""
	Field hardpointSprite$ = ""
	Field turretOffsets#[] = [0.0, 0.0]
	Field turretAngleOffsets#[] = [0.0]
	Field hardpointOffsets#[] = [0.0, 0.0]
	Field hardpointAngleOffsets#[] = [0.0]
	Field glowColor#[] = [255.0, 255.0, 255.0, 255.0]
	
	'essential to projectile
	Field projectileSpecId$	= ""
	Field barrelMode$ = "ALTERNATING"
	
	'essential to beam
	Field fringeColor#[] = [255.0, 255.0, 255.0, 255.0]
	Field coreColor#[] = [255.0, 255.0, 255.0, 255.0]
	Field textureType:Object = TEmun.CreateFormString("ROUGH") 'TEmun, TString[]
	
	'optional 	
	Field turretUnderSprite$ = ""
	Field turretGunSprite$ = ""
	Field turretGlowSprite$ = ""
	Field hardpointUnderSprite$ = ""	
	Field hardpointGunSprite$ = ""
	Field hardpointGlowSprite$	= ""
	
	Field fireSoundOne$ = ""
	Field fireSoundTwo$	 = ""
	
	Field everyFrameEffect$ = ""
	
	Field animateWhileFiring% = 1
	Field alwaysAnimate$ = 0
	Field numFrames% = 1
	Field frameRate# = 1
	
	Field renderHints:TArray = New TArray
	Field renderBelowAllWeapons% = 0
	Field showDamageWhenDecorative% = 0
	Field displayArcRadius# = 0 ' default is 250 but meh
	
	Field specialWeaponGlowHeight# = 0 ' default is 0 but meh
	Field specialWeaponGlowWidth# = 0 ' default is 0 but meh
	
	'optional, projectile only
	Field animationType$ = "NONE"
	Field visualRecoil# = 0.0
	Field separateRecoilForLinkedBarrels% = 0
	
	Field interruptibleBurst% = 0
	Field autocharge% = 0
	Field requiresFullCharge% = 1
	
	Field muzzleFlashSpec:TStarfarerWeaponMuzzleFlashSpec
	Field smokeSpec:TStarfarerWeaponSmokeSpec
	
	'optional, beam only
	Field beamEffect$ = ""
	
	Field beamFireOnlyOnFullCharge%	= 0
	Field convergeOnPoint%	= 0
	
	Field width# = 10.0
	Field textureScrollSpeed# = 64.0
	Field pixelsPerTexel# = 1.0
	Field hitGlowRadius# = 0.0
	Field darkCore% = 0
	
	Field collisionClass$ = "RAY"
	Field collisionClassByFighter$ = "RAY_FIGHTER"
	Field pierceSet:TArray = New TArray
	
	Method New()
		
	End Method
	
	Method draw_order#()
		Select size
		Case "LARGE"
			Return 3
		Case"MEDIUM"
			Return 2
		Case "SMALL"
			Return 1
		End Select
		Return 0
	End Method
	
	Method check_render_barrel_below%()
		If Not renderHints Then Return False
		For Local o:Object = EachIn renderHints.elements
			If o.tostring().Contains("RENDER_BARREL_BELOW") Then Return True
		Next
		Return False
	End Method	
EndType



Function predicate_omit_if_single_frame%( val:TValue, root:TValue )
	'omit val if numFrames <= 1 or does not exist
	Local numFrames:TNumber = TNumber(TObject(root).Get("numFrames"))
	If numFrames <> Null
		Return numFrames.value <= 1.0
	Else
		Return True
	EndIf
EndFunction

Function predicate_omit_if_single_barrel%( val:TValue, root:TValue )
	'omit val if turretAngleOffsets.length <= 1
	Local turretAngleOffsets:TArray = TArray(TObject(root).Get("turretAngleOffsets"))
	Return turretAngleOffsets.elements.Count() <= 1
EndFunction

Function predicate_omit_if_no_muzzle_flash%( val:TValue, root:TValue )
	'omit muzzleFlashSpec if animationType != MUZZLE_FLASH
	Local animationType:TString = TString(TObject(root).Get("animationType"))
	Return (animationType.value <> "MUZZLE_FLASH" And animationType.value <> "GLOW_AND_FLASH")
EndFunction

Function predicate_omit_if_no_smoke%( val:TValue, root:TValue )
	'omit muzzleFlashSpec if animationType != MUZZLE_FLASH
	Local animationType:TString = TString(TObject(root).Get("animationType"))
	Return animationType.value <> "SMOKE"
EndFunction

Function predicate_omit_if_no_glow%( val:TValue, root:TValue )
	'omit muzzleFlashSpec if animationType != MUZZLE_FLASH
	Local animationType:TString = TString(TObject(root).Get("animationType") )
	Local specClass:TString = TString(TObject(root).Get("specClass") )
	Return (specClass.value <> "beam" And animationType.value <> "GLOW" And animationType.value <> "GLOW_AND_FLASH")
EndFunction

'Function predicate_omit_if_not_type_energy%( val:TValue, root:TValue )
'	'omit val if type != ENERGY
'	Local type_:TString = TString(TObject(root).Get("type"))
'	Return type_.value <> "ENERGY"
'EndFunction
'
'Function predicate_omit_if_not_type_missile%( val:TValue, root:TValue )
'	'omit val if type != ENERGY
'	Local type_:TString = TString(TObject(root).Get("type"))
'	Return type_.value <> "MISSILE"
'EndFunction
'
'Function predicate_omit_if_not_type_ballistic%( val:TValue, root:TValue )
'	'omit val if type != ENERGY
'	Local type_:TString = TString(TObject(root).Get("type"))
'	Return type_.value <> "BALLISTIC"
'EndFunction

Function predicate_omit_if_not_specClass_beam%( val:TValue, root:TValue )
	'omit val if specClass != beam
	Local specClass:TString = TString(TObject(root).Get("specClass") )
	Return specClass.value <> "beam"
EndFunction
	
Function predicate_omit_if_not_specClass_projectile%( val:TValue, root:TValue )
	'omit val if specClass != beam
	Local specClass:TString = TString(TObject(root).Get("specClass") )
	Return specClass.value <> "projectile"
EndFunction

