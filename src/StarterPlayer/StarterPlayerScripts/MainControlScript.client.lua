local ContextActionService = game:GetService("ContextActionService")
local plr = game.Players.LocalPlayer
local chr = plr.Character or plr.CharacterAdded:Wait()
local hrp = chr:WaitForChild("HumanoidRootPart")
local BG = hrp:WaitForChild("BodyGyro")

local camera = game.Workspace.CurrentCamera

local JUMP_VELOCITY = Vector3.new(0, 100, 0)
local MOVE_SPEED = 20
local moveDir = Vector3.new(0,0,0)

plr.CharacterAdded:Connect(function(c)
	chr = c
	hrp = chr:WaitForChild("HumanoidRootPart")
	BG = hrp:WaitForChild("BodyGyro")
end)

local camera = workspace.CurrentCamera

local LEFT_KEYS = {
	Enum.KeyCode.A,
	Enum.KeyCode.Left,
	Enum.KeyCode.DPadLeft,

}
local RIGHT_KEYS = {
	Enum.KeyCode.D,
	Enum.KeyCode.Right,
	Enum.KeyCode.DPadRight,

}
local FORWARD_KEYS = {
	Enum.KeyCode.W,
	Enum.KeyCode.Up,
	Enum.KeyCode.DPadUp,
}
local BACKWARD_KEYS = {
	Enum.KeyCode.S,
	Enum.KeyCode.Down,
	Enum.KeyCode.DPadDown,
}
local JUMP_KEYS = {
	Enum.KeyCode.Space,
	Enum.KeyCode.ButtonA,
}



local r,l,f,b = false, false, false, false
local function onMove(actionName, inputState)
	if inputState == Enum.UserInputState.Begin then
		if actionName == "Right" then
			if not r then
				r = true
				moveDir = moveDir + Vector3.new(1,0,0)
			end
		elseif actionName == "Left" then
			if not l then
				l = true
				moveDir = moveDir + Vector3.new(-1,0,0)
			end
		elseif actionName == "Forward" then
			if not f then
				f = true
				moveDir = moveDir + Vector3.new(0,0,-1)
			end
		elseif actionName == "Backward" then
			if not b then
				b = true
				moveDir = moveDir + Vector3.new(0,0,1)
			end
		end
	elseif inputState == Enum.UserInputState.End then
		if actionName == "Right" then
			if r then
				moveDir = moveDir - Vector3.new(1,0,0)
				r = not r
			end
		elseif actionName == "Left" then
			if l then
				moveDir = moveDir - Vector3.new(-1,0,0)
				l = not l
			end
		elseif actionName == "Forward" then
			if f then
				moveDir = moveDir - Vector3.new(0,0,-1)
				f = not f
			end
		elseif actionName == "Backward" then
			if b then
				moveDir = moveDir - Vector3.new(0,0,1)
				b = not b
			end
		end
	end
end


local jumpTick = 1
local function onJump(actionName, inputState)
	if inputState == Enum.UserInputState.Begin then
		if tick() - jumpTick > 1.5 then
			jumpTick = tick()
			hrp.Velocity = JUMP_VELOCITY--hrp.Velocity + --hrp.CFrame:vectorToWorldSpace(JUMP_VEL)
		end
	end
end





local Event = game.ReplicatedStorage.Physics
local isRagdoll = false

Event.OnClientEvent:Connect(function(model, humanoid, _plr, recovered)
	if _plr == plr and not recovered then
		r,l,f,b = false, false, false, false
		hrp.Velocity = Vector3.new(0,0,0)
		moveDir = Vector3.new(0,0,0)
		
		camera.CameraSubject = model.Head
		humanoid:ChangeState("Physics")
		model.HumanoidRootPart.BodyGyro.P = 100

		ContextActionService:BindAction("Jump", onJump, false, table.unpack(JUMP_KEYS))
		ContextActionService:BindAction("Left", onMove, false, table.unpack(LEFT_KEYS))
		ContextActionService:BindAction("Right", onMove, false, table.unpack(RIGHT_KEYS))
		ContextActionService:BindAction("Forward", onMove, false, table.unpack(FORWARD_KEYS))
		ContextActionService:BindAction("Backward", onMove, false, table.unpack(BACKWARD_KEYS))

		isRagdoll = true
	elseif _plr == plr and recovered then
		r,l,f,b = false, false, false, false
		moveDir = Vector3.new(0,0,0)
		camera.CameraSubject = model.Humanoid
		--humanoid:ChangeState("Ragdoll")
		model.HumanoidRootPart.BodyGyro.P = 0

		ContextActionService:UnbindAction("Jump")
		ContextActionService:UnbindAction("Left")
		ContextActionService:UnbindAction("Right")
		ContextActionService:UnbindAction("Forward")
		ContextActionService:UnbindAction("Backward")

		

		isRagdoll = false
	end
end)

local soundIsStarted = false
local SoundService = game.SoundService
local sound = Instance.new("Sound")
sound.SoundId = "rbxassetid://189683058"
sound.Looped = true

local function playMovementSound(start)
	if start and not soundIsStarted then
		soundIsStarted = true
		sound:Play()
	elseif not start and soundIsStarted then
		if sound.IsPlaying then
			sound:Stop()
		end

		soundIsStarted = false
	end
end

game:GetService("RunService").Stepped:Connect(function()
	if isRagdoll then
		local moveSpeed = camera.CFrame:VectorToWorldSpace(moveDir*MOVE_SPEED)
		if moveDir ~= Vector3.new(0,0,0) then
			playMovementSound(true)
		else
			playMovementSound(false)
		end
		hrp.Velocity = Vector3.new(math.clamp(hrp.Velocity.X + moveSpeed.X, -MOVE_SPEED, MOVE_SPEED), hrp.Velocity.Y, math.clamp(hrp.Velocity.Z + moveSpeed.Z, -MOVE_SPEED, MOVE_SPEED))
		BG.CFrame = hrp.CFrame
	end
end)



