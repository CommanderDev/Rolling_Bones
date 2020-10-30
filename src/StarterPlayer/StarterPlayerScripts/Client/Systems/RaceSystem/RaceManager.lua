local Main = require(game.ReplicatedStorage.FrameShared.Main)

local StartRaceTimer = Main.getDataStream("StartRaceTimer", "RemoteEvent")
local RaceTimeUpdater = Main.getDataStream("RaceTimeUpdater", "RemoteEvent")

local Timer = Main.loadLibrary("Timer")

local playerObject = game.Players.LocalPlayer
local PlayerGui = playerObject:WaitForChild("PlayerGui")
local Interface = PlayerGui:WaitForChild("Interface")
local TimerLabel = Interface:WaitForChild("TimerLabel")

local RaceManager = {}

function RaceManager.init()
    TimerLabel.Visible = true 
    StartRaceTimer.OnClientEvent:Connect(function(amountOfTime)
        local raceTimer = Timer.new({
            length = amountOfTime;
            repeats = 0;
            callback = function()
                TimerLabel.Visible = false
            end;
            subroutines = {
                Timer.new({
                    length = 1;
                    callback = function(mainroutine)
                        TimerLabel.Text = mainroutine.timeLeft
                    end;
                })
            }
        })
        raceTimer:startTimer()
    end)
    
    RaceTimeUpdater.OnClientEvent:Connect(function(timeLeft)
        TimerLabel.Text = timeLeft
    end)
end 



return RaceManager 