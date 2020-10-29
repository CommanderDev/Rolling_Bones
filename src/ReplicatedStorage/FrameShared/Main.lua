
local RunService = game:GetService("RunService")
local MainModule

if RunService:IsServer() then
	MainModule = game.ServerScriptService.FrameServer.Main
else
	local playerScripts = game.Players.LocalPlayer:WaitForChild("PlayerScripts")
	MainModule = playerScripts:WaitForChild("FrameClient"):WaitForChild("Main")
end

return require(MainModule)