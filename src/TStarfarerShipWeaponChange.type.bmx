
Type TStarfarerShipWeaponChange Extends TStarfarerShipWeapon
	'Field angle#
	'Field arc#
	'Field id$
	'Field locations#[]
	'Field position#[]
	'Field mount$	
	'Field size$
	'Field type_$
	Rem
	  The following known values, unlikely to be set by a datafile,
	    can be used to determine if they have been set by reading in a JSON document
	  This is useful because in the context of a skin,
	    it tells us which values to inherit from the base hull.
	EndRem
	Const __angle#       = FLOAT_MAX
	Const __arc#         = FLOAT_MAX
	Const __id$          = Null
	Const __locations#[] = Null
	Const __position#[]  = Null
	Const __mount$	     = Null
	Const __size$        = Null
	Const __type_$       = Null
	
	Method New()
		angle     = __angle
		arc       = __arc
		id        = __id
		locations = __locations
		position  = __position
		mount     = __mount
		size      = __size
		type_     = __type_
	End Method

End Type
