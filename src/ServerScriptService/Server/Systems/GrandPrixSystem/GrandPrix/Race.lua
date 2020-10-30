local Main = require(game.ServerScriptService.FrameServer.Main)

local StartRaceTimer = Main.getDataStream("StartRaceTimer", "RemoteEvent")
local RaceTimeUpdater = Main.getDataStream("RaceTimeUpdater", "RemoteEvent")

local Class = Main.loadLibrary("Class")
local Timer = Main.loadLibrary("Timer")

local countdownTime = 4
local Race = Class.new()


function Race.new(grandPrix)
    local self = setmetatable({}, Race)
    self.grandPrixClass = grandPrix
    self.currentMap = grandPrix.currentMap
    return self
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

function Race:startRace()
    StartRaceTimer:FireAllClients(countdownTime)
    self:movePlayersToStartingPoint()
    for index, participant in next, self.grandPrixClass.playersInPrix do 
        participant:changeMoveSpeed(0)
    end
    local raceTimer = Timer.new({
        length = countdownTime + 1;
        repeats = 0;
        callback = function()
            for index, participant in next, self.grandPrixClass.playersInPrix do 
                participant:changeMoveSpeed(16)
            end
            --changePlayerMovement(16)
            --updatePlayerTimers(false)
            --StartRace:FireAllClients()
        end;
        subroutines = {
            Timer.new({
                length = 1;
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