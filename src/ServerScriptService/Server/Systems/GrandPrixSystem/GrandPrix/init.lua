local Main = require(game.ServerScriptService.FrameServer.Main)

local Class = Main.loadLibrary("Class")

local Race = Main.require("Race")
local Participant = Main.require("Participant")

local Maps = Main.getPath(game.ServerStorage, "Maps")

local GrandPrix = Class.new()

function GrandPrix.new()
    local self = setmetatable({}, GrandPrix)
    self.playersInPrix = {}
    self.mapsInPrix = {}
    self.currentStage = 0
    self.currentMap = nil
    self.currentRaceClass = nil 
    return self
end

function GrandPrix:startPrix()
    print("Starting grand prix!")
    coroutine.wrap(function()
        for index = 1, 3 do 
            local randomMap = math.random(1, #Maps:GetChildren())
            local randomMapFolder = Maps:GetChildren()[randomMap]
            table.insert(self.mapsInPrix, randomMapFolder)
        end
    end)()
    for index, playerObject in next, game.Players:GetPlayers() do 
        self.playersInPrix[playerObject] = Participant.new(playerObject)
    end
    self.currentStage += 1
    self.currentMap = self.mapsInPrix[self.currentStage]:Clone()
    self.currentMap.Parent = workspace
    self.currentRaceClass = Race.new(self)
    self.currentRaceClass:startRace()
end 

return GrandPrix