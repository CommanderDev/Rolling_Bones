local ReplicatedStorage = game:GetService("ReplicatedStorage")

--[[
    Author: Dev0mar

    Description: Hooks up game's music to the MusicHandler module
]]

local MusicPlayer = {}

local Main = require(ReplicatedStorage.CloudFrameShared.Main)
local MusicHandler = Main.loadLibrary("MusicHandler")

function MusicPlayer.init()
    local myMusic = script:WaitForChild("Music")
    MusicHandler.initialize(myMusic)
end

return MusicPlayer