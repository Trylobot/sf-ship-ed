'test for rjson2.bmx
' derived from tests in the jsonlint github project
SuperStrict
Import "src/rjson.bmx"

Global test_dir$ = "test"

'var fs = require("fs"),
''    assert = require("assert"),
''    parser = require("../lib/jsonlint").parser;

json.formatted = False
json.empty_container_as_null = True

Function test_object()
	Print "*** test_object"
	Local json_str$ = "{~qfoo~q: ~qbar~q}"
	Local val:TString = New TString
	val.value = "bar"
	Local obj:TObject = New TObject
	obj.fields.Insert( "foo", val )
	Local json_obj:TValue = TValue( json.parse( json_str ))
	verify( json_obj.Equals( obj ), json_obj.ToString()+"~n"+obj.ToString() )
EndFunction

Function test_escaped_backslash()
	Print "*** test_escaped_backslash"
	Local json_str$ = "{~qfoo~q: ~q\\~q}"
	Local val:TString = New TString
	val.value = "\"
	Local obj:TObject = New TObject
	obj.fields.Insert( "foo", val )
	Local json_obj:TValue = TValue( json.parse( json_str ))
	verify( json_obj.Equals( obj ), json_obj.ToString()+"~n"+obj.ToString() )
EndFunction

Function test_escaped_chars()
	Print "*** test_escaped_chars"
	Local json_str$ = "{~qfoo~q: ~q\\\\\\\~q~q}"
	Local val:TString = New TString
	val.value = "\\\~q"
	Local obj:TObject = New TObject
	obj.fields.Insert( "foo", val )
	Local json_obj:TValue = TValue( json.parse( json_str ))
	verify( json_obj.Equals( obj ), json_obj.ToString()+"~n"+obj.ToString() )
EndFunction

Function test_escaped_newline()
	Print "*** test_escaped_newline"
	Local json_str$ = "{~qfoo~q: ~q\\\n~q}"
	Local val:TString = New TString
	val.value = "\~n"
	Local obj:TObject = New TObject
	obj.fields.Insert( "foo", val )
	Local json_obj:TValue = TValue( json.parse( json_str ))
	verify( json_obj.Equals( obj ), json_obj.ToString()+"~n"+obj.ToString() )
EndFunction

Function test_string_with_escaped_line_break()
	Print "*** test_string_with_escaped_line_break"
	Local json_str$ = "{~qfoo~q:~qbar\nbar~q}"
	Local val:TString = New TString
	val.value = "bar~nbar"
	Local obj:TValue = New TObject
	TObject(obj).fields.Insert( "foo", val )
	Local json_obj:TValue = TValue( json.parse( json_str ))
	verify( json_obj.Equals( obj ), json_obj.ToString()+"~n"+obj.ToString() )
	Local json_str_roundtrip$ = json.stringify( json_obj )
	verify( json_str_roundtrip = json_str,  json_str+"~n"+json_str_roundtrip )
EndFunction

Function test_string_with_line_break()
	Print "*** test_string_with_line_break"
	Local json_str$ = "{~qfoo~q: ~qbar~nbar~q}"
	Try
		json.parse( json_str )
	Catch ex$
		Return
	EndTry
	verify( False, "    should throw error" )
EndFunction

Function test_string_literal()
	Print "*** test_string_literal"
	Local json_str$ = "~qfoo~q"
	Local val:TString = New TString; val.value = "foo";
	verify( val.Equals( json.parse( json_str )) )
EndFunction

Function test_number_literal()
	Print "*** test_number_literal"
	Local json_str$ = "1234"
	Local val:TNumber = New TNumber; val.value = 1234;
	verify( val.Equals( json.parse( json_str )) )
EndFunction

Function test_number_literal2()
	Print "*** test_number_literal with trailing f"
	Local json_str$ = "1234.0f"
	Local val:TNumber = New TNumber; val.value = 1234;
	verify( val.Equals( json.parse( json_str )) )
EndFunction

Function test_number_literal3()
	Print "*** test_number_literal starting with decimal point"
	Local json_str$ = ".8"
	Local test_val:TNumber = New TNumber
	test_val.value = 0.8;
	Local decoded_val:TNumber = TNumber( json.parse( json_str ))
	Local test_val_str$ = json.FormatDouble( test_val.value )
	Local decoded_val_str$ = json.FormatDouble( decoded_val.value )
	verify( test_val_str = decoded_val_str, ""+test_val_str+" <> "+decoded_val_str )
