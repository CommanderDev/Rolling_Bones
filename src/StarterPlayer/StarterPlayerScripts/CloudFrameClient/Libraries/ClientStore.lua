--[[
    Author: ChipioIndustries
    Description: Initialize and provide the client-side Rodux store
--]]

local Player = game.Players.LocalPlayer
local Client = require(Player.PlayerScripts:WaitForChild("CloudFrameClient",1):WaitForChild("Main",1))
local Rodux = Client.loadLibrary("Rodux")

local actionStream = Client.getDataStream("ActionReplication","RemoteEvent")
local initialStateStream = Client.getDataStream("InitialState","RemoteFunction")

local reducer = Client.require("Reducer") or Rodux.combineReducers({})

local initialState = initialStateStream:InvokeServer()

local store = Rodux.Store.new(reducer,initialState,{
	--Rodux.loggerMiddleware --print changes to output
})

--replicate actions from server
actionStream.OnClientEvent:Connect(function(action)
	store:dispatch(action)
end)

return store