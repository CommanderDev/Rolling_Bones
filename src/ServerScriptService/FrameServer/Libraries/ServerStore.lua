--[[
    Author: ChipioIndustries
    Description: Initialize and provide server-side Rodux store
--]]

local Server = require(game.ServerScriptService.CloudFrameServer.Main)
local Rodux = Server.loadLibrary("Rodux")

local reducer = Server.require("Reducer") or Rodux.combineReducers({})
local replicationMiddleware = Server.require("ReplicateActions")

--just in case replicationmiddleware isn't included
replicationMiddleware = replicationMiddleware or function(nextDispatch,store)
	return function(action)
		nextDispatch(action)
	end
end

local store = Rodux.Store.new(reducer,{},{
	--Rodux.loggerMiddleware;
	replicationMiddleware;
})

return store