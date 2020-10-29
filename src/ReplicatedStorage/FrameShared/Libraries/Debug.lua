--[[
    Author: TechSpectrum
    Description: Error Tracking Service


    To make use of this module; look at the Fire function!
--]]


local RunService = game:GetService("RunService")
local ScriptContext = game:GetService("ScriptContext")
local LogService = game:GetService("LogService")
local Sentry = require(script.Parent.Sentry)

local Debug = {}

if RunService:IsServer() then
    local Server = require(game.ServerScriptService.CloudFrameServer.Main)
    local Http = Server.loadLibrary("Http")
    local HttpService = game:GetService("HttpService")
    local ClientDebugEvent = Server.getDataStream("ClientDebug", "RemoteEvent")
    local SharedDebugEvent = Server.getDataStream("SharedDebug", "RemoteEvent")
    local Credentials = require(game.ServerScriptService.CloudFrameServer.Credentials)
    local sentryClient = Sentry:Client(Credentials.sentryToken)
    sentryClient:ConnectRemoteEvent(ClientDebugEvent)

    function Debug:fire( player, message, trace, scriptName, exceptionType, eventLevel )
		if not scriptName or scriptName == "None" then return end
        local options = {
            logger = "server", 
            tags = {
                game_version = game.PlaceVersion,
                server_id = game.JobId,
                script = scriptName
            },
            environment = "test",
        }

        if (player) then
            options.user = {}
            options.user.id = player.UserId
            options.user.username = player.Name
            options.logger = "client"
        end
        sentryClient:SendException(exceptionType, message, trace, options, eventLevel)
    end

    ScriptContext.Error:Connect(function( message, trace, myScript )
        local scriptName = myScript and myScript.Name or "None"
        if not scriptName then return end
        Debug:fire(false, message, trace, scriptName, Sentry.ExceptionType.Server, Sentry.EventLevel.Error)
    end)

    SharedDebugEvent.OnServerEvent:Connect(function( player, msgArgs, trace, scriptName, exceptionType, eventLevel )
        --msgArgs
        local message = HttpService:JSONEncode(msgArgs)
        Debug:fire(player, message, trace, scriptName, exceptionType, Sentry.EventLevel[eventLevel])
    end)

end

if RunService:IsClient() then
    local Player = game.Players.LocalPlayer
    local UserInputService = game:GetService("UserInputService")
    local Client = require(Player.PlayerScripts:WaitForChild("CloudFrameClient",1):WaitForChild("Main",1))
    local GuiService = game:GetService("GuiService")
    local ClientDebugEvent = Client.getDataStream("ClientDebug", "RemoteEvent")
    local SharedDebugEvent = Client.getDataStream("SharedDebug", "RemoteEvent")
    -- LogService.MessageOut:Connect(function(message, type)
    --     client:SendException(sentryClient.ExceptionType.Server, message, debug.traceback(), options)
    -- end)
    function Debug:fire(msgArgs, trace, scriptName, exceptionType, eventLevel)
        SharedDebugEvent:FireServer(msgArgs, trace, scriptName, exceptionType, eventLevel)
    end

    ScriptContext.Error:Connect(function( message, trace, myScript )
        local scriptName = myScript and myScript.Name or "None"
        if not scriptName or scriptName == "None" then return end
        local options = {
            logger = "client", 
            tags = {
                game_version = game.PlaceVersion,
                server_id = game.JobId,
                script = scriptName
            },
            environment = "test",
            user = {id = Player.UserId, username = Player.Name}
        }

        local keyboardEnabled = (UserInputService.KeyboardEnabled)
        local gamepadEnabled = (UserInputService.GamepadEnabled)
        local mouseEnabled = (UserInputService.MouseEnabled)
        local touchEnabled = (UserInputService.TouchEnabled)
        options.tags.xbox = GuiService:IsTenFootInterface()
        options.tags.mobile = touchEnabled and not keyboardEnabled
        options.tags.pc = keyboardEnabled and mouseEnabled
        options.tags.gamepad = gamepadEnabled
        options.tags.touch = touchEnabled

        ClientDebugEvent:FireServer(message, debug.traceback(), options)
    
    end)

end

return Debug