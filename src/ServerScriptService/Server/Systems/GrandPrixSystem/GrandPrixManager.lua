local Main = require(game.ServerScriptService.FrameServer.Main)

local StartPrixEvent = Main.getDataStream("StartPrixEvent", "RemoteEvent")
local StartRace = Main.getDataStream("StartRace", "RemoteEvent")
local IntermissionUpdater = Main.getDataStream("IntermissionUpdater", "RemoteEvent")

local Timer = Main.loadLibrary("Timer")

local GameStateManager = Main.require("GameStateManager")
local GrandPrix = Main.require("GrandPrix")
local playersInPrix = {}
local numberInPrix = 0

local numberRequired = 1

local chosenMaps = {}
local currentStage = 0

local intermissionTime = 5

local maxPointsAwarded = 20

local map 

local placements = {}
local unfinishedPlayers = {}

local currentPrix 

local GrandPrixManager = {}

local function updatePrixStatus()
    if numberInPrix >= numberRequired then 
        GameStateManager:setState("Intermission")
        IntermissionUpdater:FireAllClients(intermissionTime)
        local intermissionTimer = Timer.new({
            length = intermissionTime;
            repeats = 0;
            callback = function()
                currentPrix = GrandPrix.new()
                currentPrix:startPrix()
                GameStateManager:setState("Grand Prix")
            end;
            subroutines = {
                Timer.new({
                    length = 1;
                    callback = function(mainroutine, subroutine)
                        IntermissionUpdater:FireAllClients(mainroutine.timeLeft)
                    end;
                })
            }
        })
        intermissionTimer:startTimer()
    end 
end 

function GrandPrixManager.addPlayerToPrix(playerObject)
    numberInPrix += 1
    updatePrixStatus()
end 

function GrandPrixManager.removePlayerFromPrix(playerObject)
    local participant = currentPrix.playersInPrix[playerObject.Name]
    print(participant)
    if participant then 
        participant:Destroy()
        currentPrix.playersInPrix[playerObject.Name] = nil
        print(currentPrix.currentRaceClass.amountInRace)
        currentPrix.currentRaceClass.amountInRace -= 1
        currentPrix.currentRaceClass:checkRaceStatus()
    end
end 

return GrandPrixManager 