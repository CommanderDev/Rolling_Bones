--[[
    Author: Spynaz
    Description: Cloudframe 2.0 server module

    Quick API ref:
    loadLibrary(string name)
    require(string name)
    getPath(Insatnce origin, string path)
    getDataStream(string name, string className)
    isDataStreamRateOk(Instance dataStream, number rate, Instance player)
--]]

local Server = {}

local sharedFolder = game.ReplicatedStorage.CloudFrameShared
local sharedLibraries = sharedFolder.Libraries
local serverLibraries = script.Parent.Libraries

local Misc = require(sharedLibraries.Misc)

local moduleCache = {}

function addToModuleCache(target)
    for index,module in pairs(target:GetDescendants()) do
        if module:IsA("ModuleScript") then
            if not moduleCache[module.Name] then
                moduleCache[module.Name] = module
            end
        end
    end
end

addToModuleCache(game.ReplicatedStorage)
addToModuleCache(game.ServerScriptService)

--[[
    Description: Requires a library

    Parameters:
        name [string]: The name of the library to require
--]]
function Server.loadLibrary(name)
    local lib = moduleCache[name]

    if not lib or not (lib:IsDescendantOf(sharedLibraries) or lib:IsDescendantOf(serverLibraries)) then
        warn("Could not find a server or shared library named", name)
    else
        return require(lib)
    end
end

--[[
    Description: Requires a module

    Parameters:
        name [string]: The name of the module to require
--]]
function Server.require(name)
    local module = moduleCache[name]

    if not module then
        warn("Could not find a server or shared module named", name)
    else
        return require(module)
    end
end

--[[
    Description: Requires and calls init() on all modules in the given directory

    Parameters:
        target [Instance]: The directory to require
--]]
function Server.loadAll(directory)
    for index,module in pairs(directory:GetDescendants()) do
        if module:IsA("ModuleScript") then
            coroutine.wrap(function()
                local success,result = pcall(require,module)
                if not success then
                    error("Failed to load "..module:GetFullName()..": "..result)
                else
                    if typeof(result)=="table" and typeof(result.init)=="function" then
                        result:init()
                    end
                end
            end)()
        end
    end
end

--[[
    Description: Builds a tree of folders to the intended destination if it doesn't exist

    Parameters:
        origin [Instance]: The starting point of the path
        path [string]: The path to create. Segments should be separated with periods "."

    Example local roduxReducers = Server.getPath(game.ServerScriptService,"Rodux.Reducers")
--]]
function Server.getPath(origin,path)
    local pathSegments = string.split(path,".")
    for index,segment in pairs(pathSegments) do
        if not origin:FindFirstChild(segment) then
            local folder = Instance.new("Folder")
            folder.Name = segment
            folder.Parent = origin
        end
        origin = origin[segment]
    end
    return origin
end

--[[
    Description: Returns a data stream with the specified name and class. If one doesn't exist, it will be created

    Parameters:
        name [string]: The name of the data stream
        className [string]: The name of the class
--]]
function Server.getDataStream(name, className)
    local dataStreamFolder = sharedFolder:FindFirstChild("DataStreams")
    -- We need to create a new data stream folder if one doesn't already exist
    if dataStreamFolder == nil then
        dataStreamFolder = Instance.new("Folder")
        dataStreamFolder.Name = "DataStreams"
        dataStreamFolder.Parent = sharedFolder
    end

    local dataStream = Misc.firstFindChildOfNameAndClass(dataStreamFolder, name, className)

    -- A new data stream should be created if it doesn't already exist
    if dataStream == nil then
        dataStream = Instance.new(className)
        dataStream.Name = name
        dataStream.Parent = dataStreamFolder
    end
    
    return dataStream
end

--[[
    Description: Returns wether or not the player is firing/invoking the RemoteEvent or RemoteFunction faster then the specified rate.
    In order for this to work, this function should be called every single time the RemoteEvent or RemoteFunction is fired.

    Parameters:
        dataStream [RemoteEvent or RemoteFunction]: The data stream being fired or invoked
        rate [number]: The minimum amount of seconds that should pass between each invoke
        player [Player]: The player firing/invoking the RemoteEvent or RemoteFunction
--]]
local rateCache = {}
function Server.isDataStreamRateOk(dataStream, rate, player)
	local dataStreamCache = rateCache[dataStream] or {}
    local lastInvoke = dataStreamCache[player] or 0
    local now = tick()
	
	if (now - lastInvoke) < rate then
		--print(player, "is over the firing rate for", dataStream)
		
		return false
	end
	
	dataStreamCache[player]	= now
    rateCache[dataStream] = dataStreamCache
    
	return true
end

return Server