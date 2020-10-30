local Main = require(game.ReplicatedStorage.FrameShared.Main)

local GameStateManager = Main.require("GameStateManager")
local GrandPrixManager = Main.require("GrandPrixManager")

local PlayerManager = {}

function PlayerManager.init() 
    game.Players.PlayerAdded:Connect(function(playerObject)
        local gameState = GameStateManager:getState()
        if gameState == "Waiting" then 
            GrandPrixManager.addPlayerToPrix(playerObject)
        end
    end)
end 

return PlayerManager