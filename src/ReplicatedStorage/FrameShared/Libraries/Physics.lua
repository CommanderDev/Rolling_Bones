-- @Author: Spynaz
-- Usefull physics related functions

local PhysicsService = game:GetService("PhysicsService")

local Physics = {}

-- Position equation
function Physics.Position(p, v, a, t)
	return p + v*t + 0.5*a*(t^2)
end

-- Velocity equation
function Physics.Velocity(v, a, t)
	return a*t + v
end

local PreviousCollisionGroups 	= {}
local modelChangedSignals		= {}

-- Sets the collision group of an object
local function SetCollisionGroup(Object, CollisionGroupName)
	if Object:IsA("BasePart") then
		PreviousCollisionGroups[Object] = Object.CollisionGroupId
		PhysicsService:SetPartCollisionGroup(Object, CollisionGroupName)
	end
end

-- Resets collision group
local function ResetCollisionGroup(Object)
	local previousCollisionGroupId = PreviousCollisionGroups[Object]
	if not previousCollisionGroupId then return end 
	
	local previousCollisionGroupName = PhysicsService:GetCollisionGroupName(previousCollisionGroupId)
	if not previousCollisionGroupName then return end
	
	PhysicsService:SetPartCollisionGroup(Object, previousCollisionGroupName)
	PreviousCollisionGroups[Object] = nil
end

-- Sets the collision group of a model
function Physics.SetModelCollisionGroup(model, collisionGroupName)
	for _, object in pairs(Model:GetDescendants()) do
		SetCollisionGroup(object, CollisionGroupName)
	end
	
	modelChangedSignals[Model] = {
		Added 	= model.DescendantAdded:Connect(function(Object) SetCollisionGroup(Object, CollisionGroupName) end),
		Removing= model.DescendantRemoving:Connect(ResetCollisionGroup)
	}
end

-- Resets the collision group of a model
function Physics.resetModelCollisionGroup(model)
	local signals = modelChangedSignals[model]
	
	if signals then
		signals.Added:Disconnect()
		signals.Removing:Disconnect()
	end
	
	for _, object in next, model:GetDescendants() do
		ResetCollisionGroup(object)
	end
end

return Physics