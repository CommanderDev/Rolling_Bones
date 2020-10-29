-- @Author: Spynaz
-- Interpolation
-- Updated: 6/13/17

-- Methods
	--[[
		Name: Lerp.Approach()
		Parameters:	Type						Name			Desc
					----						----			----
				 	CFrame/Vector3/Color3		Start			Starting coordinate frame
					CFrame/Vector3/Color3		Finish			Finishing coordinate frame
					string						Style			The style of the interpolation
					int							Duration		How long the interpolation runs
					bool						NewThread		Whether or not to run the interpolation on a new thread
					function					Func			The function that will be called each position update (the current position will be passed as a parameter)
		
		Description: Interpolates between two CFrame, Vector3, or Color3 values
		
		
		Name: Lerp.ApproachValue()
		Parameters:	Type		Name			Desc
					----		----			----
				 	number		Start			Starting number value
					number		Finish			Finishing number value
					string		Style			The style of the interpolation
					int			Duration		How long the interpolation runs
					bool		NewThread		Whether or not to run the interpolation on a new thread
					function	Func			The function that will be called each position update (the current position will be passed as a parameter)
		
		Description: Interpolates between two number values
		
		
		Name: Lerp:Stop()
		Parameters:	void
		Description: Stops the animation
--]]		
					
local RunService = game:GetService("RunService")

local Lerp 		= {}
Lerp.__index 	= Lerp

local Heartbeat 		= RunService.Heartbeat
local RenderStepped		= RunService.RenderStepped
local Stepped			= RunService.Stepped

-- Types of interpolations
local LerpStyles = {
	-- Quadratic interpolation
	Quad = function(t, b, c, d)
		t = t/(d/2)
		
		if (t < 1) then return c/2*t*t + b end
		t = t-1
		return ((-c / 2) * (t * (t - 2) - 1)) + b
	end,
	
	-- Linear interpolation
	Linear = function(t, b, c, d)
		if c == 0 then
			return b - ((b / d) * t)
		else
		 	return (((c - b) * t) / d) + b 
		end
	end,
	
	-- Consine interpolation
	Cosine = function(t, b, c, d)
		if c == 0 then
			return b - (((math.cos(math.rad(180 - ((180 / d) * t))) + 1) / 2) * b)
		else
			return (((math.cos(math.rad(180 - ((180 / d) * t))) + 1) / 2) * (c - b)) + b
		end
	end 
}

-- Interplates between two cframe
function Lerp.Approach(Start, Finish, Style, Duration, NewThread, Func)

	-- Create a new animation track
	local self 				= {}
	self.Finish				= Finish
	self.Duration			= Duration
	self.StopAnim			= false
	self.Complete			= false
	
	setmetatable(self, Lerp)
	
	-- Tween between two cframe
	local function Tween()
		local now = tick()
		local d = 0
		local ratio = 0
		
		while (d < self.Duration) do
			if self.StopAnim then break end
			
			ratio = LerpStyles[Style](d, 0, 1, self.Duration)
			Func(Start:lerp(self.Finish, ratio), self)
				
			Stepped:wait()
			d = (tick() - now)
		end
		
		if not self.StopAnim then
			Func(Start:lerp(self.Finish, ratio), self)
		end
		
		self.Complete = true
	end
	-- Make sure the duration is greater than 0
	if self.Duration > 0 then
		if NewThread then spawn(Tween) else Tween() end
		
		
	-- If the duration is less than 0, instantly complete the interpolation
	else
		Func(Start:lerp(self.Finish, 1), self)
		self.Complete = true
	end
	
	return self
end

-- Interpolates between two number values
function Lerp.ApproachValue(Start, Finish, Style, Duration, NewThread, Func)
	
	-- Create a new animation track
	local self 				= {}
	self.Finish				= Finish
	self.Duration			= Duration
	self.StopAnim			= false
	self.Complete			= false
	
	setmetatable(self, Lerp)
	
	-- Tween between two numbers
	local function Tween()
		local now = tick()
		local d = 0
		
		while (d < self.Duration) do
			if self.StopAnim then break end
			
			Func(LerpStyles[Style](d, Start, self.Finish, self.Duration), self)
			
			Stepped:wait()
			d = (tick() - now)
		end
		
		if not self.StopAnim then
			Func(self.Finish, self)
		end
		
		self.Complete = true
	end
	
	-- Make sure the duration is greater than 0
	if self.Duration > 0 then
		if NewThread then spawn(Tween) else Tween() end
		
	-- If the duration is less than 0, instantly complete the interpolation
	else
		Func(self.Finish, self)
		self.Complete = true
	end
	
	return self
end

-- Stops the animation
function Lerp:Stop()
	self.StopAnim = true
end

return Lerp