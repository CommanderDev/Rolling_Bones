local ContentProvider = game:GetService("ContentProvider")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")

--[[
    Author: Dev0mar

    Description: Loads all the game's music into play lists

    API:

    [Void] MusicHandler.initialize(Instance music)

    [Void] MusicHandler.Play(String playlistName [, (Optional) Table config])
        Configurations:
            - [Boolean] canLoop (Default: false)
            - [Boolean] yielding (Default: false)
            - [[Void] Function] onTrackFinished

    [Void] MusicHandler.Stop()

    [Void] MusicHandler.setVolume(Number newVolume [, (Optional) Boolean canTween])

    [Number] MusicHandler.getTrackTimeLeft()

    [Table] MusicHandler.getPlaylist(String playlistName)
        Properties:
        [Boolean] isLoaded
        [Boolean] isPlaying
        [Number] volume
        [Table<number>] loadPending
        [Table<Instance>] list
        [Instance] currentTrack
        [Instance] soundGroup
        [Function] load
]]

local MusicHandler = {}

local Main = require(ReplicatedStorage.CloudFrameShared.Main)
local Logger = Main.loadLibrary("Logger").new(script.Name,true)

local isInitialized = false

local gamePlayLists = {}
local currentPlaylist

local fadeTweenInfo = TweenInfo.new(2,Enum.EasingStyle.Linear,Enum.EasingDirection.Out)

local pendingSounds = {} -- sounds that are currently preloading

local musicGroup = Instance.new("SoundGroup")
musicGroup.Name = "GameMusic"
musicGroup.Parent = SoundService

