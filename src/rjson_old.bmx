' bmx-rjson
'   reflection-based JSON encoder/decoder
'   by Tyler W.R. Cole
'   written according to the JSON specification http://www.json.org
'   with the following minor modifications(s):
'   - when decoding, it is okay for numbers to have any number of leading zeroes
'   - when decoding, it is okay for floating-point numbers to have a trailing 'f'
'   - when decoding, the '#' character outside of a string is treated as a single-line comment
'   - when decoding, it is okay for string values to be unquoted, as long as they only contain the following characters:
'     A-Za-z_0-9, and do not start with a number
'   - when decoding, a semicolon is an acceptable substitute for a comma

SuperStrict
'Module twrc.rjson
Import brl.reflection
Import brl.retro
Import brl.linkedlist
Import brl.map


Type JSON
	
	'///////////
	'  public
	'///////////
	
	'Generate a JSON-String from an object
	Function Encode:String( source_object:Object, settings:TJSONEncodeSettings = Null, override_type:TTypeId = Null, indent% = 0 )
		If Not settings
			settings = New TJSONEncodeSettings
		End If
		If Not source_object
			Return VALUE_NULL
		Else 'source_object <> Null
			Local encoded_json_data:String = ""
			Local source_object_type_id:TTypeId
			If override_type
				source_object_type_id = override_type
			Else
				source_object_type_id = TTypeId.ForObject( source_object )
			End If
			Local type_metadata:TJSONTypeSpecificMetadata = settings.GetTypeMetadata( source_object_type_id )
			If type_metadata.IsCustomEncoderDefined()
				encoded_json_data :+ type_metadata.custom_encoder( source_object, settings, override_type, indent )
			Else 'no custom encoder; decide what to do intelligently
				encoded_json_data :+ _EncodeObject( source_object, settings, source_object_type_id, indent )
			End If
			Return encoded_json_data
		End If
	End Function
	
	' Parse a JSON-String and populate an object
	Function Decode:Object( encoded_json_data:String, settings:TJSONDecodeSettings = Null, typeId:TTypeId = Null )
		If encoded_json_data = "" Then Return Null
		If Not settings
			settings = New TJSONDecodeSettings
		End If
		Local cursor% = 0
		If typeId
			Local decoded_object:Object
			If Not typeId.ElementType() 'non-array type provided
				Local json_object:TMap = _DecodeJSONObject( encoded_json_data, cursor )
				If json_object
					Return _InitializeObject( json_object, settings, typeId )
				Else
					Throw( " Error: an object is desired, but an array was found" )
					Return Null
				End If
			Else 'array type provided
				Local json_array:TList = _DecodeJSONArray( encoded_json_data, cursor )
				If json_array
					Return _InitializeArray( json_array, settings, typeId )
				Else
					Throw( " Error: an array is desired, but an object was found" )
				End If
			End If
			Return decoded_object
		Else 'no typeId provided; return raw data
			Return _DecodeJSONValue( encoded_json_data, cursor )
		End If
	End Function
	
	Function ObjectInfo$( obj:Object )
		If obj <> Null
			Return "0x" + Hex( Int( Byte Ptr( obj ))) + ":" + TTypeId.ForObject( obj ).Name()
		Else
			Return "0x" + Hex( 0 )
		End If
	End Function
	
	'///////////
	'  private
	'///////////
	
	Function _EncodeObject:String( source_object:Object, settings:TJSONEncodeSettings, source_object_type_id:TTypeId, indent% = 0 )
		Local encoded_json_data:String = ""
		Local type_metadata:TJSONTypeSpecificMetadata = settings.GetTypeMetadata( source_object_type_id )
		'Local is_array% = source_object_type_id.ElementType <> Null Or source_object_type_id.ExtendsType( ArrayTypeId ) Or source_object_type_id.Name().Contains("[")
		Local is_array% = source_object_type_id = ArrayTypeId Or source_object_type_id.ExtendsType( ArrayTypeId )
		If Not is_array 'Non-Array Type
			Select source_object_type_id
				Case StringTypeId
					encoded_json_data :+ STRING_BEGIN
					encoded_json_data :+ _StringEscape( source_object.ToString() )
					encoded_json_data :+ STRING_END
				Default 'User-Defined-Type
					If Not source_object
						encoded_json_data :+ VALUE_NULL
					Else
						encoded_json_data :+ OBJECT_BEGIN
						Local source_object_fields:TList = CreateList()
						Local source_object_super_type_id:TTypeId = source_object_type_id.SuperType()
						While source_object_super_type_id
							source_object_super_type_id.EnumFields( source_object_fields )
							source_object_super_type_id = source_object_super_type_id.SuperType()
						End While
						source_object_type_id.EnumFields( source_object_fields )
						Local field_count% = source_object_fields.Count()
						If field_count > 0
							If settings.pretty_print Then encoded_json_data :+ "~n"
							If settings.pretty_print Then indent :+ 1
							If settings.pretty_print Then encoded_json_data :+ _RepeatSpace( indent*settings.tab_size )
							Local field_index% = 0
							Local value:Object
							For Local source_object_field:TField = EachIn source_object_fields
								If Not type_metadata.IsFieldIgnored( source_object_field )
									encoded_json_data :+ STRING_BEGIN
									encoded_json_data :+ type_metadata.GetEncodeFieldName( source_object_field.Name() )
									encoded_json_data :+ STRING_END
									encoded_json_data :+ PAIR_SEPARATOR
									If settings.pretty_print Then encoded_json_data :+ " "
									Local source_object_field_type_id:TTypeId = source_object_field.TypeId()
									Local field_type_metadata:TJSONTypeSpecificMetadata = settings.GetTypeMetadata( source_object_field_type_id )
									Local field_override_type:TTypeId = Null
									If field_type_metadata.IsFieldTypeOverridden( source_object_field )
										field_override_type = field_type_metadata.GetFieldTypeOverride( source_object_field )
									End If
									If field_type_metadata.IsCustomEncoderDefined()
										value = source_object_field.Get( source_object )
										encoded_json_data :+ field_type_metadata.custom_encoder( value, settings, field_override_type, indent )
									Else
										Select source_object_field_type_id
											Case ByteTypeId, ..
											     ShortTypeId, ..
												   IntTypeId, ..
											     LongTypeId
												value = source_object_field.Get( source_object )
												encoded_json_data :+ String(value) 'value will have already been converted to a string
											Case FloatTypeId
												Local value_float:Float = source_object_field.GetFloat( source_object )
												encoded_json_data :+ TJSONDouble.Create( value_float ).Format( settings.default_precision )
											Case DoubleTypeId
												Local value_double:Double = source_object_field.GetDouble( source_object )
												encoded_json_data :+ TJSONDouble.Create( value_double ).Format( settings.default_precision )
											Default
												value = source_object_field.Get( source_object )
												encoded_json_data :+ Encode( value, settings,, indent )
										End Select
									End If
									If field_index < (field_count - 1) 'Not last member
										encoded_json_data :+ MEMBER_SEPARATOR
										If settings.pretty_print Then encoded_json_data :+ "~n"
										If settings.pretty_print Then encoded_json_data :+ _RepeatSpace( indent*settings.tab_size )
									End If
								End If
								field_index :+ 1
							Next
							If settings.pretty_print Then encoded_json_data :+ "~n"
							If settings.pretty_print Then indent :- 1
							If settings.pretty_print Then encoded_json_data :+ _RepeatSpace( indent*settings.tab_size )
						End If
						encoded_json_data :+ OBJECT_END
					End If
			End Select
		Else 'Array type
			If Not source_object
				encoded_json_data :+ ARRAY_BEGIN
				encoded_json_data :+ ARRAY_END
			Else
				Try
					Local dimensions% = source_object_type_id.ArrayDimensions( source_object )
					Local dimension_lengths%[] = New Int[dimensions]
					For Local d% = 0 Until dimensions
						dimension_lengths[d] = source_object_type_id.ArrayLength( source_object, d )
					Next
					Local array_length% = source_object_type_id.ArrayLength( source_object )
					If array_length = 0
						encoded_json_data :+ ARRAY_BEGIN
						encoded_json_data :+ ARRAY_END
					Else 'array_length <> 0
						Local source_object_element_type_id:TTypeId = source_object_type_id.ElementType()
						Local value:Object
						For Local index% = 0 Until array_length
							For Local d% = 0 Until dimensions
								If index Mod dimension_lengths[d] = 0
									encoded_json_data :+ ARRAY_BEGIN
									If settings.pretty_print Then encoded_json_data :+ "~n"
									If settings.pretty_print Then indent :+ 1
									If settings.pretty_print Then encoded_json_data :+ _RepeatSpace( indent*settings.tab_size )
								End If
							Next
							value = source_object_type_id.GetArrayElement( source_object, index )
							Local element_type_metadata:TJSONTypeSpecificMetadata = settings.GetTypeMetadata( source_object_element_type_id )
							If element_type_metadata.IsCustomEncoderDefined()
								encoded_json_data :+ element_type_metadata.custom_encoder( value, settings, Null, indent )
							Else
								Select source_object_element_type_id
									Case ByteTypeId, ..
									     ShortTypeId, ..
										   IntTypeId, ..
									     LongTypeId
										encoded_json_data :+ String(value) 'value will have already been converted to a string
									Case FloatTypeId, ..
									     DoubleTypeId
										encoded_json_data :+ TJSONDouble.Create( String(value).ToDouble() ).Format( settings.default_precision )
									Default
										encoded_json_data :+ Encode( value, settings,, indent )
								End Select
							End If
							For Local d% = (dimensions-1) To 0 Step -1
								If (index + 1) Mod dimension_lengths[d] = 0
									If settings.pretty_print Then encoded_json_data :+ "~n"
									If settings.pretty_print Then indent :- 1
									If settings.pretty_print Then encoded_json_data :+ _RepeatSpace( indent*settings.tab_size )
									encoded_json_data :+ ARRAY_END
								End If
							Next
							If index < (array_length - 1)
								encoded_json_data :+ VALUE_SEPARATOR
								If settings.pretty_print Then encoded_json_data :+ "~n"
								If settings.pretty_print Then encoded_json_data :+ _RepeatSpace( indent*settings.tab_size )
							End If
						Next
					End If					
				Catch ex$
					encoded_json_data :+ ARRAY_BEGIN
					encoded_json_data :+ ARRAY_END
				End Try
			End If
		End If
		Return encoded_json_data
	End Function
	
	Function _EncodeTypeTJSONWrapperObject:String( source_object:Object, settings:TJSONEncodeSettings = Null, override_type:TTypeId = Null, indent% = 0 )
		If source_object
			Select TTypeId.ForObject( source_object )
				Case TTypeId.ForName("TJSONBoolean"), ..
				     TTypeId.ForName("TJSONLong")
					Return source_object.ToString()
				Case TTypeId.ForName("TJSONDouble")
					Return TJSONDouble(source_object).Format( settings.default_precision )
			End Select
		Else
			Return "null"
		End If
	End Function
	
	Function _EncodeTypeTList:String( source_object:Object, settings:TJSONEncodeSettings = Null, override_type:TTypeId = Null, indent% = 0 )
		Local encoded_json_data:String = ""
		Local list:TList = TList(source_object)
		If list
			encoded_json_data :+ ARRAY_BEGIN
			Local size% = list.Count()
			If size > 0
				If settings.pretty_print Then encoded_json_data :+ "~n"
				If settings.pretty_print Then indent :+ 1
				If settings.pretty_print Then encoded_json_data :+ _RepeatSpace( indent*settings.tab_size )
				Local index% = 0
				For Local element:Object = EachIn list
					encoded_json_data :+ Encode( element, settings, Null, indent )
					index :+ 1
					If index < size
						encoded_json_data :+ VALUE_SEPARATOR
						If settings.pretty_print Then encoded_json_data :+ "~n"
						If settings.pretty_print Then encoded_json_data :+ _RepeatSpace( indent*settings.tab_size )
					Else 'index >= size
						If settings.pretty_print Then encoded_json_data :+ "~n"
						If settings.pretty_print Then indent :- 1
						If settings.pretty_print Then encoded_json_data :+ _RepeatSpace( indent*settings.tab_size )
					End If
				Next
			End If
			encoded_json_data :+ ARRAY_END
		End If
		Return encoded_json_data
	End Function
	
	Function _EncodeTypeTMap:String( source_object:Object, settings:TJSONEncodeSettings = Null, override_type:TTypeId = Null, indent% = 0 )
		Local encoded_json_data:String = ""
		Local map:TMap = TMap(source_object)
		If map
			encoded_json_data :+ OBJECT_BEGIN
			Local iter:TNodeEnumerator = map.Keys().ObjectEnumerator()
			If iter.HasNext()
				If settings.pretty_print Then encoded_json_data :+ "~n"
				If settings.pretty_print Then indent :+ 1
				If settings.pretty_print Then encoded_json_data :+ _RepeatSpace( indent*settings.tab_size )
				While iter.HasNext()
					Local key_obj:Object = iter.NextObject()
					encoded_json_data :+ STRING_BEGIN
					encoded_json_data :+ key_obj.ToString()
					encoded_json_data :+ STRING_END
					encoded_json_data :+ PAIR_SEPARATOR
					If settings.pretty_print Then encoded_json_data :+ " "
					encoded_json_data :+ Encode( map.ValueForKey( key_obj ), settings, Null, indent )
					If iter.HasNext()
						encoded_json_data :+ VALUE_SEPARATOR
						If settings.pretty_print Then encoded_json_data :+ "~n"
						If settings.pretty_print Then encoded_json_data :+ _RepeatSpace( indent*settings.tab_size )
					Else 'last element
						If settings.pretty_print Then encoded_json_data :+ "~n"
						If settings.pretty_print Then indent :- 1
						If settings.pretty_print Then encoded_json_data :+ _RepeatSpace( indent*settings.tab_size )
					End If
				End While
			End If
			encoded_json_data :+ OBJECT_END
		End If
		Return encoded_json_data
	End Function
	
	Function _InitializeObject:Object( json_object:TMap, settings:TJSONDecodeSettings, type_id:TTypeId )
		If type_id = TTypeId.ForName( "TMap" )
			Return json_object
		End If
		Local decoded_object:Object = type_id.NewObject()
		For Local key$ = EachIn json_object.Keys()
			Local object_field:TField = type_id.FindField( settings.GetTypeMetadata( type_id ).GetEncodeFieldName( key ))
			If object_field
				Local value:Object = json_object.ValueForKey( key )
				Local object_field_type_id:TTypeId = object_field.TypeId()
				If Not object_field_type_id.ElementType() 'non-array field type found
					'Try
						Select object_field_type_id
							Case ByteTypeId, ..
							     ShortTypeId, ..
							     IntTypeId
								Local decoded_datum:TJSONDouble = TJSONDouble(value)
								If Not decoded_datum
									Local temp_datum:String = String(value)
									If temp_datum
										decoded_datum = TJSONDouble.Create( temp_datum.ToDouble() )
									End If
								End If
								If Not decoded_datum
									Local temp_datum:TJSONBoolean = TJSONBoolean(value)
									If temp_datum
										decoded_datum = TJSONDouble.Create( temp_datum.value )
									End If
								End If
								If Not decoded_datum Then Throw " Error: attempt to assign to field "+type_id.Name()+"."+object_field.Name()+":"+object_field_type_id.Name()+" with value "+ObjectInfo(value)
								object_field.SetInt( decoded_object, Int(decoded_datum.value) )
							Case LongTypeId
								Local decoded_datum:TJSONDouble = TJSONDouble(value)
								If Not decoded_datum
									Local temp_datum:String = String(value)
									If temp_datum
										decoded_datum = TJSONDouble.Create( temp_datum.ToDouble() )
									End If
								End If
								If Not decoded_datum
									Local temp_datum:TJSONBoolean = TJSONBoolean(value)
									If temp_datum
										decoded_datum = TJSONDouble.Create( temp_datum.value )
									End If
								End If
								If Not decoded_datum Then Throw " Error: attempt to assign to field "+type_id.Name()+"."+object_field.Name()+":"+object_field_type_id.Name()+" with value "+ObjectInfo(value)
								object_field.SetLong( decoded_object, Long(decoded_datum.value) )
							Case FloatTypeId
								Local decoded_datum:TJSONDouble = TJSONDouble(value)
								If Not decoded_datum
									Local temp_datum:String = String(value)
									If temp_datum
										decoded_datum = TJSONDouble.Create( temp_datum.ToDouble() )
									End If
								End If
								If Not decoded_datum
									Local temp_datum:TJSONBoolean = TJSONBoolean(value)
									If temp_datum
										decoded_datum = TJSONDouble.Create( temp_datum.value )
									End If
								End If
								If Not decoded_datum Then Throw " Error: attempt to assign to field "+type_id.Name()+"."+object_field.Name()+":"+object_field_type_id.Name()+" with value "+ObjectInfo(value)
								object_field.SetFloat( decoded_object, Float(decoded_datum.value) )
							Case DoubleTypeId
								Local decoded_datum:TJSONDouble = TJSONDouble(value)
								If Not decoded_datum
									Local temp_datum:String = String(value)
									If temp_datum
										decoded_datum = TJSONDouble.Create( temp_datum.ToDouble() )
									End If
								End If
								If Not decoded_datum
									Local temp_datum:TJSONBoolean = TJSONBoolean(value)
									If temp_datum
										decoded_datum = TJSONDouble.Create( temp_datum.value )
									End If
								End If
								If Not decoded_datum Then Throw " Error: attempt to assign to field "+type_id.Name()+"."+object_field.Name()+":"+object_field_type_id.Name()+" with value "+ObjectInfo(value)
								object_field.SetDouble( decoded_object, Double(decoded_datum.value) )
							Case StringTypeId
								Local decoded_datum:String = String(value)
								If Not decoded_datum
									Local temp_datum:TJSONDouble = TJSONDouble(value)
									If temp_datum
										decoded_datum = temp_datum.Format( settings.default_precision )
									End If
								End If
								If Not decoded_datum 
									object_field.Set( decoded_object, Null )
								Else
									object_field.Set( decoded_object, decoded_datum )
								End If
							Case ObjectTypeId
								object_field.Set( decoded_object, value )
							Default 'user defined objects
								If value <> Null
									Local json_child_object:TMap = TMap(value)
									If Not json_child_object
										If TJSONBoolean(value)
											object_field.Set( decoded_object, TJSONBoolean(value) )
										Else
											Throw( " Error: an object is desired, but something else was found: "+ObjectInfo(value) )
										EndIf
									Else
										object_field.Set( decoded_object, _InitializeObject( json_child_object, settings, object_field_type_id ))
									EndIf
								EndIf
						End Select
					'Catch ex$
					'	Throw( " Error: could not assign decoded object member ("+ObjectInfo(value)+") to "+type_id.Name()+"."+object_field.Name()+":"+object_field_type_id.Name() )
					'End Try
				Else 'array field type found
					Local json_child_array:TList = TList(value)
					If Not json_child_array Then Throw( " Error: an array is desired, but something else was found: "+ObjectInfo(value) )
					object_field.Set( decoded_object, _InitializeArray( json_child_array, settings, object_field_type_id ))
				End If
			Else
				'Ignore this error, there was extra data
				DebugLog( " Warning: field "+key+" not found in type "+type_id.Name())
			End If
		Next
		Return decoded_object
	End Function
	
	Function _InitializeArray:Object( json_array:TList, settings:TJSONDecodeSettings, type_id:TTypeId )
		If type_id = TTypeId.ForName( "TList" )
			Return json_array
		End If
		Local element_type_id:TTypeId = type_id.ElementType()
		Local size% = json_array.Count()
		Local decoded_object:Object = type_id.NewArray( size ) 'TODO: check for destination field being a multidimensional array
		Local index% = 0
		For Local value:Object = EachIn json_array
			If Not element_type_id.ElementType() 'non-array element type found
				'Try
					Select element_type_id
						Case ByteTypeId, ..
						     ShortTypeId, ..
						     IntTypeId
							Local decoded_datum:TJSONDouble = TJSONDouble(value)
							If Not decoded_datum Then Throw " Error: attempt to assign to array element "+element_type_id.Name()+"["+index+"] with value "+ObjectInfo(value)
							type_id.SetArrayElement( decoded_object, index, decoded_datum.ToString() )
						Case LongTypeId
							Local decoded_datum:TJSONDouble = TJSONDouble(value)
							If Not decoded_datum Then Throw " Error: attempt to assign to array element "+element_type_id.Name()+"["+index+"] with value "+ObjectInfo(value)
							type_id.SetArrayElement( decoded_object, index, decoded_datum.ToString() )
						Case FloatTypeId
							Local decoded_datum:TJSONDouble = TJSONDouble(value)
							If Not decoded_datum Then Throw " Error: attempt to assign to array element "+element_type_id.Name()+"["+index+"] with value "+ObjectInfo(value)
							type_id.SetArrayElement( decoded_object, index, decoded_datum.ToString() )
						Case DoubleTypeId
							Local decoded_datum:TJSONDouble = TJSONDouble(value)
							If Not decoded_datum Then Throw " Error: attempt to assign to array element "+element_type_id.Name()+"["+index+"] with value "+ObjectInfo(value)
							type_id.SetArrayElement( decoded_object, index, decoded_datum.ToString() )
						Case StringTypeId
							Local decoded_datum:String = String(value)
							If Not decoded_datum Then type_id.SetArrayElement( decoded_object, index, Null )
							type_id.SetArrayElement( decoded_object, index, decoded_datum )
						Case ObjectTypeId
							type_id.SetArrayElement( decoded_object, index, value )
						Default 'user defined objects
							If value <> Null
								Local json_child_object:TMap = TMap(value)
								If Not json_child_object Then Throw( " Error: an object is desired, but something else was found: "+ObjectInfo(value) )
								type_id.SetArrayElement( decoded_object, index, _InitializeObject( json_child_object, settings, element_type_id ))
							EndIf
					End Select
				'Catch ex$
				'	Throw( " Error: could not assign decoded array element ("+ObjectInfo(value)+") to "+type_id.ElementType().Name()+"["+index+"]" )
				'End Try
			Else 'array element type found
				Local json_child_array:TList = TList(value)
				If Not json_child_array Then Throw( " Error: an array is desired, but something else was found: "+ObjectInfo(value) )
				type_id.SetArrayElement( decoded_object, index, _InitializeArray( json_child_array, settings, element_type_id ))
			End If
			index :+ 1
		Next
		Return decoded_object
	End Function
	
	'string, number, object, array, true, false, null
	Function _DecodeJSONValue:Object( encoded_json_data:String, cursor:Int Var )
		_EatWhitespace( encoded_json_data, cursor )
		Local temp_str$ = encoded_json_data[cursor..]
		If temp_str.StartsWith( VALUE_NULL )
			cursor :+ VALUE_NULL.Length
			Return Null
		Else If temp_str.StartsWith( VALUE_TRUE )
			cursor :+ VALUE_TRUE.Length
			Return TJSONBoolean.Create( True )
		Else If temp_str.StartsWith( VALUE_FALSE )
			cursor :+ VALUE_FALSE.Length
			Return TJSONBoolean.Create( False )
		End If
		Local char$
		char = Chr(encoded_json_data[cursor])
		Select char
			Case OBJECT_BEGIN
				Return _DecodeJSONObject( encoded_json_data, cursor )
			Case ARRAY_BEGIN
				Return _DecodeJSONArray( encoded_json_data, cursor )
			Case STRING_BEGIN
				Return _DecodeJSONString( encoded_json_data, cursor )
		End Select
		If char = "-" Or _IsDigit( char )
			Return _DecodeJSONNumber( encoded_json_data, cursor )
		End If
		Select char 'trailing comma, ignore error and continue
			Case OBJECT_END 
				Throw("IGNORE")
			Case ARRAY_END
				Throw("IGNORE")
		End Select
		If _IsAlphaNumericOrUnderscore( encoded_json_data[cursor] )
			Local try_unquoted_string$ = _DecodeJSONUnquotedString( encoded_json_data, cursor )
			If try_unquoted_string Then Return try_unquoted_string
		EndIf
		Select char 'trailing comma, ignore error and continue
			Case OBJECT_END 
				Throw("IGNORE")
			Case ARRAY_END
				Throw("IGNORE")
		End Select
		Throw( " Error: could not parse encoded JSON data at position "+(cursor-1) )
	End Function
	
	Function _DecodeJSONObject:TMap( encoded_json_data:String, cursor:Int Var )
		Local json_object:TMap = CreateMap()
		_EatWhitespace( encoded_json_data, cursor )
		Local char$
		If cursor >= (encoded_json_data.Length) Then Return Null
		char = Chr(encoded_json_data[cursor]); cursor :+ 1
		If char <> OBJECT_BEGIN
			Throw( " Error: expected open-curly-brace character at position "+(cursor-1)+_ShowPosition(encoded_json_data, cursor) )
			Return Null
		End If
		Local member_pair_name$, member_pair_value:Object
		Try
			Repeat
				_EatWhitespace( encoded_json_data, cursor )
				member_pair_name = _DecodeJSONString( encoded_json_data, cursor )
				_EatWhitespace( encoded_json_data, cursor )
				If cursor >= (encoded_json_data.Length) Then Exit
				char = Chr(encoded_json_data[cursor]); cursor :+ 1
				If char <> PAIR_SEPARATOR
					Throw( " Error: expected colon character at position "+(cursor-1)+_ShowPosition(encoded_json_data, cursor) )
					Return Null
				End If
				_EatWhitespace( encoded_json_data, cursor )
				member_pair_value = _DecodeJSONValue( encoded_json_data, cursor )
				json_object.Insert( member_pair_name, member_pair_value )
				_EatWhitespace( encoded_json_data, cursor )
				If cursor >= (encoded_json_data.Length) Then Exit
				char = Chr(encoded_json_data[cursor]); cursor :+ 1
				If char <> VALUE_SEPARATOR And char <> VALUE_SEPARATOR_ALTERNATE And char <> OBJECT_END
					Throw( " Error: expected comma or semicolon or close-curly-brace character at position "+(cursor-1)+_ShowPosition(encoded_json_data, cursor) )
					Return Null
				End If
			Until char = OBJECT_END Or cursor >= (encoded_json_data.Length - 1)
		Catch ex$
			'If ex = "IGNORE" Then DebugLog " Warning: trailing comma ignored" ..
			'Else Throw ex
			If ex <> "IGNORE" Then Throw ex
		End Try
		Return json_object
	End Function
	
	Function _DecodeJSONArray:TList( encoded_json_data:String, cursor:Int Var )
		If encoded_json_data = "" Then Return Null
		Local json_array:TList = CreateList()
		_EatWhitespace( encoded_json_data, cursor )
		Local char$
		If cursor >= (encoded_json_data.Length - 1) Then Return Null
		char = Chr(encoded_json_data[cursor]); cursor :+ 1
		If char <> ARRAY_BEGIN
			Throw( " Error: expected open-square-bracket character at position "+(cursor-1)+_ShowPosition(encoded_json_data, cursor) )
			Return Null
		End If
		Local element_value:Object
		Repeat
			If cursor >= (encoded_json_data.Length - 1) Then Throw( "Error: expected JSON value at position "+(cursor-1)+_ShowPosition(encoded_json_data, cursor))
			_EatWhitespace( encoded_json_data, cursor )
			Try
				element_value = _DecodeJSONValue( encoded_json_data, cursor )
				json_array.AddLast( element_value )
			Catch ex$ 
				'If ex = "IGNORE" Then DebugLog " Warning: trailing comma ignored" ..
				'Else Throw ex
				If ex <> "IGNORE" Then Throw ex
			End Try
			_EatWhitespace( encoded_json_data, cursor )
			If cursor >= (encoded_json_data.Length) Then Exit
			char = Chr(encoded_json_data[cursor]); cursor :+ 1
			If char <> VALUE_SEPARATOR And char <> VALUE_SEPARATOR_ALTERNATE And char <> ARRAY_END
				Throw( " Error: expected comma or semicolon or close-square-bracket character at position "+(cursor-1)+_ShowPosition(encoded_json_data, cursor) )
				Return Null
			End If
		Until char = ARRAY_END Or cursor >= (encoded_json_data.Length - 1)
		Return json_array
	End Function
	
	Function _DecodeJSONString:String( encoded_json_data:String, cursor:Int Var )
		Local json_string$ = ""
		_EatWhitespace( encoded_json_data, cursor )
		Local char$, char_temp$
		If cursor >= (encoded_json_data.Length) Then Return Null
		char = Chr(encoded_json_data[cursor]); cursor :+ 1
		Select char 'trailing comma, ignore error and continue
			Case OBJECT_END 
				Throw("IGNORE")
			Case ARRAY_END
				Throw("IGNORE")
		End Select
		If char <> STRING_BEGIN
			Throw( " Error: expected quotation character at position "+(cursor-1)+_ShowPosition(encoded_json_data, cursor) )
			Return Null
		End If
		Repeat
			char = Chr(encoded_json_data[cursor]); cursor :+ 1
			If char = STRING_END
				Exit
			End If
			If char <> STRING_ESCAPE_SEQUENCE_BEGIN
				json_string :+ char
			Else
				If cursor >= (encoded_json_data.Length - 1)
					Throw( " Error: unterminated string literal" )
					Return Null
				End If
				char_temp = Chr(encoded_json_data[cursor]); cursor :+ 1
				Select char_temp
					Case STRING_ESCAPE_QUOTATION
						json_string :+ "~q"
					Case STRING_ESCAPE_REVERSE_SOLIDUS
						json_string :+ "\"
					Case STRING_ESCAPE_BACKSPACE
						'ignore
					Case STRING_ESCAPE_FORMFEED
						'ignore
					Case STRING_ESCAPE_NEWLINE
						json_string :+ "~n"
					Case STRING_ESCAPE_CARRIAGE_RETURN
						json_string :+ "~r"
					Case STRING_ESCAPE_HORIZONTAL_TAB
						json_string :+ "~t"
					Case STRING_ESCAPE_UNICODE_BEGIN
						'ignore
						cursor :+ 4
					Default
						Throw( " Error: bad string escape sequence at position "+(cursor-1) )
						Return Null
				End Select
			End If
		Until cursor >= (encoded_json_data.Length - 1)
		Return json_string
	End Function

	Function _DecodeJSONUnquotedString:String( encoded_json_data:String, cursor:Int Var )
		Local json_string$ = ""
		_EatWhitespace( encoded_json_data, cursor )
		Local char$
		If cursor >= (encoded_json_data.Length) Then Return Null
		char = Chr( encoded_json_data[cursor] );
		cursor :+ 1
		json_string :+ char
		Repeat
			char = Chr( encoded_json_data[cursor] );
			If Not _IsAlphaNumericOrUnderscore( char )
				Exit
			End If
			cursor :+ 1
			json_string :+ char
		Until cursor >= (encoded_json_data.Length - 1)
		'DebugLog " Notify: Unquoted string found: "+json_string
		Return json_string
	End Function
	
	'TJSONLong, TJSONDouble
	Function _DecodeJSONNumber:Object( encoded_json_data:String, cursor:Int Var )
		Local json_value:Object = Null
		_EatWhitespace( encoded_json_data, cursor )
		Local cursor_start% = cursor
		Local floating_point% = False
		_EatSpecific( encoded_json_data, cursor, "+-", 1 )
		_EatSpecific( encoded_json_data, cursor, "0123456789",, 1 )
		If _EatSpecific( encoded_json_data, cursor, ".", 1 )
			floating_point = True
			_EatSpecific( encoded_json_data, cursor, "0123456789",, 1 )
		End If
		If _EatSpecific( encoded_json_data, cursor, "eE", 1 )
			floating_point = True
			_EatSpecific( encoded_json_data, cursor, "+-", 1 )
			_EatSpecific( encoded_json_data, cursor, "0123456789",, 1 )
		End If
		If _EatSpecific( encoded_json_data, cursor, "f", 1, 0 )
			floating_point = True
		End If
		If (cursor - cursor_start) > 0
			Local encoded_number$ = encoded_json_data[cursor_start..cursor]
			If encoded_number And encoded_number.Length > 0
				json_value = TJSONDouble.Create( encoded_number.ToDouble() )
			End If
		End If
		Return json_value
	End Function
	
	Function _EatWhitespace( str:String, cursor:Int Var )
		' advance cursor to first printable character
		Local cursor_char$, comment% = false
		While cursor < str.Length
			cursor_char = Chr( str[cursor] )
			If Chr( str[cursor] ) = "#"
				comment = true
			Else If Chr( str[cursor] ) = "~r" Or Chr( str[cursor] ) = "~n"
				comment = false
			End If
			If comment Or Not _IsPrintable( cursor_char )
				cursor :+ 1
			Else
				Exit 'done
			End If
		End While
	End Function
	
	Function _EatSpecific%( str:String, cursor:Int Var, char_filter:String, limit% = -1, require% = -1 )
		Local cursor_start% = cursor
		Local contained_in_filter% = True
		While cursor < str.Length And contained_in_filter
			contained_in_filter = False
			For Local c% = 0 Until char_filter.Length
				If str[cursor] = char_filter[c]
					contained_in_filter = True
					Exit
				End If
			Next
			If contained_in_filter
				cursor :+ 1
			End If
			If limit <> -1 And (cursor - cursor_start) >= limit
				Exit
			End If
		End While
		If require <> -1 And (cursor - cursor_start) < require
			Throw( " Error: expected at least "+require+" characters from the set ["+char_filter+"]" )
		End If
		Return cursor - cursor_start
	End Function

	Function _ShowPosition$( encoded_json_data$, cursor% )
		Return "~n"+encoded_json_data[cursor-6..cursor+5]+"~n"+_RepeatSpace(5)+"^"
	End Function
	
	Function _StringEscape$( str$ )
		Return str.Replace( "~q", "\~q" ).Replace( "\", "\\" ).Replace( "~n", "\n" ).Replace( "~r", "\r" ).Replace( "~t", "\t" )  
	End Function
	
	Function _RepeatSpace$( count% )
		Return LSet( "", count )
	End Function
	
	Function _IsDigit%( char$ )
		Local ascii_code% = Asc( char )
		Return ascii_code >= Asc( "0" ) And ascii_code <= Asc( "9" )
	End Function
	
	Function _IsAlpha%( char$ )
		Local ascii_code% = Asc( char )
		Return (ascii_code >= Asc( "A" ) And ascii_code <= Asc( "Z" )) ..
		Or     (ascii_code >= Asc( "a" ) And ascii_code <= Asc( "z" ))
	End Function

	Function _IsAlphaNumericOrUnderscore%( char$ )
		Local ascii_code% = Asc( char )
		Return (ascii_code >= Asc( "A" ) And ascii_code <= Asc( "Z" )) ..
		Or     (ascii_code >= Asc( "a" ) And ascii_code <= Asc( "z" )) ..
		Or     (ascii_code >= Asc( "0" ) And ascii_code <= Asc( "9" )) ..
		Or     ascii_code =  Asc( "_" )		
	End Function
	
	Function _IsPrintable%( char$ )
		Local ascii_code% = Asc( char )
		Return ascii_code > 32 And ascii_code <> 127
	End Function
	
	'JSON ASCII Literals
	Const OBJECT_BEGIN$                  = "{"
	Const OBJECT_END$                    = "}"
	Const MEMBER_SEPARATOR$              = ","
	Const PAIR_SEPARATOR$                = ":"
	Const ARRAY_BEGIN$                   = "["
	Const ARRAY_END$                     = "]"
	Const VALUE_SEPARATOR$               = ","
	Const VALUE_SEPARATOR_ALTERNATE$     = ";"
	Const VALUE_TRUE$                    = "true"
	Const VALUE_FALSE$                   = "false"
	Const VALUE_NULL$                    = "null"
	Const STRING_BEGIN$                  = "~q"
	Const STRING_END$                    = "~q"
	Const STRING_ESCAPE_SEQUENCE_BEGIN$  = "\"
	Const STRING_ESCAPE_QUOTATION$       = "~q"
	Const STRING_ESCAPE_REVERSE_SOLIDUS$ = "\"
	'Const STRING_ESCAPE_SOLIDUS$         = "/"
	Const STRING_ESCAPE_BACKSPACE$       = "b"
	Const STRING_ESCAPE_FORMFEED$        = "f"
	Const STRING_ESCAPE_NEWLINE$         = "n"
	Const STRING_ESCAPE_CARRIAGE_RETURN$ = "r"
	Const STRING_ESCAPE_HORIZONTAL_TAB$  = "t"
	Const STRING_ESCAPE_UNICODE_BEGIN$   = "u"
	
End Type


' encoding settings
Type TJSONEncodeSettings
	Field default_precision:Int 'for non-scientific floating point number output, the maximum number of digits past the decimal point to display
	Field pretty_print:Byte     '(boolean) whether to format with tabs and whitespace for human readability
	Field tab_size:Int          'spaces per tab indent level, minimum = 1
	Field metadata:TMap         'maps blitzmax type-ID's to type-specific encoding settings
	'////
	Method New()
		default_precision = -1
		pretty_print = True
		tab_size = 2
		metadata = CreateMap()
		'default encoders
		SetCustomEncoder( TTypeId.ForName("TJSONBoolean"), JSON._EncodeTypeTJSONWrapperObject )
		SetCustomEncoder( TTypeId.ForName("TJSONLong"), JSON._EncodeTypeTJSONWrapperObject )
		SetCustomEncoder( TTypeId.ForName("TJSONDouble"), JSON._EncodeTypeTJSONWrapperObject )
		SetCustomEncoder( TTypeId.ForName("TList"), JSON._EncodeTypeTList )
		SetCustomEncoder( TTypeId.ForName("TMap"), JSON._EncodeTypeTMap )
	End Method
	'////
	Method Clone:TJSONEncodeSettings()
		Local settings:TJSONEncodeSettings = New TJSONEncodeSettings
		settings.default_precision = self.default_precision
		settings.pretty_print = self.pretty_print
		settings.tab_size = self.tab_size
		For Local type_id$ = EachIn metadata.Keys()
			Local type_metadata:TJSONTypeSpecificMetadata = TJSONTypeSpecificMetadata( metadata.ValueForKey( type_id ))
			settings.metadata.Insert( type_id, type_metadata.Clone() )
		Next
		return settings
	End Method
	'////
	Method GetTypeMetadata:TJSONTypeSpecificMetadata( type_id:TTypeId )
		Local type_metadata:TJSONTypeSpecificMetadata = TJSONTypeSpecificMetadata( metadata.ValueForKey( type_id ))
		If Not type_metadata
			type_metadata = New TJSONTypeSpecificMetadata
			metadata.Insert( type_id, type_metadata )
		End If
		Return type_metadata
	End Method
	'////
	Method IgnoreField( type_id:TTypeId, field_ref:TField )
		GetTypeMetadata( type_id ).IgnoreField( field_ref )
	End Method
	'////
	Method OverrideFieldType( type_id:TTypeId, field_ref:TField, field_type:TTypeId )
		GetTypeMetadata( type_id ).OverrideFieldType( field_ref, field_type )
	End Method
	'////
	Method OverrideFieldName( type_id:TTypeId, field_name$, new_field_name$ )
		GetTypeMetadata( type_id ).OverrideFieldName( field_name, new_field_name )
	End Method
	'////
	Method SetCustomEncoder( type_id:TTypeId, custom_encoder:String( source_object:Object, settings:TJSONEncodeSettings, override_type:TTypeId, indent% ))
		GetTypeMetadata( type_id ).SetCustomEncoder( custom_encoder )
	End Method
End Type

'decoding settings (none yet)
Type TJSONDecodeSettings
	Field default_precision:Int 'only used during implicit type conversion from double to string
	Field metadata:TMap         'maps blitzmax type-ID's to type-specific encoding settings
	'////
	Method New()
		default_precision = -1
		metadata = CreateMap()
	End Method
	'////
	Method GetTypeMetadata:TJSONTypeSpecificMetadata( type_id:TTypeId )
		Local type_metadata:TJSONTypeSpecificMetadata = TJSONTypeSpecificMetadata( metadata.ValueForKey( type_id ))
		If Not type_metadata
			type_metadata = New TJSONTypeSpecificMetadata
			metadata.Insert( type_id, type_metadata )
		End If
		Return type_metadata
	End Method
	'////
	Method OverrideFieldName( type_id:TTypeId, field_name$, new_field_name$ )
		GetTypeMetadata( type_id ).OverrideFieldName( field_name, new_field_name )
	End Method
End Type

' type-specific metadata describes fields to ignore and fields to override with explicit types
Type TJSONTypeSpecificMetadata
	Field precision:Int             'overrides the setting in the container class for this field only
	Field ignore_fields:TList       'TList<String> specifies fields to ignore
	Field field_type_overrides:TMap 'maps blitzmax fields to types (to use as overrides)
	Field field_name_overrides:TMap 'maps blitzmax type field identifiers to json object field names
	Field custom_encoder:String( source_object:Object, settings:TJSONEncodeSettings, override_type:TTypeId, indent% )
	'////
	Method New()
		ignore_fields = CreateList()
		field_type_overrides = CreateMap()
		field_name_overrides = CreateMap()
	End Method
	'////
	Method Clone:TJSONTypeSpecificMetadata()
		Local meta:TJSONTypeSpecificMetadata = New TJSONTypeSpecificMetadata
		meta.precision = self.precision
		meta.ignore_fields = self.ignore_fields.Copy()
		meta.field_type_overrides = self.field_type_overrides.Copy()
		meta.field_name_overrides = self.field_name_overrides.Copy()
		meta.custom_encoder = self.custom_encoder
		Return meta
	End Method
	'////
	Method IsFieldIgnored%( field_ref:TField )
		Return ignore_fields.Contains( field_ref )
	End Method
	'////
	Method IsFieldTypeOverridden%( field_ref:TField )
		Return field_type_overrides.Contains( field_ref )
	End Method
	'////
	Method IsFieldNameOverridden%( field_name$ )
		Return field_name_overrides.Contains( field_name )
	End Method
	'////
	Method GetFieldTypeOverride:TTypeId( field_ref:TField )
		Return TTypeId( field_type_overrides.ValueForKey( field_ref ))
	End Method
	'////
	Method GetEncodeFieldName$( field_name$ )
		If field_name_overrides.Contains( field_name )
			Return String( field_name_overrides.ValueForKey( field_name ))
		Else 'nothing has been set for this field
			Return field_name
		End If
	End Method
	'////
	Method IgnoreField( field_ref:TField )
		ignore_fields.AddLast( field_ref )
	End Method
	'////
	Method OverrideFieldType( field_ref:TField, field_type:TTypeId )
		field_type_overrides.Insert( field_ref, field_type )
	End Method
	'////
	Method OverrideFieldName( field_name$, new_field_name$ )
		field_name_overrides.Insert( field_name, new_field_name )
	End Method
	'////
	Method SetCustomEncoder( custom_encoder:String( source_object:Object, settings:TJSONEncodeSettings, override_type:TTypeId, indent% ))
		Self.custom_encoder = custom_encoder
	End Method
	'////
	Method IsCustomEncoderDefined%()
		Return Self.custom_encoder <> Null
	End Method
End Type



' wrapper type for integral numbers
Type TJSONLong
	Field value:Long
	'////
	Function Create:TJSONLong( value:Long )
		Local obj:TJSONLong = New TJSONLong
		obj.value = value
		Return obj
	End Function
	'////
	Method ToString:String()
		Return String.FromLong(value)
	End Method
End Type

' wrapper type for floating-point numbers
Type TJSONDouble
	Field value:Double
	'////
	Function Create:TJSONDouble( value:Double )
		Local obj:TJSONDouble = New TJSONDouble
		obj.value = value
		Return obj
	End Function
	'////
	Method ToString:String()
		Return String.FromDouble(value)
	End Method
	'////
	Method Format:String( precision:Int )
		Return FormatDouble( value, precision )
	End Method
End Type

Function FormatDouble:String( value:Double, precision:Int, trim_trailing_zeroes:Int=True )
	Extern "C"
		Function snprintf_:Int( s:Byte Ptr, n:Int, Format$z, p:Int, v1:Double) = "snprintf"
	EndExtern
	Const CHAR_0:Byte = Asc("0")
	Const CHAR_DOT:Byte = Asc(".")
	Const STR_FMT:String = "%.*f"
	'http://codepad.org/dtEzvASt
	If precision = -1 Then precision = 6 'cstdio.h default
	Local i:Double
	Local buf:Byte[32]
	Local sz:Int = snprintf_( buf, buf.Length, STR_FMT, precision, value)
	'If trim_trailing_zeroes
		sz :- 1
		While (sz > 0) And (buf[ sz] = CHAR_0)
			If buf[ sz-1] = CHAR_DOT Then Exit
			sz :- 1
		Wend
		sz :+ 1
	'EndIf
	If sz > 0
		Return String.FromBytes( buf, sz )
	Else
		Return "0"
	EndIf
EndFunction

' wrapper type for boolean values
Type TJSONBoolean
	Field value:Byte
	'////
	Function Create:TJSONBoolean( value:Byte )
		Local obj:TJSONBoolean = New TJSONBoolean
		If value Then obj.value = True Else obj.value = False
		Return obj
	End Function
	'////
	Method ToString:String()
		If value Then Return "true" Else Return "false"
	End Method
End Type


