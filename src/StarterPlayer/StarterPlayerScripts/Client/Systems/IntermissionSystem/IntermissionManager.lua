local Main = require(game.ReplicatedStorage.FrameShared.Main)

local StartIntermissionEvent = Main.getDataStream("StartIntermissionEvent", "RemoteEvent")
local IntermissionUpdater = Main.getDataStream("IntermissionUpdater", "RemoteEvent")

local RichText = Main.loadLibrary("RichText")

local playerObject = game.Players.LocalPlayer
local PlayerGui = playerObject:WaitForChild("PlayerGui")
local Interface = PlayerGui:WaitForChild("Interface")
local TimerLabel = Interface:WaitForChild("TimerLabel")

local IntermissionManager = {}

local function intermissionTimerText(timeLeft)
    local numberText = RichText.new(timeLeft, {
        bold = true;
        font = {
           size = 55;
           color = Color3.fromRGB(255,179, 0);
        }
     })
    if timeLeft > 1 then 
        return "Grand Prix starts in "..numberText:get().." seconds"
    else 
        return "Grand Prix starts in "..numberText:get().." second"
    end 
end 

function IntermissionManager.init()
    IntermissionUpdater.OnClientEvent:Connect(function(timeLeft)
        if not timeLeft then 
            TimerLabel.Visible = false
            return
        end
        TimerLabel.Visible = true 
        TimerLabel.Text = intermissionTimerText(timeLeft)
    end)
end 

return IntermissionManager 