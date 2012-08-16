Type TKeyboardHelpWidget
	Field key$
	Field desc$
	Field show_key_as_icon%
	Field enabled%
	Field margin_bottom%
	Field program_mode$
	Field sub_mode$
	
	Function Create:TKeyboardHelpWidget( key$, desc$, show_key_as_icon%, enabled%, margin_bottom%, program_mode$=Null, sub_mode$=Null )
		Local w:TKeyboardHelpWidget = New TKeyboardHelpWidget
		w.key = key
		w.desc = desc
		w.show_key_as_icon = show_key_as_icon
		w.enabled = enabled
		w.margin_bottom = margin_bottom
		w.program_mode = program_mode
		w.sub_mode = sub_mode
		Return w
	End Function
End Type

