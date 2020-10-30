local Main = require(game.ServerScriptService.FrameServer.Main)

local Class = Main.loadLibrary("Class")

local Participant = Class.new()

Participant.changeWalkSpeedSignals = {}

function Participant.new(playerObject)
    print(playerObject.Name, " Is a participant in the prix")
    local self = setmetatable({}, Participant)
    self.playerObject = playerObject
    self.characterObject = playerObject.Character or playerObject.CharacterAdded
    return self 
end 

function Participant:moveToPoint(pointCFrame)
    self.characterObject:WaitForChild("HumanoidRootPart").CFrame = pointCFrame
end 

function Participant:changeMoveSpeed(newSpeed) 
    local humanoid = self.characterObject:WaitForChild("Humanoid")
    humanoid.WalkSpeed = newSpeed
end 

return Participant