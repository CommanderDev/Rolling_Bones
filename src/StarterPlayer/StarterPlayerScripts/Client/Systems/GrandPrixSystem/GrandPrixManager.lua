local Main = require(game.ReplicatedStorage.FrameShared.Main)

local Timer = Main.loadLibrary("Timer")

local playerObject = game.Players.LocalPlayer
local PlayerGui = playerObject:WaitForChild("PlayerGui")
local Interface = PlayerGui:WaitForChild("Interface")
local TimerLabel = Interface:WaitForChild("TimerLabel")

local GrandPrixManager = {}

function GrandPrixManager.startPrix(timeUntilStart)
    TimerLabel.Visible = true
    local countdownTimer = Timer.new({
        length = timeUntilStart;
        repeats = 0;
        callback = function()
            TimerLabel.Visible = false
        end;
        subroutines = {
            Timer.new({
                length = 1;
                callback = function(mainroutine, subroutine)
                    TimerLabel.Text = mainroutine.timeLeft
                end;
            })
        }
    })
end 

function GrandPrixManager.startRace()
    print("Start race client received!")
    TimerLabel.Visible = false
end

return GrandPrixManager