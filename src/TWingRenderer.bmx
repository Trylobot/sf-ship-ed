Type TWingRenderer	
	Field buffed_img:TMap 'String (img_path) --> TImage
	Field mockString$ = "~n" + "~n" + "~n" + "~n"
	Field mockTextWidget:TextWidget = TextWidget.Create(mockString)
	Field wingIconConSize% = 90
	Field wingIconsPerColumn% =4
	
	Method New()
		buffed_img = CreateMap()
	End Method
	
	
	Method draw_all_wings(ed:TEditor, data:TData , built_in_only% = False)
			For Local i% = 0 Until data.get_fighterbays_count()
			If i < data.ship.builtInWings.length
				draw_fighter_icons(data.ship.builtInWings[i], i, ed , True)				
			Else If Not built_in_only And i < data.ship.builtInWings.length + data.variant.wings.length
				draw_fighter_icons(data.variant.wings[i - data.ship.builtInWings.length], i, ed)
			Else
				draw_fighter_icons(Null, i, ed)
			EndIf
		Next	
	End Method
	
	Method draw_fighter_icons(wingID$, index%, ed:TEditor, builtin% = False)
		If index < 0 Then Return
		If builtin Then draw_container( 7 + ( (wingIconConSize + 7) * (index / wingIconsPerColumn) ), LINE_HEIGHT * 2 + 20 + mockTextWidget.h + ( (wingIconConSize + 7) * (index Mod wingIconsPerColumn) ), wingIconConSize, wingIconConSize, 0.0, 0.0, $FFFFFF, $FFFFFF, 0.1) Else draw_container( 7 + ( (wingIconConSize + 7) * (index / wingIconsPerColumn) ), LINE_HEIGHT * 2 + 20 + mockTextWidget.h + ( (wingIconConSize + 7) * (index Mod wingIconsPerColumn) ), wingIconConSize, wingIconConSize, 0.0, 0.0 )
		draw_fighters(wingID, 7 + ( (wingIconConSize + 7) * ( (index / wingIconsPerColumn) + 0.5) ), LINE_HEIGHT * 2 + 20 + mockTextWidget.h + ( (wingIconConSize + 7) * ( (index Mod wingIconsPerColumn) + 0.5) ), 0.6, ed)
	End Method
	
	Method draw_fighters( wingID$, x#, y#, scale#, ed:TEditor )
		Local num%
		Local formation$
		Local img_path$
		getWingData(wingID, img_path, num, formation, ed)
		
		If num < 1 Then Return
		Local wingSprite:TImage = getSpriteByPath(img_path)		
		If Not wingSprite Then Return		
		SetRotation( 90 )
		SetAlpha( 1 )
		SetColor( 255, 255, 255 )
		SetScale( scale, scale )
		Local size% = Max( wingSprite.width, wingSprite.height )
		'positions
		Local f_x# = x
		Local f_y# = y
		Local sep# = scale * size / 1.41
		Select formation
			Case "V"
				If num > 6 Then num = 6
				If num >= 6 Then DrawImage( wingSprite, f_x - 3 * Int(0.75 * sep), f_y - 3 * sep )
				If num >= 5 Then DrawImage( wingSprite, f_x - 2 * Int(0.75 * sep), f_y + 2 * sep )
				If num >= 4 Then DrawImage( wingSprite, f_x - 2 * Int(0.75 * sep), f_y - 2 * sep )
				If num >= 3 Then DrawImage( wingSprite, f_x - Int(0.75 * sep), f_y + sep )
				If num >= 2 Then DrawImage( wingSprite, f_x - Int(0.75 * sep), f_y - sep )
				If num >= 1 Then DrawImage( wingSprite, f_x, f_y )
			Case "CLAW"
				If num > 6 Then num = 6				
				If num >= 6 Then DrawImage( wingSprite, f_x + Int(2.25 * sep), f_y + Int(2.25 * sep) )
				If num >= 5 Then DrawImage( wingSprite, f_x + Int(2.25 * sep), f_y - Int(2.25 * sep) )
				If num >= 4 Then DrawImage( wingSprite, f_x + 0.5 * Int(0.75 * sep), f_y + Int(1.5 * sep) )
				If num >= 3 Then DrawImage( wingSprite, f_x + 0.5 * Int(0.75 * sep), f_y - Int(1.5 * sep) )
				If num >= 2 Then DrawImage( wingSprite, f_x, f_y + Int(0.5 * sep) )
				If num >= 1 Then DrawImage( wingSprite, f_x, f_y - Int(0.5 * sep) )
			Case "BOX"
				If num > 6 Then num = 6
				If num >= 6 Then DrawImage( wingSprite, f_x - sep, f_y + Int(0.5 * sep) )
				If num >= 5 Then DrawImage( wingSprite, f_x - sep, f_y)
				If num >= 4 Then DrawImage( wingSprite, f_x - Int(0.5 * sep), f_y + Int(0.5 * sep) )
				If num >= 3 Then DrawImage( wingSprite, f_x , f_y + Int(0.5 * sep) )
				If num >= 2 Then DrawImage( wingSprite, f_x - Int(0.5 * sep), f_y )
				If num >= 1 Then DrawImage( wingSprite, f_x, f_y )
			Case "DIAMOND"
				If num > 6 Then num = 6
				If num >= 6 Then DrawImage( wingSprite, f_x + sep, f_y - sep)
				If num >= 5 Then DrawImage( wingSprite, f_x - sep, f_y - sep)				
				If num >= 4 Then DrawImage( wingSprite, f_x , f_y - sep)
				If num >= 3 Then DrawImage( wingSprite, f_x + Int(0.5 * sep), f_y - Int(0.5 * sep) )
				If num >= 2 Then DrawImage( wingSprite, f_x - Int(0.5 * sep), f_y - Int(0.5 * sep) )
				If num >= 1 Then DrawImage( wingSprite, f_x, f_y )								
		EndSelect
		SetScale( 1, 1 )
	EndMethod	
	
	Method getWingData(wingID$, spritePath$ Var, num% Var, formation$ Var, ed:TEditor)
		Local wingRow:TMap = TMap(ed.stock_wing_stats.ValueForKey(wingID) )
		If wingRow
			Local variantID$ = String(wingRow.ValueForKey("variant") )
			If variantID
				spritePath = resource_search(ed.getVariantSpritePath(variantID)	)
			EndIf 					
			num = Int (String(wingRow.ValueForKey("num") ) )
			formation = String(wingRow.ValueForKey("formation") )
		EndIf
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
EndType