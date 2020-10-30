local Main = require(game.ServerScriptService.FrameServer.Main)

local ShowRaceStandings = Main.getDataStream("ShowRaceStandings", "RemoteEvent")
local IntermissionUpdater = Main.getDataStream("IntermissionUpdater", "RemoteEvent")
local RaceIntermissionUpdater = Main.getDataStream("RaceIntermissionUpdater", "RemoteEvent")
local PrixEndedEvent = Main.getDataStream("PrixEnded", "RemoteEvent")

local Class = Main.loadLibrary("Class")
local Sort = Main.loadLibrary("Sort")
local Timer = Main.loadLibrary("Timer")

local Race = Main.require("Race")
local Participant = Main.require("Participant")

local Maps = Main.getPath(game.ServerStorage, "Maps")

local GrandPrix = Class.new()

local raceCooldownTimer = 10
local maxPerPrix = 3

function GrandPrix.new()
    local self = setmetatable({}, GrandPrix)
    self.playersInPrix = {}
    self.mapsInPrix = {}
    self.currentStandings = {}
    self.currentStage = 0
    self.currentMap = nil
    self.currentRaceClass = nil 
    return self
end

function GrandPrix:createNextRace()
    print(self.currentStage)
    self.currentMap = self.mapsInPrix[self.currentStage]:Clone()
    self.currentMap.Parent = workspace
    self.currentRaceClass = Race.new(self)
    self.currentRaceClass:startRace()
end

function GrandPrix:startPrix()
    coroutine.wrap(function()
        for index = 1, maxPerPrix do 
            local randomMap = math.random(1, #Maps:GetChildren())
            local randomMapFolder = Maps:GetChildren()[randomMap]
            table.insert(self.mapsInPrix, randomMapFolder)
        end
    end)()
    for index, playerObject in next, game.Players:GetPlayers() do 
        self.playersInPrix[playerObject.Name] = Participant.new(playerObject)
    end
    self:beginNextRace()
end 

function GrandPrix:beginNextRace()
    IntermissionUpdater:FireAllClients(raceCooldownTimer)
    self.currentStage += 1
    local intermissionTimer = Timer.new({
        length = raceCooldownTimer;
        repeats = 0;
        callback = function()
            self:createNextRace()
        end;
        subroutines = {
            Timer.new({
                length = 0;
                callback = function(mainroutine, subroutine)
                    RaceIntermissionUpdater:FireAllClients(mainroutine.timeLeft, self.currentStage, maxPerPrix)
                end;
            })
        }
    })
    intermissionTimer:startTimer() 
end 

function GrandPrix:raceEnded(playersInRace) 
    self.currentStandings = {}
    for playerName, participant in next, self.playersInPrix do 
        table.insert(self.currentStandings, participant)
    end    
    Sort(self.currentStandings, "amountOfPoints")
    for index, participant in next, self.currentStandings do 
        if game.Players:FindFirstChild(participant.playerObject.Name) then 
            participant:updateStanding(index) 
        end
    end
    ShowRaceStandings:FireAllClients(self.playersInPrix)
    wait(12)
    if self.currentStage >= maxPerPrix then 
        self:prixEnded()
    else 
        self:beginNextRace()
    end
end 

function GrandPrix:prixEnded()
    PrixEndedEvent:FireAllClients(self.currentStandings[1].playerObject.Name)
    Main.require("GrandPrixManager").prixEnded()
end

return GrandPrix