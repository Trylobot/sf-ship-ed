
Type TCSVLoader
	
	'loads a CSV into a map
	Function Load:TMap( file$, key_field$, csv_rows:TMap=Null, field_order:TList=Null, row_order:TList=Null )
		If Not csv_rows Then csv_rows = CreateMap()
		Local input$ = LoadString( file )
		Local lines$[] = input.Split( "~n" )
		Local fields$[] = lines[0].Split( "," )
		For Local f% = 0 Until fields.length
			fields[f] = Trim( fields[f] )
			fields[f] = strip_paired_quotes( fields[f] )
			If field_order And fields[f] <> Null And fields[f] <> ""
				field_order.AddLast( fields[f] )
			EndIf
		Next
		For Local i% = 1 Until lines.length
			Local row:TMap = CreateMap()
			Local values$[] = lines[i].Split( "," )
			For Local j% = 0 Until fields.length
				If fields[j] = Null Or fields[j] = "" Then Continue
				If j < values.length
					values[j] = Trim( values[j] )
					values[j] = strip_paired_quotes( values[j] )
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
				file_str :+ csv_field
				i :+ 1
			Next
			file_str :+ "~n"
			i = 0
			For csv_field = EachIn field_order
				If i > 0 Then file_str :+ ","
				file_str :+ String( row.ValueForKey( csv_field ))
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
				file_str :+ csv_field
				i :+ 1
			Next
			file_str :+ "~n"
			For row_key = EachIn row_order
				row = TMap( csv_rows.ValueForKey( row_key ))
				i = 0
				For csv_field = EachIn field_order
					If i > 0 Then file_str :+ ","
					file_str :+ String( row.ValueForKey( csv_field ))
					i :+ 1
				Next
				file_str :+ "~n"
			Next
			SaveString( file_str, file )
		EndIf
	End function

	Function strip_paired_quotes$( val$ )
		If val.StartsWith( "~q" ) And val.EndsWith( "~q" )
			val = val[(1)..(val.length-1)]
		EndIf
		Return val
	EndFunction

EndType

