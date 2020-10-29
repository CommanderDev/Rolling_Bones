--[[
    Author: ChipioIndustries
	Description: Replicate store actions to the given replicationTarget
	
	To replicate to all players, action's replicationTarget should be "all"

	This also manages a duplicate Rodux store that only takes in replicated
	actions, so it can be easily replicated to the client when needed
--]]

local Server = require(game.ServerScriptService.CloudFrameServer.Main)
local Rodux = Server.loadLibrary("Rodux")

local actionStream = Server.getDataStream("ActionReplication","RemoteEvent")
local initialStateStream = Server.getDataStream("InitialState","RemoteFunction")

local reducer = Server.require("Reducer") or Rodux.combineReducers({})

local replicatedStore = Rodux.Store.new(reducer,{})

local function replicationMiddleware(nextDispatch,store)
	return function(action)
		if action.replicationTarget then
			if action.replicationTarget=="all" then
				actionStream:FireAllClients(action)
				replicatedStore:dispatch(action) --update our dummy store
			else
				actionStream:FireClient(action.replicationTarget,action)
			end
		end
		nextDispatch(action)
	end
end

local function provideDefaultState(player)
	return replicatedStore:getState()
end

initialStateStream.OnServerInvoke = provideDefaultState

return replicationMiddleware