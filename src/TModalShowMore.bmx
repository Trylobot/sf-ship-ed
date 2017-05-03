
Type TModalShowMore Extends TSubroutine
	Field i%

	
	Method Activate( ed:TEditor, data:TData, sprite:TSprite )
		DebugLogFile(" Showing More Fields")
		if SHOW_MORE = 0
			SHOW_MORE = 1
		ElseIf SHOW_MORE = 1
			SHOW_MORE = 2
		ElseIf SHOW_MORE = 2
			SHOW_MORE = 0
		EndIf
	EndMethod

	Method Update( ed:TEditor, data:TData, sprite:TSprite )
		
	EndMethod

	Method Draw( ed:TEditor, data:TData, sprite:TSprite )
		
	EndMethod

	Method Save( ed:TEditor, data:TData, sprite:TSprite )
	EndMethod

	Method Load( ed:TEditor, data:TData, sprite:TSprite )
	EndMethod

	Method update_bounds_coords( data:TData, sprite:TSprite )
		
	EndMethod

EndType

