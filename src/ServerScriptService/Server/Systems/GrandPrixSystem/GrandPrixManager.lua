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


local function updatePlayerTimers(timeLeft)
    local gameState = GameStateManager:getState()
    for playerObject, playerData in next, playersInPrix do 
        local PlayerGui = playerObject:WaitForChild("PlayerGui")
        local Interface = PlayerGui:WaitForChild("Interface")
        local TimerLabel = Interface:WaitForChild("TimerLabel")
        if not timeLeft then 
            TimerLabel.Visible = false
            return
        end
        TimerLabel.Visible = true
        if gameState == "Intermission" then 
            if timeLeft > 1 then 
                TimerLabel.Text = "Grand Prix starts in "..timeLeft.." seconds"
            else
                TimerLabel.Text = "Grand Prix starts in "..timeLeft.." second"
            end
        else 
            TimerLabel.Text = timeLeft
        end
    end
end 

local function changePlayerMovement(walkSpeed)
    for playerObject, playerData in next, playersInPrix do
        playerObject.Character.Humanoid.WalkSpeed = walkSpeed
    end
end

local function awardPoints()
    local amountToAward = maxPointsAwarded
    for placement, playerObject in next, placements do 
        local playerData = playersInPrix[playerObject]
        if not playerData then return end
        playerData.currentPoints += amountToAward 
        print(playerObject.Name, " now has", playerData.currentPoints, " Points")
        amountToAward -= 2
    end
end 

local function updateRaceStatus()
    for playerObject, notFinished in next, unfinishedPlayers do 
        if notFinished then 
            return
        end
    end
    awardPoints()
end

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
    local participant = currentPrix.playersInPrix[playerObject]
    if participant then 
        participant:Destroy()
    end
end 

return GrandPrixManager 