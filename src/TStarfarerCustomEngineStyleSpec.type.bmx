Type TStarfarerCustomEngineStyleSpec

	Field type_$
	Field mode$
	Field engineColor%[4]
	Field engineCampaignColor%[4]
	Field contrailParticleSizeMult#
	Field contrailParticleFinalSizeMult#
	Field contrailParticleDuration#
	Field contrailMaxSpeedMult#
	Field contrailAngularVelocityMult#
	Field contrailColor%[4]
	Field contrailCampaignColor%[4]
	
	Method New()
		type_ = "SMOKE"
		engineColor = [ 0, 0, 0, 0 ]
		engineCampaignColor = [ 0, 0, 0, 0 ]
		contrailColor = [ 0, 0, 0, 0 ]
		contrailCampaignColor = [ 0, 0, 0, 0 ]
	EndMethod

	Method Clone:TStarfarerCustomEngineStyleSpec()
		Local copy:TStarfarerCustomEngineStyleSpec = New TStarfarerCustomEngineStyleSpec
		copy.type_ = type_
		copy.mode = mode
		copy.engineColor = engineColor[..]
		copy.engineCampaignColor = engineCampaignColor[..]
		copy.contrailColor = contrailColor[..]
		copy.contrailParticleSizeMult = contrailParticleSizeMult
		copy.contrailParticleFinalSizeMult = contrailParticleFinalSizeMult
		copy.contrailParticleDuration = contrailParticleDuration
		copy.contrailMaxSpeedMult = contrailMaxSpeedMult
		copy.contrailAngularVelocityMult = contrailAngularVelocityMult
		Return copy
	EndMethod
End Type
