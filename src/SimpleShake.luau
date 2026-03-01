--!strict
-- @theonlyflare
-- SimpleShake V1.0

--[=[
	@class SimpleShake
	@client
	
	A lightweight, highly optimized camera shake module that uses pre-set profiles 
	to deliver massive game feel with zero complex math required from the developer. 
	Has the ability to make custom shake profiles to match your needs.
]=]

-- [[ SERVICES & MODULES ]] --
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local Types = require(script:WaitForChild("Types"))
local Presets = require(script:WaitForChild("Presets"))

-- [[ CONSTANTS ]] --
local RENDER_STEP_NAME = "SimpleShake_Update"

-- [[ STATE ]] --
local SimpleShake = {}
local ActiveShakes: { [string]: Types.ShakeInstance } = {}
local isRunning = false

-- [[ PRIVATE FUNCTIONS ]] --

--[=[
	The core RenderStepped loop. Accumulates all active shake offsets 
	and applies them to the camera. Automatically unbinds when empty.
	@private
]=]
local function OnRenderStep()
	local camera = workspace.CurrentCamera
	if not camera then return end

	local currentTime = os.clock()
	local totalOffset = CFrame.new()
	local activeCount = 0

	for id, shake in pairs(ActiveShakes) do
		if shake.IsPlaying then
			activeCount += 1
			totalOffset = totalOffset * shake:_Update(currentTime)
		else
			ActiveShakes[id] = nil
		end
	end

	camera.CFrame = camera.CFrame * totalOffset

	if activeCount == 0 then
		RunService:UnbindFromRenderStep(RENDER_STEP_NAME)
		isRunning = false
	end
end

-- [[ PUBLIC METHODS ]] --

--[=[
	Starts a new camera shake. You can pass a Preset name or a completely custom Profile.
	
	@param profile Types.PresetName | Types.ShakeProfile -- The name of the preset OR a custom dictionary.
	@param overrides table? -- Optional dictionary to override properties.
	@return ShakeInstance
]=]
function SimpleShake.Play(profile: Types.PresetName | Types.ShakeProfile, overrides: any?): Types.ShakeInstance
	local baseProfile: Types.ShakeProfile

	if type(profile) == "string" then -- Existing Preset 
		if Presets[profile] then
			baseProfile = table.clone(Presets[profile])
		else
			warn(`[SimpleShake] Preset '{profile}' not found. Falling back to default.`)
			baseProfile = { Amplitude = 1, Frequency = 10, Duration = 1, FadeIn = 0.1, FadeOut = 0.5 }
		end
	elseif type(profile) == "table" then -- Custom Profile 
		baseProfile = {
			Amplitude = profile.Amplitude or 1,
			Frequency = profile.Frequency or 10,
			Duration = profile.Duration or 1,
			FadeIn = profile.FadeIn or 0.1,
			FadeOut = profile.FadeOut or 0.5,
		}
	else
		warn(`[SimpleShake] Invalid type given. Falling back to default.`)
		baseProfile = { Amplitude = 1, Frequency = 10, Duration = 1, FadeIn = 0.1, FadeOut = 0.5 }
	end

	-- Apply developer overrides [ Used to tweak singular settings. E.g. FadeOut = 0.5, Duration = 2, etc.] 
	if overrides then
		for k, v in pairs(overrides) do
			baseProfile[k] = v
		end
	end

	--> Setup Instance
	local shakeInstance = {} :: Types.ShakeInstance
	shakeInstance.Id = HttpService:GenerateGUID(false)
	shakeInstance.Profile = baseProfile
	shakeInstance.StartTime = os.clock()
	shakeInstance.IsPlaying = true
	shakeInstance.IsFadingOut = false
	shakeInstance.Seed = math.random() * 1000

	--[=[
		Initiates the fade-out sequence for this specific shake.
		@param fadeOutOverride number? -- Optionally override the profile's default fade out time.
	]=]
	function shakeInstance:Stop(fadeOutOverride: number?)
		if not self.IsPlaying or self.IsFadingOut then return end

		self.IsFadingOut = true
		self.FadeOutDuration = fadeOutOverride or self.Profile.FadeOut
		self.FadeOutStartTime = os.clock()
	end

	--[=[
		Calculates the current CFrame offset for this frame using Perlin Noise.
		@private
	]=]
	function shakeInstance:_Update(currentTime: number): CFrame
		local timeAlive = currentTime - self.StartTime

		-- Trigger natural fade out if duration is reached
		if not self.IsFadingOut and timeAlive > self.Profile.Duration then
			self:Stop()
		end

		-- Calculate Fade Multiplier
		local fadeMultiplier = 1

		if self.IsFadingOut then
			local fadeTime = currentTime - (self.FadeOutStartTime or currentTime)
			local duration = self.FadeOutDuration or self.Profile.FadeOut
			fadeMultiplier = 1 - (fadeTime / duration)

			if fadeMultiplier <= 0 then
				self.IsPlaying = false
				return CFrame.new()
			end
		elseif timeAlive < self.Profile.FadeIn then
			fadeMultiplier = timeAlive / self.Profile.FadeIn
		end

		-- The Perlin Noise Math Engine
		local currentAmplitude = self.Profile.Amplitude * fadeMultiplier
		local noiseTime = timeAlive * self.Profile.Frequency

		-- We offset the Y and Z seeds so they generate unique noise patterns
		local noiseX = math.noise(noiseTime, self.Seed, 0)
		local noiseY = math.noise(noiseTime, self.Seed + 10, 0)
		local noiseZ = math.noise(noiseTime, self.Seed + 20, 0)

		-- Combine into a CFrame. Z represents a slight camera tilt/roll for extra impact.
		return CFrame.Angles(
			math.rad(noiseX * currentAmplitude), 
			math.rad(noiseY * currentAmplitude), 
			math.rad(noiseZ * currentAmplitude * 0.5) 
		)
	end

	-- Register and start loop
	ActiveShakes[shakeInstance.Id] = shakeInstance

	if not isRunning then
		isRunning = true
		RunService:BindToRenderStep(RENDER_STEP_NAME, Enum.RenderPriority.Camera.Value + 1, OnRenderStep)
	end

	return shakeInstance
end

--[=[
	Immediately initiates the fade-out sequence for all active shakes.
]=]
function SimpleShake.StopAll()
	for _, shake in pairs(ActiveShakes) do
		shake:Stop()
	end
end

--> Return
return SimpleShake
