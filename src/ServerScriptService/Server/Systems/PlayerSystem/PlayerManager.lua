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