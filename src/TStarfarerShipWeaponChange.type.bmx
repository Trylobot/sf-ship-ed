
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

	Method Overlay:TStarfarerShipWeapon( base:TStarfarerShipWeapon )
		Local merged:TStarfarerShipWeapon = base.Clone()
		If angle <> __angle         Then merged.angle = angle
		If arc <> __arc             Then merged.arc = arc
		If locations <> __locations Then merged.locations = locations
		If position <> __position   Then merged.position = position
		If mount <> __mount         Then merged.mount = mount
		If size <> __size           Then merged.size = size
		If type_ <> __type_         Then merged.type_ = type_
		Return merged
	EndMethod

End Type
