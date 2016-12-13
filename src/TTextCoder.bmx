'-----------------------------------------------------
Rem
	Code string into given code form and stream white in to url(file). Or decode url(file) in to string.
End Rem

'-----------------------------------------------------
Rem
	bbdoc:
	#LoadTextAs loads LATIN1, UTF8 or UTF16 text from @url.
	LATIN1 = 1
	UTF8 without BOM = 2
	UTF8 with = 3
	UTF16BE = 4
	UTF16LE = 5
	
End Rem
Function LoadTextAs:String ( url:Object, code% = 0)
	If code = 0 Then code = 1 'TODO add an auto detect mode.
	If code = 1 Then Return LoadString (url) 'LATIN1	
	Local buf:Byte[] = LoadByteArray( url )
	Local sbuf:Short[1]
	Local a% = 0
	Local j% = 0
	'skip the file head(BOM)
	If code = 3 Then a = 3
	If code > 3 Then a = 2
	'Bitwise works.
	For Local i% = a Until buf.LENGTH
		Local B:Short
		Local C:Short = buf[i]
		Select code
		Case 2, 3
			If C < 128
				B = C
			Else If C < 224
				i :+ 1
				Local D:Short = buf[i]
				B = (C - 192) Shl 6 + (D - 128)
			Else If C < 240
				i :+ 1
				Local D:Short = buf[i]
				i :+ 1
				Local e:Short = buf[i]
				B = (C - 224) Shl 12 + (D - 128) Shl 6 + (e - 128)
			EndIf
		Case 4
			i :+ 1
			Local D:Byte = buf[i]
			B = D Shl 8 | C
		Case 5
			i :+ 1
			Local D:Byte = buf[i]
			B = D Shl 8 | C
		End Select
		sbuf[j] = B
		j :+ 1
		sbuf = sbuf[..(j + 1)]		
	Next		
	Return String.FromShorts(sbuf, sbuf.length )
End Function

Rem
	bbdoc:
	#SaveTextAs saves LATIN1, UTF8 or UTF16 text in @str to @url.
	LATIN1 = 1
	UTF8 without BOM = 2
	UTF8 with = 3
	UTF16BE = 4
	UTF16LE = 5
	
End Rem
Function SaveTextAs ( str$, url:Object , code% = 0)
	If Not str Then Return
	If code = 0 Then code = 1 'TODO add an auto detect mode.
	If code = 1
		SaveString ( str, url ) 'LATIN1
		Return			
	EndIf
	Local buf:Byte[]
	Local j% = -1
	'add the file head(BOM)
	If code = 3
		j = 2
		buf = [239:Byte, 187:Byte, 191:Byte]
	EndIf
	If code = 4
		j = 1
		buf = [255:Byte, 254:Byte]
	EndIf
	If code = 5
		j = 1
		buf = [254:Byte, 255:Byte]
	EndIf
	'Bitwise works.
	For Local i% = 0 Until str.length
		If code = 2 Or code = 3 'UTF8
			If str[i] & 63488 '& 11111000 00000000 check
			'CCCCDDDD DDEEEEEE > 1110CCCC 10DDDDDD 10EEEEEE
			buf = buf[..(j + 4)] 'add 3 more new byte
			buf[j + 1] = (str[i] Shr 12 | 224) '1st 1110CCCC
			buf[j + 2] = (str[i] Shr 6 & 63 | 128) '2nd 10DDDDDD
			buf[j + 3] = (str[i] & 63 | 128) '3rd 10EEEEEE
			j :+ 3
			Else If str[i] & 1920 '&00000111 10000000 check
			'00000CCC CCDDDDDD > 110CCCCC 10DDDDDD
			buf = buf[..(j + 3)] 'add 2 more new byte
			buf[j + 1] = (str[i] Shr 6 | 192) '1st 110CCCCC
			buf[j + 2] = (str[i] & 63 | 128) '2nd 10DDDDDD
			j :+ 2
			Else ' it should be 00000000 0CCCCCCC
			buf = buf[..(j + 2)] 'add 1 more new Byte
			buf[j + 1] = str[i] '0CCCCCCC
			j :+ 1
			EndIf
		EndIf
		If code = 4 'UTF16BE AAAAAAAA BBBBBBBB
			buf = buf[..(j + 3)] 'add 2 more new byte
			buf[j + 1] = str[i] Shr 8 'AAAAAAAA
			buf[j + 2] = str[i] 'BBBBBBBB
			j :+ 2
		EndIf
		If code = 5 'UTF16LE
			buf = buf[..(j + 3)] 'add 2 more new byte
			buf[j + 1] = str[i] 'BBBBBBBB
			buf[j + 2] = str[i] Shr 8 'AAAAAAAA
			j :+ 2
		EndIf
	Next
	For Local i% = 0 Until buf.length
	Next
	SaveByteArray(buf, url)
End Function
