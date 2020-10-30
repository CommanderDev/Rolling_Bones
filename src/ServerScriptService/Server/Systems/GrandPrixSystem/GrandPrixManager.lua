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

local intermissionTime = 10

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

local function startRace()
    print(currentStage)
    map = chosenMaps[currentStage]:Clone()
    map.Parent = workspace
    local startPoints = map:WaitForChild("StartPoints")
    for playerObject, playerData in next, playersInPrix do 
        local characterObject = playerObject.Character or playerObject.CharacterAdded:Wait()
        characterObject:WaitForChild("HumanoidRootPart").CFrame = startPoints:GetChildren()[math.random(1, #startPoints:GetChildren())].CFrame + Vector3.new(0,2,0)
    end
    changePlayerMovement(0)
    GameStateManager:setState("Racing")
    local raceTimer = Timer.new({
        length = countdownTime + 1;
        repeats = 0;
        callback = function()
            changePlayerMovement(16)
            updatePlayerTimers(false)
            StartRace:FireAllClients()
        end;
        subroutines = {
            Timer.new({
                length = 0.25;
                callback = function(mainroutine)
                    updatePlayerTimers(mainroutine.timeLeft)
                end
            })
        }
    })
    raceTimer:startTimer()
    
    for playerObject, playerData in next, playersInPrix do 
        unfinishedPlayers[playerObject] = true
    end 
    finishTouchConnection = map.Finish.Touched:Connect(function(hit)
        local characterObject = hit.Parent 
        local playerObject = game.Players:GetPlayerFromCharacter(characterObject)
        if playerObject and not table.find(placements, playerObject) then 
            table.insert(placements, playerObject)
            unfinishedPlayers[playerObject] = false
            updateRaceStatus()
        end
    end)
end 

--[[local function startPrix()
    GameStateManager:setState("Grand Prix")
    chosenMaps = {}
    for index = 1,3 do 
        local randomMap = math.random(1, #game.ServerStorage.Maps:GetChildren())
        local randomMapFolder = game.ServerStorage.Maps:GetChildren()[randomMap]
        table.insert(chosenMaps, randomMapFolder)
    end
    currentStage = 1
    maxPointsAwarded = 2 + numberInPrix * 2 
    startRace()
end 
]]
local function updatePrixStatus()
    if numberInPrix >= numberRequired then 
        print("Starting prix!")
        GameStateManager:setState("Intermission")
        local intermissionTimer = Timer.new({
            length = intermissionTime;
            repeats = 0;
            callback = function()
                currentPrix = GrandPrix.new()
                currentPrix:startPrix()
                --startPrix()
                --updatePlayerTimers(false)
            end;
            subroutines = {
                Timer.new({
                    length = 1;
                    callback = function(mainroutine, subroutine)
                        IntermissionUpdater:FireAllClients(mainroutine.timeLeft)
                        print('Timer running!')
                      --  updatePlayerTimers(mainroutine.timeLeft);
                    end;
                })
            }
        })
        intermissionTimer:startTimer()
    end 
end 
function GrandPrixManager.addPlayerToPrix(playerObject)
  --[[  playersInPrix[playerObject] = {
        placement = 1;
        currentPoints = 0;
    }
    ]]
    numberInPrix += 1
    updatePrixStatus()
end 

return GrandPrixManager 