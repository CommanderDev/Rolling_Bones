--[[
	Tom_atoes
	Ragdoll Module - 30/03/19
	Tutorial: https://devforum.roblox.com/t/tom-atoes-customisable-ragdoll/259927
--]]

local PhysicsService = game:GetService("PhysicsService")
local Players = game:GetService("Players")

local SettingsModule = require(script.Settings)
local DespawnTypesModule = require(script.DespawnTypes)

local Ragdoll = {}
Ragdoll._index = Ragdoll

local playerCollisionGroupName = "PlayersForRagdollByTomatoes"
local HRPCollisionGroupName = "HRPForRagdoll"

PhysicsService:RemoveCollisionGroup(HRPCollisionGroupName)
PhysicsService:RemoveCollisionGroup(playerCollisionGroupName)

PhysicsService:CreateCollisionGroup(playerCollisionGroupName)

PhysicsService:CreateCollisionGroup(HRPCollisionGroupName)

PhysicsService:CollisionGroupSetCollidable(playerCollisionGroupName, HRPCollisionGroupName, false)

function Ragdoll.Activate(self, Model, DespawnTime, Constraint, CanDespawn, CanRecover, LimitsEnabled, DespawnType)
	
	if not Model then
		warn("[RAGDOLL]: Argument 1 (Model) not provided.")
		return
	end
	
	self.Player = Players:GetPlayerFromCharacter(Model);
	self.Model = Model;
	self.Humanoid = Model.Humanoid;
	self.DespawnTime = DespawnTime or SettingsModule["DEFAULTDESPAWNTIME"];
	self.Constraint = Constraint or SettingsModule["DEFAULTCONSTRAINT"];
	self.CanDespawn = CanDespawn or SettingsModule["DESPAWNENABLED"];
	self.CanRecover = CanRecover or SettingsModule["CANRECOVER"];
	self.LimitsEnabled = LimitsEnabled or SettingsModule["LIMITSENABLED"];
	self.DespawnType = DespawnType or SettingsModule["DESPAWNTYPE"];
	
	DetectRig(self) 
end

function Ragdoll.Deactivate(self, Model)
	if not Model then
		warn("[RAGDOLL]: Argument 1 (Model) not provided.")
		return
	end
	
	self.Player = Players:GetPlayerFromCharacter(Model);
	self.Model = Model;
	self.Humanoid = Model.Humanoid;
	
	self.Player:LoadCharacter()
	--self.Humanoid:BuildRigFromAttachments()
	--if self.Player then
		--SettingsModule.EVENTLOCATION:FireClient(self.Player, self.Model, self.Humanoid, self.Player, true)
	--end
end

function DetectRig(self)
	if self.Humanoid.RigType == Enum.HumanoidRigType.R6 then
		local NewAttachmentRight = Instance.new("Attachment")
		NewAttachmentRight.Parent = self.Model["Right Leg"]
		NewAttachmentRight.Name = "RagdollAttachment"
		NewAttachmentRight.Position = Vector3.new(0, 1, 0)
		
		local NewAttachmentLeft = Instance.new("Attachment")
		NewAttachmentLeft.Parent = self.Model["Left Leg"]
		NewAttachmentLeft.Name = "RagdollAttachment"
		NewAttachmentLeft.Position = Vector3.new(0, 1, 0)
		
		local WaistLeftAttachment = Instance.new("Attachment")
		WaistLeftAttachment.Parent = self.Model.Torso
		WaistLeftAttachment.Name = "WaistLeftAttachment"
		WaistLeftAttachment.Position = Vector3.new(-0.5, -1, 0)
		
		local WaistRightAttachment = Instance.new("Attachment")
		WaistRightAttachment.Parent = self.Model.Torso
		WaistRightAttachment.Name = "WaistRightAttachment"
		WaistRightAttachment.Position = Vector3.new(0.5, -1, 0)
		
		self.Parts = {
			["Right Arm"] = {self.Model.Torso.RightCollarAttachment, self.Model["Right Arm"].RightShoulderAttachment},
			["Left Arm"] = {self.Model.Torso.LeftCollarAttachment, self.Model["Left Arm"].LeftShoulderAttachment},
			["Head"] = {self.Model.Torso.NeckAttachment, self.Model.Head.FaceCenterAttachment},
			["Left Leg"] = {WaistLeftAttachment, NewAttachmentLeft},
			["Right Leg"] = {WaistRightAttachment, NewAttachmentRight},
			["HumanoidRootPart"] = {self.Model.HumanoidRootPart.RootAttachment, self.Model.Torso.BodyFrontAttachment}
		};
		
		RagdollModel(self)
	elseif self.Humanoid.RigType == Enum.HumanoidRigType.R15 then
		self.Parts = {
			["Head"] = {self.Model.UpperTorso.NeckRigAttachment, self.Model.Head.NeckRigAttachment},
	        ["LowerTorso"] = {self.Model.UpperTorso.WaistRigAttachment, self.Model.LowerTorso.RootRigAttachment},
	        
	        ["LeftUpperArm"] = {self.Model.UpperTorso.LeftShoulderRigAttachment, self.Model.LeftUpperArm.LeftShoulderRigAttachment},
	        ["LeftLowerArm"] = {self.Model.LeftUpperArm.LeftElbowRigAttachment, self.Model.LeftLowerArm.LeftElbowRigAttachment},
	        ["LeftHand"] = {self.Model.LeftLowerArm.LeftWristRigAttachment, self.Model.LeftHand.LeftWristRigAttachment},
	        
	        ["RightUpperArm"] = {self.Model.UpperTorso.RightShoulderRigAttachment, self.Model.RightUpperArm.RightShoulderRigAttachment},
	        ["RightLowerArm"] = {self.Model.RightUpperArm.RightElbowRigAttachment, self.Model.RightLowerArm.RightElbowRigAttachment},
	        ["RightHand"] = {self.Model.RightLowerArm.RightWristRigAttachment, self.Model.RightHand.RightWristRigAttachment},
	        
	        ["LeftUpperLeg"] = {self.Model.LowerTorso.LeftHipRigAttachment, self.Model.LeftUpperLeg.LeftHipRigAttachment},
	        ["LeftLowerLeg"] = {self.Model.LeftUpperLeg.LeftKneeRigAttachment, self.Model.LeftLowerLeg.LeftKneeRigAttachment},
	        ["LeftFoot"] = {self.Model.LeftLowerLeg.LeftAnkleRigAttachment, self.Model.LeftFoot.LeftAnkleRigAttachment},
	       
	        ["RightUpperLeg"] = {self.Model.LowerTorso.RightHipRigAttachment, self.Model.RightUpperLeg.RightHipRigAttachment},
	        ["RightLowerLeg"] = {self.Model.RightUpperLeg.RightKneeRigAttachment, self.Model.RightLowerLeg.RightKneeRigAttachment},
	        ["RightFoot"] = {self.Model.RightLowerLeg.RightAnkleRigAttachment, self.Model.RightFoot.RightAnkleRigAttachment},
		};
		
		RagdollModel(self)
	end
end

function RagdollModel(self)
	
	if self.Player then
		SettingsModule.EVENTLOCATION:FireClient(self.Player, self.Model, self.Humanoid, self.Player, false)
	else
		SettingsModule.EVENTLOCATION:FireAllClients(self.Model, self.Humanoid, self.Player, false)
	end
	
	PhysicsService:SetPartCollisionGroup(self.Model.HumanoidRootPart, HRPCollisionGroupName)
	
	for i, v in pairs(self.Model:GetChildren()) do
		if v:IsA("BasePart") and v.Name ~= "HumanoidRootPart" then
			PhysicsService:SetPartCollisionGroup(v, playerCollisionGroupName)
		end
	end
	
	local WeldConstraint = Instance.new("WeldConstraint")
	WeldConstraint.Part0 = self.Model.PrimaryPart
	WeldConstraint.Part1 = self.Model.UpperTorso
	WeldConstraint.Parent = self.Model.PrimaryPart
	
	for i, v in pairs(self.Parts) do
		local Part = self.Model:FindFirstChild(i)
		if Part then
			local Constraint = Instance.new(self.Constraint)
			Constraint.Parent = Part
			if Constraint:IsA("WeldConstraint") then
				Constraint.Part0 = v[1].Parent
				Constraint.Part1 = v[2].Parent	
			elseif not Constraint:IsA("WeldConstraint") then
				if self.LimitsEnabled then
					Constraint.LimitsEnabled = true
					if Constraint:IsA("HingeConstraint") then
						Constraint.LowerAngle = SettingsModule["MIN"]
						Constraint.UpperAngle = SettingsModule["MAX"]
						Constraint.Restitution = SettingsModule["RES"]
					elseif Constraint:IsA("BallSocketConstraint") then
						Constraint.TwistLimitsEnabled = true
						Constraint.UpperAngle = SettingsModule["MAX"]
						Constraint.TwistLowerAngle = SettingsModule["MIN"]
						Constraint.TwistUpperAngle = SettingsModule["MAX"]
						Constraint.Restitution = SettingsModule["RES"]
					end
				end
				Constraint.Attachment0 = v[1]
				Constraint.Attachment1 = v[2]
			end
		end
	end
	
	for i, v in pairs(self.Model:GetDescendants()) do
		if v:IsA("Motor6D") then
			v:Destroy()
		end
	end
	
	if self.CanDespawn then
		DespawnTypesModule.GetInfo(self.DespawnType)(self.Model, self.DespawnTime)
		wait(0.5)
		if self.Player then
			self.Player:LoadCharacter()
		end
		return
	end
	if self.CanRecover then
		wait(self.DespawnTime)
		self.Humanoid:BuildRigFromAttachments()
		if self.Player then
			SettingsModule.EVENTLOCATION:FireClient(self.Player, self.Model, self.Humanoid, self.Player, true)
		end
		return
	end
end

return Ragdoll