EndFunction

Function test_null_literal()
	Print "*** test_null_literal"
	Local json_str$ = "null"
	Local val:TNull = New TNull
	verify( val.Equals( json.parse( json_str )) )
EndFunction

Function test_boolean_literal()
	Print "*** test_boolean_literal"
	Local json_str$ = "true"
	Local val:TBoolean = New TBoolean; val.value = True
	verify( val.Equals( json.parse( json_str )) )
EndFunction

Function test_unclosed_array()
	Print "*** test_unclosed_array"
	Local json_str$ = LoadString( test_dir + "/fails/2.json" )
	Try
		json.parse( json_str )
	Catch ex$
		Return
	EndTry
	verify( False, "    should throw error" )
EndFunction

Function test_unquotedkey_keys_must_be_quoted()
	Print "*** test_unquotedkey_keys_must_be_quoted"
	Local json_str$ = LoadString( test_dir + "/fails/3.json" )
	Try
		json.parse( json_str )
	Catch ex$
		Return
	EndTry
	verify( False, "    should throw error" )
EndFunction

Function test_extra_comma()
	Print "*** test_extra_comma"
	Local json_str$ = LoadString( test_dir + "/fails/4.json" )
	Try
		json.parse( json_str )
	Catch ex$
		Return
	EndTry
	verify( False, "    should throw error" )
EndFunction

Function test_double_extra_comma()
	Print "*** test_double_extra_comma"
	Local json_str$ = LoadString( test_dir + "/fails/5.json" )
	Try
		json.parse( json_str )
	Catch ex$
		Return
	EndTry
	verify( False, "    should throw error" )
EndFunction

Function test_missing_value()
	Print "*** test_missing_value"
	Local json_str$ = LoadString( test_dir + "/fails/6.json" )
	Try
		json.parse( json_str )
	Catch ex$
		Return
	EndTry
	verify( False, "    should throw error" )
EndFunction

Function test_comma_after_the_close()
	Print "*** test_comma_after_the_close"
	Local json_str$ = LoadString( test_dir + "/fails/7.json" )
	Try
		json.parse( json_str )
	Catch ex$
		Return
	EndTry
	verify( False, "    should throw error" )
EndFunction

Function test_extra_close()
	Print "*** test_extra_close"
	Local json_str$ = LoadString( test_dir + "/fails/8.json" )
	Try
		json.parse( json_str )
	Catch ex$
		Return
	EndTry
	verify( False, "    should throw error" )
EndFunction

Function test_extra_comma_after_value()
	Print "*** test_extra_comma_after_value"
	Local json_str$ = LoadString( test_dir + "/fails/9.json" )
	Try
		json.parse( json_str )
	Catch ex$
		Return
	EndTry
	verify( False, "    should throw error" )
EndFunction

Function test_extra_value_after_close_with_misplaced_quotes()
	Print "*** test_extra_value_after_close_with_misplaced_quotes"
	Local json_str$ = LoadString( test_dir + "/fails/10.json" )
	Try
		json.parse( json_str )
	Catch ex$
		Return
	EndTry
	verify( False, "    should throw error" )
EndFunction

Function test_illegal_expression_addition()
	Print "*** test_illegal_expression_addition"
	Local json_str$ = LoadString( test_dir + "/fails/11.json" )
	Try
		json.parse( json_str )
	Catch ex$
		Return
	EndTry
	verify( False, "    should throw error" )
EndFunction

Function test_illegal_invocation_of_alert()
	Print "*** test_illegal_invocation_of_alert"
	Local json_str$ = LoadString( test_dir + "/fails/12.json" )
	Try
		json.parse( json_str )
	Catch ex$
		Return
	EndTry
	verify( False, "    should throw error" )
EndFunction

Function test_numbers_cannot_have_leading_zeroes()
	Print "*** test_numbers_cannot_have_leading_zeroes"
	Local json_str$ = LoadString( test_dir + "/fails/13.json" )
	Try
		json.parse( json_str )
	Catch ex$
		Return
	EndTry
	verify( False, "    should throw error" )
EndFunction

