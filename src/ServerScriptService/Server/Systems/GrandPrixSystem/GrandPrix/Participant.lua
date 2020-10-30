local Main = require(game.ServerScriptService.FrameServer.Main)

local PlayerFinishedRace = Main.getDataStream("PlayerFinishedRace", "RemoteEvent")

local Class = Main.loadLibrary("Class")

local Participant = Class.new()

Participant.changeWalkSpeedSignals = {}

function Participant.new(playerObject)
    print(playerObject.Name, " Is a participant in the prix")
    local self = setmetatable({}, Participant)
    self.playerObject = playerObject
    self.amountOfPoints = 0
    self.lastRecordedRaceStanding = nil
    self.lastRecordedRacePoints = nil
    self.currentStanding = 0;
    self.characterObject = playerObject.Character or playerObject.CharacterAdded
    self.lastTeleportedLocation = nil 
    return self 
end 

function Participant:awardPoints(amountAwarded)
    print(self.playerObject.Name, " Awarded ", amountAwarded, " points!")
    self.amountOfPoints += amountAwarded
    self.lastRecordedRacePoints = amountAwarded
end 

function Participant:moveToPoint(pointCFrame)
    self.characterObject:WaitForChild("HumanoidRootPart").CFrame = pointCFrame + Vector3.new(0,2,0)
    self.lastTeleportedLocation = pointCFrame
end 

function Participant:updateStanding(newStanding)
    self.currentStanding = newStanding
end 

function Participant:finishedRace(placement)
    if not self.playerObject then return end
    self.lastRecordedRaceStanding = placement
    PlayerFinishedRace:FireClient(self.playerObject,placement)
end 

function Participant:changeMoveSpeed(newSpeed) 
    if not self.characterObject then return end
    local humanoid = self.characterObject:WaitForChild("Humanoid")
    humanoid.WalkSpeed = newSpeed
end 

function Participant:Destroy()
    self = nil
end 

return Participant