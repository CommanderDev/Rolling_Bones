--[[
    Author: TechSpectrum & Isosta
    Description: Marketplace Service


    To make use of this module; look at the logPurchase function!
--]]



local RunService = game:GetService("RunService")
local Marketplace = {}

if RunService:IsServer() then
    local Server = require(game.ServerScriptService.CloudFrameServer.Main)
    local Http = Server.loadLibrary("Http")
    local HttpService = game:GetService("HttpService")
    local Event = Server.getDataStream("Marketplace", "RemoteEvent")
    local MarketplaceService = game:GetService("MarketplaceService")
    local Credentials = require(game.ServerScriptService.CloudFrameServer.Credentials)
    local realmAppUrl = Credentials.syncLiveOps
    --[[
        Description: Send data to server.

        Parameters:
            
    --]]

    local function logPurchase(collection, data)
        data.id = HttpService:GenerateGUID(false)
		return Http:post(realmAppUrl.."?database=fishing-simulator-purchases&collection="..collection, data)
	end
    
    --[[
        Description: Catch data being sent from Client to Server.

        Parameters:
   
    --]]

    Event.OnServerEvent:Connect(function(player, collection, data)
        data.accountAge = player.AccountAge -- Number
        data.followedFriend = player.FollowUserId ~= 0 or false -- Number
        data.localeId = player.LocaleId -- String
        data.premium = player.MembershipType == Enum.MembershipType.Premium or false
        data.username = player.Name
        data.userId = player.UserId
		logPurchase(collection, data)
	end)

    --[[
        Description: Log purchases data -- Server Side

        Parameters:
            
    --]]

    function Marketplace:purchase(collection, data)
        return logPurchase(collection, data)
    end
end

if RunService:IsClient() then
    local Player = game.Players.LocalPlayer
    local Client = require(Player.PlayerScripts:WaitForChild("CloudFrameClient",1):WaitForChild("Main",1))
    local UserInputService = game:GetService("UserInputService")
    local GuiService = game:GetService("GuiService")
    local Event = Client.getDataStream("Analytics", "RemoteEvent")

    --[[
        Description: Log purchases data -- Client Side

        Parameters:
            
            
    --]]


    function Marketplace:purchase(collection, data)
		Event:FireServer(collection, data)
    end
end

return Marketplace