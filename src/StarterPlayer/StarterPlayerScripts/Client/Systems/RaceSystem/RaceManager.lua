local Main = require(game.ReplicatedStorage.FrameShared.Main)

local StartRaceTimer = Main.getDataStream("StartRaceTimer", "RemoteEvent")
local RaceTimeUpdater = Main.getDataStream("RaceTimeUpdater", "RemoteEvent")
local ShowRaceStandings = Main.getDataStream("ShowRaceStandings", "RemoteEvent")

local Timer = Main.loadLibrary("Timer")

local PlacementText = Main.require("PlacementText")

local playerObject = game.Players.LocalPlayer
local PlayerGui = playerObject:WaitForChild("PlayerGui")
local Interface = PlayerGui:WaitForChild("Interface")
local TimerLabel = Interface:WaitForChild("TimerLabel")
local Scoreboard = Interface:WaitForChild("Scoreboard")

local ScoreboardLayout = game.ReplicatedStorage:WaitForChild("ScoreboardLayout")
local PlayerFrame = game.ReplicatedStorage:WaitForChild("PlayerFrame")

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

    ShowRaceStandings.OnClientEvent:Connect(function(playersInPrix)
        Scoreboard:ClearAllChildren()
        ScoreboardLayout:Clone().Parent = Scoreboard
        for playerName, participant in next, playersInPrix do 
            local playerObject = game.Players:FindFirstChild(playerName)
            coroutine.wrap(function()
                if not playerObject then return end
                local newPlayerFrame = PlayerFrame:Clone()
                local PlayerEmblem = newPlayerFrame:WaitForChild("PlayerEmblem")
                local Placement = newPlayerFrame:WaitForChild("Placement")
                local PlayerName = newPlayerFrame:WaitForChild("PlayerName")
                local Points = newPlayerFrame:WaitForChild("Points")
                PlayerName.Text = playerName
                local placementText = participant.lastRecordedRaceStanding.."th" 
                local placementColor = Color3.new(1,1,1)
                local placementTextData = PlacementText[participant.lastRecordedRaceStanding] 
                if placementTextData then 
                    placementText = placementTextData.text
                    placementColor =placementTextData.color
                end
                Placement.Text = placementText
                Placement.TextColor3 = placementColor
                Points.Text = participant.lastRecordedRacePoints.." pts"
                PlayerEmblem.Image = game.Players:GetUserThumbnailAsync(playerObject.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size180x180)
                newPlayerFrame.LayoutOrder = participant.lastRecordedRaceStanding
                newPlayerFrame.Name = participant.lastRecordedRaceStanding
                newPlayerFrame.Parent = Scoreboard
            end)()
        end
        Scoreboard.Visible = true
    end)
end 



return RaceManager 