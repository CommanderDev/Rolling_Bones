local defaultParameters = {
	repeats = math.huge
	
}
local Main = require(game.ReplicatedStorage.CloudFrameShared.Main)

local Class = Main.loadLibrary("Class")
local Cryo = Main.loadLibrary("Cryo")

local RunService = game:GetService("RunService")

local Timer = Class.new()

Timer.timerIdentifiers = {}

local requiredParameters = {
	length = "number";
	callback = "function";
}


function Timer.new(parameters)
	for parameter,type in pairs(requiredParameters) do
		local paramType = typeof(parameters[parameter])
		if paramType~=type then
			error("invalid parameter type: "..parameter.." expected "..type..", got "..paramType)
		end
	end
	parameters = Cryo.Dictionary.join(defaultParameters, parameters)
	local self = setmetatable(parameters, Timer)
	self.startTime = os.clock()
	self.heartbeatConnection = nil
	self.currentRepeat = 0
	self.timeLeft = self.length
	self.started = false 
	if self.uniqueIdentifier then 
		Timer.timerIdentifiers[self.uniqueIdentifier] = self
	end
	return self
end

function Timer:startTimer()
	if not self.started then 
		self.startTime = os.clock()
		self.timeLeft = self.length
		self.started = true
	end
	self.heartbeatConnection = RunService.Heartbeat:Connect(function(deltaTime)
		self.timeElasped = os.clock() - self.startTime
		self.timeLeft = math.round(self.length - self.timeElasped)

		if self.timeElasped >= self.length then 
			self.timeLeft = 0
			self:initilize()
			self.startTime = os.clock()
			self.currentRepeat += 1
			if self.currentRepeat >= self.repeats then 
				self:stopTimer()
			end
		end
	end)
	if self.subroutines then 
		for index, timer in next, self.subroutines do
			timer.mainRoutine = self
			timer:startTimer()
		end
	end
end

function Timer:stopTimer()
	if self.heartbeatConnection then 
		self.heartbeatConnection:Disconnect()
	end
	if self.subroutines then 
		for index, timer in next, self.subroutines do 
			timer:stopTimer()
		end
	end
end

function Timer:resetTimer()
	self:stopTimer()
	self.started = false
end

function Timer:initilize()
	self.callback(self.mainRoutine, self)
end

function Timer.getTimer(uniqueIdentifier): table
	print("Getting ",uniqueIdentifier, " Timer")
	return Timer.timerIdentifiers[uniqueIdentifier]	
end

return Timer
