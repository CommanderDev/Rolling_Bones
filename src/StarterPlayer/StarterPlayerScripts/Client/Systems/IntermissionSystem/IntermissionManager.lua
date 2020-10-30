local Main = require(game.ReplicatedStorage.FrameShared.Main)

local StartIntermissionEvent = Main.getDataStream("StartIntermissionEvent", "RemoteEvent")
local IntermissionUpdater = Main.getDataStream("IntermissionUpdater", "RemoteEvent")

local Timer = Main.loadLibrary("Timer")

local playerObject = game.Players.LocalPlayer
local PlayerGui = playerObject:WaitForChild("PlayerGui")
local Interface = PlayerGui:WaitForChild("Interface")
local TimerLabel = Interface:WaitForChild("TimerLabel")

local IntermissionManager = {}

local function intermissionTimerText(timeLeft)
    if timeLeft > 1 then 
        return "Grand Prix starts in "..timeLeft.." seconds"
    else 
        return "Grand Prix starts in "..timeLeft.." second"
    end 
end 

function IntermissionManager.init()
    IntermissionUpdater.OnClientEvent:Connect(function(timeLeft)
        TimerLabel.Visible = true 
        TimerLabel.Text = intermissionTimerText(timeLeft)
    end)
end 

return IntermissionManager 