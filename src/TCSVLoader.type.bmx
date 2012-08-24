
Type TCSVLoader
	Global EXPLICIT_NULL_PREFIX$ = "___NULL___"
	
	'loads a CSV into a map
	Function Load:TMap( file$, key_field$, csv_rows:TMap=Null, field_order:TList=Null, row_order:TList=Null )
		If Not csv_rows Then csv_rows = CreateMap()
		Local input$ = LoadString( file )
		Local lines$[] = input.Split( "~n" )
		Local fields$[] = csv_split( lines[0] )
		For Local f% = 0 Until fields.length
			fields[f] = Trim( fields[f] )
			If fields[f] = Null
				fields[f] = EXPLICIT_NULL_PREFIX + f
			EndIf
			If field_order
				field_order.AddLast( fields[f] )
			EndIf
		Next
		For Local i% = 1 Until lines.length
			Local row:TMap = CreateMap()
			Local values$[] = csv_split( lines[i] )
			For Local j% = 0 Until fields.length
				If fields[j] = Null Or fields[j] = "" Then Continue
				If j < values.length
					values[j] = Trim( values[j] )
					row.Insert( fields[j], values[j] )
				Else
					row.Insert( fields[j], "" )
				EndIf
			Next
			If row.ValueForKey( key_field ) <> Null And row.ValueForKey( key_field ) <> ""
				'confirm that the row has a valid identifer
				csv_rows.Insert( row.ValueForKey( key_field ), row )
				If row_order
					row_order.AddLast( row.ValueForKey( key_field ))
				EndIf
			EndIf
		Next
		Return csv_rows
	EndFunction

	Function Save_Row( file$, row:TMap, key_field$, field_order:TList )
		Local row_key$ = String( row.ValueForKey( key_field ))
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
			SaveString( file_str, file )
		
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
			SaveString( file_str, file )
		EndIf
	End function

	'like String.Split(",") but ignores commas that are quoted, like so: [0,1,2,"3,,,,",4,5]
	Function csv_split$[]( record$ )
		If record = "" Then Return Null
		Local fields$[] = New String[1]
		Local in_field% = False
		Local cursor% = 0
		Local field_i% = 0
		While cursor < record.Length
			'parse char
			Local char$ = Chr(record[cursor])
			If char = "~q"
				'field escape char
				in_field = Not in_field
			ElseIf char = "," And Not in_field
				'unquoted field separator char
				fields = fields[..(fields.Length + 1)]
				'advance field cursor and data length
				field_i :+ 1
			Else
				'field data
				fields[field_i] :+ char
			EndIf
			'advance data cursor
			cursor :+ 1
		EndWhile
		Return fields
	End Function

	'escapes string data if it contains one or more commas
	Function csv_conservative_escape$( field_data$ )
		If Not field_data.Contains(",")
			Return field_data
		Else
			Return "~q"+field_data+"~q"
		EndIf
	End Function

EndType

