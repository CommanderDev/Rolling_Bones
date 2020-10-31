local Main = require(game.ServerScriptService.FrameServer.Main)

local StartRaceTimer = Main.getDataStream("StartRaceTimer", "RemoteEvent")
local RaceTimeUpdater = Main.getDataStream("RaceTimeUpdater", "RemoteEvent")
--local RaceTimer = Main.getDataStream("RaceTimer", "RemoteEvent")

local Class = Main.loadLibrary("Class")
local Timer = Main.loadLibrary("Timer")

local Participant = Main.require("Participant")

local LobbySpawns = Main.getPath(workspace, "LobbySpawns")

local countdownTime = 3
local Race = Class.new()

function Race.new(grandPrix)
    local self = setmetatable({}, Race)
    self.grandPrixClass = grandPrix
    self.currentMap = grandPrix.currentMap
    self.playersInRace = {}
    self.maxPointsAwarded = 0
    self.playersFinished = {}
    self.finishTouchConnection = nil 
    self.killingPartsConnections = {}
    self.checkpointConnections = {}
    self.ongoing = true
    return self
end

function Race:endRace()
    self.ongoing = false
    self.grandPrixClass:raceEnded(self.playersInRace)
    if self.finishTouchConnection then 
        self.finishTouchConnection:Disconnect()
    end
    for index, killingPartConnection in next, self.killingPartsConnections do 
        if killingPartConnection then 
            killingPartConnection:Disconnect()
        end
    end
    for index, checkpointConnection in next, self.checkpointConnections do 
        if checkpointConnection then 
            checkpointConnection:Disconnect()
        end
    end
    for playerName, participant in next, self.grandPrixClass.playersInPrix do 
        local playerObject = game.Players:GetPlayerFromCharacter(characterObject)
        if playerObject then
            local randomSpawn = math.random(1, #LobbySpawns:GetChildren())
            local randomLocation = LobbySpawns:GetChildren()[randomSpawn].CFrame
            local participant = self.grandPrixClass.playersInPrix[playerObject.Name]
            participant:moveToPoint(randomLocation)
        end 
    end
    self = nil
end 

function Race:checkRaceStatus()
    if not self.ongoing then return end
    local endRace = true 
    for playerName, playerData in next, self.playersInRace do 
        local playerObject = game.Players:FindFirstChild(playerName) 
        if playerObject and not playerData.finished then 
            endRace = false
        end
    end
    if endRace then 
        self:endRace()
    end
end 

function Race:movePlayersToStartingPoint()
    for index, participant in next, self.grandPrixClass.playersInPrix do 
        local availablePoints = self.currentMap.StartPoints:GetChildren()
        local randomPoint = math.random(1,#availablePoints)
        local playerPoint = availablePoints[randomPoint]
        participant:moveToPoint(playerPoint.CFrame + Vector3.new(0,5,0)) 
        playerPoint:Destroy()
    end
    self.currentMap.StartPoints:Destroy()
end 

function Race:connectFinishline()
    self.currentMap.Finish.Touched:Connect(function(hit)
        local characterObject = hit.Parent 
        local playerObject = game.Players:GetPlayerFromCharacter(characterObject)
        if playerObject and self.playersInRace[playerObject.Name] and not self.playersInRace[playerObject.Name].finished then 
            local randomSpawn = math.random(1, #LobbySpawns:GetChildren())
            local randomLocation = LobbySpawns:GetChildren()[randomSpawn].CFrame
            local participant = self.grandPrixClass.playersInPrix[playerObject.Name]
            participant:moveToPoint(randomLocation)
            participant:awardPoints(self.maxPointsAwarded)
            self.playersInRace[playerObject.Name].finished = true
            self.maxPointsAwarded -= 2
            table.insert(self.playersFinished, playerObject)
            participant:finishedRace(#self.playersFinished, self.currentMinutes, self.currentSeconds, self.currentMiliseconds)
            self:checkRaceStatus()
        end
    end)   
end 

function Race:connectKillingParts()
    for index, part in next, self.currentMap.KillingParts:GetChildren() do 
        table.insert(self.killingPartsConnections, part.Touched:Connect(function(hit)
            local characterObject = hit.Parent 
            local playerObject = game.Players:GetPlayerFromCharacter(characterObject)
            if playerObject and self.playersInRace[playerObject.Name] and not self.playersInRace[playerObject.Name].finished then 
                local participant = self.grandPrixClass.playersInPrix[playerObject.Name]
                participant:moveToPoint(participant.lastTeleportedLocation)
            end
        end))
    end
end 

function Race:connectCheckpoints()
    for index, part in next, self.currentMap.Checkpoints:GetChildren() do 
        table.insert(self.checkpointConnections, part.Touched:Connect(function(hit)
            local characterObject = hit.Parent 
            local playerObject = game.Players:GetPlayerFromCharacter(characterObject)
            if playerObject and self.playersInRace[playerObject.Name] and not self.playersInRace[playerObject.Name].finished then 
                local participant = self.grandPrixClass.playersInPrix[playerObject.Name]
                participant.lastTeleportedLocation = part.CFrame + Vector3.new(math.random(1,5), 0, 0)
            end
        end))
    end
end

function Race:handleRaceTimer()
    self.currentMiliseconds = 0
    self.currentSeconds = 0
    self.currentMinutes = 3;
    coroutine.wrap(function()
        Participant.toggleTimerVisible:fire(true)
        while wait(1/1000) do 
            if not self.ongoing then Participant.toggleTimerVisible:fire(false) break end
            if self.currentMinutes <= 0 and self.currentSeconds <= 0 and self.currentMiliseconds <= 0 then 
                Participant.toggleTimerVisible:fire(false)
                self:endRace()
                break
            end
            self.currentMiliseconds -= 1
            if self.currentSeconds <= 0 and self.currentMinutes > 0 and self.currentMiliseconds <= 1 then 
                self.currentMinutes -= 1 
                self.currentSeconds = 59
                self.currentMiliseconds = 30
            end
            if self.currentMiliseconds < 0 then 
                self.currentSeconds -= 1
                self.currentMiliseconds = 30
            end
            Participant.updateTimer:fire(self.currentMinutes, self.currentSeconds, self.currentMiliseconds)
        end
    end)()
end

function Race:startRace()
    StartRaceTimer:FireAllClients(countdownTime)
    self:movePlayersToStartingPoint()
    for index, participant in next, self.grandPrixClass.playersInPrix do 
        if participant then 
            participant:changeMoveSpeed(0)
            participant:raceStarted()
            --participant:activateRagdoll()
            self.maxPointsAwarded += 2
            self.playersInRace[participant.playerObject.Name] = {
                finished = false;
                placement = 0;
            }
        end
    end
    RaceTimeUpdater:FireAllClients(countdownTime)
    local raceTimer = Timer.new({
        length = countdownTime;
        repeats = 0;
        callback = function()
            for index, participant in next, self.grandPrixClass.playersInPrix do 
                participant:changeMoveSpeed(16)
                self:connectFinishline()
                self:connectKillingParts()
                self:connectCheckpoints()
                self:handleRaceTimer()
            end
        end;
        subroutines = {
            Timer.new({
                length = 0.25;
                callback = function(mainroutine)
                    RaceTimeUpdater:FireAllClients(mainroutine.timeLeft)
                end
            })
        }
    })
    raceTimer:startTimer()
end 

return Race