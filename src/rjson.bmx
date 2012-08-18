Rem

bmx-rjson
reflection-based JSON encoder/decoder
by Tyler W.R. Cole

written according to the JSON specification
http://www.json.org

Note the following deviations from the standard(s):
* when parsing, a semicolon is an acceptable substitute for a comma
* when parsing, the '#' character outside of a string is treated as a single-line comment
* when parsing, it is okay for string values to be unquoted, as long as they only contain the following characters:
  A-Za-z_0-9, and do not start with a number (suitable for 'enums')
* when parsing, trailing commas in object field-lists and array item-lists are ignored
* when parsing, it is okay for floating-point numbers to have a trailing 'f'
* when parsing, it is okay for numbers to have any number of leading zeroes

Note: this system does not support USER-DEFINED cyclic data structures,
but it does support the following BlitzMax built-in types which are cyclic:
* TList
* TMap

///////////////////////////////////

The following intermediate types are used for storage during stringifying/parsing
and are used to control Transformations that can override the default field mappings:
* TNull    Extends TValue
* TBoolean Extends TValue
* TNumber  Extends TValue
* TString  Extends TValue
* TArray   Extends TValue
* TObject  Extends TValue

A separate set of mapping functions is used to map these very simple objects
to arbitrary BlitzMax types, via reflection.

///////////////////////////////////

Transformations are imperatives applied to a subset of data contained in a TValue.
They thus can transform the parsed or stringified JSON data mid-way through the process.
Filtering is performed via case-sensitive Selector strings, for example:
	":string" --> any TString belonging to the root-level container
	"$field"  --> root-level TObject's field named "field"
	"@5"      --> root-level TArray's element at position 5
	""        --> (wildcard) every root-level field or element

Any given Transformation must also specify whether it is to be applied during parse or stringify.
All Transformations are globally applied, but can be added/removed at any time.
Transformations can optionally specify a condition function that determines at run time whether an
  imperative for a selected object should actually run; in this way they can vary based on arbitrary
  user-defined conditions.

Supported transformation imperatives:
* XJ_DELETE 
* XJ_RENAME ( new_field_name )
* XJ_CONVERT( new_type )


EndRem

SuperStrict
Import brl.reflection
Import brl.retro
Import brl.linkedlist
Import brl.map



Type json
	
	'Global settings
	Global error_level% = 2 'legend   2: as strict as possible   1: ignore warnings   0: ignore errors & warnings

	'Encode settings
	Global formatted% = True 'false: compact, true: indented; global setting
	Global indent_size% = 2 'spaces per indent level, if formatted is true; global setting
	Global precision% = 6 'default floating-point precision, can be overridden per field/object/instance/item/value
	
	'Generate a JSON-Encoded String from an arbitrary Object
	Function stringify:String( source_object:Object )
		If Not source_object Then Return TValue.VALUE_NULL ' --> "null"
		Local source_object_converted:TValue = reflect_to_TValue( source_object )
		For Local xform:TValue_Transformation = EachIn transforms_stringify
			xform.Execute( source_object_converted ) 'Execute any available transformations
		Next
		Return source_object_converted.Encode( 0, precision )
	EndFunction
	
	'Generate an Object of the given type name from a JSON-Encoded String
	Function parse:Object( encoded$, type_id$="" )
		If encoded = "" Then Return Null
		Local cursor% = 0
		Local intermediate_object:TValue = allocate_TValue( encoded, cursor )
		If intermediate_object = Null Then Return Null
		intermediate_object.Decode( encoded, cursor )
		CheckLeftovers( encoded, cursor )
		For Local xform:TValue_Transformation = EachIn transforms_parse
			xform.Execute( intermediate_object ) 'Execute any available transformations
		Next
		If type_id <> ""
			Local destination_type_id:TTypeId = TTypeId.ForName( type_id )
			If destination_type_id
				Local destination_object:Object = initialize_object( intermediate_object, destination_type_id )
				Return destination_object
			Else
				json_error( json.LOG_ERROR+" Type ID not found: "+type_id )
			EndIf
		Else 'type_id not provided
			Return intermediate_object
		EndIf
	EndFunction


	'Transformations
	Global transforms_stringify:TList = CreateList()
	Global transforms_parse:TList = CreateList()
	
	Function add_stringify_transform( selector$, imperative_id%, argument:Object=Null, condition_func%( val:TValue_Search_Result )=Null )
		transforms_stringify.AddLast( ..
			TValue_Transformation.Create( ..
				selector, imperative_id, argument, condition_func ))
	EndFunction

	Function add_parse_transform( selector$, imperative_id%, argument:Object=Null, condition_func%( val:TValue_Search_Result )=Null )
		transforms_parse.AddLast( ..
			TValue_Transformation.Create( ..
				selector, imperative_id, argument, condition_func ))
	EndFunction

	Function clear_transforms()
		transforms_stringify.Clear()
		transforms_parse.Clear()
	EndFunction

	'transformations ////////////////////////////////////////////////////////////
	Const XJ_DELETE% = 86
	Const XJ_RENAME% = 102
	Const XJ_CONVERT% = 1199
	'Selector Type Codes
	Const SEL_NULL$    = "null"
	Const SEL_BOOLEAN$ = "boolean"
	Const SEL_NUMBER$  = "number"
	Const SEL_STRING$  = "string"
	Const SEL_ARRAY$   = "array"
	Const SEL_OBJECT$  = "object"

	'////////////////////////////////////////////////////////////////////////////

	Function allocate_TValue:TValue( encoded$, cursor% )
		Local jsontype% = TValue.PredictJSONType( encoded, cursor )
		If jsontype = TValue.JSONTYPE_INVALID Then Return Null
		Local intermediate_object:TValue
		Select jsontype
			Case TValue.JSONTYPE_NULL
				intermediate_object = New TNull
			Case TValue.JSONTYPE_BOOLEAN
				intermediate_object = New TBoolean
			Case TValue.JSONTYPE_NUMBER
				intermediate_object = New TNumber
			Case TValue.JSONTYPE_STRING
				intermediate_object = New TString
			Case TValue.JSONTYPE_ARRAY
				intermediate_object = New TArray
			Case TValue.JSONTYPE_OBJECT
				intermediate_object = New TObject
		EndSelect
		Return intermediate_object
	EndFunction


	'Nested Array Types (e.g.: Int[][][] ) ARE supported
	'Single Arrays with Multiple Dimensions (e.g.: Int[4,3,5] ) are NOT supported
	Function reflect_to_TValue:TValue( source_object:Object )
		If source_object = Null Then Return New TNull
		Local converted_object:TValue = TValue( source_object )
		If Not converted_object 'requires reflection-based conversion
			Local source_object_type_id:TTypeId = TTypeId.ForObject( source_object )
			'Check for cyclic built-in types; process them in a special way for convenience
			If source_object_type_id = TMap_TTypeId
				converted_object = New TObject
				For Local key$ = EachIn TMap(source_object).Keys()
					TObject(converted_object).fields.Insert( key, reflect_to_TValue( TMap(source_object).ValueForKey( key )))
				Next
			ElseIf source_object_type_id = TList_TTypeId
				converted_object = New TArray
				For Local item:Object = EachIn TList(source_object)
					TArray(converted_object).elements.AddLast( reflect_to_TValue( item ))
				Next
			Else
				If source_object_type_id.ElementType() = Null
					'Not Array
					If source_object_type_id = StringTypeId
						'String
						converted_object = New TString
						TString(converted_object).value = String(source_object)
					Else
						'Non-array Non-string: User Defined Object
						'Get list of fields in type hierarchy
						converted_object = New TObject
						Local source_object_fields:TList = enumerate_fields( source_object_type_id )
						Local field_count% = source_object_fields.Count()
						If field_count > 0
							Local field_value:TValue
							For Local source_object_field:TField = EachIn source_object_fields
								Select source_object_field.TypeId()
									Case IntTypeId, ShortTypeId, ByteTypeId
										field_value = New TNumber
										TNumber(field_value).value = source_object_field.GetInt( source_object )
									Case LongTypeId
										field_value = New TNumber
										TNumber(field_value).value = source_object_field.GetLong( source_object )
									Case FloatTypeId
										field_value = New TNumber
										TNumber(field_value).value = source_object_field.GetFloat( source_object )
									Case DoubleTypeId
										field_value = New TNumber
										TNumber(field_value).value = source_object_field.GetDouble( source_object )
									Default
										field_value = reflect_to_TValue( source_object_field.Get( source_object ))
								EndSelect
								TObject(converted_object).fields.Insert( source_object_field.Name(), field_value )
							Next
						EndIf
					EndIf
				Else ' source_object_type_id.ElementType() <> Null
					'Is Array
					converted_object = New TArray
					Local array_length% = source_object_type_id.ArrayLength( source_object )
					If array_length > 0
						Local element:Object
						Local element_value:TValue
						Local source_object_element_type_id:TTypeId = source_object_type_id.ElementType()
						For Local i% = 0 Until array_length
							element = source_object_type_id.GetArrayElement( source_object, i )
							Select source_object_element_type_id
								Case IntTypeId, ShortTypeId, ByteTypeId, LongTypeId, FloatTypeId, DoubleTypeId
									element_value = New TNumber
									TNumber(element_value).value = String( element ).ToDouble()
								Default
									element_value = reflect_to_TValue( element )
							EndSelect
							TArray(converted_object).elements.AddLast( element_value )
						Next
					EndIf
				EndIf
			EndIf
		EndIf
		Return converted_object
	EndFunction

	'fields defined by the destination type are OPTIONAL by default; 
	'  extra data or data not found will only generate warnings
	Function initialize_object:Object( source:TValue, type_id:TTypeId )
		If TNull(source) Or source = Null Then Return Null
		Local source_mapped:Object
		If type_id = TTypeId.ForName("TValue") Or type_id.SuperType() = TTypeId.ForName("TValue")
			source_mapped = source
		Else
			Local source_object_type_id:TTypeId = TTypeId.ForObject( source ) 
			If type_id.ElementType() = Null
				'Not Array Type
				If type_id = StringTypeId
					'String
					If TString(source)
						source_mapped = TString(source).value
					Else
						json_error( json.LOG_ERROR+" could not initialize "+type_id.Name()+" from "+source_object_type_id.Name() )
					EndIf
				Else
					'Non-array Non-string: User Defined Object
					If TObject(source)
						'Object data type provided (ideal)
						source_mapped = type_id.NewObject()
						Local source_mapped_field:TField
						Local source_field_value:TValue
						For Local field_name$ = EachIn TObject(source).fields.Keys()
							source_mapped_field = type_id.FindField( field_name )
							If source_mapped_field <> Null
								source_field_value = TValue(TObject(source).fields.ValueForKey( field_name ))
								Select source_mapped_field.TypeId()
									Case IntTypeId, ShortTypeId, ByteTypeId
										If TNumber(source_field_value)
											source_mapped_field.SetInt( source_mapped, Int(TNumber(source_field_value).value) )
										Else
											json_error( json.LOG_WARN+" could not initialize "+source_mapped_field.TypeId().Name()+" from "+TTypeId.ForObject( source_field_value ).Name() )
										EndIf
									Case LongTypeId
										If TNumber(source_field_value)
											source_mapped_field.SetLong( source_mapped, Long(TNumber(source_field_value).value) )
										Else
											json_error( json.LOG_WARN+" could not initialize "+source_mapped_field.TypeId().Name()+" from "+TTypeId.ForObject( source_field_value ).Name() )
										EndIf
									Case FloatTypeId
										If TNumber(source_field_value)
											source_mapped_field.SetFloat( source_mapped, Float(TNumber(source_field_value).value) )
										Else
											json_error( json.LOG_WARN+" could not initialize "+source_mapped_field.TypeId().Name()+" from "+TTypeId.ForObject( source_field_value ).Name() )
										EndIf
									Case DoubleTypeId
										If TNumber(source_field_value)
											source_mapped_field.SetDouble( source_mapped, Double(TNumber(source_field_value).value) )
										Else
											json_error( json.LOG_WARN+" could not initialize "+source_mapped_field.TypeId().Name()+" from "+TTypeId.ForObject( source_field_value ).Name() )
										EndIf
									Default
										'Recurse
										source_mapped_field.Set( source_mapped, initialize_object( source_field_value, source_mapped_field.TypeId() ))
								EndSelect
							Else
								json_error( json.LOG_WARN+" could not find field name "+field_name+" in object of type "+type_id.Name() )
							EndIf
						Next
					Else
						'Some other type of TValue provided
						json_error( json.LOG_ERROR+" could not initialize "+type_id.Name()+" from "+source_object_type_id.Name() )
					EndIf
				EndIf
			Else ' type_id.ElementType() <> Null
				'Array Type
				If TArray(source)
					Local element_type_id:TTypeId = type_id.ElementType()
					Local size% = TArray(source).elements.Count()
					source_mapped = type_id.NewArray( size )
					Local index% = 0
					For Local source_element_value:TValue = EachIn TArray(source).elements
						If source_element_value <> Null
							Select element_type_id
								Case IntTypeId, ShortTypeId, ByteTypeId, LongTypeId
									If TNumber(source_element_value)
										type_id.SetArrayElement( source_mapped, index, TNumber(source_element_value).Encode( 0, 0 ))
									Else
										json_error( json.LOG_WARN+" could not initialize "+element_type_id.Name()+" from "+TTypeId.ForObject( source_element_value ).Name() )
									EndIf
								Case FloatTypeId, DoubleTypeId
									If TNumber(source_element_value)
										type_id.SetArrayElement( source_mapped, index, TNumber(source_element_value).Encode( 0, json.precision ))
									Else
										json_error( json.LOG_WARN+" could not initialize "+element_type_id.Name()+" from "+TTypeId.ForObject( source_element_value ).Name() )
									EndIf
								Default
									'Recurse
									type_id.SetArrayElement( source_mapped, index, initialize_object( source_element_value, element_type_id ))
							EndSelect
						EndIf
						index :+ 1
					Next
				Else
					json_error( json.LOG_ERROR+" could not initialize "+type_id.Name()+" from "+source_object_type_id.Name() )
				EndIf
			EndIf
		EndIf
		Return source_mapped
	EndFunction

	'////////////////////////////////////////////////////////////////////////////

	Function enumerate_fields:TList( type_id:TTypeId )
		Local fields:TList = CreateList()
		Local type_cursor:TTypeId = type_id
		Repeat
			type_cursor.EnumFields( fields )
			type_cursor = type_cursor.SuperType()
		Until type_cursor = Null
		Return fields
	EndFunction

	'////////////////////////////////////////////////////////////////////////////

	Function FormatDouble:String( value:Double, precision:Int )
		'trims trailing zeroes and decimal separator
		Extern "C"
			Function snprintf_:Int( s:Byte Ptr, n:Int, Format$z, p:Int, v1:Double) = "snprintf"
		EndExtern
		Const CHAR_0:Byte = Asc("0")
		Const CHAR_DOT:Byte = Asc(".")
		Const STR_FMT:String = "%.*f"
		If precision = -1 Then precision = 6 'cstdio.h default
		Local i:Double
		Local buf:Byte[256]
		Local sz:Int = snprintf_( buf, buf.Length, STR_FMT, precision, value)
		sz :- 1
		While (sz > 0) And (buf[sz] = CHAR_0)
			sz :- 1
		Wend
		If (sz < buf.Length) And buf[sz] <> CHAR_DOT
			sz :+ 1
		EndIf
		If sz > 0
			Return String.FromBytes( buf, sz )
		Else
			Return "0"
		EndIf
	EndFunction

	Function EatWhitespace( encoded$, cursor% Var )
		' advance cursor to first printable character
		Local cursor_char$, comment% = False
		While cursor < encoded.Length
			cursor_char = Chr( encoded[cursor] )
			If Chr( encoded[cursor] ) = "#"
				comment = True
			Else If Chr( encoded[cursor] ) = "~r" Or Chr( encoded[cursor] ) = "~n"
				comment = False
			End If
			If comment Or Not IsPrintable( cursor_char )
				cursor :+ 1
			Else
				Exit 'done
			End If
		End While
	EndFunction

	Function EatSpecific%( encoded$, cursor% Var, char_filter$, limit% = -1, require% = -1 )
		Local cursor_start% = cursor
		Local contained_in_filter% = True
		While cursor < encoded.Length And contained_in_filter
			contained_in_filter = False
			For Local c% = 0 Until char_filter.Length
				If encoded[cursor] = char_filter[c]
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
			json_error( json.LOG_ERROR+" expected at least "+require+" characters from the set ["+char_filter+"]" )
		End If
		Return cursor - cursor_start
	EndFunction

	Function CheckLeftovers( encoded$, cursor% Var )
		If cursor < encoded.Length
			EatWhitespace( encoded, cursor )
			If cursor < encoded.Length
				json_error( json.LOG_ERROR+" unexpected data following root-level entity: "+Chr(encoded[cursor]) )
			EndIf
		EndIf
	EndFunction

	Function RepeatSpace$( count% )
		Return LSet( "", count )
	EndFunction

	Function Escape$( str$ )
		Return str.Replace( "\", "\\" ).Replace( "~q", "\~q" ).Replace( "~r", "\r" ).Replace( "~n", "\n" ).Replace( "~t", "\t" )  
	EndFunction

	Function IsNumeric%( char$ )
		If char.Length > 1 Then char = char[0..1]
		Local ascii_code% = Asc( char )
		Return (ascii_code >= Asc( "0" ) And ascii_code <= Asc( "9" )) ..
		    Or (ascii_code = Asc("-") Or ascii_code = Asc("+")) ..
		    Or (ascii_code = Asc("."))
	End Function

	Function IsAlphaNumericOrUnderscore%( char$ )
		If char.Length > 1 Then char = char[0..1]
		Local ascii_code% = Asc( char )
		Return (ascii_code >= Asc( "A" ) And ascii_code <= Asc( "Z" )) ..
		Or     (ascii_code >= Asc( "a" ) And ascii_code <= Asc( "z" )) ..
		Or     (ascii_code >= Asc( "0" ) And ascii_code <= Asc( "9" )) ..
		Or     ascii_code =  Asc( "_" )		
	End Function

	Function IsPrintable%( char$ )
		If char.Length > 1 Then char = char[0..1]
		Local ascii_code% = Asc( char )
		Return ascii_code > 32 And ascii_code <> 127
	EndFunction

	Function ShowPosition$( encoded$, cursor% )
		Local dist% = 15
		Local slice$ = encoded[cursor-1-dist..cursor+dist].Replace("~n"," ").Replace("~t"," ")
		Return "~n"+slice+"~n"+json.RepeatSpace(dist)+"^"
	EndFunction

	'logging/exceptions /////////////////////////////////////////////////////////
	Const LOG_WARN$ = "[WARN]"
	Const LOG_ERROR$ = "[ERROR]"

	'supported built-in cyclic data types ///////////////////////////////////////
	Global TMap_TTypeId:TTypeId = TTypeId.ForName("TMap")
	Global TList_TTypeId:TTypeId = TTypeId.ForName("TList")

End Type

Function json_error( message$ )
	Select json.error_level
		Case 2 ' strict
			If message.StartsWith( json.LOG_ERROR ) Or message.StartsWith( json.LOG_WARN )
				Throw message
			EndIf
		Case 1 ' ignore warnings
			If message.StartsWith( json.LOG_ERROR )
				Throw message
			EndIf
		Case 0 ' ignore all
			' do nothing
	EndSelect
EndFunction


'////////////////////////////////////////////////////////////////////////////
'////////////////////////////////////////////////////////////////////////////
'////////////////////////////////////////////////////////////////////////////


Type TValue
	
	Field value_type%

	Method Encode:String( indent%, precision% ) Abstract

	Method Decode( encoded$, cursor% Var ) Abstract

	Method Equals%( val:Object ) Abstract

	'////////////////////////////////////////////////////////////////////////////

	Method ToString:String()
		Return Encode( 0, json.precision )
	EndMethod

	Method GetSelectorCode$()
		Select value_type
			Case JSONTYPE_NULL
				Return json.SEL_NULL
			Case JSONTYPE_BOOLEAN
				Return json.SEL_BOOLEAN
			Case JSONTYPE_NUMBER
				Return json.SEL_NUMBER
			Case JSONTYPE_STRING
				Return json.SEL_STRING
			Case JSONTYPE_ARRAY
				Return json.SEL_ARRAY
			Case JSONTYPE_OBJECT
				Return json.SEL_OBJECT
			Default
				Return Null
		EndSelect
	EndMethod

	'////////////////////////////////////////////////////////////////////////////

	'this method is used to select an appropriate intermediate type to decode into
	'  given only the encoded JSON data
	Function PredictJSONType%( encoded$, cursor% )
		If encoded = Null Or encoded = "" Then Return JSONTYPE_NULL
		json.EatWhitespace( encoded, cursor )
		encoded = encoded[cursor..(cursor+SCAN_DISTANCE)]
		If encoded.StartsWith( VALUE_NULL )
			Return JSONTYPE_NULL
		ElseIf encoded.StartsWith( VALUE_TRUE ) Or encoded.StartsWith( VALUE_FALSE )
			Return JSONTYPE_BOOLEAN
		ElseIf json.IsNumeric( encoded )
			Return JSONTYPE_NUMBER
		ElseIf encoded.StartsWith( STRING_BEGIN )
			Return JSONTYPE_STRING
		ElseIf encoded.StartsWith( ARRAY_BEGIN )
			Return JSONTYPE_ARRAY
		ElseIf encoded.StartsWith( OBJECT_BEGIN )
			Return JSONTYPE_OBJECT
		ElseIf json.IsAlphaNumericOrUnderscore( encoded )
			Return JSONTYPE_STRING 'unquoted string
		Else
			Return JSONTYPE_INVALID
		EndIf
	EndFunction

	'Internal Type Enums
	Const JSONTYPE_INVALID% = -1
	Const JSONTYPE_NULL%    = 0
	Const JSONTYPE_BOOLEAN% = 1
	Const JSONTYPE_NUMBER%  = 2
	Const JSONTYPE_STRING%  = 3
	Const JSONTYPE_ARRAY%   = 4
	Const JSONTYPE_OBJECT%  = 5

	'ASCII Literals
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
	Const STRING_ESCAPE_SOLIDUS$         = "/"
	Const STRING_ESCAPE_BACKSPACE$       = "b"
	Const STRING_ESCAPE_FORMFEED$        = "f"
	Const STRING_ESCAPE_NEWLINE$         = "n"
	Const STRING_ESCAPE_CARRIAGE_RETURN$ = "r"
	Const STRING_ESCAPE_HORIZONTAL_TAB$  = "t"
	Const STRING_ESCAPE_UNICODE_BEGIN$   = "u"

	Const SCAN_DISTANCE% = 5 'the most number of characters that we'd ever have to look ahead by

EndType


Type TNull Extends TValue
	
	Method New()
		value_type = JSONTYPE_NULL
	EndMethod

	Method Encode:String( indent%, precision% )
		Return VALUE_NULL
	EndMethod

	Method Decode( encoded$, cursor% Var )
		json.EatWhitespace( encoded, cursor )
		If encoded[cursor..(cursor+VALUE_NULL.Length)] = VALUE_NULL
			cursor :+ VALUE_NULL.Length
		EndIf
	EndMethod

	Method Equals%( other:Object )
		Return (TNull(other) <> Null And TNull(other).value_type = JSONTYPE_NULL)
	EndMethod

EndType


Type TBoolean Extends TValue
	
	Field value:Int

	Method New()
		value_type = JSONTYPE_BOOLEAN
	EndMethod

	Method Encode:String( indent%, precision% )
		If value = 0
			Return VALUE_FALSE
		Else
			Return VALUE_TRUE
		EndIf
	EndMethod

	Method Decode( encoded$, cursor% Var )
		json.EatWhitespace( encoded, cursor )
		If encoded[cursor..(cursor+VALUE_FALSE.Length)] = VALUE_FALSE
			value = False
			cursor :+ VALUE_FALSE.Length
		ElseIf encoded[cursor..(cursor+VALUE_TRUE.Length)] = VALUE_TRUE
			value = True
			cursor :+ VALUE_TRUE.Length
		EndIf
	EndMethod

	Method Equals%( other:Object )
		Return (TBoolean(other) <> Null And TBoolean(other).value_type = JSONTYPE_BOOLEAN And TBoolean(other).value = Self.value)
	EndMethod

EndType


Type TNumber Extends TValue

	Field value:Double

	Method New()
		value_type = JSONTYPE_NUMBER
	EndMethod

	Method Encode:String( indent%, precision% )
		Return json.FormatDouble( value, precision )
	EndMethod

	Method Decode( encoded$, cursor% Var )
		json.EatWhitespace( encoded, cursor )
		Local cursor_start% = cursor
		Local floating_point% = False
		json.EatSpecific( encoded, cursor, "+-", 1 ) 'positive/negative
		json.EatSpecific( encoded, cursor, "0123456789",, 1 )
		If json.EatSpecific( encoded, cursor, ".", 1 ) 'decimal pt.
			floating_point = True
			json.EatSpecific( encoded, cursor, "0123456789",, 1 )
		End If
		If json.EatSpecific( encoded, cursor, "eE", 1 ) 'scientific notation
			floating_point = True
			json.EatSpecific( encoded, cursor, "+-", 1 ) 'mantissa
			json.EatSpecific( encoded, cursor, "0123456789",, 1 )
		End If
		If json.EatSpecific( encoded, cursor, "f", 1, 0 ) 'trailing f (floating point, java)
			floating_point = True
		End If
		If (cursor - cursor_start) > 0
			Local encoded_number$ = encoded[cursor_start..cursor]
			If encoded_number And encoded_number.Length > 0
				value = encoded_number.ToDouble()
			End If
		End If
	EndMethod

	Method Equals%( other:Object )
		Return (TNumber(other) <> Null And TNumber(other).value_type = JSONTYPE_NUMBER And TNumber(other).value = Self.value)
	EndMethod

EndType


Type TString Extends TValue

	Field value:String

	Method New()
		value_type = JSONTYPE_STRING
	EndMethod

	Method Encode:String( indent%, precision% )
		Return STRING_BEGIN + json.Escape( value ) + STRING_END
	EndMethod

	Method Decode( encoded$, cursor% Var )
		Local decoded_value$ = ""
		Local unquoted_mode_active% = False
		json.EatWhitespace( encoded, cursor )
		Local char$, char_temp$
		If cursor >= (encoded.Length) Then Return
		char = Chr(encoded[cursor]); cursor :+ 1
		If char <> STRING_BEGIN
			If json.IsAlphaNumericOrUnderscore( char )
				decoded_value :+ char 'NORMAL STRING CHARACTER
				unquoted_mode_active = True
			Else
				json_error( json.LOG_ERROR+" expected string at position "+(cursor-1)+json.ShowPosition(encoded,cursor) )
			EndIf
		End If
		If Not unquoted_mode_active
			'Normal, Quoted String Mode
			Repeat
				char = Chr(encoded[cursor]); cursor :+ 1
				If char = STRING_END
					Exit
				End If
				If char = "~r" Or char = "~n"
					json_error( json.LOG_ERROR+" unescaped newline in string at position "+(cursor-1)+json.ShowPosition(encoded,cursor) )
				ElseIf char = "~t"
					json_error( json.LOG_ERROR+" unescaped horizontal-tab in string at position "+(cursor-1)+json.ShowPosition(encoded,cursor) )
				ElseIf char <> STRING_ESCAPE_SEQUENCE_BEGIN
					decoded_value :+ char 'NORMAL STRING CHARACTER
				Else
					If cursor >= encoded.Length
						json_error( json.LOG_ERROR+" unterminated string literal" )
					End If
					char_temp = Chr(encoded[cursor]); cursor :+ 1
					Select char_temp
						Case STRING_ESCAPE_QUOTATION
							decoded_value :+ "~q"
						Case STRING_ESCAPE_REVERSE_SOLIDUS
							decoded_value :+ "\"
						Case STRING_ESCAPE_SOLIDUS
							decoded_value :+ "/"
						Case STRING_ESCAPE_BACKSPACE
							'ignore
						Case STRING_ESCAPE_FORMFEED
							'ignore
						Case STRING_ESCAPE_NEWLINE
							decoded_value :+ "~n"
						Case STRING_ESCAPE_CARRIAGE_RETURN
							decoded_value :+ "~r"
						Case STRING_ESCAPE_HORIZONTAL_TAB
							decoded_value :+ "~t"
						Case STRING_ESCAPE_UNICODE_BEGIN
							'ignore
							cursor :+ 4
						Default
							json_error( json.LOG_ERROR+" bad string escape sequence at position "+(cursor-1)+json.ShowPosition(encoded,cursor) )
					End Select
				End If
			Until cursor >= encoded.Length
		Else 'unquoted_mode_active
			'Unquoted String / Enumeration Mode
			' This means AlphaNumeric or Underscore characters ONLY
			' Any other characters encountered from this point on will trigger the end of the string
			Repeat
				If cursor >= (encoded.Length)
					Exit 'done (but could indicate an error higher up the chain)
				EndIf
				char = Chr(encoded[cursor]); cursor :+ 1
				If json.IsAlphaNumericOrUnderscore( char )
					decoded_value :+ char 'NORMAL STRING CHARACTER
				Else
					Exit 'done
				EndIf
			Until cursor >= (encoded.Length)
		EndIf
		value = decoded_value
	EndMethod

	Method Equals%( other:Object )
		Return (TString(other) <> Null And TString(other).value_type = JSONTYPE_STRING And TString(other).value = Self.value)
	EndMethod

EndType


Type TArray Extends TValue

	Field elements:TList'<TValue>

	Method New()
		value_type = JSONTYPE_ARRAY
		elements = CreateList()
	EndMethod

	Method Encode:String( indent%, precision% )
		If elements = Null Or elements.IsEmpty() Then Return VALUE_NULL
		Local encoded$ = ""
		encoded :+ ARRAY_BEGIN
		If json.formatted Then encoded :+ "~n"
		If json.formatted Then indent :+ 1
		If json.formatted Then encoded :+ json.RepeatSpace( indent*json.indent_size )
		Local size% = elements.Count()
		Local index% = 0
		For Local element:TValue = EachIn elements
			If element <> Null
				encoded :+ element.Encode( indent, precision )
			Else
				encoded :+ VALUE_NULL
			EndIf
			index :+ 1
			If index < size
				encoded :+ VALUE_SEPARATOR
				If json.formatted Then encoded :+ "~n"
				If json.formatted Then encoded :+ json.RepeatSpace( indent*json.indent_size )
			Else 'index >= size
				If json.formatted Then encoded :+ "~n"
				If json.formatted Then indent :- 1
				If json.formatted Then encoded :+ json.RepeatSpace( indent*json.indent_size )
			EndIf
		Next
		encoded :+ ARRAY_END
		Return encoded
	EndMethod

	Method Decode( encoded$, cursor% Var )
		If encoded = "" Then Return
		json.EatWhitespace( encoded, cursor )
		Local char$
		If cursor >= encoded.Length Then Return
		char = Chr(encoded[cursor]); cursor :+ 1
		If char <> ARRAY_BEGIN
			json_error( json.LOG_ERROR+" expected open-square-bracket character at position "+(cursor-1)+json.ShowPosition(encoded, cursor) )
		End If
		Local decoded_elements:TList = CreateList()
		Local element_value:TValue
		Repeat
			If cursor >= encoded.Length
				json_error( json.LOG_ERROR+" expected JSON Value at position "+(cursor-1)+json.ShowPosition(encoded, cursor) )
			EndIf					
			json.EatWhitespace( encoded, cursor )
			If cursor >= encoded.Length Then Exit
			char = Chr(encoded[cursor])
			If char = ARRAY_END
				cursor :+ 1 'eat it
				Exit 'empty object with no fields
			EndIf
			element_value = json.allocate_TValue( encoded, cursor )
			If element_value = Null
				json_error( json.LOG_ERROR+" expected JSON Value at position "+(cursor-1)+json.ShowPosition(encoded, cursor) )
			EndIf
			element_value.Decode( encoded, cursor )
			decoded_elements.AddLast( element_value ) ' add element
			json.EatWhitespace( encoded, cursor )
			If cursor >= (encoded.Length) Then Exit
			char = Chr(encoded[cursor]); cursor :+ 1
			If char <> VALUE_SEPARATOR And char <> VALUE_SEPARATOR_ALTERNATE And char <> ARRAY_END
				json_error( json.LOG_ERROR+" expected comma or semicolon or close-square-bracket character at position "+(cursor-1)+json.ShowPosition(encoded, cursor) )
			End If
		Until char = ARRAY_END Or cursor >= encoded.Length
		If char <> ARRAY_END
			json_error(json.LOG_ERROR+" expected close-square-bracket character at position "+(cursor-1)+json.ShowPosition(encoded,cursor))
		EndIf
		elements = decoded_elements
	EndMethod

	Method Equals%( other:Object )
		If Not (TArray(other) <> Null And TArray(other).value_type = JSONTYPE_ARRAY And TArray(other).elements.Count() = Self.elements.Count())
			Return False
		EndIf
		If Self.elements.Count() > 0
			Local self_link:TLink = Self.elements.FirstLink()
			Local other_link:TLink = TArray(other).elements.FirstLink()
			Local self_value:TValue
			Local other_value:TValue
			While self_link.NextLink() <> self_link
				self_value = TValue(self_link._value)
				other_value = TValue(other_link._value)
				If Not self_value.Equals( other_value )
					Return False
				EndIf
				self_link = self_link.NextLink()
				other_link = other_link.NextLink()
			EndWhile
		EndIf
		Return True
	EndMethod

EndType


Type TObject Extends TValue

	Field fields:TMap'<String,TValue>

	Method New()
		value_type = JSONTYPE_OBJECT
		fields = CreateMap()
	EndMethod

	Method Encode:String( indent%, precision% )
		If fields = Null Or fields.IsEmpty() Then Return VALUE_NULL
		Local encoded$ = ""
		encoded :+ OBJECT_BEGIN
		Local iter:TNodeEnumerator = fields.Keys().ObjectEnumerator()
		If iter.HasNext()
			If json.formatted Then encoded :+ "~n"
			If json.formatted Then indent :+ 1
			If json.formatted Then encoded :+ json.RepeatSpace( indent*json.indent_size )
			While iter.HasNext()
				Local field_name:String = String( iter.NextObject() )
				encoded :+ STRING_BEGIN
				encoded :+ field_name
				encoded :+ STRING_END
				encoded :+ PAIR_SEPARATOR
				If json.formatted Then encoded :+ " "
				Local field_value:TValue = TValue( fields.ValueForKey( field_name ))
				encoded :+ field_value.Encode( indent, precision )
				If iter.HasNext()
					encoded :+ VALUE_SEPARATOR
					If json.formatted Then encoded :+ "~n"
					If json.formatted Then encoded :+ json.RepeatSpace( indent*json.indent_size )
				Else 'last element
					If json.formatted Then encoded :+ "~n"
					If json.formatted Then indent :- 1
					If json.formatted Then encoded :+ json.RepeatSpace( indent*json.indent_size )
				End If
			End While
		End If
		encoded :+ OBJECT_END
		Return encoded
	EndMethod

	Method Decode( encoded$, cursor% Var )
		Local decoded_fields:TMap = CreateMap()
		json.EatWhitespace( encoded, cursor )
		Local char$
		If cursor >= (encoded.Length) Then Return
		char = Chr(encoded[cursor]); cursor :+ 1
		If char <> OBJECT_BEGIN
			json_error( json.LOG_ERROR+" expected open-curly-brace character at position "+(cursor-1)+json.ShowPosition(encoded, cursor)  )
		End If
		Local field_name:TString = New TString
		Local field_value:TValue
		Repeat
			json.EatWhitespace( encoded, cursor )
			If cursor >= encoded.Length Then Exit
			char = Chr(encoded[cursor])
			If char = OBJECT_END
				cursor :+ 1 'eat it
				Exit 'empty object with no fields
			EndIf
			field_name.Decode( encoded, cursor )
			json.EatWhitespace( encoded, cursor )
			If cursor >= encoded.Length Then Exit
			char = Chr(encoded[cursor]); cursor :+ 1
			If char <> PAIR_SEPARATOR
				json_error( json.LOG_ERROR+" expected colon character at position "+(cursor-1)+json.ShowPosition(encoded, cursor)  )
			End If
			json.EatWhitespace( encoded, cursor )
			field_value = json.allocate_TValue( encoded, cursor )
			If field_value = Null
				json_error( json.LOG_ERROR+" expected JSON Value at position "+(cursor-1)+json.ShowPosition(encoded, cursor)  )
			EndIf
			field_value.Decode( encoded, cursor )
			decoded_fields.Insert( field_name.value, field_value )
			json.EatWhitespace( encoded, cursor )
			If cursor >= (encoded.Length) Then Exit
			char = Chr(encoded[cursor]); cursor :+ 1
			If char <> VALUE_SEPARATOR And char <> VALUE_SEPARATOR_ALTERNATE And char <> OBJECT_END
				json_error( json.LOG_ERROR+" expected comma or semicolon or close-curly-brace character at position "+(cursor-1)+json.ShowPosition(encoded, cursor)  )
			End If
		Until char = OBJECT_END Or cursor >= encoded.Length
		If char <> OBJECT_END
			json_error(json.LOG_ERROR+" expected close-curly-brace character at position "+(cursor-1)+json.ShowPosition(encoded,cursor))
		EndIf
		fields = decoded_fields
	EndMethod

	Method Equals%( other:Object )
		If Not (TObject(other) <> Null ..
			 And TObject(other).value_type = JSONTYPE_OBJECT) ..
			Then Return False
		Local self_value:TValue
		Local other_value:TValue
		For Local field_name$ = EachIn Self.fields.Keys()
			self_value = TValue( Self.fields.ValueForKey( field_name ))
			other_value = TValue( TObject(other).fields.ValueForKey( field_name ))
			If Not self_value.Equals( other_value )
				Return False
			EndIf
		Next
		Return True
	EndMethod

EndType


'////////////////////////////////////////////////////////////////////////////
'////////////////////////////////////////////////////////////////////////////
'////////////////////////////////////////////////////////////////////////////


'This needs to be more robust about how it accepts type names and field names.
Type TValue_Selector_Token

	Field type_name$
	Field object_field_name$
	Field array_element_index%

	Method New()
		type_name = Null
		object_field_name = Null
		array_element_index = -1
	EndMethod

	Function Create:TValue_Selector_Token( selector_token$ )
		If Not selector_token Then Return Null
		Local tok:TValue_Selector_Token = New TValue_Selector_Token
		selector_token = selector_token
		tok.type_name = ParseSelectorTypeName( selector_token )
		tok.object_field_name = ParseSelectorObjectFieldName( selector_token )
		tok.array_element_index = ParseSelectorArrayElementIndex( selector_token )
		Return tok
	EndFunction

	Method ToString$()
		Local s$ = ""
		If object_field_name <> Null Then s:+"$"+object_field_name
		If array_element_index <> -1 Then s:+"@"+array_element_index
		If type_name <> Null         Then s:+":"+type_name
		Return s
	EndMethod

	Function ParseSelectorTypeName$( selector_token$ )
		Local cursor% = selector_token.Find( SELECTOR_TYPE_NAME_START )
		If cursor <> -1
			Local value$ = ""
			cursor :+ 1
			While cursor < selector_token.Length ..
			And   json.IsAlphaNumericOrUnderscore( Chr( selector_token[cursor] ))
				value :+ Chr( selector_token[cursor] )
				cursor :+ 1
			EndWhile
			Return value
		EndIf
		Return Null
	EndFunction

	Function ParseSelectorObjectFieldName$( selector_token$ )
		Local cursor% = selector_token.Find( SELECTOR_OBJECT_FIELD_NAME_START )
		If cursor <> -1
			Local value$ = ""
			cursor :+ 1
			While cursor < selector_token.Length ..
			And   json.IsAlphaNumericOrUnderscore( Chr( selector_token[cursor] ))
				value :+ Chr( selector_token[cursor] )
				cursor :+ 1
			EndWhile
			Return value
		EndIf
		Return Null
	EndFunction

	Function ParseSelectorArrayElementIndex%( selector_token$ )
		Local cursor% = selector_token.Find( SELECTOR_ARRAY_ELEMENT_INDEX_START )
		If cursor <> -1
			Local value$ = ""
			cursor :+ 1
			While cursor < selector_token.Length ..
			And   json.IsNumeric( Chr( selector_token[cursor] ))
				value :+ Chr( selector_token[cursor] )
				cursor :+ 1
			EndWhile
			Return value.ToInt()
		EndIf
		Return -1
	EndFunction

	'//////////
	Global SELECTOR_LEVEL_SEPARATOR$ =           "/"
	Global SELECTOR_TYPE_NAME_START$ =           ":"
	Global SELECTOR_OBJECT_FIELD_NAME_START$ =   "$"
	Global SELECTOR_ARRAY_ELEMENT_INDEX_START$ = "@"

EndType


Type TValue_Search_Result
	
	'the value in question
	Field matched:TValue
	'the containing object and field name, if any
	Field container_TObject:TObject
	Field object_field_name$
	'the containing array and index, if any
	Field container_TArray:TArray
	Field array_element_index%

	Function Create:TValue_Search_Result( matched:TValue, ..
	container_TObject:TObject=Null, object_field_name$=Null, ..
	container_TArray:TArray=Null, array_element_index%=-1 )
		Local r:TValue_Search_Result = New TValue_Search_Result
		r.matched = matched
		r.container_TObject = container_TObject
		r.object_field_name = object_field_name
		r.container_TArray = container_TArray
		r.array_element_index = array_element_index
		Return r
	EndFunction

EndType


Type TValue_Transformation
	
	Field selector:TValue_Selector_Token[]
	Field imperative_id%
	Field argument:Object
	Field condition_func%( val:TValue_Search_Result )

	Function Create:TValue_Transformation( selector$, imperative_id%, argument:Object, condition_func%( val:TValue_Search_Result ) )
		Local xf:TValue_Transformation = New TValue_Transformation
		xf.selector = ParseSelectorString( selector )
		xf.imperative_id = imperative_id
		xf.argument = argument
		xf.condition_func = condition_func
		Return xf
	EndFunction

	Method Execute( val:TValue )
		Local matches:TList = Search( val )
		For Local result:TValue_Search_Result = EachIn matches
			If (condition_func = Null) Or (condition_func( result ) = True)
				Select imperative_id
					Case json.XJ_DELETE
						If result.container_TObject
							result.container_TObject.fields.Remove( result.object_field_name )
						ElseIf result.container_TArray
							result.container_TArray.elements.Remove( result )
						EndIf
					Case json.XJ_RENAME
						If result.container_TObject
							result.container_TObject.fields.Insert( String(argument), result.matched )
							result.container_TObject.fields.Remove( result.object_field_name )
						EndIf
					Case json.XJ_CONVERT
						'???
				EndSelect
			EndIf
		Next
	EndMethod

	'recursive function (naturally) that
	'returns a List of SelectorResult objects
	Method Search:TList( this:TValue, container:TValue=Null, matches:TList=Null, path:TValue_Selector_Token[]=Null )
		'DebugLog " "+PathIndent(path)+LSet(ObjectInfo(this),18)+", "+PathInfo(path)
		If matches = Null Then matches = CreateList()
		If path <> Null And path.Length = selector.Length
			'determine if the current path matches the selector
			Local s:TValue_Selector_Token = selector[selector.Length - 1]
			Local p:TValue_Selector_Token = path[path.Length - 1]
			If  (s.type_name = Null Or s.type_name = p.type_name) ..
			And (s.object_field_name = Null Or s.object_field_name = p.object_field_name) ..
			And (s.array_element_index = -1 Or s.array_element_index = p.array_element_index)
				matches.AddLast( TValue_Search_Result.Create( ..
					this, TObject(container), p.object_field_name, TArray(container), p.array_element_index ))
			EndIf
		ElseIf path = Null Or path.Length < selector.Length
			'Allocate space for new path token
			If path = Null Then path = New TValue_Selector_Token[1] ..
			Else path = path[..path.Length + 1]
			'if this TValue is a container type, search its children
			If TObject(this)
				'search all fields of objects
				For Local field_name$ = EachIn TObject(this).fields.Keys()
					Local field_value:TValue = TValue(TObject(this).fields.ValueForKey( field_name ))
					path[path.Length - 1] = New TValue_Selector_Token
					path[path.Length - 1].type_name = field_value.GetSelectorCode()
					path[path.Length - 1].object_field_name = field_name
					Search( field_value, this, matches, path )
				Next
			ElseIf TArray(this)
				'search all elements of arrays
				Local element_index% = 0
				For Local array_element:TValue = EachIn TArray(this).elements
					path[path.Length - 1] = New TValue_Selector_Token
					path[path.Length - 1].type_name = array_element.GetSelectorCode()
					path[path.Length - 1].array_element_index = element_index
					Search( array_element, this, matches, path )
					element_index :+ 1
				Next
			EndIf
		EndIf
		Return matches
	EndMethod

	?Debug
	Function ObjectInfo$( obj:Object )
		If obj <> Null
			Return "$" + Hex( Int( Byte Ptr( obj ))) + ":" + TTypeId.ForObject( obj ).Name()
		Else
			Return "$" + Hex( 0 )
		End If
	End Function
	Function PathInfo$( path:TValue_Selector_Token[] )
		Local s$ = ""
		If path
			For Local i% = 0 Until path.Length
				If i > 0 Then s :+ "/"
				s :+ path[i].ToString()
			Next
		EndIf
		Return s
	EndFunction
	Function PathIndent$( path:TValue_Selector_Token[] )
		If Not path Then Return "" Else Return LSet("",path.Length*2)
	EndFunction
	?

	'////////////////

	Function ParseSelectorString:TValue_Selector_Token[]( selector_str$ )
		Local selector_tok$[] = selector_str.Split( TValue_Selector_Token.SELECTOR_LEVEL_SEPARATOR )
		Local selector:TValue_Selector_Token[] = New TValue_Selector_Token[selector_tok.Length]
		For Local i% = 0 Until selector.Length
			selector[i] = TValue_Selector_Token.Create( selector_tok[i] )
		Next
		Return selector
	EndFunction

EndType



