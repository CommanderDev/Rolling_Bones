--[[
    Author: ChipioIndustries
	Description: Combine submodules into a core reducer

	For use in Rodux reducers

	Receives a folder containing submodules.
--]]

local Framework = require(game.ReplicatedStorage.CloudFrameShared.Main)
local Rodux = Framework.loadLibrary("Rodux")

function combineSubreducers(source)
	local reducers = {}
	for index,reducer in pairs(source:GetChildren()) do
		if reducer:IsA("ModuleScript") then
			reducers[reducer.Name] = require(reducer)
		end
	end
	return Rodux.combineReducers(reducers)
end

return combineSubreducers