Function test_numbers_cannot_be_hex()
	Print "*** test_numbers_cannot_be_hex"
	Local json_str$ = LoadString( test_dir + "/fails/14.json" )
	Try
		json.parse( json_str )
	Catch ex$
		Return
	EndTry
	verify( False, "    should throw error" )
EndFunction

Function test_illegal_backslash_escape_null()
	Print "*** test_illegal_backslash_escape_null"
	Local json_str$ = LoadString( test_dir + "/fails/15.json" )
	Try
		json.parse( json_str )
	Catch ex$
		Return
	EndTry
	verify( False, "    should throw error" )
EndFunction

Function test_unquoted_text()
	Print "*** test_unquoted_text"
	Local json_str$ = LoadString( test_dir + "/fails/16.json" )
	Try
		json.parse( json_str )
	Catch ex$
		Return
	EndTry
	verify( False, "    should throw error" )
EndFunction

Function test_illegal_backslash_escape_sequence()
	Print "*** test_illegal_backslash_escape_sequence"
	Local json_str$ = LoadString( test_dir + "/fails/17.json" )
	Try
		json.parse( json_str )
	Catch ex$
		Return
	EndTry
	verify( False, "    should throw error" )
EndFunction

Function test_missing_colon()
	Print "*** test_missing_colon"
	Local json_str$ = LoadString( test_dir + "/fails/19.json" )
	Try
		json.parse( json_str )
	Catch ex$
		Return
	EndTry
	verify( False, "    should throw error" )
EndFunction

Function test_double_colon()
	Print "*** test_double_colon"
	Local json_str$ = LoadString( test_dir + "/fails/20.json" )
	Try
		json.parse( json_str )
	Catch ex$
		Return
	EndTry
	verify( False, "    should throw error" )
EndFunction

Function test_comma_instead_of_colon()
	Print "*** test_comma_instead_of_colon"
	Local json_str$ = LoadString( test_dir + "/fails/21.json" )
	Try
		json.parse( json_str )
	Catch ex$
		Return
	EndTry
	verify( False, "    should throw error" )
EndFunction

Function test_colon_instead_of_comma()
	Print "*** test_colon_instead_of_comma"
	Local json_str$ = LoadString( test_dir + "/fails/22.json" )
	Try
		json.parse( json_str )
	Catch ex$
		Return
	EndTry
	verify( False, "    should throw error" )
EndFunction

Function test_bad_raw_value()
	Print "*** test_bad_raw_value"
	Local json_str$ = LoadString( test_dir + "/fails/23.json" )
	Try
		json.parse( json_str )
	Catch ex$
		Return
	EndTry
	verify( False, "    should throw error" )
EndFunction

Function test_single_quotes()
	Print "*** test_single_quotes"
	Local json_str$ = LoadString( test_dir + "/fails/24.json" )
	Try
		json.parse( json_str )
	Catch ex$
		Return
	EndTry
	verify( False, "    should throw error" )
EndFunction

Function test_tab_character_in_string()
	Print "*** test_tab_character_in_string"
	Local json_str$ = LoadString( test_dir + "/fails/25.json" )
	Try
		json.parse( json_str )
	Catch ex$
		Return
	EndTry
	verify( False, "    should throw error" )
EndFunction

Function test_tab_character_in_string_2()
	Print "*** test_tab_character_in_string_2"
	Local json_str$ = LoadString( test_dir + "/fails/26.json" )
	Try
		json.parse( json_str )
	Catch ex$
		Return
	EndTry
	verify( False, "    should throw error" )
EndFunction

Function test_line_break_in_string()
	Print "*** test_line_break_in_string"
	Local json_str$ = LoadString( test_dir + "/fails/27.json" )
	Try
		json.parse( json_str )
	Catch ex$
		Return
	EndTry
	verify( False, "    should throw error" )
EndFunction

Function test_line_break_in_string_in_array()
	Print "*** test_line_break_in_string_in_array"
	Local json_str$ = LoadString( test_dir + "/fails/28.json" )
	Try
		json.parse( json_str )
	Catch ex$
		Return
	EndTry
	verify( False, "    should throw error" )
EndFunction

Function test_0e()
	Print "*** test_0e"
	Local json_str$ = LoadString( test_dir + "/fails/29.json" )
	Try
		json.parse( json_str )
	Catch ex$
		Return
	EndTry
	verify( False, "    should throw error" )
EndFunction

