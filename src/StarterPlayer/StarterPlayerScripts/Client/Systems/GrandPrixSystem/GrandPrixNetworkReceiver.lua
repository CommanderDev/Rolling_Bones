local Main = require(game.ReplicatedStorage.FrameShared.Main)

local PrixEndedEvent = Main.getDataStream("PrixEnded", "RemoteEvent")
local WaitingEvent = Main.getDataStream("WaitingEvent", "RemoteEvent")

local RichText = Main.loadLibrary("RichText")

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

   WaitingEvent.OnClientEvent:Connect(function(numberRequired)
         local numberText = RichText.new(numberRequired-#game.Players:GetPlayers(), {
            bold = true;
            font = {
               size = 65;
               color = Color3.fromRGB(255,179, 0);
            }
         })
         TimerLabel.Text = "Waiting for "..numberText:get().." to start the Grand Prix"
   end)
end 

return GrandPrixNetworkReceiver 