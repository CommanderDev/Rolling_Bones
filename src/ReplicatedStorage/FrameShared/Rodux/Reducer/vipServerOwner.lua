local ReplicatedStorage = game:GetService("ReplicatedStorage")

--[[
    Author: Dev0mar

    Description: Get the VIP Server Owner ID
]]

local Main = require(ReplicatedStorage.CloudFrameShared.Main)
local Rodux = Main.loadLibrary("Rodux")

return Rodux.createReducer(nil,{
	setVipServerOwner = function(_,action)
		return action.ID
	end
})