Function test_0e_()
	Print "*** test_0e_"
	Local json_str$ = LoadString( test_dir + "/fails/30.json" )
	Try
		json.parse( json_str )
	Catch ex$
		Return
	EndTry
	verify( False, "    should throw error" )
EndFunction

Function test_0e__1()
	Print "*** test_0e__1"
	Local json_str$ = LoadString( test_dir + "/fails/31.json" )
	Try
		json.parse( json_str )
	Catch ex$
		Return
	EndTry
	verify( False, "    should throw error" )
EndFunction

Function test_comma_instead_of_closing_brace()
	Print "*** test_comma_instead_of_closing_brace"
	Local json_str$ = LoadString( test_dir + "/fails/32.json" )
	Try
		json.parse( json_str )
	Catch ex$
		Return
	EndTry
	verify( False, "    should throw error" )
EndFunction

Function test_bracket_mismatch()
	Print "*** test_bracket_mismatch"
	Local json_str$ = LoadString( test_dir + "/fails/33.json" )
	Try
		json.parse( json_str )
	Catch ex$
		Return
	EndTry
	verify( False, "    should throw error" )
EndFunction

Function test_extra_brace()
	Print "*** test_extra_brace"
	Local json_str$ = LoadString( test_dir + "/fails/34.json" )
	Try
		json.parse( json_str )
	Catch ex$
		Return
	EndTry
	verify( False, "    should throw error" )
EndFunction

Function test_pass_1()
	Print "*** test_pass_1"
	Local json_str$ = LoadString( test_dir + "/passes/1.json" )
	json.parse( json_str )
EndFunction

Function test_pass_2()
	Print "*** test_pass_2"
	Local json_str$ = LoadString( test_dir + "/passes/2.json" )
	json.parse( json_str )
EndFunction

Function test_pass_3()
	Print "*** test_pass_3"
	Local json_str$ = LoadString( test_dir + "/passes/3.json" )
	json.parse( json_str )
EndFunction



Type type_1_simple
	Field in1:Int
	Field st1:String
	Field st2:String
EndType

Type type_2_complex
	Field by:Byte
	Field sh:Short
	Field in:Int
	Field lo:Long
	Field fl:Float
	Field do:Double
	Field t1:type_1_simple
	Field byArr:Byte[]
	Field stArr:String[]
EndType

