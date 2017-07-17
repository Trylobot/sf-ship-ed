
Type TCSVLoader
	Global EXPLICIT_NULL_PREFIX$ = "___NULL___"
	
	'loads a CSV into a map
	Function Load%( file$, key_field$, csv_rows:TMap = Null, field_order:TList = Null, row_order:TList = Null )
		Local rows_loaded% = 0
		If Not csv_rows Then csv_rows = CreateMap()
		'Local Input$ = LoadString( file )
		Local Input$ = LoadTextAs ( file , CODE_MODE)
		Local csv_data$[][] = csv_parse( Input )
		Local fields$[] = csv_data[0]
		For Local f% = 0 Until fields.length
			'DebugLog(fields[f])
			fields[f] = Trim( fields[f] )
			'DebugLog(fields[f])
			If fields[f] = Null
				fields[f] = EXPLICIT_NULL_PREFIX + f
			EndIf
			If field_order Then field_order.AddLast( fields[f] )
		Next
		Local key$
		For Local i% = 1 Until csv_data.length
			Local row:TMap = CreateMap()
			Local values$[] = csv_data[i]
			For Local j% = 0 Until fields.length
				If fields[j] = Null Or fields[j] = "" Then Continue
				If j < values.length
					values[j] = Trim( values[j] )
					row.Insert( fields[j], values[j] )
					'DebugLog(fields[j] + " " + values[j])					
				Else
					row.Insert( fields[j], "" )
				EndIf
			Next
			key = String( row.ValueForKey( key_field ))
			If key
				'confirm that the row has a valid identifer
				If Not csv_rows.Contains( key )
					rows_loaded :+ 1
				Else
					DebugLogFile(" warning: duplicate key: "+key+" ["+file+"]") ' in-game, this would be an error: duplicate key
				EndIf
				csv_rows.Insert( key, row )
				If row_order Then row_order.AddLast( key )
			EndIf
		Next
		Return rows_loaded
	EndFunction

	Function Save_Row( file$, row:TMap, key_field$, field_order:TList )
		Local row_key$ = String( row.ValueForKey( key_field ) )

		If Not row_key Or row_key = "" Then Return
		Local ftype% = FileType( file )
		Local i%, csv_field$
		
		If ftype = 0 'File not found
			'if file does not exist, create new CSV. -END-
			Local file_str$ = ""
			i = 0
			For csv_field = EachIn field_order
				If i > 0 Then file_str :+ ","
				If Not csv_field.StartsWith( EXPLICIT_NULL_PREFIX )
					file_str :+ csv_conservative_escape( csv_field ) ' skip these
				EndIf
				i :+ 1
			Next
			file_str :+ "~n"
			i = 0
			For csv_field = EachIn field_order
				If i > 0 Then file_str :+ ","
				file_str :+ csv_conservative_escape( String( row.ValueForKey( csv_field )))
				i :+ 1
			Next
			file_str :+ "~n"
			'SaveString( file_str, file )
			SaveTextAs ( file_str, file, CODE_MODE)
		
		ElseIf ftype = FILETYPE_FILE
			'else load the data at that location into a separate TMap
			'and load the ID's into a row-order 
			Local csv_rows:TMap = CreateMap()
			Local field_order:TList = CreateList()
			Local row_order:TList = CreateList()
			Load( file, key_field, csv_rows, field_order, row_order )
			'if file does not contain the id, insert it and write the file. -END-
			'else replace the existing id and write the file. -END-
			If Not csv_rows.Contains( row_key )
				row_order.AddLast( row_key )
			EndIf
			csv_rows.Insert( row_key, row )
			Local file_str$ = ""
			i = 0
			For csv_field = EachIn field_order
				If i > 0 Then file_str :+ ","
				If Not csv_field.StartsWith( EXPLICIT_NULL_PREFIX )
					file_str :+ csv_conservative_escape( csv_field )
				EndIf
				i :+ 1
			Next
			file_str :+ "~n"
			For row_key = EachIn row_order
				row = TMap( csv_rows.ValueForKey( row_key ))
				i = 0
				For csv_field = EachIn field_order
					If i > 0 Then file_str :+ ","
					file_str :+ csv_conservative_escape( String( row.ValueForKey( csv_field )))
					i :+ 1
				Next
				file_str :+ "~n"
			Next
			SaveTextAs ( file_str, file, CODE_MODE)
		EndIf
	End Function

	Function csv_parse$[][]( data$ )
		If data = "" Then Return Null
		Local records$[][] = New String[][1]
		records[0] = New String[1]
		Local c% = 0 ' data string cursor
		Local l% = 0 ' data string cursor (reset each linebreak, for comments)
		Local fl% = 0 ' field length counter
		Local r% = 0 ' record/row counter
		Local f% = 0 ' field/value counter
		Local char$ ' current character string
		Local in_quotes% = False ' current quoted/escaped state
		Local in_comment% = False ' comment state
		While c < data.Length
			'parse char
			char = Chr(data[c])
			'DebugLog(char)
			'DebugLog(l + "")
			If char = "#" And l = 0 And Not in_quotes
				in_comment = True
				'DebugStop
			ElseIf char = "~q" And Not in_comment
				'field escape char
				in_quotes = Not in_quotes
			ElseIf char = "," And Not in_quotes And Not in_comment
				'advance field counter
				records[r][f] = Mid(data, c - fl + 1, fl)
				'DebugLog(f + " " + c + " " + fl + " " + records[r][f])
				f :+ 1
				records[r] = records[r][..(f + 1)]
				fl = - 1
			ElseIf char = "~r" Or char = "~n" And Not in_quotes
			'DebugStop
				'unquoted record separator char
				records[r][f] = Mid(data, c - fl + 1, fl)
				If char = "~r" And (c + 1) < data.length And Chr(data[c + 1]) = "~n"
					'ignore "~r~n" (windows)
					c :+ 1
				EndIf				
				'advance record counter
				r :+ 1
				records = records[..(r + 1)]
				records[r] = New String[1]
				f = 0
				'If in_comment Then 	DebugStop
				in_comment = False
				l = - 1
				fl = - 1
			'ElseIf Not in_comment
				'field data
			'	records[r][f] :+ char
			EndIf
			'advance data cursor
			c :+ 1
			l :+ 1
			fl :+ 1
		EndWhile
		Return records
	End Function

	'escapes string data if it contains one or more field-separators or record-separators
	Function csv_conservative_escape$( field_data$ )
		If  Not field_data.Contains(",") ..
		And Not field_data.Contains("~r") ..
		And Not field_data.Contains("~n")
			Return field_data
		Else
			If Not field_data.Contains("~q")
				Return "~q"+field_data+"~q"
			Else
				Return field_data
			EndIf
		EndIf
	End Function

EndType

