--[[
    Author: NotSoNorm
    Description: Manages printing for easy enabling and disabling

    Parameters:
    
        Logger.new(script.Name): Creates new print class
            PrintObject:log():  Prints in output
            PrintObject:warn(): Warns in output

            PrintObject.Enabled: Enables or disables prints from being outputted under that class

    Example:
        local Logger = Server.loadLibrary("Logger")
        local logger = Logger.new(script.Name)

        logger:log("byonk byonk","byooooa wkkkk", "Alphabet soup!!!!", false, true, nil)

--]]


-- Services


-- Set up

local RunService = game:GetService("RunService")
local Class = require(script.Parent.Class)
local Logger  = Class.new()

local Location = false
if RunService:IsServer() then
    Location = require(game.ServerScriptService.CloudFrameServer.Main)
else 
    local Player = game.Players.LocalPlayer
    Location = require(Player.PlayerScripts:WaitForChild("CloudFrameClient",1):WaitForChild("Main",1))
end

-- Settings
local GLOBAL_PRINTS_ENABLED = true
local PRINT_BLACKLIST = {

}

function Logger.new(name,enabled)
    local self = {}
    self.Name = name
    self.Enabled = table.find(PRINT_BLACKLIST,name) == nil and GLOBAL_PRINTS_ENABLED == true and enabled~=false
    self.Track = false
    self.Trace = function()
        return debug.traceback(nil, 3)
    end
    setmetatable(self, Logger)

    return self
end


function Logger:log(...)
    if not self.Enabled then return end
    local args = table.pack(...)
    for _,v in pairs (args) do
        print(v)
    end
    if self.Track then
        local Debug = Location.loadLibrary("Debug")
        if RunService:IsServer() then
			--player, message, trace, scriptName, exceptionType, eventLevel
            Debug:fire(false, args, self.Trace(), self.Name, "ServerInfo", "Info")
        else 
            Debug:fire(args, self.Trace(), self.Name, "ClientInfo", "Info")
        end
    end
end

function Logger:warn(...)
    if not self.Enabled then return end
    local args = table.pack(...)
    for _,v in pairs (args) do 
        warn(v)
    end
    if self.Track then
        local Debug = Location.loadLibrary("Debug")
        if RunService:IsServer() then
            Debug:fire(false, args, self.Trace(), self.Name, "ServerWarn", "Warning")
        else 
            Debug:fire(args, self.Trace(), self.Name, "ClientWarn", "Warning")
        end
    end
end

return Logger

--https://raw.githubusercontent.com/Cloud-Entertainment/CloudFrame-2.0-Plugins/master/default.project.json
-- local HttpService = game:GetService("HttpService")

-- local data = HttpService:RequestAsync(
-- 		{
-- 			Url = "https://raw.githubusercontent.com/Cloud-Entertainment/CloudFrame-2.0-Plugins/master/default.project.json", 
-- 			Method = "GET",
-- 			Headers = {
-- 				['Accept'] = "application/vnd.github.v3+json",
-- 				["Authorization"] = "token 0af8fb781901b4476cf16eb5c98caaebf9ddd6c9"  
-- 			},
			
-- 		}
-- )

-- print(data.Body)