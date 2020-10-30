local Main = require(game.ServerScriptService.FrameServer.Main)

local StartRaceTimer = Main.getDataStream("StartRaceTimer", "RemoteEvent")
local RaceTimeUpdater = Main.getDataStream("RaceTimeUpdater", "RemoteEvent")

local Class = Main.loadLibrary("Class")
local Timer = Main.loadLibrary("Timer")

local LobbySpawns = Main.getPath(workspace, "LobbySpawns")

local countdownTime = 3
local Race = Class.new()

function Race.new(grandPrix)
    local self = setmetatable({}, Race)
    self.grandPrixClass = grandPrix
    self.currentMap = grandPrix.currentMap
    self.playersInRace = {}
    self.amountInRace = 0;
    self.maxPointsAwarded = 0
    self.playersFinished = {}
    self.finishTouchConnection = nil 
    return self
end

function Race:endRace()
    self.grandPrixClass:raceEnded(self.playersInRace)
   --[[ for index, playerObject in next, self.playersFinished do 
        local randomSpawn = math.random(1, #LobbySpawns:GetChildren())
        local randomLocation = LobbySpawns:GetChildren()[randomSpawn].CFrame
        local participant = self.grandPrixClasses.playersInPrix[playerObject]
        participant:moveToPoint(randomLocation)
        participant:awardPoints(self.maxPointsAwarded)
        self.maxPointsAwarded -= 2
    end
    ]]
    if self.finishTouchConnection then 
        self.finishTouchConnection:Disconnect()
    end
    self = nil 
end 

function Race:checkRaceStatus()
    print(#self.playersFinished) 
    print(self.amountInRace)
    if #self.playersFinished >= self.amountInRace then 
        self:endRace()
    end
end 

function Race:movePlayersToStartingPoint()
    for index, participant in next, self.grandPrixClass.playersInPrix do 
        local availablePoints = self.currentMap.StartPoints:GetChildren()
        local randomPoint = math.random(1,#availablePoints)
        local playerPoint = availablePoints[randomPoint]
        participant:moveToPoint(playerPoint.CFrame)
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
            participant:finishedRace(#self.playersFinished)
            self:checkRaceStatus()
        end
    end)   
end 

function Race:startRace()
    StartRaceTimer:FireAllClients(countdownTime)
    self:movePlayersToStartingPoint()
    for index, participant in next, self.grandPrixClass.playersInPrix do 
        self.amountInRace += 1
        participant:changeMoveSpeed(0)
        self.maxPointsAwarded += 2
        self.playersInRace[participant.playerObject.Name] = {
            finished = false;
            placement = 0;
        }
    end
    RaceTimeUpdater:FireAllClients(countdownTime)
    local raceTimer = Timer.new({
        length = countdownTime;
        repeats = 0;
        callback = function()
            for index, participant in next, self.grandPrixClass.playersInPrix do 
                participant:changeMoveSpeed(16)
                self:connectFinishline()
            end
        end;
        subroutines = {
            Timer.new({
                length = 0.25;
                callback = function(mainroutine)
                    RaceTimeUpdater:FireAllClients(mainroutine.timeLeft)
                    --updatePlayerTimers(mainroutine.timeLeft)
                end
            })
        }
    })
    raceTimer:startTimer()
end 

return Race