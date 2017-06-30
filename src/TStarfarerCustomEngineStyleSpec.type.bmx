Type TStarfarerCustomEngineStyleSpec

	Field engineColor%[4]
	Field contrailParticleSizeMult#
	Field contrailParticleDuration#
	Field contrailMaxSpeedMult#
	Field contrailAngularVelocityMult#
	Field contrailColor%[4]
	Field contrailCampaignColor%[4]
	Field type_$
	
	Method New()
		type_ = "SMOKE"
		engineColor = [ 0, 0, 0, 0 ]
		contrailColor = [ 0, 0, 0, 0 ]
	EndMethod

	Method Clone:TStarfarerCustomEngineStyleSpec()
		Local copy:TStarfarerCustomEngineStyleSpec = New TStarfarerCustomEngineStyleSpec
		copy.type_ = type_
		copy.engineColor = engineColor[..]
		copy.contrailColor = contrailColor[..]
		copy.contrailParticleSizeMult = contrailParticleSizeMult
		copy.contrailParticleDuration = contrailParticleDuration
		copy.contrailMaxSpeedMult = contrailMaxSpeedMult
		copy.contrailAngularVelocityMult = contrailAngularVelocityMult
		Return copy
	EndMethod
End Type
