'-----------------------

Type TSprite
	'image
	Field img:TImage
	'zoom and pan
	Field scale#
	Field pan_x#, pan_y#
	'actual bounds, translated to screen coordinates
	Field sx#, sy#
	Field sw#, sh#
	
	Method update()
		If img
			sx = Float(W_MID) - 0.5*scale*Float(img.height) + pan_x
			sy = Float(H_MID) - 0.5*scale*Float(img.width) + pan_y
			sw = scale*Float(img.height)
			sh = scale*Float(img.width)
		Else
			sx = Float(W_MID) + pan_x
			sy = Float(H_MID) + pan_y
			sw = 0
			sh = 0
		End If
	EndMethod
	
	Method get_img_xy( mouse_x#, mouse_y#, img_x# Var, img_y# Var, round% = True )
		img_x = (mouse_x - sx) / scale
		img_y = (mouse_y - sy) / scale
		If round
			img_x = nearest_half( img_x )
			img_y = nearest_half( img_y )
		End If
	EndMethod

	'(FAILURE #6) does not work as intended
	Method pan_to( mouse_x#, mouse_y#, img_x_target#, img_y_target# )
		'alter pan_x/y so that get_img_xy() returns the given img_x, img_y
		pan_x = scale*img_x_target + Float(W_MID) - 0.5*scale*Float(img.height) - mouse_x
		pan_y = scale*img_y_target + Float(H_MID) - 0.5*scale*Float(img.width) - mouse_y
		Rem
		?Debug
		update()
		Local img_x#, img_y#
		get_img_xy( mouse_x, mouse_y, img_x, img_y )
		mouse_str :+ coord_string( img_x_target - img_x, img_y_target - img_y )
		?
		EndRem
	EndMethod

	'map the "ship center" to real screen coordinates
	Method xform_ship_c_to_scr( c#[], x% Var, y% Var )
		x = sx + c[1]*scale
		y = sy + c[0]*scale
	EndMethod

	'using the given center, map the "ship entity location" to real screen coordinates
	Method xform_ship_ent_to_scr( c#[], e#[], e_i%=0, x% Var, y% Var )
		If Not c Then Return
		x = sx + e[e_i+0]*scale + c[1]*scale
		y = sy + e[e_i+1]*scale + c[0]*scale
	EndMethod
	
End Type

