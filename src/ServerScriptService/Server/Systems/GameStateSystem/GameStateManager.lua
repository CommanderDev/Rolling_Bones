local GameStateManager = {}

local gameState = "Waiting"

function GameStateManager:setState(newState)
    gameState = newState
end 

function GameStateManager:getState()
    return gameState
end 

return GameStateManager 