--[[
    Author: TechSpectrum
    Description: Http Handler
--]]
local Http = {}

local HttpService = game:GetService("HttpService")
local Server = require(game.ServerScriptService.CloudFrameServer.Main)
local Promise = Server.loadLibrary("Promise")
local Logger = Server.loadLibrary("Logger")
local logger = Logger.new(script.Name)

function Http:post(url, data)
	data = data and HttpService:JSONEncode(data) or {}
	return Promise.new(function(resolve, reject)
		local ok, result = pcall(HttpService.PostAsync, HttpService, url, data)

		if ok then
			result = HttpService:JSONDecode(result)
			resolve(result)
		else
			reject(result)
		end
	end)
end

function Http:get(url)
	return Promise.new(function(resolve, reject)
		local ok, result = pcall(HttpService.GetAsync, HttpService, url)

		if ok then
			result = HttpService:JSONDecode(result)
			resolve(result)
		else
			reject(result)
		end
	end)
end

return Http