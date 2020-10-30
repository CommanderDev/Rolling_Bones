local Main = require(game.ReplicatedStorage.FrameShared.Main)

local PrixEndedEvent = Main.getDataStream("PrixEnded", "RemoteEvent")

local playerObject = game.Players.LocalPlayer
local PlayerGui = playerObject:WaitForChild("PlayerGui")
local Interface = PlayerGui:WaitForChild("Interface")
local TimerLabel = Interface:WaitForChild("TimerLabel")

local GrandPrixNetworkReceiver = {}

function GrandPrixNetworkReceiver.init()
   PrixEndedEvent.OnClientEvent:Connect(function(winner)
         TimerLabel.Visible = true
         TimerLabel.Text = winner.." has won the grand prix!"
         wait(5)
         TimerLabel.Visible = false
   end)
end 

return GrandPrixNetworkReceiver 