function startRandomSongFromPlaylist(playlist, config)
    
    local playlistSong = playlist.list[math.random(#playlist.list)]
    playlist.soundGroup.Volume = 0
    local tween = TweenService:Create(playlist.soundGroup, fadeTweenInfo, {Volume = playlist.volume})
    playlist.currentTrack = playlistSong
    playlist.currentTrackConnection = playlistSong.Ended:Connect(function()
        playlist.currentTrackConnection:Disconnect()
        if config.onTrackFinished then
            if typeof(config.onTrackFinished) == "function" then
                config:onTrackFinished()
            else
                Logger:warn("attempt to run onTrackFinished, Function expected, got [ " .. typeof(config.onTrackFinished) .. " ]")
            end
        end
        if config.canLoop then
            startRandomSongFromPlaylist(playlist, config)
        end
    end)
    playlistSong:Play()
    tween:Play()
    playlist.isPlaying = true
end

function handlePreload(contentId, status)
    if Enum.AssetFetchStatus.Success == status then
        local pending = pendingSounds[contentId]
        if pending then
            for index = 1, #pending.playlists do
                local playlist = gamePlayLists[pending.playlists[index]]
                local sound = ((index == #pending.playlists and pending.object) or pending.object:Clone())
                sound.SoundGroup = playlist.soundGroup
                sound.Parent = playlist.soundGroup
                table.insert(playlist.list, sound)

                local idPosition = table.find(playlist.loadPending, contentId)
                if idPosition then
                    table.remove(playlist.loadPending, idPosition)

                    if #playlist.loadPending == 0 then
                        playlist.isLoaded = true
                    end
                end
            end

            pending.object = nil
            pending.playlists = nil
            pending = nil
        end
    else
        Logger:warn("Failed to load music of id [ " .. contentId .. " ]")
    end
end

function MusicHandler.getPlaylist(playlistName)
    assert(isInitialized == true, "[MusicHandler Error] Cannot get playlist, MusicHanlder has not been initialized")
    assert(typeof(playlistName) == "string", "[MusicHandler Error] can't get playlist, Invalid first argument string expected, got [ " .. typeof(playlistName) .. " ]")
    return gamePlayLists[playlistName]
end

function MusicHandler.Play(playlistName, config)
    assert(isInitialized == true, "[MusicHandler Error] Cannot play music, MusicHanlder has not been initialized")
    local argType = typeof(playlistName)
        assert(argType == "string", "[MusicHandler Warning] Failed to play, Invalid first arguement, string expected got [ " .. argType .. " ]")
    if config then
        assert(typeof(config) == "table", "[MusicHandler Warning] Failed to play, Invalid second arguement, table expected got [ " .. typeof(config) .. " ]")
    end
    config = config or {
        canLoop = false,
        yielding = false,
    }
    local selectedList = gamePlayLists[playlistName]
    if selectedList then
        if not currentPlaylist or currentPlaylist ~= playlistName then
            if currentPlaylist then
                local previousPlaylist = gamePlayLists[currentPlaylist]
                if previousPlaylist.currentTrackConnection then
                    previousPlaylist.currentTrackConnection:Disconnect()
                end
                previousPlaylist.currentTrackConnection = nil
                previousPlaylist.currentTrack = nil
            end
            currentPlaylist = playlistName
            if not selectedList.isLoaded then
                coroutine.wrap(function()
                    selectedList:load()
                end)()
            end
            if not config.yeilding then
                coroutine.wrap(function()
                    startRandomSongFromPlaylist(selectedList, config)
                end)()
            else
                startRandomSongFromPlaylist(selectedList, config)
            end
        end
    else
        Logger:warn("[MusicHandler Warning] Unable to play playlist with name [ " .. tostring(playlistName) .. " ]")
        return false
    end
end

function MusicHandler.setVolume(newVolume, canTween)
    assert(isInitialized == true, "[MusicHandler Error] Cannot set volume, MusicHanlder has not been initialized")
    assert(typeof(newVolume) == "number", "[MusicHandler Error] Invalid first argument, attempting to set volume, number expected got [ " .. typeof(newVolume) .. " ]")
    canTween = canTween or false
    if currentPlaylist then
        local list = gamePlayLists[currentPlaylist]
        if list.volume ~= newVolume and newVolume >= 0 then
            list.volume = newVolume
            if canTween then
                local tween = TweenService:Create(list.soundGroup, fadeTweenInfo, {Volume = newVolume})
                tween:Play()
            else
                list.soundGroup.Volume = newVolume
            end
        end
    else
        Logger:warn("[MusicHandler Warning] Attempt to set music volume while no music being played")
        return false
    end
end

function MusicHandler.getTrackTimeLeft()
    assert(isInitialized == true, "[MusicHandler Error] Cannot get track time left, MusicHanlder has not been initialized")
    local timeLeft = 0
    if currentPlaylist then
        local list = gamePlayLists[currentPlaylist]
        if list.currentTrack then
            timeLeft = list.currentTrack.TimeLength - list.currentTrack.TimePosition
        end
    end
    return timeLeft
end

function MusicHandler.Stop()
    assert(isInitialized == true, "[MusicHandler Error] Attempt to stop music, MusicHanlder has not been initialized")
    if currentPlaylist then
        local list = gamePlayLists[currentPlaylist]
        if list.currentTrackConnection then
            list.currentTrackConnection:Disconnect()
        end
        list.currentTrackConnection = nil
        if list.currentTrack and list.currentTrack:IsA("Sound") then
            list.currentTrack:Stop()
        end
        list.currentTrack = nil
        list.isPlaying = false
        currentPlaylist = nil
    end
end

local canInitialize = true
function MusicHandler.initialize(music)
    assert(typeof(music) == "Instance", "[MusicHandler Error] Cannot initialize, Invalid first argument, instance expected got [ " .. typeof(music) .. " ]")
    if not isInitialized and canInitialize then
        canInitialize = false
        local firstSounds = {} -- to preload first sound of every playlist

        for _, playlistModule in ipairs(music:GetChildren()) do
            local list = require(playlistModule)
            if typeof(list) == "table" then
                gamePlayLists[playlistModule.Name] = {
                    isLoaded = false,
                    isPlaying = false,
                    volume = 0,
                    currentTrack = nil,
                    soundGroup = nil,
                    loadPending = {},
                    list = {},
                    load = function(self)
                        if #self.loadPending > 0 then
                            local assetsToLoad = {}
                            for index = 1, #self.loadPending do
                                assetsToLoad[index] = Instance.new("Sound")
                                assetsToLoad[index].SoundId = "rbxassetid://" .. self.loadPending[index]
                                if not pendingSounds[self.loadPending[index].SoundId] then
                                    pendingSounds[self.loadPending[index].SoundId] = {
                                        object = assetsToLoad[index],
                                        playlists = {}
                                    }
                                end
                                table.insert(pendingSounds[self.loadPending[index].SoundId].playlists, playlistModule.Name)
                            end
                            ContentProvider:PreloadAsync(assetsToLoad, handlePreload)
                        else
                            self.isLoaded = true
                        end
                    end
                }
                local cacheReference = gamePlayLists[playlistModule.Name]

                cacheReference.soundGroup = Instance.new("SoundGroup")
                cacheReference.soundGroup.Name = playlistModule.Name
                cacheReference.soundGroup.Volume = 0
                cacheReference.soundGroup.Parent = musicGroup

                cacheReference.loadPending = table.create(#list, 0)
                for index, soundID in ipairs(list) do
                    cacheReference.loadPending[index] = "rbxassetid://" .. soundID
                end
                
                local newID = #firstSounds+1
                firstSounds[newID] = Instance.new("Sound")
                firstSounds[newID].SoundId = "rbxassetid://" .. list[1]
                if not pendingSounds[firstSounds[newID].SoundId] then
                    pendingSounds[firstSounds[newID].SoundId] = {
                        object = firstSounds[newID],
                        playlists = {}
                    }
                end
                table.insert(pendingSounds[firstSounds[newID].SoundId].playlists, playlistModule.Name)
            else
                Logger:warn("Attempt to load playlist [ " .. playlistModule.Name .. " ] module returned invalid data, table required got [ " .. typeof(list) .. " ]")
            end
        end

        ContentProvider:PreloadAsync(firstSounds, handlePreload)
        firstSounds = {}
        isInitialized = true
    end
end

return MusicHandler