Function test_map_object_to_tvalue()
	Print "*** test_map_object_to_tvalue"
	Local obj:type_1_simple = New type_1_simple
	obj.in1 = 75
	obj.st1 = "stri~qng1~q"
	obj.st2 = "string2"
	Local obj2:type_2_complex = New type_2_complex
	obj2.by = 128
	obj2.sh = 1280
	obj2.in = 1457428982
	obj2.lo = -2038719820
	obj2.fl = 3848.5
	obj2.do = 2.9999994999
	obj2.t1 = obj
	obj2.byArr = [ 24:Byte, 1:Byte, 99:Byte ]
	obj2.stArr = [ "s1", "~n", "~t", "\" ]
	Local json_str$ = json.stringify( obj2 )
	Local test_str$ = "{~qby~q:128,~qbyArr~q:[24,1,99],~qdo~q:3,~qfl~q:3848.5,~qin~q:1457428982,~qlo~q:-2038719820,~qsh~q:1280,~qstArr~q:[~qs1~q,~q\n~q,~q\t~q,~q\\~q],~qt1~q:{~qin1~q:75,~qst1~q:~qstri\~qng1\~q~q,~qst2~q:~qstring2~q}}"
	verify( json_str = test_str, test_str+"~n"+json_str )
EndFunction

Function test_map_tvalue_to_object()
	Print "*** test_map_tvalue_to_object"
	Local obj2:type_2_complex
	Local json_str$ = "{~qby~q:128,~qbyArr~q:[24,1,99],~qdo~q:3,~qfl~q:3848.5,~qin~q:1457428982,~qlo~q:-2038719820,~qsh~q:1280,~qstArr~q:[~qs1~q,~q\n~q,~q\t~q,~q\\~q],~qt1~q:{~qin1~q:75,~qst1~q:~qstri\~qng1\~q~q,~qst2~q:~qstring2~q}}"
	obj2 = type_2_complex( json.parse( json_str, "type_2_complex" ))
	Local roundtrip_str$ = json.stringify( obj2 )
	verify( json_str = roundtrip_str, "   ORIGINAL: "+json_str+"~n   ROUNDTRIP: "+roundtrip_str )
EndFunction

Function test_pass_starfarer()
	Print "*** test_pass_starfarer"
	Local json_str$ = LoadString( test_dir + "/passes/starfarer.json" )
	Local decoded:Object = json.parse( json_str )
	verify( ..
		TObject(decoded).fields.ValueForKey( "enum1" ).ToString() = "ENUM_VALUE", ..
		"ENUM_VALUE <> "+TObject(decoded).fields.ValueForKey( "enum1" ).ToString()  )
EndFunction

Function test_encode_TList()
	Print "*** test_encode_TList"
	Local list:TList = CreateList()
	list.AddLast( "string1" )
	list.AddLast( "string2" )
	list.AddLast( "string3" )
	Local json_str$ = json.stringify( list )
	Local test_str$ = "[~qstring1~q,~qstring2~q,~qstring3~q]"
	verify( test_str = json_str, test_str+"~n"+json_str )
EndFunction

Function test_encode_TMap()
	Print "*** test_encode_TMap"
	Local map:TMap = CreateMap()
	map.Insert( "key1", "string1" )
	map.Insert( "key2", "string2" )
	map.Insert( "key3", "string3" )
	Local json_str$ = json.stringify( map )
	Local test_str$ = "{~qkey1~q:~qstring1~q,~qkey2~q:~qstring2~q,~qkey3~q:~qstring3~q}"
	verify( test_str = json_str, test_str+"~n"+json_str )
EndFunction

Function test_tvalue_transformation_search()
	Print "*** test_tvalue_transformation_search"
	Local json_str$ = LoadString( test_dir + "/passes/xf1_in.json" )
	Local val:TValue = TValue( json.parse( json_str ))
	Local xf:TValue_Transformation = TValue_Transformation.Create( ..
		":string", json.XJ_DELETE, Null, Null )
	Local results:TList = xf.Search( val )
	Local json_out_expected$ = LoadString( test_dir + "/passes/xf1_out.json" )
	Local json_out_actual$ = json.stringify( results )
	verify( json_out_expected = json_out_actual, "   EXPECTED:~n"+json_out_expected+"~n   ACTUAL:~n"+json_out_actual )
EndFunction

Function test_tvalue_transformation_conditional_delete()
rem
	Print "*** test_tvalue_transformation_conditional_delete"
	Local json_str$ = LoadString( test_dir + "/passes/xf2_in.json" )
	json.add_transform( "parse", ":object/$ALPHA:string", json.XJ_DELETE )
	json.add_transform( "parse", "@4:number", json.XJ_DELETE )
	json.add_transform( "parse", "@5:boolean", json.XJ_DELETE )
	json.add_transform( "parse", ":object/:boolean", json.XJ_DELETE,, __TBoolean_NOT )
	Local val:TValue = TValue( json.parse( json_str,, "parse" ))
	verify( TObject(TArray( val ).elements.ValueAtIndex(8)).fields.Contains("ALPHA") = False, "value should not be found" )
	json.clear_transforms()
endrem
EndFunction
Function __TBoolean_NOT%( val:TValue )
	If TBoolean(val) Then Return (Not TBoolean(val).value) ..
	Else Return False
EndFunction

Function test_pass_sf_1()
	Print "*** test_pass_sf_1"
	Local json_str$ = LoadString( test_dir + "/passes/sfw1.json" )
	json.parse( json_str )
EndFunction

Function test_pass_sf_2()
	Print "*** test_pass_sf_2"
	Local json_str$ = LoadString( test_dir + "/passes/sfw2.json" )
	json.parse( json_str )
EndFunction


Type type_3_containers
	Field str$
	Field arr%[]
	Field obj:type_3_containers
EndType

Function test_encode_empty_objects_instead_of_nulls()
	Print "*** test_encode_empty_objects_instead_of_nulls"
	Local obj:type_3_containers = New type_3_containers
	Local json_str$
	Local test_str$
	json.empty_container_as_null = False
	json_str = json.stringify( obj )
	test_str = "{~qarr~q:[],~qobj~q:{},~qstr~q:~q~q}"
	verify( test_str = json_str, "   EXPECTED:~n"+test_str+"~n   ACTUAL:~n"+json_str )
	json.empty_container_as_null = True
	json_str = json.stringify( obj )
	test_str = "{~qarr~q:null,~qobj~q:null,~qstr~q:null}"
	verify( test_str = json_str, "   EXPECTED:~n"+test_str+"~n   ACTUAL:~n"+json_str )
EndFunction

Function bug1()
	'Print "*** reported bug 1"
	'Local json_str$ = LoadString( test_dir + "/passes/bug1.json" )
	'Local val:Object = json.parse( json_str )
	'Local check:TNumber = TNumber(TObject(TObject(val).Get("exigencyEngine")).Get("contrailMaxSpeedMult"))
	'Local expected:Double = 0.1:Double
	'verify( expected = check.value, "  EXPECTED: "+expected+"   ACTUAL: "+check.value )
EndFunction


'/////////////////////////////////////////////////////////////////

Function calc_hash%(s:String)
	Local hc% = 0
	Local l% = Len(s)
	For Local i% = 0 To l
		hc = hc * 131 + Asc(Right(s,l-i))
	Next
	hc = Abs(hc)
	Return hc
EndFunction

Function verify( boolean_expression%, error_str$="" )
	If Not boolean_expression
		Throw "  TEST FAILED~n"+error_str
	EndIf
EndFunction

Function run_test( test_function() )
	Try
		test_function()
	Catch ex$
		Print ex
	EndTry
EndFunction

Function Main()
	run_test( test_object )
	run_test( test_escaped_backslash )
	run_test( test_escaped_chars )
	run_test( test_escaped_newline )
	run_test( test_string_with_escaped_line_break )
	run_test( test_string_with_line_break )
	run_test( test_string_literal )
	run_test( test_number_literal )
	run_test( test_number_literal2 )
	run_test( test_number_literal3 )
	run_test( test_null_literal )
	run_test( test_boolean_literal )
	run_test( test_unclosed_array )
	'run_test( test_unquotedkey_keys_must_be_quoted ) 'I explicitly allow unquoted strings as long as they use [_a-zA-Z0-9]+
	'run_test( test_extra_comma ) 'I explicitly choose to accept: a single trailing comma (ARRAY)
	run_test( test_double_extra_comma )
	run_test( test_missing_value )
	run_test( test_comma_after_the_close )
	run_test( test_extra_close )
	'run_test( test_extra_comma_after_value ) 'I explicitly choose to accept: a single trailing comma (OBJECT)
	run_test( test_extra_value_after_close_with_misplaced_quotes )
	run_test( test_illegal_expression_addition )
	'run_test( test_illegal_invocation_of_alert ) 'Doesn't apply here; not Javascript
	'run_test( test_numbers_cannot_have_leading_zeroes ) 'I accept leading zeroes because Blitzmax does
	run_test( test_numbers_cannot_be_hex )
	run_test( test_illegal_backslash_escape_null )
	run_test( test_unquoted_text )
	run_test( test_illegal_backslash_escape_sequence )
	run_test( test_missing_colon )
	run_test( test_double_colon )
	run_test( test_comma_instead_of_colon )
	run_test( test_colon_instead_of_comma )
	'run_test( test_bad_raw_value ) 'Bad Raw Values are indistinguishable from unquoted strings
	run_test( test_single_quotes )
	run_test( test_tab_character_in_string )
	run_test( test_tab_character_in_string_2 )
	run_test( test_line_break_in_string )
	run_test( test_line_break_in_string_in_array )
	run_test( test_0e )
	run_test( test_0e_ )
	run_test( test_0e__1 )
	run_test( test_comma_instead_of_closing_brace )
	run_test( test_bracket_mismatch )
	run_test( test_extra_brace )
	run_test( test_pass_1 )
	run_test( test_pass_2 )
	run_test( test_pass_3 )
	run_test( test_map_object_to_tvalue )
	run_test( test_map_tvalue_to_object )
	run_test( test_pass_starfarer )
	run_test( test_encode_TList )
	run_test( test_encode_TMap )
	run_test( test_tvalue_transformation_search )
	run_test( test_tvalue_transformation_conditional_delete )
	run_test( test_pass_sf_1 )
	run_test( test_pass_sf_2 )
	run_test( test_encode_empty_objects_instead_of_nulls )
	run_test( bug1 )
EndFunction

Main()

