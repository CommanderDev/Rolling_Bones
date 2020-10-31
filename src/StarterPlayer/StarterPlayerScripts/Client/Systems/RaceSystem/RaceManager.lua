local ContentProvider = game:GetService("ContentProvider")

local Main = require(game.ReplicatedStorage.FrameShared.Main)

local StartRaceTimer = Main.getDataStream("StartRaceTimer", "RemoteEvent")
local RaceTimeUpdater = Main.getDataStream("RaceTimeUpdater", "RemoteEvent")
local ShowRaceStandings = Main.getDataStream("ShowRaceStandings", "RemoteEvent")
local RaceIntermissionUpdater = Main.getDataStream("RaceIntermissionUpdater", "RemoteEvent")

local Timer = Main.loadLibrary("Timer")
local RichText = Main.loadLibrary("RichText")

local PlacementText = Main.require("PlacementText")

local playerObject = game.Players.LocalPlayer
local PlayerGui = playerObject:WaitForChild("PlayerGui")
local Interface = PlayerGui:WaitForChild("Interface")
local TimerLabel = Interface:WaitForChild("TimerLabel")
local RaceTimerLabel = Interface:WaitForChild("RaceTimerLabel")
local Scoreboard = Interface:WaitForChild("Scoreboard")

local PlayerFrame = game.ReplicatedStorage:WaitForChild("PlayerFrame")

local RaceManager = {}

local sortedStandings = {}

local function showStandings(playersInPrix, sortedBy, points)
    Scoreboard:ClearAllChildren()
    Scoreboard.Visible = true
    Scoreboard.CanvasSize = UDim2.new(0,0,0,0)
    sortedStandings = {}
    local dnfNumber = 0
    for playerName, participant in next, playersInPrix do 
        local playerObject = game.Players:FindFirstChild(playerName)
        if playerObject then 
            local sortby = participant[sortedBy]
            if not sortby then 
                dnfNumber += 1 
                participant[sortedBy] = 30+dnfNumber
                participant[points] = 0
                sortby = participant[sortedBy]
            end 
            sortedStandings[sortby] = {
                participant = participant;
                playerName = playerName
            } 
        end
    end

    for index, playerClass in next, sortedStandings do 
        local playerName = playerClass.playerName
        local participant = playerClass.participant
        print(participant.currentStanding)
        local playerObject = game.Players:FindFirstChild(playerName)
        if not playerObject then return end
        local newPlayerFrame = PlayerFrame:Clone()
        local PlayerEmblem = newPlayerFrame:WaitForChild("PlayerEmblem")
        local Placement = newPlayerFrame:WaitForChild("Placement")
        local PlayerName = newPlayerFrame:WaitForChild("PlayerName")
        local Points = newPlayerFrame:WaitForChild("Points")
        local TimeElasped = newPlayerFrame:WaitForChild("TimeElasped")
        PlayerName.Text = playerName
        local placementText = participant[sortedBy].."th" 
        local placementColor = Color3.new(1,1,1)
        local placementTextData = PlacementText[participant[sortedBy]] 
        if placementTextData then 
            placementText = placementTextData.text
            placementColor =placementTextData.color
            newPlayerFrame:FindFirstChild("Medal"..index).Visible = true
        end
        Placement.Text = placementText
        Placement.TextColor3 = placementColor
        Points.Text = participant[points].." pts"
        local lastRecordedRaceTime = participant.lastRecordedRaceTime
        local minutes = lastRecordedRaceTime.minutes
        local seconds = lastRecordedRaceTime.seconds 
        local miliseconds = lastRecordedRaceTime.miliseconds
        TimeElasped.Text = ("%02d:%02d:%02d"):format(minutes, seconds, miliseconds)
        PlayerEmblem.Image = game.Players:GetUserThumbnailAsync(playerObject.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size180x180)
        newPlayerFrame.Name = index
        newPlayerFrame.Parent = Scoreboard
        newPlayerFrame.Position = UDim2.new(0.21,0,1,0)
        newPlayerFrame:TweenPosition(
            UDim2.new(0.21,0, 0,60*participant[sortedBy], Enum.EasingDirection.In, Enum.EasingStyle.Sine, 0.35, true)
        )
        Scoreboard.CanvasSize = UDim2.new(0,0,0,index+newPlayerFrame.Size.Y.Offset)
        wait(0.35)
    end
end 

function RaceManager.init()
    TimerLabel.Visible = true 
    StartRaceTimer.OnClientEvent:Connect(function(amountOfTime)
        local raceTimer = Timer.new({
            length = amountOfTime;
            repeats = 0;
            callback = function()
                TimerLabel.Visible = false
            end;
        })
        raceTimer:startTimer()
    end)
    
    RaceTimeUpdater.OnClientEvent:Connect(function(timeLeft)
        TimerLabel.Text = timeLeft
    end)

    ShowRaceStandings.OnClientEvent:Connect(function(playersInPrix)
        showStandings(playersInPrix, "lastRecordedRaceStanding", "lastRecordedRacePoints")
        wait(3)
        for index, value in next, sortedStandings do 
            local playerFrame = Scoreboard:FindFirstChild(index)
            print(playerFrame)
            playerFrame:TweenPosition(
                UDim2.new(0.21,0,1,0, Enum.EasingDirection.In, Enum.EasingStyle.Sine, 0.35, true)
            )   
            wait(0.35)
        end
        showStandings(playersInPrix, "currentStanding", "amountOfPoints")
        wait(5)
        Scoreboard.Visible = false
    end)
    
    RaceIntermissionUpdater.OnClientEvent:Connect(function(timeLeft, raceNumber, maxPerPrix)
        TimerLabel.Visible = true
        local raceNumberText = RichText.new(raceNumber, {
            bold = true;
            font = {
                size = 55;
                color = Color3.fromRGB(255,179, 0);   
            }
        })
        local maxPerPrixText = RichText.new(maxPerPrix, {
            bold = true;
            font = {
                size = 55;
                color = Color3.fromRGB(255,179, 0);   
            }
        })
        TimerLabel.Text = "Race ("..raceNumberText:get().."/"..maxPerPrixText:get()..") starts in "..timeLeft
    end)
end 



return RaceManager 