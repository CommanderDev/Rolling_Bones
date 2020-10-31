local TweenService = game:GetService("TweenService")

local module = {}

--[[
	TEMPLATE FOR CUSTOM DESPAWN EFFECT:
	
	[INT] = function(Model, DespawnTime)
		-- // YOUR CODE HERE
		return true
	end;
--]]

local DespawnTypes = {
	[1] = function(Model, DespawnTime)
		wait(DespawnTime)
		for i, v in pairs(Model:GetDescendants()) do
			if v:IsA("BasePart") then
				local TweenInfo_ = TweenInfo.new(1)
				TweenService:Create(v, TweenInfo_, {Transparency = 1}):Play()
			end
		end
		Model:Destroy()
		return true
	end;
	[2] = function(Model, DespawnTime)
		wait(DespawnTime)
		Model:Destroy()
	end;
}

function module.GetInfo(Type)
	if Type ~= "Random" then
		return DespawnTypes[Type]
	elseif Type == "Random" then
		local RandomDespawn = DespawnTypes[math.random(1, #DespawnTypes)]
		repeat RandomDespawn = DespawnTypes[math.random(1, #DespawnTypes)] wait() until RandomDespawn ~= "Random"
		return RandomDespawn
	end
end

return module
