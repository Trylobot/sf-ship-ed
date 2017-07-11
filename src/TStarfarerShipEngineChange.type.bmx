'-----------------------

Type TStarfarerShipEngineChange Extends TStarfarerShipEngine
	'Field angle#
	'Field contrailSize#
	'Field length#
	'Field location#[]
	'Field style$
	'Field styleId$
	'Field styleSpec:TStarfarerCustomEngineStyleSpec
	'Field width#
	Rem
	  The following known values, unlikely to be set by a datafile,
	    can be used to determine if they have been set by reading in a JSON document
	  This is useful because in the context of a skin,
	    it tells us which values to inherit from the base hull.
	EndRem
	Const __angle#        = 10e308:Double
	Const __contrailSize# = 10e308:Double
	Const __length#       = 10e308:Double
	Const __location#[]   = Null
	Const __style$        = Null
	Const __styleId$      = Null
	Const __styleSpec:TStarfarerCustomEngineStyleSpec = Null
	Const __width#        = 10e308:Double
	
	Method New()
		angle        = __angle
		contrailSize = __contrailSize
		length       = __length
		location     = __location
		style        = __style
		styleId      = __styleId
		styleSpec    = __styleSpec
		width        = __width
	End Method

EndType

