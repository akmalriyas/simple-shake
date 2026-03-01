--!strict
-- @theonlyflare

-- SimpleShake/Types

export type ShakeProfile = {
	Amplitude: number?,
	Frequency: number?,
	Duration: number?,
	FadeIn: number?,
	FadeOut: number?,
}


export type PresetName = 
	"Explosion" | 
	"Footstep_Heavy" | 
	"Footstep_Light" | 
	"Melee_Hit" | 
	"Earthquake" | 
	"Heartbeat" | 
	"Recoil_Light" | 
	"Recoil_Heavy" | 
	"Vehicle_Rumble" | 
	"Landing"

export type ShakeInstance = {
	Id: string,
	Profile: ShakeProfile,
	StartTime: number,
	IsPlaying: boolean,
	IsFadingOut: boolean,
	FadeOutDuration: number?,
	FadeOutStartTime: number?,
	Seed: number,

	Stop: (self: ShakeInstance, fadeOutOverride: number?) -> (),
	_Update: (self: ShakeInstance, currentTime: number) -> CFrame
}

return {}
