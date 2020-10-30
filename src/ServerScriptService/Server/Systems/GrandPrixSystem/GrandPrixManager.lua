local Main = require(game.ServerScriptService.FrameServer.Main)

local StartPrixEvent = Main.getDataStream("StartPrixEvent", "RemoteEvent")
local StartRace = Main.getDataStream("StartRace", "RemoteEvent")
local IntermissionUpdater = Main.getDataStream("IntermissionUpdater", "RemoteEvent")
local WaitingEvent = Main.getDataStream("WaitingEvent", "RemoteEvent")

local Timer = Main.loadLibrary("Timer")

local GameStateManager = Main.require("GameStateManager")
local GrandPrix = Main.require("GrandPrix")

local numberRequired = 1

local intermissionTime = 15

local currentPrix 

local GrandPrixManager = {}

local function updatePrixStatus()
    if #game.Players:GetPlayers() >= numberRequired then 
        print("Starting prix!")
        GameStateManager:setState("Intermission")
        IntermissionUpdater:FireAllClients(intermissionTime)
        local intermissionTimer = Timer.new({
            length = intermissionTime;
            repeats = 0;
            callback = function()
                IntermissionUpdater:FireAllClients(false)
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
    else
        WaitingEvent:FireAllClients(numberRequired)
    end 
end 

function GrandPrixManager.prixEnded()
    wait(5)
    updatePrixStatus()
end 


function GrandPrixManager.addPlayerToPrix(playerObject)
    updatePrixStatus()
end 

function GrandPrixManager.removePlayerFromPrix(playerObject)
    local participant = currentPrix.playersInPrix[playerObject.Name]
    print(participant)
    if participant then 
        participant:Destroy()
        currentPrix.playersInPrix[playerObject.Name] = nil
        if currentPrix.currentRaceClass then 
            currentPrix.currentRaceClass:checkRaceStatus()
        end 
    end
end 

return GrandPrixManager 