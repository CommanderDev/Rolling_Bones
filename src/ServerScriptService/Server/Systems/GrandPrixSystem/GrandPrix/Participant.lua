local Main = require(game.ServerScriptService.FrameServer.Main)
local Ragdoll = require(game.ServerScriptService.Server.Systems.Ragdoll.Ragdoll)

local PlayerFinishedRace = Main.getDataStream("PlayerFinishedRace", "RemoteEvent")

local Class = Main.loadLibrary("Class")
local Signal = Main.loadLibrary("Signal")
local Deactivate = game.ServerScriptService.Server.Systems.Ragdoll.Deactivate

local Participant = Class.new()

Participant.changeWalkSpeedSignals = {}
Participant.updateTimer = Signal.new()
Participant.toggleTimerVisible = Signal.new()

function Participant.new(playerObject)
    local self = setmetatable({}, Participant)
    self.playerObject = playerObject
    self.amountOfPoints = 0
    self.lastRecordedRaceStanding = false
    self.lastRecordedRacePoints = false
    self.lastRecordedRaceTime = false 

    self.currentStanding = 0; 
    self.characterObject = playerObject.Character or playerObject.CharacterAdded:Wait()
    self.lastTeleportedLocation = nil 
    self:handleTimer()
    return self 
end 

function Participant:handleTimer()
    local playerGui = self.playerObject:WaitForChild("PlayerGui")
    local interface = playerGui:WaitForChild("Interface")
    local RaceTimerLabel = interface:WaitForChild("RaceTimerLabel")
    Participant.updateTimer:connect(function(minutes, seconds, miliseconds)
        RaceTimerLabel.Text = ("%02d:%02d:%02d"):format(minutes, seconds, miliseconds)
    end)

    Participant.toggleTimerVisible:connect(function(isVisible)
        local playerGui = self.playerObject:WaitForChild("PlayerGui")
        local interface = playerGui:WaitForChild("Interface")
        local RaceTimerLabel = interface:WaitForChild("RaceTimerLabel")
        RaceTimerLabel.Visible = isVisible
    end)
end 


function Participant:awardPoints(amountAwarded)
    print(self.playerObject.Name, " Awarded ", amountAwarded, " points!")
    self.amountOfPoints += amountAwarded
    self.lastRecordedRacePoints = amountAwarded
end 

function Participant:moveToPoint(pointCFrame, endOfRace)
    if endOfRace then
        self:deactivateRagdoll()
        print(self.characterObject)
        self.characterObject:SetPrimaryPartCFrame(pointCFrame + Vector3.new(0,2.5,0))
        self.lastTeleportedLocation = pointCFrame
    else
        self:deactivateRagdoll()
        print(self.characterObject)
        self.characterObject:SetPrimaryPartCFrame(pointCFrame + Vector3.new(0,2.5,0))
        self.lastTeleportedLocation = pointCFrame
        self:activateRagdoll()
    end
    
end 

function Participant:updateStanding(newStanding)
    self.currentStanding = newStanding
end 

function Participant:finishedRace(placement, minutes, seconds, miliseconds)
    if not self.playerObject then return end
    self.lastRecordedRaceStanding = placement
    self.lastRecordedRaceTime = {
        minutes = minutes; 
        seconds = seconds;
        miliseconds = miliseconds
    }
    PlayerFinishedRace:FireClient(self.playerObject,placement)
end 

function Participant:raceStarted()
    self.lastRecordedRaceStanding = false 
    self.lastRecordedRacePoints = false 
    self.lastRecordedRaceTime = false
end 

function Participant:changeMoveSpeed(newSpeed) 
    if not self.characterObject then return end
    local humanoid = self.characterObject:WaitForChild("Humanoid")
    humanoid.WalkSpeed = newSpeed
end 

function Participant:activateRagdoll()
    Ragdoll:Activate(self.playerObject.Character)
end

function Participant:deactivateRagdoll()
    Deactivate:Fire(self.playerObject)
end

function Participant:Destroy()
    --self = nil
end 

return Participant