'-----------------------

Type TextWidget
	Field lines$[]
	Field w%
	Field h%
	
	Function Create:TextWidget( obj:Object, line_height_override% = - 1 )
		Local w:TextWidget = New TextWidget
		If TextWidget(obj)
			w.lines = TextWidget(obj).lines[..]
			w.update_size( line_height_override )
		ElseIf String[](obj)
			w.lines = String[](obj)
			w.update_size( line_height_override )
		Else 'assume string, or zero-length string (null)
			w.set( String(obj) )
		End If
		Return w
	End Function
	
	Method set( str$ )
		lines = str.Split("~n")
		update_size()
	End Method
	
	Method update_size( line_height_override% = - 1 )
		If line_height_override = -1 Then line_height_override = LINE_HEIGHT
		w = 0
		For Local line$ = EachIn lines
			w = Max( w, TextWidth( line ) )
		Next
		h = lines.length * line_height_override
	End Method
	
	Method append( widget:TextWidget )
		w = Max( w, widget.w )
		h :+ widget.h
		Local old_length% = lines.length
		lines = lines[..(lines.length + widget.lines.length)]
		For Local L% = 0 Until widget.lines.length
			lines[L + old_length] = widget.lines[L]
		Next
	End Method

	Method draw( x#,y#, ox#,oy# )
		Local p# = 10 ' padding
		Local fg% = $FFFFFF
		Local bg% = $000000
		Local bg_fill_alpha# = 0.75
    Local s# = 1.0 ' scale
		draw_container( x,y, w+(2*p),h+(2*p), ox,oy, fg,bg,bg_fill_alpha, s )
		draw_string( Self, x,y+p, fg,bg, ox,oy )
		SetColor(255,255,255)
		SetAlpha(1)
	EndMethod

End Type
