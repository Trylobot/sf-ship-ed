Const INFINITY% = - 1

Type CONSOLE
	'Global last_bk%
	
	Global CONSOLE_last_str$
	Field i%
	
	Function Update$( str$, max_size% = INFINITY, cursor_i% Var, modified% Var )
		If str <> CONSOLE_last_str Then i = str.length Else i = cursor_i
		Select EventID()
		Case EVENT_KEYDOWN, EVENT_KEYREPEAT
			Select EventData()
			Case KEY_BACKSPACE
				If i > 0
					str = str[..(i - 1)] + str[i..]
					i:- 1
					modified = True
				EndIf
			Case KEY_DELETE
				If i < str.length
					str = str[..(i)] + str[(i + 1)..]
					modified = True
				EndIf
			Case KEY_LEFT
				If i > 0 Then i :- 1
			Case KEY_RIGHT
				If i < str.length Then i :+ 1
			Default
				If PeekEvent() And PeekEvent().id = EVENT_KEYCHAR 'we got some valid input.
					If max_size = INFINITY Or str.length < max_size
						str = str[..i] + Chr( PeekEvent().data) + str[i..]
						i :+ 1
						modified = True
					EndIf
				EndIf
			EndSelect
		End Select
		cursor_i = i
		CONSOLE_last_str = str
		Return str
	End Function
	
	
	
Rem
	Function Update$( str$, max_size% = INFINITY, modified% Var )
		'remove characters from the end of th estring
		If KeyHit( KEY_BACKSPACE ) And str.length >= 1 '.. 'erase character left of cursor and move cursor left
			str = str[..(str.length - 1)]
			modified = True
			last_bk = MilliSecs()
		End If
		If KeyDown( KEY_BACKSPACE )
			If last_bk <> - 1 And ( (MilliSecs() - last_bk) > 333) 'repeat delay 1/3 second, repeat rate once per frame
				str = str[..(str.Length-1)]
				modified = True
			EndIf
		Else
			last_bk = - 1
		EndIf
		'normal input
		If max_size = INFINITY Or str.Length < max_size
			Local char$ = get_char()
			If char
				modified = True
				str :+ char
			End If
		End If
		Return str
	End Function
	
	Function flush_all()
		For Local index% = 0 To keys.Length-1
			KeyHit( keys[index] )
		Next
	End Function
	
	Global chars_Ucase$[] = [ ..
		")", "!", "@", "#", "$", "%", "^", "&", "*", "(", "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", ..
		"Q", "W", "E", "R", "T", "Y", "U", "I", "O", "P", "A", "S", "D", "F", "G", "H", "J", "K", "L", "Z", "X", "C", "V", "B", "N", "M", ..
		"~~", "_", "+", "{", "}", "|", ".", "+", "-", "*", "/", ":", "~q", "<", ">", "?", " " ]
	Global chars_Lcase$[] = [ ..
		"0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", ..
		"q", "w", "e", "r", "t", "y", "u", "i", "o", "p", "a", "s", "d", "f", "g", "h", "j", "k", "l", "z", "x", "c", "v", "b", "n", "m", ..
		"`",  "-", "=", "[", "]", "\", ".", "+", "-", "*", "/", ";", "'",  ",", ".", "/", " " ]
	Global keys%[] = [ ..
		KEY_0, KEY_1, KEY_2, KEY_3, KEY_4, KEY_5, KEY_6, KEY_7, KEY_8, KEY_9, KEY_NUM0, KEY_NUM1, KEY_NUM2, KEY_NUM3, KEY_NUM4, KEY_NUM5, KEY_NUM6, KEY_NUM7, KEY_NUM8, KEY_NUM9, ..
		KEY_Q, KEY_W, KEY_E, KEY_R, KEY_T, KEY_Y, KEY_U, KEY_I, KEY_O, KEY_P, KEY_A, KEY_S, KEY_D, KEY_F, KEY_G, KEY_H, KEY_J, KEY_K, KEY_L, KEY_Z, KEY_X, KEY_C, KEY_V, KEY_B, KEY_N, KEY_M, ..
		KEY_TILDE, KEY_MINUS, KEY_EQUALS, KEY_OPENBRACKET, KEY_CLOSEBRACKET, KEY_BACKSLASH, KEY_NUMDECIMAL, KEY_NUMADD, KEY_NUMSUBTRACT, KEY_NUMMULTIPLY, KEY_NUMDIVIDE, KEY_SEMICOLON, KEY_QUOTES, KEY_COMMA, KEY_PERIOD, KEY_SLASH, KEY_SPACE ]
	
	Function get_char$() 'returns Null if none, or a string representing the character of the key pressed
		Local upper_case% = False
		If KeyDown( KEY_LSHIFT ) Or KeyDown( KEY_RSHIFT ) Then upper_case = True
		For Local index% = 0 To keys.Length-1
			If KeyHit( keys[index] )
				If upper_case
					Return chars_Ucase[index]
				Else
					Return chars_Lcase[index]
				End If
			End If
		Next
		Return Null
	End Function
EndRem
End Type

