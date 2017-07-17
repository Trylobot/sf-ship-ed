'-----------------------

Type TSprite
	'image
	Field img:TImage
	'zoom and pan
	Field scale#
	Field pan_x#, pan_y#
	Field zpan_x#, zpan_y#
	'actual bounds, translated to screen coordinates
	Field sx#, sy#
	Field sw#, sh#
	Field asx#, asy#	
	
	Method update()
		If img <> NUll
			find_rect_verts( W_MID, H_MID, 0, 0, scale, pan_x, pan_y, zpan_x, zpan_y, asx, asy, sw, sh )
			find_rect_verts( W_MID, H_MID, img.height, img.width, scale, pan_x, pan_y, zpan_x, zpan_y, sx, sy, sw, sh )
		Else
			find_rect_verts( W_MID, H_MID, 0, 0, scale, pan_x, pan_y, zpan_x, zpan_y, sx, sy, sw, sh )
			asx = sx
			asy = sy
		End If
	EndMethod
	
	Method get_img_xy( mouse_x#, mouse_y#, img_x# Var, img_y# Var, round% = True )
		map_xy( mouse_x, mouse_y, img_x, img_y, sx, sy, scale, round )
	EndMethod
	
	Method get_xy( mouse_x#, mouse_y#, img_x# Var, img_y# Var, round% = True )
		map_xy( mouse_x, mouse_y, img_x, img_y, asx, asy, scale, round )
	EndMethod
	
	'map the "ship center" to real screen coordinates
	Method xform_ship_c_to_scr( c#[], x% Var, y% Var )
		x = sx + c[1] * scale
		y = sy + c[0] * scale
	EndMethod

	'using the given center, map the "ship entity location" to real screen coordinates
	Method xform_ship_ent_to_scr( c#[], e#[], e_i% = 0, x% Var, y% Var )
		If Not c Then Return
		x = sx + e[e_i + 0] * scale + c[1] * scale
		y = sy + e[e_i + 1] * scale + c[0] * scale
	EndMethod
	
End Type

