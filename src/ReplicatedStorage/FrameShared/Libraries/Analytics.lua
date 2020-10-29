--[[
    Author: TechSpectrum
    Description: Analytics Service


    To make use of this module; look at the Fire function!
--]]



local RunService = game:GetService("RunService")



local Analytics = {}

if RunService:IsServer() then
    local Server = require(game.ServerScriptService.CloudFrameServer.Main)
    local Http = Server.loadLibrary("Http")
    local HttpService = game:GetService("HttpService")
    local Event = Server.getDataStream("Analytics", "RemoteEvent")
    local Credentials = require(game.ServerScriptService.CloudFrameServer.Credentials)
    local realmAppUrl = Credentials.syncLiveOps
    --[[
        Description: Send data to server.

        Parameters:
            collection [string]: The category of the analytics data
            data [table]: Data being stored for analytics.
            (optional) id [mixed]: Used to update a specific document.
    --]]

    local function logData(collection, data, id)
        if id then 
            data.id = id
        else
            data.id = HttpService:GenerateGUID(false)
        end
		return Http:post(realmAppUrl.."?database=fishing-simulator-analytics&collection="..collection, data)
	end
    
    --[[
        Description: Catch data being sent from Client to Server.

        Parameters:
            player [Instance]: The Client Player object.
            collection [string]: The category of the analytics data
            data [table]: Data being stored for analytics.
            (optional) id [mixed]: Used to update a specific document.
    --]]

    Event.OnServerEvent:Connect(function(player, collection, data, id)
        data.accountAge = player.AccountAge -- Number
        data.followedFriend = player.FollowUserId ~= 0 or false -- Number
        data.localeId = player.LocaleId -- String
        data.premium = player.MembershipType == Enum.MembershipType.Premium or false
        data.username = player.Name
        data.userId = player.UserId
		logData(collection, data, id)
	end)

    --[[
        Description: Log analytics data -- Server Side

        Parameters:
            collection [string]: The category of the analytics data
            data [table]: Data being stored for analytics.
            (optional) id [mixed]: Used to update a specific document.
    --]]

    function Analytics:fire(collection, data, id)
        return logData(collection, data, id)
    end
end

if RunService:IsClient() then
    local Player = game.Players.LocalPlayer
    local Client = require(Player.PlayerScripts:WaitForChild("CloudFrameClient",1):WaitForChild("Main",1))
    local UserInputService = game:GetService("UserInputService")
    local GuiService = game:GetService("GuiService")
    local Event = Client.getDataStream("Analytics", "RemoteEvent")

    --[[
        Description: Log analytics data -- Client Side

        Parameters:
            collection [string]: The category of the analytics data
            data [table]: Data being stored for analytics.
            (optional) id [mixed]: Used to update a specific document.
    --]]

    function Analytics:fire(collection, data, id)
        local keyboardEnabled = (UserInputService.KeyboardEnabled)
        local gamepadEnabled = (UserInputService.GamepadEnabled)
        local mouseEnabled = (UserInputService.MouseEnabled)
        local touchEnabled = (UserInputService.TouchEnabled)
        data.xbox = GuiService:IsTenFootInterface()
        data.mobile = touchEnabled and not keyboardEnabled
        data.pc = keyboardEnabled and mouseEnabled
        data.gamepad = gamepadEnabled
        data.touch = touchEnabled

		Event:FireServer(collection, data, id)
    end
end

return Analytics