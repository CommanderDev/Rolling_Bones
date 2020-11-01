local Main = require(game.ReplicatedStorage.FrameShared.Main)

local GameStateManager = Main.require("GameStateManager")
local GrandPrixManager = Main.require("GrandPrixManager")
local Ragdoll = Main.require("Ragdoll")
local PlayerManager = {}

function PlayerManager.init() 
    game.Players.PlayerAdded:Connect(function(playerObject)
        playerObject.CharacterAdded:Connect(function(characterObject)
            print(characterObject)
            characterObject:WaitForChild("HumanoidRootPart")
            characterObject:WaitForChild("Head")
            print("Character added!")
            wait(1)
            Ragdoll:Activate(characterObject)
            local LobbySpawns = workspace.LobbySpawns 
            local randomSpawn = math.random(1, #LobbySpawns:GetChildren()) 
            local randomSpawnLocation = LobbySpawns:GetChildren()[randomSpawn]
            characterObject:SetPrimaryPartCFrame(randomSpawnLocation.CFrame + Vector3.new(0,5,0))
        end)
        local gameState = GameStateManager:getState()
        if gameState == "Waiting" then 
            GrandPrixManager.addPlayerToPrix(playerObject)
        end
    end)

    game.Players.PlayerRemoving:Connect(function(playerObject)
        local gameState = GameStateManager:getState()
        if gameState == "Grand Prix" then 
            GrandPrixManager.removePlayerFromPrix(playerObject)
        end
    end)
end 

return PlayerManager