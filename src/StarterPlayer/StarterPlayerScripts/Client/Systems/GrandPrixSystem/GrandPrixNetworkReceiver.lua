local Main = require(game.ReplicatedStorage.FrameShared.Main)

--local StartPrixEvent = Main.getDataStream("StartPrixEvent")
local GrandPrixManager = Main.require("GrandPrixManager")

local GrandPrixNetworkReceiver = {}

function GrandPrixNetworkReceiver.init()
   -- StartPrixEvent.OnClientEvent:Connect(GrandPrixManager.startPrix)
end 

return GrandPrixNetworkReceiver 