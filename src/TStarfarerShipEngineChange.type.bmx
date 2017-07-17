'-----------------------

Type TStarfarerShipEngineChange Extends TStarfarerShipEngine
	'Field location#[]
	'Field length#
	'Field width#
	'Field angle#
	'Field style$
	'Field styleId$
	'Field styleSpec:TStarfarerCustomEngineStyleSpec
	'Field contrailSize#
	Rem
	  The following known values, unlikely to be set by a datafile,
	    can be used to determine if they have been set by reading in a JSON document
	  This is useful because in the context of a skin,
	    it tells us which values to inherit from the base hull.
	EndRem
	Const __location#[]   = Null
	Const __length#       = FLOAT_MAX
	Const __width#        = FLOAT_MAX
	Const __angle#        = FLOAT_MAX
	Const __style$        = Null
	Const __styleId$      = Null
	Const __styleSpec:TStarfarerCustomEngineStyleSpec = Null
	Const __contrailSize# = FLOAT_MAX
	
	Method New()
		location     = __location
		length       = __length
		width        = __width
		angle        = __angle
		style        = __style
		styleId      = __styleId
		styleSpec    = __styleSpec
		contrailSize = __contrailSize
	End Method

EndType

Function predicate_omit_if_equals_FLOAT_MAX%( val:TValue, root:TValue )
	Return TNumber (val) And TNumber(val).value = FLOAT_MAX
EndFunction