--[[
    Author: ChipioIndustries
	Description: Combine reducer tree into a single reducer
	
	init.lua files will convert the parent folder into a ModuleScript
--]]

local RunService = game:GetService("RunService")
local Framework = require(game.ReplicatedStorage.CloudFrameShared.Main)
local Rodux = Framework.loadLibrary("Rodux")

local sharedReducers = script
local localReducers

if RunService:IsServer() then
	localReducers = Framework.getPath(game.ServerScriptService.CloudFrameServer.Rodux,"Reducers")
else
	local player = game.Players.LocalPlayer
	localReducers = Framework.getPath(player.PlayerScripts,"CloudFrameClient.Rodux.Reducers")
end

local allReducers = {}

local function addReducers(Source)
	for _,reducer in pairs(Source:GetChildren()) do
		allReducers[reducer.Name] = require(reducer)
	end
end

addReducers(sharedReducers)
addReducers(localReducers)

local reducer = Rodux.combineReducers(allReducers)

return reducer