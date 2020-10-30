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
        Scoreboard.Visible = true
        local sortedStandings = {}

        for playerName, participant in next, playersInPrix do 
            sortedStandings[participant.lastRecordedRaceStanding] = {
                participant = participant;
                playerName = playerName
            } 
        end
        for index, playerClass in next, sortedStandings do 
            local playerName = playerClass.playerName
            local participant = playerClass.participant
            local playerObject = game.Players:FindFirstChild(playerName)
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
            newPlayerFrame.Name = participant.lastRecordedRaceStanding
            newPlayerFrame.Parent = Scoreboard
            newPlayerFrame.Position = UDim2.new(0,0,1,0)
            newPlayerFrame:TweenPosition(
                UDim2.new(0,0, 0,40*participant.lastRecordedRaceStanding, Enum.EasingDirection.In, Enum.EasingStyle.Sine, 0.35, true)
            )
            wait(0.35)
        end
        wait(5)
        
    end)
end 



return RaceManager 