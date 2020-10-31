--[[
	DEFAULT DESPAWN TYPES:
	1 = Fade
	2 = Delete
	"Random" = Random
	
	Want to make your own? Check out the DevForum post here: https://devforum.roblox.com/t/tom-atoes-customisable-ragdoll/259927
--]]

local Settings = {
	["DEFAULTCONSTRAINT"] = "BallSocketConstraint";
	["DEFAULTDESPAWNTIME"] = 5;
	["CANRECOVER"] = false;
	["DESPAWNENABLED"] = false;
	["MIN"] = -90;
	["MAX"] = 90;
	["RES"] = 0;
	["LIMITSENABLED"] = true;
	["DESPAWNTYPE"] = "Random";
	["EVENTLOCATION"] = game:GetService("ReplicatedStorage").Physics;
	["ENDEVENTLOCATION"] = game.ServerScriptService.Server.Systems.Ragdoll.Deactivate;
}

return